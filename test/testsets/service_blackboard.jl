@testset "ServiceBlackboard" begin
    service_name = unique_service_name()
    @test !Iceoryx2.service_does_exist(service_name; service_type=:ipc, messaging_pattern=:blackboard)

    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, unique_node_name())
    node = Iceoryx2.create(node_builder; service_type=:ipc)

    svc_builder = Iceoryx2.service_builder(node, service_name)
    bb_builder = Iceoryx2.blackboard_creator(svc_builder)
    @test_throws ArgumentError Iceoryx2.create(bb_builder)
    @test !Iceoryx2.service_does_exist(service_name; service_type=:ipc, messaging_pattern=:blackboard)
    close(node)
end
