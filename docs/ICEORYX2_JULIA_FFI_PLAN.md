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
- `Publisher`/`Subscriber` send/receive paths and `loan!`/`loan_uninit!`/`loan_slice!` paths.
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
- Add a thin `ccall` wrapper layer for every function with consistent naming.
- Place raw bindings under a strict unsafe namespace/module; keep safe wrappers in `Iceoryx2`.
- Generator notes:
  - `gen/gen-bindings.jl` also regenerates `src/generated/handles.jl` and `src/generated/errors.jl` from `src/generated/Iceoryx2FFI.jl`.
  - It uses an ignorelist to skip low-level handle wrappers that would collide with high-level messaging types.
- Status: Completed (2026-01-26)

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
- Provide `do`-block helpers (e.g., `create(f, builder; ...)`) for deterministic cleanup on owning resources.
- Outputs:
  - Handle and view wrappers: `src/generated/handles.jl`
- Status: Completed (2026-01-26)

## Phase 4: Error Mapping
- Map each `*_error_e` to a Julia `Exception` type.
- Provide `check_ok(::Cint, ::Type{ErrorEnum})` that throws the correct exception.
- Use the C `*_error_string` functions for human-readable messages.
- Mark error formatting and message construction functions `@noinline` to isolate allocations.
- Outputs:
  - Error types and `check_ok`: `src/generated/errors.jl`
- Status: Completed (2026-01-26)

## Phase 5: Strings & Semantic Strings
- Provide constructors for `NodeName`, `ServiceName`, etc. from `String`.
- Convert to UTF-8 bytes + length and call `*_new`.
- Provide `.string()` that copies from `*_as_chars` to a Julia `String`.
- Never return raw pointers to users.
- Outputs:
  - String helpers: `src/strings.jl`
- Status: Completed (2026-01-26)

## Phase 6: Builder & Factory API
- Implement builder types matching the C++ API shape:
  - `NodeBuilder()`, `name!(builder, name)`, `config!(builder, config)`
  - `create(builder; service_type=:ipc)`
- Ensure builders are consumable and cleaned:
  - On `create`, mark builder invalid.
  - Add a finalizer to release if user never calls `create`.
- Pattern: mutable builder + chainable methods returning `builder` (Julia idiom).
- Outputs:
  - Builders: `src/builders.jl`
- Status: Completed (2026-01-26)

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
- Outputs:
  - Messaging wrappers: `src/messaging.jl`
- Status: Completed (2026-01-27)
  - Update (2026-01-28): moved generated bindings/handles/errors into `src/generated/` and updated scripts/docs accordingly.
  - Update (2026-01-28): aligned builder API with C++/Rust (`publish_subscribe`/typed `request_response`/typed blackboard builders) and removed the `payload_type!`/`key_type!` setup step from user code.
  - Update (2026-01-27): added typed blackboard creator helpers (`blackboard_creator(builder, ::Type)`) and `add!` to supply required entries.

## Phase 8: Callbacks & Iteration
- For callbacks (node listing, waitset, attribute iteration):
  - Use a C trampoline (`@cfunction`) with a `Ref` context.
  - `GC.@preserve` around `ccall` to keep closure alive.
- Maintain a callback registry/context struct to keep closures alive; use `FunctionWrappers.jl` and `let` blocks to avoid capture-induced allocations and type instability.
- Provide Julia-idiomatic iteration:
  - `list_nodes(config) do state ... end`
  - Optional `collect` variants that return arrays.
- Outputs:
  - Callback helpers: `src/callbacks.jl`
- Status: Completed (2026-01-27)

## Phase 9: WaitSet & FileDescriptor
- `WaitSet`, `WaitSetGuard`, `WaitSetAttachmentId` wrappers.
- Provide `wait_and_process` and `wait_and_process_once` as Julia methods accepting closures.
- Ensure guard ownership is enforced via finalizers or explicit `close`.
- Outputs:
  - WaitSet wrappers: `src/waitset.jl`
- Status: Completed (2026-01-27)

## Phase 10: Config & Static/Dynamic Config
- Map by-value config structs (static config types) to immutable Julia structs.
- Provide high-level getters with Julia types (`Duration`, `Alignment`, etc.).
- For dynamic config, wrap C handles.
- Outputs:
  - Config helpers: `src/config.jl`
