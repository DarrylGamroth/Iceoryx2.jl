# Documentation Parity Plan (Rust/C++)

Goal: Add Julia docstrings for the public API that mirror the intent, naming, and semantics of the C++/Rust docs,
while remaining idiomatic Julia. This is a staged checklist so we can track progress incrementally.

## Stage 0: Inventory & Mapping
- [x] Enumerate the public API surface (exports + public constructors + key methods).
- [x] Map each symbol to its Rust/C++ counterpart (source file + item name).
- [x] Identify gaps or naming divergences that need explicit notes in docs.
- [x] Decide the canonical terminology for Julia docs (keep upstream terms where possible).

## Stage 1: Docstring Style & Templates
- [x] Define docstring template (summary, arguments, returns, errors, safety/lifetime notes).
- [x] Add short “Safety / lifetime” block for handles and views (Sample, Slice, headers).
- [x] Define a “Cross‑language type name” note for payload/header/key types.
- [x] Establish a consistent pattern for `do`-block variants and callback handlers.

## Stage 2: Core Types & Builders
- [x] `Node`, `NodeBuilder`, `create`, `close`, `wait`, `id`, `name`, `signal_handling_mode`.
- [x] `ServiceBuilder` and `service_builder` helpers.
- [x] Config types and constructors (`Config`, `default_config`, `config_from_file`, `config_clone`).

## Stage 3: Messaging – Publish/Subscribe
- [x] `Publisher`, `Subscriber`, `Sample`, `SampleMut`.
- [x] `publish_subscribe`, `publisher_builder`, `subscriber_builder`.
- [x] Loan/receive/send APIs (`loan*`, `receive*`, `send*`, `payload*`, `user_header*`, `header*`).
- [x] Dynamic slice APIs and `Slice` semantics.

## Stage 4: Messaging – Request/Response
- [x] `Client`, `Server`, `RequestMut`, `Response`, `ResponseMut`, `PendingResponse`, `ActiveRequest`.
- [x] `request_response`, `client_builder`, `server_builder`.
- [x] Loan/receive/send APIs and lifecycle notes.

## Stage 5: Messaging – Event
- [x] `Notifier`, `Listener`, `EventId`, `event` builders.
- [x] Event lifecycle (`notify!`, grouped `try_wait`/`timed_wait`/`blocking_wait`, `wait`, `deadline`).

## Stage 6: Messaging – Blackboard
- [x] `Reader`, `Writer`, `EntryHandle`, `EntryHandleMut`, `EntryValueUninit`.
- [x] `blackboard_creator`, `blackboard_opener`, `list_keys`, `add!`.
- [x] Key/value type detail requirements and type_name notes.

## Stage 7: WaitSet & FileDescriptor
- [x] `WaitSet`, `WaitSetBuilder`, `WaitSetGuard`, `WaitSetAttachmentId`.
- [x] `wait_and_process*` + callback semantics.
- [x] File descriptor wrappers and event integration docs.

## Stage 8: Attributes & Discovery
- [x] `AttributeSpecifier`, `AttributeVerifier`, `define!`, `require!`.
- [x] `list_nodes`, `list_services`, `service_does_exist`, `service_details`.
- [x] `remove_stale_resources` docs.

## Stage 9: Error Types & Enums
- [x] Add docstrings for error types and enums with mappings to C ABI names.
- [x] Mention “throwing vs return codes” expectations in high-level wrappers.

## Stage 10: Examples & Cross‑Language Notes
- [x] Ensure example modules reference docstrings (via `@doc` or inline links).
- [x] Add a “Cross‑language compatibility” section (IOX2_TYPE_NAME, layout, alignment).

## Stage 11: Verification
- [x] Run `julia --project -e 'using Pkg; Pkg.test()'`.
- [x] Spot-check docstrings with `?symbol` in the REPL for formatting.
- [x] Ensure no docstrings mention outdated defaults or APIs.

## References (local)
- C++ examples: `/home/dgamroth/workspaces/codex/iceoryx2/examples/cxx`
- Rust API: `/home/dgamroth/workspaces/codex/iceoryx2/iceoryx2/src`
- Rust ZeroCopySend type names: `/home/dgamroth/workspaces/codex/iceoryx2/iceoryx2-bb/elementary-traits/src/zero_copy_send.rs`
