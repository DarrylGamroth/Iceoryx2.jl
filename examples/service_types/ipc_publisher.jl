include(joinpath(@__DIR__, "..", "common", "imports.jl"))

const CYCLE_MILLIS = 750

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(); service_type = :ipc)

    builder = publish_subscribe(service_builder(node, "Service-Variants-Example"), UInt64)
    service = open_or_create(builder)
    publisher = create(publisher_builder(service))

    counter = UInt64(0)
    while true
        sleep_or_interrupt(CYCLE_MILLIS / 1000) || break
        println("send: ", counter)
        send_copy(publisher, counter)
        counter += 1
    end
end

main()
