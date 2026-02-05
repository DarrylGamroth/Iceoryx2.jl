# Config, static config, and dynamic config helpers.

@inline _messaging_pattern(value::Iceoryx2FFI.iox2_messaging_pattern_e) = value

@inline function _messaging_pattern(value::Symbol)
    if value === :pubsub || value === :publish_subscribe
        return Iceoryx2FFI.iox2_messaging_pattern_e_PUBLISH_SUBSCRIBE
    elseif value === :event
        return Iceoryx2FFI.iox2_messaging_pattern_e_EVENT
    elseif value === :request_response
        return Iceoryx2FFI.iox2_messaging_pattern_e_REQUEST_RESPONSE
    elseif value === :blackboard
        return Iceoryx2FFI.iox2_messaging_pattern_e_BLACKBOARD
    end
    throw(ArgumentError("unsupported messaging pattern: $value"))
end

@inline _messaging_pattern(value) = throw(ArgumentError("unsupported messaging pattern: $value"))

@inline _unable_to_deliver_strategy(value::Iceoryx2FFI.iox2_unable_to_deliver_strategy_e) = value

@inline function _unable_to_deliver_strategy(value::Symbol)
    if value === :block
        return Iceoryx2FFI.iox2_unable_to_deliver_strategy_e_BLOCK
    elseif value === :discard_sample
        return Iceoryx2FFI.iox2_unable_to_deliver_strategy_e_DISCARD_SAMPLE
    end
    throw(ArgumentError("unsupported unable_to_deliver_strategy: $value"))
end

@inline _unable_to_deliver_strategy(value) = throw(ArgumentError("unsupported unable_to_deliver_strategy: $value"))

@inline function _cstring_from_ntuple(nt::NTuple{N, Cchar}) where {N}
    idx = findfirst(==(0), nt)
    len = idx === nothing ? N : idx - 1
    len == 0 && return ""
    data = Vector{UInt8}(undef, len)
    @inbounds for i in 1:len
        data[i] = UInt8(nt[i])
    end
    return String(data)
end

