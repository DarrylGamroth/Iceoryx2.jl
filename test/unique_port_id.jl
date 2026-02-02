@testset "UniquePortId" begin
    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, unique_node_name())
    node = Iceoryx2.create(node_builder, Iceoryx2.ServiceType.IPC)

    event_name = unique_service_name()
    event_builder = Iceoryx2.event(Iceoryx2.service_builder(node, event_name))
    event_factory = Iceoryx2.open_or_create(event_builder)

    pubsub_name = unique_service_name()
    pubsub_builder = Iceoryx2.publish_subscribe(Iceoryx2.service_builder(node, pubsub_name), UInt64)
    pubsub_factory = Iceoryx2.open_or_create(pubsub_builder)

    listener1 = Iceoryx2.create(Iceoryx2.listener_builder(event_factory))
    listener2 = Iceoryx2.create(Iceoryx2.listener_builder(event_factory))
    notifier1 = Iceoryx2.create(Iceoryx2.notifier_builder(event_factory))
    notifier2 = Iceoryx2.create(Iceoryx2.notifier_builder(event_factory))

    publisher1 = Iceoryx2.create(Iceoryx2.publisher_builder(pubsub_factory))
    publisher2 = Iceoryx2.create(Iceoryx2.publisher_builder(pubsub_factory))
    subscriber1 = Iceoryx2.create(Iceoryx2.subscriber_builder(pubsub_factory))
    subscriber2 = Iceoryx2.create(Iceoryx2.subscriber_builder(pubsub_factory))

    ids = Any[
        Iceoryx2.id(publisher1),
        Iceoryx2.id(subscriber1),
        Iceoryx2.id(notifier1),
        Iceoryx2.id(listener1),
    ]
    for uid in ids
        @test any(!=(0x00), Iceoryx2.bytes(uid))
    end

    listener_id1 = Iceoryx2.id(listener1)
    listener_id1b = Iceoryx2.id(listener1)
    listener_id2 = Iceoryx2.id(listener2)
    @test listener_id1 == listener_id1b
    @test !(listener_id1 < listener_id1b)
    @test listener_id1 != listener_id2
    @test (listener_id1 < listener_id2) || (listener_id2 < listener_id1)

    notifier_id1 = Iceoryx2.id(notifier1)
    notifier_id2 = Iceoryx2.id(notifier2)
    @test notifier_id1 != notifier_id2
    @test (notifier_id1 < notifier_id2) || (notifier_id2 < notifier_id1)

    publisher_id1 = Iceoryx2.id(publisher1)
    publisher_id2 = Iceoryx2.id(publisher2)
    @test publisher_id1 != publisher_id2
    @test (publisher_id1 < publisher_id2) || (publisher_id2 < publisher_id1)

    subscriber_id1 = Iceoryx2.id(subscriber1)
    subscriber_id2 = Iceoryx2.id(subscriber2)
    @test subscriber_id1 != subscriber_id2
    @test (subscriber_id1 < subscriber_id2) || (subscriber_id2 < subscriber_id1)

    for uid in ids
        close(uid)
    end
    close(listener_id1)
    close(listener_id1b)
    close(listener_id2)
    close(notifier_id1)
    close(notifier_id2)
    close(publisher_id1)
    close(publisher_id2)
    close(subscriber_id1)
    close(subscriber_id2)
    close(listener2)
    close(listener1)
    close(notifier2)
    close(notifier1)
    close(publisher2)
    close(publisher1)
    close(subscriber2)
    close(subscriber1)
    close(pubsub_factory)
    close(event_factory)
    close(node)
end
