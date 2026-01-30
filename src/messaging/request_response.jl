# === Request/Response ===

function _set_request_payload_type!(
    builder::RequestResponseServiceBuilder{Req,Resp,ReqH,RespH},
    ::Type{Req},
    variant::Iceoryx2FFI.iox2_type_variant_e,
) where {Req,Resp,ReqH,RespH}
    _require_valid(builder.handle, "request_response service builder")
    _require_isbits(Req)
    name, name_len, size, alignment = _type_details(Req)
    GC.@preserve name begin
        ret = Iceoryx2FFI.iox2_service_builder_request_response_set_request_payload_type_details(
            Ref{Iceoryx2FFI.iox2_service_builder_request_response_h}(builder.handle),
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

function request_payload_alignment!(builder::RequestResponseServiceBuilder, alignment::Integer)
    alignment > 0 || throw(ArgumentError("request payload alignment must be positive, got $alignment"))
    Iceoryx2FFI.iox2_service_builder_request_response_request_payload_alignment(
        Ref{Iceoryx2FFI.iox2_service_builder_request_response_h}(builder.handle),
        Iceoryx2FFI.c_size_t(alignment),
    )
    return builder
end

function _set_response_payload_type!(
    builder::RequestResponseServiceBuilder{Req,Resp,ReqH,RespH},
    ::Type{Resp},
    variant::Iceoryx2FFI.iox2_type_variant_e,
) where {Req,Resp,ReqH,RespH}
    _require_valid(builder.handle, "request_response service builder")
    _require_isbits(Resp)
    name, name_len, size, alignment = _type_details(Resp)
    GC.@preserve name begin
        ret = Iceoryx2FFI.iox2_service_builder_request_response_set_response_payload_type_details(
            Ref{Iceoryx2FFI.iox2_service_builder_request_response_h}(builder.handle),
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

function response_payload_alignment!(builder::RequestResponseServiceBuilder, alignment::Integer)
    alignment > 0 || throw(ArgumentError("response payload alignment must be positive, got $alignment"))
    Iceoryx2FFI.iox2_service_builder_request_response_response_payload_alignment(
        Ref{Iceoryx2FFI.iox2_service_builder_request_response_h}(builder.handle),
        Iceoryx2FFI.c_size_t(alignment),
    )
    return builder
end

function request_user_header(builder::RequestResponseServiceBuilder{Req,Resp,Nothing,RespH}, ::Type{H}) where {Req,Resp,RespH,H}
    _require_valid(builder.handle, "request/response service builder")
    header_type = _payload_type(H)
    variant = _variant_type(H)
    name, name_len, size, alignment = _type_details(header_type)
    GC.@preserve name begin
        ret = Iceoryx2FFI.iox2_service_builder_request_response_set_request_header_type_details(
            Ref{Iceoryx2FFI.iox2_service_builder_request_response_h}(builder.handle),
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
    return RequestResponseServiceBuilder{Req,Resp,header_type,RespH}(handle, storage, builder.keepalive)
end

function request_user_header(builder::RequestResponseServiceBuilder{Req,Resp,ReqH,RespH}, ::Type{ReqH}) where {Req,Resp,ReqH,RespH}
    _require_valid(builder.handle, "request/response service builder")
    return builder
end

function response_user_header(builder::RequestResponseServiceBuilder{Req,Resp,ReqH,Nothing}, ::Type{H}) where {Req,Resp,ReqH,H}
    _require_valid(builder.handle, "request/response service builder")
    header_type = _payload_type(H)
    variant = _variant_type(H)
    name, name_len, size, alignment = _type_details(header_type)
    GC.@preserve name begin
        ret = Iceoryx2FFI.iox2_service_builder_request_response_set_response_header_type_details(
            Ref{Iceoryx2FFI.iox2_service_builder_request_response_h}(builder.handle),
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
    return RequestResponseServiceBuilder{Req,Resp,ReqH,header_type}(handle, storage, builder.keepalive)
end

function response_user_header(builder::RequestResponseServiceBuilder{Req,Resp,ReqH,RespH}, ::Type{RespH}) where {Req,Resp,ReqH,RespH}
    _require_valid(builder.handle, "request/response service builder")
    return builder
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
    header_slot::HeaderSlot{
        Iceoryx2FFI.iox2_request_header_t,
        Iceoryx2FFI.iox2_request_header_h,
        Val{:req},
    }
    function RequestMut{Req,Resp,ReqH,RespH}(handle_ref, storage, header_slot) where {Req,Resp,ReqH,RespH}
        obj = new{Req,Resp,ReqH,RespH}(handle_ref, storage, header_slot)
        finalizer(_finalize_request_mut, obj)
        return obj
    end
end

function RequestMut{Req,Resp,ReqH,RespH}() where {Req,Resp,ReqH,RespH}
    return RequestMut{Req,Resp,ReqH,RespH}(
        Ref{Iceoryx2FFI.iox2_request_mut_h}(_IOX2_NULL),
        Ref{Iceoryx2FFI.iox2_request_mut_t}(),
        HeaderSlot{
            Iceoryx2FFI.iox2_request_header_t,
            Iceoryx2FFI.iox2_request_header_h,
            Val{:req},
        }(),
    )
end

RequestMut(client::Client{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH} =
    RequestMut{Req,Resp,ReqH,RespH}()

@inline _slice_mutable(::Type{<:RequestMut}) = true

function _finalize_request_mut(request::RequestMut)
    _drop_header!(request.header_slot)
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
    slot = request.header_slot
    _drop_header!(slot)
    Iceoryx2FFI.iox2_request_mut_header(request.handle_ref, slot.storage, slot.handle_ref)
    slot.handle_ref[] != _IOX2_NULL || throw(ErrorException("failed to acquire request header"))
    header_ref = Base.unsafe_convert(Iceoryx2FFI.iox2_request_header_h_ref, slot.handle_ref)
    return RequestHeaderRef(header_ref)
end

@inline function write_payload!(request::RequestMut{Req,Resp,ReqH,RespH}, value::Req) where {Req,Resp,ReqH,RespH}
    slice = payload_mut(request)
    unsafe_store!(slice.ptr, value, 1)
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

@inline _request_header_ref(header::RequestHeader) =
    Ref{Iceoryx2FFI.iox2_request_header_h}(unsafe_handle(header))
@inline _request_header_ref(header::RequestHeaderRef) = unsafe_handle(header)

@inline function client_id(header::Union{RequestHeader, RequestHeaderRef})
    handle_ref = Ref{Iceoryx2FFI.iox2_unique_client_id_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_request_header_client_id(
        _request_header_ref(header),
        C_NULL,
        handle_ref,
    )
    return UniqueClientId(handle_ref[])
end

@inline function number_of_elements(header::Union{RequestHeader, RequestHeaderRef})
    return Int(
        Iceoryx2FFI.iox2_request_header_number_of_elements(
            _request_header_ref(header),
        ),
    )
end


mutable struct PendingResponse{Resp,ReqH,RespH}
    handle_ref::Base.RefValue{Iceoryx2FFI.iox2_pending_response_h}
    storage::Base.RefValue{Iceoryx2FFI.iox2_pending_response_t}
    header_slot::HeaderSlot{
        Iceoryx2FFI.iox2_request_header_t,
        Iceoryx2FFI.iox2_request_header_h,
        Val{:req},
    }
    function PendingResponse{Resp,ReqH,RespH}(handle_ref, storage, header_slot) where {Resp,ReqH,RespH}
        obj = new{Resp,ReqH,RespH}(handle_ref, storage, header_slot)
        finalizer(_finalize_pending_response, obj)
        return obj
    end
end

function PendingResponse{Resp,ReqH,RespH}() where {Resp,ReqH,RespH}
    return PendingResponse{Resp,ReqH,RespH}(
        Ref{Iceoryx2FFI.iox2_pending_response_h}(_IOX2_NULL),
        Ref{Iceoryx2FFI.iox2_pending_response_t}(),
        HeaderSlot{
            Iceoryx2FFI.iox2_request_header_t,
            Iceoryx2FFI.iox2_request_header_h,
            Val{:req},
        }(),
    )
end

PendingResponse(client::Client{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH} =
    PendingResponse{Resp,ReqH,RespH}()

function _finalize_pending_response(pending::PendingResponse)
    _drop_header!(pending.header_slot)
    if pending.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_pending_response_drop(pending.handle_ref[])
        pending.handle_ref[] = _IOX2_NULL
    end
    return nothing
end

@inline function header(pending::PendingResponse)
    _require_valid(pending.handle_ref[], "pending response")
    slot = pending.header_slot
    _drop_header!(slot)
    Iceoryx2FFI.iox2_pending_response_header(pending.handle_ref, slot.storage, slot.handle_ref)
    slot.handle_ref[] != _IOX2_NULL || throw(ErrorException("failed to acquire request header"))
    header_ref = Base.unsafe_convert(Iceoryx2FFI.iox2_request_header_h_ref, slot.handle_ref)
    return RequestHeaderRef(header_ref)
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

function try_loan_slice_uninit!(
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
    ret == Iceoryx2FFI.iox2_loan_error_e_EXCEEDS_MAX_LOANED_SAMPLES && return false
    check_ok(ret, Iceoryx2FFI.iox2_loan_error_e)
    return true
end

@inline function loan_uninit!(client::Client{Req,Resp,ReqH,RespH}, request::RequestMut{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH}
    return loan_slice_uninit!(client, request, 1)
end

@inline function try_loan_uninit!(client::Client{Req,Resp,ReqH,RespH}, request::RequestMut{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH}
    return try_loan_slice_uninit!(client, request, 1)
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
    _drop_header!(request.header_slot)
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
    header_slot::HeaderSlot{
        Iceoryx2FFI.iox2_response_header_t,
        Iceoryx2FFI.iox2_response_header_h,
        Val{:resp},
    }
    function Response{Resp,RespH}(handle_ref, storage, header_slot) where {Resp,RespH}
        obj = new{Resp,RespH}(handle_ref, storage, header_slot)
        finalizer(_finalize_response, obj)
        return obj
    end
end

function Response{Resp,RespH}() where {Resp,RespH}
    return Response{Resp,RespH}(
        Ref{Iceoryx2FFI.iox2_response_h}(_IOX2_NULL),
        Ref{Iceoryx2FFI.iox2_response_t}(),
        HeaderSlot{
            Iceoryx2FFI.iox2_response_header_t,
            Iceoryx2FFI.iox2_response_header_h,
            Val{:resp},
        }(),
    )
end

Response(pending::PendingResponse{Resp,ReqH,RespH}) where {Resp,ReqH,RespH} = Response{Resp,RespH}()

function _finalize_response(resp::Response)
    _drop_header!(resp.header_slot)
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
    slot = resp.header_slot
    _drop_header!(slot)
    Iceoryx2FFI.iox2_response_header(resp.handle_ref, slot.storage, slot.handle_ref)
    slot.handle_ref[] != _IOX2_NULL || throw(ErrorException("failed to acquire response header"))
    header_ref = Base.unsafe_convert(Iceoryx2FFI.iox2_response_header_h_ref, slot.handle_ref)
    return ResponseHeaderRef(header_ref)
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

@inline _response_header_ref(header::ResponseHeader) =
    Ref{Iceoryx2FFI.iox2_response_header_h}(unsafe_handle(header))
@inline _response_header_ref(header::ResponseHeaderRef) = unsafe_handle(header)

@inline function server_id(header::Union{ResponseHeader, ResponseHeaderRef})
    handle_ref = Ref{Iceoryx2FFI.iox2_unique_server_id_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_response_header_server_id(
        _response_header_ref(header),
        C_NULL,
        handle_ref,
    )
    return UniqueServerId(handle_ref[])
end

@inline function number_of_elements(header::Union{ResponseHeader, ResponseHeaderRef})
    return Int(
        Iceoryx2FFI.iox2_response_header_number_of_elements(
            _response_header_ref(header),
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
    header_slot::HeaderSlot{
        Iceoryx2FFI.iox2_request_header_t,
        Iceoryx2FFI.iox2_request_header_h,
        Val{:req},
    }
    function ActiveRequest{Req,Resp,ReqH,RespH}(handle_ref, storage, header_slot) where {Req,Resp,ReqH,RespH}
        obj = new{Req,Resp,ReqH,RespH}(handle_ref, storage, header_slot)
        finalizer(_finalize_active_request, obj)
        return obj
    end
end

function ActiveRequest{Req,Resp,ReqH,RespH}() where {Req,Resp,ReqH,RespH}
    return ActiveRequest{Req,Resp,ReqH,RespH}(
        Ref{Iceoryx2FFI.iox2_active_request_h}(_IOX2_NULL),
        Ref{Iceoryx2FFI.iox2_active_request_t}(),
        HeaderSlot{
            Iceoryx2FFI.iox2_request_header_t,
            Iceoryx2FFI.iox2_request_header_h,
            Val{:req},
        }(),
    )
end

ActiveRequest(server::Server{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH} =
    ActiveRequest{Req,Resp,ReqH,RespH}()

function _finalize_active_request(req::ActiveRequest)
    _drop_header!(req.header_slot)
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
    slot = req.header_slot
    _drop_header!(slot)
    Iceoryx2FFI.iox2_active_request_header(req.handle_ref, slot.storage, slot.handle_ref)
    slot.handle_ref[] != _IOX2_NULL || throw(ErrorException("failed to acquire request header"))
    header_ref = Base.unsafe_convert(Iceoryx2FFI.iox2_request_header_h_ref, slot.handle_ref)
    return RequestHeaderRef(header_ref)
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
    header_slot::HeaderSlot{
        Iceoryx2FFI.iox2_response_header_t,
        Iceoryx2FFI.iox2_response_header_h,
        Val{:resp},
    }
    function ResponseMut{Resp,RespH}(handle_ref, storage, header_slot) where {Resp,RespH}
        obj = new{Resp,RespH}(handle_ref, storage, header_slot)
        finalizer(_finalize_response_mut, obj)
        return obj
    end
end

function ResponseMut{Resp,RespH}() where {Resp,RespH}
    return ResponseMut{Resp,RespH}(
        Ref{Iceoryx2FFI.iox2_response_mut_h}(_IOX2_NULL),
        Ref{Iceoryx2FFI.iox2_response_mut_t}(),
        HeaderSlot{
            Iceoryx2FFI.iox2_response_header_t,
            Iceoryx2FFI.iox2_response_header_h,
            Val{:resp},
        }(),
    )
end

ResponseMut(req::ActiveRequest{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH} = ResponseMut{Resp,RespH}()

@inline _slice_mutable(::Type{<:ResponseMut}) = true

function _finalize_response_mut(resp::ResponseMut)
    _drop_header!(resp.header_slot)
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
    slot = resp.header_slot
    _drop_header!(slot)
    Iceoryx2FFI.iox2_response_mut_header(resp.handle_ref, slot.storage, slot.handle_ref)
    slot.handle_ref[] != _IOX2_NULL || throw(ErrorException("failed to acquire response header"))
    header_ref = Base.unsafe_convert(Iceoryx2FFI.iox2_response_header_h_ref, slot.handle_ref)
    return ResponseHeaderRef(header_ref)
end

@inline function write_payload!(resp::ResponseMut{RespT,RespH}, value::RespT) where {RespT,RespH}
    slice = payload_mut(resp)
    unsafe_store!(slice.ptr, value, 1)
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

function try_loan_slice_uninit!(
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
    ret == Iceoryx2FFI.iox2_loan_error_e_EXCEEDS_MAX_LOANED_SAMPLES && return false
    check_ok(ret, Iceoryx2FFI.iox2_loan_error_e)
    return true
end

@inline function loan_uninit!(req::ActiveRequest{Req,Resp,ReqH,RespH}, resp::ResponseMut{Resp,RespH}) where {Req,Resp,ReqH,RespH}
    return loan_slice_uninit!(req, resp, 1)
end

@inline function try_loan_uninit!(req::ActiveRequest{Req,Resp,ReqH,RespH}, resp::ResponseMut{Resp,RespH}) where {Req,Resp,ReqH,RespH}
    return try_loan_slice_uninit!(req, resp, 1)
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
    _drop_header!(resp.header_slot)
    resp.handle_ref[] = _IOX2_NULL
    return nothing
end

