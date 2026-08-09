# Callback and iteration helpers.

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

@inline function _handler_ref(h::T) where {T}
    if hasfield(T, :ref)
        return getfield(h, :ref)
    else
        return Ref(h)
    end
end

@inline function _init_handler_ref!(obj)
    getfield(obj, :ref)[] = obj
    return obj
end
