@testset "NodeName" begin
    name = "First time we met, I saw the ocean, it was wet!"
    node_name = Iceoryx2.NodeName(name)
    @test string(node_name) == name
    close(node_name)

    too_long = repeat("s", Iceoryx2.Iceoryx2FFI.IOX2_NODE_NAME_LENGTH + 1)
    @test_throws Iceoryx2.SemanticStringError Iceoryx2.NodeName(too_long)
end
