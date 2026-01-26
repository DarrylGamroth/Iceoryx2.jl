using Clang.Generators
using Iceoryx2_jll

cd(@__DIR__)

include_dir = joinpath(Iceoryx2_jll.artifact_dir, "include")

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

iceoryx2_header = find_header(include_dir, "iceoryx2.h")
iceoryx2_header === nothing && error("iceoryx2.h not found under: $include_dir")

# wrapper generator options
options = load_options(joinpath(@__DIR__, "generator.toml"))

args = get_default_args()
push!(args, "-I$include_dir")

headers = [iceoryx2_header]

# create context
ctx = create_context(headers, args, options)

# run generator
build!(ctx)
