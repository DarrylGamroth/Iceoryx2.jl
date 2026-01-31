include(joinpath(@__DIR__, "..", "common", "imports.jl"))

include(joinpath(@__DIR__, "..", "common", "cli.jl"))

const CYCLE_SECONDS = 1

function main()
    set_log_level_from_env_or(:info)

    show_help_if_requested(ARGS, [
        "Notifier of the event multiplexing example.",
        "",
        "Use '-e' or '--event-id' to specify event ID that shall be used to trigger the service.",
        "Use '-s' or '--service' to specify the name of the service.",
    ])

    service_name = parse_arg(ARGS, "-s", "--service", "fuu")
    event_id_str = parse_arg(ARGS, "-e", "--event-id", "0")
    event_id_val = try
        parse(UInt64, event_id_str)
    catch
        error("Could not parse event ID: $(event_id_str)")
    end

    node = create(NodeBuilder(), ServiceType.IPC)
    service = open_or_create(event(service_builder(node, service_name)))
    notifier = create(notifier_builder(service))

    try
        while true
            sleep(CYCLE_SECONDS)
            notify!(notifier, EventId(event_id_val))
            println("[service: \"$(service_name)\"] Trigger event with id $(event_id_val)...")
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
