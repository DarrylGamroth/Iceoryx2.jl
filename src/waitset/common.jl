# WaitSet wrappers.

@inline _signal_handling_mode(value::Iceoryx2FFI.iox2_signal_handling_mode_e) = value

@inline function _signal_handling_mode(value::Symbol)
    if value === :handle_termination_requests
        return Iceoryx2FFI.iox2_signal_handling_mode_e_HANDLE_TERMINATION_REQUESTS
    elseif value === :disabled
        return Iceoryx2FFI.iox2_signal_handling_mode_e_DISABLED
    end
    throw(ArgumentError("unsupported signal handling mode: $value"))
end

@inline _signal_handling_mode(value) = throw(ArgumentError("unsupported signal handling mode: $value"))

function WaitsetBuilder()
    handle_ref = Ref{Iceoryx2FFI.iox2_waitset_builder_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_waitset_builder_new(C_NULL, handle_ref)
    return WaitsetBuilder(handle_ref[])
end

function signal_handling_mode!(builder::WaitsetBuilder, mode::Union{Symbol, Iceoryx2FFI.iox2_signal_handling_mode_e})
    _require_valid(unsafe_handle(builder), "waitset builder")
    Iceoryx2FFI.iox2_waitset_builder_set_signal_handling_mode(Ref{Iceoryx2FFI.iox2_waitset_builder_h}(unsafe_handle(builder)), _signal_handling_mode(mode))
    return builder
end

function create(builder::WaitsetBuilder; service_type::Union{Symbol, Iceoryx2FFI.iox2_service_type_e} = :ipc)
    _require_valid(unsafe_handle(builder), "waitset builder")
    handle_ref = Ref{Iceoryx2FFI.iox2_waitset_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_waitset_builder_create(unsafe_handle(builder), _service_type(service_type), C_NULL, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_waitset_create_error_e)
    invalidate!(builder)
    return Waitset(handle_ref[])
end

function create(f::Function, builder::WaitsetBuilder; service_type::Union{Symbol, Iceoryx2FFI.iox2_service_type_e} = :ipc)
    waitset = create(builder; service_type)
    try
        return f(waitset)
    finally
        close(waitset)
    end
end

@inline function signal_handling_mode(waitset::Waitset)
    return Iceoryx2FFI.iox2_waitset_signal_handling_mode(Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset)))
end

@inline function Base.isempty(waitset::Waitset)
    return Iceoryx2FFI.iox2_waitset_is_empty(Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset)))
end

@inline function Base.length(waitset::Waitset)
    return Int(Iceoryx2FFI.iox2_waitset_len(Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset))))
end

@inline function capacity(waitset::Waitset)
    return Int(Iceoryx2FFI.iox2_waitset_capacity(Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset))))
end
