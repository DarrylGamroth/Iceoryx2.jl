@testset "NodeState" begin
    node_name = unique_node_name()
    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, node_name)
    node = Iceoryx2.create(builder, Iceoryx2.ServiceType.IPC)
    target = string(Iceoryx2.name(node))

    found = Ref(false)
    state_val = Ref(Iceoryx2.Iceoryx2FFI.iox2_node_state_e_UNDEFINED)
    Iceoryx2.list_nodes(service_type=Iceoryx2.ServiceType.IPC) do state, _node_id, _node_id_str, node_name_view, _config
        if string(node_name_view) == target
            found[] = true
            state_val[] = state
            return :stop
        end
        return :continue
    end

    @test found[]
    @test state_val[] == Iceoryx2.Iceoryx2FFI.iox2_node_state_e_ALIVE

    node_id = Iceoryx2.id(node)
    close(node)
    result = Iceoryx2.remove_stale_resources(node_id; service_type=Iceoryx2.ServiceType.IPC)
    @test result isa Bool
    close(node_id)
end
