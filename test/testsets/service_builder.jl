@testset "ServiceBuilder" begin
    builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(builder, "iceoryx2_julia_test_node_service")
    node = Iceoryx2.create(builder)

    svc_builder = Iceoryx2.service_builder(node, "iceoryx2_julia_test_service")
    @test isvalid(svc_builder)

    close(node)
end
