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
    pub_backpressure = Iceoryx2.defaults_publish_subscribe_backpressure_strategy(config)
    @test pub_backpressure isa Iceoryx2.BackpressureStrategy
    Iceoryx2.defaults_publish_subscribe_backpressure_strategy!(config, pub_backpressure)
    Iceoryx2.defaults_publish_subscribe_backpressure_strategy!(
        config,
        Iceoryx2.BackpressureStrategyDiscardData
    )
    Iceoryx2.defaults_publish_subscribe_backpressure_strategy!(config, :retry_until_delivered)
    @test_throws MethodError Iceoryx2.defaults_publish_subscribe_backpressure_strategy!(
        config,
        Iceoryx2.Iceoryx2FFI.iox2_backpressure_strategy_e_DISCARD_DATA
    )
    @test_throws ArgumentError Iceoryx2.defaults_publish_subscribe_backpressure_strategy!(config, :block)
    @test_throws ArgumentError Iceoryx2.defaults_publish_subscribe_backpressure_strategy!(
        config, :discard_sample)

    rr_nodes = Iceoryx2.defaults_request_response_max_nodes(config)
    Iceoryx2.defaults_request_response_max_nodes!(config, rr_nodes)
    rr_overflow = Iceoryx2.defaults_request_response_enable_safe_overflow_for_requests(config)
    Iceoryx2.defaults_request_response_enable_safe_overflow_for_requests!(config, rr_overflow)
    rr_client_backpressure = Iceoryx2.defaults_request_response_client_backpressure_strategy(config)
    @test rr_client_backpressure isa Iceoryx2.BackpressureStrategy
    Iceoryx2.defaults_request_response_client_backpressure_strategy!(config, rr_client_backpressure)
    rr_server_backpressure = Iceoryx2.defaults_request_response_server_backpressure_strategy(config)
    @test rr_server_backpressure isa Iceoryx2.BackpressureStrategy
    Iceoryx2.defaults_request_response_server_backpressure_strategy!(config, rr_server_backpressure)

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
    node_cleanup_creation = Iceoryx2.global_node_cleanup_dead_nodes_on_creation(config)
    Iceoryx2.global_node_cleanup_dead_nodes_on_creation!(config, node_cleanup_creation)
    node_cleanup_destruction = Iceoryx2.global_node_cleanup_dead_nodes_on_destruction(config)
    Iceoryx2.global_node_cleanup_dead_nodes_on_destruction!(config, node_cleanup_destruction)
    node_monitor_suffix = Iceoryx2.global_node_monitor_suffix(config)
    Iceoryx2.global_node_monitor_suffix!(config, node_monitor_suffix)
    node_global_mgmt_suffix = Iceoryx2.global_node_global_mgmt_suffix(config)
    Iceoryx2.global_node_global_mgmt_suffix!(config, node_global_mgmt_suffix)
    node_static_config_suffix = Iceoryx2.global_node_static_config_suffix(config)
    Iceoryx2.global_node_static_config_suffix!(config, node_static_config_suffix)
    node_port_tag_suffix = Iceoryx2.global_node_port_tag_suffix(config)
    Iceoryx2.global_node_port_tag_suffix!(config, node_port_tag_suffix)
    node_service_tag_suffix = Iceoryx2.global_node_service_tag_suffix(config)
    Iceoryx2.global_node_service_tag_suffix!(config, node_service_tag_suffix)
    cleanup_on_open = Iceoryx2.global_service_cleanup_dead_nodes_on_open(config)
    Iceoryx2.global_service_cleanup_dead_nodes_on_open!(config, cleanup_on_open)
    svc_dir = Iceoryx2.global_service_directory(config)
    Iceoryx2.global_service_directory!(config, svc_dir)
    svc_data_suffix = Iceoryx2.global_service_data_segment_suffix(config)
    Iceoryx2.global_service_data_segment_suffix!(config, svc_data_suffix)
    svc_static_suffix = Iceoryx2.global_service_static_config_storage_suffix(config)
    Iceoryx2.global_service_static_config_storage_suffix!(config, svc_static_suffix)
    svc_dynamic_suffix = Iceoryx2.global_service_dynamic_config_storage_suffix(config)
    Iceoryx2.global_service_dynamic_config_storage_suffix!(config, svc_dynamic_suffix)
    svc_connection_suffix = Iceoryx2.global_service_connection_suffix(config)
    Iceoryx2.global_service_connection_suffix!(config, svc_connection_suffix)
    svc_event_connection_suffix = Iceoryx2.global_service_event_connection_suffix(config)
    Iceoryx2.global_service_event_connection_suffix!(config, svc_event_connection_suffix)
    svc_blackboard_mgmt_suffix = Iceoryx2.global_service_blackboard_mgmt_suffix(config)
    Iceoryx2.global_service_blackboard_mgmt_suffix!(config, svc_blackboard_mgmt_suffix)
    svc_blackboard_data_suffix = Iceoryx2.global_service_blackboard_data_suffix(config)
    Iceoryx2.global_service_blackboard_data_suffix!(config, svc_blackboard_data_suffix)
    timeout = Iceoryx2.global_creation_timeout(config)
    Iceoryx2.global_creation_timeout!(config, timeout[1], timeout[2])
    @test_throws ArgumentError Iceoryx2.global_creation_timeout!(config, -1, 0)
    @test_throws ArgumentError Iceoryx2.global_creation_timeout!(config, 0, 1_000_000_000)

    for name in (
        :global_creation_timeout,
        :global_creation_timeout!,
        :global_node_global_mgmt_suffix,
        :global_node_global_mgmt_suffix!,
        :global_node_port_tag_suffix,
        :global_node_port_tag_suffix!,
        :global_prefix,
        :global_root_path,
        :global_service_cleanup_dead_nodes_on_open,
        :global_service_cleanup_dead_nodes_on_open!
    )
        @test name in names(Iceoryx2)
    end

    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, unique_node_name())
    node = Iceoryx2.create(node_builder, TEST_SERVICE_TYPE)

    service_name = unique_service_name()
    @test Iceoryx2.service_details(
        unique_service_name();
        service_type = TEST_SERVICE_TYPE,
        messaging_pattern = :publish_subscribe
    ) === nothing
    svc_builder = Iceoryx2.service_builder(node, service_name)
    pubsub_builder = Iceoryx2.publish_subscribe(svc_builder, UInt64)
    factory = Iceoryx2.open_or_create(pubsub_builder)
    pub = Iceoryx2.create(Iceoryx2.publisher_builder(factory))
    sub = Iceoryx2.create(Iceoryx2.subscriber_builder(factory))

    details = Iceoryx2.service_details(
        service_name;
        service_type = TEST_SERVICE_TYPE,
        messaging_pattern = Iceoryx2.MessagingPatternPublishSubscribe
    )
    @test details !== nothing
    @test Iceoryx2.messaging_pattern(details) == Iceoryx2.MessagingPatternPublishSubscribe
    @test Iceoryx2.service_does_exist(
        service_name;
        service_type = TEST_SERVICE_TYPE,
        messaging_pattern = :publish_subscribe
    )
    @test_throws TypeError Iceoryx2.service_details(
        service_name;
        service_type = TEST_SERVICE_TYPE,
        messaging_pattern = Iceoryx2.Iceoryx2FFI.iox2_messaging_pattern_e_PUBLISH_SUBSCRIBE
    )
    attrs = Iceoryx2.attributes(details)
    @test Iceoryx2.number_of_attributes(attrs) >= 0
    ps_details = Iceoryx2.publish_subscribe(Iceoryx2.details(details))
    msg_details = Iceoryx2.message_type_details(ps_details)
    payload_details = Iceoryx2.payload(msg_details)
    @test Iceoryx2.type_variant(payload_details) == Iceoryx2.TypeVariantFixedSize
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
    @test_throws ErrorException Iceoryx2.list_publishers(factory) do _
        error("details callback failure")
    end

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

    close(details)
    @test !isvalid(details)
    @test_throws ArgumentError Iceoryx2.attributes(details)
    close(sub)
    close(pub)
    close(factory)
    close(node)
    close(from_ptr)
    close(clone)
    close(config)
end
