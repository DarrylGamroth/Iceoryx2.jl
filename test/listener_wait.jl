@testset "ListenerWait" begin
    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, unique_node_name())
    node = Iceoryx2.create(node_builder, TEST_SERVICE_TYPE)

    event_builder = Iceoryx2.event(Iceoryx2.service_builder(node, unique_service_name()))
    event_factory = Iceoryx2.open_or_create(event_builder)
    notifier = Iceoryx2.create(Iceoryx2.notifier_builder(event_factory))
    listener = Iceoryx2.create(Iceoryx2.listener_builder(event_factory))

    @test Iceoryx2.try_wait(listener) do _, _
        error("callback must not run without notifications")
    end == 0

    Iceoryx2.notify!(notifier)
    event_id = Ref{Union{Nothing, Iceoryx2.EventId}}(nothing)
    @test Iceoryx2.timed_wait(listener, 1, 0) do event, count
        event_id[] = event
        @test count == 1
    end == 1
    @test event_id[] !== nothing

    called = Ref(false)
    Iceoryx2.notify!(notifier, Iceoryx2.EventId(3))
    @test Iceoryx2.timed_wait(listener, 1, 0) do event, count
        @test Int(event) == 3
        @test count == 1
        called[] = true
    end == 1
    @test called[]

    Iceoryx2.notify!(notifier, Iceoryx2.EventId(4))
    @test_throws ErrorException Iceoryx2.try_wait(listener) do _, _
        error("listener callback failure")
    end

    close(listener)
    close(notifier)
    close(event_factory)
    close(node)
end
