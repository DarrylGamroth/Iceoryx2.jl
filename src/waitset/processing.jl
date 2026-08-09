"""
    AbstractWaitSetHandler

Abstract callback handler for waitset processing.
"""
abstract type AbstractWaitSetHandler end

function on_waitset_event(::AbstractWaitSetHandler)
    throw(ArgumentError("WaitSet handler must implement on_waitset_event(handler)"))
end

"""
    WaitSetHandler(f, waitset)
    WaitSetHandler(f, ::Type{S})

Wrap a callable `f(attachment_id)` for use with `wait_and_process*`.
"""
mutable struct WaitSetHandler{S, T} <: AbstractWaitSetHandler
    on_event::T
    attachment::WaitSetAttachmentId{S}
    ref::Base.RefValue{WaitSetHandler{S, T}}
    result_ref::Base.RefValue{Iceoryx2FFI.iox2_waitset_run_result_e}
    result_ptr::Ptr{Iceoryx2FFI.iox2_waitset_run_result_e}
    last_exception::Base.RefValue{_CallbackException}
    function WaitSetHandler{S}(on_event::T) where {S, T}
        obj = new{S, T}(
            on_event,
            WaitSetAttachmentId{S}(_IOX2_NULL),
            Ref{WaitSetHandler{S, T}}(),
            Ref{Iceoryx2FFI.iox2_waitset_run_result_e}(),
            C_NULL,
            _callback_exception_ref()
        )
        obj.ref[] = obj
        obj.result_ptr = Base.unsafe_convert(Ptr{Iceoryx2FFI.iox2_waitset_run_result_e}, obj.result_ref)
        return obj
    end
end

WaitSetHandler(on_event::T, ::Type{S}) where {S, T} = WaitSetHandler{S}(on_event)

WaitSetHandler(on_event::T, waitset::WaitSet{S}) where {S, T} = WaitSetHandler{S}(on_event)

on_waitset_event(h::WaitSetHandler) = h.on_event
@inline last_callback_exception(handler::WaitSetHandler) = handler.last_exception[]

@inline function _waitset_attachment_cleanup!(attachment::WaitSetAttachmentId)
    if attachment.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_waitset_attachment_id_drop(attachment.handle)
        attachment.handle = _IOX2_NULL
    end
    return nothing
end

@inline function _waitset_wrapper(attachment::Iceoryx2FFI.iox2_waitset_attachment_id_h, handler::WaitSetHandler)
    handler.attachment.handle = attachment
    try
        return _callback_progression(on_waitset_event(handler)(handler.attachment))
    catch err
        _record_callback_exception!(handler, err)
        return Iceoryx2FFI.iox2_callback_progression_e_STOP
    finally
        _waitset_attachment_cleanup!(handler.attachment)
    end
end

function _waitset_cfunction(::T) where {T <: AbstractWaitSetHandler}
    @cfunction(_waitset_wrapper,
        Iceoryx2FFI.iox2_callback_progression_e,
        (Iceoryx2FFI.iox2_waitset_attachment_id_h, Ref{T}),)
end

@inline function _waitset_run_result(handler::WaitSetHandler)
    return _waitset_run_result_enum(unsafe_load(handler.result_ptr))
end

"""
    wait_and_process_once(waitset, handler) -> WaitSetRunResult

Wait for one event and process it with `handler`.
"""
function wait_and_process_once(waitset::WaitSet{S}, handler::WaitSetHandler{S}) where {S}
    _require_valid(unsafe_handle(waitset), "waitset")
    _clear_callback_exception!(handler)
    handler_ref = handler.ref
    GC.@preserve handler_ref begin
        ret = Iceoryx2FFI.iox2_waitset_wait_and_process_once(
            Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset)),
            _waitset_cfunction(handler),
            handler_ref,
            handler.result_ref
        )
        check_ok(ret, Iceoryx2FFI.iox2_waitset_run_error_e)
    end
    _rethrow_callback_exception!(handler)
    return _waitset_run_result(handler)
end

"""
    wait_and_process_once(f::Function, waitset::WaitSet)

`do`-block variant for a single wait-and-process iteration.
"""
function wait_and_process_once(f::Function, waitset::WaitSet{S}) where {S}
    return wait_and_process_once(waitset, WaitSetHandler{S}(f))
end

function wait_and_process_once(waitset::WaitSet{S}, handler::AbstractWaitSetHandler) where {S}
    return wait_and_process_once(waitset, WaitSetHandler{S}(on_waitset_event(handler)))
end

"""
    wait_and_process_once(waitset, seconds, nanoseconds, handler)

Wait with timeout and process at most one event.
"""
function wait_and_process_once(waitset::WaitSet{S}, seconds::Integer,
        nanoseconds::Integer, handler::WaitSetHandler{S}) where {S}
    _require_valid(unsafe_handle(waitset), "waitset")
    secs, nanos = _timeout_parts(seconds, nanoseconds)
    _clear_callback_exception!(handler)
    handler_ref = handler.ref
    GC.@preserve handler_ref begin
        ret = Iceoryx2FFI.iox2_waitset_wait_and_process_once_with_timeout(
            Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset)),
            _waitset_cfunction(handler),
            handler_ref,
            secs,
            nanos,
            handler.result_ref
        )
        check_ok(ret, Iceoryx2FFI.iox2_waitset_run_error_e)
    end
    _rethrow_callback_exception!(handler)
    return _waitset_run_result(handler)
end

"""
    wait_and_process_once(f::Function, waitset::WaitSet, seconds, nanoseconds)

`do`-block variant with timeout.
"""
function wait_and_process_once(
        f::Function, waitset::WaitSet{S}, seconds::Integer, nanoseconds::Integer) where {S}
    return wait_and_process_once(waitset, seconds, nanoseconds, WaitSetHandler{S}(f))
