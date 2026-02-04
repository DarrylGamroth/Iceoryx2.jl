# Messaging patterns: pub/sub, request/response, event, blackboard.

@inline function _require_isbits(::Type{T}) where {T}
    isbitstype(T) || throw(ArgumentError("payload type must be isbits"))
    return nothing
end

_variant_type(::Type{T}) where {T} = iox2_type_variant_e_FIXED_SIZE
_variant_type(::Type{T}) where {T<:AbstractVector} = iox2_type_variant_e_DYNAMIC
_variant_type(::Type{T}) where {T<:Tuple} = iox2_type_variant_e_FIXED_SIZE
_payload_type(::Type{T}) where {T} = T
_payload_type(::Type{T}) where {T<:AbstractArray} = eltype(T)

_allocation_strategy(value::Iceoryx2FFI.iox2_allocation_strategy_e) = value

@inline function _allocation_strategy(value::Symbol)
    if value === :best_fit
        return Iceoryx2FFI.iox2_allocation_strategy_e_BEST_FIT
    elseif value === :power_of_two
        return Iceoryx2FFI.iox2_allocation_strategy_e_POWER_OF_TWO
    elseif value === :static
        return Iceoryx2FFI.iox2_allocation_strategy_e_STATIC
    end
    throw(ArgumentError("unsupported allocation_strategy: $value"))
end

@inline _allocation_strategy(value) = throw(ArgumentError("unsupported allocation_strategy: $value"))

type_name(::Type{UInt8}) = "u8"
type_name(::Type{UInt16}) = "u16"
type_name(::Type{UInt32}) = "u32"
type_name(::Type{UInt64}) = "u64"
type_name(::Type{UInt128}) = "u128"
type_name(::Type{Int8}) = "i8"
type_name(::Type{Int16}) = "i16"
type_name(::Type{Int32}) = "i32"
type_name(::Type{Int64}) = "i64"
type_name(::Type{Int128}) = "i128"
type_name(::Type{Float32}) = "f32"
type_name(::Type{Float64}) = "f64"
type_name(::Type{Nothing}) = "()"

"""
    type_name(::Type{T}) -> String

Return the cross-language type name used in iceoryx2 static config. For custom
payloads/headers/keys you must define:

```julia
Iceoryx2.type_name(::Type{MyType}) = "MyType"
```
"""
function type_name(::Type{T}) where {T}
    throw(ArgumentError("type_name(::Type{$T}) is not defined; define Iceoryx2.type_name(::Type{$T}) = \"...\" for cross-language compatibility"))
end

@inline function _type_details(::Type{T}) where {T}
    name = type_name(T)
    return name,
        Iceoryx2FFI.c_size_t(ncodeunits(name)),
        Iceoryx2FFI.c_size_t(sizeof(T)),
        Iceoryx2FFI.c_size_t(Base.datatype_alignment(T))
end

"""
    Slice{T,O} <: AbstractVector{T}

Allocation-free view into shared memory payloads. The slice is valid only while
its owning handle is alive. Access is bounds-checked by default.
"""
struct Slice{T,O} <: AbstractVector{T}
    ptr::Ptr{T}
    len::Int
    owner::O
end

Slice{T}(ptr::Ptr{T}, len::Integer) where {T} = Slice{T,Nothing}(ptr, Int(len), nothing)
Slice{T}(ptr::Ptr{T}, len::Integer, owner) where {T} = Slice{T,typeof(owner)}(ptr, Int(len), owner)

mutable struct HeaderSlot{S,H}
    storage::Base.RefValue{S}
    handle_ref::Base.RefValue{H}
    function HeaderSlot{S,H}() where {S,H}
        new(Ref{S}(), Ref{H}(_IOX2_NULL))
    end
end

@inline function _drop_header!(slot::HeaderSlot{Iceoryx2FFI.iox2_publish_subscribe_header_t,H}) where {H}
    if slot.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_publish_subscribe_header_drop(slot.handle_ref[])
        slot.handle_ref[] = _IOX2_NULL
    end
    return nothing
end

