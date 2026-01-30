# === Event ===

### builder tuning setters generated in src/generated/wrappers.jl

mutable struct PortFactoryEvent{S}
    handle::Iceoryx2FFI.iox2_port_factory_event_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_event_t}
    keepalive::Node{S}
    function PortFactoryEvent{S}(handle, storage, keepalive) where {S}
        obj = new{S}(handle, storage, keepalive)
        finalizer(_finalize_port_factory_event, obj)
        return obj
    end
end

function _finalize_port_factory_event(factory::PortFactoryEvent)
    if factory.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_port_factory_event_drop(factory.handle)
        factory.handle = _IOX2_NULL
    end
    factory.storage = nothing
    return nothing
end

### port factory view accessors generated in src/generated/wrappers.jl

function service_id(factory::PortFactoryEvent)
    _require_valid(factory.handle, "event port factory")
    buf_len = Int(Iceoryx2FFI.IOX2_SERVICE_ID_LENGTH)
    buffer = Vector{UInt8}(undef, buf_len + 1)
    GC.@preserve buffer begin
        Iceoryx2FFI.iox2_port_factory_event_service_id(
            Ref{Iceoryx2FFI.iox2_port_factory_event_h}(factory.handle),
            Ptr{Cchar}(pointer(buffer)),
            Iceoryx2FFI.c_size_t(buf_len + 1),
        )
    end
    return _string_from_buffer(buffer)
end

### port factory view accessors generated in src/generated/wrappers.jl

function open_or_create(builder::EventServiceBuilder{S}) where {S}
    _require_valid(builder.handle, "event service builder")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_event_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_event_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_event_open_or_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_event_open_or_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    return PortFactoryEvent{S}(handle_ref[], storage, builder.keepalive)
end