- Status: Completed (2026-01-27)
  - Update (2026-01-27): added blackboard `list_keys` callback helper.
  - Update (2026-01-28): added a TOML-driven wrapper generator for repetitive config defaults/global accessors (`gen/wrapper-spec.toml` → `src/generated/wrappers.jl`).
  - Update (2026-01-28): extended the generator to cover detail accessors, enum/optional config defaults, and notifier deadlines.
  - Update (2026-01-28): extended the generator to cover builder tuning setters (pub/sub, request/response, event, blackboard, publisher/server).
  - Update (2026-01-28): extended the generator to cover Unique*Id helpers (bytes/id/==/isless).
  - Update (2026-01-28): extended the generator to cover port factory view accessors + dynamic config counts.

## Phase 11: Logging Integration
- Expose `set_log_level`, `set_log_level_from_env` functions.
- Optionally bridge to Julia's `Logging` by providing a custom logger.
- Status: Completed (2026-01-27)

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
- Tests are organized under `test/testsets` and included from `test/runtests.jl`.
- Coverage script: `scripts/coverage_symbols.jl` compares C header functions to `Iceoryx2FFI` wrappers.
- Perf gates: `test/testsets/perf_gates.jl` adds `@inferred` and `@allocated` checks for hot-path primitives.
- Benchmark scaffolding: `scripts/bench_hotpath.jl` provides `BenchmarkTools` baselines for hot-path primitives.
- Status: Completed (2026-01-27)
  - Update (2026-01-27): added testsets mirroring iceoryx2-cxx coverage (attributes, enum conversion, logging, node/service names, node state, event/blackboard services, unique IDs, waitset notification, config basics).
  - Update (2026-01-27): added allocation gates for blackboard entry accessors and listener wait helpers.
  - Update (2026-01-27): added allocation gates for new payload helpers and a regression test for dynamic pub/sub slices.

## Phase 13: Documentation & Examples
- Provide examples matching C++ docs:
  - pub/sub, request/response, event, blackboard.
- Document:
  - ownership rules,
  - required `isbits` payload types,
  - safe vs unsafe pointer access.
 - Status: Completed (2026-01-27)

## Phase 14: Enhancements for Python/C++ Parity
- Expand builder tuning knobs surfaced in Julia:
  - Pub/Sub: `max_publishers`, `max_subscribers`, `history_size`, `subscriber_max_buffer_size`,
    `subscriber_max_borrowed_samples`, `enable_safe_overflow`.
  - Event: `max_notifiers`, `max_listeners`, `event_id_max_value`.
  - Request/Response: `max_clients`, `max_servers`, `max_loaned_requests`,
    `max_loaned_responses_per_request`, `max_response_buffer_size`,
    `enable_safe_overflow_for_requests`, `enable_safe_overflow_for_responses`.
- Add listener wait helpers that mirror higher-level APIs:
  - `blocking_wait_one`, `try_wait_one`, `timed_wait_one`, and `wait_all` with callbacks.
- Add higher-level convenience helpers present in Python/C++:
  - Connection status helpers (`has_requests`, `has_samples`, etc.) where missing.
  - Convenience `send_copy` overloads and `do`-block helpers for common ownership types.
- Benchmark parity:
  - Implement queue benchmark once the queue API is wrapped in the C ABI.
- Improve docs/examples to match Python/C++ quickstart guides.
- Status: Completed (2026-01-27)
  - Queue benchmark pending on queue API exposure in the C ABI.
  - Update (2026-01-27): added blackboard tuning (`max_readers!`, `max_nodes!`, key comparison) and cached type details to reduce hot-path allocations.
  - Update (2026-01-27): removed handle collisions with blackboard entry types, added entry-value uninit path, added slice keepalive + iteration interfaces, and hardened type-detail cache for multi-threaded use.
  - Update (2026-01-27): added scalar `loan_uninit!` helpers and `write_payload!` overloads for pub/sub and request/response; added `unsafe_payload_ptr`/`unsafe_payload_mut_ptr` convenience accessors.
  - Update (2026-01-29): switched hot-path loan/receive APIs to reuse-based `receive!`/`loan_uninit!`/`loan_slice_uninit!`, removed allocating variants, and updated examples/tests to close samples explicitly.
  - Update (2026-01-27): added StringViews-based attribute accessors (`key_view!`, `value_view!`, `key_value_view!`) with `AttributeScratch` for reuse.
  - Update (2026-01-27): typed port factories and blackboard (payload/key types enforced at builder/factory boundaries).

