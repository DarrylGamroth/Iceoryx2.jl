include(joinpath(@__DIR__, "..", "common", "imports.jl"))

const CYCLE_SECONDS = 1
const INTERESTING_KEY = UInt32(1)

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(ServiceType.IPC))

    service = Iceoryx2.open(blackboard_opener(service_builder(node, "My/Funk/ServiceName"), UInt32))
    event_service = open_or_create(event(service_builder(node, "My/Funk/ServiceName")))
    listener = create(Iceoryx2.listener_builder(event_service))

    reader = create(reader_builder(service))
    entry_handle = EntryHandle(reader, UInt64)
    reader_entry!(reader, entry_handle, INTERESTING_KEY)

    try
        while true
            event_id = timed_wait_one(listener, CYCLE_SECONDS, 0)
            if event_id !== nothing && event_id == Iceoryx2.entry_id(entry_handle)
                value, _generation = Iceoryx2.get(entry_handle)
                println("read: $(value) for entry id $(Int(event_id))")
            end
        end
    catch err
        err isa InterruptException || rethrow()
    finally
        close(entry_handle)
        close(reader)
        close(listener)
        close(event_service)
        close(service)
        close(node)
    end
end

main()
