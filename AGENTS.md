# AGENTS.md

## Project Intent
This repo provides an idiomatic Julia wrapper for iceoryx2 with full coverage of the C ABI.

## Non‑Negotiable Requirements
- **Hot-path code must be type-stable and zero-allocation.**
- **Avoid dynamic dispatch on hot paths.** Use concrete fields, parametric structs, and function barriers.
- **Do not use `unsafe_wrap`** (it allocates). Prefer allocation‑free views.
- **All hot-path structs must avoid boxing/unboxing**; keep frequently accessed fields concrete.

## Hot Path Definition
Any API called per message/event or in tight loops, including:
- `Publisher`/`Subscriber` send/receive and `loan*` paths.
- `Client`/`Server` request/response send/receive.
- `Reader`/`Writer` entry and payload access.
- `WaitSet` processing (`wait_and_process*`) and callback dispatch.
- Any high‑frequency `*_details`, `id`, `header`, or `payload` accessors.

## Style Guide (SciML)
Follow the SciML Style Guide for naming, modules, error handling, tests, documentation, and formatting. Highlights:
- Consistency is the top priority; repo‑local consistency beats strict global adherence.
- Follow ColPrac contribution guidelines (keep PRs focused and avoid mixing style-only changes with functional changes).
- Prefer generic code and trait‑based interfaces when reasonable; internal types should match user types where possible.
- Avoid global state; keep code type‑stable and type‑grounded.
- Closures should be avoided when possible; use them carefully only when needed.
- Macros should be limited and only used for clear syntactic sugar.
- Errors should be caught high and messages contextualized for newcomers.
- Prefer subpackaging/interface packages over conditional modules via Requires.jl.
- Tests should cover a wide gamut of input types.
- Avoid unsafe operations and non‑public Base APIs; avoid `eval`; avoid `ccall` unless necessary and use safe `ccall` practices.
- Use JuliaFormatter (SciML settings) and align with the SciML style guide sections on documentation and formatting.

## Allowed Helper Packages
These may be used to keep hot paths allocation‑free and ABI‑safe:
- `UnsafeArrays.jl`
- `StringViews.jl`
- `FunctionWrappers.jl`
- `WrappedUnions.jl`

## Callback Guidance
- Julia closures are allowed, but use `let` blocks (and/or `FunctionWrappers.jl`) to avoid capture‑induced allocations or type instability.
- Use `GC.@preserve` around callbacks and pointer conversions.
- It is OK to store references in structs **only** to keep other objects alive; keep those fields concrete and off hot paths.

## Library & Layout
- Use `Iceoryx2_jll` by default for the native library.
- Keep a strict unsafe boundary (raw `ccall`s) and a safe, idiomatic layer on top.
