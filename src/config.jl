# Config, static config, and dynamic config helpers.

using FunctionWrappers: FunctionWrapper

@inline function _messaging_pattern(value)
    if value isa Iceoryx2FFI.iox2_messaging_pattern_e
        return value
    elseif value === :pubsub || value === :publish_subscribe
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

@inline function _cstring_from_ntuple(nt::NTuple{N, Cchar}) where {N}
    r = Ref(nt)
    ptr = Base.unsafe_convert(Ptr{Cchar}, r)
    return unsafe_string(ptr)
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
    service_name::Union{ServiceName, ServiceNameView, AbstractString};
    service_type::Union{Symbol, Iceoryx2FFI.iox2_service_type_e} = :ipc,
    messaging_pattern::Union{Symbol, Iceoryx2FFI.iox2_messaging_pattern_e} = :publish_subscribe,
    config::Union{Config, ConfigView, Nothing} = nothing,
)
    name_handle = service_name isa AbstractString ? ServiceName(service_name) : nothing
    name_arg = name_handle === nothing ? service_name : name_handle
    exists = Ref{Bool}(false)
    ret = Iceoryx2FFI.iox2_service_does_exist(
        _service_type(service_type),
        _service_name_ptr(name_arg),
        _config_ptr_from_arg(config),
        _messaging_pattern(messaging_pattern),
        exists,
    )
    name_handle !== nothing && close(name_handle)
    check_ok(ret, Iceoryx2FFI.iox2_service_details_error_e)
    return exists[]
end

function service_details(
    service_name::Union{ServiceName, ServiceNameView, AbstractString};
    service_type::Union{Symbol, Iceoryx2FFI.iox2_service_type_e} = :ipc,
    messaging_pattern::Union{Symbol, Iceoryx2FFI.iox2_messaging_pattern_e} = :publish_subscribe,
    config::Union{Config, ConfigView, Nothing} = nothing,
)
    name_handle = service_name isa AbstractString ? ServiceName(service_name) : nothing
    name_arg = name_handle === nothing ? service_name : name_handle
    details_ref = Ref{Iceoryx2FFI.iox2_static_config_t}()
    exists = Ref{Bool}(false)
    ret = Iceoryx2FFI.iox2_service_details(
        _service_type(service_type),
        _service_name_ptr(name_arg),
        _config_ptr_from_arg(config),
        _messaging_pattern(messaging_pattern),
        details_ref,
        exists,
    )
    name_handle !== nothing && close(name_handle)
    check_ok(ret, Iceoryx2FFI.iox2_service_details_error_e)
    return exists[], StaticConfig(details_ref[])
end

struct _ServiceListCallbackCtx
    fn::FunctionWrapper{Iceoryx2FFI.iox2_callback_progression_e, Tuple{StaticConfig}}
end

function _service_list_trampoline(config_ptr::Ptr{Iceoryx2FFI.iox2_static_config_t}, ctx::Ptr{Cvoid})::Iceoryx2FFI.iox2_callback_progression_e
    ctx_ref = unsafe_pointer_to_objref(ctx)::_ServiceListCallbackCtx
    return ctx_ref.fn(StaticConfig(unsafe_load(config_ptr)))
end

const _SERVICE_LIST_CB = @cfunction(
    _service_list_trampoline,
    Iceoryx2FFI.iox2_callback_progression_e,
    (Ptr{Iceoryx2FFI.iox2_static_config_t}, Ptr{Cvoid}),
)

function list_services(
    f::Function;
    service_type::Union{Symbol, Iceoryx2FFI.iox2_service_type_e} = :ipc,
    config::Union{Config, ConfigView, Nothing} = nothing,
)
    let user_f = f
        ctx = _ServiceListCallbackCtx(FunctionWrapper{Iceoryx2FFI.iox2_callback_progression_e, Tuple{StaticConfig}}(cfg -> _callback_progression(user_f(cfg))))
        ctx_ref = Ref(ctx)
        GC.@preserve ctx_ref begin
            ret = Iceoryx2FFI.iox2_service_list(_service_type(service_type), _config_ptr_from_arg(config), _SERVICE_LIST_CB, Base.unsafe_convert(Ptr{Cvoid}, ctx_ref))
            check_ok(ret, Iceoryx2FFI.iox2_service_list_error_e)
        end
    end
    return nothing
end

struct _PublisherDetailsCallbackCtx
    fn::FunctionWrapper{Iceoryx2FFI.iox2_callback_progression_e, Tuple{PublisherDetailsView}}
end

function _publisher_details_trampoline(ctx::Ptr{Cvoid}, details_ptr::Iceoryx2FFI.iox2_publisher_details_ptr)::Iceoryx2FFI.iox2_callback_progression_e
    ctx_ref = unsafe_pointer_to_objref(ctx)::_PublisherDetailsCallbackCtx
    return ctx_ref.fn(PublisherDetailsView(details_ptr))
