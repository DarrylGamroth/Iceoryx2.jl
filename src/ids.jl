# Unique ID helpers.

abstract type AbstractUniquePortId end

struct NodeId
    raw::Iceoryx2FFI.iox2_unique_node_id_t
end

struct UniqueClientId <: AbstractUniquePortId
    value::UInt128
end

struct UniqueListenerId <: AbstractUniquePortId
    value::UInt128
end

struct UniqueNotifierId <: AbstractUniquePortId
    value::UInt128
end

struct UniquePublisherId <: AbstractUniquePortId
    value::UInt128
end

struct UniqueReaderId <: AbstractUniquePortId
    value::UInt128
end

struct UniqueServerId <: AbstractUniquePortId
    value::UInt128
end

struct UniqueSubscriberId <: AbstractUniquePortId
    value::UInt128
end

struct UniqueWriterId <: AbstractUniquePortId
    value::UInt128
end

@inline Base.isvalid(::AbstractUniquePortId) = true
@inline Base.close(::AbstractUniquePortId) = nothing
@inline Base.isvalid(::NodeId) = true
@inline Base.close(::NodeId) = nothing

@inline function _unique_port_id(
        ::Type{I},
        ::Type{R},
        ::Type{H},
        producer::P,
        value_fn::V,
        drop_fn::D,
        source::S
) where {I <: AbstractUniquePortId, R, H, P, V, D, S}
    storage = Ref{R}()
    handle = Ref{H}(_IOX2_NULL)
    value = Ref{UInt128}(0)
    GC.@preserve storage handle value begin
        producer(source, storage, handle)
        value_fn(handle[], Ptr{UInt8}(Base.unsafe_convert(Ptr{UInt128}, value)), sizeof(UInt128))
        drop_fn(handle[])
    end
    return I(value[])
end

@inline _unique_id_bytes(value::UInt128) = reinterpret(NTuple{sizeof(UInt128), UInt8}, value)

@inline function _node_id_from_ptr(ptr::Iceoryx2FFI.iox2_unique_node_id_ptr)
    storage = Ref{Iceoryx2FFI.iox2_unique_node_id_t}()
    handle = Ref{Iceoryx2FFI.iox2_unique_node_id_h}(_IOX2_NULL)
    raw = GC.@preserve storage handle begin
        Iceoryx2FFI.iox2_unique_node_id_clone_from_ptr(storage, ptr, handle)
        value = storage[]
        Iceoryx2FFI.iox2_unique_node_id_drop(handle[])
        value
    end
    return NodeId(raw)
end

"""
    to_owned(node_id::NodeIdView) -> NodeId

Copy a borrowed node ID into an allocation-free value.
"""
@inline to_owned(node_id::NodeIdView) = _node_id_from_ptr(unsafe_handle(node_id))

@inline function _node_id_call(function_::F, node_id::NodeId, args...) where {F}
    storage = Ref(node_id.raw)
    ptr = Base.unsafe_convert(Ptr{Iceoryx2FFI.iox2_unique_node_id_t}, storage)
    handle = Ref{Iceoryx2FFI.iox2_unique_node_id_h}(
        convert(Iceoryx2FFI.iox2_unique_node_id_h, ptr),
    )
    GC.@preserve storage handle begin
        return function_(handle, args...)
    end
end

# The concrete Unique*Id helpers (bytes/id/==/isless) are generated in src/generated/wrappers.jl.
