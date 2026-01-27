# WaitSet wrappers.

using FunctionWrappers: FunctionWrapper

@inline function _signal_handling_mode(value)
    if value isa Iceoryx2FFI.iox2_signal_handling_mode_e
        return value
    elseif value === :handle_termination_requests
        return Iceoryx2FFI.iox2_signal_handling_mode_e_HANDLE_TERMINATION_REQUESTS
    elseif value === :disabled
        return Iceoryx2FFI.iox2_signal_handling_mode_e_DISABLED
    end
    throw(ArgumentError("unsupported signal handling mode: $value"))
end

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

@inline function signal_handling_mode(waitset::Waitset)
    return Iceoryx2FFI.iox2_waitset_signal_handling_mode(Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset)))
end

@inline function is_empty(waitset::Waitset)
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

struct _WaitsetCallbackCtx
    fn::FunctionWrapper{Iceoryx2FFI.iox2_callback_progression_e, Tuple{WaitsetAttachmentId}}
end

function _waitset_trampoline(attachment::Iceoryx2FFI.iox2_waitset_attachment_id_h, ctx::Ptr{Cvoid})::Iceoryx2FFI.iox2_callback_progression_e
    ctx_ref = unsafe_pointer_to_objref(ctx)::_WaitsetCallbackCtx
    return ctx_ref.fn(WaitsetAttachmentId(attachment))
end

const _WAITSET_CB = @cfunction(
    _waitset_trampoline,
    Iceoryx2FFI.iox2_callback_progression_e,
    (Iceoryx2FFI.iox2_waitset_attachment_id_h, Ptr{Cvoid}),
)

function wait_and_process_once(waitset::Waitset, f::Function)
    _require_valid(unsafe_handle(waitset), "waitset")
    result = Ref{Iceoryx2FFI.iox2_waitset_run_result_e}()
    let user_f = f
        ctx = _WaitsetCallbackCtx(FunctionWrapper{Iceoryx2FFI.iox2_callback_progression_e, Tuple{WaitsetAttachmentId}}(attachment -> _callback_progression(user_f(attachment))))
        ctx_ref = Ref(ctx)
        GC.@preserve ctx_ref begin
            ret = Iceoryx2FFI.iox2_waitset_wait_and_process_once(
                Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset)),
                _WAITSET_CB,
                Base.unsafe_convert(Ptr{Cvoid}, ctx_ref),
                result,
            )
            check_ok(ret, Iceoryx2FFI.iox2_waitset_run_error_e)
        end
    end
    return result[]
end

function wait_and_process_once(waitset::Waitset, seconds::Integer, nanoseconds::Integer, f::Function)
    _require_valid(unsafe_handle(waitset), "waitset")
    result = Ref{Iceoryx2FFI.iox2_waitset_run_result_e}()
    let user_f = f
        ctx = _WaitsetCallbackCtx(FunctionWrapper{Iceoryx2FFI.iox2_callback_progression_e, Tuple{WaitsetAttachmentId}}(attachment -> _callback_progression(user_f(attachment))))
        ctx_ref = Ref(ctx)
        GC.@preserve ctx_ref begin
            ret = Iceoryx2FFI.iox2_waitset_wait_and_process_once_with_timeout(
                Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset)),
                _WAITSET_CB,
                Base.unsafe_convert(Ptr{Cvoid}, ctx_ref),
                UInt64(seconds),
                UInt32(nanoseconds),
                result,
            )
            check_ok(ret, Iceoryx2FFI.iox2_waitset_run_error_e)
        end
    end
    return result[]
end

function wait_and_process(waitset::Waitset, f::Function)
    _require_valid(unsafe_handle(waitset), "waitset")
    result = Ref{Iceoryx2FFI.iox2_waitset_run_result_e}()
    let user_f = f
        ctx = _WaitsetCallbackCtx(FunctionWrapper{Iceoryx2FFI.iox2_callback_progression_e, Tuple{WaitsetAttachmentId}}(attachment -> _callback_progression(user_f(attachment))))
        ctx_ref = Ref(ctx)
        GC.@preserve ctx_ref begin
            ret = Iceoryx2FFI.iox2_waitset_wait_and_process(
                Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset)),
                _WAITSET_CB,
                Base.unsafe_convert(Ptr{Cvoid}, ctx_ref),
                result,
            )
            check_ok(ret, Iceoryx2FFI.iox2_waitset_run_error_e)
        end
    end
    return result[]
end

function attachment_id(guard::WaitsetGuard)
    _require_valid(unsafe_handle(guard), "waitset guard")
    handle_ref = Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_waitset_attachment_id_from_guard(Ref{Iceoryx2FFI.iox2_waitset_guard_h}(unsafe_handle(guard)), C_NULL, handle_ref)
    return WaitsetAttachmentId(handle_ref[])
end

@inline function has_event_from(id::WaitsetAttachmentId, guard::WaitsetGuard)
    return Iceoryx2FFI.iox2_waitset_attachment_id_has_event_from(
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(id)),
        Ref{Iceoryx2FFI.iox2_waitset_guard_h}(unsafe_handle(guard)),
    )
end

@inline function has_missed_deadline(id::WaitsetAttachmentId, guard::WaitsetGuard)
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

@inline function Base.isless(lhs::WaitsetAttachmentId, rhs::WaitsetAttachmentId)
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
