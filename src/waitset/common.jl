# WaitSet wrappers.

@inline _signal_handling_mode(value::Iceoryx2FFI.iox2_signal_handling_mode_e) = value

@inline function _signal_handling_mode(value::Symbol)
    if value === :handle_termination_requests
        return Iceoryx2FFI.iox2_signal_handling_mode_e_HANDLE_TERMINATION_REQUESTS
    elseif value === :disabled
        return Iceoryx2FFI.iox2_signal_handling_mode_e_DISABLED
    end
    throw(ArgumentError("unsupported signal handling mode: $value"))
end

@inline _signal_handling_mode(value) = throw(ArgumentError("unsupported signal handling mode: $value"))

"""
    WaitsetBuilder(service_type::ServiceType) -> WaitsetBuilder

Create a waitset builder for the given service type.
"""
function WaitsetBuilder(service_type::ServiceType)
    handle_ref = Ref{Iceoryx2FFI.iox2_waitset_builder_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_waitset_builder_new(C_NULL, handle_ref)
    return WaitsetBuilder{service_type}(handle_ref[])
end

"""
    signal_handling_mode!(builder::WaitsetBuilder, mode)

Configure signal handling on the waitset builder.
"""
function signal_handling_mode!(builder::WaitsetBuilder, mode::Union{Symbol, Iceoryx2FFI.iox2_signal_handling_mode_e})
    _require_valid(unsafe_handle(builder), "waitset builder")
    Iceoryx2FFI.iox2_waitset_builder_set_signal_handling_mode(Ref{Iceoryx2FFI.iox2_waitset_builder_h}(unsafe_handle(builder)), _signal_handling_mode(mode))
    return builder
end

"""
    create(builder::WaitsetBuilder{S}) -> Waitset{S}

Create a waitset and consume the builder.
"""
function create(builder::WaitsetBuilder{S}) where {S}
    _require_valid(unsafe_handle(builder), "waitset builder")
    handle_ref = Ref{Iceoryx2FFI.iox2_waitset_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_waitset_builder_create(unsafe_handle(builder), _service_type(S), C_NULL, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_waitset_create_error_e)
    invalidate!(builder)
    return Waitset{S}(handle_ref[])
end

"""
    create(f::Function, builder::WaitsetBuilder{S})

Create a waitset, call `f(waitset)`, and close it in a `finally` block.
"""
function create(f::Function, builder::WaitsetBuilder{S}) where {S}
    waitset = create(builder)
    try
        return f(waitset)
    finally
        close(waitset)
    end
end

"""
    signal_handling_mode(waitset::Waitset)

Return the waitset signal handling mode.
"""
@inline function signal_handling_mode(waitset::Waitset)
    return Iceoryx2FFI.iox2_waitset_signal_handling_mode(Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset)))
end

"""
    isempty(waitset::Waitset) -> Bool

Return whether the waitset has no attached objects.
"""
@inline function Base.isempty(waitset::Waitset)
    return Iceoryx2FFI.iox2_waitset_is_empty(Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset)))
end

"""
    length(waitset::Waitset) -> Int

Return the number of attachments in the waitset.
"""
@inline function Base.length(waitset::Waitset)
    return Int(Iceoryx2FFI.iox2_waitset_len(Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset))))
end

"""
    capacity(waitset::Waitset) -> Int

Return the waitset capacity.
"""
@inline function capacity(waitset::Waitset)
    return Int(Iceoryx2FFI.iox2_waitset_capacity(Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset))))
end
