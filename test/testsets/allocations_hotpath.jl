@testset "AllocationsHotPath" begin
    payload_alloc(sample::Iceoryx2.Sample{UInt64}) = @allocated Iceoryx2.payload(sample)
    payload_mut_alloc(sample::Iceoryx2.SampleMut{UInt64}) = @allocated Iceoryx2.payload_mut(sample)
    payload_req_alloc(req::Iceoryx2.RequestMut{UInt64,UInt64}) = @allocated Iceoryx2.payload_mut(req)
    payload_active_alloc(req::Iceoryx2.ActiveRequest{UInt64,UInt64}) = @allocated Iceoryx2.payload(req)
    payload_resp_alloc(resp::Iceoryx2.Response{UInt64}) = @allocated Iceoryx2.payload(resp)
    unsafe_payload_ptr_alloc(sample::Iceoryx2.Sample{UInt64}) = @allocated Iceoryx2.unsafe_payload_ptr(sample)
    unsafe_payload_mut_ptr_alloc(sample::Iceoryx2.SampleMut{UInt64}) = @allocated Iceoryx2.unsafe_payload_mut_ptr(sample)
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
    has_event_alloc(id::Iceoryx2.WaitsetAttachmentId, guard::Iceoryx2.WaitsetGuard) =
        @allocated Iceoryx2.has_event_from(id, guard)
    missed_deadline_alloc(id::Iceoryx2.WaitsetAttachmentId, guard::Iceoryx2.WaitsetGuard) =
        @allocated Iceoryx2.has_missed_deadline(id, guard)

    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, "iceoryx2_julia_alloc_hotpath")
    node = Iceoryx2.create(builder; service_type=:ipc)

    svc_builder = Iceoryx2.service_builder(node, "iceoryx2_julia_alloc_pubsub")
    pubsub_builder = Iceoryx2.publish_subscribe(svc_builder, UInt64)
    factory = Iceoryx2.open_or_create(pubsub_builder)

    pub = Iceoryx2.create(Iceoryx2.publisher_builder(factory))
    sub = Iceoryx2.create(Iceoryx2.subscriber_builder(factory))

    data = UInt64[1]
    sample = nothing
    for _ in 1:50
        Iceoryx2.send_copy(pub, data)
        sample = Iceoryx2.receive(sub)
        sample !== nothing && break
        sleep(0.01)
    end
    @test sample !== nothing

    if sample !== nothing
        Iceoryx2.payload(sample)
        slice = Iceoryx2.payload(sample)

        @test payload_alloc(sample) == 0
        @test unsafe_payload_ptr_alloc(sample) == 0
        @test @allocated(length(slice)) == 0
        @test @allocated(slice[1]) == 0
    end

    loaned = Iceoryx2.loan_slice(pub, 1)
    Iceoryx2.payload_mut(loaned)
    @test payload_mut_alloc(loaned) == 0
    @test unsafe_payload_mut_ptr_alloc(loaned) == 0
    @test write_payload_alloc(loaned, UInt64(7)) == 0
    close(loaned)

    rr_builder = Iceoryx2.request_response(Iceoryx2.service_builder(node, "iceoryx2_julia_alloc_rr"), UInt64, UInt64)
    rr_factory = Iceoryx2.open_or_create(rr_builder)

    client = Iceoryx2.create(Iceoryx2.client_builder(rr_factory))
    server = Iceoryx2.create(Iceoryx2.server_builder(rr_factory))

    req = Iceoryx2.loan_request(client, 1)
    Iceoryx2.payload_mut(req)
    @test payload_req_alloc(req) == 0
    @test unsafe_payload_req_mut_ptr_alloc(req) == 0
    @test write_payload_req_alloc(req, UInt64(1)) == 0
    pending = Iceoryx2.send!(req)

    active = nothing
    for _ in 1:50
        active = Iceoryx2.receive(server)
        active !== nothing && break
        sleep(0.01)
    end
    @test active !== nothing

    if active !== nothing
        Iceoryx2.payload(active)
        @test payload_active_alloc(active) == 0
        @test unsafe_payload_active_ptr_alloc(active) == 0
        resp = Iceoryx2.loan_response(active, 1)
        Iceoryx2.payload_mut(resp)
        @test unsafe_payload_resp_mut_ptr_alloc(resp) == 0
        @test write_payload_resp_alloc(resp, UInt64(2)) == 0
        Iceoryx2.send!(resp)
    end

    resp = nothing
    for _ in 1:50
        resp = Iceoryx2.receive(pending)
        resp !== nothing && break
        sleep(0.01)
    end
    @test resp !== nothing

    if resp !== nothing
        Iceoryx2.payload(resp)
        @test payload_resp_alloc(resp) == 0
        @test unsafe_payload_resp_ptr_alloc(resp) == 0
    end

    waitset_builder = Iceoryx2.WaitsetBuilder()
    waitset = Iceoryx2.create(waitset_builder; service_type=:ipc)
    guard = Iceoryx2.attach_interval(waitset, 0, 10_000_000)
    attachment = Iceoryx2.attachment_id(guard)

    Iceoryx2.has_event_from(attachment, guard)
    @test has_event_alloc(attachment, guard) == 0
    Iceoryx2.has_missed_deadline(attachment, guard)
    @test missed_deadline_alloc(attachment, guard) == 0

    event_builder = Iceoryx2.event(Iceoryx2.service_builder(node, unique_service_name()))
    event_factory = Iceoryx2.open_or_create(event_builder)
    listener = Iceoryx2.create(Iceoryx2.listener_builder(event_factory))
    try_wait_alloc(l::Iceoryx2.Listener) = @allocated Iceoryx2.try_wait_one(l)
    Iceoryx2.try_wait_one(listener)
    @test try_wait_alloc(listener) == 0
    close(listener)
    close(event_factory)

    bb_builder = Iceoryx2.blackboard_creator(Iceoryx2.service_builder(node, unique_service_name()), UInt64)
    Iceoryx2.add_with_default!(bb_builder, UInt64(1), UInt64(0))
    bb_factory = Iceoryx2.create(bb_builder)
    bb_writer = Iceoryx2.create(Iceoryx2.writer_builder(bb_factory))
    bb_reader = Iceoryx2.create(Iceoryx2.reader_builder(bb_factory))
    entry_mut = Iceoryx2.writer_entry(bb_writer, UInt64(1), UInt64)
    entry = Iceoryx2.reader_entry(bb_reader, UInt64(1), UInt64)
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

    close(attachment)
    close(guard)
    close(waitset)
    close(node)
    close(factory)
    close(rr_factory)
end
