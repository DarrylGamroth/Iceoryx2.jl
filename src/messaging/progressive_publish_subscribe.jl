# === Progressive Publish/Subscribe ===

@enum ProgressiveSampleState::UInt32 begin
    ProgressiveSampleStateActive = UInt32(
        Iceoryx2FFI.iox2_progressive_sample_state_e_ACTIVE)
    ProgressiveSampleStateComplete = UInt32(
        Iceoryx2FFI.iox2_progressive_sample_state_e_COMPLETE)
    ProgressiveSampleStateAborted = UInt32(
        Iceoryx2FFI.iox2_progressive_sample_state_e_ABORTED)
end

"""
    ProgressiveSampleSnapshot

One atomically observed committed length and lifecycle state for a progressive
sample. Use `snapshot(sample)` when both values must describe the same instant.
"""
struct ProgressiveSampleSnapshot
    committed_len::Int
    state::ProgressiveSampleState
end

@inline function _progressive_sample_state(
        value::Iceoryx2FFI.iox2_progressive_sample_state_e)
    return ProgressiveSampleState(UInt32(value))
end

@inline function _progressive_sample_snapshot(
        value::Iceoryx2FFI.iox2_progressive_sample_snapshot_t)
    return ProgressiveSampleSnapshot(
        Int(value.committed_len), _progressive_sample_state(value.state))
end

@inline function _progressive_size(value::Integer, what::AbstractString)
    value >= 0 || throw(ArgumentError("$what must be nonnegative, got $value"))
    return Iceoryx2FFI.c_size_t(value)
end

@inline function _progressive_service_builder_ref(builder::ProgressivePubSubServiceBuilder)
    _require_valid(builder.handle, "progressive publish/subscribe service builder")
    return Ref{Iceoryx2FFI.iox2_service_builder_progressive_pub_sub_h}(builder.handle)
end

"""
    user_header(builder::ProgressivePubSubServiceBuilder, ::Type{UH})

Set the fixed-size application user-header type for a progressive service.
"""
function user_header(
        builder::ProgressivePubSubServiceBuilder{S, Nothing}, ::Type{UH}) where {S, UH}
    variant = _fixed_header_variant(UH, "user header type")
    header_type = _payload_type(UH)
    name, name_len, size, alignment = _type_details(header_type)
    GC.@preserve name begin
        ret = Iceoryx2FFI.iox2_service_builder_progressive_pub_sub_set_user_header_type_details(
            _progressive_service_builder_ref(builder),
            variant,
            Base.unsafe_convert(Cstring, name),
            name_len,
            size,
            alignment
        )
        check_ok(ret, Iceoryx2FFI.iox2_type_detail_error_e)
    end
    handle = builder.handle
    storage = builder.storage
    close(builder)
    return ProgressivePubSubServiceBuilder{S, header_type}(
        handle, storage, builder.keepalive)
end

function user_header(
        builder::ProgressivePubSubServiceBuilder{S, UH}, ::Type{UH}) where {S, UH}
    _require_valid(builder.handle, "progressive publish/subscribe service builder")
    return builder
end

function max_nodes!(builder::ProgressivePubSubServiceBuilder, value::Integer)
    Iceoryx2FFI.iox2_service_builder_progressive_pub_sub_set_max_nodes(
        _progressive_service_builder_ref(builder), _progressive_size(value, "max nodes"))
    return builder
end

function max_subscribers!(builder::ProgressivePubSubServiceBuilder, value::Integer)
    Iceoryx2FFI.iox2_service_builder_progressive_pub_sub_set_max_subscribers(
        _progressive_service_builder_ref(builder),
        _progressive_size(value, "max subscribers")
    )
    return builder
end

function subscriber_max_buffer_size!(
        builder::ProgressivePubSubServiceBuilder, value::Integer)
    Iceoryx2FFI.iox2_service_builder_progressive_pub_sub_set_subscriber_max_buffer_size(
        _progressive_service_builder_ref(builder),
        _progressive_size(value, "subscriber max buffer size")
    )
    return builder
end

function subscriber_max_borrowed_samples!(
        builder::ProgressivePubSubServiceBuilder, value::Integer)
    Iceoryx2FFI.iox2_service_builder_progressive_pub_sub_set_subscriber_max_borrowed_samples(
        _progressive_service_builder_ref(builder),
        _progressive_size(value, "subscriber max borrowed samples")
    )
    return builder
end

"""
    payload_alignment!(builder::ProgressivePubSubServiceBuilder, alignment)

Request a payload alignment. Progressive mode always enforces at least 128
bytes; the requested value must also be a valid power-of-two alignment.
"""
function payload_alignment!(
        builder::ProgressivePubSubServiceBuilder, alignment::Integer)
    alignment > 0 ||
        throw(ArgumentError("payload alignment must be positive, got $alignment"))
    ret = Iceoryx2FFI.iox2_service_builder_progressive_pub_sub_set_payload_alignment(
        _progressive_service_builder_ref(builder), Iceoryx2FFI.c_size_t(alignment))
    check_ok(ret, Iceoryx2FFI.iox2_type_detail_error_e)
    return builder
end

