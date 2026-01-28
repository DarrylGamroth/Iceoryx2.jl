include(joinpath(@__DIR__, "..", "common", "imports.jl"))

include(joinpath(@__DIR__, "transmission_data.jl"))
include(joinpath(@__DIR__, "pubsub_event.jl"))

const HISTORY_SIZE = 20

struct CustomPublisher
    publisher::Publisher{TransmissionData,Nothing}
    listener::Listener
    notifier::Notifier
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

function create_custom_publisher(node::Node, service_name::AbstractString)
    pub_builder = publish_subscribe(service_builder(node, service_name), TransmissionData)
    history_size!(pub_builder, HISTORY_SIZE)
    subscriber_max_buffer_size!(pub_builder, HISTORY_SIZE)
    pub_service = open_or_create(pub_builder)

    event_service = open_or_create(event(service_builder(node, service_name)))

    notifier = create(notifier_builder(event_service))
    listener = create(listener_builder(event_service))
    publisher = create(publisher_builder(pub_service))

    notify!(notifier, EventId(Int(PubSubEvent.PublisherConnected)))
    return CustomPublisher(publisher, listener, notifier)
end

function handle_event!(custom::CustomPublisher)
    event_id = try_wait_one(custom.listener)
    while event_id !== nothing
        event = pubsub_event_from_id(event_id)
        if event == PubSubEvent.SubscriberConnected
            println("new subscriber connected - delivering history")
            # update_connections! is not exposed yet; we still emit SentHistory
            notify!(custom.notifier, EventId(Int(PubSubEvent.SentHistory)))
        elseif event == PubSubEvent.SubscriberDisconnected
            println("subscriber disconnected")
        elseif event == PubSubEvent.ReceivedSample
            println("subscriber has consumed sample")
        end
        event_id = try_wait_one(custom.listener)
    end
    return nothing
end

function send_sample!(custom::CustomPublisher, counter::UInt64)
    sample = loan_uninit(custom.publisher)
    write_payload!(sample, TransmissionData(Int32(counter), Int32(counter), Float64(counter) * 812.12))
    send!(sample)
    notify!(custom.notifier, EventId(Int(PubSubEvent.SentSample)))
    return nothing
end
