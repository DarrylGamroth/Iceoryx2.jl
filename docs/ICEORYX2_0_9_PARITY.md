# iceoryx2 v0.9.999 Julia Parity Matrix

This tracks the Julia safe API against the upstream iceoryx2 language bindings
for the v0.9.999 ABI. The native fork reference used for this snapshot is
`../iceoryx2` at `332684f261ee8e81c642232446229c3c1233744a`. The package is
pinned to `Iceoryx2_jll v0.9.999+3`; the generated header comes from artifact
`7d298804b69195e4e0dea399824471d8b388942c`.

The C# comparison snapshot was taken from
`https://github.com/eclipse-iceoryx/iceoryx2-csharp` at `8dde348`
(`2026-04-17`).

## Coverage Summary

| Area | Julia status | Notes |
| --- | --- | --- |
| C ABI bindings | Covered | Generated Julia FFI has 682/682 header functions. This is ABI coverage, not safe API coverage. |
| Core node API | Mostly covered | Node creation, names, IDs, state, list nodes, wait, and stale-resource cleanup are wrapped and tested. |
| Service builders | Mostly covered | Event, publish/subscribe, request/response, and blackboard create/open/open-or-create flows are present, including attribute-based variants. Builder option coverage is broad but still benefits from negative matrix tests. |
| Service transports | Covered | The same service-dependent suite, including allocation and inference gates, runs for both `ServiceType.IPC` and `ServiceType.LOCAL`. |
| Publish/subscribe | Mostly covered | Typed payloads, dynamic slices, fixed-size user headers, loan/send/receive, headers, port IDs, port lists, subscriber buffer sizing, static/dynamic counts, and service hashes are covered. Dynamic user headers are intentionally not exposed by the safe API. |
| Request/response | Mostly covered | Typed requests/responses, dynamic slices, fixed-size user headers, loan/send/receive, headers, port IDs, port lists, static/dynamic counts, and service hashes are covered. Dynamic user headers are intentionally not exposed by the safe API. |
| Events | Mostly covered | Listener/notifier creation, grouped v0.9.999 waits, port names/lists, notifications, static config, service name, service hash, and node listing are covered. |
| Blackboard | Mostly covered | Create/open, entries, readers/writers, static/dynamic counts, attributes, service hashes, custom keys, entry acquisition errors, one `EntryHandleMut` per value, `is_up_to_date`, uninitialized update, and discard are covered. |
| Static config | Mostly covered | Factory-level static config structs and owned service-discovery snapshots are exposed for all messaging patterns; cloned attribute sets have deterministic `close` support. More negative compatibility cases remain. |
| Dynamic config | Mostly covered | Counts and list callbacks are exposed and tested for all port families. More edge cases around disconnects and concurrent changes remain. |
| Attributes | Mostly covered | Specifier/verifier, attribute views, allocation-free iteration, and negative service-open compatibility are covered. Standalone error-path coverage is still lighter than upstream. |
| WaitSet | Partial | Interval, notification, deadlines, `WaitSetAttachmentId`, signal-handling mode, and `WaitSetGuard` lifecycle are covered with zero-allocation callback gates. Multi-notification and cross-service behavior need deeper parity tests. |
| Config | Mostly covered | Global/default options, static config, dynamic counts/lists, detail accessors, 0.9 backpressure strategy names, and path suffix fields are wrapped. Exhaustive config field mutation matrix coverage remains incomplete. |
| Backpressure | Mostly covered | Config defaults, publisher/client/server builder strategy setters, publisher/client runtime getters, builder-level callback handlers, deterministic publisher buffer, client request-buffer, and server response-buffer backpressure tests are covered for safe-overflow, discard, retry-count, retry-until-timeout, discard-and-fail, and follow-strategy behavior. Retry-until-delivered unblock/disconnect cases remain. |
| Degradation handlers | Partial | Builder-level safe handlers are exposed for pub/sub and request/response ports. Deterministic degradation-triggering tests remain. |
| Cleanup state | Mostly covered | C ABI is generated. Node-level aggregate cleanup and factory-level cleanup-state wrappers are exposed for all messaging patterns. |
| File/path helper types | Partial | File descriptors are covered for listener/waitset use. Python exposes richer path/file-name wrappers than Julia currently does. |
| Cross-language examples/tests | Partial | Julia examples cover core patterns, but CI-style C++/Python/Julia interoperability tests are not present. |
| Hot-path allocation gates | Stronger than upstream Python/C++ need | Julia has explicit zero-allocation hot-path tests for pub/sub, request/response, waitsets, blackboard, attributes, and handler-installed pub/sub/request-response ports. |

