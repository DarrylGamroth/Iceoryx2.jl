include(joinpath(@__DIR__, "..", "common", "static_types.jl"))

# Note: address book capacity is reduced compared to the C++ example.
const ADDRESS_BOOK_CAPACITY = 16

struct FullName
    first_name::StaticString{256}
    last_name::StaticString{256}
end

struct ComplexType
    address_book::StaticVector{FullName, ADDRESS_BOOK_CAPACITY}
    some_matrix::StaticVector{StaticVector{Float64, 8}, 8}
    some_value::UInt16
    another_value::UInt32
end

Base.zero(::Type{FullName}) = FullName(static_string(Val(256), ""), static_string(Val(256), ""))
Base.zero(::Type{ComplexType}) = ComplexType(
    static_vector_from_value(FullName, Val(ADDRESS_BOOK_CAPACITY), 0, zero(FullName)),
    static_vector_from_value(StaticVector{Float64, 8}, Val(8), 0, static_vector_from_value(Float64, Val(8), 0, 0.0)),
    UInt16(0),
    UInt32(0),
)

Iceoryx2.type_name(::Type{ComplexType}) = "ComplexType"
