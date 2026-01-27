# Builder and factory helpers.

@inline function _require_valid(handle, what::AbstractString)
    handle != _IOX2_NULL || throw(ArgumentError("invalid $what"))
    return nothing
end

@inline function _service_type(value)
    if value isa Iceoryx2FFI.iox2_service_type_e
        return value
    elseif value isa Symbol
        if value === :ipc
            return Iceoryx2FFI.iox2_service_type_e_IPC
        elseif value === :local
            return Iceoryx2FFI.iox2_service_type_e_LOCAL
        end
    end
    throw(ArgumentError("unsupported service_type: $value"))
end

mutable struct NodeBuilder
    handle::Iceoryx2FFI.iox2_node_builder_h
    storage::Ptr{Iceoryx2FFI.iox2_node_builder_t}
end

function _free_node_builder_storage!(builder::NodeBuilder)
    if builder.storage != _IOX2_NULL
        Libc.free(builder.storage)
        builder.storage = Ptr{Iceoryx2FFI.iox2_node_builder_t}(_IOX2_NULL)
    end
    return nothing
end

function _finalize_node_builder(builder::NodeBuilder)
    builder.handle = _IOX2_NULL
    _free_node_builder_storage!(builder)
    return nothing
end

function NodeBuilder()
    storage = Ptr{Iceoryx2FFI.iox2_node_builder_t}(Libc.malloc(sizeof(Iceoryx2FFI.iox2_node_builder_t)))
    storage == _IOX2_NULL && throw(OutOfMemoryError())
    handle = Iceoryx2FFI.iox2_node_builder_new(storage)
    builder = NodeBuilder(handle, storage)
    finalizer(_finalize_node_builder, builder)
    return builder
end

@inline unsafe_handle(builder::NodeBuilder) = builder.handle
@inline Base.isvalid(builder::NodeBuilder) = builder.handle != _IOX2_NULL

function name!(builder::NodeBuilder, name::NodeName)
    _require_valid(builder.handle, "node builder")
    ptr = _node_name_ptr(unsafe_handle(name))
    Iceoryx2FFI.iox2_node_builder_set_name(Ref{Iceoryx2FFI.iox2_node_builder_h}(builder.handle), ptr)
    invalidate!(name)
    return builder
end

function name!(builder::NodeBuilder, name::NodeNameView)
    _require_valid(builder.handle, "node builder")
    Iceoryx2FFI.iox2_node_builder_set_name(Ref{Iceoryx2FFI.iox2_node_builder_h}(builder.handle), unsafe_handle(name))
    return builder
end

function name!(builder::NodeBuilder, name::AbstractString)
    return name!(builder, NodeName(name))
end

function config!(builder::NodeBuilder, config::Config)
    _require_valid(builder.handle, "node builder")
    Iceoryx2FFI.iox2_node_builder_set_config(Ref{Iceoryx2FFI.iox2_node_builder_h}(builder.handle), Ref{Iceoryx2FFI.iox2_config_h}(unsafe_handle(config)))
    return builder
end

function config!(builder::NodeBuilder, config::ConfigRef)
    _require_valid(builder.handle, "node builder")
    Iceoryx2FFI.iox2_node_builder_set_config(Ref{Iceoryx2FFI.iox2_node_builder_h}(builder.handle), unsafe_handle(config))
    return builder
end

function signal_handling_mode!(builder::NodeBuilder, mode::Iceoryx2FFI.iox2_signal_handling_mode_e)
    _require_valid(builder.handle, "node builder")
    Iceoryx2FFI.iox2_node_builder_set_signal_handling_mode(Ref{Iceoryx2FFI.iox2_node_builder_h}(builder.handle), mode)
    return builder
end

