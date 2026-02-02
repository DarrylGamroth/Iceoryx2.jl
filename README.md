# Iceoryx2.jl

![CI](https://github.com/DarrylGamroth/Iceoryx2.jl/actions/workflows/ci.yml/badge.svg)
[![codecov](https://codecov.io/gh/DarrylGamroth/Iceoryx2.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/DarrylGamroth/Iceoryx2.jl)

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
