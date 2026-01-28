include(joinpath(@__DIR__, "..", "common", "imports.jl"))

include(joinpath(@__DIR__, "..", "common", "static_types.jl"))

const CYCLE_SECONDS = 1

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(); service_type = :ipc)

    builder = publish_subscribe(service_builder(node, "CrossLanguageContainer"), StaticVector{UInt64, 32})
    builder = user_header(builder, StaticString{64})
    history_size!(builder, 5)
    subscriber_max_buffer_size!(builder, 5)
    enable_safe_overflow!(builder, false)
    service = open_or_create(builder)

    subscriber = create(subscriber_builder(service))

    println("Subscriber ready to receive data!")
    while true
        Iceoryx2.wait(node, CYCLE_SECONDS, 0)
        sample = receive(subscriber)
        while sample !== nothing
            println("received: ", payload(sample)[1], ", user_header: ", user_header(sample)[1])
            sample = receive(subscriber)
        end
    end
end

main()
