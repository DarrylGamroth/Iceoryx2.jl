@testset "Config" begin
    config = Iceoryx2.default_config()
    @test isvalid(config)
    view = Iceoryx2.config_view(config)
    @test isvalid(view)
    @test isvalid(Iceoryx2.global_config())
    clone = Iceoryx2.config_clone(config)
    @test isvalid(clone)
    from_ptr = Iceoryx2.config_from_ptr(view)
    @test isvalid(from_ptr)

    pub_nodes = Iceoryx2.defaults_publish_subscribe_max_nodes(config)
    Iceoryx2.defaults_publish_subscribe_max_nodes!(config, pub_nodes)
    pub_overflow = Iceoryx2.defaults_publish_subscribe_enable_safe_overflow(config)
    Iceoryx2.defaults_publish_subscribe_enable_safe_overflow!(config, pub_overflow)

    rr_nodes = Iceoryx2.defaults_request_response_max_nodes(config)
    Iceoryx2.defaults_request_response_max_nodes!(config, rr_nodes)
    rr_overflow = Iceoryx2.defaults_request_response_enable_safe_overflow_for_requests(config)
    Iceoryx2.defaults_request_response_enable_safe_overflow_for_requests!(config, rr_overflow)

    Iceoryx2.defaults_event_deadline!(config, 1, 0)
    deadline = Iceoryx2.defaults_event_deadline(config)
    @test deadline === nothing || deadline isa Tuple{UInt64, UInt32}

    bb_nodes = Iceoryx2.defaults_blackboard_max_nodes(config)
    Iceoryx2.defaults_blackboard_max_nodes!(config, bb_nodes)

    prefix = Iceoryx2.global_prefix(config)
    Iceoryx2.global_prefix!(config, prefix)
    root = Iceoryx2.global_root_path(config)
    Iceoryx2.global_root_path!(config, root)
    node_dir = Iceoryx2.global_node_directory(config)
    Iceoryx2.global_node_directory!(config, node_dir)
    svc_dir = Iceoryx2.global_service_directory(config)
    Iceoryx2.global_service_directory!(config, svc_dir)
    timeout = Iceoryx2.global_service_creation_timeout(config)
    Iceoryx2.global_service_creation_timeout!(config, timeout[1], timeout[2])

    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, unique_node_name())
    node = Iceoryx2.create(node_builder; service_type=:ipc)

    service_name = unique_service_name()
    svc_builder = Iceoryx2.service_builder(node, service_name)
    pubsub_builder = Iceoryx2.publish_subscribe(svc_builder, UInt64)
    factory = Iceoryx2.open_or_create(pubsub_builder)
    pub = Iceoryx2.create(Iceoryx2.publisher_builder(factory))
    sub = Iceoryx2.create(Iceoryx2.subscriber_builder(factory))

    exists, details = Iceoryx2.service_details(service_name; service_type=:ipc, messaging_pattern=:publish_subscribe)
    @test exists
    @test Iceoryx2.messaging_pattern(details) == Iceoryx2.Iceoryx2FFI.iox2_messaging_pattern_e_PUBLISH_SUBSCRIBE
    attrs = Iceoryx2.attributes(details)
    @test Iceoryx2.number_of_attributes(attrs) >= 0
    ps_details = Iceoryx2.publish_subscribe(Iceoryx2.details(details))
    msg_details = Iceoryx2.message_type_details(ps_details)
    payload_details = Iceoryx2.payload(msg_details)
    @test Iceoryx2.type_size(payload_details) == sizeof(UInt64)

    publisher_seen = Ref(false)
    Iceoryx2.list_publishers(factory) do publisher_details
        publisher_seen[] = true
        pub_id = Iceoryx2.publisher_id(publisher_details)
        @test isvalid(pub_id)
        close(pub_id)
        @test isvalid(Iceoryx2.node_id(publisher_details))
        @test Iceoryx2.number_of_samples(publisher_details) >= 0
        @test Iceoryx2.max_slice_len(publisher_details) >= 1
        return true
    end
    @test publisher_seen[]

    subscriber_seen = Ref(false)
    Iceoryx2.list_subscribers(factory) do subscriber_details
        subscriber_seen[] = true
        sub_id = Iceoryx2.subscriber_id(subscriber_details)
        @test isvalid(sub_id)
        close(sub_id)
        @test isvalid(Iceoryx2.node_id(subscriber_details))
        @test Iceoryx2.buffer_size(subscriber_details) >= 0
        return true
    end
    @test subscriber_seen[]

    close(sub)
    close(pub)
    close(factory)
    close(node)
    close(from_ptr)
    close(clone)
end
