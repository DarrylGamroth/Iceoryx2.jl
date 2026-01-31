include(joinpath(@__DIR__, "..", "common", "imports.jl"))

include(joinpath(@__DIR__, "custom_subscriber.jl"))

const DEADLINE_SECONDS = 2

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(), ServiceType.IPC)

    subscriber = create_custom_subscriber(node, "My/Funk/ServiceName")

    waitset = create(WaitsetBuilder(ServiceType.IPC))
    subscriber_guard = attach_deadline(waitset, file_descriptor(subscriber.listener), DEADLINE_SECONDS, 0)

    on_event = function (attachment_id)
        if has_event_from(attachment_id, subscriber_guard)
            handle_event!(subscriber)
        elseif has_missed_deadline(attachment_id, subscriber_guard)
            println("Contract violation! The subscriber did not receive a message for $(DEADLINE_SECONDS)s")
        end
        return :continue
    end

    wait_and_process(waitset, on_event)
end

main()