## API Comparison

The Julia wrapper intentionally uses Julia naming and mutation conventions:
`send!`, `receive!`, `loan!`, `loan_uninit!`, `payload`, `payload_mut`,
`header`, and builder setters ending in `!`. That is appropriate for Julia, but
the API should continue to track upstream nouns and option names. Aliases should
not be kept for names that upstream removed.

C++ is currently the richest high-level reference. It has a broad typed object
model for static/dynamic config, port factories, service hashes, backpressure,
degradation, cleanup state, waitsets, and detail types.

Python is also broad and closely mirrors the upstream Rust concepts in Pythonic
form. It exposes many wrappers for path/name/type/service details and has dense
per-builder tests.

C# has a high-level .NET-oriented API with SafeHandle ownership, Result-style
errors, async/await helpers, reactive extensions, and examples for the major
communication patterns. Its test suite is smaller than Julia's, but it has more
language-native async/reactive ergonomics.

Julia is strongest on typed hot paths, allocation control, and symmetric
`IPC`/`LOCAL` coverage. It is weaker on complete high-level coverage of
management/configuration APIs and some behavioral edge-case matrices.

## Test Comparison

| Suite | Files | Notes |
| --- | ---: | --- |
| Upstream C++ | 15 `*_tests.cpp` files | Dense coverage of service builders, config/static/dynamic details, service hashes, service compatibility, nodes, waitsets, and ports. |
| Upstream Python | 27 `*_tests.py` files | Broad API coverage for builders, ports, path/name/type helpers, services, waitsets, clients/servers/readers/writers, and slices. |
| C# | 4 test files plus many examples | Good smoke/integration coverage for .NET ownership, zero-copy, discovery, and runtime behavior; less exhaustive than Julia for hot-path allocation and less exhaustive than upstream C++ for parity matrices. |
| Julia | 40 test files, 3826 total test lines | Broad core coverage plus explicit hot-path allocation/type-inference tests. All service-dependent tests run against both transports; behavioral edge-case parity is still less exhaustive than upstream. |

Counts are useful for orientation only. The upstream C++ tests are much denser
per file, while the Julia suite has unique performance gates that do not map
directly onto Python/C++.

### Service-Type Matrix

| Area | Axis | Permutations | Evidence | Status | Notes |
| --- | --- | --- | --- | --- | --- |
| Service-dependent API | Service transport | `IPC`, `LOCAL` | `test/service_type_suite.jl` is instantiated by both transport modules in `test/runtests.jl` | Covered | Includes nodes, discovery, all four messaging patterns, waitsets, callbacks, compatibility, cleanup, and configuration. |
| Hot paths | Service transport | `IPC`, `LOCAL` | `test/perf_gates.jl`, `test/allocations_hotpath.jl` | Covered | The same inference and steady-state allocation assertions execute for each backend. |

## Priority Gap List

1. Add deterministic integration tests that trigger degradation handlers and
   broaden backpressure incident coverage beyond non-blocking queue saturation
   cases, especially retry-until-delivered unblock/disconnect behavior.
2. Add more negative compatibility tests for additional builder limit cases.
3. Add waitset parity tests for multi-notification and cross-service behavior.
4. Add cross-language interoperability tests that run Julia against upstream
   C++/Python examples using the same service names and type names.
5. Consider Julia-native async/reactive helpers only after core safe API parity
   stabilizes. C# has richer async/await and reactive ergonomics; Julia's
   current priority remains zero-allocation synchronous hot paths.
6. Add wrapper coverage for lower-priority utility/file-name/path helpers that
   Python exposes but the Julia safe API intentionally defers today.
7. Decide whether to add a public raw-FFI escape-hatch module name; for now the
   unsafe boundary is `Iceoryx2.Iceoryx2FFI`.

## Review Status

- Public safe signatures no longer accept raw C enum values. Symbols remain only
  where they are established Julia conveniences; public enum values are the
  canonical typed API.
- Error objects expose `code::Symbol`, `raw_code::UInt32`, and `message::String`.
  C error enum objects stay behind `check_ok` and generated FFI constructors.
- Dynamic user headers remain intentionally unavailable in the safe API to match
  upstream safe examples and avoid exposing behavior that upstream wrappers do
  not demonstrate.
- Hot callback trampolines for backpressure, degradation, node listing, and
  WaitSet processing are covered by `@inferred` and zero-allocation gates.
- Every Julia `@cfunction` trampoline contains exceptions within Julia. The
  synchronous callback APIs rethrow after the native call returns.

## Recent 0.9 Parity Fixes

