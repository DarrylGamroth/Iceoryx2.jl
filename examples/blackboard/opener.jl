include(joinpath(@__DIR__, "..", "common", "imports.jl"))

include(joinpath(@__DIR__, "blackboard_complex_key.jl"))

const CYCLE_SECONDS = 1

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(), ServiceType.IPC)

    builder = service_builder(node, "My/Funk/ServiceName")
    bb_builder = blackboard_opener(builder, BlackboardKey)
    factory = Iceoryx2.open(bb_builder)

    key_0 = BlackboardKey(Int32(0), Int32(-4), Int32(4))
    key_1 = BlackboardKey(Int32(1), Int32(-4), Int32(4))

    reader = create(reader_builder(factory))
    entry_0 = EntryHandle(reader, Int32)
    entry_1 = EntryHandle(reader, Float64)
    entry!(reader, entry_0, key_0)
    entry!(reader, entry_1, key_1)

    try
        while true
            sleep(CYCLE_SECONDS)
            value_0, _ = Iceoryx2.get(entry_0)
            value_1, _ = Iceoryx2.get(entry_1)
            println("Read value $(value_0) for key 0...")
            println("Read value $(value_1) for key 1...\n")
        end
    catch err
        err isa InterruptException || rethrow()
    finally
        close(entry_1)
        close(entry_0)
        close(reader)
        close(factory)
        close(node)
    end
end

main()
