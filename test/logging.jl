@testset "Logging" begin
    Iceoryx2.set_log_level(:trace)
    Iceoryx2.log(:trace, "hello", "world")
    Iceoryx2.log(:debug, "goodbye", "hypnotoad")
    Iceoryx2.log(:info, "who", "is looking")
    Iceoryx2.log(:warn, "warn", "me")
    Iceoryx2.log(:error, "error", "me")
    Iceoryx2.log(:fatal, "fatal", "me")
    Iceoryx2.log(Iceoryx2.LogLevelInfo, "enum", "message")
    @test_throws MethodError Iceoryx2.log(
        Iceoryx2.Iceoryx2FFI.iox2_log_level_e_INFO,
        "raw",
        "enum",
    )

    levels = [
        (:trace, Iceoryx2.LogLevelTrace),
        (:debug, Iceoryx2.LogLevelDebug),
        (:info, Iceoryx2.LogLevelInfo),
        (:warn, Iceoryx2.LogLevelWarn),
        (:error, Iceoryx2.LogLevelError),
        (:fatal, Iceoryx2.LogLevelFatal),
    ]

    for (level, enum) in levels
        Iceoryx2.set_log_level(level)
        @test Iceoryx2.log_level() == enum
        Iceoryx2.set_log_level_from_env_or(level)
        @test Iceoryx2.log_level() == enum
        Iceoryx2.set_log_level(enum)
        @test Iceoryx2.log_level() == enum
    end

    @test_throws MethodError Iceoryx2.set_log_level(
        Iceoryx2.Iceoryx2FFI.iox2_log_level_e_INFO,
    )
end
