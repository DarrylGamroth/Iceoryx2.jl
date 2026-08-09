#!/usr/bin/env julia

using Printf
using Iceoryx2_jll

function strip_comments(text::AbstractString)
    io = IOBuffer()
    i = firstindex(text)
    last = lastindex(text)
    while i <= last
        c = text[i]
        if c == '/' && i < last && text[i + 1] == '/'
            i = nextind(text, i + 1)
            while i <= last && text[i] != '\n'
                i = nextind(text, i)
            end
        elseif c == '/' && i < last && text[i + 1] == '*'
            i = nextind(text, i + 1)
            while i < last
                if text[i] == '*' && text[i + 1] == '/'
                    i = nextind(text, i + 1)
                    break
                end
                i = nextind(text, i)
            end
        else
            write(io, c)
        end
        i = nextind(text, i)
    end
    return String(take!(io))
end

function find_header(root::AbstractString, header::AbstractString)
    for (dir, _, files) in walkdir(root)
        for f in files
            if f == header
                return joinpath(dir, f)
            end
        end
    end
    return nothing
end

fallback_path = joinpath(
    @__DIR__, "..", "..", "iceoryx2", "iceoryx2-ffi", "c", "iceoryx2.h")
header_path = get(ENV, "IOX2_HEADER", fallback_path)
if !isfile(header_path)
    include_dir = joinpath(Iceoryx2_jll.artifact_dir, "include")
    found = find_header(include_dir, "iceoryx2.h")
    header_path = found === nothing ? header_path : found
end
ffi_path = joinpath(@__DIR__, "..", "src", "generated", "Iceoryx2FFI.jl")

isfile(header_path) ||
    error("header not found: $(header_path). Set IOX2_HEADER to a generated iceoryx2.h.")
isfile(ffi_path) || error("FFI file not found: $(ffi_path)")

header = strip_comments(read(header_path, String))
ffi = read(ffi_path, String)

header_names = Set{String}()
for stmt in split(header, ';')
    occursin('(', stmt) || continue
    occursin("iox2_", stmt) || continue
    occursin("typedef", stmt) && continue
    m = match(r"\biox2_[A-Za-z0-9_]+(?=\s*\()", stmt)
    m === nothing && continue
    push!(header_names, m.match)
end

ffi_names = Set{String}()
for m in eachmatch(r"^(?:@inline\s+)?function\s+(iox2_[A-Za-z0-9_]+)\s*\("m, ffi)
    push!(ffi_names, m.captures[1])
end

missing = sort!(collect(setdiff(header_names, ffi_names)))
extra = sort!(collect(setdiff(ffi_names, header_names)))

@printf("Header functions: %d\n", length(header_names))
@printf("FFI functions:    %d\n", length(ffi_names))

if !isempty(missing)
    println("\nMissing Julia wrappers:")
    for name in missing
        println("  ", name)
    end
end

if !isempty(extra)
    println("\nExtra Julia wrappers (not in header):")
    for name in extra
        println("  ", name)
    end
end

isempty(missing) && isempty(extra) || exit(1)
