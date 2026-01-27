# Messaging patterns: pub/sub, request/response, event, blackboard.

import UnsafeArrays: UnsafeArray

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

struct TypeDetails
    name::String
    name_len::Iceoryx2FFI.c_size_t
    size::Iceoryx2FFI.c_size_t
    alignment::Iceoryx2FFI.c_size_t
end

const _TYPE_DETAILS = IdDict{DataType, TypeDetails}()
const _TYPE_DETAILS_LOCK = Base.Threads.SpinLock()

@inline function _type_details(::Type{T}) where {T}
    if Base.Threads.nthreads() == 1
        details = Base.get!(_TYPE_DETAILS, T) do
            name = string(T)
            TypeDetails(
                name,
                Iceoryx2FFI.c_size_t(ncodeunits(name)),
                Iceoryx2FFI.c_size_t(sizeof(T)),
                Iceoryx2FFI.c_size_t(Base.datatype_alignment(T)),
            )
        end::TypeDetails
        return details.name, details.name_len, details.size, details.alignment
    end
    lock(_TYPE_DETAILS_LOCK)
    try
        details = Base.get!(_TYPE_DETAILS, T) do
            name = string(T)
            TypeDetails(
                name,
                Iceoryx2FFI.c_size_t(ncodeunits(name)),
                Iceoryx2FFI.c_size_t(sizeof(T)),
                Iceoryx2FFI.c_size_t(Base.datatype_alignment(T)),
            )
        end::TypeDetails
    finally
        unlock(_TYPE_DETAILS_LOCK)
    end
    return details.name, details.name_len, details.size, details.alignment
end

const _StorageRef{T} = Union{Nothing, Base.RefValue{T}}

struct Slice{T,O}
    ptr::Ptr{T}
    len::Int
    owner::O
end

Slice{T}(ptr::Ptr{T}, len::Integer) where {T} = Slice{T,Nothing}(ptr, Int(len), nothing)
Slice{T}(ptr::Ptr{T}, len::Integer, owner) where {T} = Slice{T,typeof(owner)}(ptr, Int(len), owner)

Base.length(slice::Slice) = slice.len
Base.size(slice::Slice) = (slice.len,)
Base.eltype(::Type{Slice{T}}) where {T} = T
Base.IndexStyle(::Type{<:Slice}) = IndexLinear()
Base.firstindex(::Slice) = 1
Base.lastindex(slice::Slice) = slice.len

@inline function Base.getindex(slice::Slice{T}, i::Int) where {T}
    @boundscheck (i >= 1 && i <= slice.len) || throw(BoundsError(slice, i))
    return unsafe_load(slice.ptr, i)
end

@inline function Base.iterate(slice::Slice{T}, state::Int = 1) where {T}
    state > slice.len && return nothing
    return unsafe_load(slice.ptr, state), state + 1
end

struct EventId
    raw::Iceoryx2FFI.iox2_event_id_t
end

EventId(value::Integer) = EventId(Iceoryx2FFI.iox2_event_id_t(Iceoryx2FFI.c_size_t(value)))

@inline value(id::EventId) = id.raw.value
@inline Base.Int(id::EventId) = Int(id.raw.value)

# === Publish/Subscribe ===

function payload_type!(builder::PubSubServiceBuilder, ::Type{T}; variant::Union{Symbol,Iceoryx2FFI.iox2_type_variant_e}=:fixed) where {T}
    _require_valid(builder.handle, "pub_sub service builder")
    _require_isbits(T)
    if builder.payload_type === nothing
        builder.payload_type = T
    elseif builder.payload_type !== T
        throw(ArgumentError("pub_sub payload type already set to $(builder.payload_type)"))
    end
    name, name_len, size, alignment = _type_details(T)
    v = _type_variant(variant)
    GC.@preserve name begin
        ret = Iceoryx2FFI.iox2_service_builder_pub_sub_set_payload_type_details(Ref{Iceoryx2FFI.iox2_service_builder_pub_sub_h}(builder.handle), v, Base.unsafe_convert(Cstring, name), name_len, size, alignment)
        check_ok(ret, Iceoryx2FFI.iox2_type_detail_error_e)
    end
    return builder
end

function user_header_type!(builder::PubSubServiceBuilder, ::Type{T}; variant::Union{Symbol,Iceoryx2FFI.iox2_type_variant_e}=:fixed) where {T}
    _require_valid(builder.handle, "pub_sub service builder")
    _require_isbits(T)
    if builder.user_header_type === nothing
        builder.user_header_type = T
    elseif builder.user_header_type !== T
        throw(ArgumentError("pub_sub user header type already set to $(builder.user_header_type)"))
    end
    name, name_len, size, alignment = _type_details(T)
    v = _type_variant(variant)
    GC.@preserve name begin
        ret = Iceoryx2FFI.iox2_service_builder_pub_sub_set_user_header_type_details(
            Ref{Iceoryx2FFI.iox2_service_builder_pub_sub_h}(builder.handle),
            v,
            Base.unsafe_convert(Cstring, name),
            name_len,
            size,
            alignment,
        )
        check_ok(ret, Iceoryx2FFI.iox2_type_detail_error_e)
    end
    return builder
end

function max_publishers!(builder::PubSubServiceBuilder, value::Integer)
    _require_valid(builder.handle, "pub_sub service builder")
    Iceoryx2FFI.iox2_service_builder_pub_sub_set_max_publishers(
        Ref{Iceoryx2FFI.iox2_service_builder_pub_sub_h}(builder.handle),
        Iceoryx2FFI.c_size_t(value),
    )
    return builder
end

function max_subscribers!(builder::PubSubServiceBuilder, value::Integer)
    _require_valid(builder.handle, "pub_sub service builder")
    Iceoryx2FFI.iox2_service_builder_pub_sub_set_max_subscribers(
        Ref{Iceoryx2FFI.iox2_service_builder_pub_sub_h}(builder.handle),
        Iceoryx2FFI.c_size_t(value),
    )
    return builder
end

function history_size!(builder::PubSubServiceBuilder, value::Integer)
    _require_valid(builder.handle, "pub_sub service builder")
    Iceoryx2FFI.iox2_service_builder_pub_sub_set_history_size(
        Ref{Iceoryx2FFI.iox2_service_builder_pub_sub_h}(builder.handle),
        Iceoryx2FFI.c_size_t(value),
    )
    return builder
end

function subscriber_max_buffer_size!(builder::PubSubServiceBuilder, value::Integer)
    _require_valid(builder.handle, "pub_sub service builder")
    Iceoryx2FFI.iox2_service_builder_pub_sub_set_subscriber_max_buffer_size(
        Ref{Iceoryx2FFI.iox2_service_builder_pub_sub_h}(builder.handle),
        Iceoryx2FFI.c_size_t(value),
    )
    return builder
end

function subscriber_max_borrowed_samples!(builder::PubSubServiceBuilder, value::Integer)
    _require_valid(builder.handle, "pub_sub service builder")
    Iceoryx2FFI.iox2_service_builder_pub_sub_set_subscriber_max_borrowed_samples(
        Ref{Iceoryx2FFI.iox2_service_builder_pub_sub_h}(builder.handle),
        Iceoryx2FFI.c_size_t(value),
    )
    return builder
end

