# Iceoryx2.jl Usage Notes

## Ownership and lifetimes

- Most high-level objects own native resources (handles) and **must be closed** with `close(obj)`.
- Use `create(f, builder)` or `open_or_create(f, builder)` to scope ownership with `do` blocks.
- Handles are **consumed** by some calls (e.g. `send!(sample)`); the wrapper invalidates the handle after transfer.
- Finalizers exist as a safety net but are not deterministic. For low-latency use, always call `close`.
- Migration note: `NodeBuilder` no longer takes `ServiceType`; pass it to `create(builder, ServiceType.IPC)` instead.
- Migration note: `list_nodes`, `list_services`, `service_does_exist`, `service_details`, and `remove_stale_resources`
  now require an explicit `service_type` keyword (no default).
- Migration note: `WaitSetBuilder` now requires an explicit `ServiceType` argument.
- Migration note for v0.9.999: listener waits use `try_wait`, `timed_wait`, and
  `blocking_wait`; callbacks receive `(event_id, count)` because notifications
  are grouped by event ID.

## Configuration

Create a mutable config, adjust defaults, then pass it into a builder:

```julia
config = Iceoryx2.default_config()
Iceoryx2.defaults_publish_subscribe_max_nodes!(config, 32)
Iceoryx2.global_prefix!(config, "demo")

builder = Iceoryx2.NodeBuilder()
Iceoryx2.config!(builder, config)
node = Iceoryx2.create(builder, Iceoryx2.ServiceType.IPC)

# ... use node ...

close(node)
close(config)
```

You can also load from a file or clone an existing config:

```julia
cfg_from_file = Iceoryx2.config_from_file("iceoryx2.toml")
cfg_clone = Iceoryx2.config_clone(cfg_from_file)
close(cfg_clone)
close(cfg_from_file)
```

## Port names and v0.9.999 tuning

All port builders accept semantic names, and live ports expose a borrowed
`PortNameView` through `name`:

```julia
publisher_builder = Iceoryx2.publisher_builder(factory)
Iceoryx2.name!(publisher_builder, "telemetry-publisher")
publisher = Iceoryx2.create(publisher_builder)
@assert string(Iceoryx2.name(publisher)) == "telemetry-publisher"
```

The v0.9.999 subscriber/client controls follow Julia mutation naming:
`history_request!(subscriber_builder, n)` and
`max_active_requests!(client_builder, n)`. Their runtime/detail counterparts
are `history_request(details)` and `max_active_requests(client_or_details)`.

## Payload types (`isbits` requirement)

Zero-copy payloads require `isbits` element types.

```julia
struct MyPayload
    a::UInt64
    b::UInt32
end

isbitstype(MyPayload) # true
```

The service builder checks `isbits` and throws if the payload type is not eligible for zero-copy.
Pub/sub and request/response factories are typed when you create the builder.
For non-primitive payloads and headers, you must also define a stable cross-language type name:

```julia
Iceoryx2.type_name(::Type{MyPayload}) = "MyPayload"
```

If you need to override the computed alignment, use the alignment setters on the builder:

```julia
pubsub_builder = Iceoryx2.publish_subscribe(Iceoryx2.service_builder(node, "svc"), UInt64)
Iceoryx2.payload_alignment!(pubsub_builder, Base.datatype_alignment(UInt64))
```

## Slice and payload access

`payload(::Sample)` and `payload_mut(::SampleMut)` return a `Slice{T}` view into shared memory.
It is **allocation-free** and valid only while the owning sample/request/response is alive.
The slice keeps the owner alive to avoid GC collection, but calling `close` on the owner
still invalidates the view.

Reading:

```julia
slice = Iceoryx2.payload(sample)
value = slice[1]
```

Writing (for mutable samples/requests/responses):

```julia
slice = Iceoryx2.payload_mut(sample)
slice[1] = 0xdeadbeef
```

For dynamic payloads, fill the slice without allocations using `map!` (or `broadcast!`) over indices:

```julia
slice = Iceoryx2.payload_mut(sample)
map!(i -> some_value(i - 1), slice, Base.OneTo(length(slice)))
```

Do not store the pointer or slice past the lifetime of the owning handle.

For scalar payloads, preallocate a mutable sample and use `loan_uninit!` + `write_payload!`:

```julia
sample = Iceoryx2.SampleMut(publisher)
Iceoryx2.loan_uninit!(publisher, sample)
Iceoryx2.write_payload!(sample, Distance(get_ultra_sonic_sensor_distance(), 42.0))
Iceoryx2.send!(sample)
```

