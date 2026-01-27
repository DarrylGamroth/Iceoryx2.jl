#!/usr/bin/env julia

using Random
using Base.Threads
using Iceoryx2

include(joinpath(@__DIR__, "bench_utils.jl"))
using .BenchUtils

const DEFAULT_ITERATIONS = 1_000_000

function usage()
    println(
        """
Iceoryx2 event benchmark

Usage:
  event.jl [options]

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

function build_event_factory(node::Iceoryx2.Node, name::AbstractString)
    builder = Iceoryx2.event(Iceoryx2.service_builder(node, name))
    return Iceoryx2.open_or_create(builder)
end

function wait_for_event(waitset::Iceoryx2.Waitset, guard::Iceoryx2.WaitsetGuard)
    Iceoryx2.wait_and_process_once(waitset) do attachment
        if Iceoryx2.has_event_from(attachment, guard)
            return :stop
        end
        return :continue
    end
    return nothing
end

function run_benchmark(iterations::Int, service_type::Symbol)
    suffix = unique_suffix()
    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, "iox2_julia_bench_event_" * suffix)
    node = Iceoryx2.create(node_builder; service_type)

    factory_a2b = build_event_factory(node, "a2b_" * suffix)
    factory_b2a = build_event_factory(node, "b2a_" * suffix)

    startup = SpinBarrier(3)
    start_benchmark = SpinBarrier(3)

    t1 = Threads.@spawn begin
        notifier_a2b = Iceoryx2.create(Iceoryx2.notifier_builder(factory_a2b))
        listener_b2a = Iceoryx2.create(Iceoryx2.listener_builder(factory_b2a))
        waitset = Iceoryx2.create(Iceoryx2.WaitsetBuilder(); service_type)
        guard = Iceoryx2.attach_notification(waitset, Iceoryx2.file_descriptor(listener_b2a))

        wait_barrier(startup)
        wait_barrier(start_benchmark)

        Iceoryx2.notify!(notifier_a2b)

        for _ in 1:iterations
            wait_for_event(waitset, guard)
            Iceoryx2.notify!(notifier_a2b)
        end

        Iceoryx2.close(guard)
        Iceoryx2.close(waitset)
        Iceoryx2.close(listener_b2a)
        Iceoryx2.close(notifier_a2b)
        return nothing
    end

    t2 = Threads.@spawn begin
        notifier_b2a = Iceoryx2.create(Iceoryx2.notifier_builder(factory_b2a))
        listener_a2b = Iceoryx2.create(Iceoryx2.listener_builder(factory_a2b))
        waitset = Iceoryx2.create(Iceoryx2.WaitsetBuilder(); service_type)
        guard = Iceoryx2.attach_notification(waitset, Iceoryx2.file_descriptor(listener_a2b))

        wait_barrier(startup)
        wait_barrier(start_benchmark)

        for _ in 1:iterations
            wait_for_event(waitset, guard)
            Iceoryx2.notify!(notifier_b2a)
        end

        Iceoryx2.close(guard)
        Iceoryx2.close(waitset)
        Iceoryx2.close(listener_a2b)
        Iceoryx2.close(notifier_b2a)
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
        "event::$(service_type) iterations=$(iterations) " *
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
        println("Please use either '--bench-all' or select a specific benchmark. See --help for details.")
        return nothing
    end

    for service_type in service_types
        run_benchmark(iterations, service_type)
    end

    return nothing
end

main(ARGS)
