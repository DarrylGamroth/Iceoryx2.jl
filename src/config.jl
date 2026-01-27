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

function default_config()
    handle_ref = Ref{Iceoryx2FFI.iox2_config_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_config_default(C_NULL, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_config_creation_error_e)
    return Config(handle_ref[])
end

@inline function global_config()
    return ConfigView(Iceoryx2FFI.iox2_config_global_config())
end

@inline function config_view(config::Config)
    return ConfigView(Iceoryx2FFI.iox2_cast_config_ptr(unsafe_handle(config)))
end

@inline function node_config(node::Node)
    return ConfigView(Iceoryx2FFI.iox2_node_config(Ref{Iceoryx2FFI.iox2_node_h}(unsafe_handle(node))))
end

struct StaticConfig
    raw::Iceoryx2FFI.iox2_static_config_t
end

struct StaticConfigDetails
    raw::Iceoryx2FFI.iox2_static_config_details_t
end

struct StaticConfigEvent
    raw::Iceoryx2FFI.iox2_static_config_event_t
end

struct StaticConfigPublishSubscribe
    raw::Iceoryx2FFI.iox2_static_config_publish_subscribe_t
end

struct StaticConfigRequestResponse
    raw::Iceoryx2FFI.iox2_static_config_request_response_t
end

struct StaticConfigBlackboard
    raw::Iceoryx2FFI.iox2_static_config_blackboard_t
end

@inline id(config::StaticConfig) = _cstring_from_ntuple(config.raw.id)
@inline name(config::StaticConfig) = _cstring_from_ntuple(config.raw.name)
@inline messaging_pattern(config::StaticConfig) = config.raw.messaging_pattern
@inline details(config::StaticConfig) = StaticConfigDetails(config.raw.details)

function attributes(config::StaticConfig)
    handle = config.raw.attributes
    handle == _IOX2_NULL && return AttributeSetView(Iceoryx2FFI.iox2_attribute_set_ptr(_IOX2_NULL))
    return AttributeSetView(Iceoryx2FFI.iox2_cast_attribute_set_ptr(handle))
end

@inline event(details::StaticConfigDetails) = StaticConfigEvent(details.raw.event)
@inline publish_subscribe(details::StaticConfigDetails) = StaticConfigPublishSubscribe(details.raw.publish_subscribe)
@inline request_response(details::StaticConfigDetails) = StaticConfigRequestResponse(details.raw.request_response)
@inline blackboard(details::StaticConfigDetails) = StaticConfigBlackboard(details.raw.blackboard)

@inline function _service_name_ptr(name::ServiceName)
    return _service_name_ptr(unsafe_handle(name))
end

@inline function _service_name_ptr(name::ServiceNameView)
    return unsafe_handle(name)
end

function service_does_exist(
    service_name::Union{ServiceName, ServiceNameView};
    service_type::Union{Symbol, Iceoryx2FFI.iox2_service_type_e} = :ipc,
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
    service_type::Union{Symbol, Iceoryx2FFI.iox2_service_type_e} = :ipc,
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

function service_details(
    service_name::Union{ServiceName, ServiceNameView};
    service_type::Union{Symbol, Iceoryx2FFI.iox2_service_type_e} = :ipc,
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
    service_type::Union{Symbol, Iceoryx2FFI.iox2_service_type_e} = :ipc,
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

function list_services(
    handler::AbstractServiceListHandler;
    service_type::Union{Symbol, Iceoryx2FFI.iox2_service_type_e} = :ipc,
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
    service_type::Union{Symbol, Iceoryx2FFI.iox2_service_type_e} = :ipc,
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

abstract type AbstractReaderDetailsHandler end

mutable struct ReaderDetailsHandler{T} <: AbstractReaderDetailsHandler
    on_details::T
end

on_reader_details(h::ReaderDetailsHandler) = h.on_details

function _reader_details_wrapper(handler::AbstractReaderDetailsHandler, details_ptr::Iceoryx2FFI.iox2_reader_details_ptr)
    return _callback_progression(on_reader_details(handler)(ReaderDetailsView(details_ptr)))
end

function _reader_details_cfunction(::T) where {T<:AbstractReaderDetailsHandler}
    @cfunction(
        _reader_details_wrapper,
        Iceoryx2FFI.iox2_callback_progression_e,
        (Ref{T}, Iceoryx2FFI.iox2_reader_details_ptr),
    )
end

abstract type AbstractWriterDetailsHandler end

mutable struct WriterDetailsHandler{T} <: AbstractWriterDetailsHandler
    on_details::T
end

on_writer_details(h::WriterDetailsHandler) = h.on_details

function _writer_details_wrapper(handler::AbstractWriterDetailsHandler, details_ptr::Iceoryx2FFI.iox2_writer_details_ptr)
    return _callback_progression(on_writer_details(handler)(WriterDetailsView(details_ptr)))
end

function _writer_details_cfunction(::T) where {T<:AbstractWriterDetailsHandler}
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

@inline function number_of_publishers(factory::PortFactoryPubSub{T}) where {T}
    return Int(Iceoryx2FFI.iox2_port_factory_pub_sub_dynamic_config_number_of_publishers(Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_h}(factory.handle)))
end

@inline function number_of_subscribers(factory::PortFactoryPubSub{T}) where {T}
    return Int(Iceoryx2FFI.iox2_port_factory_pub_sub_dynamic_config_number_of_subscribers(Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_h}(factory.handle)))
end

function list_publishers(factory::PortFactoryPubSub{T}, handler::AbstractPublisherDetailsHandler) where {T}
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

function list_publishers(f::Function, factory::PortFactoryPubSub{T}) where {T}
    return list_publishers(factory, PublisherDetailsHandler(f))
end

function list_publishers(factory::PortFactoryPubSub{T}, f::Function) where {T}
    return list_publishers(f, factory)
end

function list_subscribers(factory::PortFactoryPubSub{T}, handler::AbstractSubscriberDetailsHandler) where {T}
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

function list_subscribers(f::Function, factory::PortFactoryPubSub{T}) where {T}
    return list_subscribers(factory, SubscriberDetailsHandler(f))
end

function list_subscribers(factory::PortFactoryPubSub{T}, f::Function) where {T}
    return list_subscribers(f, factory)
end

@inline function number_of_listeners(factory::PortFactoryEvent)
    return Int(Iceoryx2FFI.iox2_port_factory_event_dynamic_config_number_of_listeners(Ref{Iceoryx2FFI.iox2_port_factory_event_h}(factory.handle)))
end

@inline function number_of_notifiers(factory::PortFactoryEvent)
    return Int(Iceoryx2FFI.iox2_port_factory_event_dynamic_config_number_of_notifiers(Ref{Iceoryx2FFI.iox2_port_factory_event_h}(factory.handle)))
end

function list_listeners(factory::PortFactoryEvent, handler::AbstractListenerDetailsHandler)
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

function list_listeners(f::Function, factory::PortFactoryEvent)
    return list_listeners(factory, ListenerDetailsHandler(f))
end

function list_listeners(factory::PortFactoryEvent, f::Function)
    return list_listeners(f, factory)
end

function list_notifiers(factory::PortFactoryEvent, handler::AbstractNotifierDetailsHandler)
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

function list_notifiers(f::Function, factory::PortFactoryEvent)
    return list_notifiers(factory, NotifierDetailsHandler(f))
end

function list_notifiers(factory::PortFactoryEvent, f::Function)
    return list_notifiers(f, factory)
end

@inline function number_of_clients(factory::PortFactoryRequestResponse{Req,Resp}) where {Req,Resp}
    return Int(Iceoryx2FFI.iox2_port_factory_request_response_dynamic_config_number_of_clients(Ref{Iceoryx2FFI.iox2_port_factory_request_response_h}(factory.handle)))
end

@inline function number_of_servers(factory::PortFactoryRequestResponse{Req,Resp}) where {Req,Resp}
    return Int(Iceoryx2FFI.iox2_port_factory_request_response_dynamic_config_number_of_servers(Ref{Iceoryx2FFI.iox2_port_factory_request_response_h}(factory.handle)))
end

function list_clients(factory::PortFactoryRequestResponse{Req,Resp}, handler::AbstractClientDetailsHandler) where {Req,Resp}
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

function list_clients(f::Function, factory::PortFactoryRequestResponse{Req,Resp}) where {Req,Resp}
    return list_clients(factory, ClientDetailsHandler(f))
end

function list_clients(factory::PortFactoryRequestResponse{Req,Resp}, f::Function) where {Req,Resp}
    return list_clients(f, factory)
end

function list_servers(factory::PortFactoryRequestResponse{Req,Resp}, handler::AbstractServerDetailsHandler) where {Req,Resp}
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

function list_servers(f::Function, factory::PortFactoryRequestResponse{Req,Resp}) where {Req,Resp}
    return list_servers(factory, ServerDetailsHandler(f))
end

function list_servers(factory::PortFactoryRequestResponse{Req,Resp}, f::Function) where {Req,Resp}
    return list_servers(f, factory)
end

abstract type AbstractBlackboardKeyHandler{K} end

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

function list_keys(factory::PortFactoryBlackboard{K}, ::Type{K}, handler::AbstractBlackboardKeyHandler{K}) where {K}
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

function list_keys(f::Function, factory::PortFactoryBlackboard{K}, ::Type{K}) where {K}
    return list_keys(factory, K, BlackboardKeyHandler{K}(f))
end

function list_keys(factory::PortFactoryBlackboard{K}, ::Type{K}, f::Function) where {K}
    return list_keys(f, factory, K)
end

@inline function number_of_readers(factory::PortFactoryBlackboard{K}) where {K}
    return Int(Iceoryx2FFI.iox2_port_factory_blackboard_dynamic_config_number_of_readers(Ref{Iceoryx2FFI.iox2_port_factory_blackboard_h}(factory.handle)))
end

@inline function number_of_writers(factory::PortFactoryBlackboard{K}) where {K}
    return Int(Iceoryx2FFI.iox2_port_factory_blackboard_dynamic_config_number_of_writers(Ref{Iceoryx2FFI.iox2_port_factory_blackboard_h}(factory.handle)))
end

function list_readers(factory::PortFactoryBlackboard{K}, handler::AbstractReaderDetailsHandler) where {K}
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

function list_readers(f::Function, factory::PortFactoryBlackboard{K}) where {K}
    return list_readers(factory, ReaderDetailsHandler(f))
end

function list_readers(factory::PortFactoryBlackboard{K}, f::Function) where {K}
    return list_readers(f, factory)
end

function list_writers(factory::PortFactoryBlackboard{K}, handler::AbstractWriterDetailsHandler) where {K}
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

function list_writers(f::Function, factory::PortFactoryBlackboard{K}) where {K}
    return list_writers(factory, WriterDetailsHandler(f))
end

function list_writers(factory::PortFactoryBlackboard{K}, f::Function) where {K}
    return list_writers(f, factory)
end
