# Node helpers.

@inline function name(node::Node)
    _require_valid(unsafe_handle(node), "node")
    ptr = Iceoryx2FFI.iox2_node_name(Ref{Iceoryx2FFI.iox2_node_h}(unsafe_handle(node)))
    return NodeNameView(ptr)
end

@inline function signal_handling_mode(node::Node)
    _require_valid(unsafe_handle(node), "node")
    return Iceoryx2FFI.iox2_node_signal_handling_mode(Ref{Iceoryx2FFI.iox2_node_h}(unsafe_handle(node)))
end

function id(node::Node; service_type::Union{Symbol, Iceoryx2FFI.iox2_service_type_e} = :ipc)
    _require_valid(unsafe_handle(node), "node")
    ptr = Iceoryx2FFI.iox2_node_id(Ref{Iceoryx2FFI.iox2_node_h}(unsafe_handle(node)), _service_type(service_type))
    handle_ref = Ref{Iceoryx2FFI.iox2_node_id_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_node_id_clone_from_ptr(C_NULL, ptr, handle_ref)
    return NodeId(handle_ref[])
end

function to_owned(node_id::NodeIdView)
    handle_ref = Ref{Iceoryx2FFI.iox2_node_id_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_node_id_clone_from_ptr(C_NULL, unsafe_handle(node_id), handle_ref)
    return NodeId(handle_ref[])
end

@inline function value_high(node_id::NodeId)
    return Iceoryx2FFI.iox2_node_id_value_high(Ref{Iceoryx2FFI.iox2_node_id_h}(unsafe_handle(node_id)))
end

@inline function value_low(node_id::NodeId)
    return Iceoryx2FFI.iox2_node_id_value_low(Ref{Iceoryx2FFI.iox2_node_id_h}(unsafe_handle(node_id)))
end

@inline function pid(node_id::NodeId)
    return Iceoryx2FFI.iox2_node_id_pid(Ref{Iceoryx2FFI.iox2_node_id_h}(unsafe_handle(node_id)))
end

function creation_time(node_id::NodeId)
    seconds = Ref{UInt64}(0)
    nanos = Ref{UInt32}(0)
    Iceoryx2FFI.iox2_node_id_creation_time(
        Ref{Iceoryx2FFI.iox2_node_id_h}(unsafe_handle(node_id)),
        seconds,
        nanos,
    )
    return seconds[], nanos[]
end

@inline function Base.:(==)(lhs::NodeId, rhs::NodeId)
    return value_high(lhs) == value_high(rhs) && value_low(lhs) == value_low(rhs)
end

@inline function Base.isless(lhs::NodeId, rhs::NodeId)
    lhs_high = value_high(lhs)
    rhs_high = value_high(rhs)
    lhs_high == rhs_high && return value_low(lhs) < value_low(rhs)
    return lhs_high < rhs_high
end
