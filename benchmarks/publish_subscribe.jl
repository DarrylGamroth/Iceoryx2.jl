#!/usr/bin/env julia

using Random
using Base.Threads
using Iceoryx2

include(joinpath(@__DIR__, "bench_utils.jl"))
using .BenchUtils

const DEFAULT_ITERATIONS = 10_000_000
const DEFAULT_PAYLOAD_SIZE = 8192

function usage()
    println(
        """
Iceoryx2 publish-subscribe benchmark

Usage:
  publish_subscribe.jl [options]

Options:
  -n, --iterations N                     Number of ping-pong iterations (default: $DEFAULT_ITERATIONS)
      --bench-all                        Run IPC and local benchmarks
      --bench-ipc                        Run IPC service benchmark
      --bench-local                      Run local service benchmark
  -d, --debug-mode                       Enable trace logging
      --cpu-core-participant-1 N         CPU core for participant 1 (ignored in Julia)
      --cpu-core-participant-2 N         CPU core for participant 2 (ignored in Julia)
  -s, --payload-size BYTES               Payload size in bytes (default: $DEFAULT_PAYLOAD_SIZE)
      --send-copy                        Initialize payload before sending
      --number-of-additional-publishers N  Additional publishers per service (default: 0)
      --number-of-additional-subscribers N Additional subscribers per service (default: 0)
  -h, --help                             Show this help message
""",
    )
end

function build_pubsub_factory(node::Iceoryx2.Node, name::AbstractString, additional_publishers::Int, additional_subscribers::Int)
    builder = Iceoryx2.pub_sub(Iceoryx2.service_builder(node, name))
    Iceoryx2.payload_type!(builder, UInt8; variant = :dynamic)
    Iceoryx2.max_publishers!(builder, 1 + additional_publishers)
    Iceoryx2.max_subscribers!(builder, 1 + additional_subscribers)
    Iceoryx2.history_size!(builder, 0)
    Iceoryx2.subscriber_max_buffer_size!(builder, 1)
    Iceoryx2.enable_safe_overflow!(builder, true)
    return Iceoryx2.open_or_create(builder)
end

function wait_for_sample(sub::Iceoryx2.Subscriber{UInt8})
    while true
        sample = Iceoryx2.receive(sub)
        sample === nothing && continue
        Iceoryx2.close(sample)
        return nothing
    end
end

function fill_sample!(sample::Iceoryx2.SampleMut{UInt8})
    slice = Iceoryx2.payload_mut(sample)
    for idx in 1:slice.len
        unsafe_store!(slice.ptr, UInt8(0), idx)
    end
    return sample
end

