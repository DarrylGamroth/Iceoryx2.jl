# Callback and iteration helpers.

@inline _callback_progression(value::Iceoryx2FFI.iox2_callback_progression_e) = value

@inline function _callback_progression(value::Bool)
    return value ? Iceoryx2FFI.iox2_callback_progression_e_CONTINUE :
           Iceoryx2FFI.iox2_callback_progression_e_STOP
end

@inline function _callback_progression(value::Symbol)
    if value === :continue
        return Iceoryx2FFI.iox2_callback_progression_e_CONTINUE
    elseif value === :stop
        return Iceoryx2FFI.iox2_callback_progression_e_STOP
    end
    throw(ArgumentError("unsupported callback progression: $value"))
end

@inline _callback_progression(value) = throw(ArgumentError("unsupported callback progression: $value"))

@inline function _config_ptr_from_arg(config::Config)
    _require_valid(unsafe_handle(config), "config")
    return Iceoryx2FFI.iox2_cast_config_ptr(unsafe_handle(config))
end

@inline function _config_ptr_from_arg(config::ConfigView)
    return unsafe_handle(config)
end

@inline function _config_ptr_from_arg(::Nothing)
    return Iceoryx2FFI.iox2_config_global_config()
end

abstract type AbstractNodeListHandler end

mutable struct NodeListHandler{T} <: AbstractNodeListHandler
    on_list::T
end

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
    handler_ref = Ref(handler)
    GC.@preserve handler_ref begin
        ret = Iceoryx2FFI.iox2_node_list(
            _service_type(service_type),
            _config_ptr_from_arg(config),
            _node_list_cfunction(handler_ref[]),
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

abstract type AbstractAttributeValueHandler end

mutable struct AttributeValueHandler{T} <: AbstractAttributeValueHandler
    on_value::T
end

on_attribute_value(h::AttributeValueHandler) = h.on_value

function _attribute_value_wrapper(value::Cstring, handler::AbstractAttributeValueHandler)
    return _callback_progression(on_attribute_value(handler)(value))
end

function _attribute_value_cfunction(::T) where {T<:AbstractAttributeValueHandler}
    @cfunction(_attribute_value_wrapper, Iceoryx2FFI.iox2_callback_progression_e, (Cstring, Ref{T}))
end

@inline function _attribute_set_ptr(attrs::AttributeSet)
    _require_valid(unsafe_handle(attrs), "attribute set")
    return Iceoryx2FFI.iox2_cast_attribute_set_ptr(unsafe_handle(attrs))
end

@inline function _attribute_set_ptr(attrs::AttributeSetView)
    return unsafe_handle(attrs)
end

function each_attribute_value(
    attrs::Union{AttributeSet, AttributeSetView},
    key::AbstractString,
    handler::AbstractAttributeValueHandler,
)
    key_str = String(key)
    handler_ref = Ref(handler)
    GC.@preserve handler_ref key_str begin
        Iceoryx2FFI.iox2_attribute_set_iter_key_values(
            _attribute_set_ptr(attrs),
            Base.unsafe_convert(Cstring, key_str),
            _attribute_value_cfunction(handler_ref[]),
            handler_ref,
        )
    end
    return nothing
end

function each_attribute_value(f::Function, attrs::Union{AttributeSet, AttributeSetView}, key::AbstractString)
    return each_attribute_value(attrs, key, f)
end

function attribute_values(attrs::Union{AttributeSet, AttributeSetView}, key::AbstractString)
    values = String[]
    each_attribute_value(attrs, key) do value
        push!(values, unsafe_string(value))
        return true
    end
    return values
end
