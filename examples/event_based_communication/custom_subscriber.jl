include(joinpath(@__DIR__, "..", "common", "imports.jl"))

include(joinpath(@__DIR__, "transmission_data.jl"))
include(joinpath(@__DIR__, "pubsub_event.jl"))

const HISTORY_SIZE = 20

struct CustomSubscriber
    subscriber::Subscriber{TransmissionData,Nothing}
    notifier::Notifier
    listener::Listener
end

function pubsub_event_from_id(id::EventId)
    value = Int(id)
    for event in instances(PubSubEvent)
        if Int(event) == value
            return event
        end
    end
    return PubSubEvent.Unknown
end

function create_custom_subscriber(node::Node, service_name::AbstractString)
    pub_builder = publish_subscribe(service_builder(node, service_name), TransmissionData)
    history_size!(pub_builder, HISTORY_SIZE)
    subscriber_max_buffer_size!(pub_builder, HISTORY_SIZE)
    pub_service = open_or_create(pub_builder)

    event_service = open_or_create(event(service_builder(node, service_name)))

    listener = create(listener_builder(event_service))
    notifier = create(notifier_builder(event_service))
    subscriber = create(subscriber_builder(pub_service))

    notify!(notifier, EventId(Int(PubSubEvent.SubscriberConnected)))
    return CustomSubscriber(subscriber, notifier, listener)
end

function receive_with_ack(custom::CustomSubscriber)
    sample = receive(custom.subscriber)
    if sample !== nothing
        notify!(custom.notifier, EventId(Int(PubSubEvent.ReceivedSample)))
    end
    return sample
end

function handle_event!(custom::CustomSubscriber)
    event_id = try_wait_one(custom.listener)
    while event_id !== nothing
        event = pubsub_event_from_id(event_id)
        if event == PubSubEvent.SentHistory
            println("History delivered")
            sample = receive_with_ack(custom)
            while sample !== nothing
                println("  history: ", payload(sample)[1].x)
                sample = receive_with_ack(custom)
            end
        elseif event == PubSubEvent.SentSample
            sample = receive_with_ack(custom)
            while sample !== nothing
                println("received: ", payload(sample)[1].x)
                sample = receive_with_ack(custom)
            end
        elseif event == PubSubEvent.PublisherConnected
            println("new publisher connected")
        elseif event == PubSubEvent.PublisherDisconnected
            println("publisher disconnected")
        end
        event_id = try_wait_one(custom.listener)
    end
    return nothing
end
