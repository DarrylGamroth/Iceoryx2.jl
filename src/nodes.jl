# Node helpers.

"""
    name(node::Node) -> NodeNameView

Return a view of the node name. The view is valid while the node is alive.
Use `string(name(node))` to allocate a `String`.
"""
@inline function name(node::Node)
    _require_valid(unsafe_handle(node), "node")
    ptr = Iceoryx2FFI.iox2_node_name(Ref{Iceoryx2FFI.iox2_node_h}(unsafe_handle(node)))
    return NodeNameView(ptr)
end

"""
    signal_handling_mode(node::Node)

Return the node's signal handling mode.
"""
@inline function signal_handling_mode(node::Node)
    _require_valid(unsafe_handle(node), "node")
    return Iceoryx2FFI.iox2_node_signal_handling_mode(Ref{Iceoryx2FFI.iox2_node_h}(unsafe_handle(node)))
end

"""
    wait(node::Node, seconds::Integer, nanoseconds::Integer) -> Bool

Block until the timeout expires or a termination/interrupt is observed.
Returns `true` on timeout, `false` on interrupt/termination.
"""
function wait(node::Node, seconds::Integer, nanoseconds::Integer)
    _require_valid(unsafe_handle(node), "node")
    ret = Iceoryx2FFI.iox2_node_wait(
        Ref{Iceoryx2FFI.iox2_node_h}(unsafe_handle(node)),
        UInt64(seconds),
        UInt32(nanoseconds),
    )
    ret == _IOX2_OK && return true
    code = Iceoryx2FFI.iox2_node_wait_failure_e(ret)
    if code == Iceoryx2FFI.iox2_node_wait_failure_e_INTERRUPT ||
       code == Iceoryx2FFI.iox2_node_wait_failure_e_TERMINATION_REQUEST
        return false
    end
    throw(NodeWaitFailure(code))
end

"""
    wait(node::Node, seconds::Real) -> Bool

Convenience overload taking seconds as a real value.
"""
function wait(node::Node, seconds::Real)
    seconds < 0 && throw(ArgumentError("wait duration must be non-negative, got $seconds"))
    secs = floor(Int, seconds)
    nanos = floor(Int, (seconds - secs) * 1e9)
    return wait(node, secs, nanos)
end

"""
    id(node::Node{S}) -> NodeId

Return an owned node ID for the given node.
"""
function id(node::Node{S}) where {S}
    _require_valid(unsafe_handle(node), "node")
    ptr = Iceoryx2FFI.iox2_node_id(Ref{Iceoryx2FFI.iox2_node_h}(unsafe_handle(node)), _service_type(S))
    handle_ref = Ref{Iceoryx2FFI.iox2_node_id_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_node_id_clone_from_ptr(C_NULL, ptr, handle_ref)
    return NodeId(handle_ref[])
end

"""
    to_owned(node_id::NodeIdView) -> NodeId

Clone a `NodeIdView` into an owned `NodeId`.
"""
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

"""
    creation_time(node_id::NodeId) -> (seconds, nanoseconds)

Return the creation timestamp of the node ID.
"""
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

"""
    remove_stale_resources(node_id::NodeId; service_type, config=nothing) -> Bool

Remove stale resources belonging to a dead node. Returns `true` when cleanup
succeeds.
"""
function remove_stale_resources(
    node_id::NodeId;
    service_type::ServiceType,
    config::Union{Config, ConfigRef, Nothing} = nothing,
)
    _require_valid(unsafe_handle(node_id), "node id")
    if config === nothing
        cfg = default_config()
        try
            return remove_stale_resources(node_id; service_type, config = cfg)
        finally
            close(cfg)
        end
    end
    success = Ref{Bool}(false)
    ret = Iceoryx2FFI.iox2_dead_node_remove_stale_resources(
        _service_type(service_type),
        Ref{Iceoryx2FFI.iox2_node_id_h}(unsafe_handle(node_id)),
        _config_h_ref(config),
        success,
    )
    check_ok(ret, Iceoryx2FFI.iox2_node_cleanup_failure_e)
    return success[]
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
