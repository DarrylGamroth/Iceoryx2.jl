@testset "Node" begin
    node_name = unique_node_name()
    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, node_name)
    node = Iceoryx2.create(builder, TEST_SERVICE_TYPE)
    @test string(Iceoryx2.name(node)) == node_name
    Iceoryx2.wait(node, 0, 1)

    builder2 = Iceoryx2.NodeBuilder()
    @test_throws MethodError Iceoryx2.signal_handling_mode!(
        builder2,
        Iceoryx2.Iceoryx2FFI.iox2_signal_handling_mode_e_DISABLED
    )
    Iceoryx2.signal_handling_mode!(builder2, Iceoryx2.SignalHandlingModeDisabled)
    node2 = Iceoryx2.create(builder2, TEST_SERVICE_TYPE)
    @test Iceoryx2.signal_handling_mode(node2) == Iceoryx2.SignalHandlingModeDisabled

    id1 = Iceoryx2.id(node)
    id1b = Iceoryx2.id(node)
    id2 = Iceoryx2.id(node2)
    @test id1 == id1b
    @test isbitstype(typeof(id1))
    @test hash(id1) == hash(id1b)
    @test id1 != id2
    @test Iceoryx2.pid(id1) == Iceoryx2.pid(id2)

    node_id_alloc(n::Iceoryx2.Node) = @allocated Iceoryx2.id(n)
    Iceoryx2.id(node)
    @test node_id_alloc(node) == 0

    close(id1)
    close(id1b)
    close(id2)
    close(node)
    close(node2)
end
