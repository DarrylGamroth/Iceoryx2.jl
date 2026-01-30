include(joinpath(@__DIR__, "..", "common", "imports.jl"))

include(joinpath(@__DIR__, "pubsub_event.jl"))

const CYCLE_MILLIS = 1000

function main()
    set_log_level_from_env_or(:info)
    service_name = "service_1"

    builder = NodeBuilder()
    name!(builder, "publisher 1")
    node = create(builder)

    service = open_service(node, service_name)

    publisher = create(publisher_builder(service.pubsub))
    notifier_builder_obj = notifier_builder(service.event)
    default_event_id!(notifier_builder_obj, EventId(Int(PubSubEvent.SentSample)))
    notifier = create(notifier_builder_obj)

    counter = UInt64(0)

    waitset = create(WaitsetBuilder(ServiceType.IPC))
    _cycle_guard = attach_interval(waitset, 0, CYCLE_MILLIS * 1_000_000)

    wait_and_process(waitset) do _attachment_id
        println("$(service_name): Send sample $(counter) ...")
        send_copy(publisher, counter)
        notify!(notifier)
        counter += 1
        return :continue
    end
end

main()
