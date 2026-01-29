# Builder and factory helpers.

@inline function _require_valid(handle, what::AbstractString)
    handle != _IOX2_NULL || throw(ArgumentError("invalid $what"))
    return nothing
end

@inline _service_type(value::Iceoryx2FFI.iox2_service_type_e) = value

@inline function _service_type(value::Symbol)
    if value === :ipc
        return Iceoryx2FFI.iox2_service_type_e_IPC
    elseif value === :local
        return Iceoryx2FFI.iox2_service_type_e_LOCAL
    end
    throw(ArgumentError("unsupported service_type: $value"))
end

@inline _service_type(value) = throw(ArgumentError("unsupported service_type: $value"))

mutable struct NodeBuilder
    handle::Iceoryx2FFI.iox2_node_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_node_builder_t}
    name_handle::Iceoryx2FFI.iox2_node_name_h
    config_ptr::Iceoryx2FFI.iox2_config_h_ref
    config_storage::Base.RefValue{Iceoryx2FFI.iox2_config_h}
    config_keepalive::Union{Config,Nothing}
    signal_handling_mode::Iceoryx2FFI.iox2_signal_handling_mode_e
    has_signal_handling_mode::Bool
    function NodeBuilder(handle, storage, name_handle, config_ptr, config_storage, config_keepalive, signal_handling_mode, has_signal_handling_mode)
        obj = new(handle, storage, name_handle, config_ptr, config_storage, config_keepalive, signal_handling_mode, has_signal_handling_mode)
        finalizer(_finalize_node_builder, obj)
        return obj
    end
end

function _finalize_node_builder(builder::NodeBuilder)
    if builder.name_handle != _IOX2_NULL
        Iceoryx2FFI.iox2_node_name_drop(builder.name_handle)
        builder.name_handle = _IOX2_NULL
    end
    if builder.config_keepalive !== nothing
        close(builder.config_keepalive)
        builder.config_keepalive = nothing
    end
    builder.config_ptr = _IOX2_NULL
    builder.config_storage = Ref{Iceoryx2FFI.iox2_config_h}(_IOX2_NULL)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

function NodeBuilder()
    storage = Ref{Iceoryx2FFI.iox2_node_builder_t}()
    handle = Iceoryx2FFI.iox2_node_builder_new(storage)
    config_storage = Ref{Iceoryx2FFI.iox2_config_h}(_IOX2_NULL)
    return NodeBuilder(
        handle,
        storage,
        _IOX2_NULL,
        _IOX2_NULL,
        config_storage,
        nothing,
        Iceoryx2FFI.iox2_signal_handling_mode_e_HANDLE_TERMINATION_REQUESTS,
        false,
    )
end

@inline unsafe_handle(builder::NodeBuilder) = builder.handle
@inline Base.isvalid(builder::NodeBuilder) = builder.handle != _IOX2_NULL

function _clear_node_builder_name!(builder::NodeBuilder)
    if builder.name_handle != _IOX2_NULL
        Iceoryx2FFI.iox2_node_name_drop(builder.name_handle)
        builder.name_handle = _IOX2_NULL
    end
    return nothing
end

function _clear_node_builder_config!(builder::NodeBuilder)
    if builder.config_keepalive !== nothing
        close(builder.config_keepalive)
        builder.config_keepalive = nothing
    end
    builder.config_ptr = _IOX2_NULL
    builder.config_storage[] = _IOX2_NULL
    return nothing
end

function name!(builder::NodeBuilder, name::NodeName)
    _require_valid(builder.handle, "node builder")
    _clear_node_builder_name!(builder)
    builder.name_handle = unsafe_handle(name)
    invalidate!(name)
    return builder
end

function name!(builder::NodeBuilder, name::NodeNameView)
    _require_valid(builder.handle, "node builder")
    _clear_node_builder_name!(builder)
    Iceoryx2FFI.iox2_node_builder_set_name(Ref{Iceoryx2FFI.iox2_node_builder_h}(builder.handle), unsafe_handle(name))
    return builder
end

function name!(builder::NodeBuilder, name::AbstractString)
    return name!(builder, NodeName(name))
end

function config!(builder::NodeBuilder, config::Config)
    _require_valid(builder.handle, "node builder")
    _clear_node_builder_config!(builder)
    cloned = config_clone(config)
    builder.config_keepalive = cloned
    builder.config_storage[] = unsafe_handle(cloned)
    builder.config_ptr = Base.unsafe_convert(Iceoryx2FFI.iox2_config_h_ref, builder.config_storage)
    return builder
end

function config!(builder::NodeBuilder, config::ConfigRef)
    _require_valid(builder.handle, "node builder")
    _clear_node_builder_config!(builder)
    builder.config_ptr = unsafe_handle(config)
    return builder
end

