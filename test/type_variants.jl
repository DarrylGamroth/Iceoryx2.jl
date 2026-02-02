using StaticArrays

@testset "TypeVariants" begin
    @test Iceoryx2._variant_type(UInt32) == Iceoryx2.Iceoryx2FFI.iox2_type_variant_e_FIXED_SIZE
    @test Iceoryx2._variant_type(NTuple{4,UInt8}) == Iceoryx2.Iceoryx2FFI.iox2_type_variant_e_FIXED_SIZE
    @test Iceoryx2._variant_type(Vector{UInt8}) == Iceoryx2.Iceoryx2FFI.iox2_type_variant_e_DYNAMIC
    @test Iceoryx2._variant_type(Iceoryx2.Slice{UInt8,Nothing}) ==
        Iceoryx2.Iceoryx2FFI.iox2_type_variant_e_DYNAMIC
    @test Iceoryx2._variant_type(StaticArrays.SVector{4,UInt8}) ==
        Iceoryx2.Iceoryx2FFI.iox2_type_variant_e_FIXED_SIZE
end

