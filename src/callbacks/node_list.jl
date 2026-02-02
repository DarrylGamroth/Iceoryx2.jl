"""
    AbstractNodeListHandler

Abstract callback handler for `list_nodes`.
"""
abstract type AbstractNodeListHandler end

"""
    NodeListHandler(f)

Wrap a callable `f(state, node_id_view, node_id_cstr, node_name_view, config_view)`
for use with `list_nodes`.
"""
mutable struct NodeListHandler{T} <: AbstractNodeListHandler
    on_list::T
    ref::Base.RefValue{NodeListHandler{T}}
    callback::Iceoryx2FFI.iox2_node_list_callback
    function NodeListHandler{T}(on_list::T) where {T}
        ref = Ref{NodeListHandler{T}}()
        obj = new{T}(on_list, ref, C_NULL)
        obj.callback = _node_list_cfunction(obj)
        return _init_handler_ref!(obj)
    end
end

NodeListHandler(on_list) = NodeListHandler{typeof(on_list)}(on_list)

on_node_list(h::NodeListHandler) = h.on_list

function _node_list_wrapper(
    state::Iceoryx2FFI.iox2_node_state_e,
    node_id_ptr::Iceoryx2FFI.iox2_node_id_ptr,
    node_id_str::Cstring,
    node_name_ptr::Iceoryx2FFI.iox2_node_name_ptr,
    config_ptr::Iceoryx2FFI.iox2_config_ptr,
    handler::T,
) where {T<:AbstractNodeListHandler}
    return _callback_progression(
        on_node_list(handler)(state, NodeIdView(node_id_ptr), node_id_str, NodeNameView(node_name_ptr), ConfigView(config_ptr)),
    )
end

function _node_list_cfunction(::T) where {T<:AbstractNodeListHandler}
    @cfunction(
        _node_list_wrapper,
        Iceoryx2FFI.iox2_callback_progression_e,
        (
            Iceoryx2FFI.iox2_node_state_e,
            Iceoryx2FFI.iox2_node_id_ptr,
            Cstring,
            Iceoryx2FFI.iox2_node_name_ptr,
            Iceoryx2FFI.iox2_config_ptr,
            Ref{T},
        ),
    )
end

@inline function _list_nodes(
    handler,
    callback;
    service_type::ServiceType,
    config::Union{Config, ConfigView, Nothing} = nothing,
)
    handler_ref = _handler_ref(handler)
    GC.@preserve handler_ref begin
        ret = Iceoryx2FFI.iox2_node_list(
            _service_type(service_type),
            _config_ptr_from_arg(config),
            callback,
            handler_ref,
        )
        check_ok(ret, Iceoryx2FFI.iox2_node_list_failure_e)
    end
    return nothing
end

"""
    list_nodes(handler; service_type, config=nothing)
    list_nodes(f::Function; service_type, config=nothing)

Iterate over nodes for the given service type. The callback controls iteration
by returning `true`/`false` or `:continue`/`:stop`.
"""
function list_nodes(
    handler::NodeListHandler;
    service_type::ServiceType,
    config::Union{Config, ConfigView, Nothing} = nothing,
)
    return _list_nodes(handler, handler.callback; service_type, config)
end

function list_nodes(
    handler::AbstractNodeListHandler;
    service_type::ServiceType,
    config::Union{Config, ConfigView, Nothing} = nothing,
)
    return _list_nodes(handler, _node_list_cfunction(handler); service_type, config)
end

function list_nodes(
    f::Function;
    service_type::ServiceType,
    config::Union{Config, ConfigView, Nothing} = nothing,
)
    return list_nodes(NodeListHandler(f); service_type, config)
end

@inline function _list_nodes(factory::PortFactoryEvent{S}, handler, callback) where {S}
    _require_valid(factory.handle, "event port factory")
    handler_ref = _handler_ref(handler)
    GC.@preserve handler_ref begin
        ret = Iceoryx2FFI.iox2_port_factory_event_nodes(
            Ref{Iceoryx2FFI.iox2_port_factory_event_h}(factory.handle),
            callback,
            handler_ref,
        )
        check_ok(ret, Iceoryx2FFI.iox2_node_list_failure_e)
    end
    return nothing
end

"""
    list_nodes(factory::PortFactoryEvent, handler)
    list_nodes(factory::PortFactoryEvent, f::Function)

List nodes that are visible through an event port factory.
"""
function list_nodes(factory::PortFactoryEvent{S}, handler::NodeListHandler) where {S}
    return _list_nodes(factory, handler, handler.callback)
end

function list_nodes(factory::PortFactoryEvent{S}, handler::AbstractNodeListHandler) where {S}
    return _list_nodes(factory, handler, _node_list_cfunction(handler))
end

function list_nodes(f::Function, factory::PortFactoryEvent{S}) where {S}
    return list_nodes(factory, NodeListHandler(f))
end
