# Builder and factory helpers.

@inline function _require_valid(handle, what::AbstractString)
    handle != _IOX2_NULL || throw(ArgumentError("invalid $what"))
    return nothing
end
