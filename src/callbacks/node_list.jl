abstract type AbstractNodeListHandler end

mutable struct NodeListHandler{T} <: AbstractNodeListHandler
    on_list::T
    ref::Base.RefValue{NodeListHandler{T}}
    function NodeListHandler{T}(on_list::T) where {T}
        ref = Ref{NodeListHandler{T}}()
        obj = new{T}(on_list, ref)
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
    handler::AbstractNodeListHandler,
)
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

function list_nodes(
    handler::AbstractNodeListHandler;
    service_type::Union{Symbol, Iceoryx2FFI.iox2_service_type_e} = :ipc,
    config::Union{Config, ConfigView, Nothing} = nothing,
)
    handler_ref = _handler_ref(handler)
    GC.@preserve handler_ref begin
        ret = Iceoryx2FFI.iox2_node_list(
            _service_type(service_type),
            _config_ptr_from_arg(config),
            _node_list_cfunction(handler),
            handler_ref,
        )
        check_ok(ret, Iceoryx2FFI.iox2_node_list_failure_e)
    end
    return nothing
end

function list_nodes(
    f::Function;
    service_type::Union{Symbol, Iceoryx2FFI.iox2_service_type_e} = :ipc,
    config::Union{Config, ConfigView, Nothing} = nothing,
)
    return list_nodes(NodeListHandler(f); service_type, config)
end

function list_nodes(factory::PortFactoryEvent, handler::AbstractNodeListHandler)
    _require_valid(factory.handle, "event port factory")
    handler_ref = _handler_ref(handler)
    GC.@preserve handler_ref begin
