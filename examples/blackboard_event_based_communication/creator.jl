include(joinpath(@__DIR__, "..", "common", "imports.jl"))

const CYCLE_SECONDS = 1
const INTERESTING_KEY = UInt32(1)

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(), ServiceType.IPC)

    builder = service_builder(node, "My/Funk/ServiceName")
    bb_builder = blackboard_creator(builder, UInt32)
    Iceoryx2.add_with_default!(bb_builder, UInt32(0), UInt64)
    Iceoryx2.add_with_default!(bb_builder, INTERESTING_KEY, UInt64)
    factory = create(bb_builder)

    println("Blackboard created.\n")

    event_service = open_or_create(event(service_builder(node, "My/Funk/ServiceName")))
    notifier = create(notifier_builder(event_service))

    writer = create(writer_builder(factory))
    entry_handle_mut = EntryHandleMut(writer, UInt64)
    interesting_entry_handle_mut = EntryHandleMut(writer, UInt64)
    entry!(writer, entry_handle_mut, UInt32(0))
    entry!(writer, interesting_entry_handle_mut, INTERESTING_KEY)

    entry_id = Iceoryx2.entry_id(entry_handle_mut)
    interesting_entry_id = Iceoryx2.entry_id(interesting_entry_handle_mut)

    counter = UInt64(0)
    try
        while true
            sleep(CYCLE_SECONDS)
            counter += 1

            update!(interesting_entry_handle_mut, counter)
            notify!(notifier, interesting_entry_id)
            println("Trigger event with entry id $(Int(interesting_entry_id))")

            update!(entry_handle_mut, 2 * counter)
            notify!(notifier, entry_id)
            println("Trigger event with entry id $(Int(entry_id))")
        end
    catch err
        err isa InterruptException || rethrow()
    finally
        close(interesting_entry_handle_mut)
        close(entry_handle_mut)
        close(writer)
        close(notifier)
        close(event_service)
        close(factory)
        close(node)
    end
end

main()