- Regenerated and verified all 682 C functions against `Iceoryx2_jll
  v0.9.999+3`, with exact package compatibility pins for runtime and generator
  environments.
- Migrated progressive publish/subscribe to the native
  announce/commit/complete/abort lifecycle, including coherent atomic
  committed-length/state snapshots, successful-announcement recipient counts,
  and zero-allocation gates for both transports.
- Instantiated the complete service-dependent test suite for both `IPC` and
  `LOCAL`, matching the typed/parameterized service-type strategy used by the
  upstream C++ and Python wrappers.
- Migrated listener waits to v0.9.999 `try_wait`, `timed_wait`, and
  `blocking_wait`, including grouped `(event_id, count)` callbacks.
- Added v0.9.999 port-name builders/getters, subscriber `history_request`,
  client `max_active_requests`, payload-byte accessors, node cleanup, stale
  service force-removal, and blackboard opener key comparison.
- Made port and node IDs immutable isbits values so hot `id` access is
  allocation-free and `hash` agrees with equality.
- Invalidated every consumed builder/sample/request/response before translating
  a native error, preventing double-drop and reuse after failure.
- Made service-discovery `StaticConfig` snapshots own and drop cloned attribute
  sets; nonexistent services now return `nothing` without reading uninitialized
  storage.

- Renamed Julia config API to upstream 0.9 `backpressure_strategy` naming.
- Renamed event `service_id` access to `service_hash`.
- Added `service_hash` to publish/subscribe, request/response, and blackboard
  factories.
- Added service-hash parity tests that verify same-service hashes match and
  different-service hashes differ for all four messaging patterns.
- Added publisher/client/server builder-level `backpressure_strategy!` and
  publisher/client `backpressure_strategy` getters.
- Added `CleanupState` plus factory-level `try_cleanup_dead_nodes` and
  `blocking_cleanup_dead_nodes` wrappers for all messaging patterns.
- Added node-level aggregate `try_cleanup_dead_nodes` and
  `blocking_cleanup_dead_nodes` wrappers.
- Added `global_service_cleanup_dead_nodes_on_open` config accessors.
- Added missing 0.9 global node config suffix accessors for
  `global_node_global_mgmt_suffix` and `global_node_port_tag_suffix`, and
  exported the global config accessor surface.
- Added field-level static-config accessors and parity tests for all messaging
  patterns.
- Added dynamic-config count/list/detail parity tests for all port families.
- Added negative service compatibility tests for mismatched payload, header, key,
  attribute requirements, missing required attributes, and port-limit violations.
- Added waitset lifecycle parity tests for signal handling, guard removal,
  attachment IDs, and missed deadlines.
- Added safe builder-level backpressure/degradation callback handlers with
  callback-scope info views, Julia action enums, exception capture, and
  builder-to-port keepalive transfer. Symbol action returns remain supported as
  a compatibility convenience.
- Added public Julia enums for backpressure strategies and degradation causes,
  keeping raw C enum values behind the unsafe boundary.
- Added public Julia enums for signal handling modes and WaitSet run results,
  keeping raw C enum values out of the safe Node/WaitSet API.
- Added public Julia enums for log levels, allocation strategies, messaging
  patterns, type variants, and node-list states, keeping raw C enum values
  behind the unsafe boundary.
- Changed generated exception objects to expose Julia `Symbol` codes plus raw
  numeric codes instead of raw C enum objects.
- Added zero-allocation callback trampoline tests for concrete handler
  functions.
- Added deterministic server response-buffer backpressure tests for safe
  overflow, `BackpressureDiscardData`, retry-count and retry-until-timeout handling,
  `BackpressureDiscardDataAndFail`, and `BackpressureFollowStrategy`.
- Added deterministic client request-buffer backpressure tests for safe
  overflow, `BackpressureDiscardData`, retry-count and retry-until-timeout handling,
  `BackpressureDiscardDataAndFail`, and `BackpressureFollowStrategy`.
- Added deterministic publisher buffer backpressure tests for safe overflow,
  `BackpressureDiscardData`, retry-count handling,
  `BackpressureDiscardDataAndFail`, and `BackpressureFollowStrategy`.
- Added blackboard tests for missing keys, mismatched value types, one
  `EntryHandleMut` per value, `is_up_to_date` generation counters,
  `EntryValueUninit` discard and reuse, and custom key listing/access.
- Corrected client request send paths to throw `RequestSendError` from the
  native `iox2_request_send_error_e` result instead of treating request-send
  failures as generic `SendError`s.
- Added zero-allocation send/receive gates with pub/sub and request/response
  handlers installed.
- Added `buffer_size!` for subscriber builders and verified it through dynamic
  subscriber details.
