# Messaging patterns: pub/sub, request/response, event, blackboard.

@inline function _require_isbits(::Type{T}) where {T}
    isbitstype(T) || throw(ArgumentError("payload type must be isbits"))
    return nothing
end

@inline _type_variant(value::Iceoryx2FFI.iox2_type_variant_e) = value

@inline function _type_variant(value::Symbol)
    if value === :fixed
        return Iceoryx2FFI.iox2_type_variant_e_FIXED_SIZE
    elseif value === :dynamic
        return Iceoryx2FFI.iox2_type_variant_e_DYNAMIC
    end
    throw(ArgumentError("unsupported type variant: $value"))
end

@inline _type_variant(value) = throw(ArgumentError("unsupported type variant: $value"))

@inline function _type_details(::Type{T}) where {T}
    name = string(T)
    return name, Iceoryx2FFI.c_size_t(ncodeunits(name)), Iceoryx2FFI.c_size_t(sizeof(T)), Iceoryx2FFI.c_size_t(Base.datatype_alignment(T))
end

const _StorageRef{T} = Union{Nothing, Base.RefValue{T}}

@inline _free_struct!(::Union{Nothing, Base.RefValue{T}}) where {T} = nothing

struct Slice{T}
    ptr::Ptr{T}
    len::Int
end

Base.length(slice::Slice) = slice.len

@inline function Base.getindex(slice::Slice{T}, i::Int) where {T}
    @boundscheck (i >= 1 && i <= slice.len) || throw(BoundsError(slice, i))
    return unsafe_load(slice.ptr, i)
end

# === Publish/Subscribe ===

function payload_type!(builder::PubSubServiceBuilder, ::Type{T}; variant::Union{Symbol,Iceoryx2FFI.iox2_type_variant_e}=:fixed) where {T}
    _require_valid(builder.handle, "pub_sub service builder")
    _require_isbits(T)
    name, name_len, size, alignment = _type_details(T)
    v = _type_variant(variant)
    GC.@preserve name begin
        ret = Iceoryx2FFI.iox2_service_builder_pub_sub_set_payload_type_details(Ref{Iceoryx2FFI.iox2_service_builder_pub_sub_h}(builder.handle), v, Base.unsafe_convert(Cstring, name), name_len, size, alignment)
        check_ok(ret, Iceoryx2FFI.iox2_type_detail_error_e)
    end
    return builder
end

mutable struct PortFactoryPubSub
    handle::Iceoryx2FFI.iox2_port_factory_pub_sub_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_pub_sub_t}
    keepalive::Node
end

function _finalize_port_factory_pub_sub(factory::PortFactoryPubSub)
    if factory.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_port_factory_pub_sub_drop(factory.handle)
        factory.handle = _IOX2_NULL
    end
    factory.storage = _free_struct!(factory.storage)
    return nothing
end

function open_or_create(builder::PubSubServiceBuilder)
    _require_valid(builder.handle, "pub_sub service builder")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_pub_sub_open_or_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_pub_sub_open_or_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    factory = PortFactoryPubSub(handle_ref[], storage, builder.keepalive)
    finalizer(_finalize_port_factory_pub_sub, factory)
    return factory
end

function open_or_create(f::Function, builder::PubSubServiceBuilder)
    factory = open_or_create(builder)
    try
        return f(factory)
    finally
        close(factory)
    end
end

mutable struct PublisherBuilder{T}
    handle::Iceoryx2FFI.iox2_port_factory_publisher_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_publisher_builder_t}
    keepalive::PortFactoryPubSub
end

function _finalize_publisher_builder(builder::PublisherBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = _free_struct!(builder.storage)
    return nothing
end

function publisher_builder(factory::PortFactoryPubSub, ::Type{T}) where {T}
    _require_valid(factory.handle, "pub_sub port factory")
    _require_isbits(T)
    storage = Ref{Iceoryx2FFI.iox2_port_factory_publisher_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_pub_sub_publisher_builder(Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_h}(factory.handle), storage)
    builder = PublisherBuilder{T}(handle, storage, factory)
    finalizer(_finalize_publisher_builder, builder)
    return builder
end

mutable struct SubscriberBuilder{T}
    handle::Iceoryx2FFI.iox2_port_factory_subscriber_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_subscriber_builder_t}
    keepalive::PortFactoryPubSub
end

