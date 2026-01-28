include(joinpath(@__DIR__, "..", "common", "imports.jl"))

@enum PubSubEvent::UInt8 begin
    PublisherConnected = 0
    PublisherDisconnected = 1
    SubscriberConnected = 2
    SubscriberDisconnected = 3
    SentSample = 4
    ReceivedSample = 5
    SentHistory = 6
    ProcessDied = 7
    Unknown = 8
end

Base.Int(event::PubSubEvent) = Int(UInt8(event))

function open_service(node::Node, service_name::AbstractString)
    pubsub = Iceoryx2.open(publish_subscribe(service_builder(node, service_name), UInt64))
    event_service = Iceoryx2.open(event(service_builder(node, service_name)))
    return (event = event_service, pubsub = pubsub)
end
