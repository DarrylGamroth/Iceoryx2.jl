include(joinpath(@__DIR__, "..", "common", "imports.jl"))

include(joinpath(@__DIR__, "..", "common", "cli.jl"))

function main()
    set_log_level_from_env_or(:info)

    show_help_if_requested(ARGS,
        [
            "Waiter of the event multiplexing example.",
            "",
            "Use '-s' or '--service1' to specify the name of the service 1.",
            "Use '-t' or '--service2' to specify the name of the service 2."
        ])

    service_name_1 = parse_arg(ARGS, "-s", "--service1", "fuu")
    service_name_2 = parse_arg(ARGS, "-t", "--service2", "bar")

    node = create(NodeBuilder(), ServiceType.IPC)

    service_1 = open_or_create(event(service_builder(node, service_name_1)))
    service_2 = open_or_create(event(service_builder(node, service_name_2)))
    listener_1 = create(listener_builder(service_1))
    listener_2 = create(listener_builder(service_2))

    waitset = create(WaitSetBuilder(ServiceType.IPC))
    guard_1 = attach_notification(waitset, file_descriptor(listener_1))
    guard_2 = attach_notification(waitset, file_descriptor(listener_2))

    listeners = [
        (guard_1, service_name_1, listener_1),
        (guard_2, service_name_2, listener_2)
    ]

    on_event = function (attachment_id)
        for (guard, name, listener) in listeners
            if has_event_from(attachment_id, guard)
                println("Received trigger from \"$(name)\"")
                try_wait(listener) do event_id, count
                    print(" ", Int(event_id), "×", count)
                end
                println()
                break
            end
        end
        return :continue
    end

    println("Waiting on the following services: $(service_name_1), $(service_name_2)")
    wait_and_process(waitset, on_event)
end

main()
