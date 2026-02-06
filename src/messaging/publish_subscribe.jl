# === Publish/Subscribe ===

function _set_payload_type!(
    builder::PubSubServiceBuilder{S,T},
    ::Type{T},
    variant::Iceoryx2FFI.iox2_type_variant_e,
) where {S,T}
    _require_valid(builder.handle, "publish_subscribe service builder")
    _require_isbits(T)
    name, name_len, size, alignment = _type_details(T)
    GC.@preserve name begin
        ret = Iceoryx2FFI.iox2_service_builder_pub_sub_set_payload_type_details(
            Ref{Iceoryx2FFI.iox2_service_builder_pub_sub_h}(builder.handle),
            variant,
            Base.unsafe_convert(Cstring, name),
            name_len,
            size,
            alignment,
        )
        check_ok(ret, Iceoryx2FFI.iox2_type_detail_error_e)
    end
    return builder
end

"""
    payload_alignment!(builder::PubSubServiceBuilder, alignment)

Override payload alignment for the publish/subscribe service.
"""
function payload_alignment!(builder::PubSubServiceBuilder, alignment::Integer)
    alignment > 0 || throw(ArgumentError("payload alignment must be positive, got $alignment"))
    Iceoryx2FFI.iox2_service_builder_pub_sub_set_payload_alignment(
        Ref{Iceoryx2FFI.iox2_service_builder_pub_sub_h}(builder.handle),
        Iceoryx2FFI.c_size_t(alignment),
    )
    return builder
end

"""
    user_header(builder::PubSubServiceBuilder, ::Type{UH}) -> PubSubServiceBuilder

Set the user header type for the service builder.
"""
function user_header(builder::PubSubServiceBuilder{S,T,Nothing}, ::Type{UH}) where {S,T,UH}
    _require_valid(builder.handle, "publish_subscribe service builder")
    variant = _fixed_header_variant(UH, "user header type")
    header_type = _payload_type(UH)
    name, name_len, size, alignment = _type_details(header_type)
    GC.@preserve name begin
        ret = Iceoryx2FFI.iox2_service_builder_pub_sub_set_user_header_type_details(
            Ref{Iceoryx2FFI.iox2_service_builder_pub_sub_h}(builder.handle),
            variant,
            Base.unsafe_convert(Cstring, name),
            name_len,
            size,
            alignment,
        )
        check_ok(ret, Iceoryx2FFI.iox2_type_detail_error_e)
    end
    handle = builder.handle
    storage = builder.storage
    close(builder)
    return PubSubServiceBuilder{S,T,header_type}(handle, storage, builder.keepalive)
end

function user_header(builder::PubSubServiceBuilder{S,T,UH}, ::Type{UH}) where {S,T,UH}
    _require_valid(builder.handle, "publish_subscribe service builder")
    return builder
end

### builder tuning setters generated in src/generated/wrappers.jl

"""
    PortFactoryPubSub{S,T,UH}

Factory for publishers and subscribers bound to a publish/subscribe service.
Created via `open`, `create`, or `open_or_create`.
"""
mutable struct PortFactoryPubSub{S,T,UH}
    handle::Iceoryx2FFI.iox2_port_factory_pub_sub_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_pub_sub_t}
    keepalive::Node{S}
    function PortFactoryPubSub{S,T,UH}(handle, storage, keepalive) where {S,T,UH}
        obj = new{S,T,UH}(handle, storage, keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

function Base.close(factory::PortFactoryPubSub)
    if factory.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_port_factory_pub_sub_drop(factory.handle)
        factory.handle = _IOX2_NULL
    end
    factory.storage = nothing
    return nothing
end

"""
    open_or_create(builder::PubSubServiceBuilder[, verifier]) -> PortFactoryPubSub

Open an existing publish/subscribe service or create it if missing.
"""
function open_or_create(builder::PubSubServiceBuilder{S,T,UH}) where {S,T,UH}
    _require_valid(builder.handle, "publish_subscribe service builder")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_pub_sub_open_or_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_pub_sub_open_or_create_error_e)
    close(builder)
    return PortFactoryPubSub{S,T,UH}(handle_ref[], storage, builder.keepalive)