`loan!`/`loan_slice!` default-initialize payloads using `zero(::Type{T})`.
If your payload type does not define `zero`, use `loan_uninit!`/`loan_slice_uninit!`
and write the payload manually.

## Progressive byte streams

`progressive_publish_subscribe` creates a byte-slice service with one publisher.
Announcing a private loan publishes its buffer identity with an empty committed
prefix; the returned active writer can then extend that prefix without
enqueuing another sample:

```julia
builder = Iceoryx2.progressive_publish_subscribe(
    Iceoryx2.service_builder(node, "frames"))
factory = Iceoryx2.open_or_create(builder)

publisher_builder = Iceoryx2.publisher_builder(factory)
Iceoryx2.initial_max_slice_len!(publisher_builder, 4096)
publisher = Iceoryx2.create(publisher_builder)
subscriber = Iceoryx2.create(Iceoryx2.subscriber_builder(factory))

loan = Iceoryx2.ProgressiveSampleMutUninit(publisher)
writer = Iceoryx2.ProgressiveSampleMut(publisher)
sample = Iceoryx2.ProgressiveSample(subscriber)

Iceoryx2.loan_slice_uninit!(publisher, loan, 4096)
Iceoryx2.announce!(loan, writer)
Iceoryx2.write_from_slice!(writer, UInt8[1, 2, 3, 4])

if Iceoryx2.receive!(subscriber, sample)
    prefix = Iceoryx2.payload(sample) # acquire-bounded immutable prefix
    progress = Iceoryx2.snapshot(sample) # coherent length and lifecycle state
    Iceoryx2.complete!(writer)
    close(sample)
end
```

The earlier experimental progressive API is intentionally not retained as a
compatibility layer:

| Earlier API | Current API |
| --- | --- |
| `send!(loan, writer)` | `announce!(loan, writer)` |
| `published_len(writer)` | `committed_len(writer)` |
| `unsafe_set_published_len!(writer, n)` | `unsafe_commit_until!(writer, n)` |
| `finish!(writer)` | `complete!(writer)` |
| `ProgressiveSampleStateFilling` | `ProgressiveSampleStateActive` |

`snapshot(sample)` is new. It atomically observes the committed length and
lifecycle state together; reading them in separate calls does not promise that
they describe the same instant. A successful commit release-publishes the
prefix, and subscriber reads acquire that commit. Committed bytes are immutable.

`state(sample)` and `snapshot(sample)` are allocation- and syscall-free. Use
their `_with_publisher_liveness` variants only when abrupt publisher death must
be distinguished, since those variants may perform operating-system calls
while the sample is active. `close(writer)` aborts an active sample.

For a direct external writer, retain `unsafe_payload_mut(writer)` and call
`unsafe_commit_until!` only after the new contiguous prefix is initialized,
CPU-visible, and will never be modified again. Neither function performs DMA
cache maintenance.

## Receiving samples

Receiving APIs are reuse-based to keep hot paths allocation-free. Preallocate a `Sample`
and call `receive!` inside the loop; always `close` the sample to release the loan:

```julia
sample = Iceoryx2.Sample(subscriber)
while Iceoryx2.receive!(subscriber, sample)
    try
        println("received: ", Iceoryx2.payload(sample)[1])
    finally
        close(sample)
    end
end
```

Reusable wrappers (`Sample`, `SampleMut`, `RequestMut`, `Response`, `ResponseMut`, `PendingResponse`,
`ActiveRequest`, `EntryHandle`, `EntryHandleMut`, `EntryValueUninit`) are designed for hot paths: they
hold preallocated storage and only borrow/release a C handle per call. After each `receive!`, `send!`,
`update!`, or `discard!`, the wrapper must be `close`d before reuse. These objects are not thread-safe;
use one instance per task or guard with external synchronization.

## Blackboard uninitialized updates

For uninitialized blackboard updates, use `loan_uninit!` and the `value!` helper to write the value
without exposing raw pointers:

```julia
uninit = Iceoryx2.EntryValueUninit(entry_mut)
Iceoryx2.loan_uninit!(entry_mut, uninit)
Iceoryx2.value!(uninit, UInt64(77))
Iceoryx2.update!(uninit, entry_mut)
```

## Attribute view buffers

For allocation-free access to attribute keys/values in tight loops, provide reusable `UInt8` buffers:

```julia
key_buffer = Vector{UInt8}(undef, Int(Iceoryx2.Iceoryx2FFI.IOX2_ATTRIBUTE_KEY_LENGTH) + 1)
value_buffer = Vector{UInt8}(undef, Int(Iceoryx2.Iceoryx2FFI.IOX2_ATTRIBUTE_VALUE_LENGTH) + 1)

key = Iceoryx2.key_view!(key_buffer, attrs[1])
value = Iceoryx2.value_view!(value_buffer, attrs[1])
# key/value are StringView instances backed by the supplied buffers.
# The view is invalidated by the next write into that buffer; call String(key) to keep it.
```

