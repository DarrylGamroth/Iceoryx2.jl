# iceoryx2 Julia FFI Plan (Comprehensive)

## Goals
- Full API coverage of the C ABI (`iceoryx2-ffi/c`) with stable, auto-generated low-level bindings.
- Idiomatic Julia layer that mirrors C++ ergonomics (RAII-style cleanup, builder patterns, typed payloads, `do`-blocks).
- Clear lifetime and ownership semantics mapped to Julia objects and GC.
- All hot-path APIs are type-stable and zero-allocation.

## Performance & Safety Requirements
- All hot-path code must be type-stable and zero-allocation. Treat this as a hard requirement.
- Do not use `unsafe_wrap` (it allocates). Prefer allocation-free views.
- Allowed helper packages for zero-alloc views and ABI-safe callbacks:
  - `UnsafeArrays.jl`
  - `StringViews.jl`
  - `FunctionWrappers.jl`
  - `WrappedUnions.jl`
- Use macros where they reduce boilerplate or enforce invariants (e.g., handle lifetimes, error checks, or type metadata).
- Callbacks may use Julia closures, but use `let` blocks (and/or `FunctionWrappers.jl`) to avoid captures that introduce allocations or type instability.
- Avoid boxing/unboxing overhead on regularly accessed fields. Keep hot-path struct fields concrete and type-stable.
- Avoid dynamic dispatch on hot paths; prefer concrete types, parametric structs, and function barriers.

## Hot Path Definition
Hot path refers to any API that is called per message/event or inside tight loops, including:
- `Publisher`/`Subscriber` send/receive paths and `loan`/`loan_uninit`/`loan_slice` paths.
- `Client`/`Server` request/response send/receive paths.
- `Reader`/`Writer` entry access and payload accessors.
- `WaitSet` event processing (`wait_and_process*`) and callback dispatch.
- Any `*_details`, `id`, `header`, or `payload` accessor invoked at high frequency in loops.

## Overall Recommendations
- Define "hot path" explicitly and gate it in CI with `@inferred`, `@allocated == 0`, and a small `BenchmarkTools` suite.
- Keep error/reporting paths `@noinline` to isolate allocations from hot paths.
- Establish a strict unsafe boundary: a low-level `Iceoryx2FFI` or `Iceoryx2.Unsafe` module for raw `ccall`s; a safe `Iceoryx2` module for idiomatic API.
- Require `GC.@preserve` around all pointer conversions, buffer views, and callback entrypoints.
- Add ABI/version checks in `__init__` to fail fast on incompatible library/header versions or feature sets.
- Enforce handle invariants (`isvalid`, consumed handles invalid) and test use-after-close behavior.
- It is acceptable to store references in structs to keep objects alive, but those fields must be concrete types and not on hot paths. Avoid `Any` in frequently accessed fields.

## Phase 0: Inventory + Coverage Map
- Use the upstream source repo at `../iceoryx2` as the ABI/reference source.
- Parse `../iceoryx2/iceoryx2-ffi/c` header (`iceoryx2.h`) to enumerate all types/functions.
- Build a coverage matrix mapping C++ wrappers -> C functions -> Julia functions.
- Categorize into: core types, builders, messaging patterns, waitset, config, IDs/details, logging, utilities.
- Outputs:
  - Inventory: `docs/ICEORYX2_JULIA_FFI_INVENTORY.md`
  - Coverage map: `docs/ICEORYX2_JULIA_FFI_COVERAGE.md`
- Status: Completed (2026-01-26)

## Phase 1: Package Architecture
- Split into two layers (separate modules within one repo or separate packages):
  - `Iceoryx2FFI.jl` (raw C ABI bindings, no abstractions).
  - `Iceoryx2.jl` (idiomatic Julia API).
- Decide distribution path for native library:
  - Use `Iceoryx2_jll` by default (already available) for CI + users.
- Status: Completed (2026-01-26)

## Phase 2: Low-level C ABI Bindings
- Generate bindings from the C header with `Clang.jl` to avoid drift.
- Provide:
  - `const` for IOX2_OK, constants.
  - `@cenum` for all enums.
  - `struct` definitions only for by-value types; `Ptr{Cvoid}` for opaque handles.
- Place raw bindings under a strict unsafe namespace/module; keep safe wrappers in `Iceoryx2`.

## Phase 3: Handle & Ownership Model (Julia)
- Define owning handle types as `struct` wrappers:
  - `struct Node; handle::Ptr{Cvoid}; end`
  - Provide `Base.finalizer`, `close`, `isvalid`, and `unsafe_handle`.
