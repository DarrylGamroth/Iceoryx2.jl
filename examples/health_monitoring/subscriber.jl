include(joinpath(@__DIR__, "..", "common", "imports.jl"))

include(joinpath(@__DIR__, "pubsub_event.jl"))

const REACTION_BUFFER_MILLIS = 100
const CYCLE_TIME_1_MILLIS = 1000 + REACTION_BUFFER_MILLIS
const CYCLE_TIME_2_MILLIS = 1500 + REACTION_BUFFER_MILLIS
const NODE_DEAD = Iceoryx2.Iceoryx2FFI.iox2_node_state_e_DEAD

function find_and_cleanup_dead_nodes()
    list_nodes(; config = global_config()) do state, node_id_view, _node_id_str, node_name, _cfg
        if state == NODE_DEAD
            print("detected dead node: ")
            if isvalid(node_name)
                print(string(node_name))
            end
            println()
            node_id = to_owned(node_id_view)
            remove_stale_resources(node_id)
            close(node_id)
        end
        return :continue
    end
    return nothing
end

function handle_incoming_events(listener::Listener, subscriber::Subscriber{UInt64,Nothing}, service_name::AbstractString)
    try_wait_all(listener) do event_id
        if Int(event_id) == Int(PubSubEvent.ProcessDied)
            println("$(service_name): process died!")
        elseif Int(event_id) == Int(PubSubEvent.PublisherConnected)
            println("$(service_name): publisher connected!")
        elseif Int(event_id) == Int(PubSubEvent.PublisherDisconnected)
            println("$(service_name): publisher disconnected!")
        elseif Int(event_id) == Int(PubSubEvent.SentSample)
            sample = receive(subscriber)
            if sample !== nothing
                println("$(service_name): Received sample ", payload(sample)[1], " ...")
            end
        end
    end
    return nothing
end

function main()
    set_log_level_from_env_or(:info)

    service_name_1 = "service_1"
    service_name_2 = "service_2"

    builder = NodeBuilder()
    name!(builder, "subscriber")
    node = create(builder; service_type = :ipc)

    service_1 = open_service(node, service_name_1)
    service_2 = open_service(node, service_name_2)

    subscriber_1 = create(subscriber_builder(service_1.pubsub))
    subscriber_2 = create(subscriber_builder(service_2.pubsub))
    listener_1 = create(listener_builder(service_1.event))
    listener_2 = create(listener_builder(service_2.event))

    waitset = create(WaitsetBuilder(); service_type = :ipc)

    deadline_1 = deadline(listener_1)
    deadline_2 = deadline(listener_2)

    seconds_1, nanos_1 = deadline_1 === nothing ? (0, CYCLE_TIME_1_MILLIS * 1_000_000) : deadline_1
    seconds_2, nanos_2 = deadline_2 === nothing ? (0, CYCLE_TIME_2_MILLIS * 1_000_000) : deadline_2

    listener_1_guard = attach_deadline(waitset, file_descriptor(listener_1), seconds_1, nanos_1)
    listener_2_guard = attach_deadline(waitset, file_descriptor(listener_2), seconds_2, nanos_2)

    on_event = function (attachment_id)
        if has_missed_deadline(attachment_id, listener_1_guard)
            println("$(service_name_1): violated contract and did not send a message after $(CYCLE_TIME_1_MILLIS)ms")
            find_and_cleanup_dead_nodes()
        end

        if has_missed_deadline(attachment_id, listener_2_guard)
            println("$(service_name_2): violated contract and did not send a message after $(CYCLE_TIME_2_MILLIS)ms")
            find_and_cleanup_dead_nodes()
        end

        if has_event_from(attachment_id, listener_1_guard)
            handle_incoming_events(listener_1, subscriber_1, service_name_1)
        end

        if has_event_from(attachment_id, listener_2_guard)
            handle_incoming_events(listener_2, subscriber_2, service_name_2)
        end

        return :continue
    end

    wait_and_process(waitset, on_event)
end

main()
