# Iceoryx2.jl Benchmarks

These scripts mirror the upstream iceoryx2 latency benchmarks for publish-subscribe, request-response, and event ping-pong patterns.
They require at least two Julia threads.

Set the thread count before running:

```bash
export JULIA_NUM_THREADS=2
```

## Publish-Subscribe

Benchmark the round-trip latency between a publisher and subscriber pair using two services (`a2b` and `b2a`).

```bash
julia --project benchmarks/publish_subscribe.jl --bench-all
```

Common options:

- `--iterations N`
- `--payload-size BYTES`
- `--send-copy`
- `--bench-ipc`, `--bench-local`, `--bench-all`

## Request-Response

Benchmark request latency and response stream latency using two services (`a2b` and `b2a`).

```bash
julia --project benchmarks/request_response.jl --bench-all
```

Common options:

- `--iterations N`
- `--bench-ipc`, `--bench-local`, `--bench-all`

## Event

Benchmark notifier/listener round-trip latency using two services (`a2b` and `b2a`).

```bash
julia --project benchmarks/event.jl --bench-all
```

Common options:

- `--iterations N`
- `--bench-ipc`, `--bench-local`, `--bench-all`

## Notes

- These benchmarks currently use default service builder limits. The Julia wrapper does not yet expose all tuning knobs used in the upstream C++/Rust benchmarks.
- The upstream queue benchmark is not implemented here because the queue API is not yet wrapped.
- CPU affinity/priority controls from the upstream benchmarks are not available in Julia.
