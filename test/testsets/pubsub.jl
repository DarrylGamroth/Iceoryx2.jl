@testset "PubSub" begin
    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, "iceoryx2_julia_test_node_pubsub")
    node = Iceoryx2.create(builder; service_type=:ipc)

    svc_builder = Iceoryx2.service_builder(node, "iceoryx2_julia_test_service_pubsub")
    pubsub_builder = Iceoryx2.pub_sub(svc_builder)
    Iceoryx2.payload_type!(pubsub_builder, UInt64)
    factory = Iceoryx2.open_or_create(pubsub_builder)

    pub = Iceoryx2.create(Iceoryx2.publisher_builder(factory, UInt64))
    sub = Iceoryx2.create(Iceoryx2.subscriber_builder(factory, UInt64))

    data = UInt64[0x1234_5678_9abc_def0]
    sample = nothing
    for _ in 1:50
        Iceoryx2.send_copy(pub, data)
        sample = Iceoryx2.receive(sub)
        sample !== nothing && break
        sleep(0.01)
    end
    @test sample !== nothing
    if sample !== nothing
        slice = Iceoryx2.payload(sample)
        @test length(slice) == 1
        @test slice[1] == data[1]
    end

    close(node)
end
