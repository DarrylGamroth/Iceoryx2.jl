@testset "DynamicConfigDetails" begin
    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, unique_node_name())
    node = Iceoryx2.create(builder, TEST_SERVICE_TYPE)

    try
        pubsub_factory = Iceoryx2.create(
            Iceoryx2.publish_subscribe(Iceoryx2.service_builder(node, unique_service_name()), UInt64),
        )
        pub = Iceoryx2.create(Iceoryx2.publisher_builder(pubsub_factory))
        sub = Iceoryx2.create(Iceoryx2.subscriber_builder(pubsub_factory))
        try
            @test Iceoryx2.number_of_publishers(pubsub_factory) >= 1
            @test Iceoryx2.number_of_subscribers(pubsub_factory) >= 1

            publisher_callbacks = Ref(0)
            Iceoryx2.list_publishers(pubsub_factory) do details
                publisher_callbacks[] += 1
                id = Iceoryx2.publisher_id(details)
                @test isvalid(id)
                close(id)
                @test isvalid(Iceoryx2.node_id(details))
                @test Iceoryx2.number_of_samples(details) >= 0
                @test Iceoryx2.max_slice_len(details) >= 1
                return :stop
            end
            @test publisher_callbacks[] == 1

            subscriber_callbacks = Ref(0)
            Iceoryx2.list_subscribers(pubsub_factory) do details
                subscriber_callbacks[] += 1
                id = Iceoryx2.subscriber_id(details)
                @test isvalid(id)
                close(id)
                @test isvalid(Iceoryx2.node_id(details))
                @test Iceoryx2.buffer_size(details) >= 0
                return false
            end
            @test subscriber_callbacks[] == 1
        finally
            close(sub)
            close(pub)
            close(pubsub_factory)
        end

        rr_factory = Iceoryx2.create(
            Iceoryx2.request_response(Iceoryx2.service_builder(node, unique_service_name()), UInt64, UInt64),
        )
        client = Iceoryx2.create(Iceoryx2.client_builder(rr_factory))
        server = Iceoryx2.create(Iceoryx2.server_builder(rr_factory))
        try
            @test Iceoryx2.number_of_clients(rr_factory) >= 1
            @test Iceoryx2.number_of_servers(rr_factory) >= 1

            client_callbacks = Ref(0)
            Iceoryx2.list_clients(rr_factory) do details
                client_callbacks[] += 1
                id = Iceoryx2.client_id(details)
                @test isvalid(id)
                close(id)
                @test isvalid(Iceoryx2.node_id(details))
                @test Iceoryx2.response_buffer_size(details) >= 0
                @test Iceoryx2.number_of_requests(details) >= 0
                @test Iceoryx2.max_slice_len(details) >= 1
                return :stop
            end
            @test client_callbacks[] == 1

            server_callbacks = Ref(0)
            Iceoryx2.list_servers(rr_factory) do details
                server_callbacks[] += 1
                id = Iceoryx2.server_id(details)
                @test isvalid(id)
                close(id)
                @test isvalid(Iceoryx2.node_id(details))
                @test Iceoryx2.request_buffer_size(details) >= 0
                @test Iceoryx2.number_of_responses(details) >= 0
                @test Iceoryx2.max_slice_len(details) >= 1
                return false
            end
            @test server_callbacks[] == 1
        finally
            close(server)
            close(client)
            close(rr_factory)
        end

        event_factory = Iceoryx2.create(Iceoryx2.event(Iceoryx2.service_builder(node, unique_service_name())))
        notifier = Iceoryx2.create(Iceoryx2.notifier_builder(event_factory))
        listener = Iceoryx2.create(Iceoryx2.listener_builder(event_factory))
        try
            @test Iceoryx2.number_of_notifiers(event_factory) >= 1
            @test Iceoryx2.number_of_listeners(event_factory) >= 1

            notifier_callbacks = Ref(0)
            Iceoryx2.list_notifiers(event_factory) do details
                notifier_callbacks[] += 1
                id = Iceoryx2.notifier_id(details)
                @test isvalid(id)
                close(id)
                @test isvalid(Iceoryx2.node_id(details))
                return :stop
            end
            @test notifier_callbacks[] == 1

            listener_callbacks = Ref(0)
            Iceoryx2.list_listeners(event_factory) do details
                listener_callbacks[] += 1
                id = Iceoryx2.listener_id(details)
                @test isvalid(id)
                close(id)
                @test isvalid(Iceoryx2.node_id(details))
                return false
            end
            @test listener_callbacks[] == 1
        finally
            close(listener)
            close(notifier)
            close(event_factory)
        end

        blackboard_builder = Iceoryx2.blackboard_creator(
            Iceoryx2.service_builder(node, unique_service_name()),
            UInt64,
        )
        Iceoryx2.add!(blackboard_builder, UInt64(1), UInt64(0))
        blackboard_factory = Iceoryx2.create(blackboard_builder)
        writer = Iceoryx2.create(Iceoryx2.writer_builder(blackboard_factory))
        reader = Iceoryx2.create(Iceoryx2.reader_builder(blackboard_factory))
        try
            @test Iceoryx2.number_of_writers(blackboard_factory) >= 1
            @test Iceoryx2.number_of_readers(blackboard_factory) >= 1

            writer_callbacks = Ref(0)
            Iceoryx2.list_writers(blackboard_factory) do details
                writer_callbacks[] += 1
                id = Iceoryx2.writer_id(details)
                @test isvalid(id)
                close(id)
                @test isvalid(Iceoryx2.node_id(details))
                return :stop
            end
            @test writer_callbacks[] == 1

            reader_callbacks = Ref(0)
            Iceoryx2.list_readers(blackboard_factory) do details
                reader_callbacks[] += 1
                id = Iceoryx2.reader_id(details)
                @test isvalid(id)
                close(id)
                @test isvalid(Iceoryx2.node_id(details))
                return false
            end
            @test reader_callbacks[] == 1
        finally
            close(reader)
            close(writer)
            close(blackboard_factory)
        end
    finally
        close(node)
    end
end
