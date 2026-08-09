@testset "BuilderTuning" begin
    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, unique_node_name())
    node = Iceoryx2.create(node_builder, TEST_SERVICE_TYPE)

    pubsub_builder = Iceoryx2.publish_subscribe(Iceoryx2.service_builder(node, unique_service_name()), UInt64)
    Iceoryx2.payload_alignment!(pubsub_builder, Base.datatype_alignment(UInt64))
    Iceoryx2.max_publishers!(pubsub_builder, 1)
    Iceoryx2.max_subscribers!(pubsub_builder, 1)
    Iceoryx2.history_size!(pubsub_builder, 0)
    Iceoryx2.subscriber_max_buffer_size!(pubsub_builder, 1)
    Iceoryx2.subscriber_max_borrowed_samples!(pubsub_builder, 1)
    Iceoryx2.enable_safe_overflow!(pubsub_builder, true)
    pubsub_factory = Iceoryx2.open_or_create(pubsub_builder)

    pubsub_attr_service = unique_service_name()
    pubsub_attr_spec = Iceoryx2.AttributeSpecifier()
    Iceoryx2.define!(pubsub_attr_spec, "purpose", "builder_tuning")
    pubsub_attr_builder = Iceoryx2.publish_subscribe(
        Iceoryx2.service_builder(node, pubsub_attr_service), UInt64)
    pubsub_attr_factory = Iceoryx2.create(pubsub_attr_builder, pubsub_attr_spec)
    pubsub_attr_verify = Iceoryx2.AttributeVerifier()
    Iceoryx2.require!(pubsub_attr_verify, "purpose", "builder_tuning")
    pubsub_attr_opener = Iceoryx2.publish_subscribe(Iceoryx2.service_builder(node, pubsub_attr_service), UInt64)
    pubsub_attr_factory2 = Iceoryx2.open(pubsub_attr_opener, pubsub_attr_verify)
    close(pubsub_attr_spec)
    close(pubsub_attr_verify)

    pub_builder = Iceoryx2.publisher_builder(pubsub_factory)
    Iceoryx2.name!(pub_builder, "publisher")
    Iceoryx2.max_loaned_samples!(pub_builder, 1)
    Iceoryx2.allocation_strategy!(pub_builder, Iceoryx2.AllocationStrategyBestFit)
    @test_throws MethodError Iceoryx2.allocation_strategy!(
        pub_builder,
        Iceoryx2.Iceoryx2FFI.iox2_allocation_strategy_e_BEST_FIT
    )
    Iceoryx2.backpressure_strategy!(pub_builder, :retry_until_delivered)
    pub = Iceoryx2.create(pub_builder)
    sub_builder = Iceoryx2.subscriber_builder(pubsub_factory)
    sub_name = Iceoryx2.PortName("subscriber")
    Iceoryx2.name!(sub_builder, sub_name)
    close(sub_name)
    Iceoryx2.buffer_size!(sub_builder, 1)
    Iceoryx2.history_request!(sub_builder, 0)
    sub = Iceoryx2.create(sub_builder)
    @test isvalid(pub)
    @test isvalid(sub)
    @test Iceoryx2.backpressure_strategy(pub) ==
          Iceoryx2.BackpressureStrategyRetryUntilDelivered
    @test string(Iceoryx2.name(pub)) == "publisher"
    @test string(Iceoryx2.name(sub)) == "subscriber"
    Iceoryx2.list_subscribers(pubsub_factory) do sub_details
        @test Iceoryx2.buffer_size(sub_details) == 1
        @test Iceoryx2.history_request(sub_details) == 0
        return false
    end

    rr_builder = Iceoryx2.request_response(
        Iceoryx2.service_builder(node, unique_service_name()), UInt64, UInt64)
    Iceoryx2.request_payload_alignment!(rr_builder, Base.datatype_alignment(UInt64))
    Iceoryx2.response_payload_alignment!(rr_builder, Base.datatype_alignment(UInt64))
    Iceoryx2.max_clients!(rr_builder, 1)
    Iceoryx2.max_servers!(rr_builder, 1)
    Iceoryx2.max_loaned_requests!(rr_builder, 1)
    Iceoryx2.max_response_buffer_size!(rr_builder, 1)
    Iceoryx2.enable_safe_overflow_for_requests!(rr_builder, true)
    Iceoryx2.enable_safe_overflow_for_responses!(rr_builder, true)
    Iceoryx2.max_active_requests_per_client!(rr_builder, 1)
    Iceoryx2.max_borrowed_responses_per_pending_response!(rr_builder, 1)
    rr_factory = Iceoryx2.open_or_create(rr_builder)

    rr_attr_service = unique_service_name()
    rr_attr_spec = Iceoryx2.AttributeSpecifier()
    Iceoryx2.define!(rr_attr_spec, "purpose", "builder_tuning")
    rr_attr_builder = Iceoryx2.request_response(Iceoryx2.service_builder(node, rr_attr_service), UInt64, UInt64)
    rr_attr_factory = Iceoryx2.create(rr_attr_builder, rr_attr_spec)
    rr_attr_verify = Iceoryx2.AttributeVerifier()
    Iceoryx2.require!(rr_attr_verify, "purpose", "builder_tuning")
    rr_attr_opener = Iceoryx2.request_response(Iceoryx2.service_builder(node, rr_attr_service), UInt64, UInt64)
    rr_attr_factory2 = Iceoryx2.open(rr_attr_opener, rr_attr_verify)
    close(rr_attr_spec)
    close(rr_attr_verify)

    client_builder = Iceoryx2.client_builder(rr_factory)
    server_builder = Iceoryx2.server_builder(rr_factory)
    Iceoryx2.name!(client_builder, "client")
    Iceoryx2.name!(server_builder, "server")
    Iceoryx2.max_active_requests!(client_builder, 1)
    Iceoryx2.allocation_strategy!(client_builder, Iceoryx2.AllocationStrategyPowerOfTwo)
    Iceoryx2.allocation_strategy!(server_builder, :static)
    @test_throws MethodError Iceoryx2.allocation_strategy!(
        client_builder,
        Iceoryx2.Iceoryx2FFI.iox2_allocation_strategy_e_POWER_OF_TWO
    )
    Iceoryx2.backpressure_strategy!(client_builder, :discard_data)
    Iceoryx2.backpressure_strategy!(server_builder, :retry_until_delivered)
    Iceoryx2.max_loaned_responses_per_request!(server_builder, 1)
    client = Iceoryx2.create(client_builder)
    server = Iceoryx2.create(server_builder)
    @test isvalid(client)
    @test isvalid(server)
    @test Iceoryx2.backpressure_strategy(client) ==
          Iceoryx2.BackpressureStrategyDiscardData
    @test Iceoryx2.max_active_requests(client) == 1
    @test string(Iceoryx2.name(client)) == "client"
    @test string(Iceoryx2.name(server)) == "server"
    Iceoryx2.list_clients(rr_factory) do details
        @test Iceoryx2.max_active_requests(details) == 1
        return false
    end

    event_builder = Iceoryx2.event(Iceoryx2.service_builder(node, unique_service_name()))
    Iceoryx2.max_notifiers!(event_builder, 1)
    Iceoryx2.max_listeners!(event_builder, 1)
    Iceoryx2.event_id_max_value!(event_builder, 128)
    event_factory = Iceoryx2.open_or_create(event_builder)
    notifier_builder = Iceoryx2.notifier_builder(event_factory)
    Iceoryx2.name!(notifier_builder, "notifier")
    Iceoryx2.default_event_id!(notifier_builder, Iceoryx2.EventId(7))
    notifier = Iceoryx2.create(notifier_builder)
    listener_builder = Iceoryx2.listener_builder(event_factory)
    Iceoryx2.name!(listener_builder, "listener")
    listener = Iceoryx2.create(listener_builder)
    @test isvalid(notifier)
    @test isvalid(listener)
    @test string(Iceoryx2.name(notifier)) == "notifier"
    @test string(Iceoryx2.name(listener)) == "listener"

    bb_service = unique_service_name()
    bb_builder = Iceoryx2.blackboard_creator(Iceoryx2.service_builder(node, bb_service), UInt64)
    Iceoryx2.max_readers!(bb_builder, 1)
    Iceoryx2.max_nodes!(bb_builder, 1)
    Iceoryx2.add!(bb_builder, UInt64(1), UInt64(0))
    bb_factory = Iceoryx2.create(bb_builder)
    @test isvalid(bb_factory)

    bb_opener = Iceoryx2.blackboard_opener(Iceoryx2.service_builder(node, bb_service), UInt64)
    Iceoryx2.max_readers!(bb_opener, 1)
    Iceoryx2.max_nodes!(bb_opener, 1)
    bb_factory2 = Iceoryx2.open(bb_opener)
    @test isvalid(bb_factory2)

    writer_builder = Iceoryx2.writer_builder(bb_factory)
    reader_builder = Iceoryx2.reader_builder(bb_factory)
    Iceoryx2.name!(writer_builder, "writer")
    Iceoryx2.name!(reader_builder, "reader")
    writer = Iceoryx2.create(writer_builder)
    reader = Iceoryx2.create(reader_builder)
    @test string(Iceoryx2.name(writer)) == "writer"
    @test string(Iceoryx2.name(reader)) == "reader"

    close(reader)
    close(writer)
    close(bb_factory2)
    close(bb_factory)
    close(listener)
    close(notifier)
    close(event_factory)
    close(server)
    close(client)
    close(rr_factory)
    close(rr_attr_factory2)
    close(rr_attr_factory)
    close(sub)
    close(pub)
    close(pubsub_factory)
    close(pubsub_attr_factory2)
    close(pubsub_attr_factory)
    close(node)
end