"""
    PortFactoryProgressivePubSub{S,UH}

Factory for the single progressive publisher and its subscribers.
"""
mutable struct PortFactoryProgressivePubSub{S, UH}
    handle::Iceoryx2FFI.iox2_port_factory_progressive_pub_sub_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_progressive_pub_sub_t}
    keepalive::Node{S}
    function PortFactoryProgressivePubSub{S, UH}(handle, storage, keepalive) where {S, UH}
        obj = new{S, UH}(handle, storage, keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

@inline Base.isvalid(factory::PortFactoryProgressivePubSub) = factory.handle != _IOX2_NULL
@inline unsafe_handle(factory::PortFactoryProgressivePubSub) = factory.handle

function Base.close(factory::PortFactoryProgressivePubSub)
    if factory.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_port_factory_progressive_pub_sub_drop(factory.handle)
        factory.handle = _IOX2_NULL
    end
    factory.storage = nothing
    return nothing
end

function _open_progressive(
        builder::ProgressivePubSubServiceBuilder{S, UH}, ffi_function) where {S, UH}
    _require_valid(builder.handle, "progressive publish/subscribe service builder")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_progressive_pub_sub_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_progressive_pub_sub_h}(_IOX2_NULL)
    ret = ffi_function(builder.handle, storage, handle_ref)
    close(builder)
    check_ok(ret, Iceoryx2FFI.iox2_pub_sub_open_or_create_error_e)
    return PortFactoryProgressivePubSub{S, UH}(handle_ref[], storage, builder.keepalive)
end

"""
    open_or_create(builder::ProgressivePubSubServiceBuilder)

Open an existing progressive service or create it if it does not exist.
"""
function open_or_create(builder::ProgressivePubSubServiceBuilder)
    return _open_progressive(
        builder,
        Iceoryx2FFI.iox2_service_builder_progressive_pub_sub_open_or_create
    )
end

function open(builder::ProgressivePubSubServiceBuilder)
    return _open_progressive(
        builder, Iceoryx2FFI.iox2_service_builder_progressive_pub_sub_open)
end

function create(builder::ProgressivePubSubServiceBuilder)
    return _open_progressive(
        builder, Iceoryx2FFI.iox2_service_builder_progressive_pub_sub_create)
end

function open_or_create(f::Function, builder::ProgressivePubSubServiceBuilder)
    factory = open_or_create(builder)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function open(f::Function, builder::ProgressivePubSubServiceBuilder)
    factory = open(builder)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function create(f::Function, builder::ProgressivePubSubServiceBuilder)
    factory = create(builder)
    try
        return f(factory)
    finally
        close(factory)
    end
end

abstract type AbstractSamplesPreallocationOverride end

"""
    SamplesPreallocationOverride(callback)

Own a callback used by `samples_preallocation_override!`. The callback receives
the worst-case sample count and returns the desired preallocation count.
"""
mutable struct SamplesPreallocationOverride{F} <: AbstractSamplesPreallocationOverride
    on_override::F
    ref::Base.RefValue{SamplesPreallocationOverride{F}}
    callback::Iceoryx2FFI.iox2_preallocated_samples_override
    last_exception::Base.RefValue{_CallbackException}
    function SamplesPreallocationOverride{F}(on_override::F) where {F}
        ref = Ref{SamplesPreallocationOverride{F}}()
        obj = new{F}(on_override, ref, C_NULL, _callback_exception_ref())
        obj.callback = _samples_preallocation_override_cfunction(obj)
        ref[] = obj
        return obj
    end
end

SamplesPreallocationOverride(on_override) =
    SamplesPreallocationOverride{typeof(on_override)}(on_override)

@inline last_callback_exception(handler::SamplesPreallocationOverride) =
    handler.last_exception[]

function _samples_preallocation_override_wrapper(
        count::Iceoryx2FFI.c_size_t,
        handler::T
)::Iceoryx2FFI.c_size_t where {T <: AbstractSamplesPreallocationOverride}
    try
        return Iceoryx2FFI.c_size_t(handler.on_override(Int(count)))
    catch err
        _record_callback_exception!(handler, err)
        return count
    end
end

function _samples_preallocation_override_cfunction(
        ::T) where {T <: AbstractSamplesPreallocationOverride}
    return @cfunction(
        _samples_preallocation_override_wrapper,
        Iceoryx2FFI.c_size_t,
        (Iceoryx2FFI.c_size_t, Ref{T})
    )
end

mutable struct ProgressivePublisherBuilder{S, UH}
    handle::Iceoryx2FFI.iox2_port_factory_progressive_publisher_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_progressive_publisher_builder_t}
    keepalive::PortFactoryProgressivePubSub{S, UH}
    callback_keepalive::Vector{Any}
    function ProgressivePublisherBuilder{S, UH}(handle, storage, keepalive) where {S, UH}
        obj = new{S, UH}(handle, storage, keepalive, Any[])
        finalizer(Base.close, obj)
        return obj
    end
end

