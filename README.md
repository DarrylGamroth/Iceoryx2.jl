# Iceoryx2.jl

![CI](https://github.com/DarrylGamroth/Iceoryx2.jl/actions/workflows/ci.yml/badge.svg)
[![codecov](https://codecov.io/gh/DarrylGamroth/Iceoryx2.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/DarrylGamroth/Iceoryx2.jl)

Idiomatic, zero-copy Julia bindings for the iceoryx2 C ABI. This revision is
pinned to `Iceoryx2_jll v0.9.999+2` and covers all 682 header functions.

## Quick start

```julia
using Iceoryx2

# For real applications, run publisher/subscriber in separate processes.
node = create(NodeBuilder(), ServiceType.IPC)
service = open_or_create(publish_subscribe(service_builder(node, "Demo/Service"), UInt64))

publisher = create(publisher_builder(service))
subscriber = create(subscriber_builder(service))

pub_sample = SampleMut(publisher)
sub_sample = Sample(subscriber)

loan_uninit!(publisher, pub_sample)
write_payload!(pub_sample, UInt64(42))
send!(pub_sample)

if receive!(subscriber, sub_sample)
    value = payload(sub_sample)[1]
    close(sub_sample)
end

close(pub_sample)
close(subscriber)
close(publisher)
close(service)
close(node)
```

## Progressive publish/subscribe

The progressive API announces a byte-buffer handle once, then grows the
immutable committed prefix visible to subscribers without sending another
sample:

```julia
node = create(NodeBuilder(), ServiceType.IPC)
builder = progressive_publish_subscribe(service_builder(node, "Demo/Frames"))
service = open_or_create(builder)

publisher_builder = publisher_builder(service)
initial_max_slice_len!(publisher_builder, 4096)
publisher = create(publisher_builder)
subscriber = create(subscriber_builder(service))

loan = ProgressiveSampleMutUninit(publisher)
writer = ProgressiveSampleMut(publisher)
received = ProgressiveSample(subscriber)

loan_slice_uninit!(publisher, loan, 4096)
announce!(loan, writer)
write_from_slice!(writer, UInt8[1, 2, 3, 4])

if receive!(subscriber, received)
    current_prefix = payload(received)
    progress = snapshot(received)
    complete!(writer)
    close(received)
end

close(writer) # aborts if still active
close(loan)
close(subscriber)
close(publisher)
close(service)
close(node)
```

For external zero-copy writers, retain `unsafe_payload_mut(writer)` and advance
the committed boundary with `unsafe_commit_until!` only after every newly
exposed byte is initialized, CPU-visible, and immutable.

## Examples

See `examples/` for publish/subscribe, request/response, event, and blackboard samples that match the upstream C++ examples.

## Cross-language type names

For custom payloads/headers/keys used across languages, define a stable type name:

```julia
Iceoryx2.type_name(::Type{MyType}) = "MyType"
```

## Tests

```bash
julia --project -e 'using Pkg; Pkg.test()'
```

## Generated files

CI verifies the generated bindings are up to date. Regenerate with:

```bash
julia --startup-file=no --project=gen gen/gen-bindings.jl
julia --startup-file=no --project=gen gen/verify_generated.jl
julia --startup-file=no --project=. scripts/coverage_symbols.jl
```
