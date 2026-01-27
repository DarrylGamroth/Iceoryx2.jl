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
    Iceoryx2.payload_type!(builder, UInt8)
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

function run_benchmark(iterations::Int, payload_size::Int, service_type::Symbol; send_copy::Bool)
    suffix = unique_suffix()
    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, "iox2_julia_bench_pubsub_" * suffix)
    node = Iceoryx2.create(node_builder; service_type)

    factory_a2b = build_pubsub_factory(node, "a2b_" * suffix)
    factory_b2a = build_pubsub_factory(node, "b2a_" * suffix)

    startup = SpinBarrier(3)
    start_benchmark = SpinBarrier(3)

    t1 = Threads.@spawn begin
        pub_a2b = Iceoryx2.create(Iceoryx2.publisher_builder(factory_a2b, UInt8))
        sub_b2a = Iceoryx2.create(Iceoryx2.subscriber_builder(factory_b2a, UInt8))
        payload = send_copy ? fill(UInt8(0), payload_size) : nothing

        wait_barrier(startup)
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
        pub_b2a = Iceoryx2.create(Iceoryx2.publisher_builder(factory_b2a, UInt8))
        sub_a2b = Iceoryx2.create(Iceoryx2.subscriber_builder(factory_a2b, UInt8))
        payload = send_copy ? fill(UInt8(0), payload_size) : nothing

        wait_barrier(startup)
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
    start_time = time_ns()
    wait_barrier(start_benchmark)

    fetch(t1)
    fetch(t2)

    elapsed_ns = time_ns() - start_time
    latency_ns = elapsed_ns / (iterations * 2)

    println(
        "publish_subscribe::$(service_type) iterations=$(iterations) " *
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
    payload_size = parse_int(args, ["-s", "--payload-size"], DEFAULT_PAYLOAD_SIZE)
    send_copy = has_flag(args, ["--send-copy"])
    debug = has_flag(args, ["-d", "--debug"])

    iterations > 0 || error("iterations must be positive")
    payload_size > 0 || error("payload size must be positive")

    Threads.nthreads() >= 2 || error("set JULIA_NUM_THREADS>=2 for this benchmark")

    if debug
        Iceoryx2.set_log_level(:trace)
    else
        Iceoryx2.set_log_level(:error)
    end

    service_types = parse_service_types(args; default_ipc = false)
    if isempty(service_types)
        println(\"Please use either '--bench-all' or select a specific benchmark. See --help for details.\")
        return nothing
    end

    for service_type in service_types
        run_benchmark(iterations, payload_size, service_type; send_copy)
    end

    return nothing
end

main(ARGS)
