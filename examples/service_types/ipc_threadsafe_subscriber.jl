include(joinpath(@__DIR__, "..", "common", "imports.jl"))
using Base.Threads: Atomic, atomic_load, atomic_store!, @spawn

const CYCLE_SECONDS = 1

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(), ServiceType.IPC)

    builder = publish_subscribe(service_builder(node, "Service-Variants-Example"), UInt64)
    service = open_or_create(builder)
    subscriber = create(subscriber_builder(service))

    io_lock = ReentrantLock()
    keep_running = Atomic{Bool}(true)

    background = @spawn begin
        sample = Sample(subscriber)
        try
            while atomic_load(keep_running)
                sleep(CYCLE_SECONDS)
                if receive!(subscriber, sample)
                    try
                        Base.lock(io_lock) do
                            println("[thread] received: ", payload(sample)[1])
                        end
                    finally
                        close(sample)
                    end
                end
            end
        finally
            close(sample)
        end
    end

    sample = Sample(subscriber)
    try
        while true
            sleep(CYCLE_SECONDS)
            if receive!(subscriber, sample)
                try
                    Base.lock(io_lock) do
                        println("[main] received: ", payload(sample)[1])
                    end
                finally
                    close(sample)
                end
            end
        end
    catch err
        err isa InterruptException || rethrow()
    finally
        atomic_store!(keep_running, false)
        wait(background)
        close(sample)
        close(subscriber)
        close(service)
        close(node)
    end
end

main()