## Dynamic payloads and headers

Use an `AbstractVector{T}` payload type for runtime-length payloads:

```julia
builder = Iceoryx2.publish_subscribe(service_builder, AbstractVector{UInt8})
```

User headers are fixed-size in the safe Julia API. Use isbits scalar/struct,
tuple, or static-array header types. Dynamic header variants are intentionally
not exposed unless upstream safe bindings define concrete length/access
semantics for them.

## Event listener wait helpers

You can wait on listener events directly without a WaitSet:

```julia
received = Iceoryx2.timed_wait(listener, 1, 0) do event_id, count
    println("event ", Int(event_id), " occurred ", count, " times")
end
```

The return value is the total number of notifications. Reuse a concrete
`ListenerWaitHandler` when the call is on a zero-allocation hot path.

## Durations and timeouts

The C++/Rust APIs use `Duration` values. In Julia we keep the low-level
`(seconds, nanoseconds)` arguments for allocation-free hot paths:

```julia
# 1 second (returns false on SIGINT/SIGTERM)
while Iceoryx2.wait(node, 1, 0)
    # do work
end

# 250 milliseconds
Iceoryx2.attach_interval(waitset, 0, 250_000_000)
```

This maps directly to the C ABI and avoids extra conversion overhead.

For blocking grouped handling, use `blocking_wait`:

```julia
Iceoryx2.blocking_wait(listener) do event_id, count
    @show Int(event_id) count
end
```

## Service discovery ownership

`service_details` returns `nothing` when the service does not exist. Otherwise
it returns an owned `StaticConfig`; close it to release the cloned native
attribute set. Configs passed to `list_services` callbacks are owned as well.

```julia
config = Iceoryx2.service_details(
    "my-service";
    service_type=Iceoryx2.ServiceType.IPC,
    messaging_pattern=:publish_subscribe,
)
if config !== nothing
    try
        println(Iceoryx2.name(config))
    finally
        close(config)
    end
end
```

## Blackboard entries

Use readers/writers to update and read key/value pairs:

```julia
entry_mut = Iceoryx2.EntryHandleMut(writer, UInt64)
Iceoryx2.entry!(writer, entry_mut, UInt64(1))
Iceoryx2.update!(entry_mut, UInt64(42))
close(entry_mut)

entry = Iceoryx2.EntryHandle(reader, UInt64)
Iceoryx2.entry!(reader, entry, UInt64(1))
value, generation = Iceoryx2.get(entry)
close(entry)
```

Blackboard factories are typed on the key type when the builder is created.

## Callback safety

Callbacks are wrapped via `@cfunction` trampolines with `GC.@preserve`. To keep hot paths
allocation-free, avoid capturing large environments and use `let` blocks when needed.
Detail view objects and pointer arguments passed into callbacks are only valid for the
duration of the callback; copy to `String` or owned buffers if you need to keep data.
Exceptions are caught inside every C trampoline and rethrown after synchronous native
calls return, so Julia exceptions never unwind through C. Asynchronous backpressure,
degradation, and logging callbacks expose failures through `last_callback_exception`
or `last_log_exception`.

Backpressure and degradation handlers should return the Julia action enums:

```julia
Iceoryx2.backpressure_handler!(publisher_builder) do info
    Iceoryx2.retries(info) < 2 && return Iceoryx2.BackpressureRetry
    return Iceoryx2.BackpressureDiscardData
end

Iceoryx2.degradation_handler!(publisher_builder) do cause, info
    cause == Iceoryx2.DegradationConnectionCorrupted || return Iceoryx2.DegradationIgnore
    return Iceoryx2.DegradationWarn
end
```

Strategy setters also accept Julia enum values such as
`Iceoryx2.BackpressureStrategyDiscardData` and
`Iceoryx2.AllocationStrategyBestFit`. Enum values are converted to the native C
ABI internally. Symbol action returns remain accepted for compatibility, but the
enum values are the public Julia API.

Node and WaitSet signal handling likewise use Julia enum values such as
`Iceoryx2.SignalHandlingModeDisabled`; `wait_and_process*` returns a
`WaitSetRunResult`.

Logging uses `LogLevel` values, service details expose `MessagingPattern` and
`TypeVariant` values, and node-list callbacks receive `NodeState` values. Raw C
enum values remain available only through `Iceoryx2FFI`.
