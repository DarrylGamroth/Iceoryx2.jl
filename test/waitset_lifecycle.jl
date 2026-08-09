@testset "WaitSetLifecycle" begin
    disabled_builder = Iceoryx2.WaitSetBuilder(TEST_SERVICE_TYPE)
    @test_throws MethodError Iceoryx2.signal_handling_mode!(
        disabled_builder,
        Iceoryx2.Iceoryx2FFI.iox2_signal_handling_mode_e_DISABLED
    )
    Iceoryx2.signal_handling_mode!(disabled_builder, :disabled)
    disabled_waitset = Iceoryx2.create(disabled_builder)
    try
        @test isempty(disabled_waitset)
        @test length(disabled_waitset) == 0
        @test Iceoryx2.capacity(disabled_waitset) >= 0
        @test Iceoryx2.signal_handling_mode(disabled_waitset) ==
              Iceoryx2.SignalHandlingModeDisabled
    finally
        close(disabled_waitset)
    end

    signal_builder = Iceoryx2.WaitSetBuilder(TEST_SERVICE_TYPE)
    Iceoryx2.signal_handling_mode!(signal_builder, :handle_termination_requests)
    signal_waitset = Iceoryx2.create(signal_builder)
    try
        @test Iceoryx2.signal_handling_mode(signal_waitset) ==
              Iceoryx2.SignalHandlingModeHandleTerminationRequests
    finally
        close(signal_waitset)
    end

    interval_waitset = Iceoryx2.create(Iceoryx2.WaitSetBuilder(TEST_SERVICE_TYPE))
    interval_guards = Iceoryx2.WaitSetGuard[]
    interval_ids = Iceoryx2.WaitSetAttachmentId[]
    try
        for idx in 1:3
            guard = Iceoryx2.attach_interval(interval_waitset, 100 + idx, 0)
            push!(interval_guards, guard)
            id = Iceoryx2.attachment_id(guard)
            push!(interval_ids, id)
            @test id == id
            @test length(interval_waitset) == idx
            @test !isempty(interval_waitset)
        end

        for idx in 1:3
            close(interval_guards[idx])
            @test length(interval_waitset) == 3 - idx
        end
        @test isempty(interval_waitset)
    finally
        foreach(close, interval_ids)
        foreach(close, interval_guards)
        close(interval_waitset)
    end

    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, unique_node_name())
    node = Iceoryx2.create(node_builder, TEST_SERVICE_TYPE)
    event_factory = Iceoryx2.create(Iceoryx2.event(Iceoryx2.service_builder(node, unique_service_name())))
    listener = Iceoryx2.create(Iceoryx2.listener_builder(event_factory))
    deadline_waitset = Iceoryx2.create(Iceoryx2.WaitSetBuilder(TEST_SERVICE_TYPE))
    deadline_guard = Iceoryx2.attach_deadline(
        deadline_waitset,
        Iceoryx2.file_descriptor(listener),
        0,
        1
    )
    deadline_id = Iceoryx2.attachment_id(deadline_guard)
    try
        missed_deadline = Ref(false)
        result = Iceoryx2.wait_and_process_once(deadline_waitset, 0, 500_000_000) do attachment
            @test attachment == deadline_id
            @test Iceoryx2.has_missed_deadline(attachment, deadline_guard)
            missed_deadline[] = true
            return true
        end
        @test missed_deadline[]
        @test result == Iceoryx2.WaitSetRunResultAllEventsHandled
        @test_throws ErrorException Iceoryx2.wait_and_process_once(
            deadline_waitset,
            0,
            500_000_000
        ) do _
            error("waitset callback failure")
        end
    finally
        close(deadline_id)
        close(deadline_guard)
        close(deadline_waitset)
        close(listener)
        close(event_factory)
        close(node)
    end
end
