@testset "PerfGates" begin
    data = UInt64[0x1, 0x2, 0x3, 0x4]
    slice = Iceoryx2.Slice{UInt64}(pointer(data), length(data))

    @test @inferred(length(slice)) == 4
    @test @allocated(length(slice)) == 0

    @test @inferred(slice[2]) == UInt64(0x2)
    @test @allocated(slice[2]) == 0

    @test @inferred(Iceoryx2._callback_progression(:continue)) == Iceoryx2.Iceoryx2FFI.iox2_callback_progression_e_CONTINUE
    @test @allocated(Iceoryx2._callback_progression(:continue)) == 0

    struct NodeAllocHandler end
    (::NodeAllocHandler)(::Any, ::Any, ::Cstring, ::Any, ::Any) = true
    node_handler = Iceoryx2.NodeListHandler(NodeAllocHandler())
    list_nodes_alloc(handler::Iceoryx2.AbstractNodeListHandler) =
        @allocated Iceoryx2.list_nodes(handler; service_type=:ipc)
    @test list_nodes_alloc(node_handler) > 0
end
