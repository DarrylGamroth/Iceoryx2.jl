# WaitSet wrappers.

"""
    WaitSetBuilder(service_type::ServiceType) -> WaitSetBuilder

Create a WaitSet builder for the given service type.
"""
function WaitSetBuilder(service_type::ServiceType)
    handle_ref = Ref{Iceoryx2FFI.iox2_waitset_builder_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_waitset_builder_new(C_NULL, handle_ref)
    return WaitSetBuilder{service_type}(handle_ref[])
end

"""
    signal_handling_mode!(builder::WaitSetBuilder, mode)

Configure signal handling on the WaitSet builder.
"""
function signal_handling_mode!(builder::WaitSetBuilder, mode::Union{
        Symbol, SignalHandlingMode})
    _require_valid(unsafe_handle(builder), "WaitSet builder")
    Iceoryx2FFI.iox2_waitset_builder_set_signal_handling_mode(
        Ref{Iceoryx2FFI.iox2_waitset_builder_h}(unsafe_handle(builder)),
        _signal_handling_mode(mode))
    return builder
end

"""
    create(builder::WaitSetBuilder{S}) -> WaitSet{S}

Create a WaitSet and consume the builder.
"""
function create(builder::WaitSetBuilder{S}) where {S}
    _require_valid(unsafe_handle(builder), "WaitSet builder")
    handle_ref = Ref{Iceoryx2FFI.iox2_waitset_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_waitset_builder_create(unsafe_handle(builder), _service_type(S), C_NULL, handle_ref)
    invalidate!(builder)
    check_ok(ret, Iceoryx2FFI.iox2_waitset_create_error_e)
    return WaitSet{S}(handle_ref[])
end

"""
    create(f::Function, builder::WaitSetBuilder{S})

Create a WaitSet, call `f(waitset)`, and close it in a `finally` block.
"""
function create(f::Function, builder::WaitSetBuilder{S}) where {S}
    waitset = create(builder)
    try
        return f(waitset)
    finally
        close(waitset)
    end
end

"""
    signal_handling_mode(waitset::WaitSet)

Return the WaitSet signal handling mode.
"""
@inline function signal_handling_mode(waitset::WaitSet)
    return _signal_handling_mode_enum(
        Iceoryx2FFI.iox2_waitset_signal_handling_mode(Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset))),
    )
end

"""
    isempty(waitset::WaitSet) -> Bool

Return whether the WaitSet has no attached objects.
"""
@inline function Base.isempty(waitset::WaitSet)
    return Iceoryx2FFI.iox2_waitset_is_empty(Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset)))
end

"""
    length(waitset::WaitSet) -> Int

Return the number of attachments in the WaitSet.
"""
@inline function Base.length(waitset::WaitSet)
    return Int(Iceoryx2FFI.iox2_waitset_len(Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset))))
end

"""
    capacity(waitset::WaitSet) -> Int

Return the WaitSet capacity.
"""
@inline function capacity(waitset::WaitSet)
    return Int(Iceoryx2FFI.iox2_waitset_capacity(Ref{Iceoryx2FFI.iox2_waitset_h}(unsafe_handle(waitset))))
end
