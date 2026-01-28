include(joinpath(@__DIR__, "..", "common", "imports.jl"))

include(joinpath(@__DIR__, "blackboard_complex_key.jl"))

const CYCLE_SECONDS = 1

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(); service_type = :ipc)

    builder = service_builder(node, "My/Funk/ServiceName")
    bb_builder = blackboard_opener(builder, BlackboardKey)
    factory = Iceoryx2.open(bb_builder)

    key_0 = BlackboardKey(Int32(0), Int32(-4), Int32(4))
    key_1 = BlackboardKey(Int32(1), Int32(-4), Int32(4))

    reader = create(reader_builder(factory))
    entry_0 = reader_entry(reader, key_0, Int32)
    entry_1 = reader_entry(reader, key_1, Float64)

    while true
        Iceoryx2.wait(node, CYCLE_SECONDS, 0)
        value_0, _ = Iceoryx2.get(entry_0)
        value_1, _ = Iceoryx2.get(entry_1)
        println("Read value $(value_0) for key 0...")
        println("Read value $(value_1) for key 1...\n")
    end
end

main()
