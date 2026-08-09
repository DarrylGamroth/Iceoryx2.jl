@testset "NodeState" begin
    node_name = unique_node_name()
    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, node_name)
    node = Iceoryx2.create(builder, TEST_SERVICE_TYPE)
    target = string(Iceoryx2.name(node))

    found = Ref(false)
    state_val = Ref(Iceoryx2.NodeStateUndefined)
    Iceoryx2.list_nodes(service_type=TEST_SERVICE_TYPE) do state, _node_id, _node_id_str, node_name_view, _config
        if string(node_name_view) == target
            found[] = true
            state_val[] = state
            return :stop
        end
        return :continue
    end

    @test found[]
    @test state_val[] == Iceoryx2.NodeStateAlive

    node_id = Iceoryx2.id(node)
    close(node)
    result = Iceoryx2.remove_stale_resources(node_id; service_type=TEST_SERVICE_TYPE)
    @test result isa Bool
    close(node_id)
end
