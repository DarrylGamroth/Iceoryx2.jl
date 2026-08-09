# WaitSet guard and attachment types with service-typed ownership.

"""
    WaitSetAttachmentId{S}

Opaque attachment identifier used with WaitSet guards for event queries.
"""
mutable struct WaitSetAttachmentId{S}
    handle::Iceoryx2FFI.iox2_waitset_attachment_id_h
    function WaitSetAttachmentId{S}(handle::Iceoryx2FFI.iox2_waitset_attachment_id_h) where {S}
        obj = new{S}(handle)
        finalizer(Base.close, obj)
        return obj
    end
end

@inline unsafe_handle(obj::WaitSetAttachmentId) = obj.handle
@inline Base.isvalid(obj::WaitSetAttachmentId) = obj.handle != _IOX2_NULL
@inline invalidate!(obj::WaitSetAttachmentId) = (obj.handle = _IOX2_NULL)

function Base.close(obj::WaitSetAttachmentId)
    if obj.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_waitset_attachment_id_drop(obj.handle)
        obj.handle = _IOX2_NULL
    end
    return nothing
end

"""
    WaitSetGuard{S}

Guard object used to attach to a `WaitSet{S}` and signal events.
"""
mutable struct WaitSetGuard{S}
    handle::Iceoryx2FFI.iox2_waitset_guard_h
    function WaitSetGuard{S}(handle::Iceoryx2FFI.iox2_waitset_guard_h) where {S}
        obj = new{S}(handle)
        finalizer(Base.close, obj)
        return obj
    end
end

@inline unsafe_handle(obj::WaitSetGuard) = obj.handle
@inline Base.isvalid(obj::WaitSetGuard) = obj.handle != _IOX2_NULL
@inline invalidate!(obj::WaitSetGuard) = (obj.handle = _IOX2_NULL)

function Base.close(obj::WaitSetGuard)
    if obj.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_waitset_guard_drop(obj.handle)
        obj.handle = _IOX2_NULL
    end
    return nothing
end
