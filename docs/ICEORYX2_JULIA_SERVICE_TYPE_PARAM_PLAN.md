# ServiceType as a Type Parameter Plan

## Goal
Replace Symbol-based `service_type` plumbing with a strongly-typed `ServiceType` and propagate it as a type parameter
through Node → ServiceBuilder → PortFactory → Port APIs, matching the static semantics used in C++/Rust.

## Non-goals
- Preserve backward compatibility with `service_type::Symbol` (breaking change is acceptable).
- Rework unrelated APIs or refactor messaging patterns beyond service type propagation.

## High-level approach
- Define `ServiceType` as a Julia `@enum` matching the C ABI values.
- Remove `Symbol`-based conversion helpers and replace with `ServiceType` values in API signatures.
- Make `Node` and service-related types parametric on `ServiceType`.
- Keep `NodeBuilder` untyped; pass the `ServiceType` to `create` so the resulting `Node{S}` is statically typed.
- Ensure service type is preserved from Node → ServiceBuilder → pattern builders → factories → ports.
- Update examples, tests, benchmarks, docs to use `ServiceType` instead of `:ipc`/`:local`.

## Proposed type propagation
- `Node{S}` where `S<:ServiceType`
- `ServiceBuilder{S}`
- `EventServiceBuilder{S}`
- `PubSubServiceBuilder{S,T,UH}`
- `RequestResponseServiceBuilder{S,Req,Resp,ReqH,RespH}`
- `BlackboardCreatorBuilder{S,K}` / `BlackboardOpenerBuilder{S,K}`
- Factories and ports that are tied to a service:
  - `PortFactoryEvent{S}`
  - `PortFactoryPubSub{S,T,UH}` / `Publisher{S,T,UH}` / `Subscriber{S,T,UH}`
  - `PortFactoryRequestResponse{S,Req,Resp,ReqH,RespH}` / `Client{S,...}` / `Server{S,...}`
  - `PortFactoryBlackboard{S,K}` / `BlackboardWriter{S,...}` / `BlackboardReader{S,...}`
- `Waitset{S}` only if it is semantically tied to a service type; otherwise keep untyped and accept `ServiceType` at create.

## API surface changes
- `create(::NodeBuilder, ::ServiceType)` (service type is provided at creation)
- `create(::WaitsetBuilder{S})` (service type is in the builder type parameter)
- `list_nodes(; service_type=ServiceType.IPC)`
- `service_does_exist`, `service_details`, `list_services`, config helpers, etc. accept `ServiceType`.
- Remove `Union{Symbol, Iceoryx2FFI.iox2_service_type_e}` from all signatures.

## Implementation steps
1. **Introduce `ServiceType` enum**
   - Define in a central file (likely `src/builders/common.jl` or `src/ids.jl`).
   - Map to C ABI values without conversion helpers.
   - Update docs to mention `ServiceType.IPC`/`ServiceType.LOCAL`.

2. **Parametrize `Node` and builders**
   - Update `Node` type definition and constructors to carry `S`.
   - Update `service_builder` to accept `Node{S}` and return `ServiceBuilder{S}`.
   - Update `event/publish_subscribe/request_response/blackboard_*` builder constructors to preserve `S`.

3. **Propagate `S` through factories and ports**
   - Update port factories to include `S`.
   - Update `publisher_builder`, `subscriber_builder`, `client_builder`, `server_builder`, etc. to accept `PortFactory*{S,...}` and return builders/ports with `S`.
   - Ensure keepalive relationships remain valid and parametric.

4. **Update runtime APIs to accept `ServiceType`**
   - `create` functions, waitset creation, list nodes, list services, config helpers.
   - Remove `_service_type(::Symbol)` and any symbol-based overloads.

5. **Update call sites**
   - Examples, tests, benchmarks, docs, plan references.
   - Replace `:ipc`/`:local` with `ServiceType.IPC`/`ServiceType.LOCAL`.

6. **Audit for hot-path type stability**
   - Ensure no `Union` fields are introduced for `S`.
   - Confirm `service_type` no longer stored as runtime field in hot-path structs.

7. **Tests and benchmarks**
   - Run full test suite; update any explicit `Symbol` checks.
   - Run benchmarks to validate no regression.

## Notes
- If `Waitset` should be service-typed for parity with C++/Rust, we can introduce `Waitset{S}`; otherwise, keep `Waitset` untyped and accept `ServiceType` at creation to minimize propagation.
- This is a breaking API change; consider a release note and migration guide.

## Status
- Completed (2026-01-30)
