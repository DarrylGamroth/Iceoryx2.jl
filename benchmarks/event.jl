#!/usr/bin/env julia

using Random
using Base.Threads
using Iceoryx2

include(joinpath(@__DIR__, "bench_utils.jl"))
using .BenchUtils

const DEFAULT_ITERATIONS = 1_000_000
const DEFAULT_MAX_EVENT_ID = 128

function usage()
    println(
        """
Iceoryx2 event benchmark

Usage:
  event.jl [options]

Options:
  -n, --iterations N                     Number of ping-pong iterations (default: $DEFAULT_ITERATIONS)
      --bench-all                        Run IPC and local benchmarks
      --bench-ipc                        Run IPC service benchmark
      --bench-local                      Run local service benchmark
  -m, --max-event-id N                   Maximum event id value (default: $DEFAULT_MAX_EVENT_ID)
  -d, --debug-mode                       Enable trace logging
      --cpu-core-participant-1 N         CPU core for participant 1 (ignored in Julia)
      --cpu-core-participant-2 N         CPU core for participant 2 (ignored in Julia)
      --number-of-additional-notifiers N Additional notifiers per service (default: 0)
      --number-of-additional-listeners N Additional listeners per service (default: 0)
  -h, --help                             Show this help message
""",
    )
end

function build_event_factory(node::Iceoryx2.Node, name::AbstractString, additional_notifiers::Int, additional_listeners::Int, max_event_id::Int)
    builder = Iceoryx2.event(Iceoryx2.service_builder(node, name))
    Iceoryx2.max_notifiers!(builder, 1 + additional_notifiers)
    Iceoryx2.max_listeners!(builder, 1 + additional_listeners)
    Iceoryx2.event_id_max_value!(builder, max_event_id)
    return Iceoryx2.open_or_create(builder)
end

function perform_benchmark(
    iterations::Int,
    max_event_id::Int,
    service_type::Symbol,
    additional_notifiers::Int,
    additional_listeners::Int,
)
    node_builder = Iceoryx2.NodeBuilder()
    node = Iceoryx2.create(node_builder; service_type)

    factory_a2b = build_event_factory(node, "a2b", additional_notifiers, additional_listeners, max_event_id)
    factory_b2a = build_event_factory(node, "b2a", additional_notifiers, additional_listeners, max_event_id)

    extra_notifiers = Iceoryx2.Notifier[]
    extra_listeners = Iceoryx2.Listener[]

    for _ in 1:additional_notifiers
        push!(extra_notifiers, Iceoryx2.create(Iceoryx2.notifier_builder(factory_a2b)))
        push!(extra_notifiers, Iceoryx2.create(Iceoryx2.notifier_builder(factory_b2a)))
    end

    for _ in 1:additional_listeners
        push!(extra_listeners, Iceoryx2.create(Iceoryx2.listener_builder(factory_a2b)))
        push!(extra_listeners, Iceoryx2.create(Iceoryx2.listener_builder(factory_b2a)))
    end

    startup = SpinBarrier(3)
    start_benchmark = SpinBarrier(3)

    t1 = Threads.@spawn begin
        notifier_a2b = Iceoryx2.create(Iceoryx2.notifier_builder(factory_a2b))
        listener_b2a = Iceoryx2.create(Iceoryx2.listener_builder(factory_b2a))

        wait_barrier(startup)
        wait_barrier(start_benchmark)

        Iceoryx2.notify!(notifier_a2b)

        for _ in 1:iterations
            while Iceoryx2.blocking_wait_one(listener_b2a) === nothing
            end
            Iceoryx2.notify!(notifier_a2b)
        end

        Iceoryx2.close(listener_b2a)
        Iceoryx2.close(notifier_a2b)
        return nothing
    end

    t2 = Threads.@spawn begin
        notifier_b2a = Iceoryx2.create(Iceoryx2.notifier_builder(factory_b2a))
        listener_a2b = Iceoryx2.create(Iceoryx2.listener_builder(factory_a2b))

        wait_barrier(startup)
        wait_barrier(start_benchmark)

        for _ in 1:iterations
            while Iceoryx2.blocking_wait_one(listener_a2b) === nothing
            end
            Iceoryx2.notify!(notifier_b2a)
        end

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
    latency_ns = elapsed_ns ÷ (iterations * 2)

    println(
        "$(service_type_label(service_type)) ::: MaxEventId: $(max_event_id), Iterations: $(iterations), " *
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
    max_event_id = parse_int(args, ["-m", "--max-event-id"], DEFAULT_MAX_EVENT_ID)
    debug = has_flag(args, ["-d", "--debug-mode"])
    additional_notifiers = parse_int(args, ["--number-of-additional-notifiers"], 0)
    additional_listeners = parse_int(args, ["--number-of-additional-listeners"], 0)

    iterations > 0 || error("iterations must be positive")
    max_event_id > 0 || error("max event id must be positive")
    additional_notifiers >= 0 || error("additional notifiers must be non-negative")
    additional_listeners >= 0 || error("additional listeners must be non-negative")

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
            max_event_id,
            service_type,
            additional_notifiers,
            additional_listeners,
        )
    end

    return nothing
end

main(ARGS)