function _finalize_subscriber_builder(builder::SubscriberBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = _free_struct!(builder.storage)
    return nothing
end

function subscriber_builder(factory::PortFactoryPubSub, ::Type{T}) where {T}
    _require_valid(factory.handle, "pub_sub port factory")
    _require_isbits(T)
    storage = Ref{Iceoryx2FFI.iox2_port_factory_subscriber_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_pub_sub_subscriber_builder(Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_h}(factory.handle), storage)
    builder = SubscriberBuilder{T}(handle, storage, factory)
    finalizer(_finalize_subscriber_builder, builder)
    return builder
end

mutable struct Publisher{T}
    handle::Iceoryx2FFI.iox2_publisher_h
    storage::_StorageRef{Iceoryx2FFI.iox2_publisher_t}
    keepalive::PortFactoryPubSub
end

function _finalize_publisher(pub::Publisher)
    if pub.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_publisher_drop(pub.handle)
        pub.handle = _IOX2_NULL
    end
    pub.storage = _free_struct!(pub.storage)
    return nothing
end

function create(builder::PublisherBuilder{T}) where {T}
    _require_valid(builder.handle, "publisher builder")
    storage = Ref{Iceoryx2FFI.iox2_publisher_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_publisher_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_publisher_builder_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_publisher_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_publisher_builder(builder)
    pub = Publisher{T}(handle_ref[], storage, builder.keepalive)
    finalizer(_finalize_publisher, pub)
    return pub
end

function create(f::Function, builder::PublisherBuilder{T}) where {T}
    pub = create(builder)
    try
        return f(pub)
    finally
        close(pub)
    end
end

mutable struct Subscriber{T}
    handle::Iceoryx2FFI.iox2_subscriber_h
    storage::_StorageRef{Iceoryx2FFI.iox2_subscriber_t}
    keepalive::PortFactoryPubSub
end

function _finalize_subscriber(sub::Subscriber)
    if sub.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_subscriber_drop(sub.handle)
        sub.handle = _IOX2_NULL
    end
    sub.storage = _free_struct!(sub.storage)
    return nothing
end

function create(builder::SubscriberBuilder{T}) where {T}
    _require_valid(builder.handle, "subscriber builder")
    storage = Ref{Iceoryx2FFI.iox2_subscriber_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_subscriber_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_subscriber_builder_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_subscriber_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_subscriber_builder(builder)
    sub = Subscriber{T}(handle_ref[], storage, builder.keepalive)
    finalizer(_finalize_subscriber, sub)
    return sub
end

function create(f::Function, builder::SubscriberBuilder{T}) where {T}
    sub = create(builder)
    try
        return f(sub)
    finally
        close(sub)
    end
end

mutable struct Sample{T}
    handle::Iceoryx2FFI.iox2_sample_h
    storage::_StorageRef{Iceoryx2FFI.iox2_sample_t}
end

function _finalize_sample(sample::Sample)
    if sample.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_sample_drop(sample.handle)
        sample.handle = _IOX2_NULL
    end
    sample.storage = _free_struct!(sample.storage)
    return nothing
end

@inline function payload(sample::Sample{T}) where {T}
    ptr_ref = Ref{Ptr{Cvoid}}()
    len_ref = Ref{Iceoryx2FFI.c_size_t}()
    Iceoryx2FFI.iox2_sample_payload(Ref{Iceoryx2FFI.iox2_sample_h}(sample.handle), ptr_ref, len_ref)
    return Slice{T}(Ptr{T}(ptr_ref[]), Int(len_ref[]))
end

mutable struct SampleMut{T}
    handle::Iceoryx2FFI.iox2_sample_mut_h
    storage::_StorageRef{Iceoryx2FFI.iox2_sample_mut_t}
end

function _finalize_sample_mut(sample::SampleMut)
    if sample.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_sample_mut_drop(sample.handle)
        sample.handle = _IOX2_NULL
    end
    sample.storage = _free_struct!(sample.storage)
    return nothing
end

@inline function payload_mut(sample::SampleMut{T}) where {T}
    ptr_ref = Ref{Ptr{Cvoid}}()
    len_ref = Ref{Iceoryx2FFI.c_size_t}()
    Iceoryx2FFI.iox2_sample_mut_payload_mut(Ref{Iceoryx2FFI.iox2_sample_mut_h}(sample.handle), ptr_ref, len_ref)
    return Slice{T}(Ptr{T}(ptr_ref[]), Int(len_ref[]))
end

function loan_slice(publisher::Publisher{T}, n::Integer) where {T}
    _require_valid(publisher.handle, "publisher")
    storage = Ref{Iceoryx2FFI.iox2_sample_mut_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_sample_mut_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_publisher_loan_slice_uninit(Ref{Iceoryx2FFI.iox2_publisher_h}(publisher.handle), storage, handle_ref, Iceoryx2FFI.c_size_t(n))
    check_ok(ret, Iceoryx2FFI.iox2_loan_error_e)
    sample = SampleMut{T}(handle_ref[], storage)
    finalizer(_finalize_sample_mut, sample)
    return sample
end

@inline function send!(sample::SampleMut)
    ret = Iceoryx2FFI.iox2_sample_mut_send(sample.handle, C_NULL)
    check_ok(ret, Iceoryx2FFI.iox2_send_error_e)
    sample.handle = _IOX2_NULL
    sample.storage = _free_struct!(sample.storage)
    return nothing
end

function send_copy(publisher::Publisher{T}, data::Ptr{T}, n::Integer) where {T}
    _require_valid(publisher.handle, "publisher")
    recipients = Ref{Iceoryx2FFI.c_size_t}()
    ret = Iceoryx2FFI.iox2_publisher_send_slice_copy(Ref{Iceoryx2FFI.iox2_publisher_h}(publisher.handle), data, Iceoryx2FFI.c_size_t(sizeof(T)), Iceoryx2FFI.c_size_t(n), recipients)
    check_ok(ret, Iceoryx2FFI.iox2_send_error_e)
    return Int(recipients[])
end

function send_copy(publisher::Publisher{T}, data::AbstractVector{T}) where {T}
    _require_isbits(T)
    GC.@preserve data begin
        return send_copy(publisher, pointer(data), length(data))
    end
end

function receive(subscriber::Subscriber{T}) where {T}
    _require_valid(subscriber.handle, "subscriber")
    storage = Ref{Iceoryx2FFI.iox2_sample_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_sample_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_subscriber_receive(Ref{Iceoryx2FFI.iox2_subscriber_h}(subscriber.handle), storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_receive_error_e)
    if handle_ref[] == _IOX2_NULL
        storage = _free_struct!(storage)
        return nothing
    end
    sample = Sample{T}(handle_ref[], storage)
    finalizer(_finalize_sample, sample)
    return sample
end

function has_samples(subscriber::Subscriber)
    result = Ref{Bool}()
    ret = Iceoryx2FFI.iox2_subscriber_has_samples(Ref{Iceoryx2FFI.iox2_subscriber_h}(subscriber.handle), result)
    check_ok(ret, Iceoryx2FFI.iox2_connection_failure_e)
    return result[]
end

# === Request/Response ===

function request_payload_type!(builder::RequestResponseServiceBuilder, ::Type{T}; variant::Union{Symbol,Iceoryx2FFI.iox2_type_variant_e}=:fixed) where {T}
    _require_valid(builder.handle, "request_response service builder")
    _require_isbits(T)
    name, name_len, size, alignment = _type_details(T)
    v = _type_variant(variant)
    GC.@preserve name begin
        ret = Iceoryx2FFI.iox2_service_builder_request_response_set_request_payload_type_details(Ref{Iceoryx2FFI.iox2_service_builder_request_response_h}(builder.handle), v, Base.unsafe_convert(Cstring, name), name_len, size, alignment)
        check_ok(ret, Iceoryx2FFI.iox2_type_detail_error_e)
    end
    return builder
end

function response_payload_type!(builder::RequestResponseServiceBuilder, ::Type{T}; variant::Union{Symbol,Iceoryx2FFI.iox2_type_variant_e}=:fixed) where {T}
    _require_valid(builder.handle, "request_response service builder")
    _require_isbits(T)
    name, name_len, size, alignment = _type_details(T)
    v = _type_variant(variant)
    GC.@preserve name begin
        ret = Iceoryx2FFI.iox2_service_builder_request_response_set_response_payload_type_details(Ref{Iceoryx2FFI.iox2_service_builder_request_response_h}(builder.handle), v, Base.unsafe_convert(Cstring, name), name_len, size, alignment)
        check_ok(ret, Iceoryx2FFI.iox2_type_detail_error_e)
    end
    return builder
end

mutable struct PortFactoryRequestResponse
    handle::Iceoryx2FFI.iox2_port_factory_request_response_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_request_response_t}
    keepalive::Node
end

function _finalize_port_factory_request_response(factory::PortFactoryRequestResponse)
    if factory.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_port_factory_request_response_drop(factory.handle)
        factory.handle = _IOX2_NULL
    end
    factory.storage = _free_struct!(factory.storage)
    return nothing
end

function open_or_create(builder::RequestResponseServiceBuilder)
    _require_valid(builder.handle, "request_response service builder")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_request_response_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_request_response_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_request_response_open_or_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_request_response_open_or_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    factory = PortFactoryRequestResponse(handle_ref[], storage, builder.keepalive)
    finalizer(_finalize_port_factory_request_response, factory)
    return factory
end

function open_or_create(f::Function, builder::RequestResponseServiceBuilder)
    factory = open_or_create(builder)
    try
        return f(factory)
    finally
        close(factory)
    end
end

mutable struct ClientBuilder{Req,Resp}
    handle::Iceoryx2FFI.iox2_port_factory_client_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_client_builder_t}
    keepalive::PortFactoryRequestResponse
end

function _finalize_client_builder(builder::ClientBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = _free_struct!(builder.storage)
    return nothing
end

function client_builder(factory::PortFactoryRequestResponse, ::Type{Req}, ::Type{Resp}) where {Req,Resp}
    _require_valid(factory.handle, "request_response port factory")
    _require_isbits(Req)
    _require_isbits(Resp)
    storage = Ref{Iceoryx2FFI.iox2_port_factory_client_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_request_response_client_builder(Ref{Iceoryx2FFI.iox2_port_factory_request_response_h}(factory.handle), storage)
    builder = ClientBuilder{Req,Resp}(handle, storage, factory)
    finalizer(_finalize_client_builder, builder)
    return builder
end

mutable struct ServerBuilder{Req,Resp}
    handle::Iceoryx2FFI.iox2_port_factory_server_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_server_builder_t}
    keepalive::PortFactoryRequestResponse
end

function _finalize_server_builder(builder::ServerBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = _free_struct!(builder.storage)
    return nothing
end

function server_builder(factory::PortFactoryRequestResponse, ::Type{Req}, ::Type{Resp}) where {Req,Resp}
    _require_valid(factory.handle, "request_response port factory")
    _require_isbits(Req)
    _require_isbits(Resp)
    storage = Ref{Iceoryx2FFI.iox2_port_factory_server_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_request_response_server_builder(Ref{Iceoryx2FFI.iox2_port_factory_request_response_h}(factory.handle), storage)
    builder = ServerBuilder{Req,Resp}(handle, storage, factory)
    finalizer(_finalize_server_builder, builder)
    return builder
end

mutable struct Client{Req,Resp}
    handle::Iceoryx2FFI.iox2_client_h
    storage::_StorageRef{Iceoryx2FFI.iox2_client_t}
    keepalive::PortFactoryRequestResponse
end

function _finalize_client(client::Client)
    if client.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_client_drop(client.handle)
        client.handle = _IOX2_NULL
    end
    client.storage = _free_struct!(client.storage)
    return nothing
end

function create(builder::ClientBuilder{Req,Resp}) where {Req,Resp}
    _require_valid(builder.handle, "client builder")
    storage = Ref{Iceoryx2FFI.iox2_client_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_client_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_client_builder_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_client_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_client_builder(builder)
    client = Client{Req,Resp}(handle_ref[], storage, builder.keepalive)
    finalizer(_finalize_client, client)
    return client
end

function create(f::Function, builder::ClientBuilder{Req,Resp}) where {Req,Resp}
    client = create(builder)
    try
        return f(client)
    finally
        close(client)
    end
end

mutable struct Server{Req,Resp}
    handle::Iceoryx2FFI.iox2_server_h
    storage::_StorageRef{Iceoryx2FFI.iox2_server_t}
    keepalive::PortFactoryRequestResponse
end

function _finalize_server(server::Server)
    if server.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_server_drop(server.handle)
        server.handle = _IOX2_NULL
    end
    server.storage = _free_struct!(server.storage)
    return nothing
end

function create(builder::ServerBuilder{Req,Resp}) where {Req,Resp}
    _require_valid(builder.handle, "server builder")
    storage = Ref{Iceoryx2FFI.iox2_server_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_server_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_server_builder_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_server_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_server_builder(builder)
    server = Server{Req,Resp}(handle_ref[], storage, builder.keepalive)
    finalizer(_finalize_server, server)
    return server
end

function create(f::Function, builder::ServerBuilder{Req,Resp}) where {Req,Resp}
    server = create(builder)
    try
        return f(server)
    finally
        close(server)
    end
end

mutable struct RequestMut{Req,Resp}
    handle::Iceoryx2FFI.iox2_request_mut_h
    storage::_StorageRef{Iceoryx2FFI.iox2_request_mut_t}
end

function _finalize_request_mut(request::RequestMut)
    if request.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_request_mut_drop(request.handle)
        request.handle = _IOX2_NULL
    end
    request.storage = _free_struct!(request.storage)
    return nothing
end

@inline function payload_mut(request::RequestMut{Req,Resp}) where {Req,Resp}
    ptr_ref = Ref{Ptr{Cvoid}}()
    len_ref = Ref{Iceoryx2FFI.c_size_t}()
    Iceoryx2FFI.iox2_request_mut_payload_mut(Ref{Iceoryx2FFI.iox2_request_mut_h}(request.handle), ptr_ref, len_ref)
    return Slice{Req}(Ptr{Req}(ptr_ref[]), Int(len_ref[]))
end

mutable struct PendingResponse{Resp}
    handle::Iceoryx2FFI.iox2_pending_response_h
    storage::_StorageRef{Iceoryx2FFI.iox2_pending_response_t}
end

function _finalize_pending_response(pending::PendingResponse)
    if pending.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_pending_response_drop(pending.handle)
        pending.handle = _IOX2_NULL
    end
    pending.storage = _free_struct!(pending.storage)
    return nothing
end

function loan_request(client::Client{Req,Resp}, n::Integer) where {Req,Resp}
    _require_valid(client.handle, "client")
    storage = Ref{Iceoryx2FFI.iox2_request_mut_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_request_mut_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_client_loan_slice_uninit(Ref{Iceoryx2FFI.iox2_client_h}(client.handle), storage, handle_ref, Iceoryx2FFI.c_size_t(n))
    check_ok(ret, Iceoryx2FFI.iox2_loan_error_e)
    request = RequestMut{Req,Resp}(handle_ref[], storage)
    finalizer(_finalize_request_mut, request)
    return request
end

function send!(request::RequestMut{Req,Resp}) where {Req,Resp}
    pending_storage = Ref{Iceoryx2FFI.iox2_pending_response_t}()
    pending_ref = Ref{Iceoryx2FFI.iox2_pending_response_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_request_mut_send(request.handle, pending_storage, pending_ref)
    check_ok(ret, Iceoryx2FFI.iox2_send_error_e)
    request.handle = _IOX2_NULL
    request.storage = _free_struct!(request.storage)
    pending = PendingResponse{Resp}(pending_ref[], pending_storage)
    finalizer(_finalize_pending_response, pending)
    return pending
end

function send_copy(client::Client{Req,Resp}, data::Ptr{Req}, n::Integer) where {Req,Resp}
    pending_storage = Ref{Iceoryx2FFI.iox2_pending_response_t}()
    pending_ref = Ref{Iceoryx2FFI.iox2_pending_response_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_client_send_copy(Ref{Iceoryx2FFI.iox2_client_h}(client.handle), data, Iceoryx2FFI.c_size_t(sizeof(Req)), Iceoryx2FFI.c_size_t(n), pending_storage, pending_ref)
    check_ok(ret, Iceoryx2FFI.iox2_send_error_e)
    pending = PendingResponse{Resp}(pending_ref[], pending_storage)
    finalizer(_finalize_pending_response, pending)
    return pending
end

function send_copy(client::Client{Req,Resp}, data::AbstractVector{Req}) where {Req,Resp}
    _require_isbits(Req)
    GC.@preserve data begin
        return send_copy(client, pointer(data), length(data))
    end
end

mutable struct Response{Resp}
    handle::Iceoryx2FFI.iox2_response_h
    storage::_StorageRef{Iceoryx2FFI.iox2_response_t}
end

function _finalize_response(resp::Response)
    if resp.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_response_drop(resp.handle)
        resp.handle = _IOX2_NULL
    end
    resp.storage = _free_struct!(resp.storage)
    return nothing
end

@inline function payload(resp::Response{RespT}) where {RespT}
    ptr_ref = Ref{Ptr{Cvoid}}()
    len_ref = Ref{Iceoryx2FFI.c_size_t}()
    Iceoryx2FFI.iox2_response_payload(Ref{Iceoryx2FFI.iox2_response_h}(resp.handle), ptr_ref, len_ref)
    return Slice{RespT}(Ptr{RespT}(ptr_ref[]), Int(len_ref[]))
end

function receive(pending::PendingResponse{Resp}) where {Resp}
    storage = Ref{Iceoryx2FFI.iox2_response_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_response_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_pending_response_receive(Ref{Iceoryx2FFI.iox2_pending_response_h}(pending.handle), storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_receive_error_e)
    if handle_ref[] == _IOX2_NULL
        storage = _free_struct!(storage)
        return nothing
    end
    resp = Response{Resp}(handle_ref[], storage)
    finalizer(_finalize_response, resp)
    return resp
end

mutable struct ActiveRequest{Req,Resp}
    handle::Iceoryx2FFI.iox2_active_request_h
    storage::_StorageRef{Iceoryx2FFI.iox2_active_request_t}
end

function _finalize_active_request(req::ActiveRequest)
    if req.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_active_request_drop(req.handle)
        req.handle = _IOX2_NULL
    end
    req.storage = _free_struct!(req.storage)
    return nothing
end

@inline function payload(req::ActiveRequest{ReqT,RespT}) where {ReqT,RespT}
    ptr_ref = Ref{Ptr{Cvoid}}()
    len_ref = Ref{Iceoryx2FFI.c_size_t}()
    Iceoryx2FFI.iox2_active_request_payload(Ref{Iceoryx2FFI.iox2_active_request_h}(req.handle), ptr_ref, len_ref)
    return Slice{ReqT}(Ptr{ReqT}(ptr_ref[]), Int(len_ref[]))
end

mutable struct ResponseMut{Resp}
    handle::Iceoryx2FFI.iox2_response_mut_h
    storage::_StorageRef{Iceoryx2FFI.iox2_response_mut_t}
end

function _finalize_response_mut(resp::ResponseMut)
    if resp.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_response_mut_drop(resp.handle)
        resp.handle = _IOX2_NULL
    end
    resp.storage = _free_struct!(resp.storage)
    return nothing
end

@inline function payload_mut(resp::ResponseMut{RespT}) where {RespT}
    ptr_ref = Ref{Ptr{Cvoid}}()
    len_ref = Ref{Iceoryx2FFI.c_size_t}()
    Iceoryx2FFI.iox2_response_mut_payload_mut(Ref{Iceoryx2FFI.iox2_response_mut_h}(resp.handle), ptr_ref, len_ref)
    return Slice{RespT}(Ptr{RespT}(ptr_ref[]), Int(len_ref[]))
end

function receive(server::Server{Req,Resp}) where {Req,Resp}
    _require_valid(server.handle, "server")
    storage = Ref{Iceoryx2FFI.iox2_active_request_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_active_request_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_server_receive(Ref{Iceoryx2FFI.iox2_server_h}(server.handle), storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_receive_error_e)
    if handle_ref[] == _IOX2_NULL
        storage = _free_struct!(storage)
        return nothing
    end
    req = ActiveRequest{Req,Resp}(handle_ref[], storage)
    finalizer(_finalize_active_request, req)
    return req
end

function loan_response(req::ActiveRequest{Req,Resp}, n::Integer) where {Req,Resp}
    storage = Ref{Iceoryx2FFI.iox2_response_mut_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_response_mut_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_active_request_loan_slice_uninit(Ref{Iceoryx2FFI.iox2_active_request_h}(req.handle), storage, handle_ref, Iceoryx2FFI.c_size_t(n))
    check_ok(ret, Iceoryx2FFI.iox2_loan_error_e)
    resp = ResponseMut{Resp}(handle_ref[], storage)
    finalizer(_finalize_response_mut, resp)
    return resp
end

function send_copy(req::ActiveRequest{Req,Resp}, data::Ptr{Resp}, n::Integer) where {Req,Resp}
    ret = Iceoryx2FFI.iox2_active_request_send_copy(Ref{Iceoryx2FFI.iox2_active_request_h}(req.handle), data, Iceoryx2FFI.c_size_t(sizeof(Resp)), Iceoryx2FFI.c_size_t(n))
    check_ok(ret, Iceoryx2FFI.iox2_send_error_e)
    return nothing
end

function send!(resp::ResponseMut)
    ret = Iceoryx2FFI.iox2_response_mut_send(resp.handle)
    check_ok(ret, Iceoryx2FFI.iox2_send_error_e)
    resp.handle = _IOX2_NULL
    resp.storage = _free_struct!(resp.storage)
    return nothing
end

# === Event ===

mutable struct PortFactoryEvent
    handle::Iceoryx2FFI.iox2_port_factory_event_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_event_t}
    keepalive::Node
end

function _finalize_port_factory_event(factory::PortFactoryEvent)
    if factory.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_port_factory_event_drop(factory.handle)
        factory.handle = _IOX2_NULL
    end
    factory.storage = _free_struct!(factory.storage)
    return nothing
end

function open_or_create(builder::EventServiceBuilder)
    _require_valid(builder.handle, "event service builder")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_event_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_event_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_event_open_or_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_event_open_or_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    factory = PortFactoryEvent(handle_ref[], storage, builder.keepalive)
    finalizer(_finalize_port_factory_event, factory)
    return factory
end

function open_or_create(f::Function, builder::EventServiceBuilder)
    factory = open_or_create(builder)
    try
        return f(factory)
    finally
        close(factory)
    end
end

mutable struct NotifierBuilder
    handle::Iceoryx2FFI.iox2_port_factory_notifier_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_notifier_builder_t}
    keepalive::PortFactoryEvent
end

function _finalize_notifier_builder(builder::NotifierBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = _free_struct!(builder.storage)
    return nothing
end

function notifier_builder(factory::PortFactoryEvent)
    _require_valid(factory.handle, "event port factory")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_notifier_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_event_notifier_builder(Ref{Iceoryx2FFI.iox2_port_factory_event_h}(factory.handle), storage)
    builder = NotifierBuilder(handle, storage, factory)
    finalizer(_finalize_notifier_builder, builder)
    return builder
end

mutable struct ListenerBuilder
    handle::Iceoryx2FFI.iox2_port_factory_listener_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_listener_builder_t}
    keepalive::PortFactoryEvent
end

function _finalize_listener_builder(builder::ListenerBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = _free_struct!(builder.storage)
    return nothing
end

function listener_builder(factory::PortFactoryEvent)
    _require_valid(factory.handle, "event port factory")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_listener_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_event_listener_builder(Ref{Iceoryx2FFI.iox2_port_factory_event_h}(factory.handle), storage)
    builder = ListenerBuilder(handle, storage, factory)
    finalizer(_finalize_listener_builder, builder)
    return builder
end

mutable struct Notifier
    handle::Iceoryx2FFI.iox2_notifier_h
    storage::_StorageRef{Iceoryx2FFI.iox2_notifier_t}
    keepalive::PortFactoryEvent
end

function _finalize_notifier(notifier::Notifier)
    if notifier.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_notifier_drop(notifier.handle)
        notifier.handle = _IOX2_NULL
    end
    notifier.storage = _free_struct!(notifier.storage)
    return nothing
end

function create(builder::NotifierBuilder)
    _require_valid(builder.handle, "notifier builder")
    storage = Ref{Iceoryx2FFI.iox2_notifier_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_notifier_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_notifier_builder_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_notifier_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_notifier_builder(builder)
    notifier = Notifier(handle_ref[], storage, builder.keepalive)
    finalizer(_finalize_notifier, notifier)
    return notifier
end

function create(f::Function, builder::NotifierBuilder)
    notifier = create(builder)
    try
        return f(notifier)
    finally
        close(notifier)
    end
end

mutable struct Listener
    handle::Iceoryx2FFI.iox2_listener_h
    storage::_StorageRef{Iceoryx2FFI.iox2_listener_t}
    keepalive::PortFactoryEvent
end

function _finalize_listener(listener::Listener)
    if listener.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_listener_drop(listener.handle)
        listener.handle = _IOX2_NULL
    end
    listener.storage = _free_struct!(listener.storage)
    return nothing
end

function create(builder::ListenerBuilder)
    _require_valid(builder.handle, "listener builder")
    storage = Ref{Iceoryx2FFI.iox2_listener_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_listener_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_listener_builder_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_listener_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_listener_builder(builder)
    listener = Listener(handle_ref[], storage, builder.keepalive)
    finalizer(_finalize_listener, listener)
    return listener
end

function create(f::Function, builder::ListenerBuilder)
    listener = create(builder)
    try
        return f(listener)
    finally
        close(listener)
    end
end

function notify!(notifier::Notifier)
    count = Ref{Iceoryx2FFI.c_size_t}()
    ret = Iceoryx2FFI.iox2_notifier_notify(Ref{Iceoryx2FFI.iox2_notifier_h}(notifier.handle), count)
    check_ok(ret, Iceoryx2FFI.iox2_notifier_notify_error_e)
    return Int(count[])
end

# === Blackboard (minimal) ===

mutable struct PortFactoryBlackboard
    handle::Iceoryx2FFI.iox2_port_factory_blackboard_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_blackboard_t}
    keepalive::Node
    values::Vector{Any}
end

function _finalize_port_factory_blackboard(factory::PortFactoryBlackboard)
    if factory.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_port_factory_blackboard_drop(factory.handle)
        factory.handle = _IOX2_NULL
    end
    factory.storage = _free_struct!(factory.storage)
    empty!(factory.values)
    return nothing
end

function create(builder::BlackboardCreatorBuilder)
    _require_valid(builder.handle, "blackboard creator")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_blackboard_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_blackboard_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_blackboard_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_blackboard_create_error_e)
    builder.handle = _IOX2_NULL
    values = builder.values
    builder.values = Any[]
    _finalize_service_builder_variant(builder)
    factory = PortFactoryBlackboard(handle_ref[], storage, builder.keepalive, values)
    finalizer(_finalize_port_factory_blackboard, factory)
    return factory
end

function create(f::Function, builder::BlackboardCreatorBuilder)
    factory = create(builder)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function open(builder::BlackboardOpenerBuilder)
    _require_valid(builder.handle, "blackboard opener")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_blackboard_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_blackboard_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_blackboard_open(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_blackboard_open_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    factory = PortFactoryBlackboard(handle_ref[], storage, builder.keepalive, Any[])
    finalizer(_finalize_port_factory_blackboard, factory)
    return factory
end

function open(f::Function, builder::BlackboardOpenerBuilder)
    factory = open(builder)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function key_type!(builder::BlackboardCreatorBuilder, ::Type{K}) where {K}
    _require_valid(builder.handle, "blackboard creator")
    _require_isbits(K)
    name, name_len, size, alignment = _type_details(K)
    push!(builder.values, name)
    GC.@preserve name begin
        ret = Iceoryx2FFI.iox2_service_builder_blackboard_creator_set_key_type_details(
            Ref{Iceoryx2FFI.iox2_service_builder_blackboard_creator_h}(builder.handle),
            Base.unsafe_convert(Cstring, name),
            name_len,
            size,
            alignment,
        )
        check_ok(ret, Iceoryx2FFI.iox2_type_detail_error_e)
    end
    return builder
end

function key_type!(builder::BlackboardOpenerBuilder, ::Type{K}) where {K}
    _require_valid(builder.handle, "blackboard opener")
    _require_isbits(K)
    name, name_len, size, alignment = _type_details(K)
    GC.@preserve name begin
        ret = Iceoryx2FFI.iox2_service_builder_blackboard_opener_set_key_type_details(
            Ref{Iceoryx2FFI.iox2_service_builder_blackboard_opener_h}(builder.handle),
            Base.unsafe_convert(Cstring, name),
            name_len,
            size,
            alignment,
        )
        check_ok(ret, Iceoryx2FFI.iox2_type_detail_error_e)
    end
    return builder
end

function _blackboard_release_callback(::Ptr{Cvoid})
    return nothing
end

const _BLACKBOARD_RELEASE_CB = @cfunction(_blackboard_release_callback, Cvoid, (Ptr{Cvoid},))

function add_with_default!(builder::BlackboardCreatorBuilder, key::K, value::V) where {K,V}
    _require_valid(builder.handle, "blackboard creator")
    _require_isbits(K)
    _require_isbits(V)
    key_type!(builder, K)
    key_ref = Ref{K}(key)
    value_ref = Ref{V}(value)
    push!(builder.values, key_ref)
    push!(builder.values, value_ref)
    name, name_len, size, alignment = _type_details(V)
    push!(builder.values, name)
    GC.@preserve key_ref value_ref name begin
        Iceoryx2FFI.iox2_service_builder_blackboard_creator_add(
            Ref{Iceoryx2FFI.iox2_service_builder_blackboard_creator_h}(builder.handle),
            Base.unsafe_convert(Ptr{Cvoid}, key_ref),
            Base.unsafe_convert(Ptr{Cvoid}, value_ref),
            _BLACKBOARD_RELEASE_CB,
            Base.unsafe_convert(Cstring, name),
            name_len,
            size,
            alignment,
        )
    end
    return builder
end

mutable struct WriterBuilder
    handle::Iceoryx2FFI.iox2_port_factory_writer_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_writer_builder_t}
    keepalive::PortFactoryBlackboard
end

function _finalize_writer_builder(builder::WriterBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = _free_struct!(builder.storage)
    return nothing
end

function writer_builder(factory::PortFactoryBlackboard)
    _require_valid(factory.handle, "blackboard port factory")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_writer_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_blackboard_writer_builder(Ref{Iceoryx2FFI.iox2_port_factory_blackboard_h}(factory.handle), storage)
    builder = WriterBuilder(handle, storage, factory)
    finalizer(_finalize_writer_builder, builder)
    return builder
end

mutable struct ReaderBuilder
    handle::Iceoryx2FFI.iox2_port_factory_reader_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_reader_builder_t}
    keepalive::PortFactoryBlackboard
end

function _finalize_reader_builder(builder::ReaderBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = _free_struct!(builder.storage)
    return nothing
end

function reader_builder(factory::PortFactoryBlackboard)
    _require_valid(factory.handle, "blackboard port factory")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_reader_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_blackboard_reader_builder(Ref{Iceoryx2FFI.iox2_port_factory_blackboard_h}(factory.handle), storage)
    builder = ReaderBuilder(handle, storage, factory)
    finalizer(_finalize_reader_builder, builder)
    return builder
end

mutable struct Writer
    handle::Iceoryx2FFI.iox2_writer_h
    storage::_StorageRef{Iceoryx2FFI.iox2_writer_t}
    keepalive::PortFactoryBlackboard
end

function _finalize_writer(writer::Writer)
    if writer.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_writer_drop(writer.handle)
        writer.handle = _IOX2_NULL
    end
    writer.storage = _free_struct!(writer.storage)
    return nothing
end

function create(builder::WriterBuilder)
    _require_valid(builder.handle, "writer builder")
    storage = Ref{Iceoryx2FFI.iox2_writer_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_writer_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_writer_builder_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_writer_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_writer_builder(builder)
    writer = Writer(handle_ref[], storage, builder.keepalive)
    finalizer(_finalize_writer, writer)
    return writer
end

function create(f::Function, builder::WriterBuilder)
    writer = create(builder)
    try
        return f(writer)
    finally
        close(writer)
    end
end

mutable struct Reader
    handle::Iceoryx2FFI.iox2_reader_h
    storage::_StorageRef{Iceoryx2FFI.iox2_reader_t}
    keepalive::PortFactoryBlackboard
end

function _finalize_reader(reader::Reader)
    if reader.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_reader_drop(reader.handle)
        reader.handle = _IOX2_NULL
    end
    reader.storage = _free_struct!(reader.storage)
    return nothing
end

function create(builder::ReaderBuilder)
    _require_valid(builder.handle, "reader builder")
    storage = Ref{Iceoryx2FFI.iox2_reader_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_reader_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_reader_builder_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_reader_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_reader_builder(builder)
    reader = Reader(handle_ref[], storage, builder.keepalive)
    finalizer(_finalize_reader, reader)
    return reader
end

function create(f::Function, builder::ReaderBuilder)
    reader = create(builder)
    try
        return f(reader)
    finally
        close(reader)
    end
end

@inline Base.isvalid(obj::PortFactoryPubSub) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::Publisher) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::Subscriber) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::Sample) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::SampleMut) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::PortFactoryRequestResponse) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::Client) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::Server) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::RequestMut) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::PendingResponse) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::Response) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::ActiveRequest) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::ResponseMut) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::PortFactoryEvent) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::Notifier) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::Listener) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::PortFactoryBlackboard) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::Writer) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::Reader) = obj.handle != _IOX2_NULL