@inline function _drop_header!(slot::HeaderSlot{Iceoryx2FFI.iox2_request_header_t,H}) where {H}
    if slot.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_request_header_drop(slot.handle_ref[])
        slot.handle_ref[] = _IOX2_NULL
    end
    return nothing
end

@inline function _drop_header!(slot::HeaderSlot{Iceoryx2FFI.iox2_response_header_t,H}) where {H}
    if slot.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_response_header_drop(slot.handle_ref[])
        slot.handle_ref[] = _IOX2_NULL
    end
    return nothing
end

Base.length(slice::Slice) = slice.len
Base.size(slice::Slice) = (slice.len,)
Base.axes(slice::Slice) = (Base.OneTo(slice.len),)
Base.eltype(::Type{Slice{T}}) where {T} = T
Base.elsize(::Type{Slice{T}}) where {T} = sizeof(T)
Base.IndexStyle(::Type{<:Slice}) = IndexLinear()
Base.firstindex(::Slice) = 1
Base.lastindex(slice::Slice) = slice.len
Base.unsafe_convert(::Type{Ptr{T}}, slice::Slice{T}) where {T} = slice.ptr
Base.iscontiguous(::Slice) = true
Base.iscontiguous(::Type{<:Slice}) = true
Base.pointer(slice::Slice{T}) where {T} = slice.ptr
Base.strides(::Slice) = (1,)
Base.similar(slice::Slice{T}) where {T} = Vector{T}(undef, slice.len)

@inline function Base.getindex(slice::Slice{T}, i::Int) where {T}
    @boundscheck (i >= 1 && i <= slice.len) || throw(BoundsError(slice, i))
    return unsafe_load(slice.ptr, i)
end

@inline function _require_inactive(handle_ref::Base.RefValue, what::AbstractString)
    handle_ref[] == _IOX2_NULL || throw(ArgumentError("$what is still active; call close first"))
    return nothing
end

@inline function _require_inactive(obj, what::AbstractString)
    return _require_inactive(obj.handle_ref, what)
end

@inline _slice_mutable(::Type{O}) where {O} = O === Nothing

@inline function Base.setindex!(slice::Slice{T,O}, value::T, i::Int) where {T,O}
    _slice_mutable(O) || throw(ArgumentError("slice is read-only"))
    @boundscheck (i >= 1 && i <= slice.len) || throw(BoundsError(slice, i))
    unsafe_store!(slice.ptr, value, i)
    return value
end

@inline function Base.iterate(slice::Slice{T}, state::Int = 1) where {T}
    state > slice.len && return nothing
    return unsafe_load(slice.ptr, state), state + 1
end

@inline function Base.fill!(slice::Slice{T}, value::T) where {T}
    @inbounds for idx in 1:slice.len
        unsafe_store!(slice.ptr, value, idx)
    end
    return slice
end

function Base.copyto!(dest::AbstractVector{T}, src::Slice{T}) where {T}
    length(dest) == src.len || throw(DimensionMismatch("destination has length $(length(dest)), expected $(src.len)"))
    @inbounds for i in 1:src.len
        dest[i] = unsafe_load(src.ptr, i)
    end
    return dest
end

function Base.copyto!(dest::Slice{T}, src::AbstractVector{T}) where {T}
    length(src) == dest.len || throw(DimensionMismatch("source has length $(length(src)), expected $(dest.len)"))
    @inbounds for i in 1:dest.len
        unsafe_store!(dest.ptr, src[i], i)
    end
    return dest
end

@inline function _default_value(::Type{T}) where {T}
    Base.hasmethod(zero, Tuple{Type{T}}) || throw(ArgumentError("loan!/loan_slice! requires zero(::Type{$T})"))
    return zero(T)
end

struct EventId
    raw::Iceoryx2FFI.iox2_event_id_t
end

EventId(value::Integer) = EventId(Iceoryx2FFI.iox2_event_id_t(Iceoryx2FFI.c_size_t(value)))

@inline value(id::EventId) = id.raw.value
@inline Base.Int(id::EventId) = Int(id.raw.value)