end

function open_or_create(builder::PubSubServiceBuilder{S,T,UH}, verifier::AttributeVerifier) where {S,T,UH}
    _require_valid(builder.handle, "publish_subscribe service builder")
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
    close(builder)
    return PortFactoryPubSub{S,T,UH}(handle_ref[], storage, builder.keepalive)
end

"""
    open(builder::PubSubServiceBuilder[, verifier]) -> PortFactoryPubSub

Open an existing publish/subscribe service.
"""
function open(builder::PubSubServiceBuilder{S,T,UH}) where {S,T,UH}
    _require_valid(builder.handle, "publish_subscribe service builder")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_pub_sub_open(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_pub_sub_open_or_create_error_e)
    close(builder)
    return PortFactoryPubSub{S,T,UH}(handle_ref[], storage, builder.keepalive)
end

function open(builder::PubSubServiceBuilder{S,T,UH}, verifier::AttributeVerifier) where {S,T,UH}
    _require_valid(builder.handle, "publish_subscribe service builder")
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
    close(builder)
    return PortFactoryPubSub{S,T,UH}(handle_ref[], storage, builder.keepalive)
end

"""
    create(builder::PubSubServiceBuilder[, specifier]) -> PortFactoryPubSub

Create a new publish/subscribe service.
"""
function create(builder::PubSubServiceBuilder{S,T,UH}) where {S,T,UH}
    _require_valid(builder.handle, "publish_subscribe service builder")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_pub_sub_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_pub_sub_open_or_create_error_e)
    close(builder)
    return PortFactoryPubSub{S,T,UH}(handle_ref[], storage, builder.keepalive)
end

function create(builder::PubSubServiceBuilder{S,T,UH}, specifier::AttributeSpecifier) where {S,T,UH}
    _require_valid(builder.handle, "publish_subscribe service builder")
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
    close(builder)
    return PortFactoryPubSub{S,T,UH}(handle_ref[], storage, builder.keepalive)
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

function open(f::Function, builder::PubSubServiceBuilder{S,T,UH}) where {S,T,UH}
    factory = open(builder)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function open(f::Function, builder::PubSubServiceBuilder{S,T,UH}, verifier::AttributeVerifier) where {S,T,UH}
    factory = open(builder, verifier)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function create(f::Function, builder::PubSubServiceBuilder{S,T,UH}) where {S,T,UH}
    factory = create(builder)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function create(f::Function, builder::PubSubServiceBuilder{S,T,UH}, specifier::AttributeSpecifier) where {S,T,UH}
    factory = create(builder, specifier)
    try
        return f(factory)
    finally
        close(factory)
    end
end

open_or_create_with_attributes(builder::PubSubServiceBuilder{S,T,UH}, verifier::AttributeVerifier) where {S,T,UH} = open_or_create(builder, verifier)
open_or_create_with_attributes(f::Function, builder::PubSubServiceBuilder{S,T,UH}, verifier::AttributeVerifier) where {S,T,UH} = open_or_create(f, builder, verifier)
open_with_attributes(builder::PubSubServiceBuilder{S,T,UH}, verifier::AttributeVerifier) where {S,T,UH} = open(builder, verifier)
open_with_attributes(f::Function, builder::PubSubServiceBuilder{S,T,UH}, verifier::AttributeVerifier) where {S,T,UH} = open(f, builder, verifier)
create_with_attributes(builder::PubSubServiceBuilder{S,T,UH}, specifier::AttributeSpecifier) where {S,T,UH} = create(builder, specifier)
create_with_attributes(f::Function, builder::PubSubServiceBuilder{S,T,UH}, specifier::AttributeSpecifier) where {S,T,UH} = create(f, builder, specifier)

