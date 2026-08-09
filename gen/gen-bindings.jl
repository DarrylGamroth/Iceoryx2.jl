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

# Keep each `ccall` visible to callers so supported Julia versions can
# stack-promote `Ref` out-parameters used by allocation-free safe wrappers.
function inline_ffi_wrappers!(path::AbstractString)
    source = read(path, String)
    inlined = replace(
        source,
        r"(?m)^function (?=iox2_[A-Za-z0-9_]+\()" => "@inline function ",
    )
    inlined == source && error("no iceoryx2 FFI wrappers found in: $path")
    write(path, inlined)
    return nothing
end

iceoryx2_header = find_header(include_dir, "iceoryx2.h")
iceoryx2_header === nothing && error("iceoryx2.h not found under: $include_dir")

# wrapper generator options
options = load_options(joinpath(@__DIR__, "generator.toml"))
generated_dir = abspath(
    get(
    ENV,
    "IOX2_GENERATED_DIR",
    joinpath(@__DIR__, "..", "src", "generated")
),
)
mkpath(generated_dir)
options["general"]["output_file_path"] = joinpath(generated_dir, "Iceoryx2FFI.jl")

args = get_default_args()
push!(args, "-I$include_dir")

headers = [iceoryx2_header]

# create context
ctx = create_context(headers, args, options)

# run generator
build!(ctx)

ffi_path = joinpath(generated_dir, "Iceoryx2FFI.jl")
handles_path = joinpath(generated_dir, "handles.jl")
errors_path = joinpath(generated_dir, "errors.jl")
wrappers_path = joinpath(generated_dir, "wrappers.jl")
wrapper_spec = joinpath(@__DIR__, "wrapper-spec.toml")

ignore_owning = Set([
    "node",
    "port_factory_pub_sub",
    "port_factory_request_response",
    "port_factory_event",
    "port_factory_blackboard",
    "port_factory_progressive_pub_sub",
    "publisher",
    "progressive_publisher",
    "progressive_subscriber",
    "progressive_sample",
    "progressive_sample_mut",
    "progressive_sample_mut_uninit",
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
    "waitset_attachment_id",
    "waitset_guard",
    "unique_client_id",
    "unique_listener_id",
    "unique_node_id",
    "unique_notifier_id",
    "unique_publisher_id",
    "unique_reader_id",
    "unique_server_id",
    "unique_subscriber_id",
    "unique_writer_id"
])

ffi_text = read(ffi_path, String)
generate_handles(ffi_text, handles_path; ignore_owning)
generate_errors(ffi_text, errors_path)
generate_simple_wrappers(wrapper_spec, wrappers_path)
inline_ffi_wrappers!(ffi_path)
