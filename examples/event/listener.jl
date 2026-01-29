include(joinpath(@__DIR__, "..", "common", "imports.jl"))

const CYCLE_SECONDS = 1

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(); service_type = :ipc)

    service = open_or_create(event(service_builder(node, "MyEventName")))
    listener = create(listener_builder(service))

    println("Listener ready to receive events!")

    try
        while true
            event_id = timed_wait_one(listener, CYCLE_SECONDS, 0)
            if event_id !== nothing
                println("event was triggered with id: ", Int(event_id))
            end
        end
    catch err
        err isa InterruptException || rethrow()
    finally
        close(listener)
        close(service)
        close(node)
    end
end

main()
