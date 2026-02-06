# === Request/Response ===

function _set_request_payload_type!(
    builder::RequestResponseServiceBuilder{S,Req,Resp,ReqH,RespH},
    ::Type{Req},
    variant::Iceoryx2FFI.iox2_type_variant_e,
) where {S,Req,Resp,ReqH,RespH}
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
    builder::RequestResponseServiceBuilder{S,Req,Resp,ReqH,RespH},
    ::Type{Resp},
    variant::Iceoryx2FFI.iox2_type_variant_e,
) where {S,Req,Resp,ReqH,RespH}
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

function request_user_header(builder::RequestResponseServiceBuilder{S,Req,Resp,Nothing,RespH}, ::Type{H}) where {S,Req,Resp,RespH,H}
    _require_valid(builder.handle, "request/response service builder")
    header_type = _payload_type(H)
    variant = _fixed_header_variant(H, "request user header type")
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
    close(builder)
    return RequestResponseServiceBuilder{S,Req,Resp,header_type,RespH}(handle, storage, builder.keepalive)
end

function request_user_header(builder::RequestResponseServiceBuilder{S,Req,Resp,ReqH,RespH}, ::Type{ReqH}) where {S,Req,Resp,ReqH,RespH}
    _require_valid(builder.handle, "request/response service builder")
    return builder
end

function response_user_header(builder::RequestResponseServiceBuilder{S,Req,Resp,ReqH,Nothing}, ::Type{H}) where {S,Req,Resp,ReqH,H}
    _require_valid(builder.handle, "request/response service builder")
    header_type = _payload_type(H)
    variant = _fixed_header_variant(H, "response user header type")
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
    close(builder)
    return RequestResponseServiceBuilder{S,Req,Resp,ReqH,header_type}(handle, storage, builder.keepalive)
end

function response_user_header(builder::RequestResponseServiceBuilder{S,Req,Resp,ReqH,RespH}, ::Type{RespH}) where {S,Req,Resp,ReqH,RespH}
    _require_valid(builder.handle, "request/response service builder")
    return builder
end

### builder tuning setters generated in src/generated/wrappers.jl

"""
    PortFactoryRequestResponse{S,Req,Resp,ReqH,RespH}

Factory for clients and servers bound to a request/response service.
"""
mutable struct PortFactoryRequestResponse{S,Req,Resp,ReqH,RespH}
    handle::Iceoryx2FFI.iox2_port_factory_request_response_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_request_response_t}
    keepalive::Node{S}
    function PortFactoryRequestResponse{S,Req,Resp,ReqH,RespH}(handle, storage, keepalive) where {S,Req,Resp,ReqH,RespH}
        obj = new{S,Req,Resp,ReqH,RespH}(handle, storage, keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

function Base.close(factory::PortFactoryRequestResponse)
    if factory.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_port_factory_request_response_drop(factory.handle)
        factory.handle = _IOX2_NULL
    end
    factory.storage = nothing
    return nothing
end

"""
    open_or_create(builder::RequestResponseServiceBuilder[, verifier])

Open an existing request/response service or create it if missing.
"""
function open_or_create(builder::RequestResponseServiceBuilder{S,Req,Resp,ReqH,RespH}) where {S,Req,Resp,ReqH,RespH}
    _require_valid(builder.handle, "request_response service builder")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_request_response_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_request_response_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_request_response_open_or_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_request_response_open_or_create_error_e)
    close(builder)
    return PortFactoryRequestResponse{S,Req,Resp,ReqH,RespH}(handle_ref[], storage, builder.keepalive)
end

function open_or_create(builder::RequestResponseServiceBuilder{S,Req,Resp,ReqH,RespH}, verifier::AttributeVerifier) where {S,Req,Resp,ReqH,RespH}
    _require_valid(builder.handle, "request_response service builder")
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
    close(builder)
    return PortFactoryRequestResponse{S,Req,Resp,ReqH,RespH}(handle_ref[], storage, builder.keepalive)
end

