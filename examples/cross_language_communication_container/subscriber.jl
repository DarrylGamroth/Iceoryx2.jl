include(joinpath(@__DIR__, "..", "common", "imports.jl"))

include(joinpath(@__DIR__, "..", "common", "static_types.jl"))

const CYCLE_SECONDS = 1

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(), ServiceType.IPC)

    builder = publish_subscribe(service_builder(node, "CrossLanguageContainer"), StaticVector{UInt64, 32})
    builder = user_header(builder, StaticString{64})
    history_size!(builder, 5)
    subscriber_max_buffer_size!(builder, 5)
    enable_safe_overflow!(builder, false)
    service = open_or_create(builder)

    subscriber = create(subscriber_builder(service))

    println("Subscriber ready to receive data!")
    sample = Sample(subscriber)
    try
        while true
            sleep(CYCLE_SECONDS)
            while receive!(subscriber, sample)
                try
                    println("received: ", payload(sample)[1], ", user_header: ", user_header(sample)[1])
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
