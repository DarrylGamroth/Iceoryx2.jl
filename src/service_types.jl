# Service type and core typed handles.

"""
    ServiceType

Service backend used for discovery and transport. Use `ServiceType.IPC` for
inter-process communication and `ServiceType.LOCAL` for process-local services.
"""
@enum ServiceType::UInt32 begin
    LOCAL = UInt32(Iceoryx2FFI.iox2_service_type_e_LOCAL)
    IPC = UInt32(Iceoryx2FFI.iox2_service_type_e_IPC)
end

@inline _service_type(value::ServiceType) = Iceoryx2FFI.iox2_service_type_e(UInt32(value))

@inline function Base.getproperty(::Type{ServiceType}, name::Symbol)
    if name === :IPC
        return IPC
    elseif name === :LOCAL
        return LOCAL
    end
    return getfield(ServiceType, name)
end

"""
    Node{S}

Handle to an iceoryx2 node for service type `S`.

Nodes own native resources and must be released with `close(node)` when no
longer needed. `S` is a `ServiceType` value baked into the type for
compile-time dispatch.
"""
mutable struct Node{S}
    handle::Iceoryx2FFI.iox2_node_h
    function Node{S}(handle::Iceoryx2FFI.iox2_node_h) where {S}
        obj = new{S}(handle)
        finalizer(Base.close, obj)
        return obj
    end
end

@inline unsafe_handle(obj::Node) = obj.handle
@inline Base.isvalid(obj::Node) = obj.handle != _IOX2_NULL
@inline invalidate!(obj::Node) = (obj.handle = _IOX2_NULL)

function Base.close(obj::Node)
    if obj.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_node_drop(obj.handle)
        obj.handle = _IOX2_NULL
    end
    return nothing
end

"""
    Waitset{S}

Waitset for service type `S`. Use `WaitsetBuilder(service_type)` to configure
and create a waitset, then call `wait_and_process*` to run callbacks.
"""
mutable struct Waitset{S}
    handle::Iceoryx2FFI.iox2_waitset_h
    function Waitset{S}(handle::Iceoryx2FFI.iox2_waitset_h) where {S}
        obj = new{S}(handle)
        finalizer(Base.close, obj)
        return obj
    end
end

@inline unsafe_handle(obj::Waitset) = obj.handle
@inline Base.isvalid(obj::Waitset) = obj.handle != _IOX2_NULL
@inline invalidate!(obj::Waitset) = (obj.handle = _IOX2_NULL)

function Base.close(obj::Waitset)
    if obj.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_waitset_drop(obj.handle)
        obj.handle = _IOX2_NULL
    end
    return nothing
end

"""
    WaitsetBuilder{S}

Builder for `Waitset{S}`. Construct with `WaitsetBuilder(service_type)` and
configure signal handling before calling `create`.
"""
mutable struct WaitsetBuilder{S}
    handle::Iceoryx2FFI.iox2_waitset_builder_h
    function WaitsetBuilder{S}(handle::Iceoryx2FFI.iox2_waitset_builder_h) where {S}
        obj = new{S}(handle)
        finalizer(Base.close, obj)
        return obj
    end
end

@inline unsafe_handle(obj::WaitsetBuilder) = obj.handle
@inline Base.isvalid(obj::WaitsetBuilder) = obj.handle != _IOX2_NULL
@inline invalidate!(obj::WaitsetBuilder) = (obj.handle = _IOX2_NULL)

function Base.close(obj::WaitsetBuilder)
    if obj.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_waitset_builder_drop(obj.handle)
        obj.handle = _IOX2_NULL
    end
    return nothing
end
