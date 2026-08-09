# Service type and core typed handles.

"""
    ServiceType

Service backend used for discovery and transport. Use `ServiceType.IPC` for
inter-process communication and `ServiceType.LOCAL` for process-local services.
"""
@enum ServiceType::UInt32 begin
    LOCAL = UInt32(Iceoryx2FFI.iox2_service_type_e_LOCAL)
    IPC = UInt32(Iceoryx2FFI.iox2_service_type_e_IPC)
end

@inline _service_type(value::ServiceType) = Iceoryx2FFI.iox2_service_type_e(UInt32(value))

@enum MessagingPattern::UInt32 begin
    MessagingPatternPublishSubscribe = UInt32(Iceoryx2FFI.iox2_messaging_pattern_e_PUBLISH_SUBSCRIBE)
    MessagingPatternEvent = UInt32(Iceoryx2FFI.iox2_messaging_pattern_e_EVENT)
    MessagingPatternRequestResponse = UInt32(Iceoryx2FFI.iox2_messaging_pattern_e_REQUEST_RESPONSE)
    MessagingPatternBlackboard = UInt32(Iceoryx2FFI.iox2_messaging_pattern_e_BLACKBOARD)
end

@inline _messaging_pattern(value::MessagingPattern) = Iceoryx2FFI.iox2_messaging_pattern_e(UInt32(value))

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

@inline function _messaging_pattern_enum(value::Iceoryx2FFI.iox2_messaging_pattern_e)
    if value == Iceoryx2FFI.iox2_messaging_pattern_e_PUBLISH_SUBSCRIBE
        return MessagingPatternPublishSubscribe
    elseif value == Iceoryx2FFI.iox2_messaging_pattern_e_EVENT
        return MessagingPatternEvent
    elseif value == Iceoryx2FFI.iox2_messaging_pattern_e_REQUEST_RESPONSE
        return MessagingPatternRequestResponse
    elseif value == Iceoryx2FFI.iox2_messaging_pattern_e_BLACKBOARD
        return MessagingPatternBlackboard
    end
    throw(ArgumentError("unsupported messaging pattern: $value"))
end

@inline function Base.getproperty(::Type{ServiceType}, name::Symbol)
    if name === :IPC
        return IPC
    elseif name === :LOCAL
        return LOCAL
    end
    return getfield(ServiceType, name)
end

@enum SignalHandlingMode::UInt32 begin
    SignalHandlingModeHandleTerminationRequests = UInt32(Iceoryx2FFI.iox2_signal_handling_mode_e_HANDLE_TERMINATION_REQUESTS)
    SignalHandlingModeDisabled = UInt32(Iceoryx2FFI.iox2_signal_handling_mode_e_DISABLED)
end

@inline function _signal_handling_mode(value::SignalHandlingMode)
    return Iceoryx2FFI.iox2_signal_handling_mode_e(UInt32(value))
end

@inline function _signal_handling_mode(value::Symbol)
    if value === :handle_termination_requests
        return Iceoryx2FFI.iox2_signal_handling_mode_e_HANDLE_TERMINATION_REQUESTS
    elseif value === :disabled
        return Iceoryx2FFI.iox2_signal_handling_mode_e_DISABLED
    end
    throw(ArgumentError("unsupported signal handling mode: $value"))
end

@inline _signal_handling_mode(value) = throw(ArgumentError("unsupported signal handling mode: $value"))

@inline function _signal_handling_mode_enum(value::Iceoryx2FFI.iox2_signal_handling_mode_e)
    if value == Iceoryx2FFI.iox2_signal_handling_mode_e_HANDLE_TERMINATION_REQUESTS
        return SignalHandlingModeHandleTerminationRequests
    elseif value == Iceoryx2FFI.iox2_signal_handling_mode_e_DISABLED
        return SignalHandlingModeDisabled
    end
    throw(ArgumentError("unsupported signal handling mode: $value"))
end

