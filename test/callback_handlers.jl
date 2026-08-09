_callback_backpressure_retry(::Iceoryx2.BackpressureInfoRef) = Iceoryx2.BackpressureRetry
_callback_degradation_warn(_, ::Iceoryx2.DegradationInfoRef) = Iceoryx2.DegradationWarn

_callback_backpressure_alloc(handler) =
    @allocated Iceoryx2._backpressure_handler_wrapper(C_NULL, handler)

_callback_degradation_alloc(handler) = @allocated Iceoryx2._degradation_handler_wrapper(
    Iceoryx2.Iceoryx2FFI.iox2_degradation_cause_e_CONNECTION_CORRUPTED,
    C_NULL,
    handler,
)

struct _CountingBackpressureAction
    count::Base.RefValue{Int}
    action::Iceoryx2.BackpressureAction
end

function (handler::_CountingBackpressureAction)(::Iceoryx2.BackpressureInfoRef)
    handler.count[] += 1
    return handler.action
end

struct _RetryThenDiscardBackpressureAction
    count::Base.RefValue{Int}
    retry_count::UInt64
end

function (handler::_RetryThenDiscardBackpressureAction)(info::Iceoryx2.BackpressureInfoRef)
    Iceoryx2.retries(info) == handler.retry_count && return Iceoryx2.BackpressureDiscardData
    handler.count[] += 1
    return Iceoryx2.BackpressureRetry
end

struct _ElapsedThenDiscardBackpressureAction
    count::Base.RefValue{Int}
    threshold_ns::UInt64
end

function (handler::_ElapsedThenDiscardBackpressureAction)(info::Iceoryx2.BackpressureInfoRef)
    seconds, nanoseconds = Iceoryx2.elapsed_time(info)
    elapsed_ns = seconds * UInt64(1_000_000_000) + UInt64(nanoseconds)
    elapsed_ns >= handler.threshold_ns && return Iceoryx2.BackpressureDiscardData
    handler.count[] += 1
    return Iceoryx2.BackpressureRetry
end

function _receive_backpressure_request!(server, active)
    for _ in 1:1000
        Iceoryx2.receive!(server, active) && return active
        sleep(0.001)
    end
    error("timed out waiting for request")
end

function _receive_backpressure_response!(pending, response)
    for _ in 1:1000
        Iceoryx2.receive!(pending, response) && return true
        sleep(0.001)
    end
    return false
end

function _receive_backpressure_active_value!(server, active)
    for _ in 1:1000
        if Iceoryx2.receive!(server, active)
            value = Iceoryx2.payload(active)[1]
            close(active)
            return Some(value)
        end
        sleep(0.001)
    end
    return nothing
end

function _try_receive_backpressure_active_value(server, active)
    if Iceoryx2.receive!(server, active)
        value = Iceoryx2.payload(active)[1]
        close(active)
        return Some(value)
    end
    return nothing
end

function _receive_backpressure_sample_value!(subscriber, sample)
    for _ in 1:1000
        if Iceoryx2.receive!(subscriber, sample)
            value = Iceoryx2.payload(sample)[1]
            close(sample)
            return Some(value)
        end
        sleep(0.001)
    end
    return nothing
end

function _try_receive_backpressure_sample_value(subscriber, sample)
    if Iceoryx2.receive!(subscriber, sample)
        value = Iceoryx2.payload(sample)[1]
        close(sample)
        return Some(value)
    end
    return nothing
end

