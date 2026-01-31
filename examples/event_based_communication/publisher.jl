include(joinpath(@__DIR__, "..", "common", "imports.jl"))

include(joinpath(@__DIR__, "custom_publisher.jl"))

const CYCLE_SECONDS = 1

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(), ServiceType.IPC)

    publisher = create_custom_publisher(node, "My/Funk/ServiceName")

    waitset = create(WaitsetBuilder(ServiceType.IPC))
    publisher_guard = attach_notification(waitset, file_descriptor(publisher.listener))
    cyclic_guard = attach_interval(waitset, CYCLE_SECONDS, 0)

    counter = UInt64(0)

    on_event = function (attachment_id)
        if has_event_from(attachment_id, cyclic_guard)
            println("send message: ", counter)
            send_sample!(publisher, counter)
            counter += 1
        elseif has_event_from(attachment_id, publisher_guard)
            handle_event!(publisher)
        end
        return :continue
    end

    wait_and_process(waitset, on_event)
end

main()
