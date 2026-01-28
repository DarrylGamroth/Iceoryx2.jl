@testset "RequestResponse" begin
    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, "iceoryx2_julia_test_node_rr")
    node = Iceoryx2.create(builder; service_type=:ipc)

    svc_builder_hdr = Iceoryx2.service_builder(node, "iceoryx2_julia_test_service_rr_hdr")
    rr_hdr_builder = Iceoryx2.request_response(svc_builder_hdr, UInt64, UInt64)
    rr_hdr_builder = Iceoryx2.request_user_header(rr_hdr_builder, UInt16)
    @test_throws ArgumentError Iceoryx2.request_user_header(rr_hdr_builder, UInt32)
    rr_hdr_builder = Iceoryx2.response_user_header(rr_hdr_builder, UInt8)
    @test_throws ArgumentError Iceoryx2.response_user_header(rr_hdr_builder, UInt16)
    factory_hdr = Iceoryx2.open_or_create(rr_hdr_builder)
    close(factory_hdr)

    svc_builder = Iceoryx2.service_builder(node, "iceoryx2_julia_test_service_rr")
    rr_builder = Iceoryx2.request_response(svc_builder, UInt64, UInt64)
    factory = Iceoryx2.open_or_create(rr_builder)

    client = Iceoryx2.create(Iceoryx2.client_builder(factory))
    server = Iceoryx2.create(Iceoryx2.server_builder(factory))

    client_seen = Ref(false)
    Iceoryx2.list_clients(factory) do client_details
        client_seen[] = true
        cid = Iceoryx2.client_id(client_details)
        @test isvalid(cid)
        close(cid)
        @test isvalid(Iceoryx2.node_id(client_details))
        @test Iceoryx2.response_buffer_size(client_details) >= 0
        @test Iceoryx2.number_of_requests(client_details) >= 0
        @test Iceoryx2.max_slice_len(client_details) >= 1
        return true
    end
    @test client_seen[]

    server_seen = Ref(false)
    Iceoryx2.list_servers(factory) do server_details
        server_seen[] = true
        sid = Iceoryx2.server_id(server_details)
        @test isvalid(sid)
        close(sid)
        @test isvalid(Iceoryx2.node_id(server_details))
        @test Iceoryx2.number_of_responses(server_details) >= 0
        @test Iceoryx2.request_buffer_size(server_details) >= 0
        @test Iceoryx2.max_slice_len(server_details) >= 1
        return true
    end
    @test server_seen[]

    request = Iceoryx2.loan_uninit(client)
    Iceoryx2.write_payload!(request, UInt64(42))
    req_hdr = Iceoryx2.header(request)
    @test Iceoryx2.number_of_elements(req_hdr) == 1
    client_id = Iceoryx2.client_id(req_hdr)
    @test isvalid(client_id)
    close(client_id)
    close(req_hdr)
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

        response_mut = Iceoryx2.loan_uninit(active)
        Iceoryx2.write_payload!(response_mut, UInt64(84))
        Iceoryx2.send!(response_mut)
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
        resp_hdr = Iceoryx2.header(response)
        @test Iceoryx2.number_of_elements(resp_hdr) == 1
        server_id = Iceoryx2.server_id(resp_hdr)
        @test isvalid(server_id)
        close(server_id)
        close(resp_hdr)
    end

    close(node)
end
