# Callback and iteration helpers.

using FunctionWrappers: FunctionWrapper

@inline function _callback_progression(value)
    if value isa Iceoryx2FFI.iox2_callback_progression_e
        return value
    elseif value === true || value === :continue
        return Iceoryx2FFI.iox2_callback_progression_e_CONTINUE
    elseif value === false || value === :stop
        return Iceoryx2FFI.iox2_callback_progression_e_STOP
    end
    throw(ArgumentError("unsupported callback progression: $value"))
end

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

struct _NodeListCallbackCtx
    fn::FunctionWrapper{Iceoryx2FFI.iox2_callback_progression_e, Tuple{Iceoryx2FFI.iox2_node_state_e, NodeIdView, Cstring, NodeNameView, ConfigView}}
end

function _node_list_trampoline(state::Iceoryx2FFI.iox2_node_state_e,
    node_id_ptr::Iceoryx2FFI.iox2_node_id_ptr,
    node_id_str::Cstring,
    node_name_ptr::Iceoryx2FFI.iox2_node_name_ptr,
    config_ptr::Iceoryx2FFI.iox2_config_ptr,
    ctx::Ptr{Cvoid},
)::Iceoryx2FFI.iox2_callback_progression_e
    ctx_ref = unsafe_pointer_to_objref(ctx)::_NodeListCallbackCtx
    return ctx_ref.fn(state, NodeIdView(node_id_ptr), node_id_str, NodeNameView(node_name_ptr), ConfigView(config_ptr))
end

const _NODE_LIST_CB = @cfunction(
    _node_list_trampoline,
    Iceoryx2FFI.iox2_callback_progression_e,
    (
        Iceoryx2FFI.iox2_node_state_e,
        Iceoryx2FFI.iox2_node_id_ptr,
        Cstring,
        Iceoryx2FFI.iox2_node_name_ptr,
        Iceoryx2FFI.iox2_config_ptr,
        Ptr{Cvoid},
    ),
)

function list_nodes(
    f::Function;
    service_type::Union{Symbol, Iceoryx2FFI.iox2_service_type_e} = :ipc,
    config::Union{Config, ConfigView, Nothing} = nothing,
)
    let user_f = f
        ctx = _NodeListCallbackCtx(FunctionWrapper{Iceoryx2FFI.iox2_callback_progression_e, Tuple{Iceoryx2FFI.iox2_node_state_e, NodeIdView, Cstring, NodeNameView, ConfigView}}(
            (state, node_id, node_id_str, node_name, cfg) -> _callback_progression(user_f(state, node_id, node_id_str, node_name, cfg)),
        ))
        ctx_ref = Ref(ctx)
        GC.@preserve ctx_ref begin
            ret = Iceoryx2FFI.iox2_node_list(_service_type(service_type), _config_ptr_from_arg(config), _NODE_LIST_CB, Base.unsafe_convert(Ptr{Cvoid}, ctx_ref))
            check_ok(ret, Iceoryx2FFI.iox2_node_list_failure_e)
        end
    end
    return nothing
end

struct _AttributeValueCallbackCtx
    fn::FunctionWrapper{Iceoryx2FFI.iox2_callback_progression_e, Tuple{Cstring}}
end

function _attribute_value_trampoline(value::Cstring, ctx::Ptr{Cvoid})::Iceoryx2FFI.iox2_callback_progression_e
    ctx_ref = unsafe_pointer_to_objref(ctx)::_AttributeValueCallbackCtx
    return ctx_ref.fn(value)
end

const _ATTRIBUTE_VALUE_CB = @cfunction(
    _attribute_value_trampoline,
    Iceoryx2FFI.iox2_callback_progression_e,
    (Cstring, Ptr{Cvoid}),
)

@inline function _attribute_set_ptr(attrs::AttributeSet)
    _require_valid(unsafe_handle(attrs), "attribute set")
    return Iceoryx2FFI.iox2_cast_attribute_set_ptr(unsafe_handle(attrs))
end

@inline function _attribute_set_ptr(attrs::AttributeSetView)
    return unsafe_handle(attrs)
end

function each_attribute_value(attrs::Union{AttributeSet, AttributeSetView}, key::AbstractString, f::Function)
    let user_f = f
        ctx = _AttributeValueCallbackCtx(FunctionWrapper{Iceoryx2FFI.iox2_callback_progression_e, Tuple{Cstring}}(
            value -> _callback_progression(user_f(value)),
        ))
        ctx_ref = Ref(ctx)
        key_str = String(key)
        GC.@preserve ctx_ref key_str begin
            Iceoryx2FFI.iox2_attribute_set_iter_key_values(_attribute_set_ptr(attrs), Base.unsafe_convert(Cstring, key_str), _ATTRIBUTE_VALUE_CB, Base.unsafe_convert(Ptr{Cvoid}, ctx_ref))
        end
    end
    return nothing
end

function attribute_values(attrs::Union{AttributeSet, AttributeSetView}, key::AbstractString)
    values = String[]
    each_attribute_value(attrs, key) do value
        push!(values, unsafe_string(value))
        return true
    end
    return values
end
