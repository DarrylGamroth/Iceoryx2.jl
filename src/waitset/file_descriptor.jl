@inline function _file_descriptor_ptr(fd::FileDescriptor)
    _require_valid(unsafe_handle(fd), "file descriptor")
    return Iceoryx2FFI.iox2_cast_file_descriptor_ptr(unsafe_handle(fd))
end

@inline function _file_descriptor_ptr(fd::FileDescriptorView)
    return unsafe_handle(fd)
end

"""
    FileDescriptor(value::Integer; owned=true) -> FileDescriptor

Wrap a native file descriptor. When `owned=true`, the descriptor is closed
when the handle is dropped.
"""
function FileDescriptor(value::Integer; owned::Bool = true)
    handle_ref = Ref{Iceoryx2FFI.iox2_file_descriptor_h}(_IOX2_NULL)
    ok = Iceoryx2FFI.iox2_file_descriptor_new(Int32(value), owned, C_NULL, handle_ref)
    ok || throw(ArgumentError("invalid file descriptor: $value"))
    return FileDescriptor(handle_ref[])
end

"""
    native_handle(fd) -> Int32

Return the underlying OS file descriptor.
"""
@inline function native_handle(fd::Union{FileDescriptor, FileDescriptorView})
    return Iceoryx2FFI.iox2_file_descriptor_native_handle(_file_descriptor_ptr(fd))
end

"""
    file_descriptor(listener::Listener) -> FileDescriptorView

Return a view of the file descriptor backing a listener.
"""
function file_descriptor(listener::Listener)
    _require_valid(listener.handle, "listener")
    ptr = Iceoryx2FFI.iox2_listener_get_file_descriptor(Ref{Iceoryx2FFI.iox2_listener_h}(listener.handle))
    return FileDescriptorView(ptr)
end

"""
    attach_notification(waitset, fd) -> WaitsetGuard

Attach a file descriptor notification to the waitset.
"""
function attach_notification(waitset::Waitset{S}, fd::Union{FileDescriptor, FileDescriptorView}) where {S}
    _require_valid(unsafe_handle(waitset), "waitset")
    guard_ref = Ref{Iceoryx2FFI.iox2_waitset_guard_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_waitset_attach_notification(Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset)), _file_descriptor_ptr(fd), C_NULL, guard_ref)
    check_ok(ret, Iceoryx2FFI.iox2_waitset_attachment_error_e)
    return WaitsetGuard{S}(guard_ref[])
end

"""
    attach_deadline(waitset, fd, seconds, nanoseconds) -> WaitsetGuard

Attach a file descriptor deadline to the waitset.
"""
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

"""
    attach_interval(waitset, seconds, nanoseconds) -> WaitsetGuard

Attach a periodic interval to the waitset.
"""
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
