# Unique ID helpers.

@inline function _unique_id_bytes(id_handle, len, value_fn)
    buffer = Vector{UInt8}(undef, len)
    GC.@preserve buffer begin
        value_fn(id_handle, pointer(buffer), Iceoryx2FFI.c_size_t(len))
    end
    return buffer
end

@inline function bytes(id::UniquePublisherId)
    len = sizeof(Iceoryx2FFI.iox2_unique_publisher_id_storage_t)
    return _unique_id_bytes(unsafe_handle(id), len, Iceoryx2FFI.iox2_unique_publisher_id_value)
end

@inline function bytes(id::UniqueSubscriberId)
    len = sizeof(Iceoryx2FFI.iox2_unique_subscriber_id_storage_t)
    return _unique_id_bytes(unsafe_handle(id), len, Iceoryx2FFI.iox2_unique_subscriber_id_value)
end

@inline function bytes(id::UniqueNotifierId)
    len = sizeof(Iceoryx2FFI.iox2_unique_notifier_id_storage_t)
    return _unique_id_bytes(unsafe_handle(id), len, Iceoryx2FFI.iox2_unique_notifier_id_value)
end

@inline function bytes(id::UniqueListenerId)
    len = sizeof(Iceoryx2FFI.iox2_unique_listener_id_storage_t)
    return _unique_id_bytes(unsafe_handle(id), len, Iceoryx2FFI.iox2_unique_listener_id_value)
end

@inline function bytes(id::UniqueReaderId)
    len = sizeof(Iceoryx2FFI.iox2_unique_reader_id_storage_t)
    return _unique_id_bytes(unsafe_handle(id), len, Iceoryx2FFI.iox2_unique_reader_id_value)
end

@inline function bytes(id::UniqueWriterId)
    len = sizeof(Iceoryx2FFI.iox2_unique_writer_id_storage_t)
    return _unique_id_bytes(unsafe_handle(id), len, Iceoryx2FFI.iox2_unique_writer_id_value)
end

@inline function bytes(id::UniqueClientId)
    len = sizeof(Iceoryx2FFI.iox2_unique_client_id_storage_t)
    return _unique_id_bytes(unsafe_handle(id), len, Iceoryx2FFI.iox2_unique_client_id_value)
end

@inline function bytes(id::UniqueServerId)
    len = sizeof(Iceoryx2FFI.iox2_unique_server_id_storage_t)
    return _unique_id_bytes(unsafe_handle(id), len, Iceoryx2FFI.iox2_unique_server_id_value)
end

