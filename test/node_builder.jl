@testset "NodeBuilder" begin
    builder = Iceoryx2.NodeBuilder()
    @test isvalid(builder)

    Iceoryx2.name!(builder, "iceoryx2_julia_test_node")

    config = Iceoryx2.default_config()

    Iceoryx2.config!(builder, config)

    node = Iceoryx2.create(builder, TEST_SERVICE_TYPE)
    @test !isvalid(builder)
    @test isvalid(node)

    close(node)
    close(config)
end
