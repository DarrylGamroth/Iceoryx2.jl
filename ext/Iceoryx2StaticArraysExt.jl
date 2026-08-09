module Iceoryx2StaticArraysExt

using Iceoryx2
using StaticArrays

function Iceoryx2._variant_type(::Type{T}) where {T <: StaticArrays.StaticArray}
    Iceoryx2.Iceoryx2FFI.iox2_type_variant_e_FIXED_SIZE
end

Iceoryx2._payload_type(::Type{T}) where {T <: StaticArrays.StaticArray} = T
end
