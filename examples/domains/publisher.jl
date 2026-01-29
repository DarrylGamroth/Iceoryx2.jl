include(joinpath(@__DIR__, "..", "common", "imports.jl"))

include(joinpath(@__DIR__, "..", "common", "cli.jl"))
include(joinpath(@__DIR__, "transmission_data.jl"))

const CYCLE_SECONDS = 1

function main()
    set_log_level_from_env_or(:info)

    show_help_if_requested(ARGS, [
        "Publisher of the domain example.",
        "",
        "Use '-d' or '--domain' to specify the name of the domain.",
        "Use '-s' or '--service' to specify the name of the service.",
    ])

    domain = parse_arg(ARGS, "-d", "--domain", "iox2_")
    service_name = parse_arg(ARGS, "-s", "--service", "my_funky_service")

    cfg = config_from_ptr(global_config())
    global_prefix!(cfg, domain)

    builder = NodeBuilder()
    config!(builder, cfg)
    node = create(builder; service_type = :ipc)

    service = open_or_create(publish_subscribe(service_builder(node, service_name), TransmissionData))
    publisher = create(publisher_builder(service))

    counter = Int32(0)
    sample = SampleMut(publisher)
    try
        while true
            sleep(CYCLE_SECONDS)
            counter += 1

            loan_uninit!(publisher, sample)
            write_payload!(sample, TransmissionData(counter, counter * 3, counter * 812.12))
            send!(sample)

            println("[domain: \"$(domain)\", service: \"$(service_name)\"] Send sample $(counter)...")
        end
    catch err
        err isa InterruptException || rethrow()
    finally
        close(sample)
        close(publisher)
        close(service)
        close(node)
    end
end

main()
