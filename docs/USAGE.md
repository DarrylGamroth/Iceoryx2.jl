# Iceoryx2.jl Usage Notes

## Ownership and lifetimes

- Most high-level objects own native resources (handles) and **must be closed** with `close(obj)`.
- Use `create(f, builder)` or `open_or_create(f, builder)` to scope ownership with `do` blocks.
- Handles are **consumed** by some calls (e.g. `send!(sample)`); the wrapper invalidates the handle after transfer.
- Finalizers exist as a safety net but are not deterministic. For low-latency use, always call `close`.

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

For scalar payloads, you can use `loan_uninit` + `write_payload!`:

```julia
sample = Iceoryx2.loan_uninit(publisher)
Iceoryx2.write_payload!(sample, Distance(get_ultra_sonic_sensor_distance(), 42.0))
Iceoryx2.send!(sample)
```

## Attribute scratch buffers

For allocation-free access to attribute keys/values in tight loops, use an explicit scratch buffer:

```julia
Iceoryx2.with_attribute_scratch() do scratch
    key = Iceoryx2.key_view!(scratch, attrs[1])
    value = Iceoryx2.value_view!(scratch, attrs[1])
    # key/value are StringView instances backed by scratch buffers.
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
Iceoryx2.writer_entry(writer, UInt64(1), UInt64) do entry_mut
    Iceoryx2.update!(entry_mut, UInt64(42))
end

Iceoryx2.reader_entry(reader, UInt64(1), UInt64) do entry
    value, generation = Iceoryx2.get(entry)
end
```

## Callback safety

Callbacks are wrapped via `@cfunction` trampolines with `GC.@preserve`. To keep hot paths
allocation-free, avoid capturing large environments and use `let` blocks when needed.
Detail view objects and pointer arguments passed into callbacks are only valid for the
duration of the callback; copy to `String` or owned buffers if you need to keep data.
