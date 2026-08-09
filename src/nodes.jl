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
    return _signal_handling_mode_enum(
        Iceoryx2FFI.iox2_node_signal_handling_mode(Ref{Iceoryx2FFI.iox2_node_h}(unsafe_handle(node))),
    )
end

"""
    wait(node::Node, seconds::Integer, nanoseconds::Integer) -> Bool

Block until the timeout expires or a termination/interrupt is observed.
Returns `true` on timeout, `false` on interrupt/termination.
"""
function wait(node::Node, seconds::Integer, nanoseconds::Integer)
    _require_valid(unsafe_handle(node), "node")
    secs, nanos = _timeout_parts(seconds, nanoseconds)
    ret = Iceoryx2FFI.iox2_node_wait(
        Ref{Iceoryx2FFI.iox2_node_h}(unsafe_handle(node)),
        secs,
        nanos
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
    secs, nanos = _timeout_parts(seconds)
    return wait(node, secs, nanos)
end

"""
    try_cleanup_dead_nodes(node::Node) -> CleanupState

Remove stale resources for all dead nodes visible to `node`.
"""
function try_cleanup_dead_nodes(node::Node)
    _require_valid(unsafe_handle(node), "node")
    state = _cleanup_state_ref()
    Iceoryx2FFI.iox2_node_try_cleanup_dead_nodes(
        Ref{Iceoryx2FFI.iox2_node_h}(unsafe_handle(node)),
        state
    )
    return _cleanup_state(state)
end

"""
    blocking_cleanup_dead_nodes(node::Node, seconds[, nanoseconds]) -> CleanupState

Remove stale resources for all dead nodes visible to `node`, waiting up to the
timeout for nodes currently being cleaned by another process.
"""
function blocking_cleanup_dead_nodes(
        node::Node,
        seconds::Integer,
        nanoseconds::Integer = 0
)
    _require_valid(unsafe_handle(node), "node")
    secs, nanos = _timeout_parts(seconds, nanoseconds)
    state = _cleanup_state_ref()
    Iceoryx2FFI.iox2_node_blocking_cleanup_dead_nodes(
        Ref{Iceoryx2FFI.iox2_node_h}(unsafe_handle(node)),
        state,
        secs,
        nanos
    )
    return _cleanup_state(state)
end

"""
    force_remove_service(node, service_name; messaging_pattern) -> Bool

Remove a stale service that cannot be opened normally. No other process may be
using the service. Return `true` when a service was removed.
"""
function force_remove_service(
        node::Node,
        service_name::Union{ServiceName, ServiceNameView};
        messaging_pattern::Union{Symbol, MessagingPattern}
)
    _require_valid(unsafe_handle(node), "node")
    removed = Ref{Bool}(false)
    ret = GC.@preserve service_name removed begin
        Iceoryx2FFI.iox2_node_force_remove_service(
            Ref{Iceoryx2FFI.iox2_node_h}(unsafe_handle(node)),
            _service_name_ptr(service_name),
            _messaging_pattern(messaging_pattern),
            removed
        )
    end
    check_ok(ret, Iceoryx2FFI.iox2_service_remove_error_e)
    return removed[]
end

function force_remove_service(
        node::Node,
        service_name::AbstractString;
        messaging_pattern::Union{Symbol, MessagingPattern}
)
    name = ServiceName(service_name)
    try
        return force_remove_service(node, name; messaging_pattern)
    finally
        close(name)
    end
end

function blocking_cleanup_dead_nodes(
        node::Node,
        seconds::Real
)
    secs, nanos = _timeout_parts(seconds)
    return blocking_cleanup_dead_nodes(node, secs, nanos)
end

"""
    id(node::Node{S}) -> NodeId

Return an owned node ID for the given node.
"""
function id(node::Node{S}) where {S}
    _require_valid(unsafe_handle(node), "node")
    ptr = Iceoryx2FFI.iox2_unique_node_id(Ref{Iceoryx2FFI.iox2_node_h}(unsafe_handle(node)), _service_type(S))
    return _node_id_from_ptr(ptr)
end

@inline function value_high(node_id::NodeId)
    return _node_id_call(Iceoryx2FFI.iox2_unique_node_id_value_high, node_id)
end

@inline function value_low(node_id::NodeId)
    return _node_id_call(Iceoryx2FFI.iox2_unique_node_id_value_low, node_id)
end

@inline function pid(node_id::NodeId)
    return _node_id_call(Iceoryx2FFI.iox2_unique_node_id_pid, node_id)
end

"""
    creation_time(node_id::NodeId) -> (seconds, nanoseconds)

Return the creation timestamp of the node ID.
"""
function creation_time(node_id::NodeId)
    seconds = Ref{UInt64}(0)
    nanos = Ref{UInt32}(0)
    _node_id_call(Iceoryx2FFI.iox2_unique_node_id_creation_time, node_id, seconds, nanos)
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
        config::Union{Config, ConfigRef, Nothing} = nothing
)
    if config === nothing
        cfg = default_config()
        try
            return remove_stale_resources(node_id; service_type, config = cfg)
        finally
            close(cfg)
        end
    end
    ret = _node_id_call(
        (handle, type,
            config_handle) -> Iceoryx2FFI.iox2_dead_node_try_remove_stale_resources(
            type, handle, config_handle),
        node_id,
        _service_type(service_type),
        _config_h_ref(config)
    )
    ret == _IOX2_OK && return true
    code = Iceoryx2FFI.iox2_node_cleanup_failure_e(ret)
    code == Iceoryx2FFI.iox2_node_cleanup_failure_e_RESOURCES_ALREADY_CLEANED_UP &&
        return true
    code ==
    Iceoryx2FFI.iox2_node_cleanup_failure_e_ANOTHER_INSTANCE_IS_CLEANING_UP_THE_NODE &&
        return false
    throw(NodeCleanupFailure(code))
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

@inline function Base.hash(node_id::NodeId, seed::UInt)
    return hash(value_low(node_id), hash(value_high(node_id), seed))
end
