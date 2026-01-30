include(joinpath(@__DIR__, "..", "common", "imports.jl"))

const CYCLE_SECONDS = 1

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(ServiceType.IPC))

    verifier = AttributeVerifier()
    require!(verifier, "camera_resolution", "1920x1080")
    require_key!(verifier, "dds_service_mapping")

    builder = publish_subscribe(service_builder(node, "Service/With/Properties"), UInt64)
    service = open_with_attributes(builder, verifier)

    subscriber = create(subscriber_builder(service))
    println("defined service attributes: ", attributes(service))
    sample = Sample(subscriber)

    try
        while true
            sleep(CYCLE_SECONDS)
            while receive!(subscriber, sample)
                try
                    println("received: ", payload(sample)[1])
                finally
                    close(sample)
                end
            end
        end
    catch err
        err isa InterruptException || rethrow()
    finally
        close(sample)
        close(subscriber)
        close(service)
        close(node)
    end
end

main()