function Base.close(obj::PortFactoryPubSub)
    _finalize_port_factory_pub_sub(obj)
    return nothing
end

function Base.close(obj::Publisher)
    _finalize_publisher(obj)
    return nothing
end

function Base.close(obj::Subscriber)
    _finalize_subscriber(obj)
    return nothing
end

function Base.close(obj::Sample)
    _finalize_sample(obj)
    return nothing
end

function Base.close(obj::SampleMut)
    _finalize_sample_mut(obj)
    return nothing
end

function Base.close(obj::PortFactoryRequestResponse)
    _finalize_port_factory_request_response(obj)
    return nothing
end

function Base.close(obj::Client)
    _finalize_client(obj)
    return nothing
end

function Base.close(obj::Server)
    _finalize_server(obj)
    return nothing
end

function Base.close(obj::RequestMut)
    _finalize_request_mut(obj)
    return nothing
end

function Base.close(obj::PendingResponse)
    _finalize_pending_response(obj)
    return nothing
end

function Base.close(obj::Response)
    _finalize_response(obj)
    return nothing
end

function Base.close(obj::ActiveRequest)
    _finalize_active_request(obj)
    return nothing
end

function Base.close(obj::ResponseMut)
    _finalize_response_mut(obj)
    return nothing
end

function Base.close(obj::PortFactoryEvent)
    _finalize_port_factory_event(obj)
    return nothing
end

function Base.close(obj::Notifier)
    _finalize_notifier(obj)
    return nothing
end

function Base.close(obj::Listener)
    _finalize_listener(obj)
    return nothing
end

function Base.close(obj::PortFactoryBlackboard)
    _finalize_port_factory_blackboard(obj)
    return nothing
end

function Base.close(obj::Writer)
    _finalize_writer(obj)
    return nothing
end

function Base.close(obj::Reader)
    _finalize_reader(obj)
    return nothing
end