@enum WaitSetRunResult::UInt32 begin
    WaitSetRunResultTerminationRequest = UInt32(Iceoryx2FFI.iox2_waitset_run_result_e_TERMINATION_REQUEST)
    WaitSetRunResultInterrupt = UInt32(Iceoryx2FFI.iox2_waitset_run_result_e_INTERRUPT)
    WaitSetRunResultStopRequest = UInt32(Iceoryx2FFI.iox2_waitset_run_result_e_STOP_REQUEST)
    WaitSetRunResultAllEventsHandled = UInt32(Iceoryx2FFI.iox2_waitset_run_result_e_ALL_EVENTS_HANDLED)
end

@inline function _waitset_run_result_enum(value::Iceoryx2FFI.iox2_waitset_run_result_e)
    if value == Iceoryx2FFI.iox2_waitset_run_result_e_TERMINATION_REQUEST
        return WaitSetRunResultTerminationRequest
    elseif value == Iceoryx2FFI.iox2_waitset_run_result_e_INTERRUPT
        return WaitSetRunResultInterrupt
    elseif value == Iceoryx2FFI.iox2_waitset_run_result_e_STOP_REQUEST
        return WaitSetRunResultStopRequest
    elseif value == Iceoryx2FFI.iox2_waitset_run_result_e_ALL_EVENTS_HANDLED
        return WaitSetRunResultAllEventsHandled
    end
    throw(ArgumentError("unsupported WaitSet run result: $value"))
end

"""
    Node{S}

Handle to an iceoryx2 node for service type `S`.

Nodes own native resources and must be released with `close(node)` when no
longer needed. `S` is a `ServiceType` value baked into the type for
compile-time dispatch.
"""
mutable struct Node{S}
    handle::Iceoryx2FFI.iox2_node_h
    function Node{S}(handle::Iceoryx2FFI.iox2_node_h) where {S}
        obj = new{S}(handle)
        finalizer(Base.close, obj)
        return obj
    end
end

@inline unsafe_handle(obj::Node) = obj.handle
@inline Base.isvalid(obj::Node) = obj.handle != _IOX2_NULL
@inline invalidate!(obj::Node) = (obj.handle = _IOX2_NULL)

function Base.close(obj::Node)
    if obj.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_node_drop(obj.handle)
        obj.handle = _IOX2_NULL
    end
    return nothing
end

"""
    WaitSet{S}

WaitSet for service type `S`. Use `WaitSetBuilder(service_type)` to configure
and create a WaitSet, then call `wait_and_process*` to run callbacks.
"""
mutable struct WaitSet{S}
    handle::Iceoryx2FFI.iox2_waitset_h
    function WaitSet{S}(handle::Iceoryx2FFI.iox2_waitset_h) where {S}
        obj = new{S}(handle)
        finalizer(Base.close, obj)
        return obj
    end
end

@inline unsafe_handle(obj::WaitSet) = obj.handle
@inline Base.isvalid(obj::WaitSet) = obj.handle != _IOX2_NULL
@inline invalidate!(obj::WaitSet) = (obj.handle = _IOX2_NULL)

function Base.close(obj::WaitSet)
    if obj.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_waitset_drop(obj.handle)
        obj.handle = _IOX2_NULL
    end
    return nothing
end

"""
    WaitSetBuilder{S}

Builder for `WaitSet{S}`. Construct with `WaitSetBuilder(service_type)` and
configure signal handling before calling `create`.
"""
mutable struct WaitSetBuilder{S}
    handle::Iceoryx2FFI.iox2_waitset_builder_h
    function WaitSetBuilder{S}(handle::Iceoryx2FFI.iox2_waitset_builder_h) where {S}
        obj = new{S}(handle)
        finalizer(Base.close, obj)
        return obj
    end
end

@inline unsafe_handle(obj::WaitSetBuilder) = obj.handle
@inline Base.isvalid(obj::WaitSetBuilder) = obj.handle != _IOX2_NULL
@inline invalidate!(obj::WaitSetBuilder) = (obj.handle = _IOX2_NULL)

function Base.close(obj::WaitSetBuilder)
    if obj.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_waitset_builder_drop(obj.handle)
        obj.handle = _IOX2_NULL
    end
    return nothing
end