function _publisher_backpressure_sample_scenario(
    on_backpressure;
    safe_overflow::Bool = false,
    backpressure_strategy::Union{Nothing,Symbol} = nothing,
)
    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, unique_node_name())
    node = Iceoryx2.create(builder, TEST_SERVICE_TYPE)

    try
        pubsub_builder = Iceoryx2.publish_subscribe(Iceoryx2.service_builder(node, unique_service_name()), UInt64)
        Iceoryx2.max_publishers!(pubsub_builder, 1)
        Iceoryx2.max_subscribers!(pubsub_builder, 2)
        Iceoryx2.history_size!(pubsub_builder, 0)
        Iceoryx2.enable_safe_overflow!(pubsub_builder, safe_overflow)
        Iceoryx2.subscriber_max_buffer_size!(pubsub_builder, 1)
        Iceoryx2.subscriber_max_borrowed_samples!(pubsub_builder, 2)
        factory = Iceoryx2.create(pubsub_builder)

        try
            pub_builder = Iceoryx2.publisher_builder(factory)
            Iceoryx2.max_loaned_samples!(pub_builder, 1)
            if backpressure_strategy !== nothing
                Iceoryx2.backpressure_strategy!(pub_builder, backpressure_strategy)
            end
            Iceoryx2.backpressure_handler!(pub_builder, on_backpressure)
            pub = Iceoryx2.create(pub_builder)

            sub_builder_1 = Iceoryx2.subscriber_builder(factory)
            Iceoryx2.buffer_size!(sub_builder_1, 1)
            sub1 = Iceoryx2.create(sub_builder_1)
            sub_builder_2 = Iceoryx2.subscriber_builder(factory)
            Iceoryx2.buffer_size!(sub_builder_2, 1)
            sub2 = Iceoryx2.create(sub_builder_2)
            sample1 = Iceoryx2.Sample(sub1)
            sample2 = Iceoryx2.Sample(sub2)

            try
                Iceoryx2.update_connections!(pub)
                first_recipients = Iceoryx2.send_copy(pub, UInt64(1))
                first_sub2_value = _receive_backpressure_sample_value!(sub2, sample2)
                second_send_error = nothing
                second_recipients = 0
                try
                    second_recipients = Iceoryx2.send_copy(pub, UInt64(2))
                catch err
                    second_send_error = err
                end
                sub1_value = _receive_backpressure_sample_value!(sub1, sample1)
                sub1_second_value = _try_receive_backpressure_sample_value(sub1, sample1)
                sub2_value = _receive_backpressure_sample_value!(sub2, sample2)
                sub2_second_value = _try_receive_backpressure_sample_value(sub2, sample2)
                return (;
                    first_recipients,
                    first_sub2_value,
                    second_send_error,
                    second_recipients,
                    sub1_value,
                    sub1_second_value,
                    sub2_value,
                    sub2_second_value,
                )
            finally
                close(sample1)
                close(sample2)
                close(sub2)
                close(sub1)
                close(pub)
            end
        finally
            close(factory)
        end
    finally
        close(node)
    end
end

