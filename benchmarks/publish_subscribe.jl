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
  -n, --iterations N         Number of ping-pong iterations (default: $DEFAULT_ITERATIONS)
  -w, --warmup N             Warmup iterations (default: iterations ÷ 10, capped at 10_000)
  -s, --payload-size BYTES   Payload size in bytes (default: $DEFAULT_PAYLOAD_SIZE)
      --send-copy            Use send_copy instead of loaned samples
      --bench-ipc            Run IPC service benchmark
      --bench-local          Run local service benchmark
      --bench-all            Run both IPC and local benchmarks
  -d, --debug                Enable trace logging
  -h, --help                 Show this help message
""",
    )
end

function unique_suffix()
    return string(rand(UInt))
end

function build_pubsub_factory(node::Iceoryx2.Node, name::AbstractString)
    builder = Iceoryx2.pub_sub(Iceoryx2.service_builder(node, name))
    Iceoryx2.payload_type!(builder, UInt8; variant=:dynamic)
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

function send_sample(pub::Iceoryx2.Publisher{UInt8}, payload_size::Int, payload::Union{Vector{UInt8}, Nothing})
    if payload === nothing
        sample = Iceoryx2.loan_slice(pub, payload_size)
        Iceoryx2.send!(sample)
        return nothing
    end
    Iceoryx2.send_copy(pub, payload)
    return nothing
end

function sync_send_recv(
    pub::Iceoryx2.Publisher{UInt8},
    sub::Iceoryx2.Subscriber{UInt8},
    payload_size::Int,
    payload::Union{Vector{UInt8}, Nothing};
    max_attempts::Int = 1_000_000,
)
    for _ in 1:max_attempts
        send_sample(pub, payload_size, payload)
        sample = Iceoryx2.receive(sub)
        if sample !== nothing
            Iceoryx2.close(sample)
            return true
        end
        Base.Threads.yield()
    end
    return false
end

function sync_recv_send(
    pub::Iceoryx2.Publisher{UInt8},
    sub::Iceoryx2.Subscriber{UInt8},
    payload_size::Int,
    payload::Union{Vector{UInt8}, Nothing};
    max_attempts::Int = 1_000_000,
)
    for _ in 1:max_attempts
        sample = Iceoryx2.receive(sub)
        if sample !== nothing
            Iceoryx2.close(sample)
            send_sample(pub, payload_size, payload)
            return true
        end
        Base.Threads.yield()
    end
    return false
end

function run_benchmark(iterations::Int, warmup::Int, payload_size::Int, service_type::Symbol; send_copy::Bool)
    suffix = unique_suffix()
    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, "iox2_julia_bench_pubsub_" * suffix)
    node = Iceoryx2.create(node_builder; service_type)

    factory_a2b = build_pubsub_factory(node, "a2b_" * suffix)
    factory_b2a = build_pubsub_factory(node, "b2a_" * suffix)

    startup = SpinBarrier(3)
    sync_barrier = SpinBarrier(3)
    warmup_barrier = SpinBarrier(3)
    start_benchmark = SpinBarrier(3)

    t1 = Threads.@spawn begin
        pub_builder_a2b = Iceoryx2.publisher_builder(factory_a2b, UInt8)
        Iceoryx2.initial_max_slice_len!(pub_builder_a2b, payload_size)
        pub_a2b = Iceoryx2.create(pub_builder_a2b)
        sub_b2a = Iceoryx2.create(Iceoryx2.subscriber_builder(factory_b2a, UInt8))
        payload = send_copy ? fill(UInt8(0), payload_size) : nothing

        wait_barrier(startup)
        wait_barrier(sync_barrier)
        sync_send_recv(pub_a2b, sub_b2a, payload_size, payload) || error("pubsub sync failed")
        wait_barrier(warmup_barrier)

        for _ in 1:warmup
            send_sample(pub_a2b, payload_size, payload)
            wait_for_sample(sub_b2a)
        end

        wait_barrier(start_benchmark)

        for _ in 1:iterations
            send_sample(pub_a2b, payload_size, payload)
            wait_for_sample(sub_b2a)
        end

        Iceoryx2.close(sub_b2a)
        Iceoryx2.close(pub_a2b)
        return nothing
    end

    t2 = Threads.@spawn begin
        pub_builder_b2a = Iceoryx2.publisher_builder(factory_b2a, UInt8)
        Iceoryx2.initial_max_slice_len!(pub_builder_b2a, payload_size)
        pub_b2a = Iceoryx2.create(pub_builder_b2a)
        sub_a2b = Iceoryx2.create(Iceoryx2.subscriber_builder(factory_a2b, UInt8))
        payload = send_copy ? fill(UInt8(0), payload_size) : nothing

        wait_barrier(startup)
        wait_barrier(sync_barrier)
        sync_recv_send(pub_b2a, sub_a2b, payload_size, payload) || error("pubsub sync failed")
        wait_barrier(warmup_barrier)

        for _ in 1:warmup
            wait_for_sample(sub_a2b)
            send_sample(pub_b2a, payload_size, payload)
        end

        wait_barrier(start_benchmark)

        for _ in 1:iterations
            wait_for_sample(sub_a2b)
            send_sample(pub_b2a, payload_size, payload)
        end

        Iceoryx2.close(sub_a2b)
        Iceoryx2.close(pub_b2a)
        return nothing
    end

    wait_barrier(startup)
    wait_barrier(sync_barrier)
    wait_barrier(warmup_barrier)
    wait_barrier(start_benchmark)
    start_time = time_ns()

    fetch(t1)
    fetch(t2)

    elapsed_ns = time_ns() - start_time
    latency_ns = elapsed_ns / (iterations * 2)

    println(
        "publish_subscribe::$(service_type) iterations=$(iterations) warmup=$(warmup) " *
        "payload_bytes=$(payload_size) send_copy=$(send_copy) " *
        "elapsed_s=$(elapsed_ns / 1.0e9) latency_ns=$(latency_ns)",
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
    warmup = parse_int(args, ["-w", "--warmup"], default_warmup(iterations))
    payload_size = parse_int(args, ["-s", "--payload-size"], DEFAULT_PAYLOAD_SIZE)
    send_copy = has_flag(args, ["--send-copy"])
    debug = has_flag(args, ["-d", "--debug"])

    iterations > 0 || error("iterations must be positive")
    warmup >= 0 || error("warmup must be non-negative")
    payload_size > 0 || error("payload size must be positive")

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
        run_benchmark(iterations, warmup, payload_size, service_type; send_copy)
    end

    return nothing
end

main(ARGS)
