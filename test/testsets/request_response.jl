@testset "RequestResponse" begin
    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, "iceoryx2_julia_test_node_rr")
    node = Iceoryx2.create(builder; service_type=:ipc)

    svc_builder_hdr = Iceoryx2.service_builder(node, "iceoryx2_julia_test_service_rr_hdr")
    rr_hdr_builder = Iceoryx2.request_response(svc_builder_hdr, UInt64, UInt64)
    rr_hdr_builder = Iceoryx2.request_user_header(rr_hdr_builder, UInt16)
    @test_throws MethodError Iceoryx2.request_user_header(rr_hdr_builder, UInt32)
    rr_hdr_builder = Iceoryx2.response_user_header(rr_hdr_builder, UInt8)
    @test_throws MethodError Iceoryx2.response_user_header(rr_hdr_builder, UInt16)
    factory_hdr = Iceoryx2.open_or_create(rr_hdr_builder)
    close(factory_hdr)

    svc_builder = Iceoryx2.service_builder(node, "iceoryx2_julia_test_service_rr")
    rr_builder = Iceoryx2.request_response(svc_builder, UInt64, UInt64)
    factory = Iceoryx2.open_or_create(rr_builder)

    client = Iceoryx2.create(Iceoryx2.client_builder(factory))
    server = Iceoryx2.create(Iceoryx2.server_builder(factory))
    request = Iceoryx2.RequestMut(client)
    pending = Iceoryx2.PendingResponse(client)
    response = Iceoryx2.Response(pending)
    active = Iceoryx2.ActiveRequest(server)
    response_mut = Iceoryx2.ResponseMut(active)

    Iceoryx2.loan!(client, request)
    init_payload = Iceoryx2.payload_mut(request)
    @test init_payload[1] == zero(UInt64)
    close(request)

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

    Iceoryx2.loan_uninit!(client, request)
    Iceoryx2.write_payload!(request, UInt64(42))
    req_hdr = Iceoryx2.header(request)
    @test Iceoryx2.number_of_elements(req_hdr) == 1
    client_id = Iceoryx2.client_id(req_hdr)
    @test isvalid(client_id)
    close(client_id)
    close(req_hdr)
    Iceoryx2.send!(request, pending)

    received = false
    for _ in 1:50
        if Iceoryx2.receive!(server, active)
            received = true
            break
        end
        sleep(0.01)
    end
    @test received
    if received
        try
            req_payload = Iceoryx2.payload(active)
            @test req_payload[1] == UInt64(42)

            Iceoryx2.loan_uninit!(active, response_mut)
            Iceoryx2.write_payload!(response_mut, UInt64(84))
            Iceoryx2.send!(response_mut)
        finally
            close(active)
        end
    end

    got_response = false
    for _ in 1:50
        if Iceoryx2.receive!(pending, response)
            got_response = true
            break
        end
        sleep(0.01)
    end
    @test got_response
    if got_response
        try
            resp_payload = Iceoryx2.payload(response)
            @test resp_payload[1] == UInt64(84)
            resp_hdr = Iceoryx2.header(response)
            @test Iceoryx2.number_of_elements(resp_hdr) == 1
            server_id = Iceoryx2.server_id(resp_hdr)
            @test isvalid(server_id)
            close(server_id)
            close(resp_hdr)
        finally
            close(response)
        end
    end
    close(pending)

    close(node)
end

@testset "RequestResponseTuplePayload" begin
    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, "iceoryx2_julia_test_node_rr_tuple")
    node = Iceoryx2.create(builder; service_type=:ipc)

    svc_builder = Iceoryx2.service_builder(node, unique_service_name())
    rr_builder = Iceoryx2.request_response(
        svc_builder,
        Tuple{UInt32,Float64},
        Tuple{UInt16,UInt8},
    )
    factory = Iceoryx2.open_or_create(rr_builder)

    client = Iceoryx2.create(Iceoryx2.client_builder(factory))
    server = Iceoryx2.create(Iceoryx2.server_builder(factory))
    request = Iceoryx2.RequestMut(client)
    pending = Iceoryx2.PendingResponse(client)
    response = Iceoryx2.Response(pending)
    active = Iceoryx2.ActiveRequest(server)
    response_mut = Iceoryx2.ResponseMut(active)

    Iceoryx2.loan_uninit!(client, request)
    req_payload = (UInt32(11), 2.5)
    Iceoryx2.write_payload!(request, req_payload)
    Iceoryx2.send!(request, pending)

    received = false
    for _ in 1:50
        if Iceoryx2.receive!(server, active)
            received = true
            break
        end
        sleep(0.01)
    end
    @test received
    if received
        try
            got = Iceoryx2.payload(active)
            @test got[1] == req_payload

            Iceoryx2.loan_uninit!(active, response_mut)
            resp_payload = (UInt16(9), UInt8(3))
            Iceoryx2.write_payload!(response_mut, resp_payload)
            Iceoryx2.send!(response_mut)
        finally
            close(active)
        end
    end

    got_response = false
    for _ in 1:50
        if Iceoryx2.receive!(pending, response)
            got_response = true
            break
        end
        sleep(0.01)
    end
    @test got_response
    if got_response
        try
            resp_got = Iceoryx2.payload(response)
            @test resp_got[1] == (UInt16(9), UInt8(3))
        finally
            close(response)
        end
    end
    close(pending)

    close(node)
end