end

const _PUBLISHER_DETAILS_CB = @cfunction(
    _publisher_details_trampoline,
    Iceoryx2FFI.iox2_callback_progression_e,
    (Ptr{Cvoid}, Iceoryx2FFI.iox2_publisher_details_ptr),
)

struct _SubscriberDetailsCallbackCtx
    fn::FunctionWrapper{Iceoryx2FFI.iox2_callback_progression_e, Tuple{SubscriberDetailsView}}
end

function _subscriber_details_trampoline(ctx::Ptr{Cvoid}, details_ptr::Iceoryx2FFI.iox2_subscriber_details_ptr)::Iceoryx2FFI.iox2_callback_progression_e
    ctx_ref = unsafe_pointer_to_objref(ctx)::_SubscriberDetailsCallbackCtx
    return ctx_ref.fn(SubscriberDetailsView(details_ptr))
end

const _SUBSCRIBER_DETAILS_CB = @cfunction(
    _subscriber_details_trampoline,
    Iceoryx2FFI.iox2_callback_progression_e,
    (Ptr{Cvoid}, Iceoryx2FFI.iox2_subscriber_details_ptr),
)

struct _ListenerDetailsCallbackCtx
    fn::FunctionWrapper{Iceoryx2FFI.iox2_callback_progression_e, Tuple{ListenerDetailsView}}
end

function _listener_details_trampoline(ctx::Ptr{Cvoid}, details_ptr::Iceoryx2FFI.iox2_listener_details_ptr)::Iceoryx2FFI.iox2_callback_progression_e
    ctx_ref = unsafe_pointer_to_objref(ctx)::_ListenerDetailsCallbackCtx
    return ctx_ref.fn(ListenerDetailsView(details_ptr))
end

const _LISTENER_DETAILS_CB = @cfunction(
    _listener_details_trampoline,
    Iceoryx2FFI.iox2_callback_progression_e,
    (Ptr{Cvoid}, Iceoryx2FFI.iox2_listener_details_ptr),
)

struct _NotifierDetailsCallbackCtx
    fn::FunctionWrapper{Iceoryx2FFI.iox2_callback_progression_e, Tuple{NotifierDetailsView}}
end

function _notifier_details_trampoline(ctx::Ptr{Cvoid}, details_ptr::Iceoryx2FFI.iox2_notifier_details_ptr)::Iceoryx2FFI.iox2_callback_progression_e
    ctx_ref = unsafe_pointer_to_objref(ctx)::_NotifierDetailsCallbackCtx
    return ctx_ref.fn(NotifierDetailsView(details_ptr))
end

const _NOTIFIER_DETAILS_CB = @cfunction(
    _notifier_details_trampoline,
    Iceoryx2FFI.iox2_callback_progression_e,
    (Ptr{Cvoid}, Iceoryx2FFI.iox2_notifier_details_ptr),
)

struct _ReaderDetailsCallbackCtx
    fn::FunctionWrapper{Iceoryx2FFI.iox2_callback_progression_e, Tuple{ReaderDetailsView}}
end

function _reader_details_trampoline(ctx::Ptr{Cvoid}, details_ptr::Iceoryx2FFI.iox2_reader_details_ptr)::Iceoryx2FFI.iox2_callback_progression_e
    ctx_ref = unsafe_pointer_to_objref(ctx)::_ReaderDetailsCallbackCtx
    return ctx_ref.fn(ReaderDetailsView(details_ptr))
end

const _READER_DETAILS_CB = @cfunction(
    _reader_details_trampoline,
    Iceoryx2FFI.iox2_callback_progression_e,
    (Ptr{Cvoid}, Iceoryx2FFI.iox2_reader_details_ptr),
)

struct _WriterDetailsCallbackCtx
    fn::FunctionWrapper{Iceoryx2FFI.iox2_callback_progression_e, Tuple{WriterDetailsView}}
end

function _writer_details_trampoline(ctx::Ptr{Cvoid}, details_ptr::Iceoryx2FFI.iox2_writer_details_ptr)::Iceoryx2FFI.iox2_callback_progression_e
    ctx_ref = unsafe_pointer_to_objref(ctx)::_WriterDetailsCallbackCtx
    return ctx_ref.fn(WriterDetailsView(details_ptr))
end

const _WRITER_DETAILS_CB = @cfunction(
    _writer_details_trampoline,
    Iceoryx2FFI.iox2_callback_progression_e,
    (Ptr{Cvoid}, Iceoryx2FFI.iox2_writer_details_ptr),
)

struct _ClientDetailsCallbackCtx
    fn::FunctionWrapper{Iceoryx2FFI.iox2_callback_progression_e, Tuple{ClientDetailsView}}
