@testset "SliceSafety" begin
    source = UInt64[1, 2]
    destination = UInt64[0, 0]

    GC.@preserve source destination begin
        read_only = Iceoryx2.Slice{UInt64}(pointer(source), length(source), source)
        mutable_slice = Iceoryx2.Slice{UInt64}(pointer(destination), length(destination))

        @test_throws ArgumentError fill!(read_only, UInt64(3))
        @test_throws ArgumentError copyto!(read_only, source)
        @test_throws ArgumentError copyto!(read_only, mutable_slice)

        copyto!(mutable_slice, read_only)
        @test destination == source
        copyto!(mutable_slice, mutable_slice)
        @test destination == source
        fill!(mutable_slice, UInt64(4))
        @test destination == fill(UInt64(4), 2)

        permuted = PermutedDimsArray(source, (1,))
        copyto!(mutable_slice, permuted)
        copyto!(permuted, mutable_slice)
        @test collect(permuted) == destination
    end
end
