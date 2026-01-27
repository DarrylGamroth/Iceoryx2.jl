#!/usr/bin/env julia

using Random
using Base.Threads
using Iceoryx2

include(joinpath(@__DIR__, "bench_utils.jl"))
using .BenchUtils

const DEFAULT_ITERATIONS = 10_000_000

function usage()
    println(
        """
Iceoryx2 request-response benchmark

Usage:
  request_response.jl [options]

Options:
  -n, --iterations N   Number of ping-pong iterations (default: $DEFAULT_ITERATIONS)
      --bench-ipc      Run IPC service benchmark
      --bench-local    Run local service benchmark
      --bench-all      Run both IPC and local benchmarks
  -d, --debug          Enable trace logging
  -h, --help           Show this help message
""",
    )
end

function unique_suffix()
    return string(rand(UInt))
end

function build_rr_factory(node::Iceoryx2.Node, name::AbstractString)
    builder = Iceoryx2.request_response(Iceoryx2.service_builder(node, name))
    Iceoryx2.request_payload_type!(builder, UInt64)
    Iceoryx2.response_payload_type!(builder, UInt64)
    return Iceoryx2.open_or_create(builder)
end

function wait_for_request(server::Iceoryx2.Server{UInt64, UInt64})
    while true
        req = Iceoryx2.receive(server)
        req === nothing && continue
        return req
    end
end

function wait_for_response(pending::Iceoryx2.PendingResponse{UInt64})
    while true
        resp = Iceoryx2.receive(pending)
        resp === nothing && continue
        Iceoryx2.close(resp)
        return nothing
    end
end

function run_request_benchmark(iterations::Int, service_type::Symbol)
    suffix = unique_suffix()
    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, "iox2_julia_bench_rr_req_" * suffix)
    node = Iceoryx2.create(node_builder; service_type)

    factory_a2b = build_rr_factory(node, "a2b_" * suffix)
    factory_b2a = build_rr_factory(node, "b2a_" * suffix)

    startup = SpinBarrier(3)
    start_benchmark = SpinBarrier(3)

    t1 = Threads.@spawn begin
        client_a2b = Iceoryx2.create(Iceoryx2.client_builder(factory_a2b, UInt64, UInt64))
        server_b2a = Iceoryx2.create(Iceoryx2.server_builder(factory_b2a, UInt64, UInt64))

        wait_barrier(startup)
        wait_barrier(start_benchmark)

        for _ in 1:iterations
            request = Iceoryx2.loan_request(client_a2b, 1)
            pending = Iceoryx2.send!(request)
            Iceoryx2.close(pending)

            active = wait_for_request(server_b2a)
            Iceoryx2.close(active)
        end

        Iceoryx2.close(server_b2a)
        Iceoryx2.close(client_a2b)
        return nothing
    end

    t2 = Threads.@spawn begin
        client_b2a = Iceoryx2.create(Iceoryx2.client_builder(factory_b2a, UInt64, UInt64))
        server_a2b = Iceoryx2.create(Iceoryx2.server_builder(factory_a2b, UInt64, UInt64))

        wait_barrier(startup)
        wait_barrier(start_benchmark)

        for _ in 1:iterations
            request = Iceoryx2.loan_request(client_b2a, 1)
            pending = Iceoryx2.send!(request)
            Iceoryx2.close(pending)

            active = wait_for_request(server_a2b)
            Iceoryx2.close(active)
        end

        Iceoryx2.close(server_a2b)
        Iceoryx2.close(client_b2a)
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
        "request_response::request::$(service_type) iterations=$(iterations) " *
        "elapsed_s=$(elapsed_ns / 1.0e9) latency_ns=$(latency_ns)",
    )

    Iceoryx2.close(factory_a2b)
    Iceoryx2.close(factory_b2a)
    Iceoryx2.close(node)
    return nothing
end

function run_response_stream_benchmark(iterations::Int, service_type::Symbol)
    suffix = unique_suffix()
    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, "iox2_julia_bench_rr_resp_" * suffix)
    node = Iceoryx2.create(node_builder; service_type)

    factory_a2b = build_rr_factory(node, "a2b_" * suffix)
    factory_b2a = build_rr_factory(node, "b2a_" * suffix)

    startup = SpinBarrier(3)
    start_benchmark = SpinBarrier(3)

    t1 = Threads.@spawn begin
        client_a2b = Iceoryx2.create(Iceoryx2.client_builder(factory_a2b, UInt64, UInt64))
        server_b2a = Iceoryx2.create(Iceoryx2.server_builder(factory_b2a, UInt64, UInt64))

        wait_barrier(startup)
        pending = Iceoryx2.send_copy(client_a2b, UInt64[0])
        active = wait_for_request(server_b2a)
        wait_barrier(start_benchmark)

        for _ in 1:iterations
            response = Iceoryx2.loan_response(active, 1)
            Iceoryx2.send!(response)
            wait_for_response(pending)
        end

        Iceoryx2.close(active)
        Iceoryx2.close(pending)
        Iceoryx2.close(server_b2a)
        Iceoryx2.close(client_a2b)
        return nothing
    end

    t2 = Threads.@spawn begin
        client_b2a = Iceoryx2.create(Iceoryx2.client_builder(factory_b2a, UInt64, UInt64))
        server_a2b = Iceoryx2.create(Iceoryx2.server_builder(factory_a2b, UInt64, UInt64))

        wait_barrier(startup)
        pending = Iceoryx2.send_copy(client_b2a, UInt64[0])
        active = wait_for_request(server_a2b)
        wait_barrier(start_benchmark)

        for _ in 1:iterations
            wait_for_response(pending)
            response = Iceoryx2.loan_response(active, 1)
            Iceoryx2.send!(response)
        end

        Iceoryx2.close(active)
        Iceoryx2.close(pending)
        Iceoryx2.close(server_a2b)
        Iceoryx2.close(client_b2a)
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
        "request_response::response_stream::$(service_type) iterations=$(iterations) " *
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
    debug = has_flag(args, ["-d", "--debug"])

    iterations > 0 || error("iterations must be positive")

    Threads.nthreads() >= 2 || error("set JULIA_NUM_THREADS>=2 for this benchmark")

    if debug
        Iceoryx2.set_log_level(:trace)
    else
        Iceoryx2.set_log_level(:error)
    end

    service_types = parse_service_types(args; default_ipc = false)
    if isempty(service_types)
        service_types = [:ipc, :local]
    end

    for service_type in service_types
        run_request_benchmark(iterations, service_type)
        run_response_stream_benchmark(iterations, service_type)
    end

    return nothing
end

main(ARGS)
