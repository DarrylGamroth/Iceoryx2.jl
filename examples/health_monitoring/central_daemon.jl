include(joinpath(@__DIR__, "..", "common", "imports.jl"))

include(joinpath(@__DIR__, "pubsub_event.jl"))

const CYCLE_MILLIS = 100
const DEADLINE_SERVICE_1_MILLIS = 1500
const DEADLINE_SERVICE_2_MILLIS = 2000
const NODE_DEAD = Iceoryx2.Iceoryx2FFI.iox2_node_state_e_DEAD

function find_and_cleanup_dead_nodes()
    list_nodes(service_type=ServiceType.IPC, config=global_config()) do state, node_id_view, _node_id_str, node_name, _cfg
        if state == NODE_DEAD
            print("detected dead node: ")
            if isvalid(node_name)
                print(string(node_name))
            end
            println()
            node_id = to_owned(node_id_view)
            remove_stale_resources(node_id; service_type=ServiceType.IPC)
            close(node_id)
        end
        return :continue
    end
    return nothing
end

function main()
    set_log_level_from_env_or(:info)

    service_name_1 = "service_1"
    service_name_2 = "service_2"

    builder = NodeBuilder()
    name!(builder, "central daemon")
    node = create(builder, ServiceType.IPC)

    pubsub_1 = open_or_create(publish_subscribe(service_builder(node, service_name_1), UInt64))
    event_builder_1 = event(service_builder(node, service_name_1))
    deadline!(event_builder_1, 0, DEADLINE_SERVICE_1_MILLIS * 1_000_000)
    notifier_created_event!(event_builder_1, Int(PubSubEvent.PublisherConnected))
    notifier_dropped_event!(event_builder_1, Int(PubSubEvent.PublisherDisconnected))
    notifier_dead_event!(event_builder_1, Int(PubSubEvent.ProcessDied))
    event_1 = open_or_create(event_builder_1)

    pubsub_2 = open_or_create(publish_subscribe(service_builder(node, service_name_2), UInt64))
    event_builder_2 = event(service_builder(node, service_name_2))
    deadline!(event_builder_2, 0, DEADLINE_SERVICE_2_MILLIS * 1_000_000)
    notifier_created_event!(event_builder_2, Int(PubSubEvent.PublisherConnected))
    notifier_dropped_event!(event_builder_2, Int(PubSubEvent.PublisherDisconnected))
    notifier_dead_event!(event_builder_2, Int(PubSubEvent.ProcessDied))
    event_2 = open_or_create(event_builder_2)

    waitset = create(WaitsetBuilder(ServiceType.IPC))
    _cycle_guard = attach_interval(waitset, 0, CYCLE_MILLIS * 1_000_000)

    println("Central daemon up and running.")
    wait_and_process(waitset) do _attachment_id
        find_and_cleanup_dead_nodes()
        return :continue
    end
end

main()
