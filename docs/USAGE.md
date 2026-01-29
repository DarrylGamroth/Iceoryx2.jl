# Iceoryx2.jl Usage Notes

## Ownership and lifetimes

- Most high-level objects own native resources (handles) and **must be closed** with `close(obj)`.
- Use `create(f, builder)` or `open_or_create(f, builder)` to scope ownership with `do` blocks.
- Handles are **consumed** by some calls (e.g. `send!(sample)`); the wrapper invalidates the handle after transfer.
- Finalizers exist as a safety net but are not deterministic. For low-latency use, always call `close`.

## Configuration

Create a mutable config, adjust defaults, then pass it into a builder:

```julia
config = Iceoryx2.default_config()
Iceoryx2.defaults_publish_subscribe_max_nodes!(config, 32)
Iceoryx2.global_prefix!(config, "demo")

builder = Iceoryx2.NodeBuilder()
Iceoryx2.config!(builder, config)
node = Iceoryx2.create(builder)

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
unsafe_store!(slice.ptr, 0xdeadbeef, 1)
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

## Attribute scratch buffers

For allocation-free access to attribute keys/values in tight loops, use an explicit scratch buffer:

```julia
Iceoryx2.with_attribute_scratch() do scratch
    key = Iceoryx2.key_view!(scratch, attrs[1])
    value = Iceoryx2.value_view!(scratch, attrs[1])
    # key/value are StringView instances backed by scratch buffers.
    # The view is invalidated by the next scratch use; call String(key) to keep it.
end
```

## Event listener wait helpers

You can wait on listener events directly without a waitset:

```julia
event_id = Iceoryx2.timed_wait_one(listener, 1, 0)
```

For batch handling, use `*_wait_all` with a callback:

```julia
Iceoryx2.blocking_wait_all(listener) do event_id
    @show Int(event_id)
end
```

## Blackboard entries

Use reader/writer entries to update and read key/value pairs:

```julia
entry_mut = Iceoryx2.EntryHandleMut(writer, UInt64)
Iceoryx2.writer_entry!(writer, entry_mut, UInt64(1))
Iceoryx2.update!(entry_mut, UInt64(42))
close(entry_mut)

entry = Iceoryx2.EntryHandle(reader, UInt64)
Iceoryx2.reader_entry!(reader, entry, UInt64(1))
value, generation = Iceoryx2.get(entry)
close(entry)
```

Blackboard factories are typed on the key type when the builder is created.

## Callback safety

Callbacks are wrapped via `@cfunction` trampolines with `GC.@preserve`. To keep hot paths
allocation-free, avoid capturing large environments and use `let` blocks when needed.
Detail view objects and pointer arguments passed into callbacks are only valid for the
duration of the callback; copy to `String` or owned buffers if you need to keep data.