function open_or_create(builder::EventServiceBuilder{S}, verifier::AttributeVerifier) where {S}
    _require_valid(builder.handle, "event service builder")
    _require_valid(unsafe_handle(verifier), "attribute verifier")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_event_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_event_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_event_open_or_create_with_attributes(
        builder.handle,
        Ref{Iceoryx2FFI.iox2_attribute_verifier_h}(unsafe_handle(verifier)),
        storage,
        handle_ref,
    )
    check_ok(ret, Iceoryx2FFI.iox2_event_open_or_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    return PortFactoryEvent{S}(handle_ref[], storage, builder.keepalive)
end

function open_or_create(f::Function, builder::EventServiceBuilder{S}) where {S}
    factory = open_or_create(builder)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function open_or_create(f::Function, builder::EventServiceBuilder{S}, verifier::AttributeVerifier) where {S}
    factory = open_or_create(builder, verifier)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function open(builder::EventServiceBuilder{S}) where {S}
    _require_valid(builder.handle, "event service builder")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_event_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_event_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_event_open(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_event_open_or_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    return PortFactoryEvent{S}(handle_ref[], storage, builder.keepalive)
end

function open(builder::EventServiceBuilder{S}, verifier::AttributeVerifier) where {S}
    _require_valid(builder.handle, "event service builder")
    _require_valid(unsafe_handle(verifier), "attribute verifier")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_event_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_event_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_event_open_with_attributes(
        builder.handle,
        Ref{Iceoryx2FFI.iox2_attribute_verifier_h}(unsafe_handle(verifier)),
        storage,
        handle_ref,
    )
    check_ok(ret, Iceoryx2FFI.iox2_event_open_or_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    return PortFactoryEvent{S}(handle_ref[], storage, builder.keepalive)
end

function open(f::Function, builder::EventServiceBuilder{S}) where {S}
    factory = open(builder)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function open(f::Function, builder::EventServiceBuilder{S}, verifier::AttributeVerifier) where {S}
    factory = open(builder, verifier)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function create(builder::EventServiceBuilder{S}) where {S}
    _require_valid(builder.handle, "event service builder")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_event_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_event_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_event_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_event_open_or_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    return PortFactoryEvent{S}(handle_ref[], storage, builder.keepalive)
end

function create(builder::EventServiceBuilder{S}, specifier::AttributeSpecifier) where {S}
    _require_valid(builder.handle, "event service builder")
    _require_valid(unsafe_handle(specifier), "attribute specifier")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_event_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_event_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_event_create_with_attributes(
        builder.handle,
        Ref{Iceoryx2FFI.iox2_attribute_specifier_h}(unsafe_handle(specifier)),
        storage,
        handle_ref,
    )
    check_ok(ret, Iceoryx2FFI.iox2_event_open_or_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    return PortFactoryEvent{S}(handle_ref[], storage, builder.keepalive)
end

function create(f::Function, builder::EventServiceBuilder{S}) where {S}
    factory = create(builder)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function create(f::Function, builder::EventServiceBuilder{S}, specifier::AttributeSpecifier) where {S}
    factory = create(builder, specifier)
    try
        return f(factory)
    finally
        close(factory)
    end
end

open_or_create_with_attributes(builder::EventServiceBuilder{S}, verifier::AttributeVerifier) where {S} = open_or_create(builder, verifier)
open_or_create_with_attributes(f::Function, builder::EventServiceBuilder{S}, verifier::AttributeVerifier) where {S} = open_or_create(f, builder, verifier)
open_with_attributes(builder::EventServiceBuilder{S}, verifier::AttributeVerifier) where {S} = open(builder, verifier)
open_with_attributes(f::Function, builder::EventServiceBuilder{S}, verifier::AttributeVerifier) where {S} = open(f, builder, verifier)
create_with_attributes(builder::EventServiceBuilder{S}, specifier::AttributeSpecifier) where {S} = create(builder, specifier)
create_with_attributes(f::Function, builder::EventServiceBuilder{S}, specifier::AttributeSpecifier) where {S} = create(f, builder, specifier)

mutable struct NotifierBuilder{S}
    handle::Iceoryx2FFI.iox2_port_factory_notifier_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_notifier_builder_t}
    keepalive::PortFactoryEvent{S}
    function NotifierBuilder{S}(handle, storage, keepalive) where {S}
        obj = new{S}(handle, storage, keepalive)
        finalizer(_finalize_notifier_builder, obj)
        return obj
    end
end

function _finalize_notifier_builder(builder::NotifierBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

function notifier_builder(factory::PortFactoryEvent{S}) where {S}
    _require_valid(factory.handle, "event port factory")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_notifier_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_event_notifier_builder(Ref{Iceoryx2FFI.iox2_port_factory_event_h}(factory.handle), storage)
    return NotifierBuilder{S}(handle, storage, factory)
end

function default_event_id!(builder::NotifierBuilder, id::EventId)
    _require_valid(builder.handle, "notifier builder")
    id_ref = Ref(id.raw)
    GC.@preserve id_ref begin
        Iceoryx2FFI.iox2_port_factory_notifier_builder_set_default_event_id(
            Ref{Iceoryx2FFI.iox2_port_factory_notifier_builder_h}(builder.handle),
            Base.unsafe_convert(Ptr{Iceoryx2FFI.iox2_event_id_t}, id_ref),
        )
    end
    return builder
end

mutable struct ListenerBuilder{S}
    handle::Iceoryx2FFI.iox2_port_factory_listener_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_listener_builder_t}
    keepalive::PortFactoryEvent{S}
    function ListenerBuilder{S}(handle, storage, keepalive) where {S}
        obj = new{S}(handle, storage, keepalive)
        finalizer(_finalize_listener_builder, obj)
        return obj
    end
end

function _finalize_listener_builder(builder::ListenerBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

function listener_builder(factory::PortFactoryEvent{S}) where {S}
    _require_valid(factory.handle, "event port factory")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_listener_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_event_listener_builder(Ref{Iceoryx2FFI.iox2_port_factory_event_h}(factory.handle), storage)
    return ListenerBuilder{S}(handle, storage, factory)
end

mutable struct Notifier{S}
    handle::Iceoryx2FFI.iox2_notifier_h
    storage::_StorageRef{Iceoryx2FFI.iox2_notifier_t}
    keepalive::PortFactoryEvent{S}
    function Notifier{S}(handle, storage, keepalive) where {S}
        obj = new{S}(handle, storage, keepalive)
        finalizer(_finalize_notifier, obj)
        return obj
    end
end

function _finalize_notifier(notifier::Notifier)
    if notifier.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_notifier_drop(notifier.handle)
        notifier.handle = _IOX2_NULL
    end
    notifier.storage = nothing
    return nothing
end

function create(builder::NotifierBuilder{S}) where {S}
    _require_valid(builder.handle, "notifier builder")
    storage = Ref{Iceoryx2FFI.iox2_notifier_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_notifier_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_notifier_builder_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_notifier_create_error_e)
    _finalize_notifier_builder(builder)
    return Notifier{S}(handle_ref[], storage, builder.keepalive)
end

function create(f::Function, builder::NotifierBuilder{S}) where {S}
    notifier = create(builder)
    try
        return f(notifier)
    finally
        close(notifier)
    end
end

function deadline(notifier::Notifier)
    _require_valid(notifier.handle, "notifier")
    seconds = Ref{UInt64}(0)
    nanos = Ref{UInt32}(0)
    has_deadline = Iceoryx2FFI.iox2_notifier_deadline(
        Ref{Iceoryx2FFI.iox2_notifier_h}(notifier.handle),
        seconds,
        nanos,
    )
    return has_deadline ? (seconds[], nanos[]) : nothing
end

mutable struct Listener{S}
    handle::Iceoryx2FFI.iox2_listener_h
    storage::_StorageRef{Iceoryx2FFI.iox2_listener_t}
    keepalive::PortFactoryEvent{S}
    function Listener{S}(handle, storage, keepalive) where {S}
        obj = new{S}(handle, storage, keepalive)
        finalizer(_finalize_listener, obj)
        return obj
    end
end

function _finalize_listener(listener::Listener)
    if listener.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_listener_drop(listener.handle)
        listener.handle = _IOX2_NULL
    end
    listener.storage = nothing
    return nothing
end

function create(builder::ListenerBuilder{S}) where {S}
    _require_valid(builder.handle, "listener builder")
    storage = Ref{Iceoryx2FFI.iox2_listener_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_listener_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_listener_builder_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_listener_create_error_e)
    _finalize_listener_builder(builder)
    return Listener{S}(handle_ref[], storage, builder.keepalive)
end

function create(f::Function, builder::ListenerBuilder{S}) where {S}
    listener = create(builder)
    try
        return f(listener)
    finally
        close(listener)
    end
end

function deadline(listener::Listener)
    _require_valid(listener.handle, "listener")
    seconds = Ref{UInt64}(0)
    nanos = Ref{UInt32}(0)
    has_deadline = Iceoryx2FFI.iox2_listener_deadline(
        Ref{Iceoryx2FFI.iox2_listener_h}(listener.handle),
        seconds,
        nanos,
    )
    return has_deadline ? (seconds[], nanos[]) : nothing
end

function notify!(notifier::Notifier)
    count = Ref{Iceoryx2FFI.c_size_t}()
    ret = Iceoryx2FFI.iox2_notifier_notify(Ref{Iceoryx2FFI.iox2_notifier_h}(notifier.handle), count)
    check_ok(ret, Iceoryx2FFI.iox2_notifier_notify_error_e)
    return Int(count[])
end

function notify!(notifier::Notifier, id::EventId)
    count = Ref{Iceoryx2FFI.c_size_t}()
    id_ref = Ref(id.raw)
    GC.@preserve id_ref begin
        ret = Iceoryx2FFI.iox2_notifier_notify_with_custom_event_id(
            Ref{Iceoryx2FFI.iox2_notifier_h}(notifier.handle),
            Base.unsafe_convert(Ptr{Iceoryx2FFI.iox2_event_id_t}, id_ref),
            count,
        )
        check_ok(ret, Iceoryx2FFI.iox2_notifier_notify_error_e)
    end
    return Int(count[])
end

@inline notify_with_custom_event_id!(notifier::Notifier, id::EventId) = notify!(notifier, id)

abstract type AbstractListenerWaitHandler end

mutable struct ListenerWaitHandler{T} <: AbstractListenerWaitHandler
    on_event::T
end

on_listener_event(h::ListenerWaitHandler) = h.on_event

function _listener_wait_all_wrapper(event_id_ptr::Ptr{Iceoryx2FFI.iox2_event_id_t}, handler::AbstractListenerWaitHandler)
    on_listener_event(handler)(EventId(unsafe_load(event_id_ptr)))
    return
end

function _listener_wait_all_cfunction(::T) where {T<:AbstractListenerWaitHandler}
    @cfunction(_listener_wait_all_wrapper, Cvoid, (Ptr{Iceoryx2FFI.iox2_event_id_t}, Ref{T}))
end

function try_wait_all(listener::Listener, handler::AbstractListenerWaitHandler)
    _require_valid(listener.handle, "listener")
    handler_ref = Ref(handler)
    GC.@preserve handler_ref begin
        ret = Iceoryx2FFI.iox2_listener_try_wait_all(
            Ref{Iceoryx2FFI.iox2_listener_h}(listener.handle),
            _listener_wait_all_cfunction(handler_ref[]),
            handler_ref,
        )
        check_ok(ret, Iceoryx2FFI.iox2_listener_wait_error_e)
    end
    return nothing
end

function try_wait_all(f::Function, listener::Listener)
    return try_wait_all(listener, ListenerWaitHandler(f))
end

function timed_wait_all(listener::Listener, seconds::Integer, nanoseconds::Integer, handler::AbstractListenerWaitHandler)
    _require_valid(listener.handle, "listener")
    handler_ref = Ref(handler)
    GC.@preserve handler_ref begin
        ret = Iceoryx2FFI.iox2_listener_timed_wait_all(
            Ref{Iceoryx2FFI.iox2_listener_h}(listener.handle),
            _listener_wait_all_cfunction(handler_ref[]),
            handler_ref,
            UInt64(seconds),
            UInt32(nanoseconds),
        )
        check_ok(ret, Iceoryx2FFI.iox2_listener_wait_error_e)
    end
    return nothing
end

function timed_wait_all(f::Function, listener::Listener, seconds::Integer, nanoseconds::Integer)
    return timed_wait_all(listener, seconds, nanoseconds, ListenerWaitHandler(f))
end

function blocking_wait_all(listener::Listener, handler::AbstractListenerWaitHandler)
    _require_valid(listener.handle, "listener")
    handler_ref = Ref(handler)
    GC.@preserve handler_ref begin
        ret = Iceoryx2FFI.iox2_listener_blocking_wait_all(
            Ref{Iceoryx2FFI.iox2_listener_h}(listener.handle),
            _listener_wait_all_cfunction(handler_ref[]),
            handler_ref,
        )
        check_ok(ret, Iceoryx2FFI.iox2_listener_wait_error_e)
    end
    return nothing
end

function blocking_wait_all(f::Function, listener::Listener)
    return blocking_wait_all(listener, ListenerWaitHandler(f))
end

function try_wait_one(listener::Listener)
    _require_valid(listener.handle, "listener")
    event_id = Ref{Iceoryx2FFI.iox2_event_id_t}()
    has_received = Ref{Bool}(false)
    ret = Iceoryx2FFI.iox2_listener_try_wait_one(
        Ref{Iceoryx2FFI.iox2_listener_h}(listener.handle),
        event_id,
        has_received,
    )
    check_ok(ret, Iceoryx2FFI.iox2_listener_wait_error_e)
    return has_received[] ? EventId(event_id[]) : nothing
end

function timed_wait_one(listener::Listener, seconds::Integer, nanoseconds::Integer)
    _require_valid(listener.handle, "listener")
    event_id = Ref{Iceoryx2FFI.iox2_event_id_t}()
    has_received = Ref{Bool}(false)
    ret = Iceoryx2FFI.iox2_listener_timed_wait_one(
        Ref{Iceoryx2FFI.iox2_listener_h}(listener.handle),
        event_id,
        has_received,
        UInt64(seconds),
        UInt32(nanoseconds),
    )
    check_ok(ret, Iceoryx2FFI.iox2_listener_wait_error_e)
    return has_received[] ? EventId(event_id[]) : nothing
end

function blocking_wait_one(listener::Listener)
    _require_valid(listener.handle, "listener")
    event_id = Ref{Iceoryx2FFI.iox2_event_id_t}()
    has_received = Ref{Bool}(false)
    ret = Iceoryx2FFI.iox2_listener_blocking_wait_one(
        Ref{Iceoryx2FFI.iox2_listener_h}(listener.handle),
        event_id,
        has_received,
    )
    check_ok(ret, Iceoryx2FFI.iox2_listener_wait_error_e)
    return has_received[] ? EventId(event_id[]) : nothing
end