function _client_backpressure_request_scenario(
    on_backpressure;
    safe_overflow::Bool = false,
    backpressure_strategy::Union{Nothing,Symbol} = nothing,
)
    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, unique_node_name())
    node = Iceoryx2.create(builder, TEST_SERVICE_TYPE)

    try
        rr_builder = Iceoryx2.request_response(Iceoryx2.service_builder(node, unique_service_name()), UInt64, UInt64)
        Iceoryx2.max_servers!(rr_builder, 2)
        Iceoryx2.max_active_requests_per_client!(rr_builder, 1)
        Iceoryx2.enable_safe_overflow_for_requests!(rr_builder, safe_overflow)
        factory = Iceoryx2.create(rr_builder)

        try
            server1 = Iceoryx2.create(Iceoryx2.server_builder(factory))
            server2 = Iceoryx2.create(Iceoryx2.server_builder(factory))
            client_builder = Iceoryx2.client_builder(factory)
            if backpressure_strategy !== nothing
                Iceoryx2.backpressure_strategy!(client_builder, backpressure_strategy)
            end
            Iceoryx2.backpressure_handler!(client_builder, on_backpressure)
            client = Iceoryx2.create(client_builder)
            pending1 = Iceoryx2.PendingResponse(client)
            pending2 = Iceoryx2.PendingResponse(client)
            active1 = Iceoryx2.ActiveRequest(server1)
            active2 = Iceoryx2.ActiveRequest(server2)

            try
                Iceoryx2.receive!(server1, active1)
                Iceoryx2.receive!(server2, active2)
                Iceoryx2.send_copy!(client, UInt64[123], pending1)
                first_server2_value = _receive_backpressure_active_value!(server2, active2)
                close(pending1)

                second_send_error = nothing
                second_send_elapsed_ns = UInt64(0)
                second_send_start = time_ns()
                try
                    Iceoryx2.send_copy!(client, UInt64[456], pending2)
                catch err
                    second_send_error = err
                finally
                    second_send_elapsed_ns = time_ns() - second_send_start
                end

                server1_value = _receive_backpressure_active_value!(server1, active1)
                server1_second_value = _try_receive_backpressure_active_value(server1, active1)
                server2_value = _receive_backpressure_active_value!(server2, active2)
                server2_second_value = _try_receive_backpressure_active_value(server2, active2)
                return (;
                    first_server2_value,
                    second_send_error,
                    second_send_elapsed_ns,
                    server1_value,
                    server1_second_value,
                    server2_value,
                    server2_second_value,
                )
            finally
                close(active2)
                close(active1)
                close(pending2)
                close(pending1)
                close(client)
                close(server2)
                close(server1)
            end
        finally
            close(factory)
        end
    finally
        close(node)
    end
end

function _server_backpressure_response_scenario(
    on_backpressure;
    safe_overflow::Bool = false,
    backpressure_strategy::Union{Nothing,Symbol} = nothing,
)
    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, unique_node_name())
    node = Iceoryx2.create(builder, TEST_SERVICE_TYPE)

    try
        rr_builder = Iceoryx2.request_response(Iceoryx2.service_builder(node, unique_service_name()), UInt64, UInt64)
        Iceoryx2.max_response_buffer_size!(rr_builder, 1)
        Iceoryx2.enable_safe_overflow_for_responses!(rr_builder, safe_overflow)
        factory = Iceoryx2.create(rr_builder)

        try
            server_builder = Iceoryx2.server_builder(factory)
            if backpressure_strategy !== nothing
                Iceoryx2.backpressure_strategy!(server_builder, backpressure_strategy)
            end
            Iceoryx2.backpressure_handler!(server_builder, on_backpressure)
            server = Iceoryx2.create(server_builder)
            client = Iceoryx2.create(Iceoryx2.client_builder(factory))
            pending = Iceoryx2.PendingResponse(client)
            active = Iceoryx2.ActiveRequest(server)
            response = Iceoryx2.Response(pending)

            try
                Iceoryx2.send_copy!(client, UInt64[13], pending)
                _receive_backpressure_request!(server, active)
                Iceoryx2.send_copy(active, UInt64[123])
                second_send_error = nothing
                second_send_elapsed_ns = UInt64(0)
                second_send_start = time_ns()
                try
                    Iceoryx2.send_copy(active, UInt64[456])
                catch err
                    second_send_error = err
                finally
                    second_send_elapsed_ns = time_ns() - second_send_start
                end
                received_first = _receive_backpressure_response!(pending, response)
                first_value = received_first ? Iceoryx2.payload(response)[1] : zero(UInt64)
                close(response)
                received_second = Iceoryx2.receive!(pending, response)
                return (; second_send_error, second_send_elapsed_ns, received_first, first_value, received_second)
            finally
                close(response)
                close(active)
                close(pending)
                close(client)
                close(server)
            end
        finally
            close(factory)
        end
    finally
        close(node)
    end
end

