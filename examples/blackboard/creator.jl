include(joinpath(@__DIR__, "..", "common", "imports.jl"))

include(joinpath(@__DIR__, "blackboard_complex_key.jl"))

const CYCLE_SECONDS = 1

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(); service_type = :ipc)

    key_0 = BlackboardKey(Int32(0), Int32(-4), Int32(4))
    key_1 = BlackboardKey(Int32(1), Int32(-4), Int32(4))
    initial_value = 1.1

    builder = service_builder(node, "My/Funk/ServiceName")
    bb_builder = blackboard_creator(builder, BlackboardKey)
    key_eq_comparison!(bb_builder)
    add!(bb_builder, key_0, Int32(3))
    add!(bb_builder, key_1, initial_value)
    factory = create(bb_builder)

    println("Blackboard created.")

    writer = create(writer_builder(factory))
    entry_0 = EntryHandleMut(writer, Int32)
    entry_1 = EntryHandleMut(writer, Float64)
    writer_entry!(writer, entry_0, key_0)
    writer_entry!(writer, entry_1, key_1)
    value_uninit = EntryValueUninit(entry_1)

    counter = 0
    while true
        Iceoryx2.wait(node, CYCLE_SECONDS, 0)
        counter += 1

        update!(entry_0, Int32(counter))
        println("Write new value for key 0: $(counter)...")

        loan_uninit!(entry_1, value_uninit)
        unsafe_store!(value_mut(value_uninit), initial_value * counter)
        update!(value_uninit, entry_1)
        println("Write new value for key 1: $(initial_value * counter)...\n")
    end
end

main()
