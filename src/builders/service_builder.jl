mutable struct ServiceBuilder{S}
    handle::Iceoryx2FFI.iox2_service_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_service_builder_t}
    keepalive::Node{S}
    function ServiceBuilder{S}(handle, storage, keepalive) where {S}
        obj = new{S}(handle, storage, keepalive)
        finalizer(_finalize_service_builder, obj)
        return obj
    end
end

function _finalize_service_builder(builder::ServiceBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

function service_builder(node::Node{S}, name::ServiceName) where {S}
    _require_valid(unsafe_handle(node), "node")
    storage = Ref{Iceoryx2FFI.iox2_service_builder_t}()
    node_ref = Ref{Iceoryx2FFI.iox2_node_h}(unsafe_handle(node))
    ptr = _service_name_ptr(unsafe_handle(name))
    handle = Iceoryx2FFI.iox2_node_service_builder(node_ref, storage, ptr)
    invalidate!(name)
    return ServiceBuilder{S}(handle, storage, node)
end

function service_builder(node::Node{S}, name::ServiceNameView) where {S}
    _require_valid(unsafe_handle(node), "node")
    storage = Ref{Iceoryx2FFI.iox2_service_builder_t}()
    node_ref = Ref{Iceoryx2FFI.iox2_node_h}(unsafe_handle(node))
    handle = Iceoryx2FFI.iox2_node_service_builder(node_ref, storage, unsafe_handle(name))
    return ServiceBuilder{S}(handle, storage, node)
end

function service_builder(node::Node{S}, name::AbstractString) where {S}
    return service_builder(node, ServiceName(name))
end

@inline unsafe_handle(builder::ServiceBuilder) = builder.handle
@inline Base.isvalid(builder::ServiceBuilder) = builder.handle != _IOX2_NULL
