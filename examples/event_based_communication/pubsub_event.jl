@enum PubSubEvent::UInt8 begin
    PublisherConnected = 0
    PublisherDisconnected = 1
    SubscriberConnected = 2
    SubscriberDisconnected = 3
    SentSample = 4
    ReceivedSample = 5
    SentHistory = 6
    Unknown = 7
end

Base.Int(event::PubSubEvent) = Int(UInt8(event))
