include(joinpath(@__DIR__, "..", "common", "imports.jl"))

include(joinpath(@__DIR__, "transmission_data.jl"))

const CYCLE_SECONDS = 1

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(ServiceType.IPC))

    builder = publish_subscribe(service_builder(node, "My/Funk/ServiceName"), TransmissionData)
    service = open_or_create(builder)
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

            println("Send sample $(counter)...")
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
