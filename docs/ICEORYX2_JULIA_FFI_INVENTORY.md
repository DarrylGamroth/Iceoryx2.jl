# Iceoryx2 v0.9.999 C ABI Inventory

This inventory is generated from the `Iceoryx2_jll v0.9.999+2` header. The
exact artifact used by the generator is
`0fdc7690bf18492d6035d34897d5d94cd1de02c3`, whose header is under
`include/iceoryx2/v0.9.999/iox2/iceoryx2.h`.

| Inventory item | Count | Source of truth |
| --- | ---: | --- |
| C functions in the header | 682 | `scripts/coverage_symbols.jl` |
| Generated Julia FFI functions | 682 | `src/generated/Iceoryx2FFI.jl` |
| Missing functions | 0 | `scripts/coverage_symbols.jl` |
| Extra functions | 0 | `scripts/coverage_symbols.jl` |

The generated FFI file is the exhaustive symbol/type inventory. Keeping a
second hand-maintained list here previously allowed stale v0.8/v0.9.0 names to
survive ABI updates, so verification is executable instead:

```sh
julia --startup-file=no --project=. scripts/coverage_symbols.jl
julia --startup-file=no --project=gen gen/verify_generated.jl
```

The v0.9.999 delta represented in the safe layer includes:

- progressive publish/subscribe service, port, private-loan, active-writer,
  announce/commit/complete/abort lifecycle, coherent snapshot, committed-prefix,
  and liveness APIs;

- grouped listener waits (`iox2_listener_try_wait`, `iox2_listener_timed_wait`,
  and `iox2_listener_blocking_wait`);
- semantic port names and all publisher/subscriber/notifier/listener/client/
  server/reader/writer name setters and getters;
- subscriber history requests and client maximum-active-request limits;
- payload byte counts for samples, requests, and responses;
- node-scoped dead-node cleanup and forced stale-service removal;
- blackboard opener key equality comparison;
- v0.9.999 config suffixes, cleanup settings, errors, structs, and layouts.

Raw calls remain strictly inside `Iceoryx2.Iceoryx2FFI`; high-level mappings
are summarized in `ICEORYX2_JULIA_FFI_COVERAGE.md`.
