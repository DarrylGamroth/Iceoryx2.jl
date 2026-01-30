# === Publish/Subscribe ===

function _set_payload_type!(
    builder::PubSubServiceBuilder{T},
    ::Type{T},
    variant::Iceoryx2FFI.iox2_type_variant_e,
) where {T}
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

function payload_alignment!(builder::PubSubServiceBuilder, alignment::Integer)
    alignment > 0 || throw(ArgumentError("payload alignment must be positive, got $alignment"))
    Iceoryx2FFI.iox2_service_builder_pub_sub_set_payload_alignment(
        Ref{Iceoryx2FFI.iox2_service_builder_pub_sub_h}(builder.handle),
        Iceoryx2FFI.c_size_t(alignment),
    )
    return builder
end

function user_header(builder::PubSubServiceBuilder{T,Nothing}, ::Type{UH}) where {T,UH}
    _require_valid(builder.handle, "publish_subscribe service builder")
    variant = _variant_type(UH)
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
    builder.handle = _IOX2_NULL
    builder.storage = Ref{Iceoryx2FFI.iox2_service_builder_t}()
    return PubSubServiceBuilder{T,header_type}(handle, storage, builder.keepalive)
end

function user_header(builder::PubSubServiceBuilder{T,UH}, ::Type{UH}) where {T,UH}
    _require_valid(builder.handle, "publish_subscribe service builder")
    return builder
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
    header_slot::HeaderSlot{
        Iceoryx2FFI.iox2_publish_subscribe_header_t,
        Iceoryx2FFI.iox2_publish_subscribe_header_h,
        Val{:pub},
    }
    function Sample{T,UH}(handle_ref, storage, header_slot) where {T,UH}
        obj = new{T,UH}(handle_ref, storage, header_slot)
        finalizer(_finalize_sample, obj)
        return obj
    end
end

function Sample{T,UH}() where {T,UH}
    return Sample{T,UH}(
        Ref{Iceoryx2FFI.iox2_sample_h}(_IOX2_NULL),
        Ref{Iceoryx2FFI.iox2_sample_t}(),
        HeaderSlot{
            Iceoryx2FFI.iox2_publish_subscribe_header_t,
            Iceoryx2FFI.iox2_publish_subscribe_header_h,
            Val{:pub},
        }(),
    )
end

Sample(subscriber::Subscriber{T,UH}) where {T,UH} = Sample{T,UH}()

function _finalize_sample(sample::Sample)
    _drop_header!(sample.header_slot)
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
    header_slot::HeaderSlot{
        Iceoryx2FFI.iox2_publish_subscribe_header_t,
        Iceoryx2FFI.iox2_publish_subscribe_header_h,
        Val{:pub},
    }
    function SampleMut{T,UH}(handle_ref, storage, header_slot) where {T,UH}
        obj = new{T,UH}(handle_ref, storage, header_slot)
        finalizer(_finalize_sample_mut, obj)
        return obj
    end
end

function SampleMut{T,UH}() where {T,UH}
    return SampleMut{T,UH}(
        Ref{Iceoryx2FFI.iox2_sample_mut_h}(_IOX2_NULL),
        Ref{Iceoryx2FFI.iox2_sample_mut_t}(),
        HeaderSlot{
            Iceoryx2FFI.iox2_publish_subscribe_header_t,
            Iceoryx2FFI.iox2_publish_subscribe_header_h,
            Val{:pub},
        }(),
    )
end

SampleMut(publisher::Publisher{T,UH}) where {T,UH} = SampleMut{T,UH}()

@inline _slice_mutable(::Type{<:SampleMut}) = true

function _finalize_sample_mut(sample::SampleMut)
    _drop_header!(sample.header_slot)
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

function try_loan_slice_uninit!(publisher::Publisher{T,UH}, sample::SampleMut{T,UH}, n::Integer) where {T,UH}
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

@inline function loan_uninit!(publisher::Publisher{T,UH}, sample::SampleMut{T,UH}) where {T,UH}
    return loan_slice_uninit!(publisher, sample, 1)
end

@inline function try_loan_uninit!(publisher::Publisher{T,UH}, sample::SampleMut{T,UH}) where {T,UH}
    return try_loan_slice_uninit!(publisher, sample, 1)
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

@inline function send!(sample::SampleMut)
    ret = Iceoryx2FFI.iox2_sample_mut_send(sample.handle_ref[], C_NULL)
    check_ok(ret, Iceoryx2FFI.iox2_send_error_e)
    _drop_header!(sample.header_slot)
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