function create(builder::NodeBuilder; service_type::Union{Symbol, Iceoryx2FFI.iox2_service_type_e}=:ipc)
    _require_valid(builder.handle, "node builder")
    handle_ref = Ref{Iceoryx2FFI.iox2_node_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_node_builder_create(builder.handle, C_NULL, _service_type(service_type), handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_node_creation_failure_e)
    builder.handle = _IOX2_NULL
    _free_node_builder_storage!(builder)
    return Node(handle_ref[])
end

function create(f::Function, builder::NodeBuilder; service_type::Union{Symbol, Iceoryx2FFI.iox2_service_type_e}=:ipc)
    node = create(builder; service_type)
    try
        return f(node)
    finally
        close(node)
    end
end

mutable struct ServiceBuilder
    handle::Iceoryx2FFI.iox2_service_builder_h
    storage::Ptr{Iceoryx2FFI.iox2_service_builder_t}
    keepalive::Node
end

function _free_service_builder_storage!(builder::ServiceBuilder)
    if builder.storage != _IOX2_NULL
        Libc.free(builder.storage)
        builder.storage = Ptr{Iceoryx2FFI.iox2_service_builder_t}(_IOX2_NULL)
    end
    return nothing
end

function _finalize_service_builder(builder::ServiceBuilder)
    builder.handle = _IOX2_NULL
    _free_service_builder_storage!(builder)
    return nothing
end

function service_builder(node::Node, name::ServiceName)
    _require_valid(unsafe_handle(node), "node")
    storage = Ptr{Iceoryx2FFI.iox2_service_builder_t}(Libc.malloc(sizeof(Iceoryx2FFI.iox2_service_builder_t)))
    storage == _IOX2_NULL && throw(OutOfMemoryError())
    node_ref = Ref{Iceoryx2FFI.iox2_node_h}(unsafe_handle(node))
    ptr = _service_name_ptr(unsafe_handle(name))
    handle = Iceoryx2FFI.iox2_node_service_builder(node_ref, storage, ptr)
    invalidate!(name)
    builder = ServiceBuilder(handle, storage, node)
    finalizer(_finalize_service_builder, builder)
    return builder
end

function service_builder(node::Node, name::ServiceNameView)
    _require_valid(unsafe_handle(node), "node")
    storage = Ptr{Iceoryx2FFI.iox2_service_builder_t}(Libc.malloc(sizeof(Iceoryx2FFI.iox2_service_builder_t)))
    storage == _IOX2_NULL && throw(OutOfMemoryError())
    node_ref = Ref{Iceoryx2FFI.iox2_node_h}(unsafe_handle(node))
    handle = Iceoryx2FFI.iox2_node_service_builder(node_ref, storage, unsafe_handle(name))
    builder = ServiceBuilder(handle, storage, node)
    finalizer(_finalize_service_builder, builder)
    return builder
end

function service_builder(node::Node, name::AbstractString)
    return service_builder(node, ServiceName(name))
end

@inline unsafe_handle(builder::ServiceBuilder) = builder.handle
@inline Base.isvalid(builder::ServiceBuilder) = builder.handle != _IOX2_NULL

mutable struct EventServiceBuilder
    handle::Iceoryx2FFI.iox2_service_builder_event_h
    storage::Ptr{Iceoryx2FFI.iox2_service_builder_t}
    keepalive::Node
end

mutable struct PubSubServiceBuilder
    handle::Iceoryx2FFI.iox2_service_builder_pub_sub_h
    storage::Ptr{Iceoryx2FFI.iox2_service_builder_t}
    keepalive::Node
end

mutable struct RequestResponseServiceBuilder
    handle::Iceoryx2FFI.iox2_service_builder_request_response_h
    storage::Ptr{Iceoryx2FFI.iox2_service_builder_t}
    keepalive::Node
end

mutable struct BlackboardCreatorBuilder
    handle::Iceoryx2FFI.iox2_service_builder_blackboard_creator_h
    storage::Ptr{Iceoryx2FFI.iox2_service_builder_t}
    keepalive::Node
end

mutable struct BlackboardOpenerBuilder
    handle::Iceoryx2FFI.iox2_service_builder_blackboard_opener_h
    storage::Ptr{Iceoryx2FFI.iox2_service_builder_t}
    keepalive::Node
end

function _finalize_service_builder_variant(builder)
    if builder.storage != _IOX2_NULL
        Libc.free(builder.storage)
        builder.storage = Ptr{Iceoryx2FFI.iox2_service_builder_t}(_IOX2_NULL)
    end
    return nothing
end

function event(builder::ServiceBuilder)
    _require_valid(builder.handle, "service builder")
    handle = Iceoryx2FFI.iox2_service_builder_event(builder.handle)
    builder.handle = _IOX2_NULL
    storage = builder.storage
    builder.storage = Ptr{Iceoryx2FFI.iox2_service_builder_t}(_IOX2_NULL)
    variant = EventServiceBuilder(handle, storage, builder.keepalive)
    finalizer(_finalize_service_builder_variant, variant)
    return variant
end

function pub_sub(builder::ServiceBuilder)
    _require_valid(builder.handle, "service builder")
    handle = Iceoryx2FFI.iox2_service_builder_pub_sub(builder.handle)
    builder.handle = _IOX2_NULL
    storage = builder.storage
    builder.storage = Ptr{Iceoryx2FFI.iox2_service_builder_t}(_IOX2_NULL)
    variant = PubSubServiceBuilder(handle, storage, builder.keepalive)
    finalizer(_finalize_service_builder_variant, variant)
    return variant
end

function request_response(builder::ServiceBuilder)
    _require_valid(builder.handle, "service builder")
    handle = Iceoryx2FFI.iox2_service_builder_request_response(builder.handle)
    builder.handle = _IOX2_NULL
    storage = builder.storage
    builder.storage = Ptr{Iceoryx2FFI.iox2_service_builder_t}(_IOX2_NULL)
    variant = RequestResponseServiceBuilder(handle, storage, builder.keepalive)
    finalizer(_finalize_service_builder_variant, variant)
    return variant
end

function blackboard_creator(builder::ServiceBuilder)
    _require_valid(builder.handle, "service builder")
    handle = Iceoryx2FFI.iox2_service_builder_blackboard_creator(builder.handle)
    builder.handle = _IOX2_NULL
    storage = builder.storage
    builder.storage = Ptr{Iceoryx2FFI.iox2_service_builder_t}(_IOX2_NULL)
    variant = BlackboardCreatorBuilder(handle, storage, builder.keepalive)
    finalizer(_finalize_service_builder_variant, variant)
    return variant
end

function blackboard_opener(builder::ServiceBuilder)
    _require_valid(builder.handle, "service builder")
    handle = Iceoryx2FFI.iox2_service_builder_blackboard_opener(builder.handle)
    builder.handle = _IOX2_NULL
    storage = builder.storage
    builder.storage = Ptr{Iceoryx2FFI.iox2_service_builder_t}(_IOX2_NULL)
    variant = BlackboardOpenerBuilder(handle, storage, builder.keepalive)
    finalizer(_finalize_service_builder_variant, variant)
    return variant
end
