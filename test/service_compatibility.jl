@testset "ServiceCompatibility" begin
    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, unique_node_name())
    node = Iceoryx2.create(node_builder, TEST_SERVICE_TYPE)

    try
        pubsub_name = unique_service_name()
        pubsub_factory = Iceoryx2.create(
            Iceoryx2.publish_subscribe(Iceoryx2.service_builder(node, pubsub_name), UInt64),
        )
        try
            wrong_payload_builder = Iceoryx2.publish_subscribe(
                Iceoryx2.service_builder(node, pubsub_name),
                Int64
            )
            try
                @test_throws Iceoryx2.PubSubOpenOrCreateError Iceoryx2.open(wrong_payload_builder)
            finally
                close(wrong_payload_builder)
            end
        finally
            close(pubsub_factory)
        end

        pubsub_header_name = unique_service_name()
        pubsub_header_builder = Iceoryx2.publish_subscribe(
            Iceoryx2.service_builder(node, pubsub_header_name),
            UInt64
        )
        pubsub_header_builder = Iceoryx2.user_header(pubsub_header_builder, UInt16)
        pubsub_header_factory = Iceoryx2.create(pubsub_header_builder)
        try
            wrong_header_builder = Iceoryx2.publish_subscribe(
                Iceoryx2.service_builder(node, pubsub_header_name),
                UInt64
            )
            wrong_header_builder = Iceoryx2.user_header(wrong_header_builder, UInt32)
            try
                @test_throws Iceoryx2.PubSubOpenOrCreateError Iceoryx2.open(wrong_header_builder)
            finally
                close(wrong_header_builder)
            end
        finally
            close(pubsub_header_factory)
        end

        rr_name = unique_service_name()
        rr_factory = Iceoryx2.create(
            Iceoryx2.request_response(Iceoryx2.service_builder(node, rr_name), UInt64, UInt32),
        )
        try
            wrong_request_builder = Iceoryx2.request_response(
                Iceoryx2.service_builder(node, rr_name),
                Int64,
                UInt32
            )
            try
                @test_throws Iceoryx2.RequestResponseOpenOrCreateError Iceoryx2.open(wrong_request_builder)
            finally
                close(wrong_request_builder)
            end
        finally
            close(rr_factory)
        end

        event_name = unique_service_name()
        specifier = Iceoryx2.AttributeSpecifier()
        Iceoryx2.define!(specifier, "role", "primary")
        event_factory = Iceoryx2.create(
            Iceoryx2.event(Iceoryx2.service_builder(node, event_name)),
            specifier
        )
        close(specifier)
        try
            verifier = Iceoryx2.AttributeVerifier()
            Iceoryx2.require!(verifier, "role", "secondary")
            wrong_attributes_builder = Iceoryx2.event(Iceoryx2.service_builder(node, event_name))
            try
                @test_throws Iceoryx2.EventOpenOrCreateError Iceoryx2.open(wrong_attributes_builder, verifier)
                @test !isvalid(wrong_attributes_builder)
            finally
                close(wrong_attributes_builder)
                close(verifier)
            end

            missing_verifier = Iceoryx2.AttributeVerifier()
            Iceoryx2.require_key!(missing_verifier, "missing")
            missing_attributes_builder = Iceoryx2.event(Iceoryx2.service_builder(node, event_name))
            try
                @test_throws Iceoryx2.EventOpenOrCreateError Iceoryx2.open(
                    missing_attributes_builder,
                    missing_verifier
                )
                @test !isvalid(missing_attributes_builder)
            finally
                close(missing_attributes_builder)
                close(missing_verifier)
            end
        finally
            close(event_factory)
        end

        blackboard_name = unique_service_name()
        blackboard_builder = Iceoryx2.blackboard_creator(
            Iceoryx2.service_builder(node, blackboard_name),
            UInt64
        )
        Iceoryx2.add!(blackboard_builder, UInt64(1), UInt64(0))
        blackboard_factory = Iceoryx2.create(blackboard_builder)
        try
            wrong_key_builder = Iceoryx2.blackboard_opener(
                Iceoryx2.service_builder(node, blackboard_name),
                Int64
            )
            try
                @test_throws Iceoryx2.BlackboardOpenError Iceoryx2.open(wrong_key_builder)
                @test !isvalid(wrong_key_builder)
            finally
                close(wrong_key_builder)
            end
        finally
            close(blackboard_factory)
        end

        limited_pubsub_builder = Iceoryx2.publish_subscribe(
            Iceoryx2.service_builder(node, unique_service_name()),
            UInt64
        )
        Iceoryx2.max_publishers!(limited_pubsub_builder, 1)
        Iceoryx2.max_subscribers!(limited_pubsub_builder, 1)
        limited_pubsub_factory = Iceoryx2.create(limited_pubsub_builder)
        pub = Iceoryx2.create(Iceoryx2.publisher_builder(limited_pubsub_factory))
        sub = Iceoryx2.create(Iceoryx2.subscriber_builder(limited_pubsub_factory))
        try
            extra_pub_builder = Iceoryx2.publisher_builder(limited_pubsub_factory)
            try
                @test_throws Iceoryx2.PublisherCreateError Iceoryx2.create(extra_pub_builder)
                @test !isvalid(extra_pub_builder)
            finally
                close(extra_pub_builder)
            end

            extra_sub_builder = Iceoryx2.subscriber_builder(limited_pubsub_factory)
            try
                @test_throws Iceoryx2.SubscriberCreateError Iceoryx2.create(extra_sub_builder)
                @test !isvalid(extra_sub_builder)
            finally
                close(extra_sub_builder)
            end
        finally
            close(sub)
            close(pub)
            close(limited_pubsub_factory)
        end

        limited_rr_builder = Iceoryx2.request_response(
            Iceoryx2.service_builder(node, unique_service_name()),
            UInt64,
            UInt64
        )
        Iceoryx2.max_clients!(limited_rr_builder, 1)
        Iceoryx2.max_servers!(limited_rr_builder, 1)
        limited_rr_factory = Iceoryx2.create(limited_rr_builder)
        client = Iceoryx2.create(Iceoryx2.client_builder(limited_rr_factory))
        server = Iceoryx2.create(Iceoryx2.server_builder(limited_rr_factory))
        try
            extra_client_builder = Iceoryx2.client_builder(limited_rr_factory)
            try
                @test_throws Iceoryx2.ClientCreateError Iceoryx2.create(extra_client_builder)
                @test !isvalid(extra_client_builder)
            finally
                close(extra_client_builder)
            end

            extra_server_builder = Iceoryx2.server_builder(limited_rr_factory)
            try
                @test_throws Iceoryx2.ServerCreateError Iceoryx2.create(extra_server_builder)
                @test !isvalid(extra_server_builder)
            finally
                close(extra_server_builder)
            end
        finally
            close(server)
            close(client)
            close(limited_rr_factory)
        end

        limited_event_builder = Iceoryx2.event(Iceoryx2.service_builder(node, unique_service_name()))
        Iceoryx2.max_notifiers!(limited_event_builder, 1)
        Iceoryx2.max_listeners!(limited_event_builder, 1)
        limited_event_factory = Iceoryx2.create(limited_event_builder)
        notifier = Iceoryx2.create(Iceoryx2.notifier_builder(limited_event_factory))
        listener = Iceoryx2.create(Iceoryx2.listener_builder(limited_event_factory))
        try
            extra_notifier_builder = Iceoryx2.notifier_builder(limited_event_factory)
            try
                @test_throws Iceoryx2.NotifierCreateError Iceoryx2.create(extra_notifier_builder)
                @test !isvalid(extra_notifier_builder)
            finally
                close(extra_notifier_builder)
            end

            extra_listener_builder = Iceoryx2.listener_builder(limited_event_factory)
            try
                @test_throws Iceoryx2.ListenerCreateError Iceoryx2.create(extra_listener_builder)
                @test !isvalid(extra_listener_builder)
            finally
                close(extra_listener_builder)
            end
        finally
            close(listener)
            close(notifier)
            close(limited_event_factory)
        end

        limited_blackboard_builder = Iceoryx2.blackboard_creator(
            Iceoryx2.service_builder(node, unique_service_name()),
            UInt64
        )
        Iceoryx2.add!(limited_blackboard_builder, UInt64(1), UInt64(0))
        Iceoryx2.max_readers!(limited_blackboard_builder, 1)
        limited_blackboard_factory = Iceoryx2.create(limited_blackboard_builder)
        reader = Iceoryx2.create(Iceoryx2.reader_builder(limited_blackboard_factory))
        try
            extra_reader_builder = Iceoryx2.reader_builder(limited_blackboard_factory)
            try
                @test_throws Iceoryx2.ReaderCreateError Iceoryx2.create(extra_reader_builder)
                @test !isvalid(extra_reader_builder)
            finally
                close(extra_reader_builder)
            end
        finally
            close(reader)
            close(limited_blackboard_factory)
        end
    finally
        close(node)
    end
end