function enable_safe_overflow!(builder::PubSubServiceBuilder, value::Bool)
    _require_valid(builder.handle, "pub_sub service builder")
    Iceoryx2FFI.iox2_service_builder_pub_sub_set_enable_safe_overflow(
        Ref{Iceoryx2FFI.iox2_service_builder_pub_sub_h}(builder.handle),
        value,
    )
    return builder
end

mutable struct PortFactoryPubSub{T}
    handle::Iceoryx2FFI.iox2_port_factory_pub_sub_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_pub_sub_t}
    keepalive::Node
end

function _finalize_port_factory_pub_sub(factory::PortFactoryPubSub)
    if factory.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_port_factory_pub_sub_drop(factory.handle)
        factory.handle = _IOX2_NULL
    end
    factory.storage = nothing
    return nothing
end

function open_or_create(builder::PubSubServiceBuilder)
    _require_valid(builder.handle, "pub_sub service builder")
    payload_type = builder.payload_type
    payload_type === nothing && throw(ArgumentError("payload type must be set with payload_type!"))
    storage = Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_pub_sub_open_or_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_pub_sub_open_or_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    factory = PortFactoryPubSub{payload_type}(handle_ref[], storage, builder.keepalive)
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
    keepalive::PortFactoryPubSub{T}
end

function _finalize_publisher_builder(builder::PublisherBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

function publisher_builder(factory::PortFactoryPubSub{T}, ::Type{T}) where {T}
    _require_valid(factory.handle, "pub_sub port factory")
    _require_isbits(T)
    storage = Ref{Iceoryx2FFI.iox2_port_factory_publisher_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_pub_sub_publisher_builder(Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_h}(factory.handle), storage)
    builder = PublisherBuilder{T}(handle, storage, factory)
    finalizer(_finalize_publisher_builder, builder)
    return builder
end

function max_loaned_samples!(builder::PublisherBuilder, value::Integer)
    _require_valid(builder.handle, "publisher builder")
    Iceoryx2FFI.iox2_port_factory_publisher_builder_set_max_loaned_samples(
        Ref{Iceoryx2FFI.iox2_port_factory_publisher_builder_h}(builder.handle),
        Iceoryx2FFI.c_size_t(value),
    )
    return builder
end

function initial_max_slice_len!(builder::PublisherBuilder, value::Integer)
    _require_valid(builder.handle, "publisher builder")
    Iceoryx2FFI.iox2_port_factory_publisher_builder_set_initial_max_slice_len(
        Ref{Iceoryx2FFI.iox2_port_factory_publisher_builder_h}(builder.handle),
        Iceoryx2FFI.c_size_t(value),
    )
    return builder
end

mutable struct SubscriberBuilder{T}
    handle::Iceoryx2FFI.iox2_port_factory_subscriber_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_subscriber_builder_t}
    keepalive::PortFactoryPubSub{T}
end