end

function _client_details_trampoline(ctx::Ptr{Cvoid}, details_ptr::Iceoryx2FFI.iox2_client_details_ptr)::Iceoryx2FFI.iox2_callback_progression_e
    ctx_ref = unsafe_pointer_to_objref(ctx)::_ClientDetailsCallbackCtx
    return ctx_ref.fn(ClientDetailsView(details_ptr))
end

const _CLIENT_DETAILS_CB = @cfunction(
    _client_details_trampoline,
    Iceoryx2FFI.iox2_callback_progression_e,
    (Ptr{Cvoid}, Iceoryx2FFI.iox2_client_details_ptr),
)

struct _ServerDetailsCallbackCtx
    fn::FunctionWrapper{Iceoryx2FFI.iox2_callback_progression_e, Tuple{ServerDetailsView}}
end

function _server_details_trampoline(ctx::Ptr{Cvoid}, details_ptr::Iceoryx2FFI.iox2_server_details_ptr)::Iceoryx2FFI.iox2_callback_progression_e
    ctx_ref = unsafe_pointer_to_objref(ctx)::_ServerDetailsCallbackCtx
    return ctx_ref.fn(ServerDetailsView(details_ptr))
end

const _SERVER_DETAILS_CB = @cfunction(
    _server_details_trampoline,
    Iceoryx2FFI.iox2_callback_progression_e,
    (Ptr{Cvoid}, Iceoryx2FFI.iox2_server_details_ptr),
)

@inline function number_of_publishers(factory::PortFactoryPubSub)
    return Int(Iceoryx2FFI.iox2_port_factory_pub_sub_dynamic_config_number_of_publishers(Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_h}(factory.handle)))
end

@inline function number_of_subscribers(factory::PortFactoryPubSub)
    return Int(Iceoryx2FFI.iox2_port_factory_pub_sub_dynamic_config_number_of_subscribers(Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_h}(factory.handle)))
end

function list_publishers(factory::PortFactoryPubSub, f::Function)
    let user_f = f
        ctx = _PublisherDetailsCallbackCtx(FunctionWrapper{Iceoryx2FFI.iox2_callback_progression_e, Tuple{PublisherDetailsView}}(details -> _callback_progression(user_f(details))))
        ctx_ref = Ref(ctx)
        GC.@preserve ctx_ref begin
            Iceoryx2FFI.iox2_port_factory_pub_sub_dynamic_config_list_publishers(Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_h}(factory.handle), _PUBLISHER_DETAILS_CB, Base.unsafe_convert(Ptr{Cvoid}, ctx_ref))
        end
    end
    return nothing
end

function list_subscribers(factory::PortFactoryPubSub, f::Function)
    let user_f = f
        ctx = _SubscriberDetailsCallbackCtx(FunctionWrapper{Iceoryx2FFI.iox2_callback_progression_e, Tuple{SubscriberDetailsView}}(details -> _callback_progression(user_f(details))))
        ctx_ref = Ref(ctx)
        GC.@preserve ctx_ref begin
            Iceoryx2FFI.iox2_port_factory_pub_sub_dynamic_config_list_subscribers(Ref{Iceoryx2FFI.iox2_port_factory_pub_sub_h}(factory.handle), _SUBSCRIBER_DETAILS_CB, Base.unsafe_convert(Ptr{Cvoid}, ctx_ref))
        end
    end
    return nothing
end

@inline function number_of_listeners(factory::PortFactoryEvent)
    return Int(Iceoryx2FFI.iox2_port_factory_event_dynamic_config_number_of_listeners(Ref{Iceoryx2FFI.iox2_port_factory_event_h}(factory.handle)))
end

@inline function number_of_notifiers(factory::PortFactoryEvent)
    return Int(Iceoryx2FFI.iox2_port_factory_event_dynamic_config_number_of_notifiers(Ref{Iceoryx2FFI.iox2_port_factory_event_h}(factory.handle)))
end

function list_listeners(factory::PortFactoryEvent, f::Function)
    let user_f = f
        ctx = _ListenerDetailsCallbackCtx(FunctionWrapper{Iceoryx2FFI.iox2_callback_progression_e, Tuple{ListenerDetailsView}}(details -> _callback_progression(user_f(details))))
        ctx_ref = Ref(ctx)
        GC.@preserve ctx_ref begin
            Iceoryx2FFI.iox2_port_factory_event_dynamic_config_list_listeners(Ref{Iceoryx2FFI.iox2_port_factory_event_h}(factory.handle), _LISTENER_DETAILS_CB, Base.unsafe_convert(Ptr{Cvoid}, ctx_ref))
        end
    end
    return nothing
end

