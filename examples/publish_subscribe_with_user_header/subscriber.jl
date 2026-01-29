include(joinpath(@__DIR__, "..", "common", "imports.jl"))

include(joinpath(@__DIR__, "custom_header.jl"))

const CYCLE_SECONDS = 1

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(); service_type = :ipc)

    builder = publish_subscribe(service_builder(node, "My/Funk/ServiceName"), UInt64)
    builder = user_header(builder, CustomHeader)
    service = open_or_create(builder)

    subscriber = create(subscriber_builder(service))

    println("Subscriber ready to receive data!")
    sample = Sample(subscriber)
    while true
        sleep_or_interrupt(CYCLE_SECONDS) || break
        while receive!(subscriber, sample)
            try
                println("received: ", payload(sample)[1], ", user_header: ", user_header(sample)[1])
            finally
                close(sample)
            end
        end
    end
end

main()
