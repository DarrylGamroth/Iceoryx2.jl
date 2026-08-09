# === Event ===

### builder tuning setters generated in src/generated/wrappers.jl

"""
    PortFactoryEvent{S}

Factory for notifiers and listeners bound to an event service.
"""
mutable struct PortFactoryEvent{S}
    handle::Iceoryx2FFI.iox2_port_factory_event_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_event_t}
    keepalive::Node{S}
    function PortFactoryEvent{S}(handle, storage, keepalive) where {S}
        obj = new{S}(handle, storage, keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

function Base.close(factory::PortFactoryEvent)
    if factory.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_port_factory_event_drop(factory.handle)
        factory.handle = _IOX2_NULL
    end
    factory.storage = nothing
    return nothing
end

### port factory view accessors generated in src/generated/wrappers.jl

function service_hash(factory::PortFactoryEvent)
    _require_valid(factory.handle, "event port factory")
    return _service_hash_string(
        Ref{Iceoryx2FFI.iox2_port_factory_event_h}(factory.handle),
        Iceoryx2FFI.iox2_port_factory_event_service_hash
    )
end

function try_cleanup_dead_nodes(factory::PortFactoryEvent)
    _require_valid(factory.handle, "event port factory")
    state = _cleanup_state_ref()
    Iceoryx2FFI.iox2_port_factory_event_try_cleanup_dead_nodes(
        Ref{Iceoryx2FFI.iox2_port_factory_event_h}(factory.handle),
        state
    )
    return _cleanup_state(state)
end

function blocking_cleanup_dead_nodes(factory::PortFactoryEvent, seconds::Integer, nanoseconds::Integer = 0)
    _require_valid(factory.handle, "event port factory")
    secs, nanos = _timeout_parts(seconds, nanoseconds)
    state = _cleanup_state_ref()
    Iceoryx2FFI.iox2_port_factory_event_blocking_cleanup_dead_nodes(
        Ref{Iceoryx2FFI.iox2_port_factory_event_h}(factory.handle),
        state,
        secs,
        nanos
    )
    return _cleanup_state(state)
end

function blocking_cleanup_dead_nodes(factory::PortFactoryEvent, seconds::Real)
    blocking_cleanup_dead_nodes(factory, _timeout_parts(seconds)...)
end

### port factory view accessors generated in src/generated/wrappers.jl

"""
    open_or_create(builder::EventServiceBuilder[, verifier]) -> PortFactoryEvent

Open an existing event service or create it if missing.
"""
function open_or_create(builder::EventServiceBuilder{S}) where {S}
    _require_valid(builder.handle, "event service builder")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_event_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_event_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_event_open_or_create(builder.handle, storage, handle_ref)
    close(builder)
    check_ok(ret, Iceoryx2FFI.iox2_event_open_or_create_error_e)
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
        handle_ref
    )
    close(builder)
    check_ok(ret, Iceoryx2FFI.iox2_event_open_or_create_error_e)
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

"""
    open(builder::EventServiceBuilder[, verifier]) -> PortFactoryEvent

Open an existing event service.
"""
function open(builder::EventServiceBuilder{S}) where {S}
    _require_valid(builder.handle, "event service builder")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_event_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_event_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_event_open(builder.handle, storage, handle_ref)
    close(builder)
    check_ok(ret, Iceoryx2FFI.iox2_event_open_or_create_error_e)
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
        handle_ref
    )
    close(builder)
    check_ok(ret, Iceoryx2FFI.iox2_event_open_or_create_error_e)
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

"""
    create(builder::EventServiceBuilder[, specifier]) -> PortFactoryEvent

Create a new event service.
"""
function create(builder::EventServiceBuilder{S}) where {S}
    _require_valid(builder.handle, "event service builder")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_event_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_event_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_event_create(builder.handle, storage, handle_ref)
    close(builder)
    check_ok(ret, Iceoryx2FFI.iox2_event_open_or_create_error_e)
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
        handle_ref
    )
    close(builder)
    check_ok(ret, Iceoryx2FFI.iox2_event_open_or_create_error_e)
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

