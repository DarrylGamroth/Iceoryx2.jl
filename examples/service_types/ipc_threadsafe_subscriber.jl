include(joinpath(@__DIR__, "..", "common", "imports.jl"))
using Base.Threads: Atomic, atomic_load, atomic_store!, @spawn

const CYCLE_SECONDS = 1

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(); service_type = :ipc)

    builder = publish_subscribe(service_builder(node, "Service-Variants-Example"), UInt64)
    service = open_or_create(builder)
    subscriber = create(subscriber_builder(service))

    lock = ReentrantLock()
    keep_running = Atomic{Bool}(true)

    background = @spawn begin
        while atomic_load(keep_running)
            sleep(CYCLE_SECONDS)
            sample = receive(subscriber)
            if sample !== nothing
                lock do
                    println("[thread] received: ", payload(sample)[1])
                end
            end
        end
    end

    while true
        Iceoryx2.wait(node, CYCLE_SECONDS, 0)
        sample = receive(subscriber)
        if sample !== nothing
            lock do
                println("[main] received: ", payload(sample)[1])
            end
        end
    end

    atomic_store!(keep_running, false)
    wait(background)
end

main()
