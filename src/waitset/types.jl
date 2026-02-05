# Waitset guard and attachment types with service-typed ownership.

"""
    WaitsetAttachmentId{S}

Opaque attachment identifier used with waitset guards for event queries.
"""
mutable struct WaitsetAttachmentId{S}
    handle::Iceoryx2FFI.iox2_waitset_attachment_id_h
    function WaitsetAttachmentId{S}(handle::Iceoryx2FFI.iox2_waitset_attachment_id_h) where {S}
        obj = new{S}(handle)
        finalizer(Base.close, obj)
        return obj
    end
end

@inline unsafe_handle(obj::WaitsetAttachmentId) = obj.handle
@inline Base.isvalid(obj::WaitsetAttachmentId) = obj.handle != _IOX2_NULL
@inline invalidate!(obj::WaitsetAttachmentId) = (obj.handle = _IOX2_NULL)

function Base.close(obj::WaitsetAttachmentId)
    if obj.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_waitset_attachment_id_drop(obj.handle)
        obj.handle = _IOX2_NULL
    end
    return nothing
end

"""
    WaitsetGuard{S}

Guard object used to attach to a `Waitset{S}` and signal events.
"""
mutable struct WaitsetGuard{S}
    handle::Iceoryx2FFI.iox2_waitset_guard_h
    function WaitsetGuard{S}(handle::Iceoryx2FFI.iox2_waitset_guard_h) where {S}
        obj = new{S}(handle)
        finalizer(Base.close, obj)
        return obj
    end
end

@inline unsafe_handle(obj::WaitsetGuard) = obj.handle
@inline Base.isvalid(obj::WaitsetGuard) = obj.handle != _IOX2_NULL
@inline invalidate!(obj::WaitsetGuard) = (obj.handle = _IOX2_NULL)

function Base.close(obj::WaitsetGuard)
    if obj.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_waitset_guard_drop(obj.handle)
        obj.handle = _IOX2_NULL
    end
    return nothing
end
