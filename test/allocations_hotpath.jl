@testset "AllocationsHotPath" begin
    payload_alloc(sample::Iceoryx2.Sample{UInt64}) = @allocated Iceoryx2.payload(sample)
    payload_mut_alloc(sample::Iceoryx2.SampleMut{UInt64}) = @allocated Iceoryx2.payload_mut(sample)
    payload_req_alloc(req::Iceoryx2.RequestMut{UInt64,UInt64}) = @allocated Iceoryx2.payload_mut(req)
    payload_active_alloc(req::Iceoryx2.ActiveRequest{UInt64,UInt64}) = @allocated Iceoryx2.payload(req)
    payload_resp_alloc(resp::Iceoryx2.Response{UInt64}) = @allocated Iceoryx2.payload(resp)
    unsafe_payload_ptr_alloc(sample::Iceoryx2.Sample{UInt64}) = @allocated Iceoryx2.unsafe_payload_ptr(sample)
    unsafe_payload_mut_ptr_alloc(sample::Iceoryx2.SampleMut{UInt64}) = @allocated Iceoryx2.unsafe_payload_mut_ptr(sample)
    send_copy_alloc(pub::Iceoryx2.Publisher{S,UInt64,Nothing}, data::Vector{UInt64}) where {S} =
        @allocated Iceoryx2.send_copy(pub, data)
    loan_slice_alloc(pub::Iceoryx2.Publisher{S,UInt64,Nothing}, sample::Iceoryx2.SampleMut{UInt64,Nothing}) where {S} =
        @allocated Iceoryx2.loan_slice!(pub, sample, 1)
    try_loan_slice_alloc(pub::Iceoryx2.Publisher{S,UInt64,Nothing}, sample::Iceoryx2.SampleMut{UInt64,Nothing}) where {S} =
        @allocated Iceoryx2.try_loan_slice_uninit!(pub, sample, 1)
    send_alloc(sample::Iceoryx2.SampleMut{UInt64,Nothing}) = @allocated Iceoryx2.send!(sample)
    write_payload_alloc(sample::Iceoryx2.SampleMut{UInt64}, value::UInt64) = @allocated Iceoryx2.write_payload!(sample, value)
    unsafe_payload_req_mut_ptr_alloc(req::Iceoryx2.RequestMut{UInt64,UInt64}) =
        @allocated Iceoryx2.unsafe_payload_mut_ptr(req)
    write_payload_req_alloc(req::Iceoryx2.RequestMut{UInt64,UInt64}, value::UInt64) =
        @allocated Iceoryx2.write_payload!(req, value)
    unsafe_payload_active_ptr_alloc(req::Iceoryx2.ActiveRequest{UInt64,UInt64}) =
        @allocated Iceoryx2.unsafe_payload_ptr(req)
    unsafe_payload_resp_ptr_alloc(resp::Iceoryx2.Response{UInt64}) = @allocated Iceoryx2.unsafe_payload_ptr(resp)
    unsafe_payload_resp_mut_ptr_alloc(resp::Iceoryx2.ResponseMut{UInt64}) =
        @allocated Iceoryx2.unsafe_payload_mut_ptr(resp)
    write_payload_resp_alloc(resp::Iceoryx2.ResponseMut{UInt64}, value::UInt64) =
        @allocated Iceoryx2.write_payload!(resp, value)
    header_sample_alloc(sample::Iceoryx2.Sample) = @allocated Iceoryx2.header(sample)
    header_sample_mut_alloc(sample::Iceoryx2.SampleMut) = @allocated Iceoryx2.header(sample)
    header_request_alloc(req::Iceoryx2.RequestMut) = @allocated Iceoryx2.header(req)
    header_pending_alloc(pending::Iceoryx2.PendingResponse) = @allocated Iceoryx2.header(pending)
    header_active_alloc(req::Iceoryx2.ActiveRequest) = @allocated Iceoryx2.header(req)
    header_response_alloc(resp::Iceoryx2.Response) = @allocated Iceoryx2.header(resp)
    header_response_mut_alloc(resp::Iceoryx2.ResponseMut) = @allocated Iceoryx2.header(resp)
    user_header_sample_alloc(sample::Iceoryx2.Sample) = @allocated Iceoryx2.user_header(sample)
    user_header_sample_mut_alloc(sample::Iceoryx2.SampleMut) = @allocated Iceoryx2.user_header(sample)
    user_header_sample_mut_mut_alloc(sample::Iceoryx2.SampleMut) = @allocated Iceoryx2.user_header_mut(sample)
    user_header_request_alloc(req::Iceoryx2.RequestMut) = @allocated Iceoryx2.user_header(req)
    user_header_request_mut_alloc(req::Iceoryx2.RequestMut) = @allocated Iceoryx2.user_header_mut(req)
    user_header_pending_alloc(pending::Iceoryx2.PendingResponse) = @allocated Iceoryx2.user_header(pending)
    user_header_active_alloc(req::Iceoryx2.ActiveRequest) = @allocated Iceoryx2.user_header(req)
    user_header_response_alloc(resp::Iceoryx2.Response) = @allocated Iceoryx2.user_header(resp)
    user_header_response_mut_alloc(resp::Iceoryx2.ResponseMut) = @allocated Iceoryx2.user_header(resp)
    user_header_response_mut_mut_alloc(resp::Iceoryx2.ResponseMut) = @allocated Iceoryx2.user_header_mut(resp)
    loan_request_alloc(
        client::Iceoryx2.Client{S,UInt64,UInt64,Nothing,Nothing},
        req::Iceoryx2.RequestMut{UInt64,UInt64,Nothing,Nothing},
    ) where {S} = @allocated Iceoryx2.loan_request!(client, req, 1)
    try_loan_request_alloc(
        client::Iceoryx2.Client{S,UInt64,UInt64,Nothing,Nothing},
        req::Iceoryx2.RequestMut{UInt64,UInt64,Nothing,Nothing},
    ) where {S} = @allocated Iceoryx2.try_loan_slice_uninit!(client, req, 1)
    send_request_alloc(
        req::Iceoryx2.RequestMut{UInt64,UInt64,Nothing,Nothing},
        pending::Iceoryx2.PendingResponse{UInt64,Nothing,Nothing},
    ) = @allocated Iceoryx2.send!(req, pending)
    loan_response_alloc(
        req::Iceoryx2.ActiveRequest{UInt64,UInt64,Nothing,Nothing},
        resp::Iceoryx2.ResponseMut{UInt64,Nothing},
    ) = @allocated Iceoryx2.loan_response!(req, resp, 1)
    try_loan_response_alloc(
        req::Iceoryx2.ActiveRequest{UInt64,UInt64,Nothing,Nothing},
        resp::Iceoryx2.ResponseMut{UInt64,Nothing},
    ) = @allocated Iceoryx2.try_loan_slice_uninit!(req, resp, 1)
    send_response_alloc(resp::Iceoryx2.ResponseMut{UInt64,Nothing}) = @allocated Iceoryx2.send!(resp)
    has_event_alloc(id::Iceoryx2.WaitsetAttachmentId{S}, guard::Iceoryx2.WaitsetGuard{S}) where {S} =
        @allocated Iceoryx2.has_event_from(id, guard)
    missed_deadline_alloc(id::Iceoryx2.WaitsetAttachmentId{S}, guard::Iceoryx2.WaitsetGuard{S}) where {S} =
        @allocated Iceoryx2.has_missed_deadline(id, guard)
    waitset_once_alloc(waitset::Iceoryx2.Waitset{S}, handler::Iceoryx2.WaitsetHandler{S}) where {S} =
        @allocated Iceoryx2.wait_and_process_once(waitset, 0, 0, handler)
    function receive_with_retry!(sub::Iceoryx2.Subscriber{S,T,UH}, sample::Iceoryx2.Sample{T,UH}) where {S,T,UH}
        for _ in 1:1000
            Iceoryx2.receive!(sub, sample) && return sample
        end
        error("timed out waiting for sample")
    end
    receive_alloc(sub::Iceoryx2.Subscriber{S,T,UH}, sample::Iceoryx2.Sample{T,UH}) where {S,T,UH} =
        @allocated receive_with_retry!(sub, sample)
    function receive_with_retry!(
        server::Iceoryx2.Server{S,Req,Resp,ReqH,RespH},
        req::Iceoryx2.ActiveRequest{Req,Resp,ReqH,RespH},
    ) where {S,Req,Resp,ReqH,RespH}
        for _ in 1:1000
            Iceoryx2.receive!(server, req) && return req
        end
        error("timed out waiting for request")
    end
    receive_request_alloc(
        server::Iceoryx2.Server{S,Req,Resp,ReqH,RespH},
        req::Iceoryx2.ActiveRequest{Req,Resp,ReqH,RespH},
    ) where {S,Req,Resp,ReqH,RespH} = @allocated receive_with_retry!(server, req)
    function receive_with_retry!(
        pending::Iceoryx2.PendingResponse{Resp,ReqH,RespH},
        resp::Iceoryx2.Response{Resp,RespH},
    ) where {Resp,ReqH,RespH}
        for _ in 1:1000
            Iceoryx2.receive!(pending, resp) && return resp
        end
        error("timed out waiting for response")
    end
    receive_response_alloc(
        pending::Iceoryx2.PendingResponse{Resp,ReqH,RespH},
        resp::Iceoryx2.Response{Resp,RespH},
    ) where {Resp,ReqH,RespH} = @allocated receive_with_retry!(pending, resp)
    each_attr_value_ptr_alloc(
        attrs::Union{Iceoryx2.AttributeSet, Iceoryx2.AttributeSetView},
        key::String,
        handler::Iceoryx2.AbstractAttributeValuePtrHandler,
    ) = @allocated Iceoryx2.each_attribute_value_ptr(attrs, key, handler)

    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, "iceoryx2_julia_alloc_hotpath")
    node = Iceoryx2.create(builder, Iceoryx2.ServiceType.IPC)

    svc_builder = Iceoryx2.service_builder(node, "iceoryx2_julia_alloc_pubsub")
    pubsub_builder = Iceoryx2.publish_subscribe(svc_builder, UInt64)
    factory = Iceoryx2.open_or_create(pubsub_builder)

    pub = Iceoryx2.create(Iceoryx2.publisher_builder(factory))
    sub = Iceoryx2.create(Iceoryx2.subscriber_builder(factory))
    sample = Iceoryx2.Sample(sub)
    loaned = Iceoryx2.SampleMut(pub)

    data = UInt64[1]
    @test send_copy_alloc(pub, data) == 0
    sleep(0.01)
    @test receive_alloc(sub, sample) == 0

    Iceoryx2.payload(sample)
    slice = Iceoryx2.payload(sample)

    @test payload_alloc(sample) == 0
    @test unsafe_payload_ptr_alloc(sample) == 0
    @test @allocated(length(slice)) == 0
    @test @allocated(slice[1]) == 0
    @test header_sample_alloc(sample) == 0
    close(sample)

    @test try_loan_slice_alloc(pub, loaned) == 0
    close(loaned)
    @test loan_slice_alloc(pub, loaned) == 0
    Iceoryx2.payload_mut(loaned)
    @test payload_mut_alloc(loaned) == 0
    @test unsafe_payload_mut_ptr_alloc(loaned) == 0
    @test write_payload_alloc(loaned, UInt64(7)) == 0
    @test header_sample_mut_alloc(loaned) == 0
    @test send_alloc(loaned) == 0
    close(loaned)

    rr_builder = Iceoryx2.request_response(Iceoryx2.service_builder(node, "iceoryx2_julia_alloc_rr"), UInt64, UInt64)
    rr_factory = Iceoryx2.open_or_create(rr_builder)

    client = Iceoryx2.create(Iceoryx2.client_builder(rr_factory))
    server = Iceoryx2.create(Iceoryx2.server_builder(rr_factory))
    req = Iceoryx2.RequestMut(client)
    pending = Iceoryx2.PendingResponse(client)
    active = Iceoryx2.ActiveRequest(server)
    resp = Iceoryx2.Response(pending)
    response_mut = Iceoryx2.ResponseMut(active)

    @test try_loan_request_alloc(client, req) == 0
    close(req)
    @test loan_request_alloc(client, req) == 0
    Iceoryx2.payload_mut(req)
    @test payload_req_alloc(req) == 0
    @test unsafe_payload_req_mut_ptr_alloc(req) == 0
    @test write_payload_req_alloc(req, UInt64(1)) == 0
    @test send_request_alloc(req, pending) == 0

    sleep(0.01)
    @test receive_request_alloc(server, active) == 0

    try
        Iceoryx2.payload(active)
        @test payload_active_alloc(active) == 0
        @test unsafe_payload_active_ptr_alloc(active) == 0
        @test header_active_alloc(active) == 0
        @test try_loan_response_alloc(active, response_mut) == 0
        close(response_mut)
        @test loan_response_alloc(active, response_mut) == 0
        Iceoryx2.payload_mut(response_mut)
        @test unsafe_payload_resp_mut_ptr_alloc(response_mut) == 0
        @test write_payload_resp_alloc(response_mut, UInt64(2)) == 0
        @test header_response_mut_alloc(response_mut) == 0
        @test send_response_alloc(response_mut) == 0
    finally
        close(active)
    end

    sleep(0.01)
    @test receive_response_alloc(pending, resp) == 0

    try
        Iceoryx2.payload(resp)
        @test payload_resp_alloc(resp) == 0
        @test unsafe_payload_resp_ptr_alloc(resp) == 0
        @test header_response_alloc(resp) == 0
    finally
        close(resp)
    end
    close(pending)

    waitset_builder = Iceoryx2.WaitsetBuilder(Iceoryx2.ServiceType.IPC)
    waitset = Iceoryx2.create(waitset_builder)
    guard = Iceoryx2.attach_interval(waitset, 0, 10_000_000)
    attachment = Iceoryx2.attachment_id(guard)

    Iceoryx2.has_event_from(attachment, guard)
    @test has_event_alloc(attachment, guard) == 0
    Iceoryx2.has_missed_deadline(attachment, guard)
    @test missed_deadline_alloc(attachment, guard) == 0

    struct WaitsetCallback end
    (::WaitsetCallback)(::Iceoryx2.WaitsetAttachmentId{S}) where {S} = :stop
    handler = Iceoryx2.WaitsetHandler(WaitsetCallback(), waitset)
    Iceoryx2.wait_and_process_once(waitset, 0, 0, handler)
    @test waitset_once_alloc(waitset, handler) == 0

    event_builder = Iceoryx2.event(Iceoryx2.service_builder(node, unique_service_name()))
    event_factory = Iceoryx2.open_or_create(event_builder)
    listener = Iceoryx2.create(Iceoryx2.listener_builder(event_factory))
    try_wait_alloc(l::Iceoryx2.Listener) = @allocated Iceoryx2.try_wait_one(l)
    Iceoryx2.try_wait_one(listener)
    @test try_wait_alloc(listener) == 0
    close(listener)
    close(event_factory)

    bb_builder = Iceoryx2.blackboard_creator(Iceoryx2.service_builder(node, unique_service_name()), UInt64)
    Iceoryx2.add!(bb_builder, UInt64(1), UInt64(0))
    bb_factory = Iceoryx2.create(bb_builder)
    bb_writer = Iceoryx2.create(Iceoryx2.writer_builder(bb_factory))
    bb_reader = Iceoryx2.create(Iceoryx2.reader_builder(bb_factory))
    entry_mut = Iceoryx2.EntryHandleMut(bb_writer, UInt64)
    entry = Iceoryx2.EntryHandle(bb_reader, UInt64)
    Iceoryx2.entry!(bb_writer, entry_mut, UInt64(1))
    Iceoryx2.entry!(bb_reader, entry, UInt64(1))
    value_ref = Ref{UInt64}(0)
    generation_ref = Ref{UInt64}(0)
    Iceoryx2.update!(entry_mut, UInt64(1))
    Iceoryx2.get!(entry, value_ref, generation_ref)
    Iceoryx2.entry_id(entry)
    Iceoryx2.is_up_to_date(entry, generation_ref[])

    entry_id_alloc(entry::Iceoryx2.EntryHandle) = @allocated Iceoryx2.entry_id(entry)
    get_alloc(entry::Iceoryx2.EntryHandle, value_ref, generation_ref) =
        @allocated Iceoryx2.get!(entry, value_ref, generation_ref)
    update_alloc(entry::Iceoryx2.EntryHandleMut, value_ref) = @allocated Iceoryx2.update!(entry, value_ref)
    up_to_date_alloc(entry::Iceoryx2.EntryHandle, generation_ref) =
        @allocated Iceoryx2.is_up_to_date(entry, generation_ref[])

    @test entry_id_alloc(entry) == 0
    @test get_alloc(entry, value_ref, generation_ref) == 0
    @test update_alloc(entry_mut, value_ref) == 0
    @test up_to_date_alloc(entry, generation_ref) == 0

    close(entry)
    close(entry_mut)
    close(bb_reader)
    close(bb_writer)
    close(bb_factory)

    pubsub_hdr_builder = Iceoryx2.publish_subscribe(
        Iceoryx2.service_builder(node, unique_service_name()),
        UInt64,
    )
    pubsub_hdr_builder = Iceoryx2.user_header(pubsub_hdr_builder, UInt16)
    pubsub_hdr_factory = Iceoryx2.open_or_create(pubsub_hdr_builder)
    pubsub_hdr_pub = Iceoryx2.create(Iceoryx2.publisher_builder(pubsub_hdr_factory))
    pubsub_hdr_sub = Iceoryx2.create(Iceoryx2.subscriber_builder(pubsub_hdr_factory))
    sample_hdr = Iceoryx2.Sample(pubsub_hdr_sub)
    loaned_hdr = Iceoryx2.SampleMut(pubsub_hdr_pub)
    Iceoryx2.send_copy(pubsub_hdr_pub, UInt64[7])
    sleep(0.01)
    receive_with_retry!(pubsub_hdr_sub, sample_hdr)
    @test user_header_sample_alloc(sample_hdr) == 0
    close(sample_hdr)
    Iceoryx2.loan_slice!(pubsub_hdr_pub, loaned_hdr, 1)
    @test user_header_sample_mut_alloc(loaned_hdr) == 0
    @test user_header_sample_mut_mut_alloc(loaned_hdr) == 0
    close(loaned_hdr)
    close(pubsub_hdr_sub)
    close(pubsub_hdr_pub)
    close(pubsub_hdr_factory)

    rr_hdr_builder = Iceoryx2.request_response(
        Iceoryx2.service_builder(node, unique_service_name()),
        UInt64,
        UInt64,
    )
    rr_hdr_builder = Iceoryx2.request_user_header(rr_hdr_builder, UInt32)
    rr_hdr_builder = Iceoryx2.response_user_header(rr_hdr_builder, UInt16)
    rr_hdr_factory = Iceoryx2.open_or_create(rr_hdr_builder)
    rr_hdr_client = Iceoryx2.create(Iceoryx2.client_builder(rr_hdr_factory))
    rr_hdr_server = Iceoryx2.create(Iceoryx2.server_builder(rr_hdr_factory))
    req_hdr = Iceoryx2.RequestMut(rr_hdr_client)
    pending_hdr = Iceoryx2.PendingResponse(rr_hdr_client)
    active_hdr = Iceoryx2.ActiveRequest(rr_hdr_server)
    resp_hdr = Iceoryx2.Response(pending_hdr)
    resp_mut_hdr = Iceoryx2.ResponseMut(active_hdr)
    Iceoryx2.loan_request!(rr_hdr_client, req_hdr, 1)
    @test header_request_alloc(req_hdr) == 0
    @test user_header_request_alloc(req_hdr) == 0
    @test user_header_request_mut_alloc(req_hdr) == 0
    Iceoryx2.send!(req_hdr, pending_hdr)
    @test header_pending_alloc(pending_hdr) == 0
    @test user_header_pending_alloc(pending_hdr) == 0
    sleep(0.01)
    receive_with_retry!(rr_hdr_server, active_hdr)
    @test header_active_alloc(active_hdr) == 0
    @test user_header_active_alloc(active_hdr) == 0
    Iceoryx2.loan_response!(active_hdr, resp_mut_hdr, 1)
    @test header_response_mut_alloc(resp_mut_hdr) == 0
    @test user_header_response_mut_alloc(resp_mut_hdr) == 0
    @test user_header_response_mut_mut_alloc(resp_mut_hdr) == 0
    Iceoryx2.send!(resp_mut_hdr)
    sleep(0.01)
    receive_with_retry!(pending_hdr, resp_hdr)
    @test header_response_alloc(resp_hdr) == 0
    @test user_header_response_alloc(resp_hdr) == 0
    close(resp_hdr)
    close(active_hdr)
    close(pending_hdr)
    close(rr_hdr_server)
    close(rr_hdr_client)
    close(rr_hdr_factory)

    specifier = Iceoryx2.AttributeSpecifier()
    Iceoryx2.define!(specifier, "mode", "fast")
    attrs = Iceoryx2.attributes(specifier)
    struct AttrPtrHandler end
    (::AttrPtrHandler)(::Cstring) = true
    attr_handler = Iceoryx2.AttributeValuePtrHandler(AttrPtrHandler())
    Iceoryx2.each_attribute_value_ptr(attrs, "mode", attr_handler)
    @test each_attr_value_ptr_alloc(attrs, "mode", attr_handler) == 0
    close(specifier)

    close(attachment)
    close(guard)
    close(waitset)
    close(node)
    close(factory)
    close(rr_factory)
end