function perform_benchmark(
    iterations::Int,
    payload_size::Int,
    send_copy::Bool,
    service_type::Symbol,
    additional_publishers::Int,
    additional_subscribers::Int,
)
    node_builder = Iceoryx2.NodeBuilder()
    node = Iceoryx2.create(node_builder; service_type)

    factory_a2b = build_pubsub_factory(node, "a2b", additional_publishers, additional_subscribers)
    factory_b2a = build_pubsub_factory(node, "b2a", additional_publishers, additional_subscribers)

    extra_publishers = Iceoryx2.Publisher{UInt8}[]
    extra_subscribers = Iceoryx2.Subscriber{UInt8}[]

    for _ in 1:additional_publishers
        push!(extra_publishers, Iceoryx2.create(Iceoryx2.publisher_builder(factory_a2b, UInt8)))
        push!(extra_publishers, Iceoryx2.create(Iceoryx2.publisher_builder(factory_b2a, UInt8)))
    end

    for _ in 1:additional_subscribers
        push!(extra_subscribers, Iceoryx2.create(Iceoryx2.subscriber_builder(factory_a2b, UInt8)))
        push!(extra_subscribers, Iceoryx2.create(Iceoryx2.subscriber_builder(factory_b2a, UInt8)))
    end

    startup = SpinBarrier(3)
    start_benchmark = SpinBarrier(3)

    t1 = Threads.@spawn begin
        pub_builder_a2b = Iceoryx2.publisher_builder(factory_a2b, UInt8)
        Iceoryx2.initial_max_slice_len!(pub_builder_a2b, payload_size)
        sender_a2b = Iceoryx2.create(pub_builder_a2b)
        receiver_b2a = Iceoryx2.create(Iceoryx2.subscriber_builder(factory_b2a, UInt8))

        wait_barrier(startup)
        wait_barrier(start_benchmark)

        sample = Iceoryx2.loan_slice(sender_a2b, payload_size)
        send_copy && fill_sample!(sample)

        for _ in 1:iterations
            Iceoryx2.send!(sample)
            sample = Iceoryx2.loan_slice(sender_a2b, payload_size)
            wait_for_sample(receiver_b2a)
        end

        Iceoryx2.close(sample)
        Iceoryx2.close(receiver_b2a)
        Iceoryx2.close(sender_a2b)
        return nothing
    end

    t2 = Threads.@spawn begin
        pub_builder_b2a = Iceoryx2.publisher_builder(factory_b2a, UInt8)
        Iceoryx2.initial_max_slice_len!(pub_builder_b2a, payload_size)
        sender_b2a = Iceoryx2.create(pub_builder_b2a)
        receiver_a2b = Iceoryx2.create(Iceoryx2.subscriber_builder(factory_a2b, UInt8))

        wait_barrier(startup)
        wait_barrier(start_benchmark)

        for _ in 1:iterations
            sample = Iceoryx2.loan_slice(sender_b2a, payload_size)
            send_copy && fill_sample!(sample)
            wait_for_sample(receiver_a2b)
            Iceoryx2.send!(sample)
        end

        Iceoryx2.close(receiver_a2b)
        Iceoryx2.close(sender_b2a)
        return nothing
    end

    wait_barrier(startup)
    start_time = time_ns()
    wait_barrier(start_benchmark)

    fetch(t1)
    fetch(t2)

    elapsed_ns = time_ns() - start_time
    latency_ns = elapsed_ns ÷ (iterations * 2)

    println(
        "$(service_type_label(service_type)) ::: Iterations: $(iterations), Time: $(elapsed_ns / 1.0e9) s, " *
        "Latency: $(latency_ns) ns, Sample Size: $(payload_size)",
    )

    Iceoryx2.close(factory_a2b)
    Iceoryx2.close(factory_b2a)
    Iceoryx2.close(node)
    return nothing
end

function main(args::Vector{String})
    if has_flag(args, ["-h", "--help"])
        usage()
        return
    end

    iterations = parse_int(args, ["-n", "--iterations"], DEFAULT_ITERATIONS)
    payload_size = parse_int(args, ["-s", "--payload-size"], DEFAULT_PAYLOAD_SIZE)
    send_copy = has_flag(args, ["--send-copy"])
    debug = has_flag(args, ["-d", "--debug-mode"])
    additional_publishers = parse_int(args, ["--number-of-additional-publishers"], 0)
    additional_subscribers = parse_int(args, ["--number-of-additional-subscribers"], 0)

    iterations > 0 || error("iterations must be positive")
    payload_size > 0 || error("payload size must be positive")
    additional_publishers >= 0 || error("additional publishers must be non-negative")
    additional_subscribers >= 0 || error("additional subscribers must be non-negative")

    Threads.nthreads() >= 2 || error("set JULIA_NUM_THREADS>=2 for this benchmark")

    if debug
        Iceoryx2.set_log_level(:trace)
    else
        Iceoryx2.set_log_level(:error)
    end

    service_types = parse_service_types(args; default_ipc = false)
    if isempty(service_types)
        println("Please use either '--bench-all' or select a specific benchmark. See --help for details.")
        return nothing
    end

    for service_type in service_types
        perform_benchmark(
            iterations,
            payload_size,
            send_copy,
            service_type,
            additional_publishers,
            additional_subscribers,
        )
    end

    return nothing
end

main(ARGS)
