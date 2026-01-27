# Helpers for Iceoryx2 benchmarks.

module BenchUtils

using Base.Threads

export SpinBarrier, wait_barrier, has_flag, parse_int, parse_string, parse_service_types

struct SpinBarrier
    total::Int
    count::Atomic{Int}
end

SpinBarrier(total::Integer) = SpinBarrier(Int(total), Atomic{Int}(0))

function wait_barrier(barrier::SpinBarrier)
    atomic_add!(barrier.count, 1)
    while atomic_load(barrier.count) < barrier.total
        Base.Threads.yield()
    end
    return nothing
end

function has_flag(args::Vector{String}, flags::Vector{String})
    for arg in args
        for flag in flags
            if arg == flag
                return true
            end
        end
    end
    return false
end

function parse_int(args::Vector{String}, flags::Vector{String}, default::Integer)
    for (idx, arg) in pairs(args)
        for flag in flags
            if arg == flag
                idx == length(args) && error("missing value for $flag")
                return parse(Int, args[idx + 1])
            elseif startswith(arg, flag * "=")
                return parse(Int, split(arg, "=", limit = 2)[2])
            end
        end
    end
    return Int(default)
end

function parse_string(args::Vector{String}, flags::Vector{String}, default::AbstractString)
    for (idx, arg) in pairs(args)
        for flag in flags
            if arg == flag
                idx == length(args) && error("missing value for $flag")
                return args[idx + 1]
            elseif startswith(arg, flag * "=")
                return split(arg, "=", limit = 2)[2]
            end
        end
    end
    return String(default)
end

function parse_service_types(args::Vector{String}; default_ipc::Bool = true)
    bench_all = has_flag(args, ["--bench-all"])
    bench_ipc = has_flag(args, ["--bench-ipc"])
    bench_local = has_flag(args, ["--bench-local"])

    types = Symbol[]
    if bench_all
        push!(types, :ipc, :local)
    else
        bench_ipc && push!(types, :ipc)
        bench_local && push!(types, :local)
        if isempty(types)
            default_ipc && push!(types, :ipc)
        end
    end

    return types
end

end
