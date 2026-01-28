function parse_arg(args::Vector{String}, short::String, long::String, default::String)
    idx = findfirst(a -> a == short || a == long, args)
    idx === nothing && return default
    idx == length(args) && error("Missing value for $short/$long")
    return args[idx + 1]
end

function show_help_if_requested(args::Vector{String}, lines::Vector{String})
    any(a -> a == "-h" || a == "--help", args) || return nothing
    for line in lines
        println(line)
    end
    exit(0)
end
