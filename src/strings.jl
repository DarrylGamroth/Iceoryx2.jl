# String and semantic-string helpers.

@inline function _node_name_string(ptr::Iceoryx2FFI.iox2_node_name_ptr)
    ptr == _IOX2_NULL && throw(ArgumentError("null node name pointer"))
    len = Ref{Iceoryx2FFI.c_size_t}()
    cstr = Iceoryx2FFI.iox2_node_name_as_chars(ptr, len)
    return unsafe_string(cstr, Int(len[]))
end

@inline function _service_name_string(ptr::Iceoryx2FFI.iox2_service_name_ptr)
    ptr == _IOX2_NULL && throw(ArgumentError("null service name pointer"))
    len = Ref{Iceoryx2FFI.c_size_t}()
    cstr = Iceoryx2FFI.iox2_service_name_as_chars(ptr, len)
    return unsafe_string(cstr, Int(len[]))
end

@inline function _node_name_ptr(handle::Iceoryx2FFI.iox2_node_name_h)
    handle == _IOX2_NULL && throw(ArgumentError("invalid node name handle"))
    return Iceoryx2FFI.iox2_cast_node_name_ptr(handle)
end

@inline function _service_name_ptr(handle::Iceoryx2FFI.iox2_service_name_h)
    handle == _IOX2_NULL && throw(ArgumentError("invalid service name handle"))
    return Iceoryx2FFI.iox2_cast_service_name_ptr(handle)
end

function NodeName(value::AbstractString)
    str = String(value)
    handle_ref = Ref{Iceoryx2FFI.iox2_node_name_h}(_IOX2_NULL)
    len = Iceoryx2FFI.c_size_t(ncodeunits(str))
    GC.@preserve str begin
        ret = Iceoryx2FFI.iox2_node_name_new(C_NULL, Base.unsafe_convert(Cstring, str), len, handle_ref)
        check_ok(ret, Iceoryx2FFI.iox2_semantic_string_error_e)
    end
    return NodeName(handle_ref[])
end

function ServiceName(value::AbstractString)
    str = String(value)
    handle_ref = Ref{Iceoryx2FFI.iox2_service_name_h}(_IOX2_NULL)
    len = Iceoryx2FFI.c_size_t(ncodeunits(str))
    GC.@preserve str begin
        ret = Iceoryx2FFI.iox2_service_name_new(C_NULL, Base.unsafe_convert(Cstring, str), len, handle_ref)
        check_ok(ret, Iceoryx2FFI.iox2_semantic_string_error_e)
    end
    return ServiceName(handle_ref[])
end

@inline Base.string(name::NodeName) = _node_name_string(_node_name_ptr(unsafe_handle(name)))
@inline Base.string(name::ServiceName) = _service_name_string(_service_name_ptr(unsafe_handle(name)))

@inline Base.string(name::NodeNameView) = _node_name_string(unsafe_handle(name))
@inline Base.string(name::ServiceNameView) = _service_name_string(unsafe_handle(name))
