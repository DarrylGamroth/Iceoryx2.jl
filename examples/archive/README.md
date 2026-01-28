# Iceoryx2.jl Examples

Run examples from the repo root with:

```bash
julia --project examples/pubsub.jl
```

Available examples:

- `pubsub.jl`: publish-subscribe with a single message.
- `request_response.jl`: request/response round-trip.
- `event.jl`: notifier/listener event using `EventId`.
- `blackboard.jl`: blackboard creation with writer/reader handles.

Notes:

- The blackboard example only demonstrates construction; entry-level read/write helpers are not yet wrapped.
- All examples use the IPC service type by default.
