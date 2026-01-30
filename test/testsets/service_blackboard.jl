@testset "ServiceBlackboard" begin
    service_name = unique_service_name()
    @test !Iceoryx2.service_does_exist(service_name; service_type=Iceoryx2.ServiceType.IPC, messaging_pattern=:blackboard)

    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, unique_node_name())
    node = Iceoryx2.create(node_builder)

    svc_builder = Iceoryx2.service_builder(node, service_name)
    bb_builder = Iceoryx2.blackboard_creator(svc_builder, UInt64)
    Iceoryx2.add!(bb_builder, UInt64(1), UInt64(0))
    factory = Iceoryx2.create(bb_builder)
    @test Iceoryx2.service_does_exist(service_name; service_type=Iceoryx2.ServiceType.IPC, messaging_pattern=:blackboard)
    close(factory)
    close(node)
end
