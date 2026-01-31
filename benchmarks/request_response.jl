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
  -n, --iterations N                     Number of ping-pong iterations (default: $DEFAULT_ITERATIONS)
  -d, --debug-mode                       Enable trace logging
      --cpu-core-participant-1 N         CPU core for participant 1 (ignored in Julia)
      --cpu-core-participant-2 N         CPU core for participant 2 (ignored in Julia)
      --number-of-additional-servers N   Additional servers per service (default: 0)
      --number-of-additional-clients N   Additional clients per service (default: 0)
  -h, --help                             Show this help message
""",
    )
end

function build_rr_factory(node::Iceoryx2.Node, name::AbstractString, additional_servers::Int, additional_clients::Int)
    builder = Iceoryx2.request_response(Iceoryx2.service_builder(node, name), UInt64, UInt64)
    Iceoryx2.max_servers!(builder, 1 + additional_servers)
    Iceoryx2.max_clients!(builder, 1 + additional_clients)
    Iceoryx2.max_response_buffer_size!(builder, 1)
    return Iceoryx2.open_or_create(builder)
end

function wait_for_request(server::Iceoryx2.Server, req::Iceoryx2.ActiveRequest)
    while true
        Iceoryx2.receive!(server, req) || continue
        return nothing
    end
end

function perform_request_benchmark(
    iterations::Int,
    service_type::Iceoryx2.ServiceType,
    additional_servers::Int,
    additional_clients::Int,
)
    node_builder = Iceoryx2.NodeBuilder()
    node = Iceoryx2.create(node_builder, service_type)

    factory_a2b = build_rr_factory(node, "a2b", additional_servers, additional_clients)
    factory_b2a = build_rr_factory(node, "b2a", additional_servers, additional_clients)

    extra_clients = Iceoryx2.Client[]
    extra_servers = Iceoryx2.Server[]

    for _ in 1:additional_clients
        push!(extra_clients, Iceoryx2.create(Iceoryx2.client_builder(factory_a2b)))
        push!(extra_clients, Iceoryx2.create(Iceoryx2.client_builder(factory_b2a)))
    end

    for _ in 1:additional_servers
        push!(extra_servers, Iceoryx2.create(Iceoryx2.server_builder(factory_a2b)))
        push!(extra_servers, Iceoryx2.create(Iceoryx2.server_builder(factory_b2a)))
    end

    startup = SpinBarrier(3)
    start_benchmark = SpinBarrier(3)

    t1 = Threads.@spawn begin
        client_a2b = Iceoryx2.create(Iceoryx2.client_builder(factory_a2b))
        server_b2a = Iceoryx2.create(Iceoryx2.server_builder(factory_b2a))

        wait_barrier(startup)
        wait_barrier(start_benchmark)

        request = Iceoryx2.RequestMut(client_a2b)
        pending = Iceoryx2.PendingResponse(client_a2b)
        active = Iceoryx2.ActiveRequest(server_b2a)
        Iceoryx2.loan_uninit!(client_a2b, request)

        for _ in 1:iterations
            Iceoryx2.send!(request, pending)
            Iceoryx2.close(pending)
            Iceoryx2.loan_uninit!(client_a2b, request)
            wait_for_request(server_b2a, active)
            Iceoryx2.close(active)
        end

        Iceoryx2.close(request)
        Iceoryx2.close(server_b2a)
        Iceoryx2.close(client_a2b)
        return nothing
    end

    t2 = Threads.@spawn begin
        client_b2a = Iceoryx2.create(Iceoryx2.client_builder(factory_b2a))
        server_a2b = Iceoryx2.create(Iceoryx2.server_builder(factory_a2b))

        wait_barrier(startup)
        wait_barrier(start_benchmark)

        request = Iceoryx2.RequestMut(client_b2a)
        pending = Iceoryx2.PendingResponse(client_b2a)
        active = Iceoryx2.ActiveRequest(server_a2b)

        for _ in 1:iterations
            Iceoryx2.loan_uninit!(client_b2a, request)
            wait_for_request(server_a2b, active)
            Iceoryx2.close(active)
            Iceoryx2.send!(request, pending)
            Iceoryx2.close(pending)
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
    latency_ns = elapsed_ns ÷ (iterations * 2)

    println(
        "[REQUESTS] $(service_type_label(service_type)) ::: Iterations: $(iterations), " *
        "Time: $(elapsed_ns / 1.0e9) s, Latency: $(latency_ns) ns",
    )

    Iceoryx2.close(factory_a2b)
    Iceoryx2.close(factory_b2a)
    Iceoryx2.close(node)
    return nothing
end

function perform_response_stream_benchmark(
    iterations::Int,
    service_type::Iceoryx2.ServiceType,
    additional_servers::Int,
    additional_clients::Int,
)
    node_builder = Iceoryx2.NodeBuilder()
    node = Iceoryx2.create(node_builder, service_type)

    factory_a2b = build_rr_factory(node, "a2b", additional_servers, additional_clients)
    factory_b2a = build_rr_factory(node, "b2a", additional_servers, additional_clients)

    extra_clients = Iceoryx2.Client[]
    extra_servers = Iceoryx2.Server[]

    for _ in 1:additional_clients
        push!(extra_clients, Iceoryx2.create(Iceoryx2.client_builder(factory_a2b)))
        push!(extra_clients, Iceoryx2.create(Iceoryx2.client_builder(factory_b2a)))
    end

    for _ in 1:additional_servers
        push!(extra_servers, Iceoryx2.create(Iceoryx2.server_builder(factory_a2b)))
        push!(extra_servers, Iceoryx2.create(Iceoryx2.server_builder(factory_b2a)))
    end

    startup = SpinBarrier(3)
    start_benchmark = SpinBarrier(3)

    t1 = Threads.@spawn begin
        client_a2b = Iceoryx2.create(Iceoryx2.client_builder(factory_a2b))
        server_b2a = Iceoryx2.create(Iceoryx2.server_builder(factory_b2a))

        wait_barrier(startup)
        pending = Iceoryx2.PendingResponse(client_a2b)
        response_in = Iceoryx2.Response(pending)
        Iceoryx2.send_copy!(client_a2b, UInt64[0], pending)
        while !Iceoryx2.has_requests(server_b2a)
        end
        active = Iceoryx2.ActiveRequest(server_b2a)
        Iceoryx2.receive!(server_b2a, active) || error("expected active request")
        wait_barrier(start_benchmark)

        response = Iceoryx2.ResponseMut(active)
        Iceoryx2.loan_uninit!(active, response)

        for _ in 1:iterations
            Iceoryx2.send!(response)
            Iceoryx2.loan_uninit!(active, response)
            while !Iceoryx2.receive!(pending, response_in)
            end
            Iceoryx2.close(response_in)
        end

        Iceoryx2.close(response)
        Iceoryx2.close(response)
        Iceoryx2.close(active)
        Iceoryx2.close(pending)
        Iceoryx2.close(server_b2a)
        Iceoryx2.close(client_a2b)
        return nothing
    end

    t2 = Threads.@spawn begin
        client_b2a = Iceoryx2.create(Iceoryx2.client_builder(factory_b2a))
        server_a2b = Iceoryx2.create(Iceoryx2.server_builder(factory_a2b))

        wait_barrier(startup)
        pending = Iceoryx2.PendingResponse(client_b2a)
        response_in = Iceoryx2.Response(pending)
        Iceoryx2.send_copy!(client_b2a, UInt64[0], pending)
        while !Iceoryx2.has_requests(server_a2b)
        end
        active = Iceoryx2.ActiveRequest(server_a2b)
        Iceoryx2.receive!(server_a2b, active) || error("expected active request")
        wait_barrier(start_benchmark)

        response = Iceoryx2.ResponseMut(active)
        for _ in 1:iterations
            Iceoryx2.loan_uninit!(active, response)
            while !Iceoryx2.receive!(pending, response_in)
            end
            Iceoryx2.close(response_in)
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
    latency_ns = elapsed_ns ÷ (iterations * 2)

    println(
        "[RESPONSE_STREAM] $(service_type_label(service_type)) ::: Iterations: $(iterations), " *
        "Time: $(elapsed_ns / 1.0e9) s, Latency: $(latency_ns) ns",
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
    debug = has_flag(args, ["-d", "--debug-mode"])
    additional_servers = parse_int(args, ["--number-of-additional-servers"], 0)
    additional_clients = parse_int(args, ["--number-of-additional-clients"], 0)

    iterations > 0 || error("iterations must be positive")
    additional_servers >= 0 || error("additional servers must be non-negative")
    additional_clients >= 0 || error("additional clients must be non-negative")

    Threads.nthreads() >= 2 || error("set JULIA_NUM_THREADS>=2 for this benchmark")

    if debug
        Iceoryx2.set_log_level(:trace)
    else
        Iceoryx2.set_log_level(:error)
    end

    for service_type in (Iceoryx2.ServiceType.IPC, Iceoryx2.ServiceType.LOCAL)
        perform_request_benchmark(iterations, service_type, additional_servers, additional_clients)
        perform_response_stream_benchmark(iterations, service_type, additional_servers, additional_clients)
    end

    return nothing
end

main(ARGS)