@testset "CallbackHandlers" begin
    @test Iceoryx2._backpressure_action(:follow_strategy) ==
          Iceoryx2.Iceoryx2FFI.iox2_backpressure_action_e_FOLLOW_BACKPRESSUREY_STRATEGY
    @test_throws ArgumentError Iceoryx2._backpressure_action(:follow_backpressure_strategy)

    backpressure = Iceoryx2.BackpressureHandler() do info
        @test info isa Iceoryx2.BackpressureInfoRef
        return Iceoryx2.BackpressureRetry
    end
    @test Iceoryx2._backpressure_handler_wrapper(C_NULL, backpressure) ==
          Iceoryx2.Iceoryx2FFI.iox2_backpressure_action_e_RETRY
    @test Iceoryx2.last_callback_exception(backpressure) === nothing

    failing_backpressure = Iceoryx2.BackpressureHandler(_ -> error("backpressure failure"))
    @test Iceoryx2._backpressure_handler_wrapper(C_NULL, failing_backpressure) ==
          Iceoryx2.Iceoryx2FFI.iox2_backpressure_action_e_DISCARD_DATA_AND_FAIL
    @test Iceoryx2.last_callback_exception(failing_backpressure) !== nothing
    raw_backpressure = Iceoryx2.BackpressureHandler(
        _ -> Iceoryx2.Iceoryx2FFI.iox2_backpressure_action_e_RETRY,
    )
    @test Iceoryx2._backpressure_handler_wrapper(C_NULL, raw_backpressure) ==
          Iceoryx2.Iceoryx2FFI.iox2_backpressure_action_e_DISCARD_DATA_AND_FAIL
    @test Iceoryx2.last_callback_exception(raw_backpressure) !== nothing

    degradation = Iceoryx2.DegradationHandler() do cause, info
        @test cause == Iceoryx2.DegradationConnectionCorrupted
        @test info isa Iceoryx2.DegradationInfoRef
        return Iceoryx2.DegradationWarn
    end
    @test Iceoryx2._degradation_handler_wrapper(
        Iceoryx2.Iceoryx2FFI.iox2_degradation_cause_e_CONNECTION_CORRUPTED,
        C_NULL,
        degradation,
    ) == Iceoryx2.Iceoryx2FFI.iox2_degradation_action_e_WARN
    @test Iceoryx2.last_callback_exception(degradation) === nothing

    failing_degradation = Iceoryx2.DegradationHandler((_, _) -> error("degradation failure"))
    @test Iceoryx2._degradation_handler_wrapper(
        Iceoryx2.Iceoryx2FFI.iox2_degradation_cause_e_FAILED_TO_ESTABLISH_CONNECTION,
        C_NULL,
        failing_degradation,
    ) == Iceoryx2.Iceoryx2FFI.iox2_degradation_action_e_DEGRADE_AND_FAIL
    @test Iceoryx2.last_callback_exception(failing_degradation) !== nothing
    raw_degradation = Iceoryx2.DegradationHandler(
        (_, _) -> Iceoryx2.Iceoryx2FFI.iox2_degradation_action_e_WARN,
    )
    @test Iceoryx2._degradation_handler_wrapper(
        Iceoryx2.Iceoryx2FFI.iox2_degradation_cause_e_CONNECTION_CORRUPTED,
        C_NULL,
        raw_degradation,
    ) == Iceoryx2.Iceoryx2FFI.iox2_degradation_action_e_DEGRADE_AND_FAIL
    @test Iceoryx2.last_callback_exception(raw_degradation) !== nothing

    allocation_backpressure = Iceoryx2.BackpressureHandler(_callback_backpressure_retry)
    allocation_degradation = Iceoryx2.DegradationHandler(_callback_degradation_warn)
    _callback_backpressure_alloc(allocation_backpressure)
    _callback_degradation_alloc(allocation_degradation)
    @test _callback_backpressure_alloc(allocation_backpressure) == 0
    @test _callback_degradation_alloc(allocation_degradation) == 0

    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, unique_node_name())
    node = Iceoryx2.create(builder, TEST_SERVICE_TYPE)

    try
        pubsub_factory = Iceoryx2.create(
            Iceoryx2.publish_subscribe(Iceoryx2.service_builder(node, unique_service_name()), UInt64),
        )
        pub_builder = Iceoryx2.publisher_builder(pubsub_factory)
        Iceoryx2.backpressure_handler!(pub_builder, _ -> Iceoryx2.BackpressureFollowStrategy)
        Iceoryx2.degradation_handler!(pub_builder, (_, _) -> Iceoryx2.DegradationIgnore)
        pub = Iceoryx2.create(pub_builder)
        sub_builder = Iceoryx2.subscriber_builder(pubsub_factory)
        Iceoryx2.buffer_size!(sub_builder, 1)
        Iceoryx2.degradation_handler!(sub_builder, (_, _) -> Iceoryx2.DegradationWarn)
        sub = Iceoryx2.create(sub_builder)
        try
            @test length(getfield(pub, :callback_keepalive)) == 2
            @test length(getfield(sub, :callback_keepalive)) == 1
        finally
            close(sub)
            close(pub)
            close(pubsub_factory)
        end

        rr_factory = Iceoryx2.create(
            Iceoryx2.request_response(Iceoryx2.service_builder(node, unique_service_name()), UInt64, UInt64),
        )
        client_builder = Iceoryx2.client_builder(rr_factory)
        Iceoryx2.backpressure_handler!(client_builder, _ -> Iceoryx2.BackpressureDiscardData)
        Iceoryx2.request_degradation_handler!(client_builder, (_, _) -> Iceoryx2.DegradationIgnore)
        Iceoryx2.response_degradation_handler!(client_builder, (_, _) -> Iceoryx2.DegradationWarn)
        client = Iceoryx2.create(client_builder)

        server_builder = Iceoryx2.server_builder(rr_factory)
        Iceoryx2.backpressure_handler!(server_builder, _ -> Iceoryx2.BackpressureDiscardDataAndFail)
        Iceoryx2.request_degradation_handler!(server_builder, (_, _) -> Iceoryx2.DegradationIgnore)
        Iceoryx2.response_degradation_handler!(server_builder, (_, _) -> Iceoryx2.DegradationWarn)
        server = Iceoryx2.create(server_builder)
        try
            @test length(getfield(client, :callback_keepalive)) == 3
            @test length(getfield(server, :callback_keepalive)) == 3
        finally
            close(server)
            close(client)
            close(rr_factory)
        end

        client_safe_overflow_count = Ref(0)
        client_safe_overflow_result = _client_backpressure_request_scenario(
            _CountingBackpressureAction(client_safe_overflow_count, Iceoryx2.BackpressureRetry);
            safe_overflow=true,
        )
        @test client_safe_overflow_result.first_server2_value == Some(UInt64(123))
        @test client_safe_overflow_result.second_send_error === nothing
        @test client_safe_overflow_count[] == 0
        @test client_safe_overflow_result.server1_value == Some(UInt64(456))
        @test client_safe_overflow_result.server1_second_value === nothing
        @test client_safe_overflow_result.server2_value == Some(UInt64(456))
        @test client_safe_overflow_result.server2_second_value === nothing

        client_discard_count = Ref(0)
        client_discard_result = _client_backpressure_request_scenario(
            _CountingBackpressureAction(client_discard_count, Iceoryx2.BackpressureDiscardData),
        )
        @test client_discard_result.first_server2_value == Some(UInt64(123))
        @test client_discard_result.second_send_error === nothing
        @test client_discard_count[] == 1
        @test client_discard_result.server1_value == Some(UInt64(123))
        @test client_discard_result.server1_second_value === nothing
        @test client_discard_result.server2_value == Some(UInt64(456))
        @test client_discard_result.server2_second_value === nothing

        client_retry_count = Ref(0)
        client_retry_result = _client_backpressure_request_scenario(
            _RetryThenDiscardBackpressureAction(client_retry_count, UInt64(2)),
        )
        @test client_retry_result.second_send_error === nothing
        @test client_retry_count[] == 2
        @test client_retry_result.server1_value == Some(UInt64(123))
        @test client_retry_result.server2_value == Some(UInt64(456))

        client_timeout_count = Ref(0)
        client_timeout_ns = UInt64(25_000_000)
        client_timeout_result = _client_backpressure_request_scenario(
            _ElapsedThenDiscardBackpressureAction(client_timeout_count, client_timeout_ns),
        )
        @test client_timeout_result.second_send_error === nothing
        @test client_timeout_result.second_send_elapsed_ns >= client_timeout_ns
        @test client_timeout_count[] > 0
        @test client_timeout_result.server1_value == Some(UInt64(123))
        @test client_timeout_result.server2_value == Some(UInt64(456))

        client_fail_count = Ref(0)
        client_fail_result = _client_backpressure_request_scenario(
            _CountingBackpressureAction(client_fail_count, Iceoryx2.BackpressureDiscardDataAndFail),
        )
        @test client_fail_result.second_send_error isa Iceoryx2.RequestSendError
        @test client_fail_result.second_send_error.code == :UNABLE_TO_DELIVER
        @test client_fail_count[] == 1
        @test client_fail_result.server1_value == Some(UInt64(123))
        @test client_fail_result.server2_value == Some(UInt64(456))

        client_follow_count = Ref(0)
        client_follow_result = _client_backpressure_request_scenario(
            _CountingBackpressureAction(client_follow_count, Iceoryx2.BackpressureFollowStrategy);
            backpressure_strategy=:discard_data,
        )
        @test client_follow_result.second_send_error === nothing
        @test client_follow_count[] == 1
        @test client_follow_result.server1_value == Some(UInt64(123))
        @test client_follow_result.server2_value == Some(UInt64(456))

        pub_safe_overflow_count = Ref(0)
        pub_safe_overflow_result = _publisher_backpressure_sample_scenario(
            _CountingBackpressureAction(pub_safe_overflow_count, Iceoryx2.BackpressureRetry);
            safe_overflow=true,
        )
        @test pub_safe_overflow_result.first_recipients == 2
        @test pub_safe_overflow_result.first_sub2_value == Some(UInt64(1))
        @test pub_safe_overflow_result.second_send_error === nothing
        @test pub_safe_overflow_result.second_recipients == 2
        @test pub_safe_overflow_count[] == 0
        @test pub_safe_overflow_result.sub1_value == Some(UInt64(2))
        @test pub_safe_overflow_result.sub1_second_value === nothing
        @test pub_safe_overflow_result.sub2_value == Some(UInt64(2))
        @test pub_safe_overflow_result.sub2_second_value === nothing

        pub_discard_count = Ref(0)
        pub_discard_result = _publisher_backpressure_sample_scenario(
            _CountingBackpressureAction(pub_discard_count, Iceoryx2.BackpressureDiscardData),
        )
        @test pub_discard_result.first_recipients == 2
        @test pub_discard_result.first_sub2_value == Some(UInt64(1))
        @test pub_discard_result.second_send_error === nothing
        @test pub_discard_result.second_recipients == 1
        @test pub_discard_count[] == 1
        @test pub_discard_result.sub1_value == Some(UInt64(1))
        @test pub_discard_result.sub1_second_value === nothing
        @test pub_discard_result.sub2_value == Some(UInt64(2))
        @test pub_discard_result.sub2_second_value === nothing

        pub_retry_count = Ref(0)
        pub_retry_result = _publisher_backpressure_sample_scenario(
            _RetryThenDiscardBackpressureAction(pub_retry_count, UInt64(2)),
        )
        @test pub_retry_result.second_send_error === nothing
        @test pub_retry_result.second_recipients == 1
        @test pub_retry_count[] == 2
        @test pub_retry_result.sub1_value == Some(UInt64(1))
        @test pub_retry_result.sub2_value == Some(UInt64(2))

        pub_fail_count = Ref(0)
        pub_fail_result = _publisher_backpressure_sample_scenario(
            _CountingBackpressureAction(pub_fail_count, Iceoryx2.BackpressureDiscardDataAndFail),
        )
        @test pub_fail_result.second_send_error isa Iceoryx2.SendError
        @test pub_fail_result.second_send_error.code == :UNABLE_TO_DELIVER
        @test pub_fail_count[] == 1
        @test pub_fail_result.sub1_value == Some(UInt64(1))
        @test pub_fail_result.sub2_value == Some(UInt64(2))

        pub_follow_count = Ref(0)
        pub_follow_result = _publisher_backpressure_sample_scenario(
            _CountingBackpressureAction(pub_follow_count, Iceoryx2.BackpressureFollowStrategy);
            backpressure_strategy=:discard_data,
        )
        @test pub_follow_result.second_send_error === nothing
        @test pub_follow_result.second_recipients == 1
        @test pub_follow_count[] == 1
        @test pub_follow_result.sub1_value == Some(UInt64(1))
        @test pub_follow_result.sub2_value == Some(UInt64(2))

        safe_overflow_count = Ref(0)
        safe_overflow_result = _server_backpressure_response_scenario(
            _CountingBackpressureAction(safe_overflow_count, Iceoryx2.BackpressureRetry);
            safe_overflow=true,
        )
        @test safe_overflow_result.second_send_error === nothing
        @test safe_overflow_count[] == 0
        @test safe_overflow_result.received_first
        @test safe_overflow_result.first_value == UInt64(456)
        @test !safe_overflow_result.received_second

        discard_count = Ref(0)
        discard_result = _server_backpressure_response_scenario(
            _CountingBackpressureAction(discard_count, Iceoryx2.BackpressureDiscardData),
        )
        @test discard_result.second_send_error === nothing
        @test discard_count[] == 1
        @test discard_result.received_first
        @test discard_result.first_value == UInt64(123)
        @test !discard_result.received_second

        retry_count = Ref(0)
        retry_result = _server_backpressure_response_scenario(
            _RetryThenDiscardBackpressureAction(retry_count, UInt64(2)),
        )
        @test retry_result.second_send_error === nothing
        @test retry_count[] == 2
        @test retry_result.received_first
        @test retry_result.first_value == UInt64(123)
        @test !retry_result.received_second

        timeout_count = Ref(0)
        timeout_ns = UInt64(25_000_000)
        timeout_result = _server_backpressure_response_scenario(
            _ElapsedThenDiscardBackpressureAction(timeout_count, timeout_ns),
        )
        @test timeout_result.second_send_error === nothing
        @test timeout_result.second_send_elapsed_ns >= timeout_ns
        @test timeout_count[] > 0
        @test timeout_result.received_first
        @test timeout_result.first_value == UInt64(123)
        @test !timeout_result.received_second

        fail_count = Ref(0)
        fail_result = _server_backpressure_response_scenario(
            _CountingBackpressureAction(fail_count, Iceoryx2.BackpressureDiscardDataAndFail),
        )
        @test fail_result.second_send_error isa Iceoryx2.SendError
        @test fail_result.second_send_error.code == :UNABLE_TO_DELIVER
        @test fail_count[] == 1
        @test fail_result.received_first
        @test fail_result.first_value == UInt64(123)
        @test !fail_result.received_second

        follow_count = Ref(0)
        follow_result = _server_backpressure_response_scenario(
            _CountingBackpressureAction(follow_count, Iceoryx2.BackpressureFollowStrategy);
            backpressure_strategy=:discard_data,
        )
        @test follow_result.second_send_error === nothing
        @test follow_count[] == 1
        @test follow_result.received_first
        @test follow_result.first_value == UInt64(123)
        @test !follow_result.received_second
    finally
        close(node)
    end
end
