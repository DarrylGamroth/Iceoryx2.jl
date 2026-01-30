mutable struct EventServiceBuilder{S}
    handle::Iceoryx2FFI.iox2_service_builder_event_h
    storage::_StorageRef{Iceoryx2FFI.iox2_service_builder_t}
    keepalive::Node{S}
    function EventServiceBuilder{S}(handle, storage, keepalive) where {S}
        obj = new{S}(handle, storage, keepalive)
        finalizer(_finalize_service_builder_variant, obj)
        return obj
    end
end

mutable struct PubSubServiceBuilder{S,T,UH}
    handle::Iceoryx2FFI.iox2_service_builder_pub_sub_h
    storage::_StorageRef{Iceoryx2FFI.iox2_service_builder_t}
    keepalive::Node{S}
    function PubSubServiceBuilder{S,T,UH}(handle, storage, keepalive) where {S,T,UH}
        obj = new{S,T,UH}(handle, storage, keepalive)
        finalizer(_finalize_service_builder_variant, obj)
        return obj
    end
end

mutable struct RequestResponseServiceBuilder{S,Req,Resp,ReqH,RespH}
    handle::Iceoryx2FFI.iox2_service_builder_request_response_h
    storage::_StorageRef{Iceoryx2FFI.iox2_service_builder_t}
    keepalive::Node{S}
    function RequestResponseServiceBuilder{S,Req,Resp,ReqH,RespH}(handle, storage, keepalive) where {S,Req,Resp,ReqH,RespH}
        obj = new{S,Req,Resp,ReqH,RespH}(handle, storage, keepalive)
        finalizer(_finalize_service_builder_variant, obj)
        return obj
    end
end

function _blackboard_key_eq_cmp(a::K, b::K)::Bool where {K}
    return a == b
end

function _blackboard_key_eq_cmp_cfunction(::Type{K}) where {K}
    @cfunction(_blackboard_key_eq_cmp, Bool, (Ref{K}, Ref{K}))
end

mutable struct BlackboardCreatorBuilder{S,K}
    handle::Iceoryx2FFI.iox2_service_builder_blackboard_creator_h
    storage::_StorageRef{Iceoryx2FFI.iox2_service_builder_t}
    keepalive::Node{S}
    values::Vector{Any}
    function BlackboardCreatorBuilder{S,K}(handle, storage, keepalive, values) where {S,K}
        obj = new{S,K}(handle, storage, keepalive, values)
        finalizer(_finalize_service_builder_variant, obj)
        return obj
    end
end

mutable struct BlackboardOpenerBuilder{S,K}
    handle::Iceoryx2FFI.iox2_service_builder_blackboard_opener_h
    storage::_StorageRef{Iceoryx2FFI.iox2_service_builder_t}
    keepalive::Node{S}
    function BlackboardOpenerBuilder{S,K}(handle, storage, keepalive) where {S,K}
        obj = new{S,K}(handle, storage, keepalive)
        finalizer(_finalize_service_builder_variant, obj)
        return obj
    end
end

function _finalize_service_builder_variant(builder)
    builder.storage = nothing
    return nothing
end

function _finalize_service_builder_variant(builder::BlackboardCreatorBuilder)
    builder.storage = nothing
    empty!(builder.values)
    return nothing
end

function _finalize_service_builder_variant(builder::BlackboardOpenerBuilder)
    builder.storage = nothing
    return nothing
end

function _finalize_service_builder_variant(builder::PubSubServiceBuilder)
    builder.storage = nothing
    return nothing
end

function _finalize_service_builder_variant(builder::RequestResponseServiceBuilder)
    builder.storage = nothing
    return nothing
end

function event(builder::ServiceBuilder{S}) where {S}
    _require_valid(builder.handle, "service builder")
    handle = Iceoryx2FFI.iox2_service_builder_event(builder.handle)
    builder.handle = _IOX2_NULL
    storage = builder.storage
    builder.storage = nothing
    return EventServiceBuilder{S}(handle, storage, builder.keepalive)
end

function publish_subscribe(
    builder::ServiceBuilder{S},
    ::Type{T}
) where {S,T}
    _require_valid(builder.handle, "service builder")
    handle = Iceoryx2FFI.iox2_service_builder_pub_sub(builder.handle)
    builder.handle = _IOX2_NULL
    storage = builder.storage
    builder.storage = nothing
    variant = _variant_type(T)
    payload_type = _payload_type(T)
    pub_builder = PubSubServiceBuilder{S,payload_type,Nothing}(handle, storage, builder.keepalive)
    _set_payload_type!(pub_builder, payload_type, variant)
    return pub_builder
end

function request_response(
    builder::ServiceBuilder{S},
    ::Type{Req},
    ::Type{Resp}
) where {S,Req,Resp}
    _require_valid(builder.handle, "service builder")
    handle = Iceoryx2FFI.iox2_service_builder_request_response(builder.handle)
    builder.handle = _IOX2_NULL
    storage = builder.storage
    builder.storage = nothing
    req_variant = _variant_type(Req)
    resp_variant = _variant_type(Resp)
    req_type = _payload_type(Req)
    resp_type = _payload_type(Resp)
    rr_builder = RequestResponseServiceBuilder{S,req_type,resp_type,Nothing,Nothing}(handle, storage, builder.keepalive)
    _set_request_payload_type!(rr_builder, req_type, req_variant)
    _set_response_payload_type!(rr_builder, resp_type, resp_variant)
    return rr_builder
end

function blackboard_creator(builder::ServiceBuilder{S}, ::Type{K}) where {S,K}
    _require_valid(builder.handle, "service builder")
    handle = Iceoryx2FFI.iox2_service_builder_blackboard_creator(builder.handle)
    builder.handle = _IOX2_NULL
    storage = builder.storage
    builder.storage = nothing
    bb_builder = BlackboardCreatorBuilder{S,K}(handle, storage, builder.keepalive, Any[])
    _set_key_type!(bb_builder, K)
    _key_eq_comparison!(bb_builder)
    return bb_builder
end

function blackboard_opener(builder::ServiceBuilder{S}, ::Type{K}) where {S,K}
    _require_valid(builder.handle, "service builder")
    handle = Iceoryx2FFI.iox2_service_builder_blackboard_opener(builder.handle)
    builder.handle = _IOX2_NULL
    storage = builder.storage
    builder.storage = nothing
    bb_builder = BlackboardOpenerBuilder{S,K}(handle, storage, builder.keepalive)
    _set_key_type!(bb_builder, K)
    return bb_builder
end
