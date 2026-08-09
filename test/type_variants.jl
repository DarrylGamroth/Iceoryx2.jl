using StaticArrays

@testset "TypeVariants" begin
    @test Iceoryx2._variant_type(UInt32) ==
          Iceoryx2.Iceoryx2FFI.iox2_type_variant_e_FIXED_SIZE
    @test Iceoryx2._variant_type(NTuple{4, UInt8}) ==
          Iceoryx2.Iceoryx2FFI.iox2_type_variant_e_FIXED_SIZE
    @test Iceoryx2._variant_type(Vector{UInt8}) ==
          Iceoryx2.Iceoryx2FFI.iox2_type_variant_e_DYNAMIC
    @test Iceoryx2._variant_type(AbstractVector{UInt8}) ==
          Iceoryx2.Iceoryx2FFI.iox2_type_variant_e_DYNAMIC
    @test Iceoryx2._variant_type(Iceoryx2.Slice{UInt8, Nothing}) ==
          Iceoryx2.Iceoryx2FFI.iox2_type_variant_e_DYNAMIC
    @test Iceoryx2._variant_type(StaticArrays.SVector{4, UInt8}) ==
          Iceoryx2.Iceoryx2FFI.iox2_type_variant_e_FIXED_SIZE
    @test Iceoryx2._payload_type(StaticArrays.SVector{4, UInt8}) ==
          StaticArrays.SVector{4, UInt8}
    @test Iceoryx2._fixed_header_variant(StaticArrays.SVector{4, UInt8}, "user header type") ==
          Iceoryx2.Iceoryx2FFI.iox2_type_variant_e_FIXED_SIZE
    @test_throws ArgumentError Iceoryx2._fixed_header_variant(Vector{UInt8}, "user header type")
    @test_throws ArgumentError Iceoryx2._fixed_header_variant(AbstractVector{UInt8}, "user header type")

    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, unique_node_name())
    node = Iceoryx2.create(node_builder, TEST_SERVICE_TYPE)
    factory = Iceoryx2.create(
        Iceoryx2.publish_subscribe(
        Iceoryx2.service_builder(node, unique_service_name()),
        StaticArrays.SVector{4, UInt8}
    ),
    )
    publisher = Iceoryx2.create(Iceoryx2.publisher_builder(factory))
    subscriber = Iceoryx2.create(Iceoryx2.subscriber_builder(factory))
    sample = Iceoryx2.Sample(subscriber)
    expected = StaticArrays.SVector{4, UInt8}(1, 2, 3, 4)
    received = false
    for _ in 1:50
        Iceoryx2.send_copy(publisher, expected)
        if Iceoryx2.receive!(subscriber, sample)
            received = true
            break
        end
        sleep(0.01)
    end
    @test received
    if received
        @test length(Iceoryx2.payload(sample)) == 1
        @test Iceoryx2.payload(sample)[1] == expected
    end

    close(sample)
    close(subscriber)
    close(publisher)
    close(factory)
    close(node)
end
