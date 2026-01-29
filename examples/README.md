# Iceoryx2.jl Examples

These examples mirror the upstream C++ examples in `iceoryx2/examples/cxx`.
Run with:

```
julia --project=. examples/<example>/<file>.jl
```

Examples:
- blackboard: `creator.jl`, `opener.jl`
- blackboard_event_based_communication: `creator.jl`, `opener.jl`
- complex_data_types: `complex_data_types.jl`
- cross_language_communication_basics: `publisher.jl`, `subscriber.jl`
- cross_language_communication_complex_types: `publisher.jl`, `subscriber.jl`
- cross_language_communication_container: `publisher.jl`, `subscriber.jl`
- discovery: `discovery.jl`
- domains: `publisher.jl`, `subscriber.jl`, `discovery.jl`
- event: `notifier.jl`, `listener.jl`
- event_based_communication: `publisher.jl`, `subscriber.jl`
- event_multiplexing: `notifier.jl`, `wait.jl`
- health_monitoring: `central_daemon.jl`, `publisher_1.jl`, `publisher_2.jl`, `subscriber.jl`
- publish_subscribe: `publisher.jl`, `subscriber.jl`
- publish_subscribe_dynamic_data: `publisher.jl`, `subscriber.jl`
- publish_subscribe_with_user_header: `publisher.jl`, `subscriber.jl`
- request_response: `client.jl`, `server.jl`
- request_response_dynamic_data: `client.jl`, `server.jl`
- service_attributes: `creator.jl`, `opener.jl`, `incompatible.jl`
- service_types: `ipc_publisher.jl`, `ipc_threadsafe_subscriber.jl`, `local_pubsub.jl`

Previous examples are archived in `examples/archive`.

Out-of-scope upstream examples:
- `custom_vocabulary_types` (C++-only; vocabulary type swapping is not applicable in Julia).
- `discovery_service` and `service_variant_customization` (Rust-only; use crates/traits not exposed in the C ABI).
