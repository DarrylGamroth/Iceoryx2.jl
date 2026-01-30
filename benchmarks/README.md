# Iceoryx2.jl Benchmarks

These scripts mirror the upstream iceoryx2 latency benchmarks for publish-subscribe,
request-response, and event ping-pong patterns. They require at least two Julia threads.

Set the thread count before running:

```bash
export JULIA_NUM_THREADS=2
```

## Publish-Subscribe

Benchmark the round-trip latency between a publisher and subscriber pair using two services
(`a2b` and `b2a`).

```bash
julia --project benchmarks/publish_subscribe.jl --bench-all
```

For configuration details:

```bash
julia --project benchmarks/publish_subscribe.jl --help
```

## Request-Response

Benchmark request latency and response-stream latency using two services (`a2b` and `b2a`).

```bash
julia --project benchmarks/request_response.jl
```

For configuration details:

```bash
julia --project benchmarks/request_response.jl --help
```

## Event

Benchmark notifier/listener round-trip latency using two services (`a2b` and `b2a`).

```bash
julia --project benchmarks/event.jl --bench-all
```

For configuration details:

```bash
julia --project benchmarks/event.jl --help
```

> [!IMPORTANT]
> When you increase the number of listeners or notifiers beyond a certain limit, the
> benchmark may exceed the per-user file descriptor limit. This limit can be increased by
> adjusting the `nofile` setting in `/etc/security/limits.conf` and raising your soft limit
> with `ulimit -n`.

## Notes

- The Julia bindings expose only `ServiceType.IPC` and `ServiceType.LOCAL` service types from the C ABI, so
  `--bench-all` runs those two variants (the upstream threadsafe variants are not available).
- CPU affinity and priority options are accepted for CLI parity but ignored in Julia.
- The upstream queue benchmark is not implemented here because the queue API is not yet wrapped.
