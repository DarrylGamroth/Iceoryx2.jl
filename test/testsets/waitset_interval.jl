@testset "WaitsetInterval" begin
    builder = Iceoryx2.WaitsetBuilder()
    waitset = Iceoryx2.create(builder)
    guard = Iceoryx2.attach_interval(waitset, 0, 10_000_000)

    called = Ref(false)
    result = Iceoryx2.wait_and_process_once(waitset, 0, 100_000_000) do attachment
        called[] = true
        close(attachment)
        return :stop
    end

    @test called[]
    @test result == Iceoryx2.Iceoryx2FFI.iox2_waitset_run_result_e_STOP_REQUEST ||
          result == Iceoryx2.Iceoryx2FFI.iox2_waitset_run_result_e_ALL_EVENTS_HANDLED

    close(guard)
    close(waitset)
end