end

function wait_and_process_once(waitset::WaitSet{S}, seconds::Integer, nanoseconds::Integer,
        handler::AbstractWaitSetHandler) where {S}
    return wait_and_process_once(waitset, seconds, nanoseconds, WaitSetHandler{S}(on_waitset_event(handler)))
end

"""
    wait_and_process(waitset, handler) -> WaitSetRunResult

Block and process events until the WaitSet run result indicates termination.
"""
function wait_and_process(waitset::WaitSet{S}, handler::WaitSetHandler{S}) where {S}
    _require_valid(unsafe_handle(waitset), "waitset")
    _clear_callback_exception!(handler)
    handler_ref = handler.ref
    GC.@preserve handler_ref begin
        ret = Iceoryx2FFI.iox2_waitset_wait_and_process(
            Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset)),
            _waitset_cfunction(handler),
            handler_ref,
            handler.result_ref
        )
        check_ok(ret, Iceoryx2FFI.iox2_waitset_run_error_e)
    end
    _rethrow_callback_exception!(handler)
    return _waitset_run_result(handler)
end

"""
    wait_and_process(f::Function, waitset::WaitSet)

`do`-block variant for `wait_and_process`.
"""
function wait_and_process(f::Function, waitset::WaitSet{S}) where {S}
    return wait_and_process(waitset, WaitSetHandler{S}(f))
end

function wait_and_process(waitset::WaitSet{S}, handler::AbstractWaitSetHandler) where {S}
    return wait_and_process(waitset, WaitSetHandler{S}(on_waitset_event(handler)))
end

"""
    attachment_id(guard::WaitSetGuard) -> WaitSetAttachmentId

Create an attachment ID from a guard for querying events.
"""
function attachment_id(guard::WaitSetGuard{S}) where {S}
    _require_valid(unsafe_handle(guard), "WaitSet guard")
    handle_ref = Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_waitset_attachment_id_from_guard(
        Ref{Iceoryx2FFI.iox2_waitset_guard_h}(unsafe_handle(guard)), C_NULL, handle_ref)
    return WaitSetAttachmentId{S}(handle_ref[])
end

"""
    has_event_from(id, guard) -> Bool

Return whether `guard` signaled the attachment.
"""
@inline function has_event_from(id::Union{WaitSetAttachmentId{S}, WaitSetAttachmentIdRef},
        guard::WaitSetGuard{S}) where {S}
    return Iceoryx2FFI.iox2_waitset_attachment_id_has_event_from(
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(id)),
        Ref{Iceoryx2FFI.iox2_waitset_guard_h}(unsafe_handle(guard))
    )
end

"""
    has_missed_deadline(id, guard) -> Bool

Return whether the attachment missed its deadline.
"""
@inline function has_missed_deadline(
        id::Union{WaitSetAttachmentId{S}, WaitSetAttachmentIdRef},
        guard::WaitSetGuard{S}) where {S}
    return Iceoryx2FFI.iox2_waitset_attachment_id_has_missed_deadline(
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(id)),
        Ref{Iceoryx2FFI.iox2_waitset_guard_h}(unsafe_handle(guard))
    )
end

@inline function Base.:(==)(lhs::WaitSetAttachmentId{S}, rhs::WaitSetAttachmentId{S}) where {S}
    return Iceoryx2FFI.iox2_waitset_attachment_id_equal(
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(rhs))
    )
end

@inline function Base.:(==)(lhs::WaitSetAttachmentIdRef, rhs::WaitSetAttachmentIdRef)
    return Iceoryx2FFI.iox2_waitset_attachment_id_equal(
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(rhs))
    )
end

@inline function Base.:(==)(lhs::WaitSetAttachmentIdRef, rhs::WaitSetAttachmentId{S}) where {S}
    return Iceoryx2FFI.iox2_waitset_attachment_id_equal(
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(rhs))
    )
end

@inline Base.:(==)(lhs::WaitSetAttachmentId{S}, rhs::WaitSetAttachmentIdRef) where {S} = rhs ==
                                                                                         lhs

@inline function Base.isless(lhs::WaitSetAttachmentId{S}, rhs::WaitSetAttachmentId{S}) where {S}
    return Iceoryx2FFI.iox2_waitset_attachment_id_less(
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(rhs))
    )
end

@inline function Base.isless(lhs::WaitSetAttachmentIdRef, rhs::WaitSetAttachmentIdRef)
    return Iceoryx2FFI.iox2_waitset_attachment_id_less(
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(rhs))
    )
end

@inline function Base.isless(lhs::WaitSetAttachmentIdRef, rhs::WaitSetAttachmentId{S}) where {S}
    return Iceoryx2FFI.iox2_waitset_attachment_id_less(
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(rhs))
    )
end

@inline function Base.isless(lhs::WaitSetAttachmentId{S}, rhs::WaitSetAttachmentIdRef) where {S}
    return Iceoryx2FFI.iox2_waitset_attachment_id_less(
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(rhs))
    )
end

function debug_string(id::WaitSetAttachmentId{S}) where {S}
    len = Iceoryx2FFI.iox2_waitset_attachment_id_debug_len(Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(id)))
    buf = Vector{UInt8}(undef, Int(len))
    ok = Iceoryx2FFI.iox2_waitset_attachment_id_debug(
        Ref{Iceoryx2FFI.iox2_waitset_attachment_id_h}(unsafe_handle(id)),
        pointer(buf),
        Iceoryx2FFI.c_size_t(len)
    )
    ok || return ""
    return unsafe_string(pointer(buf))
end
