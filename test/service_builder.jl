@testset "ServiceBuilder" begin
    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, "iceoryx2_julia_test_node_service")
    node = Iceoryx2.create(builder, TEST_SERVICE_TYPE)

    svc_builder = Iceoryx2.service_builder(node, "iceoryx2_julia_test_service")
    @test isvalid(svc_builder)

    owned_name = Iceoryx2.ServiceName(unique_service_name())
    owned_name_builder = Iceoryx2.service_builder(node, owned_name)
    @test !isvalid(owned_name)
    @test isvalid(owned_name_builder)
    close(owned_name_builder)

    close(svc_builder)
    close(node)
end
