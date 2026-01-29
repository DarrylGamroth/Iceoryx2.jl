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

function attach_notification(waitset::Waitset, fd::Union{FileDescriptor, FileDescriptorView})
    _require_valid(unsafe_handle(waitset), "waitset")
    guard_ref = Ref{Iceoryx2FFI.iox2_waitset_guard_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_waitset_attach_notification(Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset)), _file_descriptor_ptr(fd), C_NULL, guard_ref)
    check_ok(ret, Iceoryx2FFI.iox2_waitset_attachment_error_e)
    return WaitsetGuard(guard_ref[])
end

function attach_deadline(waitset::Waitset, fd::Union{FileDescriptor, FileDescriptorView}, seconds::Integer, nanoseconds::Integer)
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
    return WaitsetGuard(guard_ref[])
end

function attach_interval(waitset::Waitset, seconds::Integer, nanoseconds::Integer)
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
    return WaitsetGuard(guard_ref[])
end

abstract type AbstractWaitsetHandler end

on_waitset_event(::AbstractWaitsetHandler) =
    throw(ArgumentError("Waitset handler must implement on_waitset_event(handler)"))

mutable struct WaitsetHandler{T} <: AbstractWaitsetHandler
    on_event::T
    attachment::WaitsetAttachmentId
    ref::Base.RefValue{WaitsetHandler{T}}
    result_ref::Base.RefValue{Iceoryx2FFI.iox2_waitset_run_result_e}
    result_ptr::Ptr{Iceoryx2FFI.iox2_waitset_run_result_e}
    function WaitsetHandler(on_event::T) where {T}
        obj = new{T}(
            on_event,
            WaitsetAttachmentId(_IOX2_NULL),
            Ref{WaitsetHandler{T}}(),
            Ref{Iceoryx2FFI.iox2_waitset_run_result_e}(),
            C_NULL,
        )
        obj.ref[] = obj
        obj.result_ptr = Base.unsafe_convert(Ptr{Iceoryx2FFI.iox2_waitset_run_result_e}, obj.result_ref)
        return obj
    end
end

on_waitset_event(h::WaitsetHandler) = h.on_event

@inline function _waitset_attachment_cleanup!(attachment::WaitsetAttachmentId)
    if attachment.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_waitset_attachment_id_drop(attachment.handle)
        attachment.handle = _IOX2_NULL
    end
    return nothing
end

@inline function _waitset_wrapper(attachment::Iceoryx2FFI.iox2_waitset_attachment_id_h, handler::WaitsetHandler)
    handler.attachment.handle = attachment
    result = _callback_progression(on_waitset_event(handler)(handler.attachment))
    _waitset_attachment_cleanup!(handler.attachment)
    return result
end

@inline function _waitset_wrapper(attachment::Iceoryx2FFI.iox2_waitset_attachment_id_h, handler::AbstractWaitsetHandler)
    attachment_obj = WaitsetAttachmentId(attachment)
    result = _callback_progression(on_waitset_event(handler)(attachment_obj))
    _waitset_attachment_cleanup!(attachment_obj)
    return result
end

function _waitset_cfunction(::T) where {T<:AbstractWaitsetHandler}
    @cfunction(
        _waitset_wrapper,
        Iceoryx2FFI.iox2_callback_progression_e,
        (Iceoryx2FFI.iox2_waitset_attachment_id_h, Ref{T}),
    )
end

@inline function _waitset_run_result(handler::WaitsetHandler)
    return unsafe_load(handler.result_ptr)
end

function wait_and_process_once(waitset::Waitset, handler::WaitsetHandler)
    _require_valid(unsafe_handle(waitset), "waitset")
    handler_ref = handler.ref
    GC.@preserve handler_ref begin
        ret = Iceoryx2FFI.iox2_waitset_wait_and_process_once(
            Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset)),
            _waitset_cfunction(handler),
            handler_ref,
            handler.result_ref,
        )
        check_ok(ret, Iceoryx2FFI.iox2_waitset_run_error_e)
    end
    return _waitset_run_result(handler)
end

function wait_and_process_once(f::Function, waitset::Waitset)
    return wait_and_process_once(waitset, WaitsetHandler(f))
end

function wait_and_process_once(waitset::Waitset, handler::AbstractWaitsetHandler)
    _require_valid(unsafe_handle(waitset), "waitset")
    handler_ref = Ref(handler)
    result_ref = Ref{Iceoryx2FFI.iox2_waitset_run_result_e}()
    GC.@preserve handler_ref begin
        ret = Iceoryx2FFI.iox2_waitset_wait_and_process_once(
            Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset)),
            _waitset_cfunction(handler),
            handler_ref,
            result_ref,
        )
        check_ok(ret, Iceoryx2FFI.iox2_waitset_run_error_e)
    end
    return result_ref[]
end

function wait_and_process_once(waitset::Waitset, seconds::Integer, nanoseconds::Integer, handler::WaitsetHandler)
    _require_valid(unsafe_handle(waitset), "waitset")
    handler_ref = handler.ref
    GC.@preserve handler_ref begin
        ret = Iceoryx2FFI.iox2_waitset_wait_and_process_once_with_timeout(
            Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset)),
            _waitset_cfunction(handler),
            handler_ref,
            UInt64(seconds),
            UInt32(nanoseconds),
            handler.result_ref,
        )
        check_ok(ret, Iceoryx2FFI.iox2_waitset_run_error_e)
    end
    return _waitset_run_result(handler)
end