"""
    open(builder::RequestResponseServiceBuilder[, verifier])

Open an existing request/response service.
"""
function open(builder::RequestResponseServiceBuilder{S,Req,Resp,ReqH,RespH}) where {S,Req,Resp,ReqH,RespH}
    _require_valid(builder.handle, "request_response service builder")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_request_response_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_request_response_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_request_response_open(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_request_response_open_or_create_error_e)
    close(builder)
    return PortFactoryRequestResponse{S,Req,Resp,ReqH,RespH}(handle_ref[], storage, builder.keepalive)
end

function open(builder::RequestResponseServiceBuilder{S,Req,Resp,ReqH,RespH}, verifier::AttributeVerifier) where {S,Req,Resp,ReqH,RespH}
    _require_valid(builder.handle, "request_response service builder")
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
    close(builder)
    return PortFactoryRequestResponse{S,Req,Resp,ReqH,RespH}(handle_ref[], storage, builder.keepalive)
end

"""
    create(builder::RequestResponseServiceBuilder[, specifier])

Create a new request/response service.
"""
function create(builder::RequestResponseServiceBuilder{S,Req,Resp,ReqH,RespH}) where {S,Req,Resp,ReqH,RespH}
    _require_valid(builder.handle, "request_response service builder")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_request_response_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_request_response_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_request_response_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_request_response_open_or_create_error_e)
    close(builder)
    return PortFactoryRequestResponse{S,Req,Resp,ReqH,RespH}(handle_ref[], storage, builder.keepalive)
end

function create(builder::RequestResponseServiceBuilder{S,Req,Resp,ReqH,RespH}, specifier::AttributeSpecifier) where {S,Req,Resp,ReqH,RespH}
    _require_valid(builder.handle, "request_response service builder")
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
    close(builder)
    return PortFactoryRequestResponse{S,Req,Resp,ReqH,RespH}(handle_ref[], storage, builder.keepalive)
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

function open(f::Function, builder::RequestResponseServiceBuilder{S,Req,Resp,ReqH,RespH}, verifier::AttributeVerifier) where {S,Req,Resp,ReqH,RespH}
    factory = open(builder, verifier)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function create(f::Function, builder::RequestResponseServiceBuilder{S,Req,Resp,ReqH,RespH}) where {S,Req,Resp,ReqH,RespH}
    factory = create(builder)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function create(f::Function, builder::RequestResponseServiceBuilder{S,Req,Resp,ReqH,RespH}, specifier::AttributeSpecifier) where {S,Req,Resp,ReqH,RespH}
    factory = create(builder, specifier)
    try
        return f(factory)
    finally
        close(factory)
    end
end

open_or_create_with_attributes(builder::RequestResponseServiceBuilder{S,Req,Resp,ReqH,RespH}, verifier::AttributeVerifier) where {S,Req,Resp,ReqH,RespH} = open_or_create(builder, verifier)
open_or_create_with_attributes(f::Function, builder::RequestResponseServiceBuilder{S,Req,Resp,ReqH,RespH}, verifier::AttributeVerifier) where {S,Req,Resp,ReqH,RespH} = open_or_create(f, builder, verifier)
open_with_attributes(builder::RequestResponseServiceBuilder{S,Req,Resp,ReqH,RespH}, verifier::AttributeVerifier) where {S,Req,Resp,ReqH,RespH} = open(builder, verifier)
open_with_attributes(f::Function, builder::RequestResponseServiceBuilder{S,Req,Resp,ReqH,RespH}, verifier::AttributeVerifier) where {S,Req,Resp,ReqH,RespH} = open(f, builder, verifier)
create_with_attributes(builder::RequestResponseServiceBuilder{S,Req,Resp,ReqH,RespH}, specifier::AttributeSpecifier) where {S,Req,Resp,ReqH,RespH} = create(builder, specifier)
create_with_attributes(f::Function, builder::RequestResponseServiceBuilder{S,Req,Resp,ReqH,RespH}, specifier::AttributeSpecifier) where {S,Req,Resp,ReqH,RespH} = create(f, builder, specifier)

