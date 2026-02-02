abstract type AbstractWaitsetHandler end

on_waitset_event(::AbstractWaitsetHandler) =
    throw(ArgumentError("Waitset handler must implement on_waitset_event(handler)"))

mutable struct WaitsetHandler{S,T} <: AbstractWaitsetHandler
    on_event::T
    attachment::WaitsetAttachmentId{S}
    ref::Base.RefValue{WaitsetHandler{S,T}}
    result_ref::Base.RefValue{Iceoryx2FFI.iox2_waitset_run_result_e}
    result_ptr::Ptr{Iceoryx2FFI.iox2_waitset_run_result_e}
    function WaitsetHandler{S}(on_event::T) where {S,T}
        obj = new{S,T}(
            on_event,
            WaitsetAttachmentId{S}(_IOX2_NULL),
            Ref{WaitsetHandler{S,T}}(),
            Ref{Iceoryx2FFI.iox2_waitset_run_result_e}(),
            C_NULL,
        )
        obj.ref[] = obj
        obj.result_ptr = Base.unsafe_convert(Ptr{Iceoryx2FFI.iox2_waitset_run_result_e}, obj.result_ref)
        return obj
    end
end

WaitsetHandler(on_event::T, ::Type{S}) where {S,T} = WaitsetHandler{S}(on_event)

WaitsetHandler(on_event::T, waitset::Waitset{S}) where {S,T} = WaitsetHandler{S}(on_event)

WaitsetHandler(on_event::T) where {T} = WaitsetHandler{ServiceType.IPC}(on_event)

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

function wait_and_process_once(waitset::Waitset{S}, handler::WaitsetHandler{S}) where {S}
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

function wait_and_process_once(f::Function, waitset::Waitset{S}) where {S}
    return wait_and_process_once(waitset, WaitsetHandler{S}(f))
end

function wait_and_process_once(waitset::Waitset{S}, handler::AbstractWaitsetHandler) where {S}
    return wait_and_process_once(waitset, WaitsetHandler{S}(on_waitset_event(handler)))
end

function wait_and_process_once(waitset::Waitset{S}, seconds::Integer, nanoseconds::Integer, handler::WaitsetHandler{S}) where {S}
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

function wait_and_process_once(f::Function, waitset::Waitset{S}, seconds::Integer, nanoseconds::Integer) where {S}
    return wait_and_process_once(waitset, seconds, nanoseconds, WaitsetHandler{S}(f))
end

function wait_and_process_once(waitset::Waitset{S}, seconds::Integer, nanoseconds::Integer, handler::AbstractWaitsetHandler) where {S}
    return wait_and_process_once(waitset, seconds, nanoseconds, WaitsetHandler{S}(on_waitset_event(handler)))
end

function wait_and_process(waitset::Waitset{S}, handler::WaitsetHandler{S}) where {S}
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

function wait_and_process(f::Function, waitset::Waitset{S}) where {S}
    return wait_and_process(waitset, WaitsetHandler{S}(f))
end

function wait_and_process(waitset::Waitset{S}, handler::AbstractWaitsetHandler) where {S}
    return wait_and_process(waitset, WaitsetHandler{S}(on_waitset_event(handler)))
end

function attachment_id(guard::WaitsetGuard{S}) where {S}
    _require_valid(unsafe_handle(guard), "waitset guard")
    handle_ref = Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_waitset_attachment_id_from_guard(Ref{Iceoryx2FFI.iox2_waitset_guard_h}(unsafe_handle(guard)), C_NULL, handle_ref)
    return WaitsetAttachmentId{S}(handle_ref[])
end

@inline function has_event_from(id::Union{WaitsetAttachmentId{S}, WaitsetAttachmentIdRef}, guard::WaitsetGuard{S}) where {S}
    return Iceoryx2FFI.iox2_waitset_attachment_id_has_event_from(
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(id)),
        Ref{Iceoryx2FFI.iox2_waitset_guard_h}(unsafe_handle(guard)),
    )
end

@inline function has_missed_deadline(id::Union{WaitsetAttachmentId{S}, WaitsetAttachmentIdRef}, guard::WaitsetGuard{S}) where {S}
    return Iceoryx2FFI.iox2_waitset_attachment_id_has_missed_deadline(
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(id)),
        Ref{Iceoryx2FFI.iox2_waitset_guard_h}(unsafe_handle(guard)),
    )
end

@inline function Base.:(==)(lhs::WaitsetAttachmentId{S}, rhs::WaitsetAttachmentId{S}) where {S}
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

@inline function Base.:(==)(lhs::WaitsetAttachmentIdRef, rhs::WaitsetAttachmentId{S}) where {S}
    return Iceoryx2FFI.iox2_waitset_attachment_id_equal(
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(rhs)),
    )
end

@inline Base.:(==)(lhs::WaitsetAttachmentId{S}, rhs::WaitsetAttachmentIdRef) where {S} = rhs == lhs

@inline function Base.isless(lhs::WaitsetAttachmentId{S}, rhs::WaitsetAttachmentId{S}) where {S}
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

@inline function Base.isless(lhs::WaitsetAttachmentIdRef, rhs::WaitsetAttachmentId{S}) where {S}
    return Iceoryx2FFI.iox2_waitset_attachment_id_less(
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(rhs)),
    )
end

@inline function Base.isless(lhs::WaitsetAttachmentId{S}, rhs::WaitsetAttachmentIdRef) where {S}
    return Iceoryx2FFI.iox2_waitset_attachment_id_less(
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(rhs)),
    )
end

function debug_string(id::WaitsetAttachmentId{S}) where {S}
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
