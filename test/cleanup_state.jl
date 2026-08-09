function _assert_cleanup_state(factory)
    state = Iceoryx2.try_cleanup_dead_nodes(factory)
    @test state isa Iceoryx2.CleanupState
    @test state.cleanups >= 0
    @test state.failed_cleanups >= 0

    blocking_state = Iceoryx2.blocking_cleanup_dead_nodes(factory, 0, 0)
    @test blocking_state isa Iceoryx2.CleanupState
    @test blocking_state.cleanups >= 0
    @test blocking_state.failed_cleanups >= 0

    real_timeout_state = Iceoryx2.blocking_cleanup_dead_nodes(factory, 0.0)
    @test real_timeout_state isa Iceoryx2.CleanupState
end

@testset "CleanupState" begin
    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, unique_node_name())
    node = Iceoryx2.create(builder, TEST_SERVICE_TYPE)

    try
        node_cleanup = Iceoryx2.try_cleanup_dead_nodes(node)
        @test node_cleanup isa Iceoryx2.CleanupState
        @test node_cleanup.cleanups >= 0
        @test node_cleanup.failed_cleanups >= 0

        blocking_node_cleanup = Iceoryx2.blocking_cleanup_dead_nodes(
            node,
            0,
            0
        )
        @test blocking_node_cleanup isa Iceoryx2.CleanupState

        @test !Iceoryx2.force_remove_service(
            node,
            unique_service_name();
            messaging_pattern = :event
        )

        event_factory = Iceoryx2.create(Iceoryx2.event(Iceoryx2.service_builder(node, unique_service_name())))
        try
            _assert_cleanup_state(event_factory)
        finally
            close(event_factory)
        end

        pubsub_factory = Iceoryx2.create(
            Iceoryx2.publish_subscribe(Iceoryx2.service_builder(node, unique_service_name()), UInt64),
        )
        try
            _assert_cleanup_state(pubsub_factory)
        finally
            close(pubsub_factory)
        end

        rr_factory = Iceoryx2.create(
            Iceoryx2.request_response(Iceoryx2.service_builder(node, unique_service_name()), UInt64, UInt64),
        )
        try
            _assert_cleanup_state(rr_factory)
        finally
            close(rr_factory)
        end

        bb_builder = Iceoryx2.blackboard_creator(Iceoryx2.service_builder(node, unique_service_name()), UInt64)
        Iceoryx2.add!(bb_builder, UInt64(1), UInt64(0))
        blackboard_factory = Iceoryx2.create(bb_builder)
        try
            _assert_cleanup_state(blackboard_factory)
        finally
            close(blackboard_factory)
        end
    finally
        close(node)
    end
end