function signal_handling_mode!(builder::NodeBuilder, mode::Iceoryx2FFI.iox2_signal_handling_mode_e)
    _require_valid(builder.handle, "node builder")
    builder.signal_handling_mode = mode
    builder.has_signal_handling_mode = true
    return builder
end

function create(builder::NodeBuilder; service_type::Union{Symbol, Iceoryx2FFI.iox2_service_type_e}=:ipc)
    _require_valid(builder.handle, "node builder")
    if builder.name_handle != _IOX2_NULL
        ptr = _node_name_ptr(builder.name_handle)
        Iceoryx2FFI.iox2_node_builder_set_name(Ref{Iceoryx2FFI.iox2_node_builder_h}(builder.handle), ptr)
        Iceoryx2FFI.iox2_node_name_drop(builder.name_handle)
        builder.name_handle = _IOX2_NULL
    end
    if builder.config_ptr != _IOX2_NULL
        Iceoryx2FFI.iox2_node_builder_set_config(Ref{Iceoryx2FFI.iox2_node_builder_h}(builder.handle), builder.config_ptr)
        _clear_node_builder_config!(builder)
    end
    if builder.has_signal_handling_mode
        Iceoryx2FFI.iox2_node_builder_set_signal_handling_mode(Ref{Iceoryx2FFI.iox2_node_builder_h}(builder.handle), builder.signal_handling_mode)
        builder.has_signal_handling_mode = false
    end
    handle_ref = Ref{Iceoryx2FFI.iox2_node_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_node_builder_create(builder.handle, C_NULL, _service_type(service_type), handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_node_creation_failure_e)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
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
    storage::_StorageRef{Iceoryx2FFI.iox2_service_builder_t}
    keepalive::Node
    function ServiceBuilder(handle, storage, keepalive)
        obj = new(handle, storage, keepalive)
        finalizer(_finalize_service_builder, obj)
        return obj
    end
end

function _finalize_service_builder(builder::ServiceBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

function service_builder(node::Node, name::ServiceName)
    _require_valid(unsafe_handle(node), "node")
    storage = Ref{Iceoryx2FFI.iox2_service_builder_t}()
    node_ref = Ref{Iceoryx2FFI.iox2_node_h}(unsafe_handle(node))
    ptr = _service_name_ptr(unsafe_handle(name))
    handle = Iceoryx2FFI.iox2_node_service_builder(node_ref, storage, ptr)
    invalidate!(name)
    return ServiceBuilder(handle, storage, node)
end

function service_builder(node::Node, name::ServiceNameView)
    _require_valid(unsafe_handle(node), "node")
    storage = Ref{Iceoryx2FFI.iox2_service_builder_t}()
    node_ref = Ref{Iceoryx2FFI.iox2_node_h}(unsafe_handle(node))
    handle = Iceoryx2FFI.iox2_node_service_builder(node_ref, storage, unsafe_handle(name))
    return ServiceBuilder(handle, storage, node)
end

function service_builder(node::Node, name::AbstractString)
    return service_builder(node, ServiceName(name))
end

@inline unsafe_handle(builder::ServiceBuilder) = builder.handle
@inline Base.isvalid(builder::ServiceBuilder) = builder.handle != _IOX2_NULL

mutable struct EventServiceBuilder
    handle::Iceoryx2FFI.iox2_service_builder_event_h
    storage::_StorageRef{Iceoryx2FFI.iox2_service_builder_t}
    keepalive::Node
    function EventServiceBuilder(handle, storage, keepalive)
        obj = new(handle, storage, keepalive)
        finalizer(_finalize_service_builder_variant, obj)
        return obj
    end
end

mutable struct PubSubServiceBuilder{T,UH}
    handle::Iceoryx2FFI.iox2_service_builder_pub_sub_h
    storage::_StorageRef{Iceoryx2FFI.iox2_service_builder_t}
    keepalive::Node
    function PubSubServiceBuilder{T,UH}(handle, storage, keepalive) where {T,UH}
        obj = new{T,UH}(handle, storage, keepalive)
        finalizer(_finalize_service_builder_variant, obj)
        return obj
    end
end

mutable struct RequestResponseServiceBuilder{Req,Resp,ReqH,RespH}
    handle::Iceoryx2FFI.iox2_service_builder_request_response_h
    storage::_StorageRef{Iceoryx2FFI.iox2_service_builder_t}
    keepalive::Node
    function RequestResponseServiceBuilder{Req,Resp,ReqH,RespH}(handle, storage, keepalive) where {Req,Resp,ReqH,RespH}
        obj = new{Req,Resp,ReqH,RespH}(handle, storage, keepalive)
        finalizer(_finalize_service_builder_variant, obj)
        return obj
    end
end

mutable struct BlackboardCreatorBuilder{K}
    handle::Iceoryx2FFI.iox2_service_builder_blackboard_creator_h
    storage::_StorageRef{Iceoryx2FFI.iox2_service_builder_t}
    keepalive::Node
    values::Vector{Any}
    key_eq_cmp::Union{Nothing, Ptr{Cvoid}}
    key_eq_keepalive::Union{Nothing, Base.CFunction}
    function BlackboardCreatorBuilder{K}(handle, storage, keepalive, values, key_eq_cmp, key_eq_keepalive) where {K}
        obj = new{K}(handle, storage, keepalive, values, key_eq_cmp, key_eq_keepalive)
        finalizer(_finalize_service_builder_variant, obj)
        return obj
    end
end

mutable struct BlackboardOpenerBuilder{K}
    handle::Iceoryx2FFI.iox2_service_builder_blackboard_opener_h
    storage::_StorageRef{Iceoryx2FFI.iox2_service_builder_t}
    keepalive::Node
    function BlackboardOpenerBuilder{K}(handle, storage, keepalive) where {K}
        obj = new{K}(handle, storage, keepalive)
        finalizer(_finalize_service_builder_variant, obj)
        return obj
    end
end

function _finalize_service_builder_variant(builder)
    builder.storage = nothing
    return nothing
end

function _finalize_service_builder_variant(builder::BlackboardCreatorBuilder)
    builder.storage = nothing
    builder.key_eq_cmp = nothing
    builder.key_eq_keepalive = nothing
    empty!(builder.values)
    return nothing
end

function _finalize_service_builder_variant(builder::BlackboardOpenerBuilder)
    builder.storage = nothing
    return nothing
end

function _finalize_service_builder_variant(builder::PubSubServiceBuilder)
    builder.storage = nothing
    return nothing
end

function _finalize_service_builder_variant(builder::RequestResponseServiceBuilder)
    builder.storage = nothing
    return nothing
end

function event(builder::ServiceBuilder)
    _require_valid(builder.handle, "service builder")
    handle = Iceoryx2FFI.iox2_service_builder_event(builder.handle)
    builder.handle = _IOX2_NULL
    storage = builder.storage
    builder.storage = nothing
    return EventServiceBuilder(handle, storage, builder.keepalive)
end

function publish_subscribe(
    builder::ServiceBuilder,
    ::Type{T};
    variant::Union{Symbol, Iceoryx2FFI.iox2_type_variant_e} = :fixed,
) where {T}
    _require_valid(builder.handle, "service builder")
    handle = Iceoryx2FFI.iox2_service_builder_pub_sub(builder.handle)
    builder.handle = _IOX2_NULL
    storage = builder.storage
    builder.storage = nothing
    pub_builder = PubSubServiceBuilder{T,Nothing}(handle, storage, builder.keepalive)
    _set_payload_type!(pub_builder, T; variant)
    return pub_builder
end

function request_response(
    builder::ServiceBuilder,
    ::Type{Req},
    ::Type{Resp};
    request_variant::Union{Symbol, Iceoryx2FFI.iox2_type_variant_e} = :fixed,
    response_variant::Union{Symbol, Iceoryx2FFI.iox2_type_variant_e} = :fixed,
) where {Req,Resp}
    _require_valid(builder.handle, "service builder")
    handle = Iceoryx2FFI.iox2_service_builder_request_response(builder.handle)
    builder.handle = _IOX2_NULL
    storage = builder.storage
    builder.storage = nothing
    rr_builder = RequestResponseServiceBuilder{Req,Resp,Nothing,Nothing}(handle, storage, builder.keepalive)
    _set_request_payload_type!(rr_builder, Req; variant = request_variant)
    _set_response_payload_type!(rr_builder, Resp; variant = response_variant)
    return rr_builder
end

function blackboard_creator(builder::ServiceBuilder, ::Type{K}) where {K}
    _require_valid(builder.handle, "service builder")
    handle = Iceoryx2FFI.iox2_service_builder_blackboard_creator(builder.handle)
    builder.handle = _IOX2_NULL
    storage = builder.storage
    builder.storage = nothing
    bb_builder = BlackboardCreatorBuilder{K}(handle, storage, builder.keepalive, Any[], nothing, nothing)
    _set_key_type!(bb_builder, K)
    key_eq_comparison!(bb_builder)
    return bb_builder
end

function blackboard_opener(builder::ServiceBuilder, ::Type{K}) where {K}
    _require_valid(builder.handle, "service builder")
    handle = Iceoryx2FFI.iox2_service_builder_blackboard_opener(builder.handle)
    builder.handle = _IOX2_NULL
    storage = builder.storage
    builder.storage = nothing
    bb_builder = BlackboardOpenerBuilder{K}(handle, storage, builder.keepalive)
    _set_key_type!(bb_builder, K)
    return bb_builder
end
