# Builder and factory helpers.

@inline function _require_valid(handle, what::AbstractString)
    handle != _IOX2_NULL || throw(ArgumentError("invalid $what"))
    return nothing
end

@inline function _require_isbits(::Type{T}) where {T}
    isbitstype(T) || throw(ArgumentError("payload type must be isbits"))
    return nothing
end
