include(joinpath(@__DIR__, "..", "common", "imports.jl"))
using Base.Threads: Atomic, atomic_load, atomic_store!, @spawn

const CYCLE_SECONDS = 1

function main()
    set_log_level_from_env_or(:info)

    lock = ReentrantLock()
    keep_running = Atomic{Bool}(true)

    background = @spawn begin
        builder = NodeBuilder()
        name!(builder, "threadnode")
        node = create(builder; service_type = :local)

        builder_service = publish_subscribe(service_builder(node, "Service-Variants-Example"), UInt64)
        service = open_or_create(builder_service)
        subscriber = create(subscriber_builder(service))

        while atomic_load(keep_running)
            sleep(CYCLE_SECONDS)
            sample = receive(subscriber)
            while sample !== nothing
                lock do
                    println("[thread] received: ", payload(sample)[1])
                end
                sample = receive(subscriber)
            end
        end
    end

    builder = NodeBuilder()
    name!(builder, "mainnode")
    node = create(builder; service_type = :local)

    builder_service = publish_subscribe(service_builder(node, "Service-Variants-Example"), UInt64)
    service = open_or_create(builder_service)
    publisher = create(publisher_builder(service))

    counter = UInt64(0)
    while true
        Iceoryx2.wait(node, CYCLE_SECONDS, 0)
        lock do
            println("send: ", counter)
        end
        send_copy(publisher, counter)
        counter += 1
    end

    atomic_store!(keep_running, false)
    wait(background)
end

main()
