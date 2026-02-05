include(joinpath(@__DIR__, "..", "common", "imports.jl"))

include(joinpath(@__DIR__, "blackboard_complex_key.jl"))

const CYCLE_SECONDS = 1
const INITIAL_VALUE::Float64 = 1.1

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(), ServiceType.IPC)

    key_0 = BlackboardKey(Int32(0), Int32(-4), Int32(4))
    key_1 = BlackboardKey(Int32(1), Int32(-4), Int32(4))

    builder = service_builder(node, "My/Funk/ServiceName")
    bb_builder = blackboard_creator(builder, BlackboardKey)
    add!(bb_builder, key_0, Int32(3))
    add!(bb_builder, key_1, INITIAL_VALUE)
    factory = create(bb_builder)

    println("Blackboard created.")

    writer = create(writer_builder(factory))
    entry_handle_mut_0 = EntryHandleMut(writer, Int32)
    entry_handle_mut_1 = EntryHandleMut(writer, Float64)
    entry!(writer, entry_handle_mut_0, key_0)
    entry!(writer, entry_handle_mut_1, key_1)
    entry_value_uninit = EntryValueUninit(entry_handle_mut_1)

    counter = 0
    try
        while true
            sleep(CYCLE_SECONDS)
            counter += 1

            update!(entry_handle_mut_0, Int32(counter))
            println("Write new value for key 0: $(counter)...")

            loan_uninit!(entry_handle_mut_1, entry_value_uninit)
            value!(entry_value_uninit, INITIAL_VALUE * counter)
            update!(entry_value_uninit, entry_handle_mut_1)
            println("Write new value for key 1: $(INITIAL_VALUE * counter)...\n")
        end
    catch err
        err isa InterruptException || rethrow()
    finally
        close(entry_value_uninit)
        close(entry_handle_mut_1)
        close(entry_handle_mut_0)
        close(writer)
        close(factory)
        close(node)
    end
end

main()
