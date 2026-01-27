@testset "ServiceEvent" begin
    service_name = unique_service_name()
    @test !Iceoryx2.service_does_exist(service_name; service_type=:ipc, messaging_pattern=:event)

    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, unique_node_name())
    node = Iceoryx2.create(node_builder; service_type=:ipc)

    svc_builder = Iceoryx2.service_builder(node, service_name)
    event_builder = Iceoryx2.event(svc_builder)
    factory = Iceoryx2.open_or_create(event_builder)

    @test Iceoryx2.service_does_exist(service_name; service_type=:ipc, messaging_pattern=:event)

    notifier = Iceoryx2.create(Iceoryx2.notifier_builder(factory))
    listener = Iceoryx2.create(Iceoryx2.listener_builder(factory))

    @test Iceoryx2.number_of_notifiers(factory) >= 1
    @test Iceoryx2.number_of_listeners(factory) >= 1
    @test Iceoryx2.notify!(notifier) >= 0

    close(listener)
    close(notifier)
    close(factory)
    close(node)
end
