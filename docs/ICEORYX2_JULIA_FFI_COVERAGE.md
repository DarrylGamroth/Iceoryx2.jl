# Iceoryx2 v0.9.999 C ABI to Julia Coverage

The raw layer covers all 682 functions in the v0.9.999+2 header. This map records
where the corresponding safe Julia concepts live; individual raw symbols are
authoritatively listed by `src/generated/Iceoryx2FFI.jl`.

| Area | Safe implementation | Verification |
| --- | --- | --- |
| Raw C ABI, enums, layouts | `src/generated/Iceoryx2FFI.jl` | `scripts/coverage_symbols.jl`, `gen/verify_generated.jl` |
| Owning handles and borrowed views | `src/generated/handles.jl`, `src/service_types.jl` | handle lifecycle and compatibility tests |
| Generated safe errors | `src/generated/errors.jl`, `src/docs_errors.jl` | enum/error tests |
| Semantic node/service/port names | `src/strings.jl`, `src/builders/` | node, service, and builder-tuning tests |
| Node lifecycle, IDs, cleanup, force removal | `src/nodes.jl`, `src/ids.jl` | node, cleanup-state, and allocation tests |
| Publish/subscribe | `src/messaging/publish_subscribe.jl` | pub/sub, callback, compatibility, and allocation tests |
| Progressive publish/subscribe | `src/messaging/progressive_publish_subscribe.jl` | announce/commit/complete/abort lifecycle, coherent snapshots, errors, and allocation tests |
| Request/response | `src/messaging/request_response.jl` | request/response, send-error, callback, and allocation tests |
| Event/listener/notifier | `src/messaging/event.jl` | event, listener-wait, dynamic-config, and allocation tests |
| Blackboard | `src/messaging/blackboard.jl` | blackboard service/entry/config/allocation tests |
| Attributes and iteration | `src/attributes.jl`, `src/callbacks/attributes.jl` | attribute, callback-exception, and allocation tests |
| Discovery and static/dynamic config | `src/config.jl`, `src/generated/wrappers.jl` | config, service-listing, static/dynamic-config tests |
| WaitSet/file descriptors | `src/waitset/` | interval, notification, lifecycle, and allocation tests |
| Logging and native callbacks | `src/logging.jl`, `src/messaging/common.jl` | logging and callback-handler tests |
| StaticArrays integration | `ext/Iceoryx2StaticArraysExt.jl` | type-variant tests |

## Unsafe boundary

Only generated/raw implementation code invokes the C ABI. Public payload APIs
return allocation-free `Slice` views and never use `unsafe_wrap`. Owning calls
invalidate Julia handles before native errors are converted to exceptions.
Every `@cfunction` trampoline catches Julia exceptions; synchronous APIs rethrow
them after returning from C.

## High-level policy

“Full C ABI coverage” means every header function is callable through the raw
module. The safe layer intentionally groups repetitive C functions into
Julian interfaces (multiple dispatch, `!` mutation names, `do` blocks, `close`,
and typed reusable buffers) rather than exporting a one-to-one copy of every C
name.
