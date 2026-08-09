@testset "PerfGates" begin
    data = UInt64[0x1, 0x2, 0x3, 0x4]
    slice = Iceoryx2.Slice{UInt64}(pointer(data), length(data))

    @test @inferred(length(slice)) == 4
    @test @allocated(length(slice)) == 0

    @test @inferred(slice[2]) == UInt64(0x2)
    @test @allocated(slice[2]) == 0

    @test @inferred(Iceoryx2._callback_progression(:continue)) == Iceoryx2.Iceoryx2FFI.iox2_callback_progression_e_CONTINUE
    # Use a function barrier so top-level boxing is not charged to the callback.
    callback_progression_alloc(value::Symbol) = @allocated Iceoryx2._callback_progression(value)
    callback_progression_alloc(:continue)
    @test callback_progression_alloc(:continue) == 0
    @test_throws ArgumentError Iceoryx2._callback_progression(
        Iceoryx2.Iceoryx2FFI.iox2_callback_progression_e_CONTINUE,
    )

    struct BackpressureAllocHandler end
    (::BackpressureAllocHandler)(::Iceoryx2.BackpressureInfoRef) = Iceoryx2.BackpressureRetry

    struct DegradationAllocHandler end
    (::DegradationAllocHandler)(
        ::Iceoryx2.DegradationCause,
        ::Iceoryx2.DegradationInfoRef,
    ) = Iceoryx2.DegradationWarn

    struct NodeAllocHandler end
    (::NodeAllocHandler)(
        ::Iceoryx2.NodeState,
        ::Iceoryx2.NodeIdView,
        ::Cstring,
        ::Iceoryx2.NodeNameView,
        ::Iceoryx2.ConfigView,
    ) = true

    struct WaitSetAllocHandler end
    (::WaitSetAllocHandler)(::Iceoryx2.WaitSetAttachmentId) = true

    backpressure_handler = Iceoryx2.BackpressureHandler(BackpressureAllocHandler())
    degradation_handler = Iceoryx2.DegradationHandler(DegradationAllocHandler())
    node_handler = Iceoryx2.NodeListHandler(NodeAllocHandler())
    waitset_handler = Iceoryx2.WaitSetHandler{Iceoryx2.IPC}(WaitSetAllocHandler())

    @test @inferred(
        Iceoryx2._backpressure_handler_wrapper(C_NULL, backpressure_handler),
    ) == Iceoryx2.Iceoryx2FFI.iox2_backpressure_action_e_RETRY
    @test @inferred(
        Iceoryx2._degradation_handler_wrapper(
            Iceoryx2.Iceoryx2FFI.iox2_degradation_cause_e_CONNECTION_CORRUPTED,
            C_NULL,
            degradation_handler,
        ),
    ) == Iceoryx2.Iceoryx2FFI.iox2_degradation_action_e_WARN
    @test @inferred(
        Iceoryx2._node_list_wrapper(
            Iceoryx2.Iceoryx2FFI.iox2_node_state_e_ALIVE,
            C_NULL,
            Cstring(C_NULL),
            C_NULL,
            C_NULL,
            node_handler,
        ),
    ) == Iceoryx2.Iceoryx2FFI.iox2_callback_progression_e_CONTINUE
    @test @inferred(
        Iceoryx2._waitset_wrapper(C_NULL, waitset_handler),
    ) == Iceoryx2.Iceoryx2FFI.iox2_callback_progression_e_CONTINUE

    backpressure_callback_alloc(handler::Iceoryx2.BackpressureHandler) =
        @allocated Iceoryx2._backpressure_handler_wrapper(C_NULL, handler)
    degradation_callback_alloc(handler::Iceoryx2.DegradationHandler) =
        @allocated Iceoryx2._degradation_handler_wrapper(
            Iceoryx2.Iceoryx2FFI.iox2_degradation_cause_e_CONNECTION_CORRUPTED,
            C_NULL,
            handler,
        )
    node_callback_alloc(handler::Iceoryx2.NodeListHandler) =
        @allocated Iceoryx2._node_list_wrapper(
            Iceoryx2.Iceoryx2FFI.iox2_node_state_e_ALIVE,
            C_NULL,
            Cstring(C_NULL),
            C_NULL,
            C_NULL,
            handler,
        )
    waitset_callback_alloc(handler::Iceoryx2.WaitSetHandler) =
        @allocated Iceoryx2._waitset_wrapper(C_NULL, handler)

    backpressure_callback_alloc(backpressure_handler)
    degradation_callback_alloc(degradation_handler)
    node_callback_alloc(node_handler)
    waitset_callback_alloc(waitset_handler)
    @test backpressure_callback_alloc(backpressure_handler) == 0
    @test degradation_callback_alloc(degradation_handler) == 0
    @test node_callback_alloc(node_handler) == 0
    @test waitset_callback_alloc(waitset_handler) == 0

    list_nodes_alloc(handler::Iceoryx2.AbstractNodeListHandler) =
        @allocated Iceoryx2.list_nodes(handler; service_type=TEST_SERVICE_TYPE)
    Iceoryx2.list_nodes(node_handler; service_type=TEST_SERVICE_TYPE)
    @test list_nodes_alloc(node_handler) <= 128
end
