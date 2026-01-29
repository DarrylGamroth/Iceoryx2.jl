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

@inline _allocation_strategy(value::Iceoryx2FFI.iox2_allocation_strategy_e) = value

@inline function _allocation_strategy(value::Symbol)
    if value === :best_fit
        return Iceoryx2FFI.iox2_allocation_strategy_e_BEST_FIT
    elseif value === :power_of_two
        return Iceoryx2FFI.iox2_allocation_strategy_e_POWER_OF_TWO
    elseif value === :static
        return Iceoryx2FFI.iox2_allocation_strategy_e_STATIC
    end
    throw(ArgumentError("unsupported allocation_strategy: $value"))
end

@inline _allocation_strategy(value) = throw(ArgumentError("unsupported allocation_strategy: $value"))

type_name(::Type{UInt8}) = "u8"
type_name(::Type{UInt16}) = "u16"
type_name(::Type{UInt32}) = "u32"
type_name(::Type{UInt64}) = "u64"
type_name(::Type{Int8}) = "i8"
type_name(::Type{Int16}) = "i16"
type_name(::Type{Int32}) = "i32"
type_name(::Type{Int64}) = "i64"
type_name(::Type{Float32}) = "f32"
type_name(::Type{Float64}) = "f64"
type_name(::Type{Nothing}) = "()"

function type_name(::Type{T}) where {T}
    return string(T)
end

@inline function _type_details(::Type{T}) where {T}
    name = type_name(T)
    return name,
        Iceoryx2FFI.c_size_t(ncodeunits(name)),
        Iceoryx2FFI.c_size_t(sizeof(T)),
        Iceoryx2FFI.c_size_t(Base.datatype_alignment(T))
end

struct Slice{T,O} <: AbstractVector{T}
    ptr::Ptr{T}
    len::Int
    owner::O
end

Slice{T}(ptr::Ptr{T}, len::Integer) where {T} = Slice{T,Nothing}(ptr, Int(len), nothing)
Slice{T}(ptr::Ptr{T}, len::Integer, owner) where {T} = Slice{T,typeof(owner)}(ptr, Int(len), owner)

Base.length(slice::Slice) = slice.len
Base.size(slice::Slice) = (slice.len,)
Base.axes(slice::Slice) = (Base.OneTo(slice.len),)
Base.eltype(::Type{Slice{T}}) where {T} = T
Base.elsize(::Type{Slice{T}}) where {T} = sizeof(T)
Base.IndexStyle(::Type{<:Slice}) = IndexLinear()
Base.firstindex(::Slice) = 1
Base.lastindex(slice::Slice) = slice.len
Base.unsafe_convert(::Type{Ptr{T}}, slice::Slice{T}) where {T} = slice.ptr
Base.iscontiguous(::Slice) = true
Base.iscontiguous(::Type{<:Slice}) = true
Base.pointer(slice::Slice{T}) where {T} = slice.ptr
Base.strides(::Slice) = (1,)
Base.similar(slice::Slice{T}) where {T} = Vector{T}(undef, slice.len)

@inline function Base.getindex(slice::Slice{T}, i::Int) where {T}
    @boundscheck (i >= 1 && i <= slice.len) || throw(BoundsError(slice, i))
    return unsafe_load(slice.ptr, i)
end

@inline function _require_inactive(handle_ref::Base.RefValue, what::AbstractString)
    handle_ref[] == _IOX2_NULL || throw(ArgumentError("$what is still active; call close first"))
    return nothing
end

@inline function _require_inactive(obj, what::AbstractString)
    return _require_inactive(obj.handle_ref, what)
end

@inline _slice_mutable(::Type{O}) where {O} = O === Nothing

@inline function Base.setindex!(slice::Slice{T,O}, value::T, i::Int) where {T,O}
    _slice_mutable(O) || throw(ArgumentError("slice is read-only"))
    @boundscheck (i >= 1 && i <= slice.len) || throw(BoundsError(slice, i))
    unsafe_store!(slice.ptr, value, i)
    return value
end

@inline function Base.iterate(slice::Slice{T}, state::Int = 1) where {T}
    state > slice.len && return nothing
    return unsafe_load(slice.ptr, state), state + 1
end

@inline function Base.fill!(slice::Slice{T}, value::T) where {T}
    @inbounds for idx in 1:slice.len
        unsafe_store!(slice.ptr, value, idx)
    end
    return slice
end

function Base.copyto!(dest::AbstractVector{T}, src::Slice{T}) where {T}
    length(dest) == src.len || throw(DimensionMismatch("destination has length $(length(dest)), expected $(src.len)"))
    @inbounds for i in 1:src.len
        dest[i] = unsafe_load(src.ptr, i)
    end
    return dest
end

function Base.copyto!(dest::Slice{T}, src::AbstractVector{T}) where {T}
    length(src) == dest.len || throw(DimensionMismatch("source has length $(length(src)), expected $(dest.len)"))
    @inbounds for i in 1:dest.len
        unsafe_store!(dest.ptr, src[i], i)
    end
    return dest
end

@inline function _default_value(::Type{T}) where {T}
    Base.hasmethod(zero, Tuple{Type{T}}) || throw(ArgumentError("loan!/loan_slice! requires zero(::Type{$T})"))
    return zero(T)
end

struct EventId
    raw::Iceoryx2FFI.iox2_event_id_t
end

EventId(value::Integer) = EventId(Iceoryx2FFI.iox2_event_id_t(Iceoryx2FFI.c_size_t(value)))

@inline value(id::EventId) = id.raw.value
@inline Base.Int(id::EventId) = Int(id.raw.value)

# === Publish/Subscribe ===

function _set_payload_type!(builder::PubSubServiceBuilder{T}, ::Type{T}; variant::Union{Symbol,Iceoryx2FFI.iox2_type_variant_e}=:fixed) where {T}
    _require_valid(builder.handle, "publish_subscribe service builder")
    _require_isbits(T)
    name, name_len, size, alignment = _type_details(T)
    v = _type_variant(variant)
    GC.@preserve name begin
        ret = Iceoryx2FFI.iox2_service_builder_pub_sub_set_payload_type_details(Ref{Iceoryx2FFI.iox2_service_builder_pub_sub_h}(builder.handle), v, Base.unsafe_convert(Cstring, name), name_len, size, alignment)
        check_ok(ret, Iceoryx2FFI.iox2_type_detail_error_e)
    end
    return builder
end

function _set_payload_type!(builder::PubSubServiceBuilder{T}, ::Type{Other}; variant::Union{Symbol,Iceoryx2FFI.iox2_type_variant_e}=:fixed) where {T,Other}
    throw(ArgumentError("publish_subscribe payload type already set to $T"))
end

function payload_alignment!(builder::PubSubServiceBuilder, alignment::Integer)
    alignment > 0 || throw(ArgumentError("payload alignment must be positive, got $alignment"))
    Iceoryx2FFI.iox2_service_builder_pub_sub_set_payload_alignment(
        Ref{Iceoryx2FFI.iox2_service_builder_pub_sub_h}(builder.handle),
        Iceoryx2FFI.c_size_t(alignment),
    )
    return builder
end

function user_header(builder::PubSubServiceBuilder{T,Nothing}, ::Type{UH}; variant::Union{Symbol,Iceoryx2FFI.iox2_type_variant_e}=:fixed) where {T,UH}
    _require_valid(builder.handle, "publish_subscribe service builder")
    _require_isbits(UH)
    name, name_len, size, alignment = _type_details(UH)
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
    handle = builder.handle
    storage = builder.storage
    builder.handle = _IOX2_NULL
    builder.storage = Ref{Iceoryx2FFI.iox2_service_builder_t}()
    return PubSubServiceBuilder{T,UH}(handle, storage, builder.keepalive)
end

function user_header(builder::PubSubServiceBuilder{T,UH}, ::Type{UH}; variant::Union{Symbol,Iceoryx2FFI.iox2_type_variant_e}=:fixed) where {T,UH}
    _require_valid(builder.handle, "publish_subscribe service builder")
    return builder
end

function user_header(builder::PubSubServiceBuilder{T,UH}, ::Type{Other}; variant::Union{Symbol,Iceoryx2FFI.iox2_type_variant_e}=:fixed) where {T,UH,Other}
    _require_valid(builder.handle, "publish_subscribe service builder")
    throw(ArgumentError("publish_subscribe user header type already set to $UH"))
end

### builder tuning setters generated in src/generated/wrappers.jl

mutable struct PortFactoryPubSub{T,UH}
    handle::Iceoryx2FFI.iox2_port_factory_pub_sub_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_pub_sub_t}
    keepalive::Node
    function PortFactoryPubSub{T,UH}(handle, storage, keepalive) where {T,UH}
        obj = new{T,UH}(handle, storage, keepalive)
        finalizer(_finalize_port_factory_pub_sub, obj)
        return obj
    end
end

function _finalize_port_factory_pub_sub(factory::PortFactoryPubSub)
    if factory.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_port_factory_pub_sub_drop(factory.handle)
        factory.handle = _IOX2_NULL
    end
    factory.storage = nothing
    return nothing
end

function open_or_create(builder::PubSubServiceBuilder{T,UH}) where {T,UH}
    _require_valid(builder.handle, "publish_subscribe service builder")
    _require_isbits(T)
    storage = Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_pub_sub_open_or_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_pub_sub_open_or_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    return PortFactoryPubSub{T,UH}(handle_ref[], storage, builder.keepalive)
end