function id(publisher::Publisher)
    _require_valid(publisher.handle, "publisher")
    handle_ref = Ref{Iceoryx2FFI.iox2_unique_publisher_id_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_publisher_id(Ref{Iceoryx2FFI.iox2_publisher_h}(publisher.handle), C_NULL, handle_ref)
    return UniquePublisherId(handle_ref[])
end

function id(subscriber::Subscriber)
    _require_valid(subscriber.handle, "subscriber")
    handle_ref = Ref{Iceoryx2FFI.iox2_unique_subscriber_id_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_subscriber_id(Ref{Iceoryx2FFI.iox2_subscriber_h}(subscriber.handle), C_NULL, handle_ref)
    return UniqueSubscriberId(handle_ref[])
end

function id(notifier::Notifier)
    _require_valid(notifier.handle, "notifier")
    handle_ref = Ref{Iceoryx2FFI.iox2_unique_notifier_id_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_notifier_id(Ref{Iceoryx2FFI.iox2_notifier_h}(notifier.handle), C_NULL, handle_ref)
    return UniqueNotifierId(handle_ref[])
end

function id(listener::Listener)
    _require_valid(listener.handle, "listener")
    handle_ref = Ref{Iceoryx2FFI.iox2_unique_listener_id_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_listener_id(Ref{Iceoryx2FFI.iox2_listener_h}(listener.handle), C_NULL, handle_ref)
    return UniqueListenerId(handle_ref[])
end

function id(reader::Reader)
    _require_valid(reader.handle, "reader")
    handle_ref = Ref{Iceoryx2FFI.iox2_unique_reader_id_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_reader_id(Ref{Iceoryx2FFI.iox2_reader_h}(reader.handle), C_NULL, handle_ref)
    return UniqueReaderId(handle_ref[])
end

function id(writer::Writer)
    _require_valid(writer.handle, "writer")
    handle_ref = Ref{Iceoryx2FFI.iox2_unique_writer_id_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_writer_id(Ref{Iceoryx2FFI.iox2_writer_h}(writer.handle), C_NULL, handle_ref)
    return UniqueWriterId(handle_ref[])
end

function id(client::Client)
    _require_valid(client.handle, "client")
    handle_ref = Ref{Iceoryx2FFI.iox2_unique_client_id_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_client_id(Ref{Iceoryx2FFI.iox2_client_h}(client.handle), C_NULL, handle_ref)
    return UniqueClientId(handle_ref[])
end

function id(server::Server)
    _require_valid(server.handle, "server")
    handle_ref = Ref{Iceoryx2FFI.iox2_unique_server_id_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_server_id(Ref{Iceoryx2FFI.iox2_server_h}(server.handle), C_NULL, handle_ref)
    return UniqueServerId(handle_ref[])
end

@inline function Base.:(==)(lhs::UniquePublisherId, rhs::UniquePublisherId)
    return Iceoryx2FFI.iox2_unique_publisher_id_eq(
        Ref{Iceoryx2FFI.iox2_unique_publisher_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_unique_publisher_id_h}(unsafe_handle(rhs)),
    )
end

@inline function Base.isless(lhs::UniquePublisherId, rhs::UniquePublisherId)
    return Iceoryx2FFI.iox2_unique_publisher_id_less(
        Ref{Iceoryx2FFI.iox2_unique_publisher_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_unique_publisher_id_h}(unsafe_handle(rhs)),
    )
end

@inline function Base.:(==)(lhs::UniqueSubscriberId, rhs::UniqueSubscriberId)
    return Iceoryx2FFI.iox2_unique_subscriber_id_eq(
        Ref{Iceoryx2FFI.iox2_unique_subscriber_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_unique_subscriber_id_h}(unsafe_handle(rhs)),
    )
end

@inline function Base.isless(lhs::UniqueSubscriberId, rhs::UniqueSubscriberId)
    return Iceoryx2FFI.iox2_unique_subscriber_id_less(
        Ref{Iceoryx2FFI.iox2_unique_subscriber_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_unique_subscriber_id_h}(unsafe_handle(rhs)),
    )
end

@inline function Base.:(==)(lhs::UniqueNotifierId, rhs::UniqueNotifierId)
    return Iceoryx2FFI.iox2_unique_notifier_id_eq(
        Ref{Iceoryx2FFI.iox2_unique_notifier_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_unique_notifier_id_h}(unsafe_handle(rhs)),
    )
end

@inline function Base.isless(lhs::UniqueNotifierId, rhs::UniqueNotifierId)
    return Iceoryx2FFI.iox2_unique_notifier_id_less(
        Ref{Iceoryx2FFI.iox2_unique_notifier_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_unique_notifier_id_h}(unsafe_handle(rhs)),
    )
end

@inline function Base.:(==)(lhs::UniqueListenerId, rhs::UniqueListenerId)
    return Iceoryx2FFI.iox2_unique_listener_id_eq(
        Ref{Iceoryx2FFI.iox2_unique_listener_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_unique_listener_id_h}(unsafe_handle(rhs)),
    )
end

@inline function Base.isless(lhs::UniqueListenerId, rhs::UniqueListenerId)
    return Iceoryx2FFI.iox2_unique_listener_id_less(
        Ref{Iceoryx2FFI.iox2_unique_listener_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_unique_listener_id_h}(unsafe_handle(rhs)),
    )
end

@inline function Base.:(==)(lhs::UniqueReaderId, rhs::UniqueReaderId)
    return Iceoryx2FFI.iox2_unique_reader_id_eq(
        Ref{Iceoryx2FFI.iox2_unique_reader_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_unique_reader_id_h}(unsafe_handle(rhs)),
    )
end

@inline function Base.isless(lhs::UniqueReaderId, rhs::UniqueReaderId)
    return Iceoryx2FFI.iox2_unique_reader_id_less(
        Ref{Iceoryx2FFI.iox2_unique_reader_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_unique_reader_id_h}(unsafe_handle(rhs)),
    )
end

@inline function Base.:(==)(lhs::UniqueWriterId, rhs::UniqueWriterId)
    return Iceoryx2FFI.iox2_unique_writer_id_eq(
        Ref{Iceoryx2FFI.iox2_unique_writer_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_unique_writer_id_h}(unsafe_handle(rhs)),
    )
end

@inline function Base.isless(lhs::UniqueWriterId, rhs::UniqueWriterId)
    return Iceoryx2FFI.iox2_unique_writer_id_less(
        Ref{Iceoryx2FFI.iox2_unique_writer_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_unique_writer_id_h}(unsafe_handle(rhs)),
    )
end

@inline function Base.:(==)(lhs::UniqueClientId, rhs::UniqueClientId)
    return Iceoryx2FFI.iox2_unique_client_id_eq(
        Ref{Iceoryx2FFI.iox2_unique_client_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_unique_client_id_h}(unsafe_handle(rhs)),
    )
end

@inline function Base.isless(lhs::UniqueClientId, rhs::UniqueClientId)
    return Iceoryx2FFI.iox2_unique_client_id_less(
        Ref{Iceoryx2FFI.iox2_unique_client_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_unique_client_id_h}(unsafe_handle(rhs)),
    )
end

@inline function Base.:(==)(lhs::UniqueServerId, rhs::UniqueServerId)
    return Iceoryx2FFI.iox2_unique_server_id_eq(
        Ref{Iceoryx2FFI.iox2_unique_server_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_unique_server_id_h}(unsafe_handle(rhs)),
    )
end

@inline function Base.isless(lhs::UniqueServerId, rhs::UniqueServerId)
    return Iceoryx2FFI.iox2_unique_server_id_less(
        Ref{Iceoryx2FFI.iox2_unique_server_id_h}(unsafe_handle(lhs)),
        Ref{Iceoryx2FFI.iox2_unique_server_id_h}(unsafe_handle(rhs)),
    )
end
