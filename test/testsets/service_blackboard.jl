@testset "ServiceBlackboard" begin
    service_name = unique_service_name()
    @test !Iceoryx2.service_does_exist(service_name; service_type=:ipc, messaging_pattern=:blackboard)

    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, unique_node_name())
    node = Iceoryx2.create(node_builder; service_type=:ipc)

    svc_builder = Iceoryx2.service_builder(node, service_name)
    bb_builder = Iceoryx2.blackboard_creator(svc_builder)
    Iceoryx2.add_with_default!(bb_builder, UInt64(0), UInt64(42))
    factory = Iceoryx2.create(bb_builder)

    @test Iceoryx2.service_does_exist(service_name; service_type=:ipc, messaging_pattern=:blackboard)

    writer = Iceoryx2.create(Iceoryx2.writer_builder(factory))
    reader = Iceoryx2.create(Iceoryx2.reader_builder(factory))

    @test Iceoryx2.number_of_readers(factory) >= 1
    @test Iceoryx2.number_of_writers(factory) >= 1

    close(reader)
    close(writer)
    close(factory)
    close(node)
end
