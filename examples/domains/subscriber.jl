include(joinpath(@__DIR__, "..", "common", "imports.jl"))

include(joinpath(@__DIR__, "..", "common", "cli.jl"))
include(joinpath(@__DIR__, "transmission_data.jl"))

const CYCLE_SECONDS = 1

function main()
    set_log_level_from_env_or(:info)

    show_help_if_requested(ARGS, [
        "Subscriber of the domain example.",
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
    subscriber = create(subscriber_builder(service))

    println("subscribed to: [domain: \"$(domain)\", service: \"$(service_name)\"]")
    while true
        Iceoryx2.wait(node, CYCLE_SECONDS, 0)
        sample = receive(subscriber)
        while sample !== nothing
            println("received: ", payload(sample)[1])
            sample = receive(subscriber)
        end
    end
end

main()
