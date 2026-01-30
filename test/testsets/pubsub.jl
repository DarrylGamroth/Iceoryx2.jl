@testset "PubSub" begin
    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, "iceoryx2_julia_test_node_pubsub")
    node = Iceoryx2.create(builder; service_type=:ipc)

    hdr_builder = Iceoryx2.service_builder(node, "iceoryx2_julia_test_service_pubsub_hdr")
    pubsub_hdr_builder = Iceoryx2.publish_subscribe(hdr_builder, UInt64)
    pubsub_hdr_builder = Iceoryx2.user_header(pubsub_hdr_builder, UInt16)
    @test_throws MethodError Iceoryx2.user_header(pubsub_hdr_builder, UInt32)
    hdr_factory = Iceoryx2.open_or_create(pubsub_hdr_builder)
    close(hdr_factory)

    svc_builder = Iceoryx2.service_builder(node, "iceoryx2_julia_test_service_pubsub")
    pubsub_builder = Iceoryx2.publish_subscribe(svc_builder, UInt64)
    factory = Iceoryx2.open_or_create(pubsub_builder)

    pub = Iceoryx2.create(Iceoryx2.publisher_builder(factory))
    sub = Iceoryx2.create(Iceoryx2.subscriber_builder(factory))
    sample_mut = Iceoryx2.SampleMut(pub)
    sample = Iceoryx2.Sample(sub)

    Iceoryx2.loan!(pub, sample_mut)
    init_payload = Iceoryx2.payload_mut(sample_mut)
    @test init_payload[1] == zero(UInt64)
    close(sample_mut)

    data = UInt64[0x1234_5678_9abc_def0]
    received = false
    for _ in 1:50
        Iceoryx2.send_copy(pub, data)
        if Iceoryx2.receive!(sub, sample)
            received = true
            break
        end
        sleep(0.01)
    end
    @test received
    if received
        slice = Iceoryx2.payload(sample)
        @test length(slice) == 1
        @test slice[1] == data[1]
        hdr = Iceoryx2.header(sample)
        @test Iceoryx2.number_of_elements(hdr) == length(slice)
        pub_id = Iceoryx2.publisher_id(hdr)
        @test isvalid(pub_id)
        close(pub_id)
        close(hdr)
        close(sample)
    end

    close(node)
end

@testset "PubSubUserHeader" begin
    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, "iceoryx2_julia_test_node_pubsub_user_header")
    node = Iceoryx2.create(builder; service_type=:ipc)

    svc_builder = Iceoryx2.service_builder(node, unique_service_name())
    pubsub_builder = Iceoryx2.publish_subscribe(svc_builder, UInt64)
    pubsub_builder = Iceoryx2.user_header(pubsub_builder, UInt16)
    factory = Iceoryx2.open_or_create(pubsub_builder)

    pub = Iceoryx2.create(Iceoryx2.publisher_builder(factory))
    sub = Iceoryx2.create(Iceoryx2.subscriber_builder(factory))

    sample_mut = Iceoryx2.SampleMut(pub)
    sample = Iceoryx2.Sample(sub)
    Iceoryx2.loan_uninit!(pub, sample_mut)
    Iceoryx2.write_payload!(sample_mut, UInt64(9))
    hdr = Iceoryx2.user_header_mut(sample_mut)
    hdr[1] = UInt16(42)
    Iceoryx2.send!(sample_mut)

    received = false
    for _ in 1:50
        if Iceoryx2.receive!(sub, sample)
            received = true
            break
        end
        sleep(0.01)
    end
    @test received
    if received
        hdr_recv = Iceoryx2.user_header(sample)
        @test hdr_recv[1] == UInt16(42)
        close(sample)
    end

    close(sub)
    close(pub)
    close(factory)
    close(node)
end