## Correctness & Ownership Hardening
- Remove collisions between autogenerated handles and high-level wrappers (`EntryHandle`, `EntryHandleMut`, `EntryValueUninit`).
- Ensure type-detail cache is thread-safe under multi-threaded access.

## Missing Wrappers Checklist
- [x] Publish/subscribe header accessors (`publisher_id`, `number_of_elements`). (`src/messaging.jl:398`, `src/messaging.jl:408`)
- [x] Request/response header accessors (`client_id`, `server_id`, `number_of_elements`). (`src/messaging.jl:805`, `src/messaging.jl:815`, `src/messaging.jl:947`, `src/messaging.jl:957`)
- [x] `node_wait` wrapper. (`src/nodes.jl:14`)
- [x] Event port-factory accessors: `attributes`, `nodes`, `service_name`, `service_id`, `static_config`. (`src/generated/wrappers.jl:997`, `src/callbacks.jl:96`, `src/generated/wrappers.jl:1021`, `src/messaging.jl:1148`, `src/generated/wrappers.jl:115`)
- [x] Event service-builder attribute-based open/create and notifier/deadline toggles. (`src/messaging.jl:1177`, `src/messaging.jl:1277`, `src/generated/wrappers.jl:778`)
- [x] Notifier `deadline` accessor. (`src/generated/wrappers.jl:808`)
- [x] Config helpers: `config_from_file`, `config_clone`, `config_from_ptr`. (`src/config.jl:61`, `src/config.jl:77`, `src/config.jl:71`)
- [x] Config defaults/global setters (publish/subscribe, event, request/response, blackboard, global prefixes/paths). (`src/generated/wrappers.jl:740`, `src/generated/wrappers.jl:815`, `src/generated/wrappers.jl:962`)
- [x] Details view accessors (client/server/publisher/subscriber/listener/notifier/reader/writer). (`src/generated/wrappers.jl:143`)
- [x] Message type details wrapper (`iox2_message_type_details_t` / `iox2_type_detail_t`). (`src/config.jl:119`, `src/config.jl:123`)
- [x] FileDescriptor helpers: `file_descriptor_new`, `native_handle`. (`src/waitset.jl:71`, `src/waitset.jl:78`)
- [x] `dead_node_remove_stale_resources` wrapper. (`src/nodes.jl:62`)
- [x] Ensure payload views keep owning handles alive and provide basic iteration interfaces. (`src/messaging.jl:63`, `src/messaging.jl:90`)
- [x] Provide blackboard entry uninitialized update path (`loan_uninit!`, `value_mut`, `update!`, `discard!`). (`src/messaging.jl:1957`, `src/messaging.jl:1980`, `src/messaging.jl:1989`, `src/messaging.jl:2000`)
- [x] Clarify key comparator semantics and allow custom comparator pointer injection. (`src/messaging.jl:1747`, `src/messaging.jl:1759`)
- [x] Make attribute iteration return owned strings by default and provide a pointer-based variant for zero-alloc use. (`src/callbacks.jl:173`, `src/callbacks.jl:195`, `src/callbacks.jl:199`)
- [x] Harden attribute error/value string extraction against missing null terminators. (`src/attributes.jl:245`)
- Status: Completed (2026-01-27)

## Design Decisions to Mirror iceoryx2-cxx Idioms
- RAII-style cleanup via finalizers + explicit `close`.
- Builder chaining and consume-on-create semantics.
- Typed payload APIs with size/alignment checks.
- Callbacks wrapped in safe Julia closures with explicit lifetime handling.

## Refactor Notes (Backlog)
- Consider co-locating struct definitions with their constructors/methods (currently grouped by concern). Defer until a functional change touches those areas to avoid style-only churn.
- Consider StringViews-based string accessors for details/attribute views when allocation-free access is needed.
