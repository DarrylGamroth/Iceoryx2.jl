mutable struct NodeBuilder{S}
    handle::Iceoryx2FFI.iox2_node_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_node_builder_t}
    name_handle::Iceoryx2FFI.iox2_node_name_h
    config_ptr::Iceoryx2FFI.iox2_config_h_ref
    config_storage::Base.RefValue{Iceoryx2FFI.iox2_config_h}
    config_keepalive::Union{Config,Nothing}
    signal_handling_mode::Iceoryx2FFI.iox2_signal_handling_mode_e
    has_signal_handling_mode::Bool
    function NodeBuilder{S}(handle, storage, name_handle, config_ptr, config_storage, config_keepalive, signal_handling_mode, has_signal_handling_mode) where {S}
        obj = new{S}(handle, storage, name_handle, config_ptr, config_storage, config_keepalive, signal_handling_mode, has_signal_handling_mode)
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

function NodeBuilder(service_type::ServiceType = ServiceType.IPC)
    storage = Ref{Iceoryx2FFI.iox2_node_builder_t}()
    handle = Iceoryx2FFI.iox2_node_builder_new(storage)
    config_storage = Ref{Iceoryx2FFI.iox2_config_h}(_IOX2_NULL)
    return NodeBuilder{service_type}(
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

function create(builder::NodeBuilder{S}) where {S}
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
    ret = Iceoryx2FFI.iox2_node_builder_create(builder.handle, C_NULL, _service_type(S), handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_node_creation_failure_e)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return Node{S}(handle_ref[])
end

function create(f::Function, builder::NodeBuilder{S}) where {S}
    node = create(builder)
    try
        return f(node)
    finally
        close(node)
    end
end
