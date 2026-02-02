@testset "ListenerWait" begin
    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, unique_node_name())
    node = Iceoryx2.create(node_builder, Iceoryx2.ServiceType.IPC)

    event_builder = Iceoryx2.event(Iceoryx2.service_builder(node, unique_service_name()))
    event_factory = Iceoryx2.open_or_create(event_builder)
    notifier = Iceoryx2.create(Iceoryx2.notifier_builder(event_factory))
    listener = Iceoryx2.create(Iceoryx2.listener_builder(event_factory))

    @test Iceoryx2.try_wait_one(listener) === nothing

    Iceoryx2.notify!(notifier)
    event_id = Iceoryx2.timed_wait_one(listener, 1, 0)
    @test event_id !== nothing

    called = Ref(false)
    Iceoryx2.notify!(notifier, Iceoryx2.EventId(3))
    Iceoryx2.timed_wait_all(listener, 1, 0) do _event
        called[] = true
    end
    @test called[]

    close(listener)
    close(notifier)
    close(event_factory)
    close(node)
end