function wait_and_process_once(f::Function, waitset::Waitset, seconds::Integer, nanoseconds::Integer)
    return wait_and_process_once(waitset, seconds, nanoseconds, WaitsetHandler(f))
end

function wait_and_process_once(waitset::Waitset, seconds::Integer, nanoseconds::Integer, handler::AbstractWaitsetHandler)
    _require_valid(unsafe_handle(waitset), "waitset")
    handler_ref = Ref(handler)
    result_ref = Ref{Iceoryx2FFI.iox2_waitset_run_result_e}()
    GC.@preserve handler_ref begin
        ret = Iceoryx2FFI.iox2_waitset_wait_and_process_once_with_timeout(
            Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset)),
            _waitset_cfunction(handler),
            handler_ref,
            UInt64(seconds),
            UInt32(nanoseconds),
            result_ref,
        )
        check_ok(ret, Iceoryx2FFI.iox2_waitset_run_error_e)
    end
    return result_ref[]
end

function wait_and_process(waitset::Waitset, handler::WaitsetHandler)
    _require_valid(unsafe_handle(waitset), "waitset")
    handler_ref = handler.ref
    GC.@preserve handler_ref begin
        ret = Iceoryx2FFI.iox2_waitset_wait_and_process(
            Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset)),
            _waitset_cfunction(handler),
            handler_ref,
            handler.result_ref,
        )
        check_ok(ret, Iceoryx2FFI.iox2_waitset_run_error_e)
    end
    return _waitset_run_result(handler)
end

function wait_and_process(f::Function, waitset::Waitset)
    return wait_and_process(waitset, WaitsetHandler(f))
end

function wait_and_process(waitset::Waitset, handler::AbstractWaitsetHandler)
    _require_valid(unsafe_handle(waitset), "waitset")
    handler_ref = Ref(handler)
    result_ref = Ref{Iceoryx2FFI.iox2_waitset_run_result_e}()
    GC.@preserve handler_ref begin
        ret = Iceoryx2FFI.iox2_waitset_wait_and_process(
            Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset)),
            _waitset_cfunction(handler),
            handler_ref,
            result_ref,
        )
        check_ok(ret, Iceoryx2FFI.iox2_waitset_run_error_e)
    end
    return result_ref[]
end

function attachment_id(guard::WaitsetGuard)
    _require_valid(unsafe_handle(guard), "waitset guard")
    handle_ref = Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_waitset_attachment_id_from_guard(Ref{Iceoryx2FFI.iox2_waitset_guard_h}(unsafe_handle(guard)), C_NULL, handle_ref)
    return WaitsetAttachmentId(handle_ref[])
end

@inline function has_event_from(id::Union{WaitsetAttachmentId, WaitsetAttachmentIdRef}, guard::WaitsetGuard)
    return Iceoryx2FFI.iox2_waitset_attachment_id_has_event_from(
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(id)),
        Ref{Iceoryx2FFI.iox2_waitset_guard_h}(unsafe_handle(guard)),
    )
end

@inline function has_missed_deadline(id::Union{WaitsetAttachmentId, WaitsetAttachmentIdRef}, guard::WaitsetGuard)
    return Iceoryx2FFI.iox2_waitset_attachment_id_has_missed_deadline(
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(id)),
        Ref{Iceoryx2FFI.iox2_waitset_guard_h}(unsafe_handle(guard)),
    )
end

@inline function Base.:(==)(lhs::WaitsetAttachmentId, rhs::WaitsetAttachmentId)
    return Iceoryx2FFI.iox2_waitset_attachment_id_equal(
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(rhs)),
    )
end

@inline function Base.:(==)(lhs::WaitsetAttachmentIdRef, rhs::WaitsetAttachmentIdRef)
    return Iceoryx2FFI.iox2_waitset_attachment_id_equal(
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(rhs)),
    )
end

@inline function Base.:(==)(lhs::WaitsetAttachmentIdRef, rhs::WaitsetAttachmentId)
    return Iceoryx2FFI.iox2_waitset_attachment_id_equal(
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(rhs)),
    )
end

@inline Base.:(==)(lhs::WaitsetAttachmentId, rhs::WaitsetAttachmentIdRef) = rhs == lhs

@inline function Base.isless(lhs::WaitsetAttachmentId, rhs::WaitsetAttachmentId)
    return Iceoryx2FFI.iox2_waitset_attachment_id_less(
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(rhs)),
    )
end

@inline function Base.isless(lhs::WaitsetAttachmentIdRef, rhs::WaitsetAttachmentIdRef)
    return Iceoryx2FFI.iox2_waitset_attachment_id_less(
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(rhs)),
    )
end

@inline function Base.isless(lhs::WaitsetAttachmentIdRef, rhs::WaitsetAttachmentId)
    return Iceoryx2FFI.iox2_waitset_attachment_id_less(
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(rhs)),
    )
end

@inline function Base.isless(lhs::WaitsetAttachmentId, rhs::WaitsetAttachmentIdRef)
    return Iceoryx2FFI.iox2_waitset_attachment_id_less(
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(rhs)),
    )
end

function debug_string(id::WaitsetAttachmentId)
    len = Iceoryx2FFI.iox2_waitset_attachment_id_debug_len(Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(id)))
    buf = Vector{UInt8}(undef, Int(len))
    ok = Iceoryx2FFI.iox2_waitset_attachment_id_debug(
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(id)),
        pointer(buf),
        Iceoryx2FFI.c_size_t(len),
    )
    ok || return ""
    return unsafe_string(pointer(buf))
end
