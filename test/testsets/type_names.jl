@testset "TypeNames" begin
    @test Iceoryx2.type_name(UInt8) == "u8"
    @test Iceoryx2.type_name(UInt16) == "u16"
    @test Iceoryx2.type_name(UInt32) == "u32"
    @test Iceoryx2.type_name(UInt64) == "u64"
    @test Iceoryx2.type_name(Int8) == "i8"
    @test Iceoryx2.type_name(Int16) == "i16"
    @test Iceoryx2.type_name(Int32) == "i32"
    @test Iceoryx2.type_name(Int64) == "i64"
    @test Iceoryx2.type_name(Float32) == "f32"
    @test Iceoryx2.type_name(Float64) == "f64"
    @test Iceoryx2.type_name(Nothing) == "()"

    struct TypeNameTestPayload
        value::UInt32
    end

    Iceoryx2.type_name(::Type{TypeNameTestPayload}) = "TypeNameTestPayload"
    @test Iceoryx2.type_name(TypeNameTestPayload) == "TypeNameTestPayload"

    name, name_len, size, alignment = Iceoryx2._type_details(TypeNameTestPayload)
    @test name == "TypeNameTestPayload"
    @test name_len == Iceoryx2.Iceoryx2FFI.c_size_t(length(codeunits("TypeNameTestPayload")))
    @test size == Iceoryx2.Iceoryx2FFI.c_size_t(sizeof(TypeNameTestPayload))
    @test alignment == Iceoryx2.Iceoryx2FFI.c_size_t(Base.datatype_alignment(TypeNameTestPayload))
end
