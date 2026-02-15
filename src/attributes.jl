# Attribute helpers.

import StringViews: StringView

"""
    AttributeScratch

Reusable buffers for allocation-free attribute access. Use with
`with_attribute_scratch` and the `*_view!` APIs.
"""
struct AttributeScratch
    key_buffer::Vector{UInt8}
    value_buffer::Vector{UInt8}
    key_value_buffer::Vector{UInt8}
end

"""
    AttributeScratch() -> AttributeScratch

Create scratch buffers sized for maximum attribute key/value length.
"""
function AttributeScratch()
    key_len = Int(Iceoryx2FFI.IOX2_ATTRIBUTE_KEY_LENGTH)
    value_len = Int(Iceoryx2FFI.IOX2_ATTRIBUTE_VALUE_LENGTH)
    return AttributeScratch(
        Vector{UInt8}(undef, key_len + 1),
        Vector{UInt8}(undef, value_len + 1),
        Vector{UInt8}(undef, value_len + 1),
    )
end

"""
    with_attribute_scratch(f::Function)

Create a scratch buffer and pass it to `f(scratch)`.
"""
function with_attribute_scratch(f::Function)
    scratch = AttributeScratch()
    return f(scratch)
end

@inline function _ensure_valid_attribute(handle, what::AbstractString)
    handle != _IOX2_NULL || throw(ArgumentError("invalid $what"))
    return nothing
end

