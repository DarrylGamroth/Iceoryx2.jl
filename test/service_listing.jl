@testset "ServiceListing" begin
    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, "iceoryx2_julia_test_node_service_list")
    node = Iceoryx2.create(builder, TEST_SERVICE_TYPE)

    service_name = "iceoryx2_julia_test_service_list"
    svc_builder = Iceoryx2.service_builder(node, service_name)
    pubsub_builder = Iceoryx2.publish_subscribe(svc_builder, UInt64)
    factory = Iceoryx2.open_or_create(pubsub_builder)

    names = String[]
    Iceoryx2.list_services(service_type = TEST_SERVICE_TYPE) do cfg
        try
            push!(names, Iceoryx2.name(cfg))
            return :continue
        finally
            close(cfg)
        end
    end
    @test any(==(service_name), names)

    @test Iceoryx2.service_does_exist(
        service_name; service_type = TEST_SERVICE_TYPE,
        messaging_pattern = :publish_subscribe)
    details = Iceoryx2.service_details(
        service_name; service_type = TEST_SERVICE_TYPE,
        messaging_pattern = :publish_subscribe)
    @test details !== nothing
    @test Iceoryx2.name(details) == service_name

    close(details)
    close(node)
    close(factory)
end
