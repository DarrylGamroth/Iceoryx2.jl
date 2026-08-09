function _progressive_receive_with_retry!(
        subscriber::Iceoryx2.ProgressiveSubscriber{S, UH},
        sample::Iceoryx2.ProgressiveSample{S, UH}
) where {S, UH}
    for _ in 1:1000
        Iceoryx2.receive!(subscriber, sample) && return true
        yield()
    end
    return false
end

_progressive_loan_alloc(
    publisher::Iceoryx2.ProgressivePublisher{S, UH},
    loan::Iceoryx2.ProgressiveSampleMutUninit{S, UH},
    capacity::Int
) where {S, UH} = @allocated Iceoryx2.loan_slice_uninit!(publisher, loan, capacity)

_progressive_private_payload_alloc(
    loan::Iceoryx2.ProgressiveSampleMutUninit
) = @allocated Iceoryx2.payload_mut(loan)

_progressive_announce_alloc(
    loan::Iceoryx2.ProgressiveSampleMutUninit{S, UH},
    writer::Iceoryx2.ProgressiveSampleMut{S, UH}
) where {S, UH} = @allocated Iceoryx2.announce!(loan, writer)

_progressive_write_alloc(
    writer::Iceoryx2.ProgressiveSampleMut,
    bytes::Vector{UInt8}
) = @allocated Iceoryx2.write_from_slice!(writer, bytes)

_progressive_committed_len_alloc(
    writer::Iceoryx2.ProgressiveSampleMut
) = @allocated Iceoryx2.committed_len(writer)

_progressive_commit_until_alloc(
    writer::Iceoryx2.ProgressiveSampleMut,
    len::Int
) = @allocated Iceoryx2.unsafe_commit_until!(writer, len)

_progressive_has_samples_alloc(
    subscriber::Iceoryx2.ProgressiveSubscriber
) = @allocated Iceoryx2.has_samples(subscriber)

_progressive_receive_alloc(
    subscriber::Iceoryx2.ProgressiveSubscriber{S, UH},
    sample::Iceoryx2.ProgressiveSample{S, UH}
) where {S, UH} = @allocated _progressive_receive_with_retry!(subscriber, sample)

_progressive_payload_alloc(
    sample::Iceoryx2.ProgressiveSample
) = @allocated Iceoryx2.payload(sample)

_progressive_state_alloc(
    sample::Iceoryx2.ProgressiveSample
) = @allocated Iceoryx2.state(sample)

_progressive_snapshot_alloc(
    sample::Iceoryx2.ProgressiveSample
) = @allocated Iceoryx2.snapshot(sample)

_progressive_liveness_state_alloc(
    sample::Iceoryx2.ProgressiveSample
) = @allocated Iceoryx2.state_with_publisher_liveness(sample)

_progressive_liveness_snapshot_alloc(
    sample::Iceoryx2.ProgressiveSample
) = @allocated Iceoryx2.snapshot_with_publisher_liveness(sample)

