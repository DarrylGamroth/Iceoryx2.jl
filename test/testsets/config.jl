@testset "Config" begin
    config = Iceoryx2.default_config()
    @test isvalid(config)
    view = Iceoryx2.config_view(config)
    @test isvalid(view)
    @test isvalid(Iceoryx2.global_config())

    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, unique_node_name())
    node = Iceoryx2.create(node_builder; service_type=:ipc)

    service_name = unique_service_name()
    svc_builder = Iceoryx2.service_builder(node, service_name)
    pubsub_builder = Iceoryx2.pub_sub(svc_builder)
    Iceoryx2.payload_type!(pubsub_builder, UInt64)
    factory = Iceoryx2.open_or_create(pubsub_builder)

    exists, details = Iceoryx2.service_details(service_name; service_type=:ipc, messaging_pattern=:publish_subscribe)
    @test exists
    @test Iceoryx2.messaging_pattern(details) == Iceoryx2.Iceoryx2FFI.iox2_messaging_pattern_e_PUBLISH_SUBSCRIBE
    attrs = Iceoryx2.attributes(details)
    @test Iceoryx2.number_of_attributes(attrs) >= 0

    close(factory)
    close(node)
end