"""
    AttributeSpecifier() -> AttributeSpecifier

Create an attribute specifier for defining service attributes.
"""
function AttributeSpecifier()
    handle_ref = Ref{Iceoryx2FFI.iox2_attribute_specifier_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_attribute_specifier_new(C_NULL, handle_ref)
    ret == _IOX2_OK || throw(ErrorException("failed to create AttributeSpecifier (code=$ret)"))
    return AttributeSpecifier(handle_ref[])
end

"""
    AttributeVerifier() -> AttributeVerifier

Create an attribute verifier for matching service attributes.
"""
function AttributeVerifier()
    handle_ref = Ref{Iceoryx2FFI.iox2_attribute_verifier_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_attribute_verifier_new(C_NULL, handle_ref)
    ret == _IOX2_OK || throw(ErrorException("failed to create AttributeVerifier (code=$ret)"))
    return AttributeVerifier(handle_ref[])
end

"""
    define!(specifier::AttributeSpecifier, key, value)

Add a key/value attribute to the specifier.
"""
function define!(specifier::AttributeSpecifier, key::AbstractString, value::AbstractString)
    _ensure_valid_attribute(unsafe_handle(specifier), "attribute specifier")
    key_str = String(key)
    value_str = String(value)
    GC.@preserve key_str value_str begin
        ret = Iceoryx2FFI.iox2_attribute_specifier_define(
            Ref{Iceoryx2FFI.iox2_attribute_specifier_h}(unsafe_handle(specifier)),
            Base.unsafe_convert(Cstring, key_str),
            Base.unsafe_convert(Cstring, value_str),
        )
        check_ok(ret, Iceoryx2FFI.iox2_attribute_definition_error_e)
    end
    return specifier
end

"""
    require!(verifier::AttributeVerifier, key, value)

Require a key/value attribute when opening a service.
"""
function require!(verifier::AttributeVerifier, key::AbstractString, value::AbstractString)
    _ensure_valid_attribute(unsafe_handle(verifier), "attribute verifier")
    key_str = String(key)
    value_str = String(value)
    GC.@preserve key_str value_str begin
        ret = Iceoryx2FFI.iox2_attribute_verifier_require(
            Ref{Iceoryx2FFI.iox2_attribute_verifier_h}(unsafe_handle(verifier)),
            Base.unsafe_convert(Cstring, key_str),
            Base.unsafe_convert(Cstring, value_str),
        )
        check_ok(ret, Iceoryx2FFI.iox2_attribute_verification_error_e)
    end
    return verifier
end

"""
    require_key!(verifier::AttributeVerifier, key)

Require a key to be present (any value).
"""
function require_key!(verifier::AttributeVerifier, key::AbstractString)
    _ensure_valid_attribute(unsafe_handle(verifier), "attribute verifier")
    key_str = String(key)
    GC.@preserve key_str begin
        ret = Iceoryx2FFI.iox2_attribute_verifier_require_key(
            Ref{Iceoryx2FFI.iox2_attribute_verifier_h}(unsafe_handle(verifier)),
            Base.unsafe_convert(Cstring, key_str),
        )
        check_ok(ret, Iceoryx2FFI.iox2_attribute_verification_error_e)
    end
    return verifier
end

"""
    attributes(specifier::AttributeSpecifier) -> AttributeSetView
    attributes(verifier::AttributeVerifier) -> AttributeSetView

Return a view of attributes held by the specifier or verifier.
"""
@inline function attributes(specifier::AttributeSpecifier)
    _ensure_valid_attribute(unsafe_handle(specifier), "attribute specifier")
    ptr = Iceoryx2FFI.iox2_attribute_specifier_attributes(Ref{Iceoryx2FFI.iox2_attribute_specifier_h}(unsafe_handle(specifier)))
    return AttributeSetView(ptr)
end

@inline function attributes(verifier::AttributeVerifier)
    _ensure_valid_attribute(unsafe_handle(verifier), "attribute verifier")
    ptr = Iceoryx2FFI.iox2_attribute_verifier_attributes(Ref{Iceoryx2FFI.iox2_attribute_verifier_h}(unsafe_handle(verifier)))
    return AttributeSetView(ptr)
end

"""
    verify_requirements(verifier, attrs) -> Union{Nothing,String}

Return `nothing` when requirements are satisfied; otherwise return a string
describing the failure.
"""
function verify_requirements(verifier::AttributeVerifier, attrs::Union{AttributeSet, AttributeSetView})
    _ensure_valid_attribute(unsafe_handle(verifier), "attribute verifier")
    buf_len = Int(Iceoryx2FFI.IOX2_ATTRIBUTE_KEY_LENGTH)
    buffer = Vector{UInt8}(undef, buf_len + 1)
    ret = GC.@preserve buffer begin
        Iceoryx2FFI.iox2_attribute_verifier_verify_requirements(
            Ref{Iceoryx2FFI.iox2_attribute_verifier_h}(unsafe_handle(verifier)),
            _attribute_set_ptr(attrs),
            Ptr{Cchar}(pointer(buffer)),
            Iceoryx2FFI.c_size_t(buf_len + 1),
        )
    end
    ret == _IOX2_OK && return nothing
    return _string_from_buffer(buffer)
end

"""
    number_of_attributes(attrs) -> Int

Return the number of attributes in the set.
"""
@inline function number_of_attributes(attrs::Union{AttributeSet, AttributeSetView})
    return Int(Iceoryx2FFI.iox2_attribute_set_number_of_attributes(_attribute_set_ptr(attrs)))
end

Base.length(attrs::Union{AttributeSet, AttributeSetView}) = number_of_attributes(attrs)
Base.firstindex(::Union{AttributeSet, AttributeSetView}) = 1
Base.lastindex(attrs::Union{AttributeSet, AttributeSetView}) = length(attrs)
Base.eltype(::Type{AttributeSet}) = AttributeRef
Base.eltype(::Type{AttributeSetView}) = AttributeRef

function Base.iterate(attrs::Union{AttributeSet, AttributeSetView}, state::Int = 1)
    state > length(attrs) && return nothing
    return attrs[state], state + 1
end

"""
    getindex(attrs, index) -> AttributeRef

Return the attribute at the given index (1-based).
"""
function Base.getindex(attrs::Union{AttributeSet, AttributeSetView}, index::Integer)
    count = number_of_attributes(attrs)
    1 <= index <= count || throw(BoundsError(attrs, index))
    handle = Iceoryx2FFI.iox2_attribute_set_index(_attribute_set_ptr(attrs), Iceoryx2FFI.c_size_t(index - 1))
    return AttributeRef(handle)
end

"""
    key(attr::AttributeRef) -> String

Copy the attribute key into a new `String`.
"""
function key(attr::AttributeRef)
    len = Int(Iceoryx2FFI.iox2_attribute_key_len(unsafe_handle(attr)))
    buffer = Vector{UInt8}(undef, len + 1)
    GC.@preserve buffer begin
        Iceoryx2FFI.iox2_attribute_key(
            unsafe_handle(attr),
            Ptr{Cchar}(pointer(buffer)),
            Iceoryx2FFI.c_size_t(len + 1),
        )
    end
    return unsafe_string(pointer(buffer), len)
end

"""
    key_view!(buffer, attr) -> StringView
    key_view!(scratch::AttributeScratch, attr) -> StringView

Read the attribute key into a reusable buffer without allocating a `String`.
"""
function key_view!(buffer::Vector{UInt8}, attr::AttributeRef)
    len = Int(Iceoryx2FFI.iox2_attribute_key_len(unsafe_handle(attr)))
    length(buffer) < len + 1 && resize!(buffer, len + 1)
    GC.@preserve buffer begin
        Iceoryx2FFI.iox2_attribute_key(
            unsafe_handle(attr),
            Ptr{Cchar}(pointer(buffer)),
            Iceoryx2FFI.c_size_t(len + 1),
        )
    end
    resize!(buffer, len)
    return StringView(buffer)
end

function key_view!(scratch::AttributeScratch, attr::AttributeRef)
    return key_view!(scratch.key_buffer, attr)
end

"""
    value(attr::AttributeRef) -> String

Copy the attribute value into a new `String`.
"""
function value(attr::AttributeRef)
    len = Int(Iceoryx2FFI.iox2_attribute_value_len(unsafe_handle(attr)))
    buffer = Vector{UInt8}(undef, len + 1)
    GC.@preserve buffer begin
        Iceoryx2FFI.iox2_attribute_value(
            unsafe_handle(attr),
            Ptr{Cchar}(pointer(buffer)),
            Iceoryx2FFI.c_size_t(len + 1),
        )
    end
    return unsafe_string(pointer(buffer), len)
end

"""
    value_view!(buffer, attr) -> StringView
    value_view!(scratch::AttributeScratch, attr) -> StringView

Read the attribute value into a reusable buffer without allocating a `String`.
"""
function value_view!(buffer::Vector{UInt8}, attr::AttributeRef)
    len = Int(Iceoryx2FFI.iox2_attribute_value_len(unsafe_handle(attr)))
    length(buffer) < len + 1 && resize!(buffer, len + 1)
    GC.@preserve buffer begin
        Iceoryx2FFI.iox2_attribute_value(
            unsafe_handle(attr),
            Ptr{Cchar}(pointer(buffer)),
            Iceoryx2FFI.c_size_t(len + 1),
        )
    end
    resize!(buffer, len)
    return StringView(buffer)
end

function value_view!(scratch::AttributeScratch, attr::AttributeRef)
    return value_view!(scratch.value_buffer, attr)
end

"""
    number_of_key_values(attrs, key) -> Int

Return the number of values associated with the given key.
"""
function number_of_key_values(attrs::Union{AttributeSet, AttributeSetView}, key::AbstractString)
    key_str = String(key)
    GC.@preserve key_str begin
        return Int(
            Iceoryx2FFI.iox2_attribute_set_number_of_key_values(
                _attribute_set_ptr(attrs),
                Base.unsafe_convert(Cstring, key_str),
            ),
        )
    end
end

function key_value(attrs::Union{AttributeSet, AttributeSetView}, key::AbstractString, index::Integer)
    index < 1 && throw(BoundsError(attrs, index))
    key_str = String(key)
    buffer_len = Int(Iceoryx2FFI.IOX2_ATTRIBUTE_VALUE_LENGTH)
    buffer = Vector{UInt8}(undef, buffer_len + 1)
    has_value = Ref{Bool}(false)
    GC.@preserve key_str buffer begin
        Iceoryx2FFI.iox2_attribute_set_key_value(
            _attribute_set_ptr(attrs),
            Base.unsafe_convert(Cstring, key_str),
            Iceoryx2FFI.c_size_t(index - 1),
            Ptr{Cchar}(pointer(buffer)),
            Iceoryx2FFI.c_size_t(buffer_len + 1),
            has_value,
        )
    end
    has_value[] || return nothing
    return _string_from_buffer(buffer)
end

function key_value_view!(buffer::Vector{UInt8}, attrs::Union{AttributeSet, AttributeSetView}, key::AbstractString, index::Integer)
    index < 1 && throw(BoundsError(attrs, index))
    key_str = String(key)
    buffer_len = Int(Iceoryx2FFI.IOX2_ATTRIBUTE_VALUE_LENGTH)
    length(buffer) < buffer_len + 1 && resize!(buffer, buffer_len + 1)
    has_value = Ref{Bool}(false)
    GC.@preserve key_str buffer begin
        Iceoryx2FFI.iox2_attribute_set_key_value(
            _attribute_set_ptr(attrs),
            Base.unsafe_convert(Cstring, key_str),
            Iceoryx2FFI.c_size_t(index - 1),
            Ptr{Cchar}(pointer(buffer)),
            Iceoryx2FFI.c_size_t(buffer_len + 1),
            has_value,
        )
    end
    has_value[] || return nothing
    return _string_view_from_buffer!(buffer)
end

function key_value_view!(scratch::AttributeScratch, attrs::Union{AttributeSet, AttributeSetView}, key::AbstractString, index::Integer)
    return key_value_view!(scratch.key_value_buffer, attrs, key, index)
end

function _string_from_buffer(buffer::Vector{UInt8})
    idx = findfirst(==(0x00), buffer)
    len = idx === nothing ? length(buffer) : idx - 1
    return unsafe_string(pointer(buffer), len)
end

function _string_view_from_buffer!(buffer::Vector{UInt8})
    idx = findfirst(==(0x00), buffer)
    len = idx === nothing ? length(buffer) : idx - 1
    resize!(buffer, len)
    return StringView(buffer)
end

function keys(verifier::AttributeVerifier)
    _ensure_valid_attribute(unsafe_handle(verifier), "attribute verifier")
    handle_ref = Ref{Iceoryx2FFI.iox2_attribute_verifier_h}(unsafe_handle(verifier))
    count = Int(Iceoryx2FFI.iox2_attribute_verifier_number_of_keys(handle_ref))
    out = Vector{String}(undef, count)
    for idx in 0:(count - 1)
        len = Int(Iceoryx2FFI.iox2_attribute_verifier_key_len(handle_ref, Iceoryx2FFI.c_size_t(idx)))
        buffer = Vector{UInt8}(undef, len + 1)
        GC.@preserve buffer begin
            Iceoryx2FFI.iox2_attribute_verifier_key(
                handle_ref,
                Iceoryx2FFI.c_size_t(idx),
                Ptr{Cchar}(pointer(buffer)),
                Iceoryx2FFI.c_size_t(len + 1),
            )
        end
        out[idx + 1] = unsafe_string(pointer(buffer), len)
    end
    return out
end

function to_owned(attrs::Union{AttributeSet, AttributeSetView})
    handle_ref = Ref{Iceoryx2FFI.iox2_attribute_set_h}(_IOX2_NULL)
    Iceoryx2FFI.iox2_attribute_set_new_clone(C_NULL, _attribute_set_ptr(attrs), handle_ref)
    return AttributeSet(handle_ref[])
end