function _finalize_subscriber_builder(builder::SubscriberBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

function subscriber_builder(factory::PortFactoryPubSub{T}, ::Type{T}) where {T}
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
    keepalive::PortFactoryPubSub{T}
end

function _finalize_publisher(pub::Publisher)
    if pub.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_publisher_drop(pub.handle)
        pub.handle = _IOX2_NULL
    end
    pub.storage = nothing
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
    keepalive::PortFactoryPubSub{T}
end

function _finalize_subscriber(sub::Subscriber)
    if sub.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_subscriber_drop(sub.handle)
        sub.handle = _IOX2_NULL
    end
    sub.storage = nothing
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
    sample.storage = nothing
    return nothing
end

@inline function payload(sample::Sample{T}) where {T}
    ptr_ref = Ref{Ptr{Cvoid}}()
    len_ref = Ref{Iceoryx2FFI.c_size_t}()
    Iceoryx2FFI.iox2_sample_payload(Ref{Iceoryx2FFI.iox2_sample_h}(sample.handle), ptr_ref, len_ref)
    return Slice{T}(Ptr{T}(ptr_ref[]), Int(len_ref[]), sample)
end

@inline function unsafe_payload_ptr(sample::Sample{T}) where {T}
    return payload(sample).ptr
end

@inline function unsafe_user_header_ptr(sample::Sample, ::Type{T}) where {T}
    _require_isbits(T)
    ptr_ref = Ref{Ptr{Cvoid}}()
    Iceoryx2FFI.iox2_sample_user_header(Ref{Iceoryx2FFI.iox2_sample_h}(sample.handle), ptr_ref)
    return Ptr{T}(ptr_ref[])
end

@inline function user_header_view(sample::Sample, ::Type{T}) where {T}
    return UnsafeArray(unsafe_user_header_ptr(sample, T), (1,))
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
    sample.storage = nothing
    return nothing
end

@inline function payload_mut(sample::SampleMut{T}) where {T}
    ptr_ref = Ref{Ptr{Cvoid}}()
    len_ref = Ref{Iceoryx2FFI.c_size_t}()
    Iceoryx2FFI.iox2_sample_mut_payload_mut(Ref{Iceoryx2FFI.iox2_sample_mut_h}(sample.handle), ptr_ref, len_ref)
    return Slice{T}(Ptr{T}(ptr_ref[]), Int(len_ref[]), sample)
end

@inline function unsafe_payload_mut_ptr(sample::SampleMut{T}) where {T}
    return payload_mut(sample).ptr
end

@inline function unsafe_user_header_mut_ptr(sample::SampleMut, ::Type{T}) where {T}
    _require_isbits(T)
    ptr_ref = Ref{Ptr{Cvoid}}()
    Iceoryx2FFI.iox2_sample_mut_user_header_mut(Ref{Iceoryx2FFI.iox2_sample_mut_h}(sample.handle), ptr_ref)
    return Ptr{T}(ptr_ref[])
end

@inline function user_header_mut_view(sample::SampleMut, ::Type{T}) where {T}
    return UnsafeArray(unsafe_user_header_mut_ptr(sample, T), (1,))
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

@inline function loan_uninit(publisher::Publisher{T}) where {T}
    return loan_slice(publisher, 1)
end

function loan_slice(f::Function, publisher::Publisher{T}, n::Integer) where {T}
    sample = loan_slice(publisher, n)
    try
        return f(sample)
    finally
        close(sample)
    end
end

function loan_slice(publisher::Publisher{T}, n::Integer, f::Function) where {T}
    return loan_slice(f, publisher, n)
end

@inline function write_payload!(sample::SampleMut{T}, value::T) where {T}
    slice = payload_mut(sample)
    unsafe_store!(slice.ptr, value, 1)
    return sample
end

@inline function send!(sample::SampleMut)
    ret = Iceoryx2FFI.iox2_sample_mut_send(sample.handle, C_NULL)
    check_ok(ret, Iceoryx2FFI.iox2_send_error_e)
    sample.handle = _IOX2_NULL
    sample.storage = nothing
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
        storage = nothing
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
    if builder.request_type === nothing
        builder.request_type = T
    elseif builder.request_type !== T
        throw(ArgumentError("request payload type already set to $(builder.request_type)"))
    end
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
    if builder.response_type === nothing
        builder.response_type = T
    elseif builder.response_type !== T
        throw(ArgumentError("response payload type already set to $(builder.response_type)"))
    end
    name, name_len, size, alignment = _type_details(T)
    v = _type_variant(variant)
    GC.@preserve name begin
        ret = Iceoryx2FFI.iox2_service_builder_request_response_set_response_payload_type_details(Ref{Iceoryx2FFI.iox2_service_builder_request_response_h}(builder.handle), v, Base.unsafe_convert(Cstring, name), name_len, size, alignment)
        check_ok(ret, Iceoryx2FFI.iox2_type_detail_error_e)
    end
    return builder
end

function request_user_header_type!(builder::RequestResponseServiceBuilder, ::Type{T}; variant::Union{Symbol,Iceoryx2FFI.iox2_type_variant_e}=:fixed) where {T}
    _require_valid(builder.handle, "request/response service builder")
    _require_isbits(T)
    if builder.request_header_type === nothing
        builder.request_header_type = T
    elseif builder.request_header_type !== T
        throw(ArgumentError("request user header type already set to $(builder.request_header_type)"))
    end
    name, name_len, size, alignment = _type_details(T)
    v = _type_variant(variant)
    GC.@preserve name begin
        ret = Iceoryx2FFI.iox2_service_builder_request_response_set_request_header_type_details(
            Ref{Iceoryx2FFI.iox2_service_builder_request_response_h}(builder.handle),
            v,
            Base.unsafe_convert(Cstring, name),
            name_len,
            size,
            alignment,
        )
        check_ok(ret, Iceoryx2FFI.iox2_type_detail_error_e)
    end
    return builder
end

function response_user_header_type!(builder::RequestResponseServiceBuilder, ::Type{T}; variant::Union{Symbol,Iceoryx2FFI.iox2_type_variant_e}=:fixed) where {T}
    _require_valid(builder.handle, "request/response service builder")
    _require_isbits(T)
    if builder.response_header_type === nothing
        builder.response_header_type = T
    elseif builder.response_header_type !== T
        throw(ArgumentError("response user header type already set to $(builder.response_header_type)"))
    end
    name, name_len, size, alignment = _type_details(T)
    v = _type_variant(variant)
    GC.@preserve name begin
        ret = Iceoryx2FFI.iox2_service_builder_request_response_set_response_header_type_details(
            Ref{Iceoryx2FFI.iox2_service_builder_request_response_h}(builder.handle),
            v,
            Base.unsafe_convert(Cstring, name),
            name_len,
            size,
            alignment,
        )
        check_ok(ret, Iceoryx2FFI.iox2_type_detail_error_e)
    end
    return builder
end

function max_clients!(builder::RequestResponseServiceBuilder, value::Integer)
    _require_valid(builder.handle, "request_response service builder")
    Iceoryx2FFI.iox2_service_builder_request_response_max_clients(
        Ref{Iceoryx2FFI.iox2_service_builder_request_response_h}(builder.handle),
        Iceoryx2FFI.c_size_t(value),
    )
    return builder
end

function max_servers!(builder::RequestResponseServiceBuilder, value::Integer)
    _require_valid(builder.handle, "request_response service builder")
    Iceoryx2FFI.iox2_service_builder_request_response_max_servers(
        Ref{Iceoryx2FFI.iox2_service_builder_request_response_h}(builder.handle),
        Iceoryx2FFI.c_size_t(value),
    )
    return builder
end

function max_loaned_requests!(builder::RequestResponseServiceBuilder, value::Integer)
    _require_valid(builder.handle, "request_response service builder")
    Iceoryx2FFI.iox2_service_builder_request_response_max_loaned_requests(
        Ref{Iceoryx2FFI.iox2_service_builder_request_response_h}(builder.handle),
        Iceoryx2FFI.c_size_t(value),
    )
    return builder
end

function max_response_buffer_size!(builder::RequestResponseServiceBuilder, value::Integer)
    _require_valid(builder.handle, "request_response service builder")
    Iceoryx2FFI.iox2_service_builder_request_response_max_response_buffer_size(
        Ref{Iceoryx2FFI.iox2_service_builder_request_response_h}(builder.handle),
        Iceoryx2FFI.c_size_t(value),
    )
    return builder
end

function enable_safe_overflow_for_requests!(builder::RequestResponseServiceBuilder, value::Bool)
    _require_valid(builder.handle, "request_response service builder")
    Iceoryx2FFI.iox2_service_builder_request_response_enable_safe_overflow_for_requests(
        Ref{Iceoryx2FFI.iox2_service_builder_request_response_h}(builder.handle),
        value,
    )
    return builder
end

function enable_safe_overflow_for_responses!(builder::RequestResponseServiceBuilder, value::Bool)
    _require_valid(builder.handle, "request_response service builder")
    Iceoryx2FFI.iox2_service_builder_request_response_enable_safe_overflow_for_responses(
        Ref{Iceoryx2FFI.iox2_service_builder_request_response_h}(builder.handle),
        value,
    )
    return builder
end

function max_active_requests_per_client!(builder::RequestResponseServiceBuilder, value::Integer)
    _require_valid(builder.handle, "request_response service builder")
    Iceoryx2FFI.iox2_service_builder_request_response_max_active_requests_per_client(
        Ref{Iceoryx2FFI.iox2_service_builder_request_response_h}(builder.handle),
        Iceoryx2FFI.c_size_t(value),
    )
    return builder
end

function max_borrowed_responses_per_pending_response!(builder::RequestResponseServiceBuilder, value::Integer)
    _require_valid(builder.handle, "request_response service builder")
    Iceoryx2FFI.iox2_service_builder_request_response_max_borrowed_responses_per_pending_response(
        Ref{Iceoryx2FFI.iox2_service_builder_request_response_h}(builder.handle),
        Iceoryx2FFI.c_size_t(value),
    )
    return builder
end

mutable struct PortFactoryRequestResponse{Req,Resp}
    handle::Iceoryx2FFI.iox2_port_factory_request_response_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_request_response_t}
    keepalive::Node
end

function _finalize_port_factory_request_response(factory::PortFactoryRequestResponse)
    if factory.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_port_factory_request_response_drop(factory.handle)
        factory.handle = _IOX2_NULL
    end
    factory.storage = nothing
    return nothing
end

