# Unique ID helpers.

@inline function _unique_id_bytes(id_handle, len, value_fn)
    buffer = Vector{UInt8}(undef, len)
    GC.@preserve buffer begin
        value_fn(id_handle, pointer(buffer), Iceoryx2FFI.c_size_t(len))
    end
    return buffer
end

# The concrete Unique*Id helpers (bytes/id/==/isless) are generated in src/generated/wrappers.jl.
