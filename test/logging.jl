@testset "Logging" begin
    Iceoryx2.set_log_level(:trace)
    Iceoryx2.log(:trace, "hello", "world")
    Iceoryx2.log(:debug, "goodbye", "hypnotoad")
    Iceoryx2.log(:info, "who", "is looking")
    Iceoryx2.log(:warn, "warn", "me")
    Iceoryx2.log(:error, "error", "me")
    Iceoryx2.log(:fatal, "fatal", "me")

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
