include(joinpath(@__DIR__, "..", "common", "imports.jl"))

const CYCLE_SECONDS = 1

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(); service_type = :ipc)

    builder = publish_subscribe(service_builder(node, "Service With Dynamic Data"), UInt8; variant = :dynamic)
    service = open_or_create(builder)
    subscriber = create(subscriber_builder(service))

    println("Subscriber ready to receive data!")

    while true
        Iceoryx2.wait(node, CYCLE_SECONDS, 0)
        sample = receive(subscriber)
        while sample !== nothing
            println("received: ", length(payload(sample)), " bytes")
            sample = receive(subscriber)
        end
    end
end

main()