- Non-owning view types for `_ptr` and `_h_ref` variants:
  - `struct NodeNameView; ptr::Ptr{Cvoid}; end`
  - Views never own memory; always copy to `String` when returning text.
- Explicit consume semantics for C functions that take ownership:
  - After a call that consumes a handle, set `handle = C_NULL`.
- If references are stored only to keep other objects alive, store them in concrete fields (e.g., `keepalive::K` or `keepalive::NamedTuple`), and keep those fields off hot paths.

## Phase 4: Error Mapping
- Map each `*_error_e` to a Julia `Exception` type.
- Provide `check_ok(::Cint, ::Type{ErrorEnum})` that throws the correct exception.
- Use the C `*_error_string` functions for human-readable messages.
- Mark error formatting and message construction functions `@noinline` to isolate allocations.

## Phase 5: Strings & Semantic Strings
- Provide constructors for `NodeName`, `ServiceName`, etc. from `String`.
- Convert to UTF-8 bytes + length and call `*_new`.
- Provide `.string()` that copies from `*_as_chars` to a Julia `String`.
- Never return raw pointers to users.

## Phase 6: Builder & Factory API
- Implement builder types matching the C++ API shape:
  - `NodeBuilder()`, `name!(builder, name)`, `config!(builder, config)`
  - `create(builder; service_type=:ipc)`
- Ensure builders are consumable and cleaned:
  - On `create`, mark builder invalid.
  - Add a finalizer to release if user never calls `create`.
- Pattern: mutable builder + chainable methods returning `builder` (Julia idiom).

## Phase 7: Messaging Patterns & Payloads
- Publish/Subscribe, Request/Response, Event, Blackboard all mirror C++ API:
  - `ServiceBuilder`, `PortFactory*`, `Publisher`, `Subscriber`, `Client`, `Server`, `Reader`, `Writer`.
- Typed payloads:
  - Require `isbits` structs for zero-copy payloads.
  - Use `sizeof`, `Base.datatype_alignment` to set type details.
  - Provide `payload(::Sample)` returning `Ptr{T}` or an allocation-free view (e.g., `UnsafeArrays` or `StringViews`).
- Dynamic slice support:
  - `Slice{T}` wrapper with pointer + length.
  - Methods `loan_slice`, `payload(::Sample)::Slice{T}`.

## Phase 8: Callbacks & Iteration
- For callbacks (node listing, waitset, attribute iteration):
  - Use a C trampoline (`@cfunction`) with a `Ref` context.
  - `GC.@preserve` around `ccall` to keep closure alive.
- Maintain a callback registry/context struct to keep closures alive; use `FunctionWrappers.jl` and `let` blocks to avoid capture-induced allocations and type instability.
- Provide Julia-idiomatic iteration:
  - `list_nodes(config) do state ... end`
  - Optional `collect` variants that return arrays.

## Phase 9: WaitSet & FileDescriptor
- `WaitSet`, `WaitSetGuard`, `WaitSetAttachmentId` wrappers.
- Provide `wait_and_process` and `wait_and_process_once` as Julia methods accepting closures.
- Ensure guard ownership is enforced via finalizers or explicit `close`.

## Phase 10: Config & Static/Dynamic Config
- Map by-value config structs (static config types) to immutable Julia structs.
- Provide high-level getters with Julia types (`Duration`, `Alignment`, etc.).
- For dynamic config, wrap C handles.

## Phase 11: Logging Integration
- Expose `set_log_level`, `set_log_level_from_env` functions.
- Optionally bridge to Julia's `Logging` by providing a custom logger.

## Phase 12: Testing Strategy
- Unit tests for:
  - handle lifetime + finalizers,
  - error mapping,
  - string conversions.
- Integration tests for:
  - basic Node create,
  - pub/sub send/receive,
  - request/response round-trip,
  - event + waitset.
- Add a coverage script comparing C header symbols to Julia exports.
- Add performance gates for hot-path APIs: `@inferred`, `@allocated == 0`, and small `BenchmarkTools` baselines in CI.

## Phase 13: Documentation & Examples
- Provide examples matching C++ docs:
  - pub/sub, request/response, event, blackboard.
- Document:
  - ownership rules,
  - required `isbits` payload types,
  - safe vs unsafe pointer access.

## Design Decisions to Mirror iceoryx2-cxx Idioms
- RAII-style cleanup via finalizers + explicit `close`.
- Builder chaining and consume-on-create semantics.
- Typed payload APIs with size/alignment checks.
- Callbacks wrapped in safe Julia closures with explicit lifetime handling.
