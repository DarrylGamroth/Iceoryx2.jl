struct StaticString{N}
    len::UInt32
    data::NTuple{N, UInt8}
end

function static_string(::Val{N}, value::AbstractString) where {N}
    bytes = codeunits(String(value))
    len = min(length(bytes), N)
    data = ntuple(i -> i <= len ? bytes[i] : 0x00, N)
    return StaticString{N}(UInt32(len), data)
end

Base.string(value::StaticString{N}) where {N} = String(Vector{UInt8}(value.data[1:Int(value.len)]))

function Base.show(io::IO, value::StaticString)
    print(io, '"', string(value), '"')
end

struct StaticVector{T,N}
    len::UInt32
    data::NTuple{N, T}
end

function static_vector_from_value(::Type{T}, ::Val{N}, count::Integer, value::T) where {T,N}
    count > N && throw(ArgumentError("count exceeds capacity"))
    fill_value = Base.hasmethod(zero, Tuple{Type{T}}) ? zero(T) : value
    data = ntuple(i -> i <= count ? value : fill_value, N)
    return StaticVector{T,N}(UInt32(count), data)
end

function static_vector_push(vec::StaticVector{T,N}, value::T) where {T,N}
    len = Int(vec.len)
    len < N || throw(ArgumentError("StaticVector is full"))
    data = ntuple(i -> i == len + 1 ? value : vec.data[i], N)
    return StaticVector{T,N}(UInt32(len + 1), data)
end

Base.length(vec::StaticVector) = Int(vec.len)
Base.getindex(vec::StaticVector{T,N}, i::Integer) where {T,N} = vec.data[i]

function Base.show(io::IO, vec::StaticVector{T,N}) where {T,N}
    print(io, "StaticVector{")
    print(io, T)
    print(io, ", ", N, ", len=")
    print(io, vec.len)
    print(io, ")")
end