function open_or_create(builder::PubSubServiceBuilder{T,UH}, verifier::AttributeVerifier) where {T,UH}
    _require_valid(builder.handle, "publish_subscribe service builder")
    _require_isbits(T)
    _require_valid(unsafe_handle(verifier), "attribute verifier")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_pub_sub_open_or_create_with_attributes(
        builder.handle,
        Ref{Iceoryx2FFI.iox2_attribute_verifier_h}(unsafe_handle(verifier)),
        storage,
        handle_ref,
    )
    check_ok(ret, Iceoryx2FFI.iox2_pub_sub_open_or_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    return PortFactoryPubSub{T,UH}(handle_ref[], storage, builder.keepalive)
end

function open(builder::PubSubServiceBuilder{T,UH}) where {T,UH}
    _require_valid(builder.handle, "publish_subscribe service builder")
    _require_isbits(T)
    storage = Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_pub_sub_open(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_pub_sub_open_or_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    return PortFactoryPubSub{T,UH}(handle_ref[], storage, builder.keepalive)
end

function open(builder::PubSubServiceBuilder{T,UH}, verifier::AttributeVerifier) where {T,UH}
    _require_valid(builder.handle, "publish_subscribe service builder")
    _require_isbits(T)
    _require_valid(unsafe_handle(verifier), "attribute verifier")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_pub_sub_open_with_attributes(
        builder.handle,
        Ref{Iceoryx2FFI.iox2_attribute_verifier_h}(unsafe_handle(verifier)),
        storage,
        handle_ref,
    )
    check_ok(ret, Iceoryx2FFI.iox2_pub_sub_open_or_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    return PortFactoryPubSub{T,UH}(handle_ref[], storage, builder.keepalive)
end

function create(builder::PubSubServiceBuilder{T,UH}) where {T,UH}
    _require_valid(builder.handle, "publish_subscribe service builder")
    _require_isbits(T)
    storage = Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_pub_sub_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_pub_sub_open_or_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    return PortFactoryPubSub{T,UH}(handle_ref[], storage, builder.keepalive)
end

function create(builder::PubSubServiceBuilder{T,UH}, specifier::AttributeSpecifier) where {T,UH}
    _require_valid(builder.handle, "publish_subscribe service builder")
    _require_isbits(T)
    _require_valid(unsafe_handle(specifier), "attribute specifier")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_pub_sub_create_with_attributes(
        builder.handle,
        Ref{Iceoryx2FFI.iox2_attribute_specifier_h}(unsafe_handle(specifier)),
        storage,
        handle_ref,
    )
    check_ok(ret, Iceoryx2FFI.iox2_pub_sub_open_or_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    return PortFactoryPubSub{T,UH}(handle_ref[], storage, builder.keepalive)
end

function open_or_create(f::Function, builder::PubSubServiceBuilder)
    factory = open_or_create(builder)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function open_or_create(f::Function, builder::PubSubServiceBuilder, verifier::AttributeVerifier)
    factory = open_or_create(builder, verifier)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function open(f::Function, builder::PubSubServiceBuilder)
    factory = open(builder)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function open(f::Function, builder::PubSubServiceBuilder, verifier::AttributeVerifier)
    factory = open(builder, verifier)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function create(f::Function, builder::PubSubServiceBuilder)
    factory = create(builder)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function create(f::Function, builder::PubSubServiceBuilder, specifier::AttributeSpecifier)
    factory = create(builder, specifier)
    try
        return f(factory)
    finally
        close(factory)
    end
end

open_or_create_with_attributes(builder::PubSubServiceBuilder, verifier::AttributeVerifier) = open_or_create(builder, verifier)
open_or_create_with_attributes(f::Function, builder::PubSubServiceBuilder, verifier::AttributeVerifier) = open_or_create(f, builder, verifier)
open_with_attributes(builder::PubSubServiceBuilder, verifier::AttributeVerifier) = open(builder, verifier)
open_with_attributes(f::Function, builder::PubSubServiceBuilder, verifier::AttributeVerifier) = open(f, builder, verifier)
create_with_attributes(builder::PubSubServiceBuilder, specifier::AttributeSpecifier) = create(builder, specifier)
create_with_attributes(f::Function, builder::PubSubServiceBuilder, specifier::AttributeSpecifier) = create(f, builder, specifier)

mutable struct PublisherBuilder{T,UH}
    handle::Iceoryx2FFI.iox2_port_factory_publisher_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_publisher_builder_t}
    keepalive::PortFactoryPubSub{T,UH}
    function PublisherBuilder{T,UH}(handle, storage, keepalive) where {T,UH}
        obj = new{T,UH}(handle, storage, keepalive)
        finalizer(_finalize_publisher_builder, obj)
        return obj
    end
end

function _finalize_publisher_builder(builder::PublisherBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

function publisher_builder(factory::PortFactoryPubSub{T,UH}) where {T,UH}
    _require_valid(factory.handle, "publish_subscribe port factory")
    _require_isbits(T)
    storage = Ref{Iceoryx2FFI.iox2_port_factory_publisher_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_pub_sub_publisher_builder(Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_h}(factory.handle), storage)
    return PublisherBuilder{T,UH}(handle, storage, factory)
end

### builder tuning setters generated in src/generated/wrappers.jl

function allocation_strategy!(builder::PublisherBuilder, value::Union{Symbol,Iceoryx2FFI.iox2_allocation_strategy_e})
    _require_valid(builder.handle, "publisher builder")
    Iceoryx2FFI.iox2_port_factory_publisher_builder_set_allocation_strategy(
        Ref{Iceoryx2FFI.iox2_port_factory_publisher_builder_h}(builder.handle),
        _allocation_strategy(value),
    )
    return builder
end

mutable struct SubscriberBuilder{T,UH}
    handle::Iceoryx2FFI.iox2_port_factory_subscriber_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_subscriber_builder_t}
    keepalive::PortFactoryPubSub{T,UH}
    function SubscriberBuilder{T,UH}(handle, storage, keepalive) where {T,UH}
        obj = new{T,UH}(handle, storage, keepalive)
        finalizer(_finalize_subscriber_builder, obj)
        return obj
    end
end

function _finalize_subscriber_builder(builder::SubscriberBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

function subscriber_builder(factory::PortFactoryPubSub{T,UH}) where {T,UH}
    _require_valid(factory.handle, "publish_subscribe port factory")
    _require_isbits(T)
    storage = Ref{Iceoryx2FFI.iox2_port_factory_subscriber_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_pub_sub_subscriber_builder(Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_h}(factory.handle), storage)
    return SubscriberBuilder{T,UH}(handle, storage, factory)
end

mutable struct Publisher{T,UH}
    handle::Iceoryx2FFI.iox2_publisher_h
    storage::_StorageRef{Iceoryx2FFI.iox2_publisher_t}
    keepalive::PortFactoryPubSub{T,UH}
    function Publisher{T,UH}(handle, storage, keepalive) where {T,UH}
        obj = new{T,UH}(handle, storage, keepalive)
        finalizer(_finalize_publisher, obj)
        return obj
    end
end

function _finalize_publisher(pub::Publisher)
    if pub.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_publisher_drop(pub.handle)
        pub.handle = _IOX2_NULL
    end
    pub.storage = nothing
    return nothing
end

function create(builder::PublisherBuilder{T,UH}) where {T,UH}
    _require_valid(builder.handle, "publisher builder")
    storage = Ref{Iceoryx2FFI.iox2_publisher_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_publisher_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_publisher_builder_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_publisher_create_error_e)
    _finalize_publisher_builder(builder)
    return Publisher{T,UH}(handle_ref[], storage, builder.keepalive)
end

function create(f::Function, builder::PublisherBuilder{T,UH}) where {T,UH}
    pub = create(builder)
    try
        return f(pub)
    finally
        close(pub)
    end
end

mutable struct Subscriber{T,UH}
    handle::Iceoryx2FFI.iox2_subscriber_h
    storage::_StorageRef{Iceoryx2FFI.iox2_subscriber_t}
    keepalive::PortFactoryPubSub{T,UH}
    function Subscriber{T,UH}(handle, storage, keepalive) where {T,UH}
        obj = new{T,UH}(handle, storage, keepalive)
        finalizer(_finalize_subscriber, obj)
        return obj
    end
end

function _finalize_subscriber(sub::Subscriber)
    if sub.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_subscriber_drop(sub.handle)
        sub.handle = _IOX2_NULL
    end
    sub.storage = nothing
    return nothing
end

function create(builder::SubscriberBuilder{T,UH}) where {T,UH}
    _require_valid(builder.handle, "subscriber builder")
    storage = Ref{Iceoryx2FFI.iox2_subscriber_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_subscriber_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_subscriber_builder_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_subscriber_create_error_e)
    _finalize_subscriber_builder(builder)
    return Subscriber{T,UH}(handle_ref[], storage, builder.keepalive)
end

function create(f::Function, builder::SubscriberBuilder{T,UH}) where {T,UH}
    sub = create(builder)
    try
        return f(sub)
    finally
        close(sub)
    end
end

mutable struct Sample{T,UH}
    handle_ref::Base.RefValue{Iceoryx2FFI.iox2_sample_h}
    storage::Base.RefValue{Iceoryx2FFI.iox2_sample_t}
    function Sample{T,UH}(handle_ref, storage) where {T,UH}
        obj = new{T,UH}(handle_ref, storage)
        finalizer(_finalize_sample, obj)
        return obj
    end
end

function Sample{T,UH}() where {T,UH}
    return Sample{T,UH}(Ref{Iceoryx2FFI.iox2_sample_h}(_IOX2_NULL), Ref{Iceoryx2FFI.iox2_sample_t}())
end

Sample(subscriber::Subscriber{T,UH}) where {T,UH} = Sample{T,UH}()

function _finalize_sample(sample::Sample)
    if sample.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_sample_drop(sample.handle_ref[])
        sample.handle_ref[] = _IOX2_NULL
    end
    return nothing
end

@inline function payload(sample::Sample{T,UH}) where {T,UH}
    ptr_ref = Ref{Ptr{Cvoid}}()
    len_ref = Ref{Iceoryx2FFI.c_size_t}()
    Iceoryx2FFI.iox2_sample_payload(sample.handle_ref, ptr_ref, len_ref)
    return Slice{T}(Ptr{T}(ptr_ref[]), Int(len_ref[]), sample)
end

@inline function unsafe_payload_ptr(sample::Sample{T,UH}) where {T,UH}
    return payload(sample).ptr
end

@inline function header(sample::Sample)
    _require_valid(sample.handle_ref[], "sample")
    handle_ref = Ref{Iceoryx2FFI.iox2_publish_subscribe_header_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_sample_header(sample.handle_ref, C_NULL, handle_ref)
    handle_ref[] != _IOX2_NULL || throw(ErrorException("failed to acquire sample header"))
    return PublishSubscribeHeader(handle_ref[])
end

@inline function unsafe_user_header_ptr(sample::Sample, ::Type{T}) where {T}
    _require_isbits(T)
    ptr_ref = Ref{Ptr{Cvoid}}()
    Iceoryx2FFI.iox2_sample_user_header(sample.handle_ref, ptr_ref)
    return Ptr{T}(ptr_ref[])
end

@inline function user_header(sample::Sample{T,Nothing}) where {T}
    throw(ArgumentError("sample has no user header type; call user_header(sample, ::Type) instead"))
end

@inline function user_header(sample::Sample{T,UH}) where {T,UH}
    ptr = unsafe_user_header_ptr(sample, UH)
    return Slice{UH}(ptr, 1, sample)
end

@inline function user_header(sample::Sample{T,UH}, ::Type{UH}) where {T,UH}
    ptr = unsafe_user_header_ptr(sample, UH)
    return Slice{UH}(ptr, 1, sample)
end


mutable struct SampleMut{T,UH}
    handle_ref::Base.RefValue{Iceoryx2FFI.iox2_sample_mut_h}
    storage::Base.RefValue{Iceoryx2FFI.iox2_sample_mut_t}
    function SampleMut{T,UH}(handle_ref, storage) where {T,UH}
        obj = new{T,UH}(handle_ref, storage)
        finalizer(_finalize_sample_mut, obj)
        return obj
    end
end

function SampleMut{T,UH}() where {T,UH}
    return SampleMut{T,UH}(Ref{Iceoryx2FFI.iox2_sample_mut_h}(_IOX2_NULL), Ref{Iceoryx2FFI.iox2_sample_mut_t}())
end

SampleMut(publisher::Publisher{T,UH}) where {T,UH} = SampleMut{T,UH}()

@inline _slice_mutable(::Type{<:SampleMut}) = true

function _finalize_sample_mut(sample::SampleMut)
    if sample.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_sample_mut_drop(sample.handle_ref[])
        sample.handle_ref[] = _IOX2_NULL
    end
    return nothing
end

@inline function payload_mut(sample::SampleMut{T,UH}) where {T,UH}
    ptr_ref = Ref{Ptr{Cvoid}}()
    len_ref = Ref{Iceoryx2FFI.c_size_t}()
    Iceoryx2FFI.iox2_sample_mut_payload_mut(sample.handle_ref, ptr_ref, len_ref)
    return Slice{T}(Ptr{T}(ptr_ref[]), Int(len_ref[]), sample)
end

@inline function unsafe_payload_mut_ptr(sample::SampleMut{T,UH}) where {T,UH}
    return payload_mut(sample).ptr
end

@inline function header(sample::SampleMut)
    _require_valid(sample.handle_ref[], "sample")
    handle_ref = Ref{Iceoryx2FFI.iox2_publish_subscribe_header_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_sample_mut_header(sample.handle_ref, C_NULL, handle_ref)
    handle_ref[] != _IOX2_NULL || throw(ErrorException("failed to acquire sample header"))
    return PublishSubscribeHeader(handle_ref[])
end

@inline function unsafe_user_header_mut_ptr(sample::SampleMut, ::Type{T}) where {T}
    _require_isbits(T)
    ptr_ref = Ref{Ptr{Cvoid}}()
    Iceoryx2FFI.iox2_sample_mut_user_header_mut(sample.handle_ref, ptr_ref)
    return Ptr{T}(ptr_ref[])
end

@inline function user_header(sample::SampleMut{T,Nothing}) where {T}
    throw(ArgumentError("sample has no user header type; call user_header(sample, ::Type) instead"))
end

@inline function user_header(sample::SampleMut{T,UH}) where {T,UH}
    ptr = unsafe_user_header_mut_ptr(sample, UH)
    return Slice{UH}(ptr, 1, sample)
end

@inline function user_header(sample::SampleMut{T,UH}, ::Type{UH}) where {T,UH}
    ptr = unsafe_user_header_mut_ptr(sample, UH)
    return Slice{UH}(ptr, 1, sample)
end

@inline function user_header_mut(sample::SampleMut{T,UH}) where {T,UH}
    ptr = unsafe_user_header_mut_ptr(sample, UH)
    return Slice{UH}(ptr, 1, sample)
end

@inline function user_header_mut(sample::SampleMut{T,UH}, ::Type{UH}) where {T,UH}
    ptr = unsafe_user_header_mut_ptr(sample, UH)
    return Slice{UH}(ptr, 1, sample)
end

@inline function publisher_id(header::PublishSubscribeHeader)
    handle_ref = Ref{Iceoryx2FFI.iox2_unique_publisher_id_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_publish_subscribe_header_publisher_id(
        Ref{Iceoryx2FFI.iox2_publish_subscribe_header_h}(unsafe_handle(header)),
        C_NULL,
        handle_ref,
    )
    return UniquePublisherId(handle_ref[])
end

@inline function number_of_elements(header::PublishSubscribeHeader)
    return Int(
        Iceoryx2FFI.iox2_publish_subscribe_header_number_of_elements(
            Ref{Iceoryx2FFI.iox2_publish_subscribe_header_h}(unsafe_handle(header)),
        ),
    )
end


function loan_slice_uninit!(publisher::Publisher{T,UH}, sample::SampleMut{T,UH}, n::Integer) where {T,UH}
    _require_valid(publisher.handle, "publisher")
    _require_inactive(sample, "sample")
    sample.handle_ref[] = _IOX2_NULL
    ret = Iceoryx2FFI.iox2_publisher_loan_slice_uninit(
        Ref{Iceoryx2FFI.iox2_publisher_h}(publisher.handle),
        sample.storage,
        sample.handle_ref,
        Iceoryx2FFI.c_size_t(n),
    )
    check_ok(ret, Iceoryx2FFI.iox2_loan_error_e)
    return sample
end

@inline function loan_uninit!(publisher::Publisher{T,UH}, sample::SampleMut{T,UH}) where {T,UH}
    return loan_slice_uninit!(publisher, sample, 1)
end

function loan!(publisher::Publisher{T,UH}, sample::SampleMut{T,UH}) where {T,UH}
    loan_slice_uninit!(publisher, sample, 1)
    fill!(payload_mut(sample), _default_value(T))
    return sample
end

function loan_slice!(publisher::Publisher{T,UH}, sample::SampleMut{T,UH}, n::Integer) where {T,UH}
    loan_slice_uninit!(publisher, sample, n)
    fill!(payload_mut(sample), _default_value(T))
    return sample
end

function loan_slice!(f::Function, publisher::Publisher{T,UH}, sample::SampleMut{T,UH}, n::Integer) where {T,UH}
    loan_slice!(publisher, sample, n)
    try
        return f(sample)
    finally
        close(sample)
    end
end

function loan_slice_uninit!(f::Function, publisher::Publisher{T,UH}, sample::SampleMut{T,UH}, n::Integer) where {T,UH}
    loan_slice_uninit!(publisher, sample, n)
    try
        return f(sample)
    finally
        close(sample)
    end
end

@inline function write_payload!(sample::SampleMut{T,UH}, value::T) where {T,UH}
    slice = payload_mut(sample)
    unsafe_store!(slice.ptr, value, 1)
    return sample
end

@inline function _write_from_fn!(slice::Slice{T}, f::Function) where {T}
    @inbounds for idx in 1:slice.len
        unsafe_store!(slice.ptr, f(idx - 1), idx)
    end
    return slice
end

function write_from_fn!(f::Function, sample::SampleMut{T,UH}) where {T,UH}
    _write_from_fn!(payload_mut(sample), f)
    return sample
end

@inline function send!(sample::SampleMut)
    ret = Iceoryx2FFI.iox2_sample_mut_send(sample.handle_ref[], C_NULL)
    check_ok(ret, Iceoryx2FFI.iox2_send_error_e)
    sample.handle_ref[] = _IOX2_NULL
    return nothing
end

function send_copy(publisher::Publisher{T,UH}, data::Ptr{T}, n::Integer) where {T,UH}
    _require_valid(publisher.handle, "publisher")
    recipients = Ref{Iceoryx2FFI.c_size_t}()
    ret = Iceoryx2FFI.iox2_publisher_send_slice_copy(Ref{Iceoryx2FFI.iox2_publisher_h}(publisher.handle), data, Iceoryx2FFI.c_size_t(sizeof(T)), Iceoryx2FFI.c_size_t(n), recipients)
    check_ok(ret, Iceoryx2FFI.iox2_send_error_e)
    return Int(recipients[])
end

function send_copy(publisher::Publisher{T,UH}, data::AbstractVector{T}) where {T,UH}
    _require_isbits(T)
    GC.@preserve data begin
        return send_copy(publisher, pointer(data), length(data))
    end
end

function send_copy(publisher::Publisher{T,UH}, value::T) where {T,UH}
    _require_isbits(T)
    value_ref = Ref{T}(value)
    GC.@preserve value_ref begin
        return send_copy(publisher, Base.unsafe_convert(Ptr{T}, value_ref), 1)
    end
end

function update_connections!(publisher::Publisher)
    _require_valid(publisher.handle, "publisher")
    ret = Iceoryx2FFI.iox2_publisher_update_connections(Ref{Iceoryx2FFI.iox2_publisher_h}(publisher.handle))
    check_ok(ret, Iceoryx2FFI.iox2_connection_failure_e)
    return nothing
end

function receive!(subscriber::Subscriber{T,UH}, sample::Sample{T,UH}) where {T,UH}
    _require_valid(subscriber.handle, "subscriber")
    _require_inactive(sample, "sample")
    sample.handle_ref[] = _IOX2_NULL
    ret = Iceoryx2FFI.iox2_subscriber_receive(
        Ref{Iceoryx2FFI.iox2_subscriber_h}(subscriber.handle),
        sample.storage,
        sample.handle_ref,
    )
    check_ok(ret, Iceoryx2FFI.iox2_receive_error_e)
    return sample.handle_ref[] != _IOX2_NULL
end

function receive!(f::Function, subscriber::Subscriber{T,UH}, sample::Sample{T,UH}) where {T,UH}
    if receive!(subscriber, sample)
        try
            return f(sample)
        finally
            close(sample)
        end
    end
    return nothing
end

function has_samples(subscriber::Subscriber)
    result = Ref{Bool}()
    ret = Iceoryx2FFI.iox2_subscriber_has_samples(Ref{Iceoryx2FFI.iox2_subscriber_h}(subscriber.handle), result)
    check_ok(ret, Iceoryx2FFI.iox2_connection_failure_e)
    return result[]
end

# === Request/Response ===

function _set_request_payload_type!(builder::RequestResponseServiceBuilder{Req,Resp,ReqH,RespH}, ::Type{Req}; variant::Union{Symbol,Iceoryx2FFI.iox2_type_variant_e}=:fixed) where {Req,Resp,ReqH,RespH}
    _require_valid(builder.handle, "request_response service builder")
    _require_isbits(Req)
    name, name_len, size, alignment = _type_details(Req)
    v = _type_variant(variant)
    GC.@preserve name begin
        ret = Iceoryx2FFI.iox2_service_builder_request_response_set_request_payload_type_details(Ref{Iceoryx2FFI.iox2_service_builder_request_response_h}(builder.handle), v, Base.unsafe_convert(Cstring, name), name_len, size, alignment)
        check_ok(ret, Iceoryx2FFI.iox2_type_detail_error_e)
    end
    return builder
end

function _set_request_payload_type!(builder::RequestResponseServiceBuilder{Req,Resp,ReqH,RespH}, ::Type{Other}; variant::Union{Symbol,Iceoryx2FFI.iox2_type_variant_e}=:fixed) where {Req,Resp,ReqH,RespH,Other}
    throw(ArgumentError("request payload type already set to $Req"))
end

function request_payload_alignment!(builder::RequestResponseServiceBuilder, alignment::Integer)
    alignment > 0 || throw(ArgumentError("request payload alignment must be positive, got $alignment"))
    Iceoryx2FFI.iox2_service_builder_request_response_request_payload_alignment(
        Ref{Iceoryx2FFI.iox2_service_builder_request_response_h}(builder.handle),
        Iceoryx2FFI.c_size_t(alignment),
    )
    return builder
end

function _set_response_payload_type!(builder::RequestResponseServiceBuilder{Req,Resp,ReqH,RespH}, ::Type{Resp}; variant::Union{Symbol,Iceoryx2FFI.iox2_type_variant_e}=:fixed) where {Req,Resp,ReqH,RespH}
    _require_valid(builder.handle, "request_response service builder")
    _require_isbits(Resp)
    name, name_len, size, alignment = _type_details(Resp)
    v = _type_variant(variant)
    GC.@preserve name begin
        ret = Iceoryx2FFI.iox2_service_builder_request_response_set_response_payload_type_details(Ref{Iceoryx2FFI.iox2_service_builder_request_response_h}(builder.handle), v, Base.unsafe_convert(Cstring, name), name_len, size, alignment)
        check_ok(ret, Iceoryx2FFI.iox2_type_detail_error_e)
    end
    return builder
end

function _set_response_payload_type!(builder::RequestResponseServiceBuilder{Req,Resp,ReqH,RespH}, ::Type{Other}; variant::Union{Symbol,Iceoryx2FFI.iox2_type_variant_e}=:fixed) where {Req,Resp,ReqH,RespH,Other}
    throw(ArgumentError("response payload type already set to $Resp"))
end

function response_payload_alignment!(builder::RequestResponseServiceBuilder, alignment::Integer)
    alignment > 0 || throw(ArgumentError("response payload alignment must be positive, got $alignment"))
    Iceoryx2FFI.iox2_service_builder_request_response_response_payload_alignment(
        Ref{Iceoryx2FFI.iox2_service_builder_request_response_h}(builder.handle),
        Iceoryx2FFI.c_size_t(alignment),
    )
    return builder
end

function request_user_header(builder::RequestResponseServiceBuilder{Req,Resp,Nothing,RespH}, ::Type{H}; variant::Union{Symbol,Iceoryx2FFI.iox2_type_variant_e}=:fixed) where {Req,Resp,RespH,H}
    _require_valid(builder.handle, "request/response service builder")
    _require_isbits(H)
    name, name_len, size, alignment = _type_details(H)
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
    handle = builder.handle
    storage = builder.storage
    builder.handle = _IOX2_NULL
    builder.storage = Ref{Iceoryx2FFI.iox2_service_builder_t}()
    return RequestResponseServiceBuilder{Req,Resp,H,RespH}(handle, storage, builder.keepalive)
end

function request_user_header(builder::RequestResponseServiceBuilder{Req,Resp,ReqH,RespH}, ::Type{ReqH}; variant::Union{Symbol,Iceoryx2FFI.iox2_type_variant_e}=:fixed) where {Req,Resp,ReqH,RespH}
    _require_valid(builder.handle, "request/response service builder")
    return builder
end

function request_user_header(builder::RequestResponseServiceBuilder{Req,Resp,ReqH,RespH}, ::Type{Other}; variant::Union{Symbol,Iceoryx2FFI.iox2_type_variant_e}=:fixed) where {Req,Resp,ReqH,RespH,Other}
    _require_valid(builder.handle, "request/response service builder")
    throw(ArgumentError("request user header type already set to $ReqH"))
end

function response_user_header(builder::RequestResponseServiceBuilder{Req,Resp,ReqH,Nothing}, ::Type{H}; variant::Union{Symbol,Iceoryx2FFI.iox2_type_variant_e}=:fixed) where {Req,Resp,ReqH,H}
    _require_valid(builder.handle, "request/response service builder")
    _require_isbits(H)
    name, name_len, size, alignment = _type_details(H)
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
    handle = builder.handle
    storage = builder.storage
    builder.handle = _IOX2_NULL
    builder.storage = Ref{Iceoryx2FFI.iox2_service_builder_t}()
    return RequestResponseServiceBuilder{Req,Resp,ReqH,H}(handle, storage, builder.keepalive)
end

function response_user_header(builder::RequestResponseServiceBuilder{Req,Resp,ReqH,RespH}, ::Type{RespH}; variant::Union{Symbol,Iceoryx2FFI.iox2_type_variant_e}=:fixed) where {Req,Resp,ReqH,RespH}
    _require_valid(builder.handle, "request/response service builder")
    return builder
end

function response_user_header(builder::RequestResponseServiceBuilder{Req,Resp,ReqH,RespH}, ::Type{Other}; variant::Union{Symbol,Iceoryx2FFI.iox2_type_variant_e}=:fixed) where {Req,Resp,ReqH,RespH,Other}
    _require_valid(builder.handle, "request/response service builder")
    throw(ArgumentError("response user header type already set to $RespH"))
end

### builder tuning setters generated in src/generated/wrappers.jl

mutable struct PortFactoryRequestResponse{Req,Resp,ReqH,RespH}
    handle::Iceoryx2FFI.iox2_port_factory_request_response_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_request_response_t}
    keepalive::Node
    function PortFactoryRequestResponse{Req,Resp,ReqH,RespH}(handle, storage, keepalive) where {Req,Resp,ReqH,RespH}
        obj = new{Req,Resp,ReqH,RespH}(handle, storage, keepalive)
        finalizer(_finalize_port_factory_request_response, obj)
        return obj
    end
end

function _finalize_port_factory_request_response(factory::PortFactoryRequestResponse)
    if factory.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_port_factory_request_response_drop(factory.handle)
        factory.handle = _IOX2_NULL
    end
    factory.storage = nothing
    return nothing
end

function open_or_create(builder::RequestResponseServiceBuilder{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH}
    _require_valid(builder.handle, "request_response service builder")
    _require_isbits(Req)
    _require_isbits(Resp)
    storage = Ref{Iceoryx2FFI.iox2_port_factory_request_response_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_request_response_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_request_response_open_or_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_request_response_open_or_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    return PortFactoryRequestResponse{Req,Resp,ReqH,RespH}(handle_ref[], storage, builder.keepalive)
end

function open_or_create(builder::RequestResponseServiceBuilder{Req,Resp,ReqH,RespH}, verifier::AttributeVerifier) where {Req,Resp,ReqH,RespH}
    _require_valid(builder.handle, "request_response service builder")
    _require_isbits(Req)
    _require_isbits(Resp)
    _require_valid(unsafe_handle(verifier), "attribute verifier")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_request_response_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_request_response_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_request_response_open_or_create_with_attributes(
        builder.handle,
        Ref{Iceoryx2FFI.iox2_attribute_verifier_h}(unsafe_handle(verifier)),
        storage,
        handle_ref,
    )
    check_ok(ret, Iceoryx2FFI.iox2_request_response_open_or_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    return PortFactoryRequestResponse{Req,Resp,ReqH,RespH}(handle_ref[], storage, builder.keepalive)
end

function open(builder::RequestResponseServiceBuilder{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH}
    _require_valid(builder.handle, "request_response service builder")
    _require_isbits(Req)
    _require_isbits(Resp)
    storage = Ref{Iceoryx2FFI.iox2_port_factory_request_response_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_request_response_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_request_response_open(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_request_response_open_or_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    return PortFactoryRequestResponse{Req,Resp,ReqH,RespH}(handle_ref[], storage, builder.keepalive)
end

function open(builder::RequestResponseServiceBuilder{Req,Resp,ReqH,RespH}, verifier::AttributeVerifier) where {Req,Resp,ReqH,RespH}
    _require_valid(builder.handle, "request_response service builder")
    _require_isbits(Req)
    _require_isbits(Resp)
    _require_valid(unsafe_handle(verifier), "attribute verifier")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_request_response_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_request_response_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_request_response_open_with_attributes(
        builder.handle,
        Ref{Iceoryx2FFI.iox2_attribute_verifier_h}(unsafe_handle(verifier)),
        storage,
        handle_ref,
    )
    check_ok(ret, Iceoryx2FFI.iox2_request_response_open_or_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    return PortFactoryRequestResponse{Req,Resp,ReqH,RespH}(handle_ref[], storage, builder.keepalive)
end

function create(builder::RequestResponseServiceBuilder{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH}
    _require_valid(builder.handle, "request_response service builder")
    _require_isbits(Req)
    _require_isbits(Resp)
    storage = Ref{Iceoryx2FFI.iox2_port_factory_request_response_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_request_response_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_request_response_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_request_response_open_or_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    return PortFactoryRequestResponse{Req,Resp,ReqH,RespH}(handle_ref[], storage, builder.keepalive)
end

function create(builder::RequestResponseServiceBuilder{Req,Resp,ReqH,RespH}, specifier::AttributeSpecifier) where {Req,Resp,ReqH,RespH}
    _require_valid(builder.handle, "request_response service builder")
    _require_isbits(Req)
    _require_isbits(Resp)
    _require_valid(unsafe_handle(specifier), "attribute specifier")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_request_response_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_request_response_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_request_response_create_with_attributes(
        builder.handle,
        Ref{Iceoryx2FFI.iox2_attribute_specifier_h}(unsafe_handle(specifier)),
        storage,
        handle_ref,
    )
    check_ok(ret, Iceoryx2FFI.iox2_request_response_open_or_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    return PortFactoryRequestResponse{Req,Resp,ReqH,RespH}(handle_ref[], storage, builder.keepalive)
end

function open_or_create(f::Function, builder::RequestResponseServiceBuilder)
    factory = open_or_create(builder)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function open_or_create(f::Function, builder::RequestResponseServiceBuilder, verifier::AttributeVerifier)
    factory = open_or_create(builder, verifier)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function open(f::Function, builder::RequestResponseServiceBuilder)
    factory = open(builder)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function open(f::Function, builder::RequestResponseServiceBuilder, verifier::AttributeVerifier)
    factory = open(builder, verifier)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function create(f::Function, builder::RequestResponseServiceBuilder)
    factory = create(builder)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function create(f::Function, builder::RequestResponseServiceBuilder, specifier::AttributeSpecifier)
    factory = create(builder, specifier)
    try
        return f(factory)
    finally
        close(factory)
    end
end

open_or_create_with_attributes(builder::RequestResponseServiceBuilder, verifier::AttributeVerifier) = open_or_create(builder, verifier)
open_or_create_with_attributes(f::Function, builder::RequestResponseServiceBuilder, verifier::AttributeVerifier) = open_or_create(f, builder, verifier)
open_with_attributes(builder::RequestResponseServiceBuilder, verifier::AttributeVerifier) = open(builder, verifier)
open_with_attributes(f::Function, builder::RequestResponseServiceBuilder, verifier::AttributeVerifier) = open(f, builder, verifier)
create_with_attributes(builder::RequestResponseServiceBuilder, specifier::AttributeSpecifier) = create(builder, specifier)
create_with_attributes(f::Function, builder::RequestResponseServiceBuilder, specifier::AttributeSpecifier) = create(f, builder, specifier)

mutable struct ClientBuilder{Req,Resp,ReqH,RespH}
    handle::Iceoryx2FFI.iox2_port_factory_client_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_client_builder_t}
    keepalive::PortFactoryRequestResponse{Req,Resp,ReqH,RespH}
    function ClientBuilder{Req,Resp,ReqH,RespH}(handle, storage, keepalive) where {Req,Resp,ReqH,RespH}
        obj = new{Req,Resp,ReqH,RespH}(handle, storage, keepalive)
        finalizer(_finalize_client_builder, obj)
        return obj
    end
end

function _finalize_client_builder(builder::ClientBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

function client_builder(factory::PortFactoryRequestResponse{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH}
    _require_valid(factory.handle, "request_response port factory")
    _require_isbits(Req)
    _require_isbits(Resp)
    storage = Ref{Iceoryx2FFI.iox2_port_factory_client_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_request_response_client_builder(Ref{Iceoryx2FFI.iox2_port_factory_request_response_h}(factory.handle), storage)
    return ClientBuilder{Req,Resp,ReqH,RespH}(handle, storage, factory)
end

mutable struct ServerBuilder{Req,Resp,ReqH,RespH}
    handle::Iceoryx2FFI.iox2_port_factory_server_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_server_builder_t}
    keepalive::PortFactoryRequestResponse{Req,Resp,ReqH,RespH}
    function ServerBuilder{Req,Resp,ReqH,RespH}(handle, storage, keepalive) where {Req,Resp,ReqH,RespH}
        obj = new{Req,Resp,ReqH,RespH}(handle, storage, keepalive)
        finalizer(_finalize_server_builder, obj)
        return obj
    end
end

function _finalize_server_builder(builder::ServerBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

function server_builder(factory::PortFactoryRequestResponse{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH}
    _require_valid(factory.handle, "request_response port factory")
    _require_isbits(Req)
    _require_isbits(Resp)
    storage = Ref{Iceoryx2FFI.iox2_port_factory_server_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_request_response_server_builder(Ref{Iceoryx2FFI.iox2_port_factory_request_response_h}(factory.handle), storage)
    return ServerBuilder{Req,Resp,ReqH,RespH}(handle, storage, factory)
end

### builder tuning setters generated in src/generated/wrappers.jl

function allocation_strategy!(builder::ClientBuilder, value::Union{Symbol,Iceoryx2FFI.iox2_allocation_strategy_e})
    _require_valid(builder.handle, "client builder")
    Iceoryx2FFI.iox2_port_factory_client_builder_set_allocation_strategy(
        Ref{Iceoryx2FFI.iox2_port_factory_client_builder_h}(builder.handle),
        _allocation_strategy(value),
    )
    return builder
end

function allocation_strategy!(builder::ServerBuilder, value::Union{Symbol,Iceoryx2FFI.iox2_allocation_strategy_e})
    _require_valid(builder.handle, "server builder")
    Iceoryx2FFI.iox2_port_factory_server_builder_set_allocation_strategy(
        Ref{Iceoryx2FFI.iox2_port_factory_server_builder_h}(builder.handle),
        _allocation_strategy(value),
    )
    return builder
end

function initial_max_slice_len!(builder::ClientBuilder, value::Integer)
    _require_valid(builder.handle, "client builder")
    Iceoryx2FFI.iox2_port_factory_client_builder_set_initial_max_slice_len(
        Ref{Iceoryx2FFI.iox2_port_factory_client_builder_h}(builder.handle),
        Iceoryx2FFI.c_size_t(value),
    )
    return builder
end

function initial_max_slice_len!(builder::ServerBuilder, value::Integer)
    _require_valid(builder.handle, "server builder")
    Iceoryx2FFI.iox2_port_factory_server_builder_set_initial_max_slice_len(
        Ref{Iceoryx2FFI.iox2_port_factory_server_builder_h}(builder.handle),
        Iceoryx2FFI.c_size_t(value),
    )
    return builder
end

mutable struct Client{Req,Resp,ReqH,RespH}
    handle::Iceoryx2FFI.iox2_client_h
    storage::_StorageRef{Iceoryx2FFI.iox2_client_t}
    keepalive::PortFactoryRequestResponse{Req,Resp,ReqH,RespH}
    function Client{Req,Resp,ReqH,RespH}(handle, storage, keepalive) where {Req,Resp,ReqH,RespH}
        obj = new{Req,Resp,ReqH,RespH}(handle, storage, keepalive)
        finalizer(_finalize_client, obj)
        return obj
    end
end

function _finalize_client(client::Client)
    if client.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_client_drop(client.handle)
        client.handle = _IOX2_NULL
    end
    client.storage = nothing
    return nothing
end

function create(builder::ClientBuilder{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH}
    _require_valid(builder.handle, "client builder")
    storage = Ref{Iceoryx2FFI.iox2_client_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_client_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_client_builder_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_client_create_error_e)
    _finalize_client_builder(builder)
    return Client{Req,Resp,ReqH,RespH}(handle_ref[], storage, builder.keepalive)
end

function create(f::Function, builder::ClientBuilder{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH}
    client = create(builder)
    try
        return f(client)
    finally
        close(client)
    end
end

mutable struct Server{Req,Resp,ReqH,RespH}
    handle::Iceoryx2FFI.iox2_server_h
    storage::_StorageRef{Iceoryx2FFI.iox2_server_t}
    keepalive::PortFactoryRequestResponse{Req,Resp,ReqH,RespH}
    function Server{Req,Resp,ReqH,RespH}(handle, storage, keepalive) where {Req,Resp,ReqH,RespH}
        obj = new{Req,Resp,ReqH,RespH}(handle, storage, keepalive)
        finalizer(_finalize_server, obj)
        return obj
    end
end

function _finalize_server(server::Server)
    if server.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_server_drop(server.handle)
        server.handle = _IOX2_NULL
    end
    server.storage = nothing
    return nothing
end

function create(builder::ServerBuilder{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH}
    _require_valid(builder.handle, "server builder")
    storage = Ref{Iceoryx2FFI.iox2_server_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_server_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_server_builder_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_server_create_error_e)
    _finalize_server_builder(builder)
    return Server{Req,Resp,ReqH,RespH}(handle_ref[], storage, builder.keepalive)
end

function create(f::Function, builder::ServerBuilder{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH}
    server = create(builder)
    try
        return f(server)
    finally
        close(server)
    end
end

mutable struct RequestMut{Req,Resp,ReqH,RespH}
    handle_ref::Base.RefValue{Iceoryx2FFI.iox2_request_mut_h}
    storage::Base.RefValue{Iceoryx2FFI.iox2_request_mut_t}
    function RequestMut{Req,Resp,ReqH,RespH}(handle_ref, storage) where {Req,Resp,ReqH,RespH}
        obj = new{Req,Resp,ReqH,RespH}(handle_ref, storage)
        finalizer(_finalize_request_mut, obj)
        return obj
    end
end

function RequestMut{Req,Resp,ReqH,RespH}() where {Req,Resp,ReqH,RespH}
    return RequestMut{Req,Resp,ReqH,RespH}(Ref{Iceoryx2FFI.iox2_request_mut_h}(_IOX2_NULL), Ref{Iceoryx2FFI.iox2_request_mut_t}())
end

RequestMut(client::Client{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH} =
    RequestMut{Req,Resp,ReqH,RespH}()

@inline _slice_mutable(::Type{<:RequestMut}) = true

function _finalize_request_mut(request::RequestMut)
    if request.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_request_mut_drop(request.handle_ref[])
        request.handle_ref[] = _IOX2_NULL
    end
    return nothing
end

@inline function payload_mut(request::RequestMut{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH}
    ptr_ref = Ref{Ptr{Cvoid}}()
    len_ref = Ref{Iceoryx2FFI.c_size_t}()
    Iceoryx2FFI.iox2_request_mut_payload_mut(request.handle_ref, ptr_ref, len_ref)
    return Slice{Req}(Ptr{Req}(ptr_ref[]), Int(len_ref[]), request)
end

@inline function unsafe_payload_mut_ptr(request::RequestMut{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH}
    return payload_mut(request).ptr
end

@inline function header(request::RequestMut)
    _require_valid(request.handle_ref[], "request")
    handle_ref = Ref{Iceoryx2FFI.iox2_request_header_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_request_mut_header(request.handle_ref, C_NULL, handle_ref)
    handle_ref[] != _IOX2_NULL || throw(ErrorException("failed to acquire request header"))
    return RequestHeader(handle_ref[])
end

@inline function write_payload!(request::RequestMut{Req,Resp,ReqH,RespH}, value::Req) where {Req,Resp,ReqH,RespH}
    slice = payload_mut(request)
    unsafe_store!(slice.ptr, value, 1)
    return request
end

function write_from_fn!(f::Function, request::RequestMut{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH}
    _write_from_fn!(payload_mut(request), f)
    return request
end

@inline function unsafe_user_header_mut_ptr(request::RequestMut, ::Type{T}) where {T}
    _require_isbits(T)
    ptr_ref = Ref{Ptr{Cvoid}}()
    Iceoryx2FFI.iox2_request_mut_user_header_mut(request.handle_ref, ptr_ref)
    return Ptr{T}(ptr_ref[])
end

@inline function user_header(request::RequestMut{Req,Resp,Nothing,RespH}) where {Req,Resp,RespH}
    throw(ArgumentError("request has no user header type; call user_header(request, ::Type) instead"))
end

@inline function user_header(request::RequestMut{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH}
    ptr = unsafe_user_header_mut_ptr(request, ReqH)
    return Slice{ReqH}(ptr, 1, request)
end

@inline function user_header(request::RequestMut{Req,Resp,ReqH,RespH}, ::Type{ReqH}) where {Req,Resp,ReqH,RespH}
    ptr = unsafe_user_header_mut_ptr(request, ReqH)
    return Slice{ReqH}(ptr, 1, request)
end

@inline function user_header_mut(request::RequestMut{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH}
    ptr = unsafe_user_header_mut_ptr(request, ReqH)
    return Slice{ReqH}(ptr, 1, request)
end

@inline function user_header_mut(request::RequestMut{Req,Resp,ReqH,RespH}, ::Type{ReqH}) where {Req,Resp,ReqH,RespH}
    ptr = unsafe_user_header_mut_ptr(request, ReqH)
    return Slice{ReqH}(ptr, 1, request)
end

@inline function client_id(header::RequestHeader)
    handle_ref = Ref{Iceoryx2FFI.iox2_unique_client_id_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_request_header_client_id(
        Ref{Iceoryx2FFI.iox2_request_header_h}(unsafe_handle(header)),
        C_NULL,
        handle_ref,
    )
    return UniqueClientId(handle_ref[])
end

@inline function number_of_elements(header::RequestHeader)
    return Int(
        Iceoryx2FFI.iox2_request_header_number_of_elements(
            Ref{Iceoryx2FFI.iox2_request_header_h}(unsafe_handle(header)),
        ),
    )
end


mutable struct PendingResponse{Resp,ReqH,RespH}
    handle_ref::Base.RefValue{Iceoryx2FFI.iox2_pending_response_h}
    storage::Base.RefValue{Iceoryx2FFI.iox2_pending_response_t}
    function PendingResponse{Resp,ReqH,RespH}(handle_ref, storage) where {Resp,ReqH,RespH}
        obj = new{Resp,ReqH,RespH}(handle_ref, storage)
        finalizer(_finalize_pending_response, obj)
        return obj
    end
end

function PendingResponse{Resp,ReqH,RespH}() where {Resp,ReqH,RespH}
    return PendingResponse{Resp,ReqH,RespH}(Ref{Iceoryx2FFI.iox2_pending_response_h}(_IOX2_NULL), Ref{Iceoryx2FFI.iox2_pending_response_t}())
end

PendingResponse(client::Client{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH} =
    PendingResponse{Resp,ReqH,RespH}()

function _finalize_pending_response(pending::PendingResponse)
    if pending.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_pending_response_drop(pending.handle_ref[])
        pending.handle_ref[] = _IOX2_NULL
    end
    return nothing
end

@inline function header(pending::PendingResponse)
    _require_valid(pending.handle_ref[], "pending response")
    handle_ref = Ref{Iceoryx2FFI.iox2_request_header_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_pending_response_header(pending.handle_ref, C_NULL, handle_ref)
    handle_ref[] != _IOX2_NULL || throw(ErrorException("failed to acquire request header"))
    return RequestHeader(handle_ref[])
end

@inline function unsafe_user_header_ptr(pending::PendingResponse, ::Type{T}) where {T}
    _require_isbits(T)
    ptr_ref = Ref{Ptr{Cvoid}}()
    Iceoryx2FFI.iox2_pending_response_user_header(pending.handle_ref, ptr_ref)
    return Ptr{T}(ptr_ref[])
end

@inline function user_header(pending::PendingResponse{Resp,Nothing,RespH}) where {Resp,RespH}
    throw(ArgumentError("pending response has no user header type; call user_header(pending, ::Type) instead"))
end

@inline function user_header(pending::PendingResponse{Resp,ReqH,RespH}) where {Resp,ReqH,RespH}
    ptr = unsafe_user_header_ptr(pending, ReqH)
    return Slice{ReqH}(ptr, 1, pending)
end

@inline function user_header(pending::PendingResponse{Resp,ReqH,RespH}, ::Type{ReqH}) where {Resp,ReqH,RespH}
    ptr = unsafe_user_header_ptr(pending, ReqH)
    return Slice{ReqH}(ptr, 1, pending)
end


function loan_slice_uninit!(
    client::Client{Req,Resp,ReqH,RespH},
    request::RequestMut{Req,Resp,ReqH,RespH},
    n::Integer,
) where {Req,Resp,ReqH,RespH}
    _require_valid(client.handle, "client")
    _require_inactive(request, "request")
    request.handle_ref[] = _IOX2_NULL
    ret = Iceoryx2FFI.iox2_client_loan_slice_uninit(
        Ref{Iceoryx2FFI.iox2_client_h}(client.handle),
        request.storage,
        request.handle_ref,
        Iceoryx2FFI.c_size_t(n),
    )
    check_ok(ret, Iceoryx2FFI.iox2_loan_error_e)
    return request
end

@inline function loan_uninit!(client::Client{Req,Resp,ReqH,RespH}, request::RequestMut{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH}
    return loan_slice_uninit!(client, request, 1)
end

@inline function loan!(client::Client{Req,Resp,ReqH,RespH}, request::RequestMut{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH}
    loan_slice_uninit!(client, request, 1)
    fill!(payload_mut(request), _default_value(Req))
    return request
end

function loan_slice!(client::Client{Req,Resp,ReqH,RespH}, request::RequestMut{Req,Resp,ReqH,RespH}, n::Integer) where {Req,Resp,ReqH,RespH}
    loan_slice_uninit!(client, request, n)
    fill!(payload_mut(request), _default_value(Req))
    return request
end

function loan_slice!(f::Function, client::Client{Req,Resp,ReqH,RespH}, request::RequestMut{Req,Resp,ReqH,RespH}, n::Integer) where {Req,Resp,ReqH,RespH}
    loan_slice!(client, request, n)
    try
        return f(request)
    finally
        close(request)
    end
end

function loan_slice_uninit!(f::Function, client::Client{Req,Resp,ReqH,RespH}, request::RequestMut{Req,Resp,ReqH,RespH}, n::Integer) where {Req,Resp,ReqH,RespH}
    loan_slice_uninit!(client, request, n)
    try
        return f(request)
    finally
        close(request)
    end
end

function loan_request!(client::Client{Req,Resp,ReqH,RespH}, request::RequestMut{Req,Resp,ReqH,RespH}, n::Integer) where {Req,Resp,ReqH,RespH}
    return loan_slice_uninit!(client, request, n)
end

function loan_request!(f::Function, client::Client{Req,Resp,ReqH,RespH}, request::RequestMut{Req,Resp,ReqH,RespH}, n::Integer) where {Req,Resp,ReqH,RespH}
    return loan_slice_uninit!(f, client, request, n)
end

function send!(request::RequestMut{Req,Resp,ReqH,RespH}, pending::PendingResponse{Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH}
    _require_inactive(pending, "pending response")
    pending.handle_ref[] = _IOX2_NULL
    ret = Iceoryx2FFI.iox2_request_mut_send(request.handle_ref[], pending.storage, pending.handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_send_error_e)
    request.handle_ref[] = _IOX2_NULL
    return pending
end

function send_copy!(
    client::Client{Req,Resp,ReqH,RespH},
    data::Ptr{Req},
    n::Integer,
    pending::PendingResponse{Resp,ReqH,RespH},
) where {Req,Resp,ReqH,RespH}
    _require_inactive(pending, "pending response")
    pending.handle_ref[] = _IOX2_NULL
    ret = Iceoryx2FFI.iox2_client_send_copy(
        Ref{Iceoryx2FFI.iox2_client_h}(client.handle),
        data,
        Iceoryx2FFI.c_size_t(sizeof(Req)),
        Iceoryx2FFI.c_size_t(n),
        pending.storage,
        pending.handle_ref,
    )
    check_ok(ret, Iceoryx2FFI.iox2_send_error_e)
    return pending
end

function send_copy!(
    client::Client{Req,Resp,ReqH,RespH},
    data::AbstractVector{Req},
    pending::PendingResponse{Resp,ReqH,RespH},
) where {Req,Resp,ReqH,RespH}
    _require_isbits(Req)
    GC.@preserve data begin
        return send_copy!(client, pointer(data), length(data), pending)
    end
end

function send_copy!(
    client::Client{Req,Resp,ReqH,RespH},
    value::Req,
    pending::PendingResponse{Resp,ReqH,RespH},
) where {Req,Resp,ReqH,RespH}
    _require_isbits(Req)
    value_ref = Ref{Req}(value)
    GC.@preserve value_ref begin
        return send_copy!(client, Base.unsafe_convert(Ptr{Req}, value_ref), 1, pending)
    end
end

mutable struct Response{Resp,RespH}
    handle_ref::Base.RefValue{Iceoryx2FFI.iox2_response_h}
    storage::Base.RefValue{Iceoryx2FFI.iox2_response_t}
    function Response{Resp,RespH}(handle_ref, storage) where {Resp,RespH}
        obj = new{Resp,RespH}(handle_ref, storage)
        finalizer(_finalize_response, obj)
        return obj
    end
end

function Response{Resp,RespH}() where {Resp,RespH}
    return Response{Resp,RespH}(Ref{Iceoryx2FFI.iox2_response_h}(_IOX2_NULL), Ref{Iceoryx2FFI.iox2_response_t}())
end

Response(pending::PendingResponse{Resp,ReqH,RespH}) where {Resp,ReqH,RespH} = Response{Resp,RespH}()

function _finalize_response(resp::Response)
    if resp.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_response_drop(resp.handle_ref[])
        resp.handle_ref[] = _IOX2_NULL
    end
    return nothing
end

@inline function payload(resp::Response{RespT,RespH}) where {RespT,RespH}
    ptr_ref = Ref{Ptr{Cvoid}}()
    len_ref = Ref{Iceoryx2FFI.c_size_t}()
    Iceoryx2FFI.iox2_response_payload(resp.handle_ref, ptr_ref, len_ref)
    return Slice{RespT}(Ptr{RespT}(ptr_ref[]), Int(len_ref[]), resp)
end

@inline function unsafe_payload_ptr(resp::Response{RespT,RespH}) where {RespT,RespH}
    return payload(resp).ptr
end

@inline function header(resp::Response)
    _require_valid(resp.handle_ref[], "response")
    handle_ref = Ref{Iceoryx2FFI.iox2_response_header_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_response_header(resp.handle_ref, C_NULL, handle_ref)
    handle_ref[] != _IOX2_NULL || throw(ErrorException("failed to acquire response header"))
    return ResponseHeader(handle_ref[])
end

@inline function unsafe_user_header_ptr(resp::Response, ::Type{T}) where {T}
    _require_isbits(T)
    ptr_ref = Ref{Ptr{Cvoid}}()
    Iceoryx2FFI.iox2_response_user_header(resp.handle_ref, ptr_ref)
    return Ptr{T}(ptr_ref[])
end

@inline function user_header(resp::Response{RespT,Nothing}) where {RespT}
    throw(ArgumentError("response has no user header type; call user_header(response, ::Type) instead"))
end

@inline function user_header(resp::Response{RespT,RespH}) where {RespT,RespH}
    ptr = unsafe_user_header_ptr(resp, RespH)
    return Slice{RespH}(ptr, 1, resp)
end

@inline function user_header(resp::Response{RespT,RespH}, ::Type{RespH}) where {RespT,RespH}
    ptr = unsafe_user_header_ptr(resp, RespH)
    return Slice{RespH}(ptr, 1, resp)
end

@inline function server_id(header::ResponseHeader)
    handle_ref = Ref{Iceoryx2FFI.iox2_unique_server_id_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_response_header_server_id(
        Ref{Iceoryx2FFI.iox2_response_header_h}(unsafe_handle(header)),
        C_NULL,
        handle_ref,
    )
    return UniqueServerId(handle_ref[])
end

@inline function number_of_elements(header::ResponseHeader)
    return Int(
        Iceoryx2FFI.iox2_response_header_number_of_elements(
            Ref{Iceoryx2FFI.iox2_response_header_h}(unsafe_handle(header)),
        ),
    )
end


function receive!(pending::PendingResponse{Resp,ReqH,RespH}, resp::Response{Resp,RespH}) where {Resp,ReqH,RespH}
    _require_valid(pending.handle_ref[], "pending response")
    _require_inactive(resp, "response")
    resp.handle_ref[] = _IOX2_NULL
    ret = Iceoryx2FFI.iox2_pending_response_receive(
        pending.handle_ref,
        resp.storage,
        resp.handle_ref,
    )
    check_ok(ret, Iceoryx2FFI.iox2_receive_error_e)
    return resp.handle_ref[] != _IOX2_NULL
end

function receive!(f::Function, pending::PendingResponse{Resp,ReqH,RespH}, resp::Response{Resp,RespH}) where {Resp,ReqH,RespH}
    if receive!(pending, resp)
        try
            return f(resp)
        finally
            close(resp)
        end
    end
    return nothing
end

mutable struct ActiveRequest{Req,Resp,ReqH,RespH}
    handle_ref::Base.RefValue{Iceoryx2FFI.iox2_active_request_h}
    storage::Base.RefValue{Iceoryx2FFI.iox2_active_request_t}
    function ActiveRequest{Req,Resp,ReqH,RespH}(handle_ref, storage) where {Req,Resp,ReqH,RespH}
        obj = new{Req,Resp,ReqH,RespH}(handle_ref, storage)
        finalizer(_finalize_active_request, obj)
        return obj
    end
end

function ActiveRequest{Req,Resp,ReqH,RespH}() where {Req,Resp,ReqH,RespH}
    return ActiveRequest{Req,Resp,ReqH,RespH}(Ref{Iceoryx2FFI.iox2_active_request_h}(_IOX2_NULL), Ref{Iceoryx2FFI.iox2_active_request_t}())
end

ActiveRequest(server::Server{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH} =
    ActiveRequest{Req,Resp,ReqH,RespH}()

function _finalize_active_request(req::ActiveRequest)
    if req.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_active_request_drop(req.handle_ref[])
        req.handle_ref[] = _IOX2_NULL
    end
    return nothing
end

@inline function payload(req::ActiveRequest{ReqT,RespT,ReqH,RespH}) where {ReqT,RespT,ReqH,RespH}
    ptr_ref = Ref{Ptr{Cvoid}}()
    len_ref = Ref{Iceoryx2FFI.c_size_t}()
    Iceoryx2FFI.iox2_active_request_payload(req.handle_ref, ptr_ref, len_ref)
    return Slice{ReqT}(Ptr{ReqT}(ptr_ref[]), Int(len_ref[]), req)
end

@inline function unsafe_payload_ptr(req::ActiveRequest{ReqT,RespT,ReqH,RespH}) where {ReqT,RespT,ReqH,RespH}
    return payload(req).ptr
end

@inline function header(req::ActiveRequest)
    _require_valid(req.handle_ref[], "active request")
    handle_ref = Ref{Iceoryx2FFI.iox2_request_header_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_active_request_header(req.handle_ref, C_NULL, handle_ref)
    handle_ref[] != _IOX2_NULL || throw(ErrorException("failed to acquire request header"))
    return RequestHeader(handle_ref[])
end

@inline function unsafe_user_header_ptr(req::ActiveRequest, ::Type{T}) where {T}
    _require_isbits(T)
    ptr_ref = Ref{Ptr{Cvoid}}()
    Iceoryx2FFI.iox2_active_request_user_header(req.handle_ref, ptr_ref)
    return Ptr{T}(ptr_ref[])
end

@inline function user_header(req::ActiveRequest{ReqT,RespT,Nothing,RespH}) where {ReqT,RespT,RespH}
    throw(ArgumentError("active request has no user header type; call user_header(request, ::Type) instead"))
end

@inline function user_header(req::ActiveRequest{ReqT,RespT,ReqH,RespH}) where {ReqT,RespT,ReqH,RespH}
    ptr = unsafe_user_header_ptr(req, ReqH)
    return Slice{ReqH}(ptr, 1, req)
end

@inline function user_header(req::ActiveRequest{ReqT,RespT,ReqH,RespH}, ::Type{ReqH}) where {ReqT,RespT,ReqH,RespH}
    ptr = unsafe_user_header_ptr(req, ReqH)
    return Slice{ReqH}(ptr, 1, req)
end


mutable struct ResponseMut{Resp,RespH}
    handle_ref::Base.RefValue{Iceoryx2FFI.iox2_response_mut_h}
    storage::Base.RefValue{Iceoryx2FFI.iox2_response_mut_t}
    function ResponseMut{Resp,RespH}(handle_ref, storage) where {Resp,RespH}
        obj = new{Resp,RespH}(handle_ref, storage)
        finalizer(_finalize_response_mut, obj)
        return obj
    end
end

function ResponseMut{Resp,RespH}() where {Resp,RespH}
    return ResponseMut{Resp,RespH}(Ref{Iceoryx2FFI.iox2_response_mut_h}(_IOX2_NULL), Ref{Iceoryx2FFI.iox2_response_mut_t}())
end

ResponseMut(req::ActiveRequest{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH} = ResponseMut{Resp,RespH}()

@inline _slice_mutable(::Type{<:ResponseMut}) = true

function _finalize_response_mut(resp::ResponseMut)
    if resp.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_response_mut_drop(resp.handle_ref[])
        resp.handle_ref[] = _IOX2_NULL
    end
    return nothing
end

@inline function payload_mut(resp::ResponseMut{RespT,RespH}) where {RespT,RespH}
    ptr_ref = Ref{Ptr{Cvoid}}()
    len_ref = Ref{Iceoryx2FFI.c_size_t}()
    Iceoryx2FFI.iox2_response_mut_payload_mut(resp.handle_ref, ptr_ref, len_ref)
    return Slice{RespT}(Ptr{RespT}(ptr_ref[]), Int(len_ref[]), resp)
end

@inline function unsafe_payload_mut_ptr(resp::ResponseMut{RespT,RespH}) where {RespT,RespH}
    return payload_mut(resp).ptr
end

@inline function header(resp::ResponseMut)
    _require_valid(resp.handle_ref[], "response")
    handle_ref = Ref{Iceoryx2FFI.iox2_response_header_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_response_mut_header(resp.handle_ref, C_NULL, handle_ref)
    handle_ref[] != _IOX2_NULL || throw(ErrorException("failed to acquire response header"))
    return ResponseHeader(handle_ref[])
end

@inline function write_payload!(resp::ResponseMut{RespT,RespH}, value::RespT) where {RespT,RespH}
    slice = payload_mut(resp)
    unsafe_store!(slice.ptr, value, 1)
    return resp
end

function write_from_fn!(f::Function, resp::ResponseMut{RespT,RespH}) where {RespT,RespH}
    _write_from_fn!(payload_mut(resp), f)
    return resp
end

@inline function unsafe_user_header_mut_ptr(resp::ResponseMut, ::Type{T}) where {T}
    _require_isbits(T)
    ptr_ref = Ref{Ptr{Cvoid}}()
    Iceoryx2FFI.iox2_response_mut_user_header_mut(resp.handle_ref, ptr_ref)
    return Ptr{T}(ptr_ref[])
end

@inline function user_header(resp::ResponseMut{RespT,Nothing}) where {RespT}
    throw(ArgumentError("response has no user header type; call user_header(response, ::Type) instead"))
end

@inline function user_header(resp::ResponseMut{RespT,RespH}) where {RespT,RespH}
    ptr = unsafe_user_header_mut_ptr(resp, RespH)
    return Slice{RespH}(ptr, 1, resp)
end

@inline function user_header(resp::ResponseMut{RespT,RespH}, ::Type{RespH}) where {RespT,RespH}
    ptr = unsafe_user_header_mut_ptr(resp, RespH)
    return Slice{RespH}(ptr, 1, resp)
end

@inline function user_header_mut(resp::ResponseMut{RespT,RespH}) where {RespT,RespH}
    ptr = unsafe_user_header_mut_ptr(resp, RespH)
    return Slice{RespH}(ptr, 1, resp)
end

@inline function user_header_mut(resp::ResponseMut{RespT,RespH}, ::Type{RespH}) where {RespT,RespH}
    ptr = unsafe_user_header_mut_ptr(resp, RespH)
    return Slice{RespH}(ptr, 1, resp)
end


function receive!(server::Server{Req,Resp,ReqH,RespH}, req::ActiveRequest{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH}
    _require_valid(server.handle, "server")
    _require_inactive(req, "active request")
    req.handle_ref[] = _IOX2_NULL
    ret = Iceoryx2FFI.iox2_server_receive(
        Ref{Iceoryx2FFI.iox2_server_h}(server.handle),
        req.storage,
        req.handle_ref,
    )
    check_ok(ret, Iceoryx2FFI.iox2_receive_error_e)
    return req.handle_ref[] != _IOX2_NULL
end

function receive!(f::Function, server::Server{Req,Resp,ReqH,RespH}, req::ActiveRequest{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH}
    if receive!(server, req)
        try
            return f(req)
        finally
            close(req)
        end
    end
    return nothing
end

function has_requests(server::Server)
    result = Ref{Bool}()
    ret = Iceoryx2FFI.iox2_server_has_requests(Ref{Iceoryx2FFI.iox2_server_h}(server.handle), result)
    check_ok(ret, Iceoryx2FFI.iox2_connection_failure_e)
    return result[]
end

function loan_slice_uninit!(
    req::ActiveRequest{Req,Resp,ReqH,RespH},
    resp::ResponseMut{Resp,RespH},
    n::Integer,
) where {Req,Resp,ReqH,RespH}
    _require_inactive(resp, "response")
    resp.handle_ref[] = _IOX2_NULL
    ret = Iceoryx2FFI.iox2_active_request_loan_slice_uninit(
        req.handle_ref,
        resp.storage,
        resp.handle_ref,
        Iceoryx2FFI.c_size_t(n),
    )
    check_ok(ret, Iceoryx2FFI.iox2_loan_error_e)
    return resp
end

@inline function loan_uninit!(req::ActiveRequest{Req,Resp,ReqH,RespH}, resp::ResponseMut{Resp,RespH}) where {Req,Resp,ReqH,RespH}
    return loan_slice_uninit!(req, resp, 1)
end

@inline function loan!(req::ActiveRequest{Req,Resp,ReqH,RespH}, resp::ResponseMut{Resp,RespH}) where {Req,Resp,ReqH,RespH}
    loan_slice_uninit!(req, resp, 1)
    fill!(payload_mut(resp), _default_value(Resp))
    return resp
end

function loan_slice!(req::ActiveRequest{Req,Resp,ReqH,RespH}, resp::ResponseMut{Resp,RespH}, n::Integer) where {Req,Resp,ReqH,RespH}
    loan_slice_uninit!(req, resp, n)
    fill!(payload_mut(resp), _default_value(Resp))
    return resp
end

function loan_slice!(f::Function, req::ActiveRequest{Req,Resp,ReqH,RespH}, resp::ResponseMut{Resp,RespH}, n::Integer) where {Req,Resp,ReqH,RespH}
    loan_slice!(req, resp, n)
    try
        return f(resp)
    finally
        close(resp)
    end
end

function loan_slice_uninit!(f::Function, req::ActiveRequest{Req,Resp,ReqH,RespH}, resp::ResponseMut{Resp,RespH}, n::Integer) where {Req,Resp,ReqH,RespH}
    loan_slice_uninit!(req, resp, n)
    try
        return f(resp)
    finally
        close(resp)
    end
end

function loan_response!(req::ActiveRequest{Req,Resp,ReqH,RespH}, resp::ResponseMut{Resp,RespH}, n::Integer) where {Req,Resp,ReqH,RespH}
    return loan_slice_uninit!(req, resp, n)
end

function loan_response!(f::Function, req::ActiveRequest{Req,Resp,ReqH,RespH}, resp::ResponseMut{Resp,RespH}, n::Integer) where {Req,Resp,ReqH,RespH}
    return loan_slice_uninit!(f, req, resp, n)
end

function send_copy(req::ActiveRequest{Req,Resp,ReqH,RespH}, data::Ptr{Resp}, n::Integer) where {Req,Resp,ReqH,RespH}
    ret = Iceoryx2FFI.iox2_active_request_send_copy(req.handle_ref, data, Iceoryx2FFI.c_size_t(sizeof(Resp)), Iceoryx2FFI.c_size_t(n))
    check_ok(ret, Iceoryx2FFI.iox2_send_error_e)
    return nothing
end

function send!(resp::ResponseMut)
    ret = Iceoryx2FFI.iox2_response_mut_send(resp.handle_ref[])
    check_ok(ret, Iceoryx2FFI.iox2_send_error_e)
    resp.handle_ref[] = _IOX2_NULL
    return nothing
end

# === Event ===

### builder tuning setters generated in src/generated/wrappers.jl

mutable struct PortFactoryEvent
    handle::Iceoryx2FFI.iox2_port_factory_event_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_event_t}
    keepalive::Node
    function PortFactoryEvent(handle, storage, keepalive)
        obj = new(handle, storage, keepalive)
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

function open_or_create(builder::EventServiceBuilder)
    _require_valid(builder.handle, "event service builder")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_event_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_event_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_event_open_or_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_event_open_or_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    return PortFactoryEvent(handle_ref[], storage, builder.keepalive)
end

function open_or_create(builder::EventServiceBuilder, verifier::AttributeVerifier)
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
    return PortFactoryEvent(handle_ref[], storage, builder.keepalive)
end

function open_or_create(f::Function, builder::EventServiceBuilder)
    factory = open_or_create(builder)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function open_or_create(f::Function, builder::EventServiceBuilder, verifier::AttributeVerifier)
    factory = open_or_create(builder, verifier)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function open(builder::EventServiceBuilder)
    _require_valid(builder.handle, "event service builder")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_event_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_event_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_event_open(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_event_open_or_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    return PortFactoryEvent(handle_ref[], storage, builder.keepalive)
end

function open(builder::EventServiceBuilder, verifier::AttributeVerifier)
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
    return PortFactoryEvent(handle_ref[], storage, builder.keepalive)
end

function open(f::Function, builder::EventServiceBuilder)
    factory = open(builder)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function open(f::Function, builder::EventServiceBuilder, verifier::AttributeVerifier)
    factory = open(builder, verifier)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function create(builder::EventServiceBuilder)
    _require_valid(builder.handle, "event service builder")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_event_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_event_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_event_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_event_open_or_create_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    return PortFactoryEvent(handle_ref[], storage, builder.keepalive)
end

function create(builder::EventServiceBuilder, specifier::AttributeSpecifier)
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
    return PortFactoryEvent(handle_ref[], storage, builder.keepalive)
end

function create(f::Function, builder::EventServiceBuilder)
    factory = create(builder)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function create(f::Function, builder::EventServiceBuilder, specifier::AttributeSpecifier)
    factory = create(builder, specifier)
    try
        return f(factory)
    finally
        close(factory)
    end
end

open_or_create_with_attributes(builder::EventServiceBuilder, verifier::AttributeVerifier) = open_or_create(builder, verifier)
open_or_create_with_attributes(f::Function, builder::EventServiceBuilder, verifier::AttributeVerifier) = open_or_create(f, builder, verifier)
open_with_attributes(builder::EventServiceBuilder, verifier::AttributeVerifier) = open(builder, verifier)
open_with_attributes(f::Function, builder::EventServiceBuilder, verifier::AttributeVerifier) = open(f, builder, verifier)
create_with_attributes(builder::EventServiceBuilder, specifier::AttributeSpecifier) = create(builder, specifier)
create_with_attributes(f::Function, builder::EventServiceBuilder, specifier::AttributeSpecifier) = create(f, builder, specifier)

mutable struct NotifierBuilder
    handle::Iceoryx2FFI.iox2_port_factory_notifier_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_notifier_builder_t}
    keepalive::PortFactoryEvent
    function NotifierBuilder(handle, storage, keepalive)
        obj = new(handle, storage, keepalive)
        finalizer(_finalize_notifier_builder, obj)
        return obj
    end
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
    return NotifierBuilder(handle, storage, factory)
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
    function ListenerBuilder(handle, storage, keepalive)
        obj = new(handle, storage, keepalive)
        finalizer(_finalize_listener_builder, obj)
        return obj
    end
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
    return ListenerBuilder(handle, storage, factory)
end

mutable struct Notifier
    handle::Iceoryx2FFI.iox2_notifier_h
    storage::_StorageRef{Iceoryx2FFI.iox2_notifier_t}
    keepalive::PortFactoryEvent
    function Notifier(handle, storage, keepalive)
        obj = new(handle, storage, keepalive)
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

function create(builder::NotifierBuilder)
    _require_valid(builder.handle, "notifier builder")
    storage = Ref{Iceoryx2FFI.iox2_notifier_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_notifier_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_notifier_builder_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_notifier_create_error_e)
    _finalize_notifier_builder(builder)
    return Notifier(handle_ref[], storage, builder.keepalive)
end

function create(f::Function, builder::NotifierBuilder)
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

mutable struct Listener
    handle::Iceoryx2FFI.iox2_listener_h
    storage::_StorageRef{Iceoryx2FFI.iox2_listener_t}
    keepalive::PortFactoryEvent
    function Listener(handle, storage, keepalive)
        obj = new(handle, storage, keepalive)
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

function create(builder::ListenerBuilder)
    _require_valid(builder.handle, "listener builder")
    storage = Ref{Iceoryx2FFI.iox2_listener_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_listener_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_listener_builder_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_listener_create_error_e)
    _finalize_listener_builder(builder)
    return Listener(handle_ref[], storage, builder.keepalive)
end

function create(f::Function, builder::ListenerBuilder)
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

mutable struct PortFactoryBlackboard{K}
    handle::Iceoryx2FFI.iox2_port_factory_blackboard_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_blackboard_t}
    keepalive::Node
    values::Vector{Any}
    function PortFactoryBlackboard{K}(handle, storage, keepalive, values) where {K}
        obj = new{K}(handle, storage, keepalive, values)
        finalizer(_finalize_port_factory_blackboard, obj)
        return obj
    end
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

function create(builder::BlackboardCreatorBuilder{K}) where {K}
    _require_valid(builder.handle, "blackboard creator")
    _require_isbits(K)
    storage = Ref{Iceoryx2FFI.iox2_port_factory_blackboard_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_blackboard_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_blackboard_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_blackboard_create_error_e)
    builder.handle = _IOX2_NULL
    values = builder.values
    builder.values = Any[]
    _finalize_service_builder_variant(builder)
    return PortFactoryBlackboard{K}(handle_ref[], storage, builder.keepalive, values)
end

function create(f::Function, builder::BlackboardCreatorBuilder)
    factory = create(builder)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function open(builder::BlackboardOpenerBuilder{K}) where {K}
    _require_valid(builder.handle, "blackboard opener")
    _require_isbits(K)
    storage = Ref{Iceoryx2FFI.iox2_port_factory_blackboard_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_blackboard_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_blackboard_open(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_blackboard_open_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    return PortFactoryBlackboard{K}(handle_ref[], storage, builder.keepalive, Any[])
end

function open(f::Function, builder::BlackboardOpenerBuilder)
    factory = open(builder)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function _set_key_type!(builder::BlackboardCreatorBuilder{K}, ::Type{K}) where {K}
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

function _set_key_type!(builder::BlackboardOpenerBuilder{K}, ::Type{K}) where {K}
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

function _set_key_type!(builder::BlackboardCreatorBuilder{K}, ::Type{Other}) where {K,Other}
    throw(ArgumentError("blackboard key type already set to $K"))
end

function _set_key_type!(builder::BlackboardOpenerBuilder{K}, ::Type{Other}) where {K,Other}
    throw(ArgumentError("blackboard key type already set to $K"))
end

function _key_eq_comparison!(builder::BlackboardCreatorBuilder{K}) where {K}
    _require_valid(builder.handle, "blackboard creator")
    Iceoryx2FFI.iox2_service_builder_blackboard_creator_set_key_eq_comparison_function(
        Ref{Iceoryx2FFI.iox2_service_builder_blackboard_creator_h}(builder.handle),
        _blackboard_key_eq_cmp_cfunction(K),
    )
    return builder
end

### builder tuning setters generated in src/generated/wrappers.jl

function add!(builder::BlackboardCreatorBuilder{K}, key::K, value::V) where {K,V}
    _require_valid(builder.handle, "blackboard creator")
    _require_isbits(K)
    _require_isbits(V)
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

function add_with_default!(builder::BlackboardCreatorBuilder{K}, key::K, ::Type{V}) where {K,V}
    return add!(builder, key, zero(V))
end

mutable struct WriterBuilder{K}
    handle::Iceoryx2FFI.iox2_port_factory_writer_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_writer_builder_t}
    keepalive::PortFactoryBlackboard{K}
    function WriterBuilder{K}(handle, storage, keepalive) where {K}
        obj = new{K}(handle, storage, keepalive)
        finalizer(_finalize_writer_builder, obj)
        return obj
    end
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
    return WriterBuilder{K}(handle, storage, factory)
end

mutable struct ReaderBuilder{K}
    handle::Iceoryx2FFI.iox2_port_factory_reader_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_reader_builder_t}
    keepalive::PortFactoryBlackboard{K}
    function ReaderBuilder{K}(handle, storage, keepalive) where {K}
        obj = new{K}(handle, storage, keepalive)
        finalizer(_finalize_reader_builder, obj)
        return obj
    end
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
    return ReaderBuilder{K}(handle, storage, factory)
end

mutable struct Writer{K}
    handle::Iceoryx2FFI.iox2_writer_h
    storage::_StorageRef{Iceoryx2FFI.iox2_writer_t}
    keepalive::PortFactoryBlackboard{K}
    function Writer{K}(handle, storage, keepalive) where {K}
        obj = new{K}(handle, storage, keepalive)
        finalizer(_finalize_writer, obj)
        return obj
    end
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
    _finalize_writer_builder(builder)
    return Writer{K}(handle_ref[], storage, builder.keepalive)
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
    function Reader{K}(handle, storage, keepalive) where {K}
        obj = new{K}(handle, storage, keepalive)
        finalizer(_finalize_reader, obj)
        return obj
    end
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
    _finalize_reader_builder(builder)
    return Reader{K}(handle_ref[], storage, builder.keepalive)
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
    handle_ref::Base.RefValue{Iceoryx2FFI.iox2_entry_handle_h}
    storage::Base.RefValue{Iceoryx2FFI.iox2_entry_handle_t}
    keepalive::Reader{K}
    function EntryHandle{K,V}(handle_ref, storage, keepalive) where {K,V}
        obj = new{K,V}(handle_ref, storage, keepalive)
        finalizer(_finalize_entry_handle, obj)
        return obj
    end
end

function EntryHandle{K,V}(reader::Reader{K}) where {K,V}
    return EntryHandle{K,V}(Ref{Iceoryx2FFI.iox2_entry_handle_h}(_IOX2_NULL), Ref{Iceoryx2FFI.iox2_entry_handle_t}(), reader)
end

EntryHandle(reader::Reader{K}, ::Type{V}) where {K,V} = EntryHandle{K,V}(reader)

function _finalize_entry_handle(entry::EntryHandle)
    if entry.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_entry_handle_drop(entry.handle_ref[])
        entry.handle_ref[] = _IOX2_NULL
    end
    return nothing
end

mutable struct EntryHandleMut{K,V}
    handle_ref::Base.RefValue{Iceoryx2FFI.iox2_entry_handle_mut_h}
    storage::Base.RefValue{Iceoryx2FFI.iox2_entry_handle_mut_t}
    keepalive::Writer{K}
    function EntryHandleMut{K,V}(handle_ref, storage, keepalive) where {K,V}
        obj = new{K,V}(handle_ref, storage, keepalive)
        finalizer(_finalize_entry_handle_mut, obj)
        return obj
    end
end

function EntryHandleMut{K,V}(writer::Writer{K}) where {K,V}
    return EntryHandleMut{K,V}(Ref{Iceoryx2FFI.iox2_entry_handle_mut_h}(_IOX2_NULL), Ref{Iceoryx2FFI.iox2_entry_handle_mut_t}(), writer)
end

EntryHandleMut(writer::Writer{K}, ::Type{V}) where {K,V} = EntryHandleMut{K,V}(writer)

function _finalize_entry_handle_mut(entry::EntryHandleMut)
    if entry.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_entry_handle_mut_drop(entry.handle_ref[])
        entry.handle_ref[] = _IOX2_NULL
    end
    return nothing
end

mutable struct EntryValueUninit{K,V}
    handle_ref::Base.RefValue{Iceoryx2FFI.iox2_entry_value_uninit_h}
    storage::Base.RefValue{Iceoryx2FFI.iox2_entry_value_uninit_t}
    keepalive::Writer{K}
    function EntryValueUninit{K,V}(handle_ref, storage, keepalive) where {K,V}
        obj = new{K,V}(handle_ref, storage, keepalive)
        finalizer(_finalize_entry_value_uninit, obj)
        return obj
    end
end

function EntryValueUninit{K,V}(writer::Writer{K}) where {K,V}
    return EntryValueUninit{K,V}(Ref{Iceoryx2FFI.iox2_entry_value_uninit_h}(_IOX2_NULL), Ref{Iceoryx2FFI.iox2_entry_value_uninit_t}(), writer)
end

EntryValueUninit(writer::Writer{K}, ::Type{V}) where {K,V} = EntryValueUninit{K,V}(writer)
EntryValueUninit(entry::EntryHandleMut{K,V}) where {K,V} = EntryValueUninit{K,V}(entry.keepalive)

@inline _slice_mutable(::Type{<:EntryValueUninit}) = true

function _finalize_entry_value_uninit(value::EntryValueUninit)
    if value.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_entry_value_uninit_drop(value.handle_ref[])
        value.handle_ref[] = _IOX2_NULL
    end
    return nothing
end

function loan_uninit!(entry::EntryHandleMut{K,V}, value::EntryValueUninit{K,V}) where {K,V}
    _require_valid(entry.handle_ref[], "entry handle mut")
    _require_inactive(value, "entry value")
    value.handle_ref[] = _IOX2_NULL
    size = Iceoryx2FFI.c_size_t(sizeof(V))
    alignment = Iceoryx2FFI.c_size_t(Base.datatype_alignment(V))
    Iceoryx2FFI.iox2_entry_handle_mut_loan_uninit(entry.handle_ref[], value.storage, value.handle_ref, size, alignment)
    entry.handle_ref[] = _IOX2_NULL
    value.keepalive = entry.keepalive
    return value
end

function loan_uninit!(f::Function, entry::EntryHandleMut{K,V}, value::EntryValueUninit{K,V}) where {K,V}
    loan_uninit!(entry, value)
    try
        return f(value)
    finally
        isvalid(value) && close(value)
    end
end

@inline function value_mut(value::EntryValueUninit{K,V}) where {K,V}
    ptr_ref = Ref{Ptr{Cvoid}}()
    Iceoryx2FFI.iox2_entry_value_uninit_value_mut(
        value.handle_ref,
        ptr_ref,
    )
    return Ptr{V}(ptr_ref[])
end

function update!(value::EntryValueUninit{K,V}, entry::EntryHandleMut{K,V}) where {K,V}
    _require_inactive(entry, "entry handle mut")
    entry.handle_ref[] = _IOX2_NULL
    Iceoryx2FFI.iox2_entry_value_uninit_update(value.handle_ref[], entry.storage, entry.handle_ref)
    value.handle_ref[] = _IOX2_NULL
    entry.keepalive = value.keepalive
    return entry
end

function discard!(value::EntryValueUninit{K,V}, entry::EntryHandleMut{K,V}) where {K,V}
    _require_inactive(entry, "entry handle mut")
    entry.handle_ref[] = _IOX2_NULL
    Iceoryx2FFI.iox2_entry_value_uninit_discard(value.handle_ref[], entry.storage, entry.handle_ref)
    value.handle_ref[] = _IOX2_NULL
    entry.keepalive = value.keepalive
    return entry
end

function reader_entry!(reader::Reader{K}, entry::EntryHandle{K,V}, key::K) where {K,V}
    _require_valid(reader.handle, "reader")
    _require_isbits(K)
    _require_isbits(V)
    _require_inactive(entry, "entry handle")
    entry.handle_ref[] = _IOX2_NULL
    key_ref = Ref{K}(key)
    name, name_len, size, alignment = _type_details(V)
    GC.@preserve key_ref name begin
        ret = Iceoryx2FFI.iox2_reader_entry(
            Ref{Iceoryx2FFI.iox2_reader_h}(reader.handle),
            entry.storage,
            entry.handle_ref,
            Base.unsafe_convert(Ptr{Cvoid}, key_ref),
            Base.unsafe_convert(Cstring, name),
            name_len,
            size,
            alignment,
        )
        check_ok(ret, Iceoryx2FFI.iox2_entry_handle_error_e)
    end
    entry.keepalive = reader
    return entry
end

function reader_entry!(f::Function, reader::Reader{K}, entry::EntryHandle{K,V}, key::K) where {K,V}
    reader_entry!(reader, entry, key)
    try
        return f(entry)
    finally
        close(entry)
    end
end

function try_reader_entry!(reader::Reader{K}, entry::EntryHandle{K,V}, key::K) where {K,V}
    _require_valid(reader.handle, "reader")
    _require_isbits(K)
    _require_isbits(V)
    _require_inactive(entry, "entry handle")
    entry.handle_ref[] = _IOX2_NULL
    key_ref = Ref{K}(key)
    name, name_len, size, alignment = _type_details(V)
    GC.@preserve key_ref name begin
        ret = Iceoryx2FFI.iox2_reader_entry(
            Ref{Iceoryx2FFI.iox2_reader_h}(reader.handle),
            entry.storage,
            entry.handle_ref,
            Base.unsafe_convert(Ptr{Cvoid}, key_ref),
            Base.unsafe_convert(Cstring, name),
            name_len,
            size,
            alignment,
        )
        err = Iceoryx2FFI.iox2_entry_handle_error_e(ret)
        if err == Iceoryx2FFI.iox2_entry_handle_error_e_ENTRY_DOES_NOT_EXIST
            return false
        end
        check_ok(ret, Iceoryx2FFI.iox2_entry_handle_error_e)
    end
    entry.keepalive = reader
    return true
end

function try_reader_entry!(f::Function, reader::Reader{K}, entry::EntryHandle{K,V}, key::K) where {K,V}
    try_reader_entry!(reader, entry, key) || return nothing
    try
        return f(entry)
    finally
        close(entry)
    end
end

function writer_entry!(writer::Writer{K}, entry::EntryHandleMut{K,V}, key::K) where {K,V}
    _require_valid(writer.handle, "writer")
    _require_isbits(K)
    _require_isbits(V)
    _require_inactive(entry, "entry handle mut")
    entry.handle_ref[] = _IOX2_NULL
    key_ref = Ref{K}(key)
    name, name_len, size, alignment = _type_details(V)
    GC.@preserve key_ref name begin
        ret = Iceoryx2FFI.iox2_writer_entry(
            Ref{Iceoryx2FFI.iox2_writer_h}(writer.handle),
            entry.storage,
            entry.handle_ref,
            Base.unsafe_convert(Ptr{Cvoid}, key_ref),
            Base.unsafe_convert(Cstring, name),
            name_len,
            size,
            alignment,
        )
        check_ok(ret, Iceoryx2FFI.iox2_entry_handle_mut_error_e)
    end
    entry.keepalive = writer
    return entry
end

function writer_entry!(f::Function, writer::Writer{K}, entry::EntryHandleMut{K,V}, key::K) where {K,V}
    writer_entry!(writer, entry, key)
    try
        return f(entry)
    finally
        close(entry)
    end
end

function try_writer_entry!(writer::Writer{K}, entry::EntryHandleMut{K,V}, key::K) where {K,V}
    _require_valid(writer.handle, "writer")
    _require_isbits(K)
    _require_isbits(V)
    _require_inactive(entry, "entry handle mut")
    entry.handle_ref[] = _IOX2_NULL
    key_ref = Ref{K}(key)
    name, name_len, size, alignment = _type_details(V)
    GC.@preserve key_ref name begin
        ret = Iceoryx2FFI.iox2_writer_entry(
            Ref{Iceoryx2FFI.iox2_writer_h}(writer.handle),
            entry.storage,
            entry.handle_ref,
            Base.unsafe_convert(Ptr{Cvoid}, key_ref),
            Base.unsafe_convert(Cstring, name),
            name_len,
            size,
            alignment,
        )
        err = Iceoryx2FFI.iox2_entry_handle_mut_error_e(ret)
        if err == Iceoryx2FFI.iox2_entry_handle_mut_error_e_ENTRY_DOES_NOT_EXIST
            return false
        end
        check_ok(ret, Iceoryx2FFI.iox2_entry_handle_mut_error_e)
    end
    entry.keepalive = writer
    return true
end

function try_writer_entry!(f::Function, writer::Writer{K}, entry::EntryHandleMut{K,V}, key::K) where {K,V}
    try_writer_entry!(writer, entry, key) || return nothing
    try
        return f(entry)
    finally
        close(entry)
    end
end

@inline function entry_id(entry::EntryHandle)
    id_ref = Ref{Iceoryx2FFI.iox2_event_id_t}()
    Iceoryx2FFI.iox2_entry_handle_entry_id(entry.handle_ref, id_ref)
    return EventId(id_ref[])
end

@inline function entry_id(entry::EntryHandleMut)
    id_ref = Ref{Iceoryx2FFI.iox2_event_id_t}()
    Iceoryx2FFI.iox2_entry_handle_mut_entry_id(entry.handle_ref, id_ref)
    return EventId(id_ref[])
end

function get!(entry::EntryHandle{K,V}, value_ref::Base.RefValue{V}, generation_ref::Base.RefValue{UInt64}) where {K,V}
    size = Iceoryx2FFI.c_size_t(sizeof(V))
    alignment = Iceoryx2FFI.c_size_t(Base.datatype_alignment(V))
    GC.@preserve value_ref generation_ref begin
        Iceoryx2FFI.iox2_entry_handle_get(
            entry.handle_ref,
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
        entry.handle_ref,
        generation_counter,
    )
end

function update!(entry::EntryHandleMut{K,V}, value_ref::Base.RefValue{V}) where {K,V}
    size = Iceoryx2FFI.c_size_t(sizeof(V))
    alignment = Iceoryx2FFI.c_size_t(Base.datatype_alignment(V))
    GC.@preserve value_ref begin
        Iceoryx2FFI.iox2_entry_handle_mut_update_with_copy(
            entry.handle_ref,
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

@inline update_with_copy(entry::EntryHandleMut{K,V}, value_ref::Base.RefValue{V}) where {K,V} = update!(entry, value_ref)
@inline update_with_copy(entry::EntryHandleMut{K,V}, value::V) where {K,V} = update!(entry, value)

@inline Base.isvalid(obj::PortFactoryPubSub) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::Publisher) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::Subscriber) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::Sample) = obj.handle_ref[] != _IOX2_NULL
@inline Base.isvalid(obj::SampleMut) = obj.handle_ref[] != _IOX2_NULL
@inline Base.isvalid(obj::PortFactoryRequestResponse) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::Client) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::Server) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::RequestMut) = obj.handle_ref[] != _IOX2_NULL
@inline Base.isvalid(obj::PendingResponse) = obj.handle_ref[] != _IOX2_NULL
@inline Base.isvalid(obj::Response) = obj.handle_ref[] != _IOX2_NULL
@inline Base.isvalid(obj::ActiveRequest) = obj.handle_ref[] != _IOX2_NULL
@inline Base.isvalid(obj::ResponseMut) = obj.handle_ref[] != _IOX2_NULL
@inline Base.isvalid(obj::PortFactoryEvent) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::Notifier) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::Listener) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::PortFactoryBlackboard) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::Writer) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::Reader) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::EntryHandle) = obj.handle_ref[] != _IOX2_NULL
@inline Base.isvalid(obj::EntryHandleMut) = obj.handle_ref[] != _IOX2_NULL
@inline Base.isvalid(obj::EntryValueUninit) = obj.handle_ref[] != _IOX2_NULL

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