@testset "PubSubTuplePayload" begin
    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, "iceoryx2_julia_test_node_pubsub_tuple")
    node = Iceoryx2.create(builder; service_type=:ipc)

    svc_builder = Iceoryx2.service_builder(node, unique_service_name())
    pubsub_builder = Iceoryx2.publish_subscribe(svc_builder, Tuple{UInt32,Float64})
    factory = Iceoryx2.open_or_create(pubsub_builder)

    pub = Iceoryx2.create(Iceoryx2.publisher_builder(factory))
    sub = Iceoryx2.create(Iceoryx2.subscriber_builder(factory))

    sample_mut = Iceoryx2.SampleMut(pub)
    sample = Iceoryx2.Sample(sub)
    Iceoryx2.loan_uninit!(pub, sample_mut)
    payload = (UInt32(7), 3.25)
    Iceoryx2.write_payload!(sample_mut, payload)
    Iceoryx2.send!(sample_mut)

    received = false
    for _ in 1:50
        if Iceoryx2.receive!(sub, sample)
            received = true
            break
        end
        sleep(0.01)
    end
    @test received
    if received
        recv = Iceoryx2.payload(sample)
        @test recv[1] == payload
        close(sample)
    end

    close(sub)
    close(pub)
    close(factory)
    close(node)
end

@testset "PubSubDynamicSlice" begin
    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, "iceoryx2_julia_test_node_pubsub_dynamic")
    node = Iceoryx2.create(builder; service_type=:ipc)

    svc_builder = Iceoryx2.service_builder(node, unique_service_name())
    pubsub_builder = Iceoryx2.publish_subscribe(svc_builder, AbstractVector{UInt8})
    factory = Iceoryx2.open_or_create(pubsub_builder)

    payload_len = 8
    pub_builder = Iceoryx2.publisher_builder(factory)
    Iceoryx2.initial_max_slice_len!(pub_builder, payload_len)
    pub = Iceoryx2.create(pub_builder)
    sub = Iceoryx2.create(Iceoryx2.subscriber_builder(factory))
    sample_mut = Iceoryx2.SampleMut(pub)
    sample = Iceoryx2.Sample(sub)

    Iceoryx2.loan_slice_uninit!(pub, sample_mut, payload_len)
    slice = Iceoryx2.payload_mut(sample_mut)
    for idx in 1:payload_len
        @test slice[idx] == 0x00
    end
    for idx in 1:payload_len
        slice[idx] = UInt8(idx)
    end
    Iceoryx2.send!(sample_mut)

    received = false
    for _ in 1:50
        if Iceoryx2.receive!(sub, sample)
            received = true
            break
        end
        sleep(0.01)
    end
    @test received
    if received
        recv = Iceoryx2.payload(sample)
        @test length(recv) == payload_len
        @test recv[1] == 0x01
        @test recv[end] == UInt8(payload_len)
        close(sample)
    end

    close(sub)
    close(pub)
    close(factory)
    close(node)
end

@testset "PubSubDynamicSliceStructSetindex" begin
    struct TestHeader
        a::UInt32
        b::Float64
    end

    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, "iceoryx2_julia_test_node_pubsub_struct_slice")
    node = Iceoryx2.create(builder; service_type=:ipc)

    svc_builder = Iceoryx2.service_builder(node, unique_service_name())
    pubsub_builder = Iceoryx2.publish_subscribe(svc_builder, AbstractVector{TestHeader})
    factory = Iceoryx2.open_or_create(pubsub_builder)

    payload_len = 2
    pub_builder = Iceoryx2.publisher_builder(factory)
    Iceoryx2.initial_max_slice_len!(pub_builder, payload_len)
    pub = Iceoryx2.create(pub_builder)
    sub = Iceoryx2.create(Iceoryx2.subscriber_builder(factory))
    sample_mut = Iceoryx2.SampleMut(pub)
    sample = Iceoryx2.Sample(sub)

    Iceoryx2.loan_slice_uninit!(pub, sample_mut, payload_len)
    slice = Iceoryx2.payload_mut(sample_mut)
    slice[1] = TestHeader(UInt32(1), 2.0)
    slice[2] = TestHeader(UInt32(3), 4.0)
    Iceoryx2.send!(sample_mut)

    received = false
    for _ in 1:50
        if Iceoryx2.receive!(sub, sample)
            received = true
            break
        end
        sleep(0.01)
    end
    @test received
    if received
        recv = Iceoryx2.payload(sample)
        @test length(recv) == payload_len
        @test recv[1].a == UInt32(1)
        @test recv[1].b == 2.0
        @test recv[2].a == UInt32(3)
        @test recv[2].b == 4.0
        close(sample)
    end

    close(sub)
    close(pub)
    close(factory)
    close(node)
end