mutable struct ProgressiveSubscriberBuilder{S, UH}
    handle::Iceoryx2FFI.iox2_port_factory_progressive_subscriber_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_progressive_subscriber_builder_t}
    keepalive::PortFactoryProgressivePubSub{S, UH}
    function ProgressiveSubscriberBuilder{S, UH}(handle, storage, keepalive) where {S, UH}
        obj = new{S, UH}(handle, storage, keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

@inline Base.isvalid(builder::Union{
    ProgressivePublisherBuilder, ProgressiveSubscriberBuilder}) =
    builder.handle != _IOX2_NULL

function Base.close(builder::ProgressivePublisherBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    _drop_callback_keepalive!(builder)
    return nothing
end

function Base.close(builder::ProgressiveSubscriberBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

function publisher_builder(factory::PortFactoryProgressivePubSub{S, UH}) where {S, UH}
    _require_valid(factory.handle, "progressive publish/subscribe port factory")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_progressive_publisher_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_progressive_pub_sub_publisher_builder(
        Ref{Iceoryx2FFI.iox2_port_factory_progressive_pub_sub_h}(factory.handle), storage)
    return ProgressivePublisherBuilder{S, UH}(handle, storage, factory)
end

function subscriber_builder(factory::PortFactoryProgressivePubSub{S, UH}) where {S, UH}
    _require_valid(factory.handle, "progressive publish/subscribe port factory")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_progressive_subscriber_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_progressive_pub_sub_subscriber_builder(
        Ref{Iceoryx2FFI.iox2_port_factory_progressive_pub_sub_h}(factory.handle), storage)
    return ProgressiveSubscriberBuilder{S, UH}(handle, storage, factory)
end

@inline function _progressive_publisher_builder_ref(builder::ProgressivePublisherBuilder)
    _require_valid(builder.handle, "progressive publisher builder")
    return Ref{Iceoryx2FFI.iox2_port_factory_progressive_publisher_builder_h}(
        builder.handle)
end

@inline function _progressive_subscriber_builder_ref(builder::ProgressiveSubscriberBuilder)
    _require_valid(builder.handle, "progressive subscriber builder")
    return Ref{Iceoryx2FFI.iox2_port_factory_progressive_subscriber_builder_h}(
        builder.handle)
end

function name!(builder::ProgressivePublisherBuilder,
        name::Union{PortName, PortNameView, AbstractString})
    return _set_port_name!(
        builder,
        name,
        Iceoryx2FFI.iox2_port_factory_progressive_publisher_builder_set_name,
        _progressive_publisher_builder_ref(builder),
        "progressive publisher builder"
    )
end

function name!(builder::ProgressiveSubscriberBuilder,
        name::Union{PortName, PortNameView, AbstractString})
    return _set_port_name!(
        builder,
        name,
        Iceoryx2FFI.iox2_port_factory_progressive_subscriber_builder_set_name,
        _progressive_subscriber_builder_ref(builder),
        "progressive subscriber builder"
    )
end

function initial_max_slice_len!(builder::ProgressivePublisherBuilder, value::Integer)
    Iceoryx2FFI.iox2_port_factory_progressive_publisher_builder_set_initial_max_slice_len(
        _progressive_publisher_builder_ref(builder),
        _progressive_size(value, "initial max slice length")
    )
    return builder
end

function max_loaned_samples!(builder::ProgressivePublisherBuilder, value::Integer)
    Iceoryx2FFI.iox2_port_factory_progressive_publisher_builder_set_max_loaned_samples(
        _progressive_publisher_builder_ref(builder),
        _progressive_size(value, "max loaned samples")
    )
    return builder
end

function allocation_strategy!(builder::ProgressivePublisherBuilder,
        value::Union{Symbol, AllocationStrategy})
    Iceoryx2FFI.iox2_port_factory_progressive_publisher_builder_set_allocation_strategy(
        _progressive_publisher_builder_ref(builder), _allocation_strategy(value))
    return builder
end

function backpressure_strategy!(builder::ProgressivePublisherBuilder,
        value::Union{Symbol, BackpressureStrategy})
    Iceoryx2FFI.iox2_port_factory_progressive_publisher_builder_set_backpressure_strategy(
        _progressive_publisher_builder_ref(builder), _backpressure_strategy(value))
    return builder
end

function backpressure_handler!(
        builder::ProgressivePublisherBuilder, handler::AbstractBackpressureHandler)
    Iceoryx2FFI.iox2_port_factory_progressive_publisher_builder_set_backpressure_handler(
        _progressive_publisher_builder_ref(builder), handler.callback, handler.ref)
    push!(builder.callback_keepalive, handler)
    return builder
end

function backpressure_handler!(builder::ProgressivePublisherBuilder, on_backpressure)
    return backpressure_handler!(builder, BackpressureHandler(on_backpressure))
end

function samples_preallocation_override!(builder::ProgressivePublisherBuilder,
        handler::AbstractSamplesPreallocationOverride)
    Iceoryx2FFI.iox2_port_factory_progressive_publisher_builder_override_samples_preallocation(
        _progressive_publisher_builder_ref(builder), handler.callback, handler.ref)
    push!(builder.callback_keepalive, handler)
    return builder
end

function samples_preallocation_override!(builder::ProgressivePublisherBuilder, on_override)
    return samples_preallocation_override!(
        builder, SamplesPreallocationOverride(on_override))
end

function buffer_size!(builder::ProgressiveSubscriberBuilder, value::Integer)
    Iceoryx2FFI.iox2_port_factory_progressive_subscriber_builder_set_buffer_size(
        _progressive_subscriber_builder_ref(builder),
        _progressive_size(value, "subscriber buffer size")
    )
    return builder
end

mutable struct ProgressivePublisher{S, UH}
    handle::Iceoryx2FFI.iox2_progressive_publisher_h
    handle_ref::Base.RefValue{Iceoryx2FFI.iox2_progressive_publisher_h}
    storage::_StorageRef{Iceoryx2FFI.iox2_progressive_publisher_t}
    keepalive::PortFactoryProgressivePubSub{S, UH}
    callback_keepalive::Vector{Any}
    function ProgressivePublisher{S, UH}(
            handle, storage, keepalive, callback_keepalive) where {S, UH}
        obj = new{S, UH}(
            handle, Ref{Iceoryx2FFI.iox2_progressive_publisher_h}(handle),
            storage, keepalive, callback_keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

mutable struct ProgressiveSubscriber{S, UH}
    handle::Iceoryx2FFI.iox2_progressive_subscriber_h
    handle_ref::Base.RefValue{Iceoryx2FFI.iox2_progressive_subscriber_h}
    storage::_StorageRef{Iceoryx2FFI.iox2_progressive_subscriber_t}
    keepalive::PortFactoryProgressivePubSub{S, UH}
    has_samples_ref::Base.RefValue{Bool}
    function ProgressiveSubscriber{S, UH}(handle, storage, keepalive) where {S, UH}
        obj = new{S, UH}(
            handle, Ref{Iceoryx2FFI.iox2_progressive_subscriber_h}(handle),
            storage, keepalive, Ref(false))
        finalizer(Base.close, obj)
        return obj
    end
end

@inline Base.isvalid(publisher::ProgressivePublisher) = publisher.handle != _IOX2_NULL
@inline Base.isvalid(subscriber::ProgressiveSubscriber) = subscriber.handle != _IOX2_NULL
@inline unsafe_handle(publisher::ProgressivePublisher) = publisher.handle
@inline unsafe_handle(subscriber::ProgressiveSubscriber) = subscriber.handle

function Base.close(publisher::ProgressivePublisher)
    if publisher.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_progressive_publisher_drop(publisher.handle)
        publisher.handle = _IOX2_NULL
        publisher.handle_ref[] = _IOX2_NULL
    end
    publisher.storage = nothing
    _drop_callback_keepalive!(publisher)
    return nothing
end

function Base.close(subscriber::ProgressiveSubscriber)
    if subscriber.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_progressive_subscriber_drop(subscriber.handle)
        subscriber.handle = _IOX2_NULL
        subscriber.handle_ref[] = _IOX2_NULL
    end
    subscriber.storage = nothing
    return nothing
end

function create(builder::ProgressivePublisherBuilder{S, UH}) where {S, UH}
    _require_valid(builder.handle, "progressive publisher builder")
    storage = Ref{Iceoryx2FFI.iox2_progressive_publisher_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_progressive_publisher_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_progressive_publisher_builder_create(
        builder.handle, storage, handle_ref)
    callbacks = _take_callback_keepalive!(builder)
    close(builder)
    check_ok(ret, Iceoryx2FFI.iox2_publisher_create_error_e)
    return ProgressivePublisher{S, UH}(
        handle_ref[], storage, builder.keepalive, callbacks)
end

function create(builder::ProgressiveSubscriberBuilder{S, UH}) where {S, UH}
    _require_valid(builder.handle, "progressive subscriber builder")
    storage = Ref{Iceoryx2FFI.iox2_progressive_subscriber_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_progressive_subscriber_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_progressive_subscriber_builder_create(
        builder.handle, storage, handle_ref)
    close(builder)
    check_ok(ret, Iceoryx2FFI.iox2_subscriber_create_error_e)
    return ProgressiveSubscriber{S, UH}(handle_ref[], storage, builder.keepalive)
end

function create(f::Function, builder::ProgressivePublisherBuilder)
    publisher = create(builder)
    try
        return f(publisher)
    finally
        close(publisher)
    end
end

function create(f::Function, builder::ProgressiveSubscriberBuilder)
    subscriber = create(builder)
    try
        return f(subscriber)
    finally
        close(subscriber)
    end
end

"""
    ProgressiveSampleMutUninit(publisher)

Reusable holder for a private, uninitialized progressive publisher loan.
"""
mutable struct ProgressiveSampleMutUninit{S, UH}
    handle_ref::Base.RefValue{Iceoryx2FFI.iox2_progressive_sample_mut_uninit_h}
    storage::Base.RefValue{Iceoryx2FFI.iox2_progressive_sample_mut_uninit_t}
    keepalive::ProgressivePublisher{S, UH}
    payload_ptr_ref::Base.RefValue{Ptr{Cvoid}}
    capacity_ref::Base.RefValue{Iceoryx2FFI.c_size_t}
    function ProgressiveSampleMutUninit{S, UH}(
            handle_ref, storage, keepalive, payload_ptr_ref, capacity_ref) where {S, UH}
        obj = new{S, UH}(
            handle_ref, storage, keepalive, payload_ptr_ref, capacity_ref)
        finalizer(Base.close, obj)
        return obj
    end
end

function ProgressiveSampleMutUninit(
        publisher::ProgressivePublisher{S, UH}) where {S, UH}
    return ProgressiveSampleMutUninit{S, UH}(
        Ref{Iceoryx2FFI.iox2_progressive_sample_mut_uninit_h}(_IOX2_NULL),
        Ref{Iceoryx2FFI.iox2_progressive_sample_mut_uninit_t}(),
        publisher,
        Ref{Ptr{Cvoid}}(C_NULL),
        Ref{Iceoryx2FFI.c_size_t}(0)
    )
end

@inline Base.isvalid(sample::ProgressiveSampleMutUninit) =
    sample.handle_ref[] != _IOX2_NULL
@inline unsafe_handle(sample::ProgressiveSampleMutUninit) = sample.handle_ref[]
@inline _slice_mutable(::Type{<:ProgressiveSampleMutUninit}) = true

function Base.close(sample::ProgressiveSampleMutUninit)
    if sample.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_progressive_sample_mut_uninit_drop(sample.handle_ref[])
        sample.handle_ref[] = _IOX2_NULL
    end
    sample.payload_ptr_ref[] = C_NULL
    sample.capacity_ref[] = 0
    return nothing
end

"""
    loan_slice_uninit!(publisher, sample, capacity)

Loan a private uninitialized byte buffer into the reusable `sample` holder.
"""
function loan_slice_uninit!(publisher::ProgressivePublisher{S, UH},
        sample::ProgressiveSampleMutUninit{S, UH}, capacity::Integer) where {S, UH}
    _require_valid(publisher.handle, "progressive publisher")
    _require_inactive(sample, "progressive private loan")
    sample.handle_ref[] = _IOX2_NULL
    sample.payload_ptr_ref[] = C_NULL
    sample.capacity_ref[] = 0
    ret = Iceoryx2FFI.iox2_progressive_publisher_loan_slice_uninit(
        publisher.handle_ref,
        sample.storage,
        sample.handle_ref,
        _progressive_size(capacity, "payload capacity")
    )
    check_ok(ret, Iceoryx2FFI.iox2_loan_error_e)
    sample.keepalive = publisher
    return sample
end

@inline function _refresh_private_payload!(sample::ProgressiveSampleMutUninit)
    _require_valid(sample.handle_ref[], "progressive private loan")
    Iceoryx2FFI.iox2_progressive_sample_mut_uninit_payload_mut(
        sample.handle_ref, sample.payload_ptr_ref, sample.capacity_ref)
    return nothing
end

"""
    payload_mut(sample::ProgressiveSampleMutUninit) -> Slice{UInt8}

Return the full mutable private payload allocation. The view becomes subject to
progressive commit rules after the loan is announced.
"""
@inline function payload_mut(sample::ProgressiveSampleMutUninit)
    _refresh_private_payload!(sample)
    return Slice{UInt8}(
        Ptr{UInt8}(sample.payload_ptr_ref[]), Int(sample.capacity_ref[]), sample)
end

@inline function unsafe_payload_mut_ptr(sample::ProgressiveSampleMutUninit)
    _refresh_private_payload!(sample)
    return Ptr{UInt8}(sample.payload_ptr_ref[])
end

@inline function payload_capacity(sample::ProgressiveSampleMutUninit)
    _refresh_private_payload!(sample)
    return Int(sample.capacity_ref[])
end

@inline payload_number_of_bytes(sample::ProgressiveSampleMutUninit) =
    payload_capacity(sample)

@inline function unsafe_user_header_mut_ptr(
        sample::ProgressiveSampleMutUninit, ::Type{T}) where {T}
    _require_valid(sample.handle_ref[], "progressive private loan")
    _require_isbits(T)
    return Ptr{T}(
        Iceoryx2FFI.iox2_progressive_sample_mut_uninit_user_header_mut(
            sample.handle_ref))
end

@inline function user_header(sample::ProgressiveSampleMutUninit{S, Nothing}) where {S}
    throw(ArgumentError("progressive sample has no user header type"))
end

@inline function user_header(sample::ProgressiveSampleMutUninit{S, UH}) where {S, UH}
    return Slice{UH}(unsafe_user_header_mut_ptr(sample, UH), 1, sample)
end

@inline user_header_mut(sample::ProgressiveSampleMutUninit) = user_header(sample)

"""
    ProgressiveSampleMut(publisher)

Reusable active-writer holder. `close(writer)` aborts an active sample.
"""
mutable struct ProgressiveSampleMut{S, UH}
    handle_ref::Base.RefValue{Iceoryx2FFI.iox2_progressive_sample_mut_h}
    storage::Base.RefValue{Iceoryx2FFI.iox2_progressive_sample_mut_t}
    number_of_recipients_ref::Base.RefValue{Iceoryx2FFI.c_size_t}
    keepalive::ProgressivePublisher{S, UH}
    payload_ptr::Ptr{UInt8}
    capacity::Int
    function ProgressiveSampleMut{S, UH}(
            handle_ref, storage, number_of_recipients_ref,
            keepalive, payload_ptr, capacity) where {S, UH}
        obj = new{S, UH}(handle_ref, storage, number_of_recipients_ref,
            keepalive, payload_ptr, capacity)
        finalizer(Base.close, obj)
        return obj
    end
end

function ProgressiveSampleMut(publisher::ProgressivePublisher{S, UH}) where {S, UH}
    return ProgressiveSampleMut{S, UH}(
        Ref{Iceoryx2FFI.iox2_progressive_sample_mut_h}(_IOX2_NULL),
        Ref{Iceoryx2FFI.iox2_progressive_sample_mut_t}(),
        Ref{Iceoryx2FFI.c_size_t}(0),
        publisher,
        Ptr{UInt8}(0),
        0
    )
end

@inline Base.isvalid(writer::ProgressiveSampleMut) = writer.handle_ref[] != _IOX2_NULL
@inline unsafe_handle(writer::ProgressiveSampleMut) = writer.handle_ref[]
@inline _slice_mutable(::Type{<:ProgressiveSampleMut}) = true

function Base.close(writer::ProgressiveSampleMut)
    if writer.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_progressive_sample_mut_drop(writer.handle_ref[])
        writer.handle_ref[] = _IOX2_NULL
    end
    writer.number_of_recipients_ref[] = 0
    writer.payload_ptr = Ptr{UInt8}(0)
    writer.capacity = 0
    return nothing
end

"""
    announce!(private_loan, writer) -> Int

Announce the buffer and transfer the private loan into the reusable active
`writer`. Return the number of subscriber queues that accepted the sample at
announcement. This is not a processing acknowledgment or a live connection
count. The private-loan handle is consumed even when delivery fails.
"""
function announce!(sample::ProgressiveSampleMutUninit{S, UH},
        writer::ProgressiveSampleMut{S, UH}) where {S, UH}
    _require_valid(sample.handle_ref[], "progressive private loan")
    _require_inactive(writer, "progressive writer")
    _refresh_private_payload!(sample)
    payload_ptr = Ptr{UInt8}(sample.payload_ptr_ref[])
    capacity = Int(sample.capacity_ref[])
    writer.handle_ref[] = _IOX2_NULL
    writer.number_of_recipients_ref[] = 0
    ret = Iceoryx2FFI.iox2_progressive_sample_mut_uninit_announce(
        sample.handle_ref[], writer.storage, writer.handle_ref,
        writer.number_of_recipients_ref)
    sample.handle_ref[] = _IOX2_NULL
    sample.payload_ptr_ref[] = C_NULL
    sample.capacity_ref[] = 0
    if ret == _IOX2_OK
        writer.keepalive = sample.keepalive
        writer.payload_ptr = payload_ptr
        writer.capacity = capacity
    else
        writer.payload_ptr = Ptr{UInt8}(0)
        writer.capacity = 0
    end
    check_ok(ret, Iceoryx2FFI.iox2_send_error_e)
    return Int(writer.number_of_recipients_ref[])
end

"""
    unsafe_payload_mut(writer::ProgressiveSampleMut) -> Slice{UInt8}

Return the retained mutable allocation for an active writer. Never modify
bytes below `committed_len(writer)`, and stop using the view before the writer
is completed, aborted, or closed.
"""
@inline function unsafe_payload_mut(writer::ProgressiveSampleMut)
    _require_valid(writer.handle_ref[], "progressive writer")
    return Slice{UInt8}(writer.payload_ptr, writer.capacity, writer)
end

@inline function unsafe_payload_mut_ptr(writer::ProgressiveSampleMut)
    _require_valid(writer.handle_ref[], "progressive writer")
    return writer.payload_ptr
end

@inline function payload_capacity(writer::ProgressiveSampleMut)
    _require_valid(writer.handle_ref[], "progressive writer")
    return Int(Iceoryx2FFI.iox2_progressive_sample_mut_payload_capacity(
        writer.handle_ref))
end

"""
    committed_len(writer::ProgressiveSampleMut) -> Int

Acquire the current contiguous committed byte length.
"""
@inline function committed_len(writer::ProgressiveSampleMut)
    _require_valid(writer.handle_ref[], "progressive writer")
    return Int(Iceoryx2FFI.iox2_progressive_sample_mut_committed_len(
        writer.handle_ref))
end

@inline payload_number_of_bytes(writer::ProgressiveSampleMut) = committed_len(writer)

@inline function unsafe_user_header_ptr(
        writer::ProgressiveSampleMut, ::Type{T}) where {T}
    _require_valid(writer.handle_ref[], "progressive writer")
    _require_isbits(T)
    return Ptr{T}(Iceoryx2FFI.iox2_progressive_sample_mut_user_header(
        writer.handle_ref))
end

@inline function user_header(writer::ProgressiveSampleMut{S, Nothing}) where {S}
    throw(ArgumentError("progressive writer has no user header type"))
end

@inline function user_header(writer::ProgressiveSampleMut{S, UH}) where {S, UH}
    return Slice{UH}(unsafe_user_header_ptr(writer, UH), 1, writer)
end

"""
    write_from_slice!(writer, bytes)

Copy `bytes` into the uncommitted suffix and release-commit the enlarged prefix.
The source must not overlap the progressive payload allocation.
"""
function write_from_slice!(writer::ProgressiveSampleMut, bytes::StridedVector{UInt8})
    _require_valid(writer.handle_ref[], "progressive writer")
    stride(bytes, 1) == 1 || throw(ArgumentError("source bytes must be contiguous"))
    GC.@preserve bytes begin
        ret = Iceoryx2FFI.iox2_progressive_sample_mut_write_from_slice(
            writer.handle_ref,
            pointer(bytes),
            Iceoryx2FFI.c_size_t(length(bytes))
        )
        check_ok(ret, Iceoryx2FFI.iox2_progressive_write_error_e)
    end
    return writer
end

"""
    unsafe_commit_until!(writer, new_len)

Release-commit a monotonically increasing contiguous byte boundary. Before
calling, every byte below `new_len` must be initialized, CPU-visible, and
immutable for the remainder of the sample's lifetime. This does not establish
DMA cache coherency.
"""
function unsafe_commit_until!(writer::ProgressiveSampleMut, new_len::Integer)
    _require_valid(writer.handle_ref[], "progressive writer")
    ret = Iceoryx2FFI.iox2_progressive_sample_mut_commit_until(
        writer.handle_ref, _progressive_size(new_len, "committed length"))
    check_ok(ret, Iceoryx2FFI.iox2_progressive_write_error_e)
    return writer
end

@inline function _terminal!(writer::ProgressiveSampleMut, ffi_function)
    _require_valid(writer.handle_ref[], "progressive writer")
    ret = ffi_function(writer.handle_ref[])
    writer.handle_ref[] = _IOX2_NULL
    writer.payload_ptr = Ptr{UInt8}(0)
    writer.capacity = 0
    check_ok(ret, Iceoryx2FFI.iox2_progressive_write_error_e)
    return nothing
end

"""Complete a progressive sample and consume the writer."""
complete!(writer::ProgressiveSampleMut) =
    _terminal!(writer, Iceoryx2FFI.iox2_progressive_sample_mut_complete)

"""Mark a progressive sample aborted and consume the writer."""
abort!(writer::ProgressiveSampleMut) =
    _terminal!(writer, Iceoryx2FFI.iox2_progressive_sample_mut_abort)

"""
    ProgressiveSample(subscriber)

Reusable receive holder for a progressive sample.
"""
mutable struct ProgressiveSample{S, UH}
    handle_ref::Base.RefValue{Iceoryx2FFI.iox2_progressive_sample_h}
    storage::Base.RefValue{Iceoryx2FFI.iox2_progressive_sample_t}
    keepalive::ProgressiveSubscriber{S, UH}
    payload_ptr_ref::Base.RefValue{Ptr{UInt8}}
    committed_len_ref::Base.RefValue{Iceoryx2FFI.c_size_t}
    snapshot_ref::Base.RefValue{Iceoryx2FFI.iox2_progressive_sample_snapshot_t}
    function ProgressiveSample{S, UH}(
            handle_ref, storage, keepalive, payload_ptr_ref,
            committed_len_ref, snapshot_ref) where {S, UH}
        obj = new{S, UH}(
            handle_ref, storage, keepalive, payload_ptr_ref,
            committed_len_ref, snapshot_ref)
        finalizer(Base.close, obj)
        return obj
    end
end

function ProgressiveSample(subscriber::ProgressiveSubscriber{S, UH}) where {S, UH}
    return ProgressiveSample{S, UH}(
        Ref{Iceoryx2FFI.iox2_progressive_sample_h}(_IOX2_NULL),
        Ref{Iceoryx2FFI.iox2_progressive_sample_t}(),
        subscriber,
        Ref{Ptr{UInt8}}(Ptr{UInt8}(0)),
        Ref{Iceoryx2FFI.c_size_t}(0),
        Ref(Iceoryx2FFI.iox2_progressive_sample_snapshot_t(
            0, Iceoryx2FFI.iox2_progressive_sample_state_e_ABORTED))
    )
end

@inline Base.isvalid(sample::ProgressiveSample) = sample.handle_ref[] != _IOX2_NULL
@inline unsafe_handle(sample::ProgressiveSample) = sample.handle_ref[]

function Base.close(sample::ProgressiveSample)
    if sample.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_progressive_sample_drop(sample.handle_ref[])
        sample.handle_ref[] = _IOX2_NULL
    end
    sample.payload_ptr_ref[] = Ptr{UInt8}(0)
    sample.committed_len_ref[] = 0
    return nothing
end

"""
    receive!(subscriber, sample) -> Bool

Receive into a reusable progressive sample holder. An empty queue returns
`false` without activating `sample`.
"""
function receive!(subscriber::ProgressiveSubscriber{S, UH},
        sample::ProgressiveSample{S, UH}) where {S, UH}
    _require_valid(subscriber.handle, "progressive subscriber")
    _require_inactive(sample, "progressive sample")
    sample.handle_ref[] = _IOX2_NULL
    ret = Iceoryx2FFI.iox2_progressive_subscriber_receive(
        subscriber.handle_ref,
        sample.storage,
        sample.handle_ref
    )
    check_ok(ret, Iceoryx2FFI.iox2_connection_failure_e)
    sample.keepalive = subscriber
    return sample.handle_ref[] != _IOX2_NULL
end

function receive!(f::Function, subscriber::ProgressiveSubscriber{S, UH},
        sample::ProgressiveSample{S, UH}) where {S, UH}
    if receive!(subscriber, sample)
        try
            return f(sample)
        finally
            close(sample)
        end
    end
    return nothing
end

function has_samples(subscriber::ProgressiveSubscriber)
    _require_valid(subscriber.handle, "progressive subscriber")
    ret = Iceoryx2FFI.iox2_progressive_subscriber_has_samples(
        subscriber.handle_ref,
        subscriber.has_samples_ref
    )
    check_ok(ret, Iceoryx2FFI.iox2_connection_failure_e)
    return subscriber.has_samples_ref[]
end

@inline function _refresh_progressive_payload!(sample::ProgressiveSample)
    _require_valid(sample.handle_ref[], "progressive sample")
    Iceoryx2FFI.iox2_progressive_sample_payload(
        sample.handle_ref, sample.payload_ptr_ref, sample.committed_len_ref)
    return nothing
end

"""
    payload(sample::ProgressiveSample) -> Slice{UInt8}

Acquire one immutable snapshot of the currently committed prefix.
"""
@inline function payload(sample::ProgressiveSample)
    _refresh_progressive_payload!(sample)
    return Slice{UInt8}(
        sample.payload_ptr_ref[], Int(sample.committed_len_ref[]), sample)
end

@inline function unsafe_payload_ptr(sample::ProgressiveSample)
    _refresh_progressive_payload!(sample)
    return sample.payload_ptr_ref[]
end

@inline function payload_number_of_bytes(sample::ProgressiveSample)
    _refresh_progressive_payload!(sample)
    return Int(sample.committed_len_ref[])
end

"""
    snapshot(sample::ProgressiveSample) -> ProgressiveSampleSnapshot

Acquire the committed length and lifecycle state as one coherent atomic
snapshot without performing an operating-system liveness check.
"""
@inline function snapshot(sample::ProgressiveSample)
    _require_valid(sample.handle_ref[], "progressive sample")
    Iceoryx2FFI.iox2_progressive_sample_snapshot(
        sample.handle_ref, sample.snapshot_ref)
    return _progressive_sample_snapshot(sample.snapshot_ref[])
end

@inline committed_len(value::ProgressiveSampleSnapshot) = value.committed_len
@inline state(value::ProgressiveSampleSnapshot) = value.state

@inline function payload_capacity(sample::ProgressiveSample)
    _require_valid(sample.handle_ref[], "progressive sample")
    return Int(Iceoryx2FFI.iox2_progressive_sample_payload_capacity(
        sample.handle_ref))
end

@inline function unsafe_user_header_ptr(
        sample::ProgressiveSample, ::Type{T}) where {T}
    _require_valid(sample.handle_ref[], "progressive sample")
    _require_isbits(T)
    return Ptr{T}(Iceoryx2FFI.iox2_progressive_sample_user_header(
        sample.handle_ref))
end

@inline function user_header(sample::ProgressiveSample{S, Nothing}) where {S}
    throw(ArgumentError("progressive sample has no user header type"))
end

@inline function user_header(sample::ProgressiveSample{S, UH}) where {S, UH}
    return Slice{UH}(unsafe_user_header_ptr(sample, UH), 1, sample)
end

"""
    state(sample::ProgressiveSample) -> ProgressiveSampleState

Acquire the current state without an operating-system liveness check.
"""
@inline function state(sample::ProgressiveSample)
    _require_valid(sample.handle_ref[], "progressive sample")
    return _progressive_sample_state(
        Iceoryx2FFI.iox2_progressive_sample_state(sample.handle_ref))
end

"""
    state_with_publisher_liveness(sample::ProgressiveSample)

Return the state while accounting for abrupt publisher death. This may perform
operating-system calls while the sample is still active.
"""
function state_with_publisher_liveness(sample::ProgressiveSample)
    return state(snapshot_with_publisher_liveness(sample))
end

"""
    snapshot_with_publisher_liveness(sample::ProgressiveSample)

Return one coherent committed-length and state snapshot while accounting for
abrupt publisher death. This may perform operating-system calls while the
sample is still active.
"""
function snapshot_with_publisher_liveness(sample::ProgressiveSample)
    _require_valid(sample.handle_ref[], "progressive sample")
    ret = Iceoryx2FFI.iox2_progressive_sample_snapshot_with_publisher_liveness(
        sample.handle_ref, sample.snapshot_ref)
    check_ok(ret, Iceoryx2FFI.iox2_connection_failure_e)
    return _progressive_sample_snapshot(sample.snapshot_ref[])
end