function open_or_create_with_attributes(builder::EventServiceBuilder{S}, verifier::AttributeVerifier) where {S}
    open_or_create(builder, verifier)
end
function open_or_create_with_attributes(
        f::Function, builder::EventServiceBuilder{S}, verifier::AttributeVerifier) where {S}
    open_or_create(f, builder, verifier)
end
function open_with_attributes(builder::EventServiceBuilder{S}, verifier::AttributeVerifier) where {S}
    open(builder, verifier)
end
function open_with_attributes(
        f::Function, builder::EventServiceBuilder{S}, verifier::AttributeVerifier) where {S}
    open(f, builder, verifier)
end
function create_with_attributes(builder::EventServiceBuilder{S}, specifier::AttributeSpecifier) where {S}
    create(builder, specifier)
end
function create_with_attributes(f::Function, builder::EventServiceBuilder{S},
        specifier::AttributeSpecifier) where {S}
    create(f, builder, specifier)
end

"""
    NotifierBuilder{S}

Builder for `Notifier{S}`.
"""
mutable struct NotifierBuilder{S}
    handle::Iceoryx2FFI.iox2_port_factory_notifier_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_notifier_builder_t}
    keepalive::PortFactoryEvent{S}
    function NotifierBuilder{S}(handle, storage, keepalive) where {S}
        obj = new{S}(handle, storage, keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

function Base.close(builder::NotifierBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

function notifier_builder(factory::PortFactoryEvent{S}) where {S}
    _require_valid(factory.handle, "event port factory")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_notifier_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_event_notifier_builder(
        Ref{Iceoryx2FFI.iox2_port_factory_event_h}(factory.handle), storage)
    return NotifierBuilder{S}(handle, storage, factory)
end

function name!(
        builder::NotifierBuilder,
        name::Union{PortName, PortNameView, AbstractString}
)
    return _set_port_name!(
        builder,
        name,
        Iceoryx2FFI.iox2_port_factory_notifier_builder_set_name,
        Ref{Iceoryx2FFI.iox2_port_factory_notifier_builder_h}(builder.handle),
        "notifier builder"
    )
end

"""
    default_event_id!(builder::NotifierBuilder, id::EventId)

Set the default event ID used by the notifier.
"""
function default_event_id!(builder::NotifierBuilder, id::EventId)
    _require_valid(builder.handle, "notifier builder")
    id_ref = Ref(id.raw)
    GC.@preserve id_ref begin
        Iceoryx2FFI.iox2_port_factory_notifier_builder_set_default_event_id(
            Ref{Iceoryx2FFI.iox2_port_factory_notifier_builder_h}(builder.handle),
            Base.unsafe_convert(Ptr{Iceoryx2FFI.iox2_event_id_t}, id_ref)
        )
    end
    return builder
end

"""
    ListenerBuilder{S}

Builder for `Listener{S}`.
"""
mutable struct ListenerBuilder{S}
    handle::Iceoryx2FFI.iox2_port_factory_listener_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_listener_builder_t}
    keepalive::PortFactoryEvent{S}
    function ListenerBuilder{S}(handle, storage, keepalive) where {S}
        obj = new{S}(handle, storage, keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

@inline Base.isvalid(builder::Union{NotifierBuilder, ListenerBuilder}) = builder.handle !=
                                                                         _IOX2_NULL

function Base.close(builder::ListenerBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

function listener_builder(factory::PortFactoryEvent{S}) where {S}
    _require_valid(factory.handle, "event port factory")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_listener_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_event_listener_builder(
        Ref{Iceoryx2FFI.iox2_port_factory_event_h}(factory.handle), storage)
    return ListenerBuilder{S}(handle, storage, factory)
end

function name!(
        builder::ListenerBuilder,
        name::Union{PortName, PortNameView, AbstractString}
)
    return _set_port_name!(
        builder,
        name,
        Iceoryx2FFI.iox2_port_factory_listener_builder_set_name,
        Ref{Iceoryx2FFI.iox2_port_factory_listener_builder_h}(builder.handle),
        "listener builder"
    )
end

"""
    Notifier{S}

Send event notifications to listeners.
"""
mutable struct Notifier{S}
    handle::Iceoryx2FFI.iox2_notifier_h
    storage::_StorageRef{Iceoryx2FFI.iox2_notifier_t}
    keepalive::PortFactoryEvent{S}
    function Notifier{S}(handle, storage, keepalive) where {S}
        obj = new{S}(handle, storage, keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

function Base.close(notifier::Notifier)
    if notifier.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_notifier_drop(notifier.handle)
        notifier.handle = _IOX2_NULL
    end
    notifier.storage = nothing
    return nothing
end

"""
    create(builder::NotifierBuilder) -> Notifier

Create a notifier and consume the builder.
"""
function create(builder::NotifierBuilder{S}) where {S}
    _require_valid(builder.handle, "notifier builder")
    storage = Ref{Iceoryx2FFI.iox2_notifier_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_notifier_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_notifier_builder_create(builder.handle, storage, handle_ref)
    close(builder)
    check_ok(ret, Iceoryx2FFI.iox2_notifier_create_error_e)
    return Notifier{S}(handle_ref[], storage, builder.keepalive)
end

"""
    create(f::Function, builder::NotifierBuilder)

Create a notifier, call `f(notifier)`, and close it in a `finally` block.
"""
function create(f::Function, builder::NotifierBuilder{S}) where {S}
    notifier = create(builder)
    try
        return f(notifier)
    finally
        close(notifier)
    end
end

"""
    deadline(notifier::Notifier) -> Union{Nothing,Tuple{UInt64,UInt32}}

Return the notifier deadline as `(seconds, nanoseconds)` or `nothing`.
"""
function deadline(notifier::Notifier)
    _require_valid(notifier.handle, "notifier")
    seconds = Ref{UInt64}(0)
    nanos = Ref{UInt32}(0)
    has_deadline = Iceoryx2FFI.iox2_notifier_deadline(
        Ref{Iceoryx2FFI.iox2_notifier_h}(notifier.handle),
        seconds,
        nanos
    )
    return has_deadline ? (seconds[], nanos[]) : nothing
end

"""
    Listener{S}

Receive event notifications from notifiers.
"""
mutable struct Listener{S}
    handle::Iceoryx2FFI.iox2_listener_h
    storage::_StorageRef{Iceoryx2FFI.iox2_listener_t}
    keepalive::PortFactoryEvent{S}
    function Listener{S}(handle, storage, keepalive) where {S}
        obj = new{S}(handle, storage, keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

function Base.close(listener::Listener)
    if listener.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_listener_drop(listener.handle)
        listener.handle = _IOX2_NULL
    end
    listener.storage = nothing
    return nothing
end

"""
    create(builder::ListenerBuilder) -> Listener

Create a listener and consume the builder.
"""
function create(builder::ListenerBuilder{S}) where {S}
    _require_valid(builder.handle, "listener builder")
    storage = Ref{Iceoryx2FFI.iox2_listener_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_listener_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_listener_builder_create(builder.handle, storage, handle_ref)
    close(builder)
    check_ok(ret, Iceoryx2FFI.iox2_listener_create_error_e)
    return Listener{S}(handle_ref[], storage, builder.keepalive)
end

"""
    create(f::Function, builder::ListenerBuilder)

Create a listener, call `f(listener)`, and close it in a `finally` block.
"""
function create(f::Function, builder::ListenerBuilder{S}) where {S}
    listener = create(builder)
    try
        return f(listener)
    finally
        close(listener)
    end
end

"""
    deadline(listener::Listener) -> Union{Nothing,Tuple{UInt64,UInt32}}

Return the listener deadline as `(seconds, nanoseconds)` or `nothing`.
"""
function deadline(listener::Listener)
    _require_valid(listener.handle, "listener")
    seconds = Ref{UInt64}(0)
    nanos = Ref{UInt32}(0)
    has_deadline = Iceoryx2FFI.iox2_listener_deadline(
        Ref{Iceoryx2FFI.iox2_listener_h}(listener.handle),
        seconds,
        nanos
    )
    return has_deadline ? (seconds[], nanos[]) : nothing
end

"""
    notify!(notifier::Notifier)
    notify!(notifier::Notifier, id::EventId)

Send a notification, optionally with a custom event ID.
"""
function notify!(notifier::Notifier)
    _require_valid(notifier.handle, "notifier")
    count = Ref{Iceoryx2FFI.c_size_t}()
    ret = Iceoryx2FFI.iox2_notifier_notify(Ref{Iceoryx2FFI.iox2_notifier_h}(notifier.handle), count)
    check_ok(ret, Iceoryx2FFI.iox2_notifier_notify_error_e)
    return Int(count[])
end

function notify!(notifier::Notifier, id::EventId)
    _require_valid(notifier.handle, "notifier")
    count = Ref{Iceoryx2FFI.c_size_t}()
    id_ref = Ref(id.raw)
    GC.@preserve id_ref begin
        ret = Iceoryx2FFI.iox2_notifier_notify_with_custom_event_id(
            Ref{Iceoryx2FFI.iox2_notifier_h}(notifier.handle),
            Base.unsafe_convert(Ptr{Iceoryx2FFI.iox2_event_id_t}, id_ref),
            count
        )
        check_ok(ret, Iceoryx2FFI.iox2_notifier_notify_error_e)
    end
    return Int(count[])
end

@inline notify_with_custom_event_id!(notifier::Notifier, id::EventId) = notify!(notifier, id)

"""
    AbstractListenerWaitHandler

Abstract callback handler for listener wait APIs.
"""
abstract type AbstractListenerWaitHandler end

function on_listener_event(::AbstractListenerWaitHandler)
    throw(ArgumentError("listener wait handler must implement on_listener_event(handler)"))
end

"""
    ListenerWaitHandler(f)

    Wrap a callable `f(event_id, count)` for listener wait APIs.
"""
mutable struct ListenerWaitHandler{T} <: AbstractListenerWaitHandler
    on_event::T
    ref::Base.RefValue{ListenerWaitHandler{T}}
    last_exception::Base.RefValue{_CallbackException}
    function ListenerWaitHandler{T}(on_event::T) where {T}
        ref = Ref{ListenerWaitHandler{T}}()
        handler = new{T}(on_event, ref, _callback_exception_ref())
        ref[] = handler
        return handler
    end
end

ListenerWaitHandler(on_event::T) where {T} = ListenerWaitHandler{T}(on_event)

on_listener_event(h::ListenerWaitHandler) = h.on_event
@inline last_callback_exception(handler::ListenerWaitHandler) = handler.last_exception[]

function _listener_wait_wrapper(
        event_id_ptr::Ptr{Iceoryx2FFI.iox2_event_id_t},
        count::UInt64,
        handler::AbstractListenerWaitHandler
)
    handler.last_exception[] === nothing || return
    try
        on_listener_event(handler)(EventId(unsafe_load(event_id_ptr)), count)
    catch err
        _record_callback_exception!(handler, err)
    end
    return
end

function _listener_wait_cfunction(::T) where {T <: AbstractListenerWaitHandler}
    @cfunction(_listener_wait_wrapper,
        Cvoid,
        (Ptr{Iceoryx2FFI.iox2_event_id_t}, UInt64, Ref{T}),)
end

"""
    try_wait(listener, handler) -> UInt64

Poll for events and invoke `handler(event_id, count)` for each event ID. Return
the total number of notifications received.
"""
function try_wait(listener::Listener, handler::ListenerWaitHandler)
    _require_valid(listener.handle, "listener")
    _clear_callback_exception!(handler)
    number_of_notifications = Ref{UInt64}(0)
    handler_ref = handler.ref
    GC.@preserve handler_ref number_of_notifications begin
        ret = Iceoryx2FFI.iox2_listener_try_wait(
            Ref{Iceoryx2FFI.iox2_listener_h}(listener.handle),
            number_of_notifications,
            _listener_wait_cfunction(handler),
            handler_ref
        )
        check_ok(ret, Iceoryx2FFI.iox2_listener_wait_error_e)
    end
    _rethrow_callback_exception!(handler)
    return number_of_notifications[]
end

function try_wait(listener::Listener, handler::AbstractListenerWaitHandler)
    return try_wait(listener, ListenerWaitHandler(on_listener_event(handler)))
end

try_wait(f::Function, listener::Listener) = try_wait(listener, ListenerWaitHandler(f))

"""
    timed_wait(listener, seconds, nanoseconds, handler) -> UInt64

Wait with timeout and invoke `handler(event_id, count)` for each event ID.
"""
function timed_wait(
        listener::Listener,
        seconds::Integer,
        nanoseconds::Integer,
        handler::ListenerWaitHandler
)
    _require_valid(listener.handle, "listener")
    secs, nanos = _timeout_parts(seconds, nanoseconds)
    _clear_callback_exception!(handler)
    number_of_notifications = Ref{UInt64}(0)
    handler_ref = handler.ref
    GC.@preserve handler_ref number_of_notifications begin
        ret = Iceoryx2FFI.iox2_listener_timed_wait(
            Ref{Iceoryx2FFI.iox2_listener_h}(listener.handle),
            number_of_notifications,
            _listener_wait_cfunction(handler),
            handler_ref,
            secs,
            nanos
        )
        check_ok(ret, Iceoryx2FFI.iox2_listener_wait_error_e)
    end
    _rethrow_callback_exception!(handler)
    return number_of_notifications[]
end

function timed_wait(
        listener::Listener,
        seconds::Integer,
        nanoseconds::Integer,
        handler::AbstractListenerWaitHandler
)
    return timed_wait(
        listener,
        seconds,
        nanoseconds,
        ListenerWaitHandler(on_listener_event(handler))
    )
end

function timed_wait(f::Function, listener::Listener, seconds::Integer, nanoseconds::Integer)
    timed_wait(listener, seconds, nanoseconds, ListenerWaitHandler(f))
end

"""
    blocking_wait(listener, handler) -> UInt64

Block and invoke `handler(event_id, count)` for each event ID.
"""
function blocking_wait(listener::Listener, handler::ListenerWaitHandler)
    _require_valid(listener.handle, "listener")
    _clear_callback_exception!(handler)
    number_of_notifications = Ref{UInt64}(0)
    handler_ref = handler.ref
    GC.@preserve handler_ref number_of_notifications begin
        ret = Iceoryx2FFI.iox2_listener_blocking_wait(
            Ref{Iceoryx2FFI.iox2_listener_h}(listener.handle),
            number_of_notifications,
            _listener_wait_cfunction(handler),
            handler_ref
        )
        check_ok(ret, Iceoryx2FFI.iox2_listener_wait_error_e)
    end
    _rethrow_callback_exception!(handler)
    return number_of_notifications[]
end

function blocking_wait(listener::Listener, handler::AbstractListenerWaitHandler)
    return blocking_wait(listener, ListenerWaitHandler(on_listener_event(handler)))
end

function blocking_wait(f::Function, listener::Listener)
    blocking_wait(listener, ListenerWaitHandler(f))
end