"""
    PublisherBuilder{S,T,UH}

Builder for `Publisher{S,T,UH}` created from a publish/subscribe factory.
"""
mutable struct PublisherBuilder{S,T,UH}
    handle::Iceoryx2FFI.iox2_port_factory_publisher_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_publisher_builder_t}
    keepalive::PortFactoryPubSub{S,T,UH}
    function PublisherBuilder{S,T,UH}(handle, storage, keepalive) where {S,T,UH}
        obj = new{S,T,UH}(handle, storage, keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

function Base.close(builder::PublisherBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

"""
    publisher_builder(factory::PortFactoryPubSub) -> PublisherBuilder

Create a publisher builder from a publish/subscribe factory.
"""
function publisher_builder(factory::PortFactoryPubSub{S,T,UH}) where {S,T,UH}
    _require_valid(factory.handle, "publish_subscribe port factory")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_publisher_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_pub_sub_publisher_builder(Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_h}(factory.handle), storage)
    return PublisherBuilder{S,T,UH}(handle, storage, factory)
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

"""
    SubscriberBuilder{S,T,UH}

Builder for `Subscriber{S,T,UH}` created from a publish/subscribe factory.
"""
mutable struct SubscriberBuilder{S,T,UH}
    handle::Iceoryx2FFI.iox2_port_factory_subscriber_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_subscriber_builder_t}
    keepalive::PortFactoryPubSub{S,T,UH}
    function SubscriberBuilder{S,T,UH}(handle, storage, keepalive) where {S,T,UH}
        obj = new{S,T,UH}(handle, storage, keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

function Base.close(builder::SubscriberBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

"""
    subscriber_builder(factory::PortFactoryPubSub) -> SubscriberBuilder

Create a subscriber builder from a publish/subscribe factory.
"""
function subscriber_builder(factory::PortFactoryPubSub{S,T,UH}) where {S,T,UH}
    _require_valid(factory.handle, "publish_subscribe port factory")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_subscriber_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_pub_sub_subscriber_builder(Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_h}(factory.handle), storage)
    return SubscriberBuilder{S,T,UH}(handle, storage, factory)
end

"""
    Publisher{S,T,UH}

Publish samples for a publish/subscribe service.
"""
mutable struct Publisher{S,T,UH}
    handle::Iceoryx2FFI.iox2_publisher_h
    storage::_StorageRef{Iceoryx2FFI.iox2_publisher_t}
    keepalive::PortFactoryPubSub{S,T,UH}
    function Publisher{S,T,UH}(handle, storage, keepalive) where {S,T,UH}
        obj = new{S,T,UH}(handle, storage, keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

function Base.close(pub::Publisher)
    if pub.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_publisher_drop(pub.handle)
        pub.handle = _IOX2_NULL
    end
    pub.storage = nothing
    return nothing
end

"""
    create(builder::PublisherBuilder) -> Publisher

Create a publisher and consume the builder.
"""
function create(builder::PublisherBuilder{S,T,UH}) where {S,T,UH}
    _require_valid(builder.handle, "publisher builder")
    storage = Ref{Iceoryx2FFI.iox2_publisher_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_publisher_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_publisher_builder_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_publisher_create_error_e)
    close(builder)
    return Publisher{S,T,UH}(handle_ref[], storage, builder.keepalive)
end

"""
    create(f::Function, builder::PublisherBuilder)

Create a publisher, call `f(pub)`, and close it in a `finally` block.
"""
function create(f::Function, builder::PublisherBuilder{S,T,UH}) where {S,T,UH}
    pub = create(builder)
    try
        return f(pub)
    finally
        close(pub)
    end
end

"""
    Subscriber{S,T,UH}

Receive samples for a publish/subscribe service.
"""
mutable struct Subscriber{S,T,UH}
    handle::Iceoryx2FFI.iox2_subscriber_h
    storage::_StorageRef{Iceoryx2FFI.iox2_subscriber_t}
    keepalive::PortFactoryPubSub{S,T,UH}
    function Subscriber{S,T,UH}(handle, storage, keepalive) where {S,T,UH}
        obj = new{S,T,UH}(handle, storage, keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

function Base.close(sub::Subscriber)
    if sub.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_subscriber_drop(sub.handle)
        sub.handle = _IOX2_NULL
    end
    sub.storage = nothing
    return nothing
end

"""
    create(builder::SubscriberBuilder) -> Subscriber

Create a subscriber and consume the builder.
"""
function create(builder::SubscriberBuilder{S,T,UH}) where {S,T,UH}
    _require_valid(builder.handle, "subscriber builder")
    storage = Ref{Iceoryx2FFI.iox2_subscriber_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_subscriber_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_subscriber_builder_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_subscriber_create_error_e)
    close(builder)
    return Subscriber{S,T,UH}(handle_ref[], storage, builder.keepalive)
end

"""
    create(f::Function, builder::SubscriberBuilder)

Create a subscriber, call `f(sub)`, and close it in a `finally` block.
"""
function create(f::Function, builder::SubscriberBuilder{S,T,UH}) where {S,T,UH}
    sub = create(builder)
    try
        return f(sub)
    finally
        close(sub)
    end
end

"""
    Sample{T,UH}

Reusable receive buffer for publish/subscribe. Call `receive!` to populate and
`close` when done to release the loan.
"""
mutable struct Sample{T,UH}
    handle_ref::Base.RefValue{Iceoryx2FFI.iox2_sample_h}
    storage::Base.RefValue{Iceoryx2FFI.iox2_sample_t}
    header_slot::HeaderSlot{
        Iceoryx2FFI.iox2_publish_subscribe_header_t,
        Iceoryx2FFI.iox2_publish_subscribe_header_h,
    }
    function Sample{T,UH}(handle_ref, storage, header_slot) where {T,UH}
        obj = new{T,UH}(handle_ref, storage, header_slot)
        finalizer(Base.close, obj)
        return obj
    end
end

"""
    Sample{T,UH}() -> Sample

Create an empty reusable sample buffer.
"""
function Sample{T,UH}() where {T,UH}
    return Sample{T,UH}(
        Ref{Iceoryx2FFI.iox2_sample_h}(_IOX2_NULL),
        Ref{Iceoryx2FFI.iox2_sample_t}(),
        HeaderSlot{
            Iceoryx2FFI.iox2_publish_subscribe_header_t,
            Iceoryx2FFI.iox2_publish_subscribe_header_h,
        }(),
    )
end

Sample(subscriber::Subscriber{S,T,UH}) where {S,T,UH} = Sample{T,UH}()

function Base.close(sample::Sample)
    _drop_header!(sample.header_slot)
    if sample.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_sample_drop(sample.handle_ref[])
        sample.handle_ref[] = _IOX2_NULL
    end
    return nothing
end

"""
    payload(sample::Sample) -> Slice

Return a zero-copy view of the sample payload.
"""
@inline function payload(sample::Sample{T,UH}) where {T,UH}
    ptr_ref = Ref{Ptr{Cvoid}}()
    len_ref = Ref{Iceoryx2FFI.c_size_t}()
    Iceoryx2FFI.iox2_sample_payload(sample.handle_ref, ptr_ref, len_ref)
    return Slice{T}(Ptr{T}(ptr_ref[]), Int(len_ref[]), sample)
end

"""
    unsafe_payload_ptr(sample::Sample) -> Ptr

Return a raw pointer to the payload (unsafe).
"""
@inline function unsafe_payload_ptr(sample::Sample{T,UH}) where {T,UH}
    return payload(sample).ptr
end

"""
    header(sample::Sample) -> PublishSubscribeHeaderRef

Return a view of the publish/subscribe header.
"""
@inline function header(sample::Sample)
    _require_valid(sample.handle_ref[], "sample")
    slot = sample.header_slot
    _drop_header!(slot)
    Iceoryx2FFI.iox2_sample_header(sample.handle_ref, slot.storage, slot.handle_ref)
    slot.handle_ref[] != _IOX2_NULL || throw(ErrorException("failed to acquire sample header"))
    header_ref = Base.unsafe_convert(Iceoryx2FFI.iox2_publish_subscribe_header_h_ref, slot.handle_ref)
    return PublishSubscribeHeaderRef(header_ref)
end

@inline function unsafe_user_header_ptr(sample::Sample, ::Type{T}) where {T}
    _require_isbits(T)
    ptr_ref = Ref{Ptr{Cvoid}}()
    Iceoryx2FFI.iox2_sample_user_header(sample.handle_ref, ptr_ref)
    return Ptr{T}(ptr_ref[])
end

"""
    user_header(sample::Sample)
    user_header(sample::Sample, ::Type{UH})

Return a zero-copy view of the user header if present.
"""
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


"""
    SampleMut{T,UH}

Reusable mutable sample for publishers. Call `loan*` to acquire and `send!` to
publish.
"""
mutable struct SampleMut{T,UH}
    handle_ref::Base.RefValue{Iceoryx2FFI.iox2_sample_mut_h}
    storage::Base.RefValue{Iceoryx2FFI.iox2_sample_mut_t}
    header_slot::HeaderSlot{
        Iceoryx2FFI.iox2_publish_subscribe_header_t,
        Iceoryx2FFI.iox2_publish_subscribe_header_h,
    }
    function SampleMut{T,UH}(handle_ref, storage, header_slot) where {T,UH}
        obj = new{T,UH}(handle_ref, storage, header_slot)
        finalizer(Base.close, obj)
        return obj
    end
end

"""
    SampleMut{T,UH}() -> SampleMut

Create an empty mutable sample buffer for publishing.
"""
function SampleMut{T,UH}() where {T,UH}
    return SampleMut{T,UH}(
        Ref{Iceoryx2FFI.iox2_sample_mut_h}(_IOX2_NULL),
        Ref{Iceoryx2FFI.iox2_sample_mut_t}(),
        HeaderSlot{
            Iceoryx2FFI.iox2_publish_subscribe_header_t,
            Iceoryx2FFI.iox2_publish_subscribe_header_h,
        }(),
    )
end

SampleMut(publisher::Publisher{S,T,UH}) where {S,T,UH} = SampleMut{T,UH}()

@inline _slice_mutable(::Type{<:SampleMut}) = true

function Base.close(sample::SampleMut)
    _drop_header!(sample.header_slot)
    if sample.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_sample_mut_drop(sample.handle_ref[])
        sample.handle_ref[] = _IOX2_NULL
    end
    return nothing
end

"""
    payload_mut(sample::SampleMut) -> Slice

Return a zero-copy mutable view of the payload.
"""
@inline function payload_mut(sample::SampleMut{T,UH}) where {T,UH}
    ptr_ref = Ref{Ptr{Cvoid}}()
    len_ref = Ref{Iceoryx2FFI.c_size_t}()
    Iceoryx2FFI.iox2_sample_mut_payload_mut(sample.handle_ref, ptr_ref, len_ref)
    return Slice{T}(Ptr{T}(ptr_ref[]), Int(len_ref[]), sample)
end

"""
    unsafe_payload_mut_ptr(sample::SampleMut) -> Ptr

Return a raw mutable pointer to the payload (unsafe).
"""
@inline function unsafe_payload_mut_ptr(sample::SampleMut{T,UH}) where {T,UH}
    return payload_mut(sample).ptr
end

"""
    header(sample::SampleMut) -> PublishSubscribeHeaderRef

Return a view of the publish/subscribe header.
"""
@inline function header(sample::SampleMut)
    _require_valid(sample.handle_ref[], "sample")
    slot = sample.header_slot
    _drop_header!(slot)
    Iceoryx2FFI.iox2_sample_mut_header(sample.handle_ref, slot.storage, slot.handle_ref)
    slot.handle_ref[] != _IOX2_NULL || throw(ErrorException("failed to acquire sample header"))
    header_ref = Base.unsafe_convert(Iceoryx2FFI.iox2_publish_subscribe_header_h_ref, slot.handle_ref)
    return PublishSubscribeHeaderRef(header_ref)
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

"""
    user_header(sample::SampleMut)
    user_header(sample::SampleMut, ::Type{UH})
    user_header_mut(sample::SampleMut)
    user_header_mut(sample::SampleMut, ::Type{UH})

Return a zero-copy (mutable) view of the user header.
"""
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

@inline _pubsub_header_ref(header::PublishSubscribeHeader) =
    Ref{Iceoryx2FFI.iox2_publish_subscribe_header_h}(unsafe_handle(header))
@inline _pubsub_header_ref(header::PublishSubscribeHeaderRef) = unsafe_handle(header)

@inline function publisher_id(header::Union{PublishSubscribeHeader, PublishSubscribeHeaderRef})
    handle_ref = Ref{Iceoryx2FFI.iox2_unique_publisher_id_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_publish_subscribe_header_publisher_id(
        _pubsub_header_ref(header),
        C_NULL,
        handle_ref,
    )
    return UniquePublisherId(handle_ref[])
end

@inline function number_of_elements(header::Union{PublishSubscribeHeader, PublishSubscribeHeaderRef})
    return Int(
        Iceoryx2FFI.iox2_publish_subscribe_header_number_of_elements(
            _pubsub_header_ref(header),
        ),
    )
end


"""
    loan_slice_uninit!(publisher, sample, n)

Loan an uninitialized slice of length `n` into `sample`.
"""
function loan_slice_uninit!(publisher::Publisher{S,T,UH}, sample::SampleMut{T,UH}, n::Integer) where {S,T,UH}
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

"""
    try_loan_slice_uninit!(publisher, sample, n) -> Bool

Try to loan an uninitialized slice. Returns `false` if no loan is available.
"""
function try_loan_slice_uninit!(publisher::Publisher{S,T,UH}, sample::SampleMut{T,UH}, n::Integer) where {S,T,UH}
    _require_valid(publisher.handle, "publisher")
    _require_inactive(sample, "sample")
    sample.handle_ref[] = _IOX2_NULL
    ret = Iceoryx2FFI.iox2_publisher_loan_slice_uninit(
        Ref{Iceoryx2FFI.iox2_publisher_h}(publisher.handle),
        sample.storage,
        sample.handle_ref,
        Iceoryx2FFI.c_size_t(n),
    )
    ret == Iceoryx2FFI.iox2_loan_error_e_EXCEEDS_MAX_LOANED_SAMPLES && return false
    check_ok(ret, Iceoryx2FFI.iox2_loan_error_e)
    return true
end

"""
    loan_uninit!(publisher, sample)

Loan an uninitialized single sample into `sample`.
"""
@inline function loan_uninit!(publisher::Publisher{S,T,UH}, sample::SampleMut{T,UH}) where {S,T,UH}
    return loan_slice_uninit!(publisher, sample, 1)
end

"""
    try_loan_uninit!(publisher, sample) -> Bool

Try to loan an uninitialized sample. Returns `false` if no loan is available.
"""
@inline function try_loan_uninit!(publisher::Publisher{S,T,UH}, sample::SampleMut{T,UH}) where {S,T,UH}
    return try_loan_slice_uninit!(publisher, sample, 1)
end

"""
    loan!(publisher, sample)

Loan a sample and default-initialize the payload with `zero(T)`.
"""
function loan!(publisher::Publisher{S,T,UH}, sample::SampleMut{T,UH}) where {S,T,UH}
    loan_slice_uninit!(publisher, sample, 1)
    fill!(payload_mut(sample), _default_value(T))
    return sample
end

"""
    loan_slice!(publisher, sample, n)

Loan a slice and default-initialize the payload with `zero(T)`.
"""
function loan_slice!(publisher::Publisher{S,T,UH}, sample::SampleMut{T,UH}, n::Integer) where {S,T,UH}
    loan_slice_uninit!(publisher, sample, n)
    fill!(payload_mut(sample), _default_value(T))
    return sample
end

function loan_slice!(f::Function, publisher::Publisher{S,T,UH}, sample::SampleMut{T,UH}, n::Integer) where {S,T,UH}
    loan_slice!(publisher, sample, n)
    try
        return f(sample)
    finally
        close(sample)
    end
end

function loan_slice_uninit!(f::Function, publisher::Publisher{S,T,UH}, sample::SampleMut{T,UH}, n::Integer) where {S,T,UH}
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

"""
    send!(sample::SampleMut)

Send a loaned sample and invalidate its handle.
"""
@inline function send!(sample::SampleMut)
    ret = Iceoryx2FFI.iox2_sample_mut_send(sample.handle_ref[], C_NULL)
    check_ok(ret, Iceoryx2FFI.iox2_send_error_e)
    _drop_header!(sample.header_slot)
    sample.handle_ref[] = _IOX2_NULL
    return nothing
end

"""
    send_copy(publisher, data, n)
    send_copy(publisher, data::AbstractVector)
    send_copy(publisher, value::T)

Send by copying from an existing buffer or value.
"""
function send_copy(publisher::Publisher{S,T,UH}, data::Ptr{T}, n::Integer) where {S,T,UH}
    _require_valid(publisher.handle, "publisher")
    recipients = Ref{Iceoryx2FFI.c_size_t}()
    ret = Iceoryx2FFI.iox2_publisher_send_slice_copy(Ref{Iceoryx2FFI.iox2_publisher_h}(publisher.handle), data, Iceoryx2FFI.c_size_t(sizeof(T)), Iceoryx2FFI.c_size_t(n), recipients)
    check_ok(ret, Iceoryx2FFI.iox2_send_error_e)
    return Int(recipients[])
end

function send_copy(publisher::Publisher{S,T,UH}, data::AbstractVector{T}) where {S,T,UH}
    GC.@preserve data begin
        return send_copy(publisher, pointer(data), length(data))
    end
end

function send_copy(publisher::Publisher{S,T,UH}, value::T) where {S,T,UH}
    value_ref = Ref{T}(value)
    GC.@preserve value_ref begin
        return send_copy(publisher, Base.unsafe_convert(Ptr{T}, value_ref), 1)
    end
end

"""
    update_connections!(publisher::Publisher)

Update internal connection state (used by some event-based examples).
"""
function update_connections!(publisher::Publisher)
    _require_valid(publisher.handle, "publisher")
    ret = Iceoryx2FFI.iox2_publisher_update_connections(Ref{Iceoryx2FFI.iox2_publisher_h}(publisher.handle))
    check_ok(ret, Iceoryx2FFI.iox2_connection_failure_e)
    return nothing
end

"""
    receive!(subscriber, sample) -> Bool

Receive a sample into the reusable buffer. Returns `true` on success.
"""
function receive!(subscriber::Subscriber{S,T,UH}, sample::Sample{T,UH}) where {S,T,UH}
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

"""
    receive!(f::Function, subscriber, sample)

Receive into `sample`, call `f(sample)`, and always `close(sample)` afterward.
"""
function receive!(f::Function, subscriber::Subscriber{S,T,UH}, sample::Sample{T,UH}) where {S,T,UH}
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
