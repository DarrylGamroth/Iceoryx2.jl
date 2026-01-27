using Test
using Iceoryx2

@testset "NodeBuilder" begin
    builder = Iceoryx2.NodeBuilder()
    @test isvalid(builder)

    Iceoryx2.name!(builder, "iceoryx2_julia_test_node")

    config_handle = Ref{Iceoryx2.Iceoryx2FFI.iox2_config_h}(C_NULL)
    ret = Iceoryx2.Iceoryx2FFI.iox2_config_default(C_NULL, config_handle)
    Iceoryx2.check_ok(ret, Iceoryx2.Iceoryx2FFI.iox2_config_creation_error_e)
    config = Iceoryx2.Config(config_handle[])

    Iceoryx2.config!(builder, config)

    node = Iceoryx2.create(builder; service_type=:ipc)
    @test !isvalid(builder)
    @test isvalid(node)

    close(node)
    close(config)
end

@testset "ServiceBuilder" begin
    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, "iceoryx2_julia_test_node_service")
    node = Iceoryx2.create(builder; service_type=:ipc)

    svc_builder = Iceoryx2.service_builder(node, "iceoryx2_julia_test_service")
    @test isvalid(svc_builder)

    close(node)
end

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

@testset "RequestResponse" begin
    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, "iceoryx2_julia_test_node_rr")
    node = Iceoryx2.create(builder; service_type=:ipc)

    svc_builder = Iceoryx2.service_builder(node, "iceoryx2_julia_test_service_rr")
    rr_builder = Iceoryx2.request_response(svc_builder)
    Iceoryx2.request_payload_type!(rr_builder, UInt64)
    Iceoryx2.response_payload_type!(rr_builder, UInt64)
    factory = Iceoryx2.open_or_create(rr_builder)

    client = Iceoryx2.create(Iceoryx2.client_builder(factory, UInt64, UInt64))
    server = Iceoryx2.create(Iceoryx2.server_builder(factory, UInt64, UInt64))

    request = Iceoryx2.loan_request(client, 1)
    req_slice = Iceoryx2.payload_mut(request)
    unsafe_store!(req_slice.ptr, UInt64(42))
    pending = Iceoryx2.send!(request)

    active = nothing
    for _ in 1:50
        active = Iceoryx2.receive(server)
        active !== nothing && break
        sleep(0.01)
    end
    @test active !== nothing
    if active !== nothing
        req_payload = Iceoryx2.payload(active)
        @test req_payload[1] == UInt64(42)

        resp_data = UInt64[84]
        GC.@preserve resp_data begin
            Iceoryx2.send_copy(active, pointer(resp_data), length(resp_data))
        end
    end

    response = nothing
    for _ in 1:50
        response = Iceoryx2.receive(pending)
        response !== nothing && break
        sleep(0.01)
    end
    @test response !== nothing
    if response !== nothing
        resp_payload = Iceoryx2.payload(response)
        @test resp_payload[1] == UInt64(84)
    end

    close(node)
end
