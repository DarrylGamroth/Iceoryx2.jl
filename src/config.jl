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

function config_from_file(path::AbstractString)
    file = String(path)
    handle_ref = Ref{Iceoryx2FFI.iox2_config_h}(_IOX2_NULL)
    GC.@preserve file begin
        ret = Iceoryx2FFI.iox2_config_from_file(C_NULL, handle_ref, Base.unsafe_convert(Cstring, file))
        check_ok(ret, Iceoryx2FFI.iox2_config_creation_error_e)
    end
    return Config(handle_ref[])
end

function config_from_ptr(config::ConfigView)
    handle_ref = Ref{Iceoryx2FFI.iox2_config_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_config_from_ptr(unsafe_handle(config), C_NULL, handle_ref)
    return Config(handle_ref[])
end

function config_clone(config::Config)
    handle_ref = Ref{Iceoryx2FFI.iox2_config_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_config_clone(_config_h_ref(config), C_NULL, handle_ref)
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

# === Details accessors ===

@inline function client_id(details::ClientDetailsView)
    handle_ref = Ref{Iceoryx2FFI.iox2_unique_client_id_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_client_details_client_id(unsafe_handle(details), C_NULL, handle_ref)
    return UniqueClientId(handle_ref[])
end

@inline function node_id(details::ClientDetailsView)
    return NodeIdView(Iceoryx2FFI.iox2_client_details_node_id(unsafe_handle(details)))
end

@inline function number_of_requests(details::ClientDetailsView)
    return Int(Iceoryx2FFI.iox2_client_details_number_of_requests(unsafe_handle(details)))
end

@inline function response_buffer_size(details::ClientDetailsView)
    return Int(Iceoryx2FFI.iox2_client_details_response_buffer_size(unsafe_handle(details)))
end

@inline function max_slice_len(details::ClientDetailsView)
    return Int(Iceoryx2FFI.iox2_client_details_max_slice_len(unsafe_handle(details)))
end

@inline function listener_id(details::ListenerDetailsView)
    handle_ref = Ref{Iceoryx2FFI.iox2_unique_listener_id_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_listener_details_listener_id(unsafe_handle(details), C_NULL, handle_ref)
    return UniqueListenerId(handle_ref[])
end

@inline function node_id(details::ListenerDetailsView)
    return NodeIdView(Iceoryx2FFI.iox2_listener_details_node_id(unsafe_handle(details)))
end

@inline function notifier_id(details::NotifierDetailsView)
    handle_ref = Ref{Iceoryx2FFI.iox2_unique_notifier_id_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_notifier_details_notifier_id(unsafe_handle(details), C_NULL, handle_ref)
    return UniqueNotifierId(handle_ref[])
end

@inline function node_id(details::NotifierDetailsView)
    return NodeIdView(Iceoryx2FFI.iox2_notifier_details_node_id(unsafe_handle(details)))
end

@inline function publisher_id(details::PublisherDetailsView)
    handle_ref = Ref{Iceoryx2FFI.iox2_unique_publisher_id_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_publisher_details_publisher_id(unsafe_handle(details), C_NULL, handle_ref)
    return UniquePublisherId(handle_ref[])
end

@inline function node_id(details::PublisherDetailsView)
    return NodeIdView(Iceoryx2FFI.iox2_publisher_details_node_id(unsafe_handle(details)))
end

@inline function number_of_samples(details::PublisherDetailsView)
    return Int(Iceoryx2FFI.iox2_publisher_details_number_of_samples(unsafe_handle(details)))
end

@inline function max_slice_len(details::PublisherDetailsView)
    return Int(Iceoryx2FFI.iox2_publisher_details_max_slice_len(unsafe_handle(details)))
end

@inline function reader_id(details::ReaderDetailsView)
    handle_ref = Ref{Iceoryx2FFI.iox2_unique_reader_id_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_reader_details_reader_id(unsafe_handle(details), C_NULL, handle_ref)
    return UniqueReaderId(handle_ref[])
end

@inline function node_id(details::ReaderDetailsView)
    return NodeIdView(Iceoryx2FFI.iox2_reader_details_node_id(unsafe_handle(details)))
end

@inline function server_id(details::ServerDetailsView)
    handle_ref = Ref{Iceoryx2FFI.iox2_unique_server_id_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_server_details_server_id(unsafe_handle(details), C_NULL, handle_ref)
    return UniqueServerId(handle_ref[])
end

@inline function node_id(details::ServerDetailsView)
    return NodeIdView(Iceoryx2FFI.iox2_server_details_node_id(unsafe_handle(details)))
end

@inline function number_of_responses(details::ServerDetailsView)
    return Int(Iceoryx2FFI.iox2_server_details_number_of_responses(unsafe_handle(details)))
end

@inline function request_buffer_size(details::ServerDetailsView)
    return Int(Iceoryx2FFI.iox2_server_details_request_buffer_size(unsafe_handle(details)))
end

@inline function max_slice_len(details::ServerDetailsView)
    return Int(Iceoryx2FFI.iox2_server_details_max_slice_len(unsafe_handle(details)))
end

@inline function subscriber_id(details::SubscriberDetailsView)
    handle_ref = Ref{Iceoryx2FFI.iox2_unique_subscriber_id_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_subscriber_details_subscriber_id(unsafe_handle(details), C_NULL, handle_ref)
    return UniqueSubscriberId(handle_ref[])
end

@inline function node_id(details::SubscriberDetailsView)
    return NodeIdView(Iceoryx2FFI.iox2_subscriber_details_node_id(unsafe_handle(details)))
end

@inline function buffer_size(details::SubscriberDetailsView)
    return Int(Iceoryx2FFI.iox2_subscriber_details_buffer_size(unsafe_handle(details)))
end

@inline function writer_id(details::WriterDetailsView)
    handle_ref = Ref{Iceoryx2FFI.iox2_unique_writer_id_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_writer_details_writer_id(unsafe_handle(details), C_NULL, handle_ref)
    return UniqueWriterId(handle_ref[])
end

@inline function node_id(details::WriterDetailsView)
    return NodeIdView(Iceoryx2FFI.iox2_writer_details_node_id(unsafe_handle(details)))
end

# === Config defaults ===

@inline function defaults_publish_subscribe_max_nodes(config::Union{Config, ConfigRef})
    return Int(Iceoryx2FFI.iox2_config_defaults_publish_subscribe_max_nodes(_config_h_ref(config)))
end

function defaults_publish_subscribe_max_nodes!(config::Union{Config, ConfigRef}, value::Integer)
    Iceoryx2FFI.iox2_config_defaults_publish_subscribe_set_max_nodes(_config_h_ref(config), Iceoryx2FFI.c_size_t(value))
    return config
end

@inline function defaults_publish_subscribe_max_publishers(config::Union{Config, ConfigRef})
    return Int(Iceoryx2FFI.iox2_config_defaults_publish_subscribe_max_publishers(_config_h_ref(config)))
end

function defaults_publish_subscribe_max_publishers!(config::Union{Config, ConfigRef}, value::Integer)
    Iceoryx2FFI.iox2_config_defaults_publish_subscribe_set_max_publishers(_config_h_ref(config), Iceoryx2FFI.c_size_t(value))
    return config
end

@inline function defaults_publish_subscribe_max_subscribers(config::Union{Config, ConfigRef})
    return Int(Iceoryx2FFI.iox2_config_defaults_publish_subscribe_max_subscribers(_config_h_ref(config)))
end

function defaults_publish_subscribe_max_subscribers!(config::Union{Config, ConfigRef}, value::Integer)
    Iceoryx2FFI.iox2_config_defaults_publish_subscribe_set_max_subscribers(_config_h_ref(config), Iceoryx2FFI.c_size_t(value))
    return config
end

@inline function defaults_publish_subscribe_history_size(config::Union{Config, ConfigRef})
    return Int(Iceoryx2FFI.iox2_config_defaults_publish_subscribe_publisher_history_size(_config_h_ref(config)))
end

function defaults_publish_subscribe_history_size!(config::Union{Config, ConfigRef}, value::Integer)
    Iceoryx2FFI.iox2_config_defaults_publish_subscribe_set_publisher_history_size(_config_h_ref(config), Iceoryx2FFI.c_size_t(value))
    return config
end

@inline function defaults_publish_subscribe_max_loaned_samples(config::Union{Config, ConfigRef})
    return Int(Iceoryx2FFI.iox2_config_defaults_publish_subscribe_publisher_max_loaned_samples(_config_h_ref(config)))
end

function defaults_publish_subscribe_max_loaned_samples!(config::Union{Config, ConfigRef}, value::Integer)
    Iceoryx2FFI.iox2_config_defaults_publish_subscribe_set_publisher_max_loaned_samples(_config_h_ref(config), Iceoryx2FFI.c_size_t(value))
    return config
end

@inline function defaults_publish_subscribe_subscriber_max_buffer_size(config::Union{Config, ConfigRef})
    return Int(Iceoryx2FFI.iox2_config_defaults_publish_subscribe_subscriber_max_buffer_size(_config_h_ref(config)))
end

function defaults_publish_subscribe_subscriber_max_buffer_size!(config::Union{Config, ConfigRef}, value::Integer)
    Iceoryx2FFI.iox2_config_defaults_publish_subscribe_set_subscriber_max_buffer_size(
        _config_h_ref(config),
        Iceoryx2FFI.c_size_t(value),
    )
    return config
end

@inline function defaults_publish_subscribe_subscriber_max_borrowed_samples(config::Union{Config, ConfigRef})
    return Int(Iceoryx2FFI.iox2_config_defaults_publish_subscribe_subscriber_max_borrowed_samples(_config_h_ref(config)))
end

function defaults_publish_subscribe_subscriber_max_borrowed_samples!(config::Union{Config, ConfigRef}, value::Integer)
    Iceoryx2FFI.iox2_config_defaults_publish_subscribe_set_subscriber_max_borrowed_samples(
        _config_h_ref(config),
        Iceoryx2FFI.c_size_t(value),
    )
    return config
end

@inline function defaults_publish_subscribe_subscriber_expired_connection_buffer(config::Union{Config, ConfigRef})
    return Int(Iceoryx2FFI.iox2_config_defaults_publish_subscribe_subscriber_expired_connection_buffer(_config_h_ref(config)))
end

function defaults_publish_subscribe_subscriber_expired_connection_buffer!(config::Union{Config, ConfigRef}, value::Integer)
    Iceoryx2FFI.iox2_config_defaults_publish_subscribe_set_subscriber_expired_connection_buffer(
        _config_h_ref(config),
        Iceoryx2FFI.c_size_t(value),
    )
    return config
end

@inline function defaults_publish_subscribe_unable_to_deliver_strategy(config::Union{Config, ConfigRef})
    return Iceoryx2FFI.iox2_unable_to_deliver_strategy_e(
        Iceoryx2FFI.iox2_config_defaults_publish_subscribe_unable_to_deliver_strategy(_config_h_ref(config)),
    )
end

function defaults_publish_subscribe_unable_to_deliver_strategy!(
    config::Union{Config, ConfigRef},
    value::Union{Symbol, Iceoryx2FFI.iox2_unable_to_deliver_strategy_e},
)
    Iceoryx2FFI.iox2_config_defaults_publish_subscribe_set_unable_to_deliver_strategy(
        _config_h_ref(config),
        _unable_to_deliver_strategy(value),
    )
    return config
end

@inline function defaults_publish_subscribe_enable_safe_overflow(config::Union{Config, ConfigRef})
    return Iceoryx2FFI.iox2_config_defaults_publish_subscribe_enable_safe_overflow(_config_h_ref(config))
end

function defaults_publish_subscribe_enable_safe_overflow!(config::Union{Config, ConfigRef}, value::Bool)
    Iceoryx2FFI.iox2_config_defaults_publish_subscribe_set_enable_safe_overflow(_config_h_ref(config), value)
    return config
end

@inline function defaults_request_response_max_nodes(config::Union{Config, ConfigRef})
    return Int(Iceoryx2FFI.iox2_config_defaults_request_response_max_nodes(_config_h_ref(config)))
end

function defaults_request_response_max_nodes!(config::Union{Config, ConfigRef}, value::Integer)
    Iceoryx2FFI.iox2_config_defaults_request_response_set_max_nodes(_config_h_ref(config), Iceoryx2FFI.c_size_t(value))
    return config
end

@inline function defaults_request_response_max_clients(config::Union{Config, ConfigRef})
    return Int(Iceoryx2FFI.iox2_config_defaults_request_response_max_clients(_config_h_ref(config)))
end

function defaults_request_response_max_clients!(config::Union{Config, ConfigRef}, value::Integer)
    Iceoryx2FFI.iox2_config_defaults_request_response_set_max_clients(_config_h_ref(config), Iceoryx2FFI.c_size_t(value))
    return config
end

@inline function defaults_request_response_max_servers(config::Union{Config, ConfigRef})
    return Int(Iceoryx2FFI.iox2_config_defaults_request_response_max_servers(_config_h_ref(config)))
end

function defaults_request_response_max_servers!(config::Union{Config, ConfigRef}, value::Integer)
    Iceoryx2FFI.iox2_config_defaults_request_response_set_max_servers(_config_h_ref(config), Iceoryx2FFI.c_size_t(value))
    return config
end

@inline function defaults_request_response_max_loaned_requests(config::Union{Config, ConfigRef})
    return Int(Iceoryx2FFI.iox2_config_defaults_request_response_max_loaned_requests(_config_h_ref(config)))
end

function defaults_request_response_max_loaned_requests!(config::Union{Config, ConfigRef}, value::Integer)
    Iceoryx2FFI.iox2_config_defaults_request_response_set_max_loaned_requests(
        _config_h_ref(config),
        Iceoryx2FFI.c_size_t(value),
    )
    return config
end

@inline function defaults_request_response_max_active_requests_per_client(config::Union{Config, ConfigRef})
    return Int(Iceoryx2FFI.iox2_config_defaults_request_response_max_active_requests_per_client(_config_h_ref(config)))
end

function defaults_request_response_max_active_requests_per_client!(config::Union{Config, ConfigRef}, value::Integer)
    Iceoryx2FFI.iox2_config_defaults_request_response_set_max_active_requests_per_client(
        _config_h_ref(config),
        Iceoryx2FFI.c_size_t(value),
    )
    return config
end

@inline function defaults_request_response_max_response_buffer_size(config::Union{Config, ConfigRef})
    return Int(Iceoryx2FFI.iox2_config_defaults_request_response_max_response_buffer_size(_config_h_ref(config)))
end

function defaults_request_response_max_response_buffer_size!(config::Union{Config, ConfigRef}, value::Integer)
    Iceoryx2FFI.iox2_config_defaults_request_response_set_max_response_buffer_size(
        _config_h_ref(config),
        Iceoryx2FFI.c_size_t(value),
    )
    return config
end

@inline function defaults_request_response_max_borrowed_responses_per_pending_response(config::Union{Config, ConfigRef})
    return Int(Iceoryx2FFI.iox2_config_defaults_request_response_max_borrowed_responses_per_pending_response(_config_h_ref(config)))
end

function defaults_request_response_max_borrowed_responses_per_pending_response!(config::Union{Config, ConfigRef}, value::Integer)
    Iceoryx2FFI.iox2_config_defaults_request_response_set_max_borrowed_responses_per_pending_response(
        _config_h_ref(config),
        Iceoryx2FFI.c_size_t(value),
    )
    return config
end

@inline function defaults_request_response_enable_safe_overflow_for_requests(config::Union{Config, ConfigRef})
    return Iceoryx2FFI.iox2_config_defaults_request_response_enable_safe_overflow_for_requests(_config_h_ref(config))
end

function defaults_request_response_enable_safe_overflow_for_requests!(config::Union{Config, ConfigRef}, value::Bool)
    Iceoryx2FFI.iox2_config_defaults_request_response_set_enable_safe_overflow_for_requests(_config_h_ref(config), value)
    return config
end

@inline function defaults_request_response_enable_safe_overflow_for_responses(config::Union{Config, ConfigRef})
    return Iceoryx2FFI.iox2_config_defaults_request_response_enable_safe_overflow_for_responses(_config_h_ref(config))
end

function defaults_request_response_enable_safe_overflow_for_responses!(config::Union{Config, ConfigRef}, value::Bool)
    Iceoryx2FFI.iox2_config_defaults_request_response_set_enable_safe_overflow_for_responses(_config_h_ref(config), value)
    return config
end

@inline function defaults_request_response_fire_and_forget_requests(config::Union{Config, ConfigRef})
    return Iceoryx2FFI.iox2_config_defaults_request_response_has_fire_and_forget_requests(_config_h_ref(config))
end

function defaults_request_response_fire_and_forget_requests!(config::Union{Config, ConfigRef}, value::Bool)
    Iceoryx2FFI.iox2_config_defaults_request_response_set_fire_and_forget_requests(_config_h_ref(config), value)
    return config
end

@inline function defaults_request_response_client_expired_connection_buffer(config::Union{Config, ConfigRef})
    return Int(Iceoryx2FFI.iox2_config_defaults_request_response_client_expired_connection_buffer(_config_h_ref(config)))
end

function defaults_request_response_client_expired_connection_buffer!(config::Union{Config, ConfigRef}, value::Integer)
    Iceoryx2FFI.iox2_config_defaults_request_response_set_client_expired_connection_buffer(
        _config_h_ref(config),
        Iceoryx2FFI.c_size_t(value),
    )
    return config
end

@inline function defaults_request_response_server_expired_connection_buffer(config::Union{Config, ConfigRef})
    return Int(Iceoryx2FFI.iox2_config_defaults_request_response_server_expired_connection_buffer(_config_h_ref(config)))
end

function defaults_request_response_server_expired_connection_buffer!(config::Union{Config, ConfigRef}, value::Integer)
    Iceoryx2FFI.iox2_config_defaults_request_response_set_server_expired_connection_buffer(
        _config_h_ref(config),
        Iceoryx2FFI.c_size_t(value),
    )
    return config
end

@inline function defaults_request_response_server_max_loaned_responses_per_request(config::Union{Config, ConfigRef})
    return Int(Iceoryx2FFI.iox2_config_defaults_request_response_server_max_loaned_responses_per_request(_config_h_ref(config)))
end

function defaults_request_response_server_max_loaned_responses_per_request!(config::Union{Config, ConfigRef}, value::Integer)
    Iceoryx2FFI.iox2_config_defaults_request_response_set_server_max_loaned_responses_per_request(
        _config_h_ref(config),
        Iceoryx2FFI.c_size_t(value),
    )
    return config
end

@inline function defaults_request_response_client_unable_to_deliver_strategy(config::Union{Config, ConfigRef})
    return Iceoryx2FFI.iox2_unable_to_deliver_strategy_e(
        Iceoryx2FFI.iox2_config_defaults_request_response_client_unable_to_deliver_strategy(_config_h_ref(config)),
    )
end

function defaults_request_response_client_unable_to_deliver_strategy!(
    config::Union{Config, ConfigRef},
    value::Union{Symbol, Iceoryx2FFI.iox2_unable_to_deliver_strategy_e},
)
    Iceoryx2FFI.iox2_config_defaults_request_response_set_client_unable_to_deliver_strategy(
        _config_h_ref(config),
        _unable_to_deliver_strategy(value),
    )
    return config
end

@inline function defaults_request_response_server_unable_to_deliver_strategy(config::Union{Config, ConfigRef})
    return Iceoryx2FFI.iox2_unable_to_deliver_strategy_e(
        Iceoryx2FFI.iox2_config_defaults_request_response_server_unable_to_deliver_strategy(_config_h_ref(config)),
    )
end

function defaults_request_response_server_unable_to_deliver_strategy!(
    config::Union{Config, ConfigRef},
    value::Union{Symbol, Iceoryx2FFI.iox2_unable_to_deliver_strategy_e},
)
    Iceoryx2FFI.iox2_config_defaults_request_response_set_server_unable_to_deliver_strategy(
        _config_h_ref(config),
        _unable_to_deliver_strategy(value),
    )
    return config
end

@inline function defaults_event_max_nodes(config::Union{Config, ConfigRef})
    return Int(Iceoryx2FFI.iox2_config_defaults_event_max_nodes(_config_h_ref(config)))
end

function defaults_event_max_nodes!(config::Union{Config, ConfigRef}, value::Integer)
    Iceoryx2FFI.iox2_config_defaults_event_set_max_nodes(_config_h_ref(config), Iceoryx2FFI.c_size_t(value))
    return config
end

@inline function defaults_event_max_notifiers(config::Union{Config, ConfigRef})
    return Int(Iceoryx2FFI.iox2_config_defaults_event_max_notifiers(_config_h_ref(config)))
end

function defaults_event_max_notifiers!(config::Union{Config, ConfigRef}, value::Integer)
    Iceoryx2FFI.iox2_config_defaults_event_set_max_notifiers(_config_h_ref(config), Iceoryx2FFI.c_size_t(value))
    return config
end

@inline function defaults_event_max_listeners(config::Union{Config, ConfigRef})
    return Int(Iceoryx2FFI.iox2_config_defaults_event_max_listeners(_config_h_ref(config)))
end

function defaults_event_max_listeners!(config::Union{Config, ConfigRef}, value::Integer)
    Iceoryx2FFI.iox2_config_defaults_event_set_max_listeners(_config_h_ref(config), Iceoryx2FFI.c_size_t(value))
    return config
end

@inline function defaults_event_id_max_value(config::Union{Config, ConfigRef})
    return Int(Iceoryx2FFI.iox2_config_defaults_event_event_id_max_value(_config_h_ref(config)))
end

function defaults_event_id_max_value!(config::Union{Config, ConfigRef}, value::Integer)
    Iceoryx2FFI.iox2_config_defaults_event_set_event_id_max_value(_config_h_ref(config), Iceoryx2FFI.c_size_t(value))
    return config
end

function defaults_event_deadline(config::Union{Config, ConfigRef})
    seconds = Ref{UInt64}()
    nanoseconds = Ref{UInt32}()
    has = Iceoryx2FFI.iox2_config_defaults_event_deadline(_config_h_ref(config), seconds, nanoseconds)
    return has ? (seconds[], nanoseconds[]) : nothing
end

function defaults_event_deadline!(config::Union{Config, ConfigRef}, seconds::Integer, nanoseconds::Integer)
    sec_ref = Ref{UInt64}(UInt64(seconds))
    nsec_ref = Ref{UInt32}(UInt32(nanoseconds))
    Iceoryx2FFI.iox2_config_defaults_event_set_deadline(_config_h_ref(config), sec_ref, nsec_ref)
    return config
end

function defaults_event_notifier_created_event(config::Union{Config, ConfigRef})
    value = Ref{Iceoryx2FFI.c_size_t}()
    has = Iceoryx2FFI.iox2_config_defaults_event_notifier_created_event(_config_h_ref(config), value)
    return has ? Int(value[]) : nothing
end

function defaults_event_notifier_created_event!(config::Union{Config, ConfigRef}, value::Integer)
    val_ref = Ref{Iceoryx2FFI.c_size_t}(Iceoryx2FFI.c_size_t(value))
    Iceoryx2FFI.iox2_config_defaults_event_set_notifier_created_event(_config_h_ref(config), val_ref)
    return config
end

function defaults_event_notifier_dead_event(config::Union{Config, ConfigRef})
    value = Ref{Iceoryx2FFI.c_size_t}()
    has = Iceoryx2FFI.iox2_config_defaults_event_notifier_dead_event(_config_h_ref(config), value)
    return has ? Int(value[]) : nothing
end

function defaults_event_notifier_dead_event!(config::Union{Config, ConfigRef}, value::Integer)
    val_ref = Ref{Iceoryx2FFI.c_size_t}(Iceoryx2FFI.c_size_t(value))
    Iceoryx2FFI.iox2_config_defaults_event_set_notifier_dead_event(_config_h_ref(config), val_ref)
    return config
end

function defaults_event_notifier_dropped_event(config::Union{Config, ConfigRef})
    value = Ref{Iceoryx2FFI.c_size_t}()
    has = Iceoryx2FFI.iox2_config_defaults_event_notifier_dropped_event(_config_h_ref(config), value)
    return has ? Int(value[]) : nothing
end

function defaults_event_notifier_dropped_event!(config::Union{Config, ConfigRef}, value::Integer)
    val_ref = Ref{Iceoryx2FFI.c_size_t}(Iceoryx2FFI.c_size_t(value))
    Iceoryx2FFI.iox2_config_defaults_event_set_notifier_dropped_event(_config_h_ref(config), val_ref)
    return config
end

@inline function defaults_blackboard_max_nodes(config::Union{Config, ConfigRef})
    return Int(Iceoryx2FFI.iox2_config_defaults_blackboard_max_nodes(_config_h_ref(config)))
end

function defaults_blackboard_max_nodes!(config::Union{Config, ConfigRef}, value::Integer)
    Iceoryx2FFI.iox2_config_defaults_blackboard_set_max_nodes(_config_h_ref(config), Iceoryx2FFI.c_size_t(value))
    return config
end

@inline function defaults_blackboard_max_readers(config::Union{Config, ConfigRef})
    return Int(Iceoryx2FFI.iox2_config_defaults_blackboard_max_readers(_config_h_ref(config)))
end

function defaults_blackboard_max_readers!(config::Union{Config, ConfigRef}, value::Integer)
    Iceoryx2FFI.iox2_config_defaults_blackboard_set_max_readers(_config_h_ref(config), Iceoryx2FFI.c_size_t(value))
    return config
end

# === Global config fields ===

@inline function global_prefix(config::Union{Config, ConfigRef})
    return unsafe_string(Iceoryx2FFI.iox2_config_global_prefix(_config_h_ref(config)))
end

function global_prefix!(config::Union{Config, ConfigRef}, value::AbstractString)
    str = String(value)
    GC.@preserve str begin
        ret = Iceoryx2FFI.iox2_config_global_set_prefix(_config_h_ref(config), Base.unsafe_convert(Cstring, str))
        check_ok(ret, Iceoryx2FFI.iox2_semantic_string_error_e)
    end
    return config
end

@inline function global_root_path(config::Union{Config, ConfigRef})
    return unsafe_string(Iceoryx2FFI.iox2_config_global_root_path(_config_h_ref(config)))
end

function global_root_path!(config::Union{Config, ConfigRef}, value::AbstractString)
    str = String(value)
    GC.@preserve str begin
        ret = Iceoryx2FFI.iox2_config_global_set_root_path(_config_h_ref(config), Base.unsafe_convert(Cstring, str))
        check_ok(ret, Iceoryx2FFI.iox2_semantic_string_error_e)
    end
    return config
end

@inline function global_node_directory(config::Union{Config, ConfigRef})
    return unsafe_string(Iceoryx2FFI.iox2_config_global_node_directory(_config_h_ref(config)))
end

function global_node_directory!(config::Union{Config, ConfigRef}, value::AbstractString)
    str = String(value)
    GC.@preserve str begin
        ret = Iceoryx2FFI.iox2_config_global_node_set_directory(_config_h_ref(config), Base.unsafe_convert(Cstring, str))
        check_ok(ret, Iceoryx2FFI.iox2_semantic_string_error_e)
    end
    return config
end

@inline function global_node_monitor_suffix(config::Union{Config, ConfigRef})
    return unsafe_string(Iceoryx2FFI.iox2_config_global_node_monitor_suffix(_config_h_ref(config)))
end

function global_node_monitor_suffix!(config::Union{Config, ConfigRef}, value::AbstractString)
    str = String(value)
    GC.@preserve str begin
        ret = Iceoryx2FFI.iox2_config_global_node_set_monitor_suffix(_config_h_ref(config), Base.unsafe_convert(Cstring, str))
        check_ok(ret, Iceoryx2FFI.iox2_semantic_string_error_e)
    end
    return config
end

@inline function global_node_static_config_suffix(config::Union{Config, ConfigRef})
    return unsafe_string(Iceoryx2FFI.iox2_config_global_node_static_config_suffix(_config_h_ref(config)))
end

function global_node_static_config_suffix!(config::Union{Config, ConfigRef}, value::AbstractString)
    str = String(value)
    GC.@preserve str begin
        ret = Iceoryx2FFI.iox2_config_global_node_set_static_config_suffix(
            _config_h_ref(config),
            Base.unsafe_convert(Cstring, str),
        )
        check_ok(ret, Iceoryx2FFI.iox2_semantic_string_error_e)
    end
    return config
end

@inline function global_node_service_tag_suffix(config::Union{Config, ConfigRef})
    return unsafe_string(Iceoryx2FFI.iox2_config_global_node_service_tag_suffix(_config_h_ref(config)))
end

function global_node_service_tag_suffix!(config::Union{Config, ConfigRef}, value::AbstractString)
    str = String(value)
    GC.@preserve str begin
        ret = Iceoryx2FFI.iox2_config_global_node_set_service_tag_suffix(
            _config_h_ref(config),
            Base.unsafe_convert(Cstring, str),
        )
        check_ok(ret, Iceoryx2FFI.iox2_semantic_string_error_e)
    end
    return config
end

@inline function global_node_cleanup_dead_nodes_on_creation(config::Union{Config, ConfigRef})
    return Iceoryx2FFI.iox2_config_global_node_cleanup_dead_nodes_on_creation(_config_h_ref(config))
end

function global_node_cleanup_dead_nodes_on_creation!(config::Union{Config, ConfigRef}, value::Bool)
    Iceoryx2FFI.iox2_config_global_node_set_cleanup_dead_nodes_on_creation(_config_h_ref(config), value)
    return config
end

@inline function global_node_cleanup_dead_nodes_on_destruction(config::Union{Config, ConfigRef})
    return Iceoryx2FFI.iox2_config_global_node_cleanup_dead_nodes_on_destruction(_config_h_ref(config))
end

function global_node_cleanup_dead_nodes_on_destruction!(config::Union{Config, ConfigRef}, value::Bool)
    Iceoryx2FFI.iox2_config_global_node_set_cleanup_dead_nodes_on_destruction(_config_h_ref(config), value)
    return config
end

@inline function global_service_directory(config::Union{Config, ConfigRef})
    return unsafe_string(Iceoryx2FFI.iox2_config_global_service_directory(_config_h_ref(config)))
end

function global_service_directory!(config::Union{Config, ConfigRef}, value::AbstractString)
    str = String(value)
    GC.@preserve str begin
        ret = Iceoryx2FFI.iox2_config_global_service_set_directory(_config_h_ref(config), Base.unsafe_convert(Cstring, str))
        check_ok(ret, Iceoryx2FFI.iox2_semantic_string_error_e)
    end
    return config
end

@inline function global_service_data_segment_suffix(config::Union{Config, ConfigRef})
    return unsafe_string(Iceoryx2FFI.iox2_config_global_service_data_segment_suffix(_config_h_ref(config)))
end

function global_service_data_segment_suffix!(config::Union{Config, ConfigRef}, value::AbstractString)
    str = String(value)
    GC.@preserve str begin
        ret = Iceoryx2FFI.iox2_config_global_service_set_data_segment_suffix(
            _config_h_ref(config),
            Base.unsafe_convert(Cstring, str),
        )
        check_ok(ret, Iceoryx2FFI.iox2_semantic_string_error_e)
    end
    return config
end

@inline function global_service_static_config_storage_suffix(config::Union{Config, ConfigRef})
    return unsafe_string(Iceoryx2FFI.iox2_config_global_service_static_config_storage_suffix(_config_h_ref(config)))
end

function global_service_static_config_storage_suffix!(config::Union{Config, ConfigRef}, value::AbstractString)
    str = String(value)
    GC.@preserve str begin
        ret = Iceoryx2FFI.iox2_config_global_service_set_static_config_storage_suffix(
            _config_h_ref(config),
            Base.unsafe_convert(Cstring, str),
        )
        check_ok(ret, Iceoryx2FFI.iox2_semantic_string_error_e)
    end
    return config
end

@inline function global_service_dynamic_config_storage_suffix(config::Union{Config, ConfigRef})
    return unsafe_string(Iceoryx2FFI.iox2_config_global_service_dynamic_config_storage_suffix(_config_h_ref(config)))
end

function global_service_dynamic_config_storage_suffix!(config::Union{Config, ConfigRef}, value::AbstractString)
    str = String(value)
    GC.@preserve str begin
        ret = Iceoryx2FFI.iox2_config_global_service_set_dynamic_config_storage_suffix(
            _config_h_ref(config),
            Base.unsafe_convert(Cstring, str),
        )
        check_ok(ret, Iceoryx2FFI.iox2_semantic_string_error_e)
    end
    return config
end

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

@inline function global_service_connection_suffix(config::Union{Config, ConfigRef})
    return unsafe_string(Iceoryx2FFI.iox2_config_global_service_connection_suffix(_config_h_ref(config)))
end

function global_service_connection_suffix!(config::Union{Config, ConfigRef}, value::AbstractString)
    str = String(value)
    GC.@preserve str begin
        ret = Iceoryx2FFI.iox2_config_global_service_set_connection_suffix(
            _config_h_ref(config),
            Base.unsafe_convert(Cstring, str),
        )
        check_ok(ret, Iceoryx2FFI.iox2_semantic_string_error_e)
    end
    return config
end

@inline function global_service_event_connection_suffix(config::Union{Config, ConfigRef})
    return unsafe_string(Iceoryx2FFI.iox2_config_global_service_event_connection_suffix(_config_h_ref(config)))
end

function global_service_event_connection_suffix!(config::Union{Config, ConfigRef}, value::AbstractString)
    str = String(value)
    GC.@preserve str begin
        ret = Iceoryx2FFI.iox2_config_global_service_set_event_connection_suffix(
            _config_h_ref(config),
            Base.unsafe_convert(Cstring, str),
        )
        check_ok(ret, Iceoryx2FFI.iox2_semantic_string_error_e)
    end
    return config
end

@inline function global_service_blackboard_mgmt_suffix(config::Union{Config, ConfigRef})
    return unsafe_string(Iceoryx2FFI.iox2_config_global_service_blackboard_mgmt_suffix(_config_h_ref(config)))
end

function global_service_blackboard_mgmt_suffix!(config::Union{Config, ConfigRef}, value::AbstractString)
    str = String(value)
    GC.@preserve str begin
        ret = Iceoryx2FFI.iox2_config_global_service_set_blackboard_mgmt_suffix(
            _config_h_ref(config),
            Base.unsafe_convert(Cstring, str),
        )
        check_ok(ret, Iceoryx2FFI.iox2_semantic_string_error_e)
    end
    return config
end

@inline function global_service_blackboard_data_suffix(config::Union{Config, ConfigRef})
    return unsafe_string(Iceoryx2FFI.iox2_config_global_service_blackboard_data_suffix(_config_h_ref(config)))
end

function global_service_blackboard_data_suffix!(config::Union{Config, ConfigRef}, value::AbstractString)
    str = String(value)
    GC.@preserve str begin
        ret = Iceoryx2FFI.iox2_config_global_service_set_blackboard_data_suffix(
            _config_h_ref(config),
            Base.unsafe_convert(Cstring, str),
        )
        check_ok(ret, Iceoryx2FFI.iox2_semantic_string_error_e)
    end
    return config
end
