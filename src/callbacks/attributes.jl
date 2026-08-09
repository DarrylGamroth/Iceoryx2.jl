"""
    AbstractAttributeValueHandler

Abstract handler for attribute value iteration.
"""
abstract type AbstractAttributeValueHandler end

"""
    AttributeValueHandler(f)

Wrap a callable `f(value::String)` for attribute iteration.
"""
mutable struct AttributeValueHandler{T} <: AbstractAttributeValueHandler
    on_value::T
    ref::Base.RefValue{AttributeValueHandler{T}}
    last_exception::Base.RefValue{_CallbackException}
    function AttributeValueHandler{T}(on_value::T) where {T}
        ref = Ref{AttributeValueHandler{T}}()
        obj = new{T}(on_value, ref, _callback_exception_ref())
        return _init_handler_ref!(obj)
    end
end

function AttributeValueHandler(on_value::T) where {T}
    AttributeValueHandler{T}(on_value)
end

on_attribute_value(h::AttributeValueHandler) = h.on_value
@inline last_callback_exception(handler::AttributeValueHandler) = handler.last_exception[]

function _attribute_value_wrapper(value::Cstring, handler::T) where {T <:
                                                                     AbstractAttributeValueHandler}
    try
        return _callback_progression(on_attribute_value(handler)(unsafe_string(value)))
    catch err
        _record_callback_exception!(handler, err)
        return Iceoryx2FFI.iox2_callback_progression_e_STOP
    end
end

function _attribute_value_cfunction(::T) where {T <: AbstractAttributeValueHandler}
    @cfunction(_attribute_value_wrapper,
        Iceoryx2FFI.iox2_callback_progression_e,
        (Cstring, Ref{T}),)
end

"""
    AbstractAttributeValuePtrHandler

Abstract handler for attribute value iteration with raw C strings.
"""
abstract type AbstractAttributeValuePtrHandler end

"""
    AttributeValuePtrHandler(f)

Wrap a callable `f(value::Cstring)` for attribute iteration.
"""
mutable struct AttributeValuePtrHandler{T} <: AbstractAttributeValuePtrHandler
    on_value::T
    ref::Base.RefValue{AttributeValuePtrHandler{T}}
    last_exception::Base.RefValue{_CallbackException}
    function AttributeValuePtrHandler{T}(on_value::T) where {T}
        ref = Ref{AttributeValuePtrHandler{T}}()
        obj = new{T}(on_value, ref, _callback_exception_ref())
        return _init_handler_ref!(obj)
    end
end

function AttributeValuePtrHandler(on_value::T) where {T}
    AttributeValuePtrHandler{T}(on_value)
end

on_attribute_value_ptr(h::AttributeValuePtrHandler) = h.on_value
@inline last_callback_exception(handler::AttributeValuePtrHandler) = handler.last_exception[]

function _attribute_value_ptr_wrapper(value::Cstring, handler::T) where {T <:
                                                                         AbstractAttributeValuePtrHandler}
    try
        return _callback_progression(on_attribute_value_ptr(handler)(value))
    catch err
        _record_callback_exception!(handler, err)
        return Iceoryx2FFI.iox2_callback_progression_e_STOP
    end
end

function _attribute_value_ptr_cfunction(::T) where {T <: AbstractAttributeValuePtrHandler}
    @cfunction(_attribute_value_ptr_wrapper,
        Iceoryx2FFI.iox2_callback_progression_e,
        (Cstring, Ref{T}),)
end

@inline function _attribute_set_ptr(attrs::AttributeSet)
    _require_valid(unsafe_handle(attrs), "attribute set")
    return Iceoryx2FFI.iox2_cast_attribute_set_ptr(unsafe_handle(attrs))
end

@inline function _attribute_set_ptr(attrs::AttributeSetView)
    return unsafe_handle(attrs)
end

"""
    each_attribute_value(attrs, key, handler)
    each_attribute_value(f::Function, attrs, key)

Iterate over attribute values for a key, passing values as `String`.
"""
function each_attribute_value(
        attrs::Union{AttributeSet, AttributeSetView},
        key::AbstractString,
        handler::AttributeValueHandler
)
    key_str = String(key)
    handler_ref = _handler_ref(handler)
    _clear_callback_exception!(handler)
    GC.@preserve attrs handler_ref key_str begin
        Iceoryx2FFI.iox2_attribute_set_iter_key_values(
            _attribute_set_ptr(attrs),
            Base.unsafe_convert(Cstring, key_str),
            _attribute_value_cfunction(handler),
            handler_ref
        )
    end
    _rethrow_callback_exception!(handler)
    return nothing
end

function each_attribute_value(
        attrs::Union{AttributeSet, AttributeSetView},
        key::AbstractString,
        handler::AbstractAttributeValueHandler
)
    return each_attribute_value(attrs, key, AttributeValueHandler(on_attribute_value(handler)))
end

function each_attribute_value(f::Function, attrs::Union{AttributeSet, AttributeSetView}, key::AbstractString)
    return each_attribute_value(attrs, key, AttributeValueHandler(f))
end

"""
    each_attribute_value_ptr(attrs, key, handler)
    each_attribute_value_ptr(f::Function, attrs, key)

Iterate over attribute values for a key, passing raw `Cstring` values.
"""
function each_attribute_value_ptr(
        attrs::Union{AttributeSet, AttributeSetView},
        key::AbstractString,
        handler::AttributeValuePtrHandler
)
    key_str = String(key)
    handler_ref = _handler_ref(handler)
    _clear_callback_exception!(handler)
    GC.@preserve attrs handler_ref key_str begin
        Iceoryx2FFI.iox2_attribute_set_iter_key_values(
            _attribute_set_ptr(attrs),
            Base.unsafe_convert(Cstring, key_str),
            _attribute_value_ptr_cfunction(handler),
            handler_ref
        )
    end
    _rethrow_callback_exception!(handler)
    return nothing
end

function each_attribute_value_ptr(
        attrs::Union{AttributeSet, AttributeSetView},
        key::AbstractString,
        handler::AbstractAttributeValuePtrHandler
)
    return each_attribute_value_ptr(
        attrs,
        key,
        AttributeValuePtrHandler(on_attribute_value_ptr(handler))
    )
end

function each_attribute_value_ptr(
        f::Function, attrs::Union{AttributeSet, AttributeSetView}, key::AbstractString)
    return each_attribute_value_ptr(attrs, key, AttributeValuePtrHandler(f))
end

"""
    attribute_values(attrs, key) -> Vector{String}

Collect all attribute values for a key into a vector.
"""
function attribute_values(attrs::Union{AttributeSet, AttributeSetView}, key::AbstractString)
    values = String[]
    each_attribute_value(attrs, key) do value
        push!(values, value)
        return true
    end
    return values
end
