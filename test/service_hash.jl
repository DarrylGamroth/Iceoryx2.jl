function _test_service_hash_pair(create_factory, open_factory, create_other_factory)
    created = create_factory()
    opened = open_factory()
    other = create_other_factory()
    try
        @test !isempty(service_hash(created))
        @test service_hash(created) == service_hash(opened)
        @test service_hash(created) != service_hash(other)
    finally
        close(other)
        close(opened)
        close(created)
    end
end

@testset "ServiceHash" begin
    builder = NodeBuilder()
    name!(builder, unique_node_name())
    node = create(builder, TEST_SERVICE_TYPE)

    try
        event_name = unique_service_name()
        event_builder() = event(service_builder(node, event_name))
        _test_service_hash_pair(
            () -> create(event_builder()),
            () -> Iceoryx2.open(event_builder()),
            () -> create(event(service_builder(node, unique_service_name()))),
        )

        pubsub_name = unique_service_name()
        pubsub_builder() = publish_subscribe(service_builder(node, pubsub_name), UInt64)
        _test_service_hash_pair(
            () -> create(pubsub_builder()),
            () -> Iceoryx2.open(pubsub_builder()),
            () -> create(publish_subscribe(service_builder(node, unique_service_name()), UInt64)),
        )

        rr_name = unique_service_name()
        rr_builder() = request_response(service_builder(node, rr_name), UInt64, UInt64)
        _test_service_hash_pair(
            () -> create(rr_builder()),
            () -> Iceoryx2.open(rr_builder()),
            () -> create(request_response(service_builder(node, unique_service_name()), UInt64, UInt64)),
        )

        bb_name = unique_service_name()
        bb_creator() = begin
            builder = blackboard_creator(service_builder(node, bb_name), UInt64)
            add!(builder, UInt64(1), UInt64(0))
            builder
        end
        bb_opener() = blackboard_opener(service_builder(node, bb_name), UInt64)
        other_bb_creator() = begin
            builder = blackboard_creator(service_builder(node, unique_service_name()), UInt64)
            add!(builder, UInt64(1), UInt64(0))
            builder
        end
        _test_service_hash_pair(
            () -> create(bb_creator()),
            () -> Iceoryx2.open(bb_opener()),
            () -> create(other_bb_creator()),
        )
    finally
        close(node)
    end
end
