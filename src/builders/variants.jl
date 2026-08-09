"""
    EventServiceBuilder{S}

Service builder for the event messaging pattern scoped to service type `S`.
Create via `event(service_builder(...))`.
"""
mutable struct EventServiceBuilder{S}
    handle::Iceoryx2FFI.iox2_service_builder_event_h
    storage::_StorageRef{Iceoryx2FFI.iox2_service_builder_t}
    keepalive::Node{S}
    function EventServiceBuilder{S}(handle, storage, keepalive) where {S}
        obj = new{S}(handle, storage, keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

"""
    PubSubServiceBuilder{S,T,UH}

Service builder for publish/subscribe with payload type `T` and optional user
header `UH`.
"""
mutable struct PubSubServiceBuilder{S, T, UH}
    handle::Iceoryx2FFI.iox2_service_builder_pub_sub_h
    storage::_StorageRef{Iceoryx2FFI.iox2_service_builder_t}
    keepalive::Node{S}
    function PubSubServiceBuilder{S, T, UH}(handle, storage, keepalive) where {S, T, UH}
        _require_isbits(T)
        UH === Nothing || _require_isbits(UH)
        obj = new{S, T, UH}(handle, storage, keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

"""
    ProgressivePubSubServiceBuilder{S,UH}

Service builder for progressive byte-slice publish/subscribe with an optional
user header `UH`.
"""
mutable struct ProgressivePubSubServiceBuilder{S, UH}
    handle::Iceoryx2FFI.iox2_service_builder_progressive_pub_sub_h
    storage::_StorageRef{Iceoryx2FFI.iox2_service_builder_t}
    keepalive::Node{S}
    function ProgressivePubSubServiceBuilder{S, UH}(handle, storage, keepalive) where {S, UH}
        UH === Nothing || _require_isbits(UH)
        obj = new{S, UH}(handle, storage, keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

"""
    RequestResponseServiceBuilder{S,Req,Resp,ReqH,RespH}

Service builder for request/response with request/response payload and optional
header types.
"""
mutable struct RequestResponseServiceBuilder{S, Req, Resp, ReqH, RespH}
    handle::Iceoryx2FFI.iox2_service_builder_request_response_h
    storage::_StorageRef{Iceoryx2FFI.iox2_service_builder_t}
    keepalive::Node{S}
    function RequestResponseServiceBuilder{S, Req, Resp, ReqH, RespH}(
            handle, storage, keepalive) where {S, Req, Resp, ReqH, RespH}
        _require_isbits(Req)
        _require_isbits(Resp)
        ReqH === Nothing || _require_isbits(ReqH)
        RespH === Nothing || _require_isbits(RespH)
        obj = new{S, Req, Resp, ReqH, RespH}(handle, storage, keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

function _blackboard_key_eq_cmp(a::K, b::K)::Bool where {K}
    try
        return a == b
    catch
        return false
    end
end

function _blackboard_key_eq_cmp_cfunction(::Type{K}) where {K}
    @cfunction(_blackboard_key_eq_cmp, Bool, (Ref{K}, Ref{K}))
end

"""
    BlackboardCreatorBuilder{S,K}

Service builder for creating a blackboard with key type `K`.
"""
mutable struct BlackboardCreatorBuilder{S, K}
    handle::Iceoryx2FFI.iox2_service_builder_blackboard_creator_h
    storage::_StorageRef{Iceoryx2FFI.iox2_service_builder_t}
    keepalive::Node{S}
    values::Vector{Any}
    function BlackboardCreatorBuilder{S, K}(handle, storage, keepalive, values) where {S, K}
        obj = new{S, K}(handle, storage, keepalive, values)
        finalizer(Base.close, obj)
        return obj
    end
end

"""
    BlackboardOpenerBuilder{S,K}

Service builder for opening an existing blackboard with key type `K`.
"""
mutable struct BlackboardOpenerBuilder{S, K}
    handle::Iceoryx2FFI.iox2_service_builder_blackboard_opener_h
    storage::_StorageRef{Iceoryx2FFI.iox2_service_builder_t}
    keepalive::Node{S}
    function BlackboardOpenerBuilder{S, K}(handle, storage, keepalive) where {S, K}
        obj = new{S, K}(handle, storage, keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

const _ServiceVariantBuilder = Union{
    EventServiceBuilder,
    PubSubServiceBuilder,
    ProgressivePubSubServiceBuilder,
    RequestResponseServiceBuilder,
    BlackboardCreatorBuilder,
    BlackboardOpenerBuilder
}

@inline unsafe_handle(builder::_ServiceVariantBuilder) = builder.handle
@inline Base.isvalid(builder::_ServiceVariantBuilder) = builder.handle != _IOX2_NULL

function Base.close(builder::EventServiceBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

function Base.close(builder::PubSubServiceBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

function Base.close(builder::ProgressivePubSubServiceBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

function Base.close(builder::RequestResponseServiceBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

function Base.close(builder::BlackboardCreatorBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    empty!(builder.values)
    return nothing
end

function Base.close(builder::BlackboardOpenerBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

"""
    event(builder::ServiceBuilder{S}) -> EventServiceBuilder{S}

Convert a `ServiceBuilder` into an event service builder.
"""
function event(builder::ServiceBuilder{S}) where {S}
    _require_valid(builder.handle, "service builder")
    handle = Iceoryx2FFI.iox2_service_builder_event(builder.handle)
    storage = builder.storage
    close(builder)
    return EventServiceBuilder{S}(handle, storage, builder.keepalive)
end

"""
    publish_subscribe(builder::ServiceBuilder{S}, ::Type{T}) -> PubSubServiceBuilder{S,...}

Convert a `ServiceBuilder` into a publish/subscribe builder with payload type
`T`. For dynamic payloads, pass an `AbstractVector{T}` type.
"""
function publish_subscribe(
        builder::ServiceBuilder{S},
        ::Type{T}
) where {S, T}
    _require_valid(builder.handle, "service builder")
    handle = Iceoryx2FFI.iox2_service_builder_pub_sub(builder.handle)
    storage = builder.storage
    close(builder)
    variant = _variant_type(T)
    payload_type = _payload_type(T)
    pub_builder = PubSubServiceBuilder{S, payload_type, Nothing}(handle, storage, builder.keepalive)
    _set_payload_type!(pub_builder, payload_type, variant)
    return pub_builder
end

"""
    progressive_publish_subscribe(builder::ServiceBuilder{S}) -> ProgressivePubSubServiceBuilder{S,Nothing}

Convert a `ServiceBuilder` into an experimental progressive byte-slice
publish/subscribe builder. Progressive payloads are always byte slices; use
`user_header` to configure an optional application header.
"""
function progressive_publish_subscribe(builder::ServiceBuilder{S}) where {S}
    _require_valid(builder.handle, "service builder")
    handle = Iceoryx2FFI.iox2_service_builder_progressive_pub_sub(builder.handle)
    storage = builder.storage
    close(builder)
    return ProgressivePubSubServiceBuilder{S, Nothing}(handle, storage, builder.keepalive)
end

"""
    progressive_pub_sub(builder::ServiceBuilder)

Alias for `progressive_publish_subscribe`.
"""
progressive_pub_sub(builder::ServiceBuilder) = progressive_publish_subscribe(builder)

"""
    request_response(builder::ServiceBuilder{S}, ::Type{Req}, ::Type{Resp})

Convert a `ServiceBuilder` into a request/response builder with request and
response payload types.
"""
function request_response(
        builder::ServiceBuilder{S},
        ::Type{Req},
        ::Type{Resp}
) where {S, Req, Resp}
    _require_valid(builder.handle, "service builder")
    handle = Iceoryx2FFI.iox2_service_builder_request_response(builder.handle)
    storage = builder.storage
    close(builder)
    req_variant = _variant_type(Req)
    resp_variant = _variant_type(Resp)
    req_type = _payload_type(Req)
    resp_type = _payload_type(Resp)
    rr_builder = RequestResponseServiceBuilder{S, req_type, resp_type, Nothing, Nothing}(
        handle, storage, builder.keepalive)
    _set_request_payload_type!(rr_builder, req_type, req_variant)
    _set_response_payload_type!(rr_builder, resp_type, resp_variant)
    return rr_builder
end

"""
    blackboard_creator(builder::ServiceBuilder{S}, ::Type{K})

Convert a `ServiceBuilder` into a blackboard creator builder with key type `K`.
"""
function blackboard_creator(builder::ServiceBuilder{S}, ::Type{K}) where {S, K}
    _require_valid(builder.handle, "service builder")
    handle = Iceoryx2FFI.iox2_service_builder_blackboard_creator(builder.handle)
    storage = builder.storage
    close(builder)
    bb_builder = BlackboardCreatorBuilder{S, K}(handle, storage, builder.keepalive, Any[])
    _set_key_type!(bb_builder, K)
    _key_eq_comparison!(bb_builder)
    return bb_builder
end

"""
    blackboard_opener(builder::ServiceBuilder{S}, ::Type{K})

Convert a `ServiceBuilder` into a blackboard opener builder with key type `K`.
"""
function blackboard_opener(builder::ServiceBuilder{S}, ::Type{K}) where {S, K}
    _require_valid(builder.handle, "service builder")
    handle = Iceoryx2FFI.iox2_service_builder_blackboard_opener(builder.handle)
    storage = builder.storage
    close(builder)
    bb_builder = BlackboardOpenerBuilder{S, K}(handle, storage, builder.keepalive)
    _set_key_type!(bb_builder, K)
    _key_eq_comparison!(bb_builder)
    return bb_builder
end
