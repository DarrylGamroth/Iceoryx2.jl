include(joinpath(@__DIR__, "..", "common", "imports.jl"))

const CYCLE_SECONDS = 1

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(ServiceType.IPC))

    service = open_or_create(event(service_builder(node, "MyEventName")))
    max_event_id = event_id_max_value(static_config(service))
    max_event_id = max_event_id > 0 ? max_event_id : 1

    notifier = create(notifier_builder(service))

    counter = UInt64(0)
    try
        while true
            sleep(CYCLE_SECONDS)
            counter += 1
            event_id = EventId(counter % UInt64(max_event_id))
            notify!(notifier, event_id)
            println("Trigger event with id $(Int(event_id))...")
        end
    catch err
        err isa InterruptException || rethrow()
    finally
        close(notifier)
        close(service)
        close(node)
    end
end

main()