"""
    ClientBuilder{S,Req,Resp,ReqH,RespH}

Builder for `Client`.
"""
mutable struct ClientBuilder{S,Req,Resp,ReqH,RespH}
    handle::Iceoryx2FFI.iox2_port_factory_client_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_client_builder_t}
    keepalive::PortFactoryRequestResponse{S,Req,Resp,ReqH,RespH}
    function ClientBuilder{S,Req,Resp,ReqH,RespH}(handle, storage, keepalive) where {S,Req,Resp,ReqH,RespH}
        obj = new{S,Req,Resp,ReqH,RespH}(handle, storage, keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

function Base.close(builder::ClientBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

"""
    client_builder(factory::PortFactoryRequestResponse) -> ClientBuilder

Create a client builder from a request/response factory.
"""
function client_builder(factory::PortFactoryRequestResponse{S,Req,Resp,ReqH,RespH}) where {S,Req,Resp,ReqH,RespH}
    _require_valid(factory.handle, "request_response port factory")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_client_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_request_response_client_builder(Ref{Iceoryx2FFI.iox2_port_factory_request_response_h}(factory.handle), storage)
    return ClientBuilder{S,Req,Resp,ReqH,RespH}(handle, storage, factory)
end

"""
    ServerBuilder{S,Req,Resp,ReqH,RespH}

Builder for `Server`.
"""
mutable struct ServerBuilder{S,Req,Resp,ReqH,RespH}
    handle::Iceoryx2FFI.iox2_port_factory_server_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_server_builder_t}
    keepalive::PortFactoryRequestResponse{S,Req,Resp,ReqH,RespH}
    function ServerBuilder{S,Req,Resp,ReqH,RespH}(handle, storage, keepalive) where {S,Req,Resp,ReqH,RespH}
        obj = new{S,Req,Resp,ReqH,RespH}(handle, storage, keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

function Base.close(builder::ServerBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

"""
    server_builder(factory::PortFactoryRequestResponse) -> ServerBuilder

Create a server builder from a request/response factory.
"""
function server_builder(factory::PortFactoryRequestResponse{S,Req,Resp,ReqH,RespH}) where {S,Req,Resp,ReqH,RespH}
    _require_valid(factory.handle, "request_response port factory")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_server_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_request_response_server_builder(Ref{Iceoryx2FFI.iox2_port_factory_request_response_h}(factory.handle), storage)
    return ServerBuilder{S,Req,Resp,ReqH,RespH}(handle, storage, factory)
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

"""
    Client{S,Req,Resp,ReqH,RespH}

Request/response client used to send requests and receive responses.
"""
mutable struct Client{S,Req,Resp,ReqH,RespH}
    handle::Iceoryx2FFI.iox2_client_h
    storage::_StorageRef{Iceoryx2FFI.iox2_client_t}
    keepalive::PortFactoryRequestResponse{S,Req,Resp,ReqH,RespH}
    function Client{S,Req,Resp,ReqH,RespH}(handle, storage, keepalive) where {S,Req,Resp,ReqH,RespH}
        obj = new{S,Req,Resp,ReqH,RespH}(handle, storage, keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

function Base.close(client::Client)
    if client.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_client_drop(client.handle)
        client.handle = _IOX2_NULL
    end
    client.storage = nothing
    return nothing
end

"""
    create(builder::ClientBuilder) -> Client

Create a client and consume the builder.
"""
function create(builder::ClientBuilder{S,Req,Resp,ReqH,RespH}) where {S,Req,Resp,ReqH,RespH}
    _require_valid(builder.handle, "client builder")
    storage = Ref{Iceoryx2FFI.iox2_client_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_client_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_client_builder_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_client_create_error_e)
    close(builder)
    return Client{S,Req,Resp,ReqH,RespH}(handle_ref[], storage, builder.keepalive)
end

function create(f::Function, builder::ClientBuilder{S,Req,Resp,ReqH,RespH}) where {S,Req,Resp,ReqH,RespH}
    client = create(builder)
    try
        return f(client)
    finally
        close(client)
    end
end

"""
    Server{S,Req,Resp,ReqH,RespH}

Request/response server used to receive requests and send responses.
"""
mutable struct Server{S,Req,Resp,ReqH,RespH}
    handle::Iceoryx2FFI.iox2_server_h
    storage::_StorageRef{Iceoryx2FFI.iox2_server_t}
    keepalive::PortFactoryRequestResponse{S,Req,Resp,ReqH,RespH}
    function Server{S,Req,Resp,ReqH,RespH}(handle, storage, keepalive) where {S,Req,Resp,ReqH,RespH}
        obj = new{S,Req,Resp,ReqH,RespH}(handle, storage, keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

function Base.close(server::Server)
    if server.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_server_drop(server.handle)
        server.handle = _IOX2_NULL
    end
    server.storage = nothing
    return nothing
end

"""
    create(builder::ServerBuilder) -> Server

Create a server and consume the builder.
"""
function create(builder::ServerBuilder{S,Req,Resp,ReqH,RespH}) where {S,Req,Resp,ReqH,RespH}
    _require_valid(builder.handle, "server builder")
    storage = Ref{Iceoryx2FFI.iox2_server_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_server_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_server_builder_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_server_create_error_e)
    close(builder)
    return Server{S,Req,Resp,ReqH,RespH}(handle_ref[], storage, builder.keepalive)
end

function create(f::Function, builder::ServerBuilder{S,Req,Resp,ReqH,RespH}) where {S,Req,Resp,ReqH,RespH}
    server = create(builder)
    try
        return f(server)
    finally
        close(server)
    end
end

"""
    RequestMut{Req,Resp,ReqH,RespH}

Reusable mutable request buffer for clients.
"""
mutable struct RequestMut{Req,Resp,ReqH,RespH}
    handle_ref::Base.RefValue{Iceoryx2FFI.iox2_request_mut_h}
    storage::Base.RefValue{Iceoryx2FFI.iox2_request_mut_t}
    header_slot::HeaderSlot{
        Iceoryx2FFI.iox2_request_header_t,
        Iceoryx2FFI.iox2_request_header_h
    }
    function RequestMut{Req,Resp,ReqH,RespH}(handle_ref, storage, header_slot) where {Req,Resp,ReqH,RespH}
        obj = new{Req,Resp,ReqH,RespH}(handle_ref, storage, header_slot)
        finalizer(Base.close, obj)
        return obj
    end
end

function RequestMut{Req,Resp,ReqH,RespH}() where {Req,Resp,ReqH,RespH}
    return RequestMut{Req,Resp,ReqH,RespH}(
        Ref{Iceoryx2FFI.iox2_request_mut_h}(_IOX2_NULL),
        Ref{Iceoryx2FFI.iox2_request_mut_t}(),
        HeaderSlot{
            Iceoryx2FFI.iox2_request_header_t,
            Iceoryx2FFI.iox2_request_header_h
        }(),
    )
end

RequestMut(client::Client{S,Req,Resp,ReqH,RespH}) where {S,Req,Resp,ReqH,RespH} =
    RequestMut{Req,Resp,ReqH,RespH}()

@inline _slice_mutable(::Type{<:RequestMut}) = true

function Base.close(request::RequestMut)
    _drop_header!(request.header_slot)
    if request.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_request_mut_drop(request.handle_ref[])
        request.handle_ref[] = _IOX2_NULL
    end
    return nothing
end

"""
    payload_mut(request::RequestMut) -> Slice

Return a zero-copy mutable view of the request payload.
"""
@inline function payload_mut(request::RequestMut{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH}
    ptr_ref = Ref{Ptr{Cvoid}}()
    len_ref = Ref{Iceoryx2FFI.c_size_t}()
    Iceoryx2FFI.iox2_request_mut_payload_mut(request.handle_ref, ptr_ref, len_ref)
    return Slice{Req}(Ptr{Req}(ptr_ref[]), Int(len_ref[]), request)
end

@inline function unsafe_payload_mut_ptr(request::RequestMut{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH}
    return payload_mut(request).ptr
end

"""
    header(request::RequestMut) -> RequestHeaderRef

Return a view of the request header.
"""
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

"""
    user_header(request::RequestMut)
    user_header(request::RequestMut, ::Type{ReqH})
    user_header_mut(request::RequestMut)
    user_header_mut(request::RequestMut, ::Type{ReqH})

Return a zero-copy (mutable) view of the request user header.
"""
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


"""
    PendingResponse{Resp,ReqH,RespH}

Handle for pending responses after sending a request.
"""
mutable struct PendingResponse{Resp,ReqH,RespH}
    handle_ref::Base.RefValue{Iceoryx2FFI.iox2_pending_response_h}
    storage::Base.RefValue{Iceoryx2FFI.iox2_pending_response_t}
    header_slot::HeaderSlot{
        Iceoryx2FFI.iox2_request_header_t,
        Iceoryx2FFI.iox2_request_header_h
    }
    function PendingResponse{Resp,ReqH,RespH}(handle_ref, storage, header_slot) where {Resp,ReqH,RespH}
        obj = new{Resp,ReqH,RespH}(handle_ref, storage, header_slot)
        finalizer(Base.close, obj)
        return obj
    end
end

function PendingResponse{Resp,ReqH,RespH}() where {Resp,ReqH,RespH}
    return PendingResponse{Resp,ReqH,RespH}(
        Ref{Iceoryx2FFI.iox2_pending_response_h}(_IOX2_NULL),
        Ref{Iceoryx2FFI.iox2_pending_response_t}(),
        HeaderSlot{
            Iceoryx2FFI.iox2_request_header_t,
            Iceoryx2FFI.iox2_request_header_h
        }(),
    )
end

PendingResponse(client::Client{S,Req,Resp,ReqH,RespH}) where {S,Req,Resp,ReqH,RespH} =
    PendingResponse{Resp,ReqH,RespH}()

function Base.close(pending::PendingResponse)
    _drop_header!(pending.header_slot)
    if pending.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_pending_response_drop(pending.handle_ref[])
        pending.handle_ref[] = _IOX2_NULL
    end
    return nothing
end

"""
    header(pending::PendingResponse) -> RequestHeaderRef

Return a view of the request header stored in a pending response.
"""
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

"""
    user_header(pending::PendingResponse)
    user_header(pending::PendingResponse, ::Type{ReqH})

Return a view of the request user header stored in a pending response.
"""
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


"""
    loan_slice_uninit!(client, request, n)
    loan_uninit!(client, request)
    loan!(client, request)
    loan_slice!(client, request, n)

Loan request payloads into a reusable `RequestMut`.
"""
function loan_slice_uninit!(
    client::Client{S,Req,Resp,ReqH,RespH},
    request::RequestMut{Req,Resp,ReqH,RespH},
    n::Integer,
) where {S,Req,Resp,ReqH,RespH}
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
    client::Client{S,Req,Resp,ReqH,RespH},
    request::RequestMut{Req,Resp,ReqH,RespH},
    n::Integer,
) where {S,Req,Resp,ReqH,RespH}
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

@inline function loan_uninit!(client::Client{S,Req,Resp,ReqH,RespH}, request::RequestMut{Req,Resp,ReqH,RespH}) where {S,Req,Resp,ReqH,RespH}
    return loan_slice_uninit!(client, request, 1)
end

@inline function try_loan_uninit!(client::Client{S,Req,Resp,ReqH,RespH}, request::RequestMut{Req,Resp,ReqH,RespH}) where {S,Req,Resp,ReqH,RespH}
    return try_loan_slice_uninit!(client, request, 1)
end

@inline function loan!(client::Client{S,Req,Resp,ReqH,RespH}, request::RequestMut{Req,Resp,ReqH,RespH}) where {S,Req,Resp,ReqH,RespH}
    loan_slice_uninit!(client, request, 1)
    fill!(payload_mut(request), _default_value(Req))
    return request
end

function loan_slice!(client::Client{S,Req,Resp,ReqH,RespH}, request::RequestMut{Req,Resp,ReqH,RespH}, n::Integer) where {S,Req,Resp,ReqH,RespH}
    loan_slice_uninit!(client, request, n)
    fill!(payload_mut(request), _default_value(Req))
    return request
end

function loan_slice!(f::Function, client::Client{S,Req,Resp,ReqH,RespH}, request::RequestMut{Req,Resp,ReqH,RespH}, n::Integer) where {S,Req,Resp,ReqH,RespH}
    loan_slice!(client, request, n)
    try
        return f(request)
    finally
        close(request)
    end
end

function loan_slice_uninit!(f::Function, client::Client{S,Req,Resp,ReqH,RespH}, request::RequestMut{Req,Resp,ReqH,RespH}, n::Integer) where {S,Req,Resp,ReqH,RespH}
    loan_slice_uninit!(client, request, n)
    try
        return f(request)
    finally
        close(request)
    end
end

"""
    loan_request!(client, request, n)

Alias for `loan_slice!` used for request/response naming.
"""
function loan_request!(client::Client{S,Req,Resp,ReqH,RespH}, request::RequestMut{Req,Resp,ReqH,RespH}, n::Integer) where {S,Req,Resp,ReqH,RespH}
    return loan_slice_uninit!(client, request, n)
end

function loan_request!(f::Function, client::Client{S,Req,Resp,ReqH,RespH}, request::RequestMut{Req,Resp,ReqH,RespH}, n::Integer) where {S,Req,Resp,ReqH,RespH}
    return loan_slice_uninit!(f, client, request, n)
end

"""
    send!(request, pending)

Send a request and populate `pending` for receiving responses.
"""
function send!(request::RequestMut{Req,Resp,ReqH,RespH}, pending::PendingResponse{Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH}
    _require_inactive(pending, "pending response")
    pending.handle_ref[] = _IOX2_NULL
    ret = Iceoryx2FFI.iox2_request_mut_send(request.handle_ref[], pending.storage, pending.handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_send_error_e)
    _drop_header!(request.header_slot)
    request.handle_ref[] = _IOX2_NULL
    return pending
end

"""
    send_copy!(client, pending, value)
    send_copy!(client, pending, data::AbstractVector)

Send a request by copying from a value or buffer.
"""
function send_copy!(
    client::Client{S,Req,Resp,ReqH,RespH},
    data::Ptr{Req},
    n::Integer,
    pending::PendingResponse{Resp,ReqH,RespH},
) where {S,Req,Resp,ReqH,RespH}
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
    client::Client{S,Req,Resp,ReqH,RespH},
    data::AbstractVector{Req},
    pending::PendingResponse{Resp,ReqH,RespH},
) where {S,Req,Resp,ReqH,RespH}
    GC.@preserve data begin
        return send_copy!(client, pointer(data), length(data), pending)
    end
end

function send_copy!(
    client::Client{S,Req,Resp,ReqH,RespH},
    value::Req,
    pending::PendingResponse{Resp,ReqH,RespH},
) where {S,Req,Resp,ReqH,RespH}
    value_ref = Ref{Req}(value)
    GC.@preserve value_ref begin
        return send_copy!(client, Base.unsafe_convert(Ptr{Req}, value_ref), 1, pending)
    end
end

"""
    Response{Resp,RespH}

Reusable response buffer owned by a client.
"""
mutable struct Response{Resp,RespH}
    handle_ref::Base.RefValue{Iceoryx2FFI.iox2_response_h}
    storage::Base.RefValue{Iceoryx2FFI.iox2_response_t}
    header_slot::HeaderSlot{
        Iceoryx2FFI.iox2_response_header_t,
        Iceoryx2FFI.iox2_response_header_h
    }
    function Response{Resp,RespH}(handle_ref, storage, header_slot) where {Resp,RespH}
        obj = new{Resp,RespH}(handle_ref, storage, header_slot)
        finalizer(Base.close, obj)
        return obj
    end
end

function Response{Resp,RespH}() where {Resp,RespH}
    return Response{Resp,RespH}(
        Ref{Iceoryx2FFI.iox2_response_h}(_IOX2_NULL),
        Ref{Iceoryx2FFI.iox2_response_t}(),
        HeaderSlot{
            Iceoryx2FFI.iox2_response_header_t,
            Iceoryx2FFI.iox2_response_header_h
        }(),
    )
end

Response(pending::PendingResponse{Resp,ReqH,RespH}) where {Resp,ReqH,RespH} = Response{Resp,RespH}()

function Base.close(resp::Response)
    _drop_header!(resp.header_slot)
    if resp.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_response_drop(resp.handle_ref[])
        resp.handle_ref[] = _IOX2_NULL
    end
    return nothing
end

"""
    payload(resp::Response) -> Slice

Return a zero-copy view of the response payload.
"""
@inline function payload(resp::Response{RespT,RespH}) where {RespT,RespH}
    ptr_ref = Ref{Ptr{Cvoid}}()
    len_ref = Ref{Iceoryx2FFI.c_size_t}()
    Iceoryx2FFI.iox2_response_payload(resp.handle_ref, ptr_ref, len_ref)
    return Slice{RespT}(Ptr{RespT}(ptr_ref[]), Int(len_ref[]), resp)
end

@inline function unsafe_payload_ptr(resp::Response{RespT,RespH}) where {RespT,RespH}
    return payload(resp).ptr
end

"""
    header(resp::Response) -> ResponseHeaderRef

Return a view of the response header.
"""
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

"""
    user_header(resp::Response)
    user_header(resp::Response, ::Type{RespH})

Return a view of the response user header.
"""
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


"""
    receive!(pending, resp) -> Bool

Receive a response into the reusable buffer. Returns `true` on success.
"""
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

"""
    receive!(f::Function, pending, resp)

Receive into `resp`, call `f(resp)`, and always `close(resp)` afterward.
"""
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

"""
    ActiveRequest{Req,Resp,ReqH,RespH}

Reusable request buffer owned by a server.
"""
mutable struct ActiveRequest{Req,Resp,ReqH,RespH}
    handle_ref::Base.RefValue{Iceoryx2FFI.iox2_active_request_h}
    storage::Base.RefValue{Iceoryx2FFI.iox2_active_request_t}
    header_slot::HeaderSlot{
        Iceoryx2FFI.iox2_request_header_t,
        Iceoryx2FFI.iox2_request_header_h
    }
    function ActiveRequest{Req,Resp,ReqH,RespH}(handle_ref, storage, header_slot) where {Req,Resp,ReqH,RespH}
        obj = new{Req,Resp,ReqH,RespH}(handle_ref, storage, header_slot)
        finalizer(Base.close, obj)
        return obj
    end
end

function ActiveRequest{Req,Resp,ReqH,RespH}() where {Req,Resp,ReqH,RespH}
    return ActiveRequest{Req,Resp,ReqH,RespH}(
        Ref{Iceoryx2FFI.iox2_active_request_h}(_IOX2_NULL),
        Ref{Iceoryx2FFI.iox2_active_request_t}(),
        HeaderSlot{
            Iceoryx2FFI.iox2_request_header_t,
            Iceoryx2FFI.iox2_request_header_h
        }(),
    )
end

ActiveRequest(server::Server{S,Req,Resp,ReqH,RespH}) where {S,Req,Resp,ReqH,RespH} =
    ActiveRequest{Req,Resp,ReqH,RespH}()

function Base.close(req::ActiveRequest)
    _drop_header!(req.header_slot)
    if req.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_active_request_drop(req.handle_ref[])
        req.handle_ref[] = _IOX2_NULL
    end
    return nothing
end

"""
    payload(req::ActiveRequest) -> Slice

Return a zero-copy view of the request payload.
"""
@inline function payload(req::ActiveRequest{ReqT,RespT,ReqH,RespH}) where {ReqT,RespT,ReqH,RespH}
    ptr_ref = Ref{Ptr{Cvoid}}()
    len_ref = Ref{Iceoryx2FFI.c_size_t}()
    Iceoryx2FFI.iox2_active_request_payload(req.handle_ref, ptr_ref, len_ref)
    return Slice{ReqT}(Ptr{ReqT}(ptr_ref[]), Int(len_ref[]), req)
end

@inline function unsafe_payload_ptr(req::ActiveRequest{ReqT,RespT,ReqH,RespH}) where {ReqT,RespT,ReqH,RespH}
    return payload(req).ptr
end

"""
    header(req::ActiveRequest) -> RequestHeaderRef

Return a view of the request header.
"""
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

"""
    user_header(req::ActiveRequest)
    user_header(req::ActiveRequest, ::Type{ReqH})

Return a view of the request user header.
"""
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


"""
    ResponseMut{Resp,RespH}

Reusable mutable response buffer owned by a server.
"""
mutable struct ResponseMut{Resp,RespH}
    handle_ref::Base.RefValue{Iceoryx2FFI.iox2_response_mut_h}
    storage::Base.RefValue{Iceoryx2FFI.iox2_response_mut_t}
    header_slot::HeaderSlot{
        Iceoryx2FFI.iox2_response_header_t,
        Iceoryx2FFI.iox2_response_header_h
    }
    function ResponseMut{Resp,RespH}(handle_ref, storage, header_slot) where {Resp,RespH}
        obj = new{Resp,RespH}(handle_ref, storage, header_slot)
        finalizer(Base.close, obj)
        return obj
    end
end

function ResponseMut{Resp,RespH}() where {Resp,RespH}
    return ResponseMut{Resp,RespH}(
        Ref{Iceoryx2FFI.iox2_response_mut_h}(_IOX2_NULL),
        Ref{Iceoryx2FFI.iox2_response_mut_t}(),
        HeaderSlot{
            Iceoryx2FFI.iox2_response_header_t,
            Iceoryx2FFI.iox2_response_header_h
        }(),
    )
end

ResponseMut(req::ActiveRequest{Req,Resp,ReqH,RespH}) where {Req,Resp,ReqH,RespH} = ResponseMut{Resp,RespH}()

@inline _slice_mutable(::Type{<:ResponseMut}) = true

function Base.close(resp::ResponseMut)
    _drop_header!(resp.header_slot)
    if resp.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_response_mut_drop(resp.handle_ref[])
        resp.handle_ref[] = _IOX2_NULL
    end
    return nothing
end

"""
    payload_mut(resp::ResponseMut) -> Slice

Return a zero-copy mutable view of the response payload.
"""
@inline function payload_mut(resp::ResponseMut{RespT,RespH}) where {RespT,RespH}
    ptr_ref = Ref{Ptr{Cvoid}}()
    len_ref = Ref{Iceoryx2FFI.c_size_t}()
    Iceoryx2FFI.iox2_response_mut_payload_mut(resp.handle_ref, ptr_ref, len_ref)
    return Slice{RespT}(Ptr{RespT}(ptr_ref[]), Int(len_ref[]), resp)
end

@inline function unsafe_payload_mut_ptr(resp::ResponseMut{RespT,RespH}) where {RespT,RespH}
    return payload_mut(resp).ptr
end

"""
    header(resp::ResponseMut) -> ResponseHeaderRef

Return a view of the response header.
"""
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

"""
    user_header(resp::ResponseMut)
    user_header(resp::ResponseMut, ::Type{RespH})
    user_header_mut(resp::ResponseMut)
    user_header_mut(resp::ResponseMut, ::Type{RespH})

Return a zero-copy (mutable) view of the response user header.
"""
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


"""
    receive!(server, req) -> Bool

Receive an active request into the reusable buffer. Returns `true` on success.
"""
function receive!(server::Server{S,Req,Resp,ReqH,RespH}, req::ActiveRequest{Req,Resp,ReqH,RespH}) where {S,Req,Resp,ReqH,RespH}
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

"""
    receive!(f::Function, server, req)

Receive into `req`, call `f(req)`, and always `close(req)` afterward.
"""
function receive!(f::Function, server::Server{S,Req,Resp,ReqH,RespH}, req::ActiveRequest{Req,Resp,ReqH,RespH}) where {S,Req,Resp,ReqH,RespH}
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

"""
    loan_slice_uninit!(req, resp, n)
    loan_uninit!(req, resp)
    loan!(req, resp)
    loan_slice!(req, resp, n)
    loan_response!(req, resp, n)

Loan response payloads into a reusable `ResponseMut`.
"""
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

"""
    send_copy(req, data, n)
    send_copy(req, data::AbstractVector)
    send!(resp::ResponseMut)

Send responses by copying or by sending a loaned response.
"""
function send_copy(req::ActiveRequest{Req,Resp,ReqH,RespH}, data::Ptr{Resp}, n::Integer) where {Req,Resp,ReqH,RespH}
    ret = Iceoryx2FFI.iox2_active_request_send_copy(req.handle_ref, data, Iceoryx2FFI.c_size_t(sizeof(Resp)), Iceoryx2FFI.c_size_t(n))
    check_ok(ret, Iceoryx2FFI.iox2_send_error_e)
    return nothing
end

"""
    send!(resp::ResponseMut)

Send a loaned response and invalidate its handle.
"""
function send!(resp::ResponseMut)
    ret = Iceoryx2FFI.iox2_response_mut_send(resp.handle_ref[])
    check_ok(ret, Iceoryx2FFI.iox2_send_error_e)
    _drop_header!(resp.header_slot)
    resp.handle_ref[] = _IOX2_NULL
    return nothing
end
