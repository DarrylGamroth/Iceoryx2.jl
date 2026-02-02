@inline function _file_descriptor_ptr(fd::FileDescriptor)
    _require_valid(unsafe_handle(fd), "file descriptor")
    return Iceoryx2FFI.iox2_cast_file_descriptor_ptr(unsafe_handle(fd))
end

@inline function _file_descriptor_ptr(fd::FileDescriptorView)
    return unsafe_handle(fd)
end

function FileDescriptor(value::Integer; owned::Bool = true)
    handle_ref = Ref{Iceoryx2FFI.iox2_file_descriptor_h}(_IOX2_NULL)
    ok = Iceoryx2FFI.iox2_file_descriptor_new(Int32(value), owned, C_NULL, handle_ref)
    ok || throw(ArgumentError("invalid file descriptor: $value"))
    return FileDescriptor(handle_ref[])
end

@inline function native_handle(fd::Union{FileDescriptor, FileDescriptorView})
    return Iceoryx2FFI.iox2_file_descriptor_native_handle(_file_descriptor_ptr(fd))
end

function file_descriptor(listener::Listener)
    _require_valid(listener.handle, "listener")
    ptr = Iceoryx2FFI.iox2_listener_get_file_descriptor(Ref{Iceoryx2FFI.iox2_listener_h}(listener.handle))
    return FileDescriptorView(ptr)
end

function attach_notification(waitset::Waitset{S}, fd::Union{FileDescriptor, FileDescriptorView}) where {S}
    _require_valid(unsafe_handle(waitset), "waitset")
    guard_ref = Ref{Iceoryx2FFI.iox2_waitset_guard_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_waitset_attach_notification(Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset)), _file_descriptor_ptr(fd), C_NULL, guard_ref)
    check_ok(ret, Iceoryx2FFI.iox2_waitset_attachment_error_e)
    return WaitsetGuard{S}(guard_ref[])
end

function attach_deadline(waitset::Waitset{S}, fd::Union{FileDescriptor, FileDescriptorView}, seconds::Integer, nanoseconds::Integer) where {S}
    _require_valid(unsafe_handle(waitset), "waitset")
    guard_ref = Ref{Iceoryx2FFI.iox2_waitset_guard_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_waitset_attach_deadline(
        Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset)),
        _file_descriptor_ptr(fd),
        UInt64(seconds),
        UInt32(nanoseconds),
        C_NULL,
        guard_ref,
    )
    check_ok(ret, Iceoryx2FFI.iox2_waitset_attachment_error_e)
    return WaitsetGuard{S}(guard_ref[])
end

function attach_interval(waitset::Waitset{S}, seconds::Integer, nanoseconds::Integer) where {S}
    _require_valid(unsafe_handle(waitset), "waitset")
    guard_ref = Ref{Iceoryx2FFI.iox2_waitset_guard_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_waitset_attach_interval(
        Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset)),
        UInt64(seconds),
        UInt32(nanoseconds),
        C_NULL,
        guard_ref,
    )
    check_ok(ret, Iceoryx2FFI.iox2_waitset_attachment_error_e)
    return WaitsetGuard{S}(guard_ref[])
end
