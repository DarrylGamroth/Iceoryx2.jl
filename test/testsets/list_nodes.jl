@testset "ListNodes" begin
    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, "iceoryx2_julia_test_node_list")
    node = Iceoryx2.create(builder; service_type=:ipc)

    count = Ref(0)
    Iceoryx2.list_nodes(service_type=:ipc) do _state, _node_id, _node_id_str, _node_name, _config
        count[] += 1
        return :stop
    end
    @test count[] >= 1

    close(node)
end
