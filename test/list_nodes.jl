@testset "ListNodes" begin
    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, "iceoryx2_julia_test_node_list")
    node = Iceoryx2.create(builder, TEST_SERVICE_TYPE)

    count = Ref(0)
    Iceoryx2.list_nodes(service_type = TEST_SERVICE_TYPE) do _state,
    _node_id, _node_id_str, _node_name, _config
        count[] += 1
        return :stop
    end
    @test count[] >= 1

    @test_throws ErrorException Iceoryx2.list_nodes(service_type = TEST_SERVICE_TYPE) do _,
    _, _, _, _
        error("node callback failure")
    end

    close(node)
end
