@testset "Node" begin
    node_name = unique_node_name()
    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, node_name)
    node = Iceoryx2.create(builder, Iceoryx2.ServiceType.IPC)
    @test string(Iceoryx2.name(node)) == node_name
    Iceoryx2.wait(node, 0, 1)

    builder2 = Iceoryx2.NodeBuilder()
    Iceoryx2.signal_handling_mode!(builder2, Iceoryx2.Iceoryx2FFI.iox2_signal_handling_mode_e_DISABLED)
    node2 = Iceoryx2.create(builder2, Iceoryx2.ServiceType.IPC)
    @test Iceoryx2.signal_handling_mode(node2) == Iceoryx2.Iceoryx2FFI.iox2_signal_handling_mode_e_DISABLED

    id1 = Iceoryx2.id(node)
    id1b = Iceoryx2.id(node)
    id2 = Iceoryx2.id(node2)
    @test id1 == id1b
    @test id1 != id2
    @test Iceoryx2.pid(id1) == Iceoryx2.pid(id2)

    close(id1)
    close(id1b)
    close(id2)
    close(node)
    close(node2)
end