"""
    default_config() -> Config

Create a new mutable configuration with default values.
"""
function default_config()
    handle_ref = Ref{Iceoryx2FFI.iox2_config_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_config_default(C_NULL, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_config_creation_error_e)
    return Config(handle_ref[])
end

@inline function _config_h_ref(config::Config)
    _require_valid(unsafe_handle(config), "config")
    return Ref{Iceoryx2FFI.iox2_config_h}(unsafe_handle(config))
end

@inline function _config_h_ref(config::ConfigRef)
    _require_valid(unsafe_handle(config), "config")
    return unsafe_handle(config)
end

"""
    config_from_file(path::AbstractString) -> Config

Load a configuration from a TOML file.
"""
function config_from_file(path::AbstractString)
    file = String(path)
    handle_ref = Ref{Iceoryx2FFI.iox2_config_h}(_IOX2_NULL)
    GC.@preserve file begin
        ret = Iceoryx2FFI.iox2_config_from_file(C_NULL, handle_ref, Base.unsafe_convert(Cstring, file))
        check_ok(ret, Iceoryx2FFI.iox2_config_creation_error_e)
    end
    return Config(handle_ref[])
end

"""
    config_from_ptr(config::ConfigView) -> Config

Clone a dynamic config from a view pointer.
"""
function config_from_ptr(config::ConfigView)
    handle_ref = Ref{Iceoryx2FFI.iox2_config_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_config_from_ptr(unsafe_handle(config), C_NULL, handle_ref)
    return Config(handle_ref[])
end

"""
    config_clone(config::Config) -> Config

Clone a dynamic config handle.
"""
function config_clone(config::Config)
    handle_ref = Ref{Iceoryx2FFI.iox2_config_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_config_clone(_config_h_ref(config), C_NULL, handle_ref)
    return Config(handle_ref[])
end

"""
    global_config() -> ConfigView

Return a view of the global config (not owned by Julia).
"""
@inline function global_config()
    return ConfigView(Iceoryx2FFI.iox2_config_global_config())
end

"""
    config_view(config::Config) -> ConfigView

Return a view of a dynamic config handle.
"""
@inline function config_view(config::Config)
    return ConfigView(Iceoryx2FFI.iox2_cast_config_ptr(unsafe_handle(config)))
end

"""
    node_config(node::Node) -> ConfigView

Return a view of the config associated with a node.
"""
@inline function node_config(node::Node)
    return ConfigView(Iceoryx2FFI.iox2_node_config(Ref{Iceoryx2FFI.iox2_node_h}(unsafe_handle(node))))
end

"""
    StaticConfig

Immutable snapshot of static config values.
"""
struct StaticConfig
    raw::Iceoryx2FFI.iox2_static_config_t
end

"""
    StaticConfigDetails

Static configuration details for a service.
"""
struct StaticConfigDetails
    raw::Iceoryx2FFI.iox2_static_config_details_t
end

"""
    StaticConfigEvent

Static config for the event messaging pattern.
"""
struct StaticConfigEvent
    raw::Iceoryx2FFI.iox2_static_config_event_t
end

"""
    StaticConfigPublishSubscribe

Static config for publish/subscribe services.
"""
struct StaticConfigPublishSubscribe
    raw::Iceoryx2FFI.iox2_static_config_publish_subscribe_t
end

"""
    StaticConfigRequestResponse

Static config for request/response services.
"""
struct StaticConfigRequestResponse
    raw::Iceoryx2FFI.iox2_static_config_request_response_t
end

"""
    StaticConfigBlackboard

Static config for blackboard services.
"""
struct StaticConfigBlackboard
    raw::Iceoryx2FFI.iox2_static_config_blackboard_t
end

"""
    TypeDetail

Static type details (name/size/alignment) stored in static config.
"""
struct TypeDetail
    raw::Iceoryx2FFI.iox2_type_detail_t
end

struct MessageTypeDetails
    raw::Iceoryx2FFI.iox2_message_type_details_t
end

@inline id(config::StaticConfig) = _cstring_from_ntuple(config.raw.id)
@inline name(config::StaticConfig) = _cstring_from_ntuple(config.raw.name)
@inline messaging_pattern(config::StaticConfig) = config.raw.messaging_pattern
@inline details(config::StaticConfig) = StaticConfigDetails(config.raw.details)

@inline event_id_max_value(config::StaticConfigEvent) = Int(config.raw.event_id_max_value)

function attributes(config::StaticConfig)
    handle = config.raw.attributes
    handle == _IOX2_NULL && return AttributeSetView(Iceoryx2FFI.iox2_attribute_set_ptr(_IOX2_NULL))
    return AttributeSetView(Iceoryx2FFI.iox2_cast_attribute_set_ptr(handle))
end

@inline event(details::StaticConfigDetails) = StaticConfigEvent(details.raw.event)
@inline publish_subscribe(details::StaticConfigDetails) = StaticConfigPublishSubscribe(details.raw.publish_subscribe)
@inline request_response(details::StaticConfigDetails) = StaticConfigRequestResponse(details.raw.request_response)
@inline blackboard(details::StaticConfigDetails) = StaticConfigBlackboard(details.raw.blackboard)

@inline message_type_details(config::StaticConfigPublishSubscribe) = MessageTypeDetails(config.raw.message_type_details)
@inline request_message_type_details(config::StaticConfigRequestResponse) = MessageTypeDetails(config.raw.request_message_type_details)
@inline response_message_type_details(config::StaticConfigRequestResponse) = MessageTypeDetails(config.raw.response_message_type_details)
@inline type_details(config::StaticConfigBlackboard) = TypeDetail(config.raw.type_details)

@inline type_variant(details::TypeDetail) = details.raw.variant
@inline type_name(details::TypeDetail) = _cstring_from_ntuple(details.raw.type_name)
@inline type_size(details::TypeDetail) = Int(details.raw.size)
@inline type_alignment(details::TypeDetail) = Int(details.raw.alignment)

@inline header(details::MessageTypeDetails) = TypeDetail(details.raw.header)
@inline user_header(details::MessageTypeDetails) = TypeDetail(details.raw.user_header)
@inline payload(details::MessageTypeDetails) = TypeDetail(details.raw.payload)

@inline function _service_name_ptr(name::ServiceName)
    return _service_name_ptr(unsafe_handle(name))
end

@inline function _service_name_ptr(name::ServiceNameView)
    return unsafe_handle(name)
end

"""
    service_does_exist(
        name;
        service_type,
        messaging_pattern=:publish_subscribe,
        config=nothing,
    ) -> Bool

Check whether a service exists for the given name and pattern.
"""
function service_does_exist(
    service_name::Union{ServiceName, ServiceNameView};
    service_type::ServiceType,
    messaging_pattern::Union{Symbol, Iceoryx2FFI.iox2_messaging_pattern_e} = :publish_subscribe,
    config::Union{Config, ConfigView, Nothing} = nothing,
)
    exists = Ref{Bool}(false)
    ret = Iceoryx2FFI.iox2_service_does_exist(
        _service_type(service_type),
        _service_name_ptr(service_name),
        _config_ptr_from_arg(config),
        _messaging_pattern(messaging_pattern),
        exists,
    )
    check_ok(ret, Iceoryx2FFI.iox2_service_details_error_e)
    return exists[]
end

function service_does_exist(
    service_name::AbstractString;
    service_type::ServiceType,
    messaging_pattern::Union{Symbol, Iceoryx2FFI.iox2_messaging_pattern_e} = :publish_subscribe,
    config::Union{Config, ConfigView, Nothing} = nothing,
)
    name = ServiceName(service_name)
    try
        return service_does_exist(name; service_type, messaging_pattern, config)
    finally
        close(name)
    end
end

"""
    service_details(
        name;
        service_type,
        messaging_pattern=:publish_subscribe,
        config=nothing,
    ) -> (exists::Bool, details::StaticConfigDetails)

Fetch static service details if the service exists.
"""
function service_details(
    service_name::Union{ServiceName, ServiceNameView};
    service_type::ServiceType,
    messaging_pattern::Union{Symbol, Iceoryx2FFI.iox2_messaging_pattern_e} = :publish_subscribe,
    config::Union{Config, ConfigView, Nothing} = nothing,
)
    details_ref = Ref{Iceoryx2FFI.iox2_static_config_t}()
    exists = Ref{Bool}(false)
    ret = Iceoryx2FFI.iox2_service_details(
        _service_type(service_type),
        _service_name_ptr(service_name),
        _config_ptr_from_arg(config),
        _messaging_pattern(messaging_pattern),
        details_ref,
        exists,
    )
    check_ok(ret, Iceoryx2FFI.iox2_service_details_error_e)
    return exists[], StaticConfig(details_ref[])
end

function service_details(
    service_name::AbstractString;
    service_type::ServiceType,
    messaging_pattern::Union{Symbol, Iceoryx2FFI.iox2_messaging_pattern_e} = :publish_subscribe,
    config::Union{Config, ConfigView, Nothing} = nothing,
)
    name = ServiceName(service_name)
    try
        return service_details(name; service_type, messaging_pattern, config)
    finally
        close(name)
    end
end

abstract type AbstractServiceListHandler end

mutable struct ServiceListHandler{T} <: AbstractServiceListHandler
    on_service::T
end

on_service_list(h::ServiceListHandler) = h.on_service

function _service_list_wrapper(config_ptr::Ptr{Iceoryx2FFI.iox2_static_config_t}, handler::AbstractServiceListHandler)
    return _callback_progression(on_service_list(handler)(StaticConfig(unsafe_load(config_ptr))))
end

function _service_list_cfunction(::T) where {T<:AbstractServiceListHandler}
    @cfunction(
        _service_list_wrapper,
        Iceoryx2FFI.iox2_callback_progression_e,
        (Ptr{Iceoryx2FFI.iox2_static_config_t}, Ref{T}),
    )
end

"""
    list_services(handler; service_type, config=nothing)
    list_services(f::Function; service_type, config=nothing)

Iterate over services visible for the given service type. The callback receives
`StaticConfigDetails` or a config view, depending on the handler variant.
"""
function list_services(
    handler::AbstractServiceListHandler;
    service_type::ServiceType,
    config::Union{Config, ConfigView, Nothing} = nothing,
)
    handler_ref = Ref(handler)
    GC.@preserve handler_ref begin
        ret = Iceoryx2FFI.iox2_service_list(
            _service_type(service_type),
            _config_ptr_from_arg(config),
            _service_list_cfunction(handler_ref[]),
            handler_ref,
        )
        check_ok(ret, Iceoryx2FFI.iox2_service_list_error_e)
    end
    return nothing
end

function list_services(
    f::Function;
    service_type::ServiceType,
    config::Union{Config, ConfigView, Nothing} = nothing,
)
    return list_services(ServiceListHandler(f); service_type, config)
end

abstract type AbstractPublisherDetailsHandler end

mutable struct PublisherDetailsHandler{T} <: AbstractPublisherDetailsHandler
    on_details::T
end

on_publisher_details(h::PublisherDetailsHandler) = h.on_details

function _publisher_details_wrapper(handler::AbstractPublisherDetailsHandler, details_ptr::Iceoryx2FFI.iox2_publisher_details_ptr)
    return _callback_progression(on_publisher_details(handler)(PublisherDetailsView(details_ptr)))
end

function _publisher_details_cfunction(::T) where {T<:AbstractPublisherDetailsHandler}
    @cfunction(
        _publisher_details_wrapper,
        Iceoryx2FFI.iox2_callback_progression_e,
        (Ref{T}, Iceoryx2FFI.iox2_publisher_details_ptr),
    )
end

abstract type AbstractSubscriberDetailsHandler end

mutable struct SubscriberDetailsHandler{T} <: AbstractSubscriberDetailsHandler
    on_details::T
end

on_subscriber_details(h::SubscriberDetailsHandler) = h.on_details

function _subscriber_details_wrapper(handler::AbstractSubscriberDetailsHandler, details_ptr::Iceoryx2FFI.iox2_subscriber_details_ptr)
    return _callback_progression(on_subscriber_details(handler)(SubscriberDetailsView(details_ptr)))
end

function _subscriber_details_cfunction(::T) where {T<:AbstractSubscriberDetailsHandler}
    @cfunction(
        _subscriber_details_wrapper,
        Iceoryx2FFI.iox2_callback_progression_e,
        (Ref{T}, Iceoryx2FFI.iox2_subscriber_details_ptr),
    )
end

abstract type AbstractListenerDetailsHandler end

mutable struct ListenerDetailsHandler{T} <: AbstractListenerDetailsHandler
    on_details::T
end

on_listener_details(h::ListenerDetailsHandler) = h.on_details

function _listener_details_wrapper(handler::AbstractListenerDetailsHandler, details_ptr::Iceoryx2FFI.iox2_listener_details_ptr)
    return _callback_progression(on_listener_details(handler)(ListenerDetailsView(details_ptr)))
end

function _listener_details_cfunction(::T) where {T<:AbstractListenerDetailsHandler}
    @cfunction(
        _listener_details_wrapper,
        Iceoryx2FFI.iox2_callback_progression_e,
        (Ref{T}, Iceoryx2FFI.iox2_listener_details_ptr),
    )
end

abstract type AbstractNotifierDetailsHandler end

mutable struct NotifierDetailsHandler{T} <: AbstractNotifierDetailsHandler
    on_details::T
end

on_notifier_details(h::NotifierDetailsHandler) = h.on_details

function _notifier_details_wrapper(handler::AbstractNotifierDetailsHandler, details_ptr::Iceoryx2FFI.iox2_notifier_details_ptr)
    return _callback_progression(on_notifier_details(handler)(NotifierDetailsView(details_ptr)))
end

function _notifier_details_cfunction(::T) where {T<:AbstractNotifierDetailsHandler}
    @cfunction(
        _notifier_details_wrapper,
        Iceoryx2FFI.iox2_callback_progression_e,
        (Ref{T}, Iceoryx2FFI.iox2_notifier_details_ptr),
    )
end

abstract type AbstractEntryReaderDetailsHandler end

mutable struct EntryReaderDetailsHandler{T} <: AbstractEntryReaderDetailsHandler
    on_details::T
end

on_reader_details(h::EntryReaderDetailsHandler) = h.on_details

function _reader_details_wrapper(handler::AbstractEntryReaderDetailsHandler, details_ptr::Iceoryx2FFI.iox2_reader_details_ptr)
    return _callback_progression(on_reader_details(handler)(EntryReaderDetailsView(details_ptr)))
end

function _reader_details_cfunction(::T) where {T<:AbstractEntryReaderDetailsHandler}
    @cfunction(
        _reader_details_wrapper,
        Iceoryx2FFI.iox2_callback_progression_e,
        (Ref{T}, Iceoryx2FFI.iox2_reader_details_ptr),
    )
end

abstract type AbstractEntryWriterDetailsHandler end

mutable struct EntryWriterDetailsHandler{T} <: AbstractEntryWriterDetailsHandler
    on_details::T
end

on_writer_details(h::EntryWriterDetailsHandler) = h.on_details

function _writer_details_wrapper(handler::AbstractEntryWriterDetailsHandler, details_ptr::Iceoryx2FFI.iox2_writer_details_ptr)
    return _callback_progression(on_writer_details(handler)(EntryWriterDetailsView(details_ptr)))
end

function _writer_details_cfunction(::T) where {T<:AbstractEntryWriterDetailsHandler}
    @cfunction(
        _writer_details_wrapper,
        Iceoryx2FFI.iox2_callback_progression_e,
        (Ref{T}, Iceoryx2FFI.iox2_writer_details_ptr),
    )
end

abstract type AbstractClientDetailsHandler end

mutable struct ClientDetailsHandler{T} <: AbstractClientDetailsHandler
    on_details::T
end

on_client_details(h::ClientDetailsHandler) = h.on_details

function _client_details_wrapper(handler::AbstractClientDetailsHandler, details_ptr::Iceoryx2FFI.iox2_client_details_ptr)
    return _callback_progression(on_client_details(handler)(ClientDetailsView(details_ptr)))
end

function _client_details_cfunction(::T) where {T<:AbstractClientDetailsHandler}
    @cfunction(
        _client_details_wrapper,
        Iceoryx2FFI.iox2_callback_progression_e,
        (Ref{T}, Iceoryx2FFI.iox2_client_details_ptr),
    )
end

abstract type AbstractServerDetailsHandler end

mutable struct ServerDetailsHandler{T} <: AbstractServerDetailsHandler
    on_details::T
end

on_server_details(h::ServerDetailsHandler) = h.on_details

function _server_details_wrapper(handler::AbstractServerDetailsHandler, details_ptr::Iceoryx2FFI.iox2_server_details_ptr)
    return _callback_progression(on_server_details(handler)(ServerDetailsView(details_ptr)))
end

function _server_details_cfunction(::T) where {T<:AbstractServerDetailsHandler}
    @cfunction(
        _server_details_wrapper,
        Iceoryx2FFI.iox2_callback_progression_e,
        (Ref{T}, Iceoryx2FFI.iox2_server_details_ptr),
    )
end


function list_publishers(factory::PortFactoryPubSub{S,T,UH}, handler::AbstractPublisherDetailsHandler) where {S,T,UH}
    handler_ref = Ref(handler)
    GC.@preserve handler_ref begin
        Iceoryx2FFI.iox2_port_factory_pub_sub_dynamic_config_list_publishers(
            Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_h}(factory.handle),
            _publisher_details_cfunction(handler_ref[]),
            handler_ref,
        )
    end
    return nothing
end

function list_publishers(f::Function, factory::PortFactoryPubSub{S,T,UH}) where {S,T,UH}
    return list_publishers(factory, PublisherDetailsHandler(f))
end

function list_subscribers(factory::PortFactoryPubSub{S,T,UH}, handler::AbstractSubscriberDetailsHandler) where {S,T,UH}
    handler_ref = Ref(handler)
    GC.@preserve handler_ref begin
        Iceoryx2FFI.iox2_port_factory_pub_sub_dynamic_config_list_subscribers(
            Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_h}(factory.handle),
            _subscriber_details_cfunction(handler_ref[]),
            handler_ref,
        )
    end
    return nothing
end

function list_subscribers(f::Function, factory::PortFactoryPubSub{S,T,UH}) where {S,T,UH}
    return list_subscribers(factory, SubscriberDetailsHandler(f))
end


function list_listeners(factory::PortFactoryEvent{S}, handler::AbstractListenerDetailsHandler) where {S}
    handler_ref = Ref(handler)
    GC.@preserve handler_ref begin
        Iceoryx2FFI.iox2_port_factory_event_dynamic_config_list_listeners(
            Ref{Iceoryx2FFI.iox2_port_factory_event_h}(factory.handle),
            _listener_details_cfunction(handler_ref[]),
            handler_ref,
        )
    end
    return nothing
end

function list_listeners(f::Function, factory::PortFactoryEvent{S}) where {S}
    return list_listeners(factory, ListenerDetailsHandler(f))
end

function list_notifiers(factory::PortFactoryEvent{S}, handler::AbstractNotifierDetailsHandler) where {S}
    handler_ref = Ref(handler)
    GC.@preserve handler_ref begin
        Iceoryx2FFI.iox2_port_factory_event_dynamic_config_list_notifiers(
            Ref{Iceoryx2FFI.iox2_port_factory_event_h}(factory.handle),
            _notifier_details_cfunction(handler_ref[]),
            handler_ref,
        )
    end
    return nothing
end

function list_notifiers(f::Function, factory::PortFactoryEvent{S}) where {S}
    return list_notifiers(factory, NotifierDetailsHandler(f))
end


"""
    list_clients(factory, handler)
    list_clients(f::Function, factory)

Iterate over client details for a request/response service.
"""
function list_clients(factory::PortFactoryRequestResponse{S,Req,Resp,ReqH,RespH}, handler::AbstractClientDetailsHandler) where {S,Req,Resp,ReqH,RespH}
    handler_ref = Ref(handler)
    GC.@preserve handler_ref begin
        Iceoryx2FFI.iox2_port_factory_request_response_dynamic_config_list_clients(
            Ref{Iceoryx2FFI.iox2_port_factory_request_response_h}(factory.handle),
            _client_details_cfunction(handler_ref[]),
            handler_ref,
        )
    end
    return nothing
end

function list_clients(f::Function, factory::PortFactoryRequestResponse{S,Req,Resp,ReqH,RespH}) where {S,Req,Resp,ReqH,RespH}
    return list_clients(factory, ClientDetailsHandler(f))
end

"""
    list_servers(factory, handler)
    list_servers(f::Function, factory)

Iterate over server details for a request/response service.
"""
function list_servers(factory::PortFactoryRequestResponse{S,Req,Resp,ReqH,RespH}, handler::AbstractServerDetailsHandler) where {S,Req,Resp,ReqH,RespH}
    handler_ref = Ref(handler)
    GC.@preserve handler_ref begin
        Iceoryx2FFI.iox2_port_factory_request_response_dynamic_config_list_servers(
            Ref{Iceoryx2FFI.iox2_port_factory_request_response_h}(factory.handle),
            _server_details_cfunction(handler_ref[]),
            handler_ref,
        )
    end
    return nothing
end

function list_servers(f::Function, factory::PortFactoryRequestResponse{S,Req,Resp,ReqH,RespH}) where {S,Req,Resp,ReqH,RespH}
    return list_servers(factory, ServerDetailsHandler(f))
end

"""
    AbstractBlackboardKeyHandler{K}

Abstract callback handler for `list_keys`.
"""
abstract type AbstractBlackboardKeyHandler{K} end

"""
    BlackboardKeyHandler{K}(f)

Wrap a callable `f(key)` for blackboard key iteration.
"""
mutable struct BlackboardKeyHandler{K, T} <: AbstractBlackboardKeyHandler{K}
    on_key::T
end

BlackboardKeyHandler{K}(f) where {K} = BlackboardKeyHandler{K, typeof(f)}(f)

on_blackboard_key(h::BlackboardKeyHandler) = h.on_key

function _blackboard_key_wrapper(key_ptr::Ptr{Cvoid}, handler::AbstractBlackboardKeyHandler{K}) where {K}
    key = unsafe_load(Ptr{K}(key_ptr))
    return _callback_progression(on_blackboard_key(handler)(key))
end

function _blackboard_key_cfunction(::T) where {T<:AbstractBlackboardKeyHandler}
    @cfunction(_blackboard_key_wrapper, Iceoryx2FFI.iox2_callback_progression_e, (Ptr{Cvoid}, Ref{T}))
end

"""
    list_keys(factory, ::Type{K}, handler)
    list_keys(f::Function, factory, ::Type{K})

Iterate over keys present in a blackboard.
"""
function list_keys(factory::PortFactoryBlackboard{S,K}, ::Type{K}, handler::AbstractBlackboardKeyHandler{K}) where {S,K}
    _require_isbits(K)
    handler_ref = Ref(handler)
    GC.@preserve handler_ref begin
        Iceoryx2FFI.iox2_port_factory_blackboard_list_keys(
            Ref{Iceoryx2FFI.iox2_port_factory_blackboard_h}(factory.handle),
            _blackboard_key_cfunction(handler_ref[]),
            handler_ref,
        )
    end
    return nothing
end

function list_keys(f::Function, factory::PortFactoryBlackboard{S,K}, ::Type{K}) where {S,K}
    return list_keys(factory, K, BlackboardKeyHandler{K}(f))
end


"""
    list_readers(factory, handler)
    list_readers(f::Function, factory)

Iterate over entry reader details for a blackboard.
"""
function list_readers(factory::PortFactoryBlackboard{S,K}, handler::AbstractEntryReaderDetailsHandler) where {S,K}
    handler_ref = Ref(handler)
    GC.@preserve handler_ref begin
        Iceoryx2FFI.iox2_port_factory_blackboard_dynamic_config_list_readers(
            Ref{Iceoryx2FFI.iox2_port_factory_blackboard_h}(factory.handle),
            _reader_details_cfunction(handler_ref[]),
            handler_ref,
        )
    end
    return nothing
end

function list_readers(f::Function, factory::PortFactoryBlackboard{S,K}) where {S,K}
    return list_readers(factory, EntryReaderDetailsHandler(f))
end

"""
    list_writers(factory, handler)
    list_writers(f::Function, factory)

Iterate over entry writer details for a blackboard.
"""
function list_writers(factory::PortFactoryBlackboard{S,K}, handler::AbstractEntryWriterDetailsHandler) where {S,K}
    handler_ref = Ref(handler)
    GC.@preserve handler_ref begin
        Iceoryx2FFI.iox2_port_factory_blackboard_dynamic_config_list_writers(
            Ref{Iceoryx2FFI.iox2_port_factory_blackboard_h}(factory.handle),
            _writer_details_cfunction(handler_ref[]),
            handler_ref,
        )
    end
    return nothing
end

function list_writers(f::Function, factory::PortFactoryBlackboard{S,K}) where {S,K}
    return list_writers(factory, EntryWriterDetailsHandler(f))
end

# === Details accessors ===
# Implemented in src/generated/wrappers.jl

# === Config defaults ===
# Implemented in src/generated/wrappers.jl (except specialized helpers below)

# === Global config fields ===

function global_service_creation_timeout(config::Union{Config, ConfigRef})
    secs = Ref{UInt64}()
    nsecs = Ref{UInt32}()
    Iceoryx2FFI.iox2_config_global_service_creation_timeout(_config_h_ref(config), secs, nsecs)
    return secs[], nsecs[]
end

function global_service_creation_timeout!(config::Union{Config, ConfigRef}, seconds::Integer, nanoseconds::Integer)
    Iceoryx2FFI.iox2_config_global_service_set_creation_timeout(
        _config_h_ref(config),
        UInt64(seconds),
        UInt32(nanoseconds),
    )
    return config
end