function open_or_create(builder::RequestResponseServiceBuilder)
    _require_valid(builder.handle, "request_response service builder")
    request_type = builder.request_type
    response_type = builder.response_type
    request_type === nothing && throw(ArgumentError("request payload type must be set with request_payload_type!"))
    response_type === nothing && throw(ArgumentError("response payload type must be set with response_payload_type!"))
    storage = Ref{Iceoryx2FFI.iox2_port_factory_request_response_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_request_response_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_request_response_open_or_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_request_response_open_or_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    factory = PortFactoryRequestResponse{request_type, response_type}(handle_ref[], storage, builder.keepalive)
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
    keepalive::PortFactoryRequestResponse{Req,Resp}
end

function _finalize_client_builder(builder::ClientBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

function client_builder(factory::PortFactoryRequestResponse{Req,Resp}, ::Type{Req}, ::Type{Resp}) where {Req,Resp}
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
    keepalive::PortFactoryRequestResponse{Req,Resp}
end

function _finalize_server_builder(builder::ServerBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

function server_builder(factory::PortFactoryRequestResponse{Req,Resp}, ::Type{Req}, ::Type{Resp}) where {Req,Resp}
    _require_valid(factory.handle, "request_response port factory")
    _require_isbits(Req)
    _require_isbits(Resp)
    storage = Ref{Iceoryx2FFI.iox2_port_factory_server_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_request_response_server_builder(Ref{Iceoryx2FFI.iox2_port_factory_request_response_h}(factory.handle), storage)
    builder = ServerBuilder{Req,Resp}(handle, storage, factory)
    finalizer(_finalize_server_builder, builder)
    return builder
end

function max_loaned_responses_per_request!(builder::ServerBuilder, value::Integer)
    _require_valid(builder.handle, "server builder")
    Iceoryx2FFI.iox2_port_factory_server_builder_set_max_loaned_responses_per_request(
        Ref{Iceoryx2FFI.iox2_port_factory_server_builder_h}(builder.handle),
        Iceoryx2FFI.c_size_t(value),
    )
    return builder
end

mutable struct Client{Req,Resp}
    handle::Iceoryx2FFI.iox2_client_h
    storage::_StorageRef{Iceoryx2FFI.iox2_client_t}
    keepalive::PortFactoryRequestResponse{Req,Resp}
end

function _finalize_client(client::Client)
    if client.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_client_drop(client.handle)
        client.handle = _IOX2_NULL
    end
    client.storage = nothing
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
    keepalive::PortFactoryRequestResponse{Req,Resp}
end

function _finalize_server(server::Server)
    if server.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_server_drop(server.handle)
        server.handle = _IOX2_NULL
    end
    server.storage = nothing
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
    request.storage = nothing
    return nothing
end

@inline function payload_mut(request::RequestMut{Req,Resp}) where {Req,Resp}
    ptr_ref = Ref{Ptr{Cvoid}}()
    len_ref = Ref{Iceoryx2FFI.c_size_t}()
    Iceoryx2FFI.iox2_request_mut_payload_mut(Ref{Iceoryx2FFI.iox2_request_mut_h}(request.handle), ptr_ref, len_ref)
    return Slice{Req}(Ptr{Req}(ptr_ref[]), Int(len_ref[]), request)
end

@inline function unsafe_payload_mut_ptr(request::RequestMut{Req,Resp}) where {Req,Resp}
    return payload_mut(request).ptr
end

@inline function write_payload!(request::RequestMut{Req,Resp}, value::Req) where {Req,Resp}
    slice = payload_mut(request)
    unsafe_store!(slice.ptr, value, 1)
    return request
end

@inline function unsafe_user_header_mut_ptr(request::RequestMut, ::Type{T}) where {T}
    _require_isbits(T)
    ptr_ref = Ref{Ptr{Cvoid}}()
    Iceoryx2FFI.iox2_request_mut_user_header_mut(Ref{Iceoryx2FFI.iox2_request_mut_h}(request.handle), ptr_ref)
    return Ptr{T}(ptr_ref[])
end

@inline function user_header_mut_view(request::RequestMut, ::Type{T}) where {T}
    return UnsafeArray(unsafe_user_header_mut_ptr(request, T), (1,))
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
    pending.storage = nothing
    return nothing
end

@inline function unsafe_user_header_ptr(pending::PendingResponse, ::Type{T}) where {T}
    _require_isbits(T)
    ptr_ref = Ref{Ptr{Cvoid}}()
    Iceoryx2FFI.iox2_pending_response_user_header(Ref{Iceoryx2FFI.iox2_pending_response_h}(pending.handle), ptr_ref)
    return Ptr{T}(ptr_ref[])
end

@inline function user_header_view(pending::PendingResponse, ::Type{T}) where {T}
    return UnsafeArray(unsafe_user_header_ptr(pending, T), (1,))
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

@inline function loan_uninit(client::Client{Req,Resp}) where {Req,Resp}
    return loan_request(client, 1)
end

function loan_request(f::Function, client::Client{Req,Resp}, n::Integer) where {Req,Resp}
    request = loan_request(client, n)
    try
        return f(request)
    finally
        close(request)
    end
end

function loan_request(client::Client{Req,Resp}, n::Integer, f::Function) where {Req,Resp}
    return loan_request(f, client, n)
end

function send!(request::RequestMut{Req,Resp}) where {Req,Resp}
    pending_storage = Ref{Iceoryx2FFI.iox2_pending_response_t}()
    pending_ref = Ref{Iceoryx2FFI.iox2_pending_response_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_request_mut_send(request.handle, pending_storage, pending_ref)
    check_ok(ret, Iceoryx2FFI.iox2_send_error_e)
    request.handle = _IOX2_NULL
    request.storage = nothing
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
    resp.storage = nothing
    return nothing
end

@inline function payload(resp::Response{RespT}) where {RespT}
    ptr_ref = Ref{Ptr{Cvoid}}()
    len_ref = Ref{Iceoryx2FFI.c_size_t}()
    Iceoryx2FFI.iox2_response_payload(Ref{Iceoryx2FFI.iox2_response_h}(resp.handle), ptr_ref, len_ref)
    return Slice{RespT}(Ptr{RespT}(ptr_ref[]), Int(len_ref[]), resp)
end

@inline function unsafe_payload_ptr(resp::Response{RespT}) where {RespT}
    return payload(resp).ptr
end

@inline function unsafe_user_header_ptr(resp::Response, ::Type{T}) where {T}
    _require_isbits(T)
    ptr_ref = Ref{Ptr{Cvoid}}()
    Iceoryx2FFI.iox2_response_user_header(Ref{Iceoryx2FFI.iox2_response_h}(resp.handle), ptr_ref)
    return Ptr{T}(ptr_ref[])
end

@inline function user_header_view(resp::Response, ::Type{T}) where {T}
    return UnsafeArray(unsafe_user_header_ptr(resp, T), (1,))
end

function receive(pending::PendingResponse{Resp}) where {Resp}
    storage = Ref{Iceoryx2FFI.iox2_response_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_response_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_pending_response_receive(Ref{Iceoryx2FFI.iox2_pending_response_h}(pending.handle), storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_receive_error_e)
    if handle_ref[] == _IOX2_NULL
        storage = nothing
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
    req.storage = nothing
    return nothing
end

@inline function payload(req::ActiveRequest{ReqT,RespT}) where {ReqT,RespT}
    ptr_ref = Ref{Ptr{Cvoid}}()
    len_ref = Ref{Iceoryx2FFI.c_size_t}()
    Iceoryx2FFI.iox2_active_request_payload(Ref{Iceoryx2FFI.iox2_active_request_h}(req.handle), ptr_ref, len_ref)
    return Slice{ReqT}(Ptr{ReqT}(ptr_ref[]), Int(len_ref[]), req)
end

@inline function unsafe_payload_ptr(req::ActiveRequest{ReqT,RespT}) where {ReqT,RespT}
    return payload(req).ptr
end

@inline function unsafe_user_header_ptr(req::ActiveRequest, ::Type{T}) where {T}
    _require_isbits(T)
    ptr_ref = Ref{Ptr{Cvoid}}()
    Iceoryx2FFI.iox2_active_request_user_header(Ref{Iceoryx2FFI.iox2_active_request_h}(req.handle), ptr_ref)
    return Ptr{T}(ptr_ref[])
end

@inline function user_header_view(req::ActiveRequest, ::Type{T}) where {T}
    return UnsafeArray(unsafe_user_header_ptr(req, T), (1,))
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
    resp.storage = nothing
    return nothing
end

@inline function payload_mut(resp::ResponseMut{RespT}) where {RespT}
    ptr_ref = Ref{Ptr{Cvoid}}()
    len_ref = Ref{Iceoryx2FFI.c_size_t}()
    Iceoryx2FFI.iox2_response_mut_payload_mut(Ref{Iceoryx2FFI.iox2_response_mut_h}(resp.handle), ptr_ref, len_ref)
    return Slice{RespT}(Ptr{RespT}(ptr_ref[]), Int(len_ref[]), resp)
end

@inline function unsafe_payload_mut_ptr(resp::ResponseMut{RespT}) where {RespT}
    return payload_mut(resp).ptr
end

@inline function write_payload!(resp::ResponseMut{RespT}, value::RespT) where {RespT}
    slice = payload_mut(resp)
    unsafe_store!(slice.ptr, value, 1)
    return resp
end

@inline function unsafe_user_header_mut_ptr(resp::ResponseMut, ::Type{T}) where {T}
    _require_isbits(T)
    ptr_ref = Ref{Ptr{Cvoid}}()
    Iceoryx2FFI.iox2_response_mut_user_header_mut(Ref{Iceoryx2FFI.iox2_response_mut_h}(resp.handle), ptr_ref)
    return Ptr{T}(ptr_ref[])
end

@inline function user_header_mut_view(resp::ResponseMut, ::Type{T}) where {T}
    return UnsafeArray(unsafe_user_header_mut_ptr(resp, T), (1,))
end

function receive(server::Server{Req,Resp}) where {Req,Resp}
    _require_valid(server.handle, "server")
    storage = Ref{Iceoryx2FFI.iox2_active_request_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_active_request_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_server_receive(Ref{Iceoryx2FFI.iox2_server_h}(server.handle), storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_receive_error_e)
    if handle_ref[] == _IOX2_NULL
        storage = nothing
        return nothing
    end
    req = ActiveRequest{Req,Resp}(handle_ref[], storage)
    finalizer(_finalize_active_request, req)
    return req
end

function has_requests(server::Server)
    result = Ref{Bool}()
    ret = Iceoryx2FFI.iox2_server_has_requests(Ref{Iceoryx2FFI.iox2_server_h}(server.handle), result)
    check_ok(ret, Iceoryx2FFI.iox2_connection_failure_e)
    return result[]
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

@inline function loan_uninit(req::ActiveRequest{Req,Resp}) where {Req,Resp}
    return loan_response(req, 1)
end

function loan_response(f::Function, req::ActiveRequest{Req,Resp}, n::Integer) where {Req,Resp}
    response = loan_response(req, n)
    try
        return f(response)
    finally
        close(response)
    end
end

function loan_response(req::ActiveRequest{Req,Resp}, n::Integer, f::Function) where {Req,Resp}
    return loan_response(f, req, n)
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
    resp.storage = nothing
    return nothing
end

# === Event ===

function max_notifiers!(builder::EventServiceBuilder, value::Integer)
    _require_valid(builder.handle, "event service builder")
    Iceoryx2FFI.iox2_service_builder_event_set_max_notifiers(
        Ref{Iceoryx2FFI.iox2_service_builder_event_h}(builder.handle),
        Iceoryx2FFI.c_size_t(value),
    )
    return builder
end

function max_listeners!(builder::EventServiceBuilder, value::Integer)
    _require_valid(builder.handle, "event service builder")
    Iceoryx2FFI.iox2_service_builder_event_set_max_listeners(
        Ref{Iceoryx2FFI.iox2_service_builder_event_h}(builder.handle),
        Iceoryx2FFI.c_size_t(value),
    )
    return builder
end

function event_id_max_value!(builder::EventServiceBuilder, value::Integer)
    _require_valid(builder.handle, "event service builder")
    Iceoryx2FFI.iox2_service_builder_event_set_event_id_max_value(
        Ref{Iceoryx2FFI.iox2_service_builder_event_h}(builder.handle),
        Iceoryx2FFI.c_size_t(value),
    )
    return builder
end

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
    factory.storage = nothing
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
    builder.storage = nothing
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

mutable struct ListenerBuilder
    handle::Iceoryx2FFI.iox2_port_factory_listener_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_listener_builder_t}
    keepalive::PortFactoryEvent
end

function _finalize_listener_builder(builder::ListenerBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
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
    notifier.storage = nothing
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
    listener.storage = nothing
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

function try_wait_all(listener::Listener, f::Function)
    return try_wait_all(f, listener)
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

function timed_wait_all(listener::Listener, seconds::Integer, nanoseconds::Integer, f::Function)
    return timed_wait_all(f, listener, seconds, nanoseconds)
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

function blocking_wait_all(listener::Listener, f::Function)
    return blocking_wait_all(f, listener)
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

# === Blackboard (minimal) ===

mutable struct PortFactoryBlackboard{K}
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
    factory.storage = nothing
    empty!(factory.values)
    return nothing
end

function create(builder::BlackboardCreatorBuilder)
    _require_valid(builder.handle, "blackboard creator")
    key_type = builder.key_type
    key_type === nothing && throw(ArgumentError("blackboard key type must be set with key_type!"))
    storage = Ref{Iceoryx2FFI.iox2_port_factory_blackboard_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_blackboard_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_blackboard_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_blackboard_create_error_e)
    builder.handle = _IOX2_NULL
    values = builder.values
    builder.values = Any[]
    _finalize_service_builder_variant(builder)
    factory = PortFactoryBlackboard{key_type}(handle_ref[], storage, builder.keepalive, values)
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
    key_type = builder.key_type
    key_type === nothing && throw(ArgumentError("blackboard key type must be set with key_type!"))
    storage = Ref{Iceoryx2FFI.iox2_port_factory_blackboard_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_blackboard_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_blackboard_open(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_blackboard_open_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    factory = PortFactoryBlackboard{key_type}(handle_ref[], storage, builder.keepalive, Any[])
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
    if builder.key_type === nothing
        builder.key_type = K
    elseif builder.key_type !== K
        throw(ArgumentError("blackboard key type already set to $(builder.key_type)"))
    end
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
    if builder.key_type === nothing
        builder.key_type = K
    elseif builder.key_type !== K
        throw(ArgumentError("blackboard key type already set to $(builder.key_type)"))
    end
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

function _blackboard_key_eq_cmp_1(a::Ptr{Cvoid}, b::Ptr{Cvoid})::Bool
    return unsafe_load(Ptr{NTuple{1, UInt8}}(a)) == unsafe_load(Ptr{NTuple{1, UInt8}}(b))
end

function _blackboard_key_eq_cmp_2(a::Ptr{Cvoid}, b::Ptr{Cvoid})::Bool
    return unsafe_load(Ptr{NTuple{2, UInt8}}(a)) == unsafe_load(Ptr{NTuple{2, UInt8}}(b))
end

function _blackboard_key_eq_cmp_4(a::Ptr{Cvoid}, b::Ptr{Cvoid})::Bool
    return unsafe_load(Ptr{NTuple{4, UInt8}}(a)) == unsafe_load(Ptr{NTuple{4, UInt8}}(b))
end

function _blackboard_key_eq_cmp_8(a::Ptr{Cvoid}, b::Ptr{Cvoid})::Bool
    return unsafe_load(Ptr{NTuple{8, UInt8}}(a)) == unsafe_load(Ptr{NTuple{8, UInt8}}(b))
end

function _blackboard_key_eq_cmp_16(a::Ptr{Cvoid}, b::Ptr{Cvoid})::Bool
    return unsafe_load(Ptr{NTuple{16, UInt8}}(a)) == unsafe_load(Ptr{NTuple{16, UInt8}}(b))
end

function _blackboard_key_eq_cmp_32(a::Ptr{Cvoid}, b::Ptr{Cvoid})::Bool
    return unsafe_load(Ptr{NTuple{32, UInt8}}(a)) == unsafe_load(Ptr{NTuple{32, UInt8}}(b))
end

function _blackboard_key_eq_cmp_64(a::Ptr{Cvoid}, b::Ptr{Cvoid})::Bool
    return unsafe_load(Ptr{NTuple{64, UInt8}}(a)) == unsafe_load(Ptr{NTuple{64, UInt8}}(b))
end

const _BLACKBOARD_KEY_EQ_CMP_1 = @cfunction(_blackboard_key_eq_cmp_1, Bool, (Ptr{Cvoid}, Ptr{Cvoid}))
const _BLACKBOARD_KEY_EQ_CMP_2 = @cfunction(_blackboard_key_eq_cmp_2, Bool, (Ptr{Cvoid}, Ptr{Cvoid}))
const _BLACKBOARD_KEY_EQ_CMP_4 = @cfunction(_blackboard_key_eq_cmp_4, Bool, (Ptr{Cvoid}, Ptr{Cvoid}))
const _BLACKBOARD_KEY_EQ_CMP_8 = @cfunction(_blackboard_key_eq_cmp_8, Bool, (Ptr{Cvoid}, Ptr{Cvoid}))
const _BLACKBOARD_KEY_EQ_CMP_16 = @cfunction(_blackboard_key_eq_cmp_16, Bool, (Ptr{Cvoid}, Ptr{Cvoid}))
const _BLACKBOARD_KEY_EQ_CMP_32 = @cfunction(_blackboard_key_eq_cmp_32, Bool, (Ptr{Cvoid}, Ptr{Cvoid}))
const _BLACKBOARD_KEY_EQ_CMP_64 = @cfunction(_blackboard_key_eq_cmp_64, Bool, (Ptr{Cvoid}, Ptr{Cvoid}))

@inline function _blackboard_key_eq_cmp_ptr(::Type{K}) where {K}
    size = sizeof(K)
    if size == 1
        return _BLACKBOARD_KEY_EQ_CMP_1
    elseif size == 2
        return _BLACKBOARD_KEY_EQ_CMP_2
    elseif size == 4
        return _BLACKBOARD_KEY_EQ_CMP_4
    elseif size == 8
        return _BLACKBOARD_KEY_EQ_CMP_8
    elseif size == 16
        return _BLACKBOARD_KEY_EQ_CMP_16
    elseif size == 32
        return _BLACKBOARD_KEY_EQ_CMP_32
    elseif size == 64
        return _BLACKBOARD_KEY_EQ_CMP_64
    end
    throw(ArgumentError("unsupported blackboard key size: $size bytes"))
end

"""
    key_eq_comparison!(builder::BlackboardCreatorBuilder, ::Type{K})

Configures a byte-wise key equality comparator for `K`. Keys should avoid padding and
uninitialized bytes to ensure deterministic equality.
"""
function key_eq_comparison!(builder::BlackboardCreatorBuilder, ::Type{K}) where {K}
    _require_valid(builder.handle, "blackboard creator")
    _require_isbits(K)
    return key_eq_comparison!(builder, _blackboard_key_eq_cmp_ptr(K))
end

function key_eq_comparison!(builder::BlackboardCreatorBuilder, cmp::Ptr{Cvoid})
    _require_valid(builder.handle, "blackboard creator")
    Iceoryx2FFI.iox2_service_builder_blackboard_creator_set_key_eq_comparison_function(
        Ref{Iceoryx2FFI.iox2_service_builder_blackboard_creator_h}(builder.handle),
        cmp,
    )
    return builder
end

function max_readers!(builder::BlackboardCreatorBuilder, value::Integer)
    _require_valid(builder.handle, "blackboard creator")
    Iceoryx2FFI.iox2_service_builder_blackboard_creator_set_max_readers(
        Ref{Iceoryx2FFI.iox2_service_builder_blackboard_creator_h}(builder.handle),
        Iceoryx2FFI.c_size_t(value),
    )
    return builder
end

function max_readers!(builder::BlackboardOpenerBuilder, value::Integer)
    _require_valid(builder.handle, "blackboard opener")
    Iceoryx2FFI.iox2_service_builder_blackboard_opener_set_max_readers(
        Ref{Iceoryx2FFI.iox2_service_builder_blackboard_opener_h}(builder.handle),
        Iceoryx2FFI.c_size_t(value),
    )
    return builder
end

function max_nodes!(builder::BlackboardCreatorBuilder, value::Integer)
    _require_valid(builder.handle, "blackboard creator")
    Iceoryx2FFI.iox2_service_builder_blackboard_creator_set_max_nodes(
        Ref{Iceoryx2FFI.iox2_service_builder_blackboard_creator_h}(builder.handle),
        Iceoryx2FFI.c_size_t(value),
    )
    return builder
end

function max_nodes!(builder::BlackboardOpenerBuilder, value::Integer)
    _require_valid(builder.handle, "blackboard opener")
    Iceoryx2FFI.iox2_service_builder_blackboard_opener_set_max_nodes(
        Ref{Iceoryx2FFI.iox2_service_builder_blackboard_opener_h}(builder.handle),
        Iceoryx2FFI.c_size_t(value),
    )
    return builder
end

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
            C_NULL,
            Base.unsafe_convert(Cstring, name),
            name_len,
            size,
            alignment,
        )
    end
    return builder
end

mutable struct WriterBuilder{K}
    handle::Iceoryx2FFI.iox2_port_factory_writer_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_writer_builder_t}
    keepalive::PortFactoryBlackboard{K}
end

function _finalize_writer_builder(builder::WriterBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

function writer_builder(factory::PortFactoryBlackboard{K}) where {K}
    _require_valid(factory.handle, "blackboard port factory")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_writer_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_blackboard_writer_builder(Ref{Iceoryx2FFI.iox2_port_factory_blackboard_h}(factory.handle), storage)
    builder = WriterBuilder{K}(handle, storage, factory)
    finalizer(_finalize_writer_builder, builder)
    return builder
end

mutable struct ReaderBuilder{K}
    handle::Iceoryx2FFI.iox2_port_factory_reader_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_reader_builder_t}
    keepalive::PortFactoryBlackboard{K}
end

function _finalize_reader_builder(builder::ReaderBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

function reader_builder(factory::PortFactoryBlackboard{K}) where {K}
    _require_valid(factory.handle, "blackboard port factory")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_reader_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_blackboard_reader_builder(Ref{Iceoryx2FFI.iox2_port_factory_blackboard_h}(factory.handle), storage)
    builder = ReaderBuilder{K}(handle, storage, factory)
    finalizer(_finalize_reader_builder, builder)
    return builder
end

mutable struct Writer{K}
    handle::Iceoryx2FFI.iox2_writer_h
    storage::_StorageRef{Iceoryx2FFI.iox2_writer_t}
    keepalive::PortFactoryBlackboard{K}
end

function _finalize_writer(writer::Writer)
    if writer.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_writer_drop(writer.handle)
        writer.handle = _IOX2_NULL
    end
    writer.storage = nothing
    return nothing
end

function create(builder::WriterBuilder{K}) where {K}
    _require_valid(builder.handle, "writer builder")
    storage = Ref{Iceoryx2FFI.iox2_writer_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_writer_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_writer_builder_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_writer_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_writer_builder(builder)
    writer = Writer{K}(handle_ref[], storage, builder.keepalive)
    finalizer(_finalize_writer, writer)
    return writer
end

function create(f::Function, builder::WriterBuilder{K}) where {K}
    writer = create(builder)
    try
        return f(writer)
    finally
        close(writer)
    end
end

mutable struct Reader{K}
    handle::Iceoryx2FFI.iox2_reader_h
    storage::_StorageRef{Iceoryx2FFI.iox2_reader_t}
    keepalive::PortFactoryBlackboard{K}
end

function _finalize_reader(reader::Reader)
    if reader.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_reader_drop(reader.handle)
        reader.handle = _IOX2_NULL
    end
    reader.storage = nothing
    return nothing
end

function create(builder::ReaderBuilder{K}) where {K}
    _require_valid(builder.handle, "reader builder")
    storage = Ref{Iceoryx2FFI.iox2_reader_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_reader_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_reader_builder_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_reader_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_reader_builder(builder)
    reader = Reader{K}(handle_ref[], storage, builder.keepalive)
    finalizer(_finalize_reader, reader)
    return reader
end

function create(f::Function, builder::ReaderBuilder{K}) where {K}
    reader = create(builder)
    try
        return f(reader)
    finally
        close(reader)
    end
end

mutable struct EntryHandle{K,V}
    handle::Iceoryx2FFI.iox2_entry_handle_h
    storage::_StorageRef{Iceoryx2FFI.iox2_entry_handle_t}
    keepalive::Reader{K}
end

function _finalize_entry_handle(entry::EntryHandle)
    if entry.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_entry_handle_drop(entry.handle)
        entry.handle = _IOX2_NULL
    end
    entry.storage = nothing
    return nothing
end

mutable struct EntryHandleMut{K,V}
    handle::Iceoryx2FFI.iox2_entry_handle_mut_h
    storage::_StorageRef{Iceoryx2FFI.iox2_entry_handle_mut_t}
    keepalive::Writer{K}
end

function _finalize_entry_handle_mut(entry::EntryHandleMut)
    if entry.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_entry_handle_mut_drop(entry.handle)
        entry.handle = _IOX2_NULL
    end
    entry.storage = nothing
    return nothing
end

mutable struct EntryValueUninit{K,V}
    handle::Iceoryx2FFI.iox2_entry_value_uninit_h
    storage::_StorageRef{Iceoryx2FFI.iox2_entry_value_uninit_t}
    keepalive::Writer{K}
end

function _finalize_entry_value_uninit(value::EntryValueUninit)
    if value.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_entry_value_uninit_drop(value.handle)
        value.handle = _IOX2_NULL
    end
    value.storage = nothing
    return nothing
end

function loan_uninit(entry::EntryHandleMut{K,V}) where {K,V}
    _require_valid(entry.handle, "entry handle mut")
    storage = Ref{Iceoryx2FFI.iox2_entry_value_uninit_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_entry_value_uninit_h}(_IOX2_NULL)
    size = Iceoryx2FFI.c_size_t(sizeof(V))
    alignment = Iceoryx2FFI.c_size_t(Base.datatype_alignment(V))
    Iceoryx2FFI.iox2_entry_handle_mut_loan_uninit(entry.handle, storage, handle_ref, size, alignment)
    entry.handle = _IOX2_NULL
    entry.storage = nothing
    value = EntryValueUninit{K,V}(handle_ref[], storage, entry.keepalive)
    finalizer(_finalize_entry_value_uninit, value)
    return value
end

function loan_uninit(f::Function, entry::EntryHandleMut{K,V}) where {K,V}
    value = loan_uninit(entry)
    try
        return f(value)
    finally
        isvalid(value) && close(value)
    end
end

function loan_uninit(entry::EntryHandleMut{K,V}, f::Function) where {K,V}
    return loan_uninit(f, entry)
end

@inline function value_mut(value::EntryValueUninit{K,V}) where {K,V}
    ptr_ref = Ref{Ptr{Cvoid}}()
    Iceoryx2FFI.iox2_entry_value_uninit_value_mut(
        Ref{Iceoryx2FFI.iox2_entry_value_uninit_h}(value.handle),
        ptr_ref,
    )
    return Ptr{V}(ptr_ref[])
end

function update!(value::EntryValueUninit{K,V}) where {K,V}
    storage = Ref{Iceoryx2FFI.iox2_entry_handle_mut_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_entry_handle_mut_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_entry_value_uninit_update(value.handle, storage, handle_ref)
    value.handle = _IOX2_NULL
    value.storage = nothing
    entry = EntryHandleMut{K,V}(handle_ref[], storage, value.keepalive)
    finalizer(_finalize_entry_handle_mut, entry)
    return entry
end

function discard!(value::EntryValueUninit{K,V}) where {K,V}
    storage = Ref{Iceoryx2FFI.iox2_entry_handle_mut_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_entry_handle_mut_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_entry_value_uninit_discard(value.handle, storage, handle_ref)
    value.handle = _IOX2_NULL
    value.storage = nothing
    entry = EntryHandleMut{K,V}(handle_ref[], storage, value.keepalive)
    finalizer(_finalize_entry_handle_mut, entry)
    return entry
end

function reader_entry(reader::Reader{K}, key::K, ::Type{V}) where {K,V}
    _require_valid(reader.handle, "reader")
    _require_isbits(K)
    _require_isbits(V)
    key_ref = Ref{K}(key)
    storage = Ref{Iceoryx2FFI.iox2_entry_handle_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_entry_handle_h}(_IOX2_NULL)
    name, name_len, size, alignment = _type_details(V)
    GC.@preserve key_ref name begin
        ret = Iceoryx2FFI.iox2_reader_entry(
            Ref{Iceoryx2FFI.iox2_reader_h}(reader.handle),
            storage,
            handle_ref,
            Base.unsafe_convert(Ptr{Cvoid}, key_ref),
            Base.unsafe_convert(Cstring, name),
            name_len,
            size,
            alignment,
        )
        check_ok(ret, Iceoryx2FFI.iox2_entry_handle_error_e)
    end
    entry = EntryHandle{K,V}(handle_ref[], storage, reader)
    finalizer(_finalize_entry_handle, entry)
    return entry
end

function reader_entry(f::Function, reader::Reader{K}, key::K, ::Type{V}) where {K,V}
    entry = reader_entry(reader, key, V)
    try
        return f(entry)
    finally
        close(entry)
    end
end

function reader_entry(reader::Reader{K}, key::K, ::Type{V}, f::Function) where {K,V}
    return reader_entry(f, reader, key, V)
end

function try_reader_entry(reader::Reader{K}, key::K, ::Type{V}) where {K,V}
    _require_valid(reader.handle, "reader")
    _require_isbits(K)
    _require_isbits(V)
    key_ref = Ref{K}(key)
    storage = Ref{Iceoryx2FFI.iox2_entry_handle_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_entry_handle_h}(_IOX2_NULL)
    name, name_len, size, alignment = _type_details(V)
    GC.@preserve key_ref name begin
        ret = Iceoryx2FFI.iox2_reader_entry(
            Ref{Iceoryx2FFI.iox2_reader_h}(reader.handle),
            storage,
            handle_ref,
            Base.unsafe_convert(Ptr{Cvoid}, key_ref),
            Base.unsafe_convert(Cstring, name),
            name_len,
            size,
            alignment,
        )
        err = Iceoryx2FFI.iox2_entry_handle_error_e(ret)
        if err == Iceoryx2FFI.iox2_entry_handle_error_e_ENTRY_DOES_NOT_EXIST
            return nothing
        end
        check_ok(ret, Iceoryx2FFI.iox2_entry_handle_error_e)
    end
    entry = EntryHandle{K,V}(handle_ref[], storage, reader)
    finalizer(_finalize_entry_handle, entry)
    return entry
end

function try_reader_entry(f::Function, reader::Reader{K}, key::K, ::Type{V}) where {K,V}
    entry = try_reader_entry(reader, key, V)
    entry === nothing && return nothing
    try
        return f(entry)
    finally
        close(entry)
    end
end

function try_reader_entry(reader::Reader{K}, key::K, ::Type{V}, f::Function) where {K,V}
    return try_reader_entry(f, reader, key, V)
end

function writer_entry(writer::Writer{K}, key::K, ::Type{V}) where {K,V}
    _require_valid(writer.handle, "writer")
    _require_isbits(K)
    _require_isbits(V)
    key_ref = Ref{K}(key)
    storage = Ref{Iceoryx2FFI.iox2_entry_handle_mut_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_entry_handle_mut_h}(_IOX2_NULL)
    name, name_len, size, alignment = _type_details(V)
    GC.@preserve key_ref name begin
        ret = Iceoryx2FFI.iox2_writer_entry(
            Ref{Iceoryx2FFI.iox2_writer_h}(writer.handle),
            storage,
            handle_ref,
            Base.unsafe_convert(Ptr{Cvoid}, key_ref),
            Base.unsafe_convert(Cstring, name),
            name_len,
            size,
            alignment,
        )
        check_ok(ret, Iceoryx2FFI.iox2_entry_handle_mut_error_e)
    end
    entry = EntryHandleMut{K,V}(handle_ref[], storage, writer)
    finalizer(_finalize_entry_handle_mut, entry)
    return entry
end

function writer_entry(f::Function, writer::Writer{K}, key::K, ::Type{V}) where {K,V}
    entry = writer_entry(writer, key, V)
    try
        return f(entry)
    finally
        close(entry)
    end
end

function writer_entry(writer::Writer{K}, key::K, ::Type{V}, f::Function) where {K,V}
    return writer_entry(f, writer, key, V)
end

function try_writer_entry(writer::Writer{K}, key::K, ::Type{V}) where {K,V}
    _require_valid(writer.handle, "writer")
    _require_isbits(K)
    _require_isbits(V)
    key_ref = Ref{K}(key)
    storage = Ref{Iceoryx2FFI.iox2_entry_handle_mut_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_entry_handle_mut_h}(_IOX2_NULL)
    name, name_len, size, alignment = _type_details(V)
    GC.@preserve key_ref name begin
        ret = Iceoryx2FFI.iox2_writer_entry(
            Ref{Iceoryx2FFI.iox2_writer_h}(writer.handle),
            storage,
            handle_ref,
            Base.unsafe_convert(Ptr{Cvoid}, key_ref),
            Base.unsafe_convert(Cstring, name),
            name_len,
            size,
            alignment,
        )
        err = Iceoryx2FFI.iox2_entry_handle_mut_error_e(ret)
        if err == Iceoryx2FFI.iox2_entry_handle_mut_error_e_ENTRY_DOES_NOT_EXIST
            return nothing
        end
        check_ok(ret, Iceoryx2FFI.iox2_entry_handle_mut_error_e)
    end
    entry = EntryHandleMut{K,V}(handle_ref[], storage, writer)
    finalizer(_finalize_entry_handle_mut, entry)
    return entry
end

function try_writer_entry(f::Function, writer::Writer{K}, key::K, ::Type{V}) where {K,V}
    entry = try_writer_entry(writer, key, V)
    entry === nothing && return nothing
    try
        return f(entry)
    finally
        close(entry)
    end
end

function try_writer_entry(writer::Writer{K}, key::K, ::Type{V}, f::Function) where {K,V}
    return try_writer_entry(f, writer, key, V)
end

@inline function entry_id(entry::EntryHandle)
    id_ref = Ref{Iceoryx2FFI.iox2_event_id_t}()
    Iceoryx2FFI.iox2_entry_handle_entry_id(Ref{Iceoryx2FFI.iox2_entry_handle_h}(entry.handle), id_ref)
    return EventId(id_ref[])
end

@inline function entry_id(entry::EntryHandleMut)
    id_ref = Ref{Iceoryx2FFI.iox2_event_id_t}()
    Iceoryx2FFI.iox2_entry_handle_mut_entry_id(Ref{Iceoryx2FFI.iox2_entry_handle_mut_h}(entry.handle), id_ref)
    return EventId(id_ref[])
end

function get!(entry::EntryHandle{K,V}, value_ref::Base.RefValue{V}, generation_ref::Base.RefValue{UInt64}) where {K,V}
    size = Iceoryx2FFI.c_size_t(sizeof(V))
    alignment = Iceoryx2FFI.c_size_t(Base.datatype_alignment(V))
    GC.@preserve value_ref generation_ref begin
        Iceoryx2FFI.iox2_entry_handle_get(
            Ref{Iceoryx2FFI.iox2_entry_handle_h}(entry.handle),
            Base.unsafe_convert(Ptr{Cvoid}, value_ref),
            size,
            alignment,
            Base.unsafe_convert(Ptr{Cvoid}, generation_ref),
        )
    end
    return nothing
end

function get!(entry::EntryHandle{K,V}, value_ref::Base.RefValue{V}) where {K,V}
    generation_ref = Ref{UInt64}(0)
    get!(entry, value_ref, generation_ref)
    return generation_ref[]
end

function get(entry::EntryHandle{K,V}) where {K,V}
    value_ref = Ref{V}()
    generation_ref = Ref{UInt64}(0)
    get!(entry, value_ref, generation_ref)
    return value_ref[], generation_ref[]
end

@inline function is_up_to_date(entry::EntryHandle, generation_counter::UInt64)
    return Iceoryx2FFI.iox2_entry_handle_is_up_to_date(
        Ref{Iceoryx2FFI.iox2_entry_handle_h}(entry.handle),
        generation_counter,
    )
end

function update!(entry::EntryHandleMut{K,V}, value_ref::Base.RefValue{V}) where {K,V}
    size = Iceoryx2FFI.c_size_t(sizeof(V))
    alignment = Iceoryx2FFI.c_size_t(Base.datatype_alignment(V))
    GC.@preserve value_ref begin
        Iceoryx2FFI.iox2_entry_handle_mut_update_with_copy(
            Ref{Iceoryx2FFI.iox2_entry_handle_mut_h}(entry.handle),
            Base.unsafe_convert(Ptr{Cvoid}, value_ref),
            size,
            alignment,
        )
    end
    return nothing
end

function update!(entry::EntryHandleMut{K,V}, value::V) where {K,V}
    value_ref = Ref{V}(value)
    update!(entry, value_ref)
    return nothing
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
@inline Base.isvalid(obj::EntryHandle) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::EntryHandleMut) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::EntryValueUninit) = obj.handle != _IOX2_NULL

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

function Base.close(obj::EntryHandle)
    _finalize_entry_handle(obj)
    return nothing
end

function Base.close(obj::EntryHandleMut)
    _finalize_entry_handle_mut(obj)
    return nothing
end

function Base.close(obj::EntryValueUninit)
    _finalize_entry_value_uninit(obj)
    return nothing
end
