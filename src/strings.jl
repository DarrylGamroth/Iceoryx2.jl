# String and semantic-string helpers.

function _node_name_string(ptr::Iceoryx2FFI.iox2_node_name_ptr)
    ptr == _IOX2_NULL && throw(ArgumentError("null node name pointer"))
    len = Ref{Iceoryx2FFI.c_size_t}()
    cstr = Iceoryx2FFI.iox2_node_name_as_chars(ptr, len)
    return unsafe_string(Ptr{UInt8}(cstr), Int(len[]))
end

function _service_name_string(ptr::Iceoryx2FFI.iox2_service_name_ptr)
    ptr == _IOX2_NULL && throw(ArgumentError("null service name pointer"))
    len = Ref{Iceoryx2FFI.c_size_t}()
    cstr = Iceoryx2FFI.iox2_service_name_as_chars(ptr, len)
    return unsafe_string(Ptr{UInt8}(cstr), Int(len[]))
end

function _port_name_string(ptr::Iceoryx2FFI.iox2_port_name_ptr)
    ptr == _IOX2_NULL && throw(ArgumentError("null port name pointer"))
    len = Ref{Iceoryx2FFI.c_size_t}()
    cstr = Iceoryx2FFI.iox2_port_name_as_chars(ptr, len)
    return unsafe_string(Ptr{UInt8}(cstr), Int(len[]))
end

@inline function _node_name_ptr(handle::Iceoryx2FFI.iox2_node_name_h)
    handle == _IOX2_NULL && throw(ArgumentError("invalid node name handle"))
    return Iceoryx2FFI.iox2_cast_node_name_ptr(handle)
end

@inline function _service_name_ptr(handle::Iceoryx2FFI.iox2_service_name_h)
    handle == _IOX2_NULL && throw(ArgumentError("invalid service name handle"))
    return Iceoryx2FFI.iox2_cast_service_name_ptr(handle)
end

@inline _service_name_ptr(name::ServiceName) = _service_name_ptr(unsafe_handle(name))

@inline function _service_name_ptr(name::ServiceNameView)
    _require_valid(unsafe_handle(name), "service name")
    return unsafe_handle(name)
end

@inline function _port_name_ptr(handle::Iceoryx2FFI.iox2_port_name_h)
    handle == _IOX2_NULL && throw(ArgumentError("invalid port name handle"))
    return Iceoryx2FFI.iox2_cast_port_name_ptr(handle)
end

"""
    NodeName(value::AbstractString)

Create a semantic node name owned by Julia. The resulting handle is consumed
by `name!(::NodeBuilder, ...)` and must be closed if not transferred.
"""
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

"""
    ServiceName(value::AbstractString)

Create a semantic service name owned by Julia. The resulting handle is consumed
and closed by `service_builder`; close it explicitly if it is not consumed.
"""
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

"""
    PortName(value::AbstractString)

Create an owned semantic name for a publisher, subscriber, notifier, listener,
client, server, reader, or writer.
"""
function PortName(value::AbstractString)
    str = String(value)
    handle_ref = Ref{Iceoryx2FFI.iox2_port_name_h}(_IOX2_NULL)
    len = Iceoryx2FFI.c_size_t(ncodeunits(str))
    GC.@preserve str begin
        ret = Iceoryx2FFI.iox2_port_name_new(
            C_NULL,
            Base.unsafe_convert(Cstring, str),
            len,
            handle_ref
        )
        check_ok(ret, Iceoryx2FFI.iox2_semantic_string_error_e)
    end
    return PortName(handle_ref[])
end

"""
    string(name::NodeName)
    string(name::ServiceName)
    string(name::NodeNameView)
    string(name::ServiceNameView)

Convert a semantic name handle into a Julia `String` by copying the underlying
UTF-8 bytes.
"""
Base.string(name::NodeName) = _node_name_string(_node_name_ptr(unsafe_handle(name)))
function Base.string(name::ServiceName)
    _service_name_string(_service_name_ptr(unsafe_handle(name)))
end
Base.string(name::PortName) = _port_name_string(_port_name_ptr(unsafe_handle(name)))

Base.string(name::NodeNameView) = _node_name_string(unsafe_handle(name))
Base.string(name::ServiceNameView) = _service_name_string(unsafe_handle(name))
Base.string(name::PortNameView) = _port_name_string(unsafe_handle(name))

function _set_port_name!(
        builder, name::PortName, setter::F, handle_ref, what::AbstractString) where {F}
    _require_valid(builder.handle, what)
    GC.@preserve name begin
        setter(handle_ref, _port_name_ptr(unsafe_handle(name)))
    end
    return builder
end

function _set_port_name!(
        builder, name::PortNameView, setter::F, handle_ref, what::AbstractString) where {F}
    _require_valid(builder.handle, what)
    setter(handle_ref, unsafe_handle(name))
    return builder
end

function _set_port_name!(builder, name::AbstractString, setter::F,
        handle_ref, what::AbstractString) where {F}
    port_name = PortName(name)
    try
        return _set_port_name!(builder, port_name, setter, handle_ref, what)
    finally
        close(port_name)
    end
end