@testset "ProgressivePubSub" begin
    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, unique_node_name())
    node = Iceoryx2.create(node_builder, TEST_SERVICE_TYPE)

    service_builder = Iceoryx2.progressive_publish_subscribe(
        Iceoryx2.service_builder(node, unique_service_name()))
    service_builder = Iceoryx2.user_header(service_builder, UInt64)
    Iceoryx2.max_nodes!(service_builder, 2)
    Iceoryx2.max_subscribers!(service_builder, 2)
    Iceoryx2.subscriber_max_buffer_size!(service_builder, 2)
    Iceoryx2.subscriber_max_borrowed_samples!(service_builder, 2)
    Iceoryx2.payload_alignment!(service_builder, 4096)
    factory = Iceoryx2.open_or_create(service_builder)

    publisher_builder = Iceoryx2.publisher_builder(factory)
    Iceoryx2.initial_max_slice_len!(publisher_builder, 32)
    Iceoryx2.max_loaned_samples!(publisher_builder, 2)
    Iceoryx2.allocation_strategy!(publisher_builder, :static)
    Iceoryx2.backpressure_strategy!(publisher_builder, :discard_data)
    Iceoryx2.samples_preallocation_override!(publisher_builder, identity)
    Iceoryx2.name!(publisher_builder, unique_name("progressive_publisher"))

    subscriber_builder = Iceoryx2.subscriber_builder(factory)
    Iceoryx2.buffer_size!(subscriber_builder, 2)
    Iceoryx2.name!(subscriber_builder, unique_name("progressive_subscriber"))

    publisher = Iceoryx2.create(publisher_builder)
    subscriber = Iceoryx2.create(subscriber_builder)
    loan = Iceoryx2.ProgressiveSampleMutUninit(publisher)
    writer = Iceoryx2.ProgressiveSampleMut(publisher)
    sample = Iceoryx2.ProgressiveSample(subscriber)

    try
        @test !Iceoryx2.has_samples(subscriber)
        @test !Iceoryx2.receive!(subscriber, sample)

        Iceoryx2.loan_slice_uninit!(publisher, loan, 32)
        private_payload = Iceoryx2.payload_mut(loan)
        @test length(private_payload) == 32
        @test UInt(pointer(private_payload)) % 4096 == 0
        private_payload[1:4] .= UInt8[1, 2, 3, 4]
        Iceoryx2.user_header_mut(loan)[1] = UInt64(0xfeed_beef)

        Iceoryx2.announce!(loan, writer)
        Iceoryx2.unsafe_commit_until!(writer, 4)
        @test Iceoryx2.payload_capacity(writer) == 32
        @test Iceoryx2.committed_len(writer) == 4
        @test Iceoryx2.user_header(writer)[1] == UInt64(0xfeed_beef)
        @test Iceoryx2.has_samples(subscriber)
        @test _progressive_receive_with_retry!(subscriber, sample)

        @test collect(Iceoryx2.payload(sample)) == UInt8[1, 2, 3, 4]
        @test Iceoryx2.payload_capacity(sample) == 32
        @test Iceoryx2.user_header(sample)[1] == UInt64(0xfeed_beef)
        @test Iceoryx2.state(sample) == Iceoryx2.ProgressiveSampleStateActive
        @test Iceoryx2.state_with_publisher_liveness(sample) ==
              Iceoryx2.ProgressiveSampleStateActive
        progress = Iceoryx2.snapshot(sample)
        @test Iceoryx2.committed_len(progress) == 4
        @test Iceoryx2.state(progress) == Iceoryx2.ProgressiveSampleStateActive
        live_progress = Iceoryx2.snapshot_with_publisher_liveness(sample)
        @test Iceoryx2.committed_len(live_progress) == 4
        @test Iceoryx2.state(live_progress) == Iceoryx2.ProgressiveSampleStateActive

        err = try
            Iceoryx2.unsafe_commit_until!(writer, 3)
            nothing
        catch ex
            ex
        end
        @test err isa Iceoryx2.ProgressiveWriteError
        @test err.code == :COMMITTED_LENGTH_REGRESSED

        retained_payload = Iceoryx2.unsafe_payload_mut(writer)
        retained_payload[5] = UInt8(5)
        retained_payload[6] = UInt8(6)
        Iceoryx2.unsafe_commit_until!(writer, 6)
        @test collect(Iceoryx2.payload(sample)) == UInt8[1, 2, 3, 4, 5, 6]

        Iceoryx2.write_from_slice!(writer, UInt8[7, 8])
        @test collect(Iceoryx2.payload(sample)) == UInt8[1, 2, 3, 4, 5, 6, 7, 8]
        Iceoryx2.complete!(writer)
        @test Iceoryx2.state(sample) == Iceoryx2.ProgressiveSampleStateComplete
        completed = Iceoryx2.snapshot(sample)
        @test Iceoryx2.committed_len(completed) == 8
        @test Iceoryx2.state(completed) == Iceoryx2.ProgressiveSampleStateComplete
        close(sample)

        for explicit_abort in (true, false)
            Iceoryx2.loan_slice_uninit!(publisher, loan, 8)
            Iceoryx2.announce!(loan, writer)
            @test _progressive_receive_with_retry!(subscriber, sample)
            explicit_abort ? Iceoryx2.abort!(writer) : close(writer)
            @test Iceoryx2.state(sample) == Iceoryx2.ProgressiveSampleStateAborted
            close(sample)
        end

        allocation_bytes = UInt8[9, 10]
        Iceoryx2.loan_slice_uninit!(publisher, loan, 16)
        Iceoryx2.payload_mut(loan)
        Iceoryx2.announce!(loan, writer)
        Iceoryx2.write_from_slice!(writer, allocation_bytes)
        @test _progressive_receive_with_retry!(subscriber, sample)

        Iceoryx2.committed_len(writer)
        Iceoryx2.payload(sample)
        Iceoryx2.state(sample)
        Iceoryx2.snapshot(sample)
        Iceoryx2.state_with_publisher_liveness(sample)
        Iceoryx2.snapshot_with_publisher_liveness(sample)
        Iceoryx2.has_samples(subscriber)

        @test _progressive_committed_len_alloc(writer) == 0
        @test _progressive_payload_alloc(sample) == 0
        @test _progressive_state_alloc(sample) == 0
        @test _progressive_snapshot_alloc(sample) == 0
        @test _progressive_liveness_state_alloc(sample) == 0
        @test _progressive_liveness_snapshot_alloc(sample) == 0
        @test _progressive_has_samples_alloc(subscriber) == 0
        @test _progressive_write_alloc(writer, allocation_bytes) == 0
        retained_payload = Iceoryx2.unsafe_payload_mut(writer)
        retained_payload[3] = UInt8(11)
        retained_payload[4] = UInt8(12)
        @test _progressive_commit_until_alloc(writer, 4) == 0

        Iceoryx2.complete!(writer)
        close(sample)

        @test _progressive_loan_alloc(publisher, loan, 16) == 0
        Iceoryx2.payload_mut(loan)
        @test _progressive_private_payload_alloc(loan) == 0
        @test _progressive_announce_alloc(loan, writer) == 0
        @test _progressive_receive_alloc(subscriber, sample) == 0
        Iceoryx2.abort!(writer)
        close(sample)
    finally
        close(sample)
        close(writer)
        close(loan)
        close(subscriber)
        close(publisher)
        close(factory)
        close(node)
    end
end
