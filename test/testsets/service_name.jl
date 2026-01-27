@testset "ServiceName" begin
    name = "I am walking on sunshine - woo hoo."
    service_name = Iceoryx2.ServiceName(name)
    @test string(service_name) == name
    close(service_name)

    too_long = repeat("s", Iceoryx2.Iceoryx2FFI.IOX2_SERVICE_NAME_LENGTH + 1)
    @test_throws Iceoryx2.SemanticStringError Iceoryx2.ServiceName(too_long)
end
