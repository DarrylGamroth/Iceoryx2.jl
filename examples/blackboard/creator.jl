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
    entry_0 = writer_entry(writer, key_0, Int32)
    entry_1 = writer_entry(writer, key_1, Float64)

    counter = 0
    while true
        Iceoryx2.wait(node, CYCLE_SECONDS, 0)
        counter += 1

        update!(entry_0, Int32(counter))
        println("Write new value for key 0: $(counter)...")

        value_uninit = loan_uninit(entry_1)
        unsafe_store!(value_mut(value_uninit), initial_value * counter)
        entry_1 = update!(value_uninit)
        println("Write new value for key 1: $(initial_value * counter)...\n")
    end
end

main()
