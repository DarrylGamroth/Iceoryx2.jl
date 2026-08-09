# v0.9.999 Binding Traceability

| Requirement ID | Requirement | Implementation | Verification evidence |
| --- | --- | --- | --- |
| ABI-001 | Bind exactly `Iceoryx2_jll v0.9.999+3` | exact compat pins in root/gen projects; `gen/gen-bindings.jl` | `scripts/coverage_symbols.jl` reports 682/682; `gen/verify_generated.jl` performs a non-destructive byte comparison |
| ABI-002 | Preserve the raw C ABI boundary | `src/generated/Iceoryx2FFI.jl` and generated handle/error layers | package load plus full test suite |
| OWN-001 | Invalidate every natively consumed handle on success and failure | node/waitset/service/port builders and sample/request/response `send!` paths | `test/service_compatibility.jl`, `test/request_response.jl` |
| OWN-002 | Release cloned static-config attributes | owned `StaticConfig` with `close`/finalizer in `src/config.jl` | `test/config.jl`, `test/service_listing.jl` |
| SAFE-001 | Never unwind a Julia exception through C | all callback trampolines catch; synchronous APIs rethrow after C returns | listener, node-list, attribute, config-list, callback-handler, and waitset tests |
| SAFE-002 | Prevent writes through read-only shared-memory views | mutability guards and explicit `copyto!` methods for `Slice` | `test/slice.jl`; ambiguity check in verification |
| TEST-001 | Exercise service behavior under every supported transport | shared service-type suite instantiated for `IPC` and `LOCAL` in isolated modules | `test/service_type_suite.jl`; named backend summaries from `Pkg.test()` |
| PERF-001 | Hot IDs are type-stable and allocation-free | immutable isbits `NodeId`/`Unique*Id` values in `src/ids.jl` | `test/node.jl`, `test/unique_port_id.jl`, allocation suite |
| PERF-002 | Messaging and WaitSet hot paths allocate zero bytes after warmup | reusable concrete buffers/handlers, no `unsafe_wrap` | `test/perf_gates.jl`, `test/allocations_hotpath.jl` |
| API-001 | Expose grouped v0.9.999 listener waits | `try_wait`, `timed_wait`, `blocking_wait` in `src/messaging/event.jl` | `test/listener_wait.jl` and event benchmark |
| API-002 | Expose v0.9.999 port names and tuning | port `name!`/`name`, `history_request!`, `max_active_requests!` | `test/builder_tuning.jl` |
| API-003 | Expose v0.9.999 payload byte counts | `payload_number_of_bytes` for pub/sub and request/response buffers | `test/pubsub.jl`, `test/request_response.jl` |
| API-004 | Expose node cleanup and stale-service removal | `try_cleanup_dead_nodes`, `blocking_cleanup_dead_nodes`, `force_remove_service` | `test/cleanup_state.jl` |
| API-005 | Expose progressive buffer ownership, announcement recipients, and atomic progress | recipient count from `announce!`, `unsafe_commit_until!`, `complete!`, `abort!`, and coherent snapshots in `src/messaging/progressive_publish_subscribe.jl` | `test/progressive_pubsub.jl` for both transports, including type-inference and zero-allocation gates |
| EXT-001 | Treat a `StaticArray` as one fixed-size payload | `ext/Iceoryx2StaticArraysExt.jl` | `test/type_variants.jl` |

The table uses stable IDs so future ABI updates can amend implementation and
evidence without silently dropping a safety or performance requirement.
