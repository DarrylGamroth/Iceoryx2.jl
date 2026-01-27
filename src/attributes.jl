# Attribute helpers.

@inline function _ensure_valid_attribute(handle, what::AbstractString)
    handle != _IOX2_NULL || throw(ArgumentError("invalid $what"))
    return nothing
end

function AttributeSpecifier()
    handle_ref = Ref{Iceoryx2FFI.iox2_attribute_specifier_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_attribute_specifier_new(C_NULL, handle_ref)
    ret == _IOX2_OK || throw(ErrorException("failed to create AttributeSpecifier (code=$ret)"))
    return AttributeSpecifier(handle_ref[])
end

function AttributeVerifier()
    handle_ref = Ref{Iceoryx2FFI.iox2_attribute_verifier_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_attribute_verifier_new(C_NULL, handle_ref)
    ret == _IOX2_OK || throw(ErrorException("failed to create AttributeVerifier (code=$ret)"))
    return AttributeVerifier(handle_ref[])
end

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

function verify_requirements(verifier::AttributeVerifier, attrs::Union{AttributeSet, AttributeSetView})
    _ensure_valid_attribute(unsafe_handle(verifier), "attribute verifier")
    buf_len = Int(Iceoryx2FFI.IOX2_ATTRIBUTE_KEY_LENGTH)
    buffer = Vector{UInt8}(undef, buf_len + 1)
    ret = GC.@preserve buffer begin
        Iceoryx2FFI.iox2_attribute_verifier_verify_requirements(
            Ref{Iceoryx2FFI.iox2_attribute_verifier_h}(unsafe_handle(verifier)),
            _attribute_set_ptr(attrs),
            Base.unsafe_convert(Cstring, buffer),
            Iceoryx2FFI.c_size_t(buf_len + 1),
        )
    end
    ret == _IOX2_OK && return nothing
    return unsafe_string(pointer(buffer))
end

@inline function number_of_attributes(attrs::Union{AttributeSet, AttributeSetView})
    return Int(Iceoryx2FFI.iox2_attribute_set_number_of_attributes(_attribute_set_ptr(attrs)))
end

function Base.getindex(attrs::Union{AttributeSet, AttributeSetView}, index::Integer)
    count = number_of_attributes(attrs)
    1 <= index <= count || throw(BoundsError(attrs, index))
    handle = Iceoryx2FFI.iox2_attribute_set_index(_attribute_set_ptr(attrs), Iceoryx2FFI.c_size_t(index - 1))
    return AttributeRef(handle)
end

@inline function key(attr::AttributeRef)
    len = Int(Iceoryx2FFI.iox2_attribute_key_len(unsafe_handle(attr)))
    buffer = Vector{UInt8}(undef, len + 1)
    GC.@preserve buffer begin
        Iceoryx2FFI.iox2_attribute_key(
            unsafe_handle(attr),
            Base.unsafe_convert(Cstring, buffer),
            Iceoryx2FFI.c_size_t(len + 1),
        )
    end
    return unsafe_string(pointer(buffer), len)
end

@inline function value(attr::AttributeRef)
    len = Int(Iceoryx2FFI.iox2_attribute_value_len(unsafe_handle(attr)))
    buffer = Vector{UInt8}(undef, len + 1)
    GC.@preserve buffer begin
        Iceoryx2FFI.iox2_attribute_value(
            unsafe_handle(attr),
            Base.unsafe_convert(Cstring, buffer),
            Iceoryx2FFI.c_size_t(len + 1),
        )
    end
    return unsafe_string(pointer(buffer), len)
end

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
            Base.unsafe_convert(Cstring, buffer),
            Iceoryx2FFI.c_size_t(buffer_len + 1),
            has_value,
        )
    end
    has_value[] || return nothing
    return unsafe_string(pointer(buffer))
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
                Base.unsafe_convert(Cstring, buffer),
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