function list_notifiers(factory::PortFactoryEvent, f::Function)
    let user_f = f
        ctx = _NotifierDetailsCallbackCtx(FunctionWrapper{Iceoryx2FFI.iox2_callback_progression_e, Tuple{NotifierDetailsView}}(details -> _callback_progression(user_f(details))))
        ctx_ref = Ref(ctx)
        GC.@preserve ctx_ref begin
            Iceoryx2FFI.iox2_port_factory_event_dynamic_config_list_notifiers(Ref{Iceoryx2FFI.iox2_port_factory_event_h}(factory.handle), _NOTIFIER_DETAILS_CB, Base.unsafe_convert(Ptr{Cvoid}, ctx_ref))
        end
    end
    return nothing
end

@inline function number_of_clients(factory::PortFactoryRequestResponse)
    return Int(Iceoryx2FFI.iox2_port_factory_request_response_dynamic_config_number_of_clients(Ref{Iceoryx2FFI.iox2_port_factory_request_response_h}(factory.handle)))
end

@inline function number_of_servers(factory::PortFactoryRequestResponse)
    return Int(Iceoryx2FFI.iox2_port_factory_request_response_dynamic_config_number_of_servers(Ref{Iceoryx2FFI.iox2_port_factory_request_response_h}(factory.handle)))
end

function list_clients(factory::PortFactoryRequestResponse, f::Function)
    let user_f = f
        ctx = _ClientDetailsCallbackCtx(FunctionWrapper{Iceoryx2FFI.iox2_callback_progression_e, Tuple{ClientDetailsView}}(details -> _callback_progression(user_f(details))))
        ctx_ref = Ref(ctx)
        GC.@preserve ctx_ref begin
            Iceoryx2FFI.iox2_port_factory_request_response_dynamic_config_list_clients(Ref{Iceoryx2FFI.iox2_port_factory_request_response_h}(factory.handle), _CLIENT_DETAILS_CB, Base.unsafe_convert(Ptr{Cvoid}, ctx_ref))
        end
    end
    return nothing
end

function list_servers(factory::PortFactoryRequestResponse, f::Function)
    let user_f = f
        ctx = _ServerDetailsCallbackCtx(FunctionWrapper{Iceoryx2FFI.iox2_callback_progression_e, Tuple{ServerDetailsView}}(details -> _callback_progression(user_f(details))))
        ctx_ref = Ref(ctx)
        GC.@preserve ctx_ref begin
            Iceoryx2FFI.iox2_port_factory_request_response_dynamic_config_list_servers(Ref{Iceoryx2FFI.iox2_port_factory_request_response_h}(factory.handle), _SERVER_DETAILS_CB, Base.unsafe_convert(Ptr{Cvoid}, ctx_ref))
        end
    end
    return nothing
end

@inline function number_of_readers(factory::PortFactoryBlackboard)
    return Int(Iceoryx2FFI.iox2_port_factory_blackboard_dynamic_config_number_of_readers(Ref{Iceoryx2FFI.iox2_port_factory_blackboard_h}(factory.handle)))
end

@inline function number_of_writers(factory::PortFactoryBlackboard)
    return Int(Iceoryx2FFI.iox2_port_factory_blackboard_dynamic_config_number_of_writers(Ref{Iceoryx2FFI.iox2_port_factory_blackboard_h}(factory.handle)))
end

function list_readers(factory::PortFactoryBlackboard, f::Function)
    let user_f = f
        ctx = _ReaderDetailsCallbackCtx(FunctionWrapper{Iceoryx2FFI.iox2_callback_progression_e, Tuple{ReaderDetailsView}}(details -> _callback_progression(user_f(details))))
        ctx_ref = Ref(ctx)
        GC.@preserve ctx_ref begin
            Iceoryx2FFI.iox2_port_factory_blackboard_dynamic_config_list_readers(Ref{Iceoryx2FFI.iox2_port_factory_blackboard_h}(factory.handle), _READER_DETAILS_CB, Base.unsafe_convert(Ptr{Cvoid}, ctx_ref))
        end
    end
    return nothing
end

function list_writers(factory::PortFactoryBlackboard, f::Function)
    let user_f = f
        ctx = _WriterDetailsCallbackCtx(FunctionWrapper{Iceoryx2FFI.iox2_callback_progression_e, Tuple{WriterDetailsView}}(details -> _callback_progression(user_f(details))))
        ctx_ref = Ref(ctx)
        GC.@preserve ctx_ref begin
            Iceoryx2FFI.iox2_port_factory_blackboard_dynamic_config_list_writers(Ref{Iceoryx2FFI.iox2_port_factory_blackboard_h}(factory.handle), _WRITER_DETAILS_CB, Base.unsafe_convert(Ptr{Cvoid}, ctx_ref))
        end
    end
    return nothing
end
