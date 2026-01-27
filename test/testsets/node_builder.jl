@testset "NodeBuilder" begin
    builder = Iceoryx2.NodeBuilder()
    @test isvalid(builder)

    Iceoryx2.name!(builder, "iceoryx2_julia_test_node")

    config_handle = Ref{Iceoryx2.Iceoryx2FFI.iox2_config_h}(C_NULL)
    ret = Iceoryx2.Iceoryx2FFI.iox2_config_default(C_NULL, config_handle)
    Iceoryx2.check_ok(ret, Iceoryx2.Iceoryx2FFI.iox2_config_creation_error_e)
    config = Iceoryx2.Config(config_handle[])

    Iceoryx2.config!(builder, config)

    node = Iceoryx2.create(builder; service_type=:ipc)
    @test !isvalid(builder)
    @test isvalid(node)

    close(node)
    close(config)
end
