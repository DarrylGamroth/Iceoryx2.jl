using Clang.Generators
using Iceoryx2_jll

cd(@__DIR__)

include_dir = joinpath(Iceoryx2_jll.artifact_dir, "include")
include("generate-wrappers.jl")

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

ffi_path = joinpath(@__DIR__, "..", "src", "generated", "Iceoryx2FFI.jl")
handles_path = joinpath(@__DIR__, "..", "src", "generated", "handles.jl")
errors_path = joinpath(@__DIR__, "..", "src", "generated", "errors.jl")
wrappers_path = joinpath(@__DIR__, "..", "src", "generated", "wrappers.jl")
wrapper_spec = joinpath(@__DIR__, "wrapper-spec.toml")

ignore_owning = Set([
    "node",
    "port_factory_pub_sub",
    "port_factory_request_response",
    "port_factory_event",
    "port_factory_blackboard",
    "publisher",
    "subscriber",
    "sample",
    "sample_mut",
    "client",
    "server",
    "request_mut",
    "response",
    "response_mut",
    "pending_response",
    "active_request",
    "notifier",
    "listener",
    "reader",
    "writer",
    "entry_handle",
    "entry_handle_mut",
    "entry_value_uninit",
    "waitset",
    "waitset_builder",
])

ffi_text = read(ffi_path, String)
generate_handles(ffi_text, handles_path; ignore_owning)
generate_errors(ffi_text, errors_path)
generate_simple_wrappers(wrapper_spec, wrappers_path)
