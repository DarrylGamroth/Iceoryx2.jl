@testset "StaticConfigFields" begin
    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, unique_node_name())
    node = Iceoryx2.create(builder, TEST_SERVICE_TYPE)

    try
        event_builder = Iceoryx2.event(Iceoryx2.service_builder(node, unique_service_name()))
        Iceoryx2.max_notifiers!(event_builder, 2)
        Iceoryx2.max_listeners!(event_builder, 3)
        Iceoryx2.max_nodes!(event_builder, 4)
        Iceoryx2.event_id_max_value!(event_builder, 128)
        Iceoryx2.deadline!(event_builder, 1, 2)
        Iceoryx2.notifier_created_event!(event_builder, 7)
        Iceoryx2.notifier_dead_event!(event_builder, 8)
        Iceoryx2.notifier_dropped_event!(event_builder, 9)
        event_factory = Iceoryx2.create(event_builder)
        try
            config = Iceoryx2.static_config(event_factory)
            @test Iceoryx2.max_notifiers(config) == 2
            @test Iceoryx2.max_listeners(config) == 3
            @test Iceoryx2.max_nodes(config) == 4
            @test Iceoryx2.event_id_max_value(config) == 128
            @test Iceoryx2.deadline(config) == (UInt64(1), UInt32(2))
            @test Int(Iceoryx2.notifier_created_event(config)) == 7
            @test Int(Iceoryx2.notifier_dead_event(config)) == 8
            @test Int(Iceoryx2.notifier_dropped_event(config)) == 9
        finally
            close(event_factory)
        end

        pubsub_builder = Iceoryx2.publish_subscribe(Iceoryx2.service_builder(node, unique_service_name()), UInt64)
        Iceoryx2.max_publishers!(pubsub_builder, 2)
        Iceoryx2.max_subscribers!(pubsub_builder, 3)
        Iceoryx2.max_nodes!(pubsub_builder, 4)
        Iceoryx2.history_size!(pubsub_builder, 1)
        Iceoryx2.subscriber_max_buffer_size!(pubsub_builder, 5)
        Iceoryx2.subscriber_max_borrowed_samples!(pubsub_builder, 6)
        Iceoryx2.enable_safe_overflow!(pubsub_builder, true)
        pubsub_factory = Iceoryx2.create(pubsub_builder)
        try
            config = Iceoryx2.static_config(pubsub_factory)
            @test Iceoryx2.max_publishers(config) == 2
            @test Iceoryx2.max_subscribers(config) == 3
            @test Iceoryx2.max_nodes(config) == 4
            @test Iceoryx2.history_size(config) == 1
            @test Iceoryx2.subscriber_max_buffer_size(config) == 5
            @test Iceoryx2.subscriber_max_borrowed_samples(config) == 6
            @test Iceoryx2.enable_safe_overflow(config)
            details = Iceoryx2.payload(Iceoryx2.message_type_details(config))
            @test Iceoryx2.type_name(details) == "u64"
            @test Iceoryx2.type_size(details) == sizeof(UInt64)
            @test Iceoryx2.type_alignment(details) == Base.datatype_alignment(UInt64)
        finally
            close(pubsub_factory)
        end

        rr_builder = Iceoryx2.request_response(Iceoryx2.service_builder(node, unique_service_name()), UInt32, UInt64)
        Iceoryx2.max_clients!(rr_builder, 2)
        Iceoryx2.max_servers!(rr_builder, 3)
        Iceoryx2.max_nodes!(rr_builder, 4)
        Iceoryx2.max_loaned_requests!(rr_builder, 5)
        Iceoryx2.max_response_buffer_size!(rr_builder, 6)
        Iceoryx2.max_active_requests_per_client!(rr_builder, 7)
        Iceoryx2.max_borrowed_responses_per_pending_response!(rr_builder, 8)
        Iceoryx2.enable_safe_overflow_for_requests!(rr_builder, true)
        Iceoryx2.enable_safe_overflow_for_responses!(rr_builder, true)
        rr_factory = Iceoryx2.create(rr_builder)
        try
            config = Iceoryx2.static_config(rr_factory)
            @test Iceoryx2.max_clients(config) == 2
            @test Iceoryx2.max_servers(config) == 3
            @test Iceoryx2.max_nodes(config) == 4
            @test Iceoryx2.max_loaned_requests(config) == 5
            @test Iceoryx2.max_response_buffer_size(config) == 6
            @test Iceoryx2.max_active_requests_per_client(config) == 7
            @test Iceoryx2.max_borrowed_responses_per_pending_response(config) == 8
            @test Iceoryx2.enable_safe_overflow_for_requests(config)
            @test Iceoryx2.enable_safe_overflow_for_responses(config)
            request_details = Iceoryx2.payload(Iceoryx2.request_message_type_details(config))
            response_details = Iceoryx2.payload(Iceoryx2.response_message_type_details(config))
            @test Iceoryx2.type_name(request_details) == "u32"
            @test Iceoryx2.type_size(request_details) == sizeof(UInt32)
            @test Iceoryx2.type_name(response_details) == "u64"
            @test Iceoryx2.type_size(response_details) == sizeof(UInt64)
        finally
            close(rr_factory)
        end

        bb_builder = Iceoryx2.blackboard_creator(Iceoryx2.service_builder(node, unique_service_name()), UInt64)
        Iceoryx2.max_readers!(bb_builder, 2)
        Iceoryx2.max_nodes!(bb_builder, 3)
        Iceoryx2.add!(bb_builder, UInt64(1), UInt64(0))
        blackboard_factory = Iceoryx2.create(bb_builder)
        try
            config = Iceoryx2.static_config(blackboard_factory)
            @test Iceoryx2.max_readers(config) == 2
            @test Iceoryx2.max_writers(config) >= 0
            @test Iceoryx2.max_nodes(config) == 3
            details = Iceoryx2.type_details(config)
            @test Iceoryx2.type_name(details) == "u64"
            @test Iceoryx2.type_size(details) == sizeof(UInt64)
        finally
            close(blackboard_factory)
        end
    finally
        close(node)
    end
end
