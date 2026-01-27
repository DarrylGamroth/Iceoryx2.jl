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
