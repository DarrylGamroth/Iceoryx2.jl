# Logging helpers.

using Logging

@enum LogLevel::UInt32 begin
    LogLevelTrace = UInt32(Iceoryx2FFI.iox2_log_level_e_TRACE)
    LogLevelDebug = UInt32(Iceoryx2FFI.iox2_log_level_e_DEBUG)
    LogLevelInfo = UInt32(Iceoryx2FFI.iox2_log_level_e_INFO)
    LogLevelWarn = UInt32(Iceoryx2FFI.iox2_log_level_e_WARN)
    LogLevelError = UInt32(Iceoryx2FFI.iox2_log_level_e_ERROR)
    LogLevelFatal = UInt32(Iceoryx2FFI.iox2_log_level_e_FATAL)
end

@inline _log_level(value::LogLevel) = Iceoryx2FFI.iox2_log_level_e(UInt32(value))

@inline function _log_level(value::Symbol)
    if value === :trace
        return Iceoryx2FFI.iox2_log_level_e_TRACE
    elseif value === :debug
        return Iceoryx2FFI.iox2_log_level_e_DEBUG
    elseif value === :info
        return Iceoryx2FFI.iox2_log_level_e_INFO
    elseif value === :warn || value === :warning
        return Iceoryx2FFI.iox2_log_level_e_WARN
    elseif value === :error
        return Iceoryx2FFI.iox2_log_level_e_ERROR
    elseif value === :fatal
        return Iceoryx2FFI.iox2_log_level_e_FATAL
    end
    throw(ArgumentError("unsupported log level: $value"))
end

@inline _log_level(value) = throw(ArgumentError("unsupported log level: $value"))

@inline function _log_level_enum(value::Iceoryx2FFI.iox2_log_level_e)
    if value == Iceoryx2FFI.iox2_log_level_e_TRACE
        return LogLevelTrace
    elseif value == Iceoryx2FFI.iox2_log_level_e_DEBUG
        return LogLevelDebug
    elseif value == Iceoryx2FFI.iox2_log_level_e_INFO
        return LogLevelInfo
    elseif value == Iceoryx2FFI.iox2_log_level_e_WARN
        return LogLevelWarn
    elseif value == Iceoryx2FFI.iox2_log_level_e_ERROR
        return LogLevelError
    elseif value == Iceoryx2FFI.iox2_log_level_e_FATAL
        return LogLevelFatal
    end
    throw(ArgumentError("unsupported log level: $value"))
end

"""
    log_level() -> LogLevel

Return the current iceoryx2 log level.
"""
@inline function log_level()
    return _log_level_enum(Iceoryx2FFI.iox2_get_log_level())
end

"""
    set_log_level(level)

Set the global iceoryx2 log level. Accepts a symbol (`:info`, `:warn`, ...)
or a `LogLevel` value.
"""
function set_log_level(level::Union{Symbol, LogLevel})
    Iceoryx2FFI.iox2_set_log_level(_log_level(level))
    return nothing
end

"""
    set_log_level_from_env()

Set the log level from environment variables (iceoryx2 default behavior).
"""
function set_log_level_from_env()
    Iceoryx2FFI.iox2_set_log_level_from_env_or_default()
    return nothing
end

"""
    set_log_level_from_env_or(level)

Set the log level from the environment, or fall back to `level` if not set.
"""
function set_log_level_from_env_or(level::Union{Symbol, LogLevel})
    Iceoryx2FFI.iox2_set_log_level_from_env_or(_log_level(level))
    return nothing
end

"""
    log(level, origin, message)

Emit an iceoryx2 log message with the given level and origin string.
"""
function log(level::Union{Symbol, LogLevel}, origin::AbstractString, message::AbstractString)
    origin_str = String(origin)
    message_str = String(message)
    GC.@preserve origin_str message_str begin
        Iceoryx2FFI.iox2_log(_log_level(level), Base.unsafe_convert(Cstring, origin_str),
            Base.unsafe_convert(Cstring, message_str))
    end
    return nothing
end

"""
    AbstractLogHandler

Abstract callback target for the iceoryx2 logger.
"""
abstract type AbstractLogHandler end

"""
    LogHandler(f)

Wrap a callable `f(level, origin, message)` as a log handler.
"""
mutable struct LogHandler{T} <: AbstractLogHandler
    on_log::T
end

function log_callback(handler::LogHandler, level, origin, message)
    handler.on_log(level, origin, message)
end

"""
    JuliaLoggerHandler(logger)

Forward iceoryx2 logs into a Julia `AbstractLogger`.
"""
mutable struct JuliaLoggerHandler{L} <: AbstractLogHandler
    logger::L
end

function log_callback(handler::JuliaLoggerHandler, level, origin, message)
    _log_to_julia(handler.logger, level, origin, message)
    return nothing
end

const _LOG_HANDLER = Ref{Any}(nothing)
const _LOG_EXCEPTION = Ref{_CallbackException}(nothing)

@inline last_callback_exception(::AbstractLogHandler) = _LOG_EXCEPTION[]
@inline last_log_exception() = _LOG_EXCEPTION[]

function _log_wrapper(level::Iceoryx2FFI.iox2_log_level_e, origin::Cstring, message::Cstring)
    handler = _LOG_HANDLER[]
    handler === nothing && return nothing
    try
        log_callback(handler, _log_level_enum(level), unsafe_string(origin), unsafe_string(message))
    catch err
        _LOG_EXCEPTION[] = CapturedException(err, catch_backtrace())
    end
    return nothing
end

const _LOG_CB = @cfunction(_log_wrapper, Cvoid,
    (Iceoryx2FFI.iox2_log_level_e, Cstring, Cstring))

"""
    set_logger(handler::AbstractLogHandler) -> Bool

Install a log handler callback. Returns `true` on success.
"""
function set_logger(handler::AbstractLogHandler)
    previous = _LOG_HANDLER[]
    _LOG_HANDLER[] = handler
    _LOG_EXCEPTION[] = nothing
    if !Iceoryx2FFI.iox2_set_logger(_LOG_CB)
        _LOG_HANDLER[] = previous
        return false
    end
    return true
end

"""
    set_logger(f::Function) -> Bool

Convenience overload that wraps `f` in a `LogHandler`.
"""
function set_logger(f::Function)
    return set_logger(LogHandler(f))
end

function _log_to_julia(logger, level::LogLevel, origin::AbstractString, message::AbstractString)
    io_level = if level == LogLevelTrace || level == LogLevelDebug
        Logging.Debug
    elseif level == LogLevelInfo
        Logging.Info
    elseif level == LogLevelWarn
        Logging.Warn
    elseif level == LogLevelError || level == LogLevelFatal
        Logging.Error
    else
        Logging.Info
    end
    Logging.handle_message(logger, io_level, message, nothing, nothing, nothing; origin)
    return nothing
end

"""
    set_logger_to_julia(logger = current_logger()) -> Bool

Route iceoryx2 logs into the provided Julia logger.
"""
function set_logger_to_julia(logger::Logging.AbstractLogger = Logging.current_logger())
    return set_logger(JuliaLoggerHandler(logger))
end
