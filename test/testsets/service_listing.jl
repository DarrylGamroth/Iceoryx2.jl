@testset "ServiceListing" begin
    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, "iceoryx2_julia_test_node_service_list")
    node = Iceoryx2.create(builder; service_type=:ipc)

    service_name = "iceoryx2_julia_test_service_list"
    svc_builder = Iceoryx2.service_builder(node, service_name)
    pubsub_builder = Iceoryx2.pub_sub(svc_builder)
    Iceoryx2.payload_type!(pubsub_builder, UInt64)
    factory = Iceoryx2.open_or_create(pubsub_builder)

    names = String[]
    Iceoryx2.list_services(service_type=:ipc) do cfg
        push!(names, Iceoryx2.name(cfg))
        return :continue
    end
    @test any(==(service_name), names)

    @test Iceoryx2.service_does_exist(service_name; service_type=:ipc, messaging_pattern=:publish_subscribe)
    exists, details = Iceoryx2.service_details(service_name; service_type=:ipc, messaging_pattern=:publish_subscribe)
    @test exists
    @test Iceoryx2.name(details) == service_name

    close(node)
    close(factory)
end
