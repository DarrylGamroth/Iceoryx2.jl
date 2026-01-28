@testset "FileDescriptor" begin
    fd = Iceoryx2.FileDescriptor(1; owned=false)
    @test Iceoryx2.native_handle(fd) == 1
    close(fd)
end
