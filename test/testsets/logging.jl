@testset "Logging" begin
    entries = Vector{Tuple{Iceoryx2.Iceoryx2FFI.iox2_log_level_e, String, String}}()
    handler = (level, origin, message) -> push!(entries, (level, origin, message))
    @test Iceoryx2.set_logger(handler)

    Iceoryx2.set_log_level(:trace)
    Iceoryx2.log(:trace, "hello", "world")
    Iceoryx2.log(:debug, "goodbye", "hypnotoad")
    Iceoryx2.log(:info, "who", "is looking")
    Iceoryx2.log(:warn, "warn", "me")
    Iceoryx2.log(:error, "error", "me")
    Iceoryx2.log(:fatal, "fatal", "me")

    @test length(entries) == 6
    @test entries[1] == (Iceoryx2.Iceoryx2FFI.iox2_log_level_e_TRACE, "hello", "world")
    @test entries[2] == (Iceoryx2.Iceoryx2FFI.iox2_log_level_e_DEBUG, "goodbye", "hypnotoad")
    @test entries[3] == (Iceoryx2.Iceoryx2FFI.iox2_log_level_e_INFO, "who", "is looking")
    @test entries[4] == (Iceoryx2.Iceoryx2FFI.iox2_log_level_e_WARN, "warn", "me")
    @test entries[5] == (Iceoryx2.Iceoryx2FFI.iox2_log_level_e_ERROR, "error", "me")
    @test entries[6] == (Iceoryx2.Iceoryx2FFI.iox2_log_level_e_FATAL, "fatal", "me")

    levels = [
        (:trace, Iceoryx2.Iceoryx2FFI.iox2_log_level_e_TRACE),
        (:debug, Iceoryx2.Iceoryx2FFI.iox2_log_level_e_DEBUG),
        (:info, Iceoryx2.Iceoryx2FFI.iox2_log_level_e_INFO),
        (:warn, Iceoryx2.Iceoryx2FFI.iox2_log_level_e_WARN),
        (:error, Iceoryx2.Iceoryx2FFI.iox2_log_level_e_ERROR),
        (:fatal, Iceoryx2.Iceoryx2FFI.iox2_log_level_e_FATAL),
    ]

    for (level, enum) in levels
        Iceoryx2.set_log_level(level)
        @test Iceoryx2.log_level() == enum
        Iceoryx2.set_log_level_from_env_or(level)
        @test Iceoryx2.log_level() == enum
    end
end
