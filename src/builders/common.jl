# Builder and factory helpers.

@inline function _require_valid(handle, what::AbstractString)
    handle != _IOX2_NULL || throw(ArgumentError("invalid $what"))
    return nothing
end

@inline _service_type(value::Iceoryx2FFI.iox2_service_type_e) = value

@inline function _service_type(value::Symbol)
    if value === :ipc
        return Iceoryx2FFI.iox2_service_type_e_IPC
    elseif value === :local
        return Iceoryx2FFI.iox2_service_type_e_LOCAL
    end
    throw(ArgumentError("unsupported service_type: $value"))
end

@inline _service_type(value) = throw(ArgumentError("unsupported service_type: $value"))
