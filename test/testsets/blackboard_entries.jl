@testset "BlackboardEntries" begin
    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, unique_node_name())
    node = Iceoryx2.create(node_builder; service_type=:ipc)

    service_builder = Iceoryx2.service_builder(node, unique_service_name())
    bb_builder = Iceoryx2.blackboard_creator(service_builder)
    Iceoryx2.add_with_default!(bb_builder, UInt64(1), UInt64(0))

    factory = Iceoryx2.create(bb_builder)
    writer = Iceoryx2.create(Iceoryx2.writer_builder(factory))
    reader = Iceoryx2.create(Iceoryx2.reader_builder(factory))

    keys = UInt64[]
    Iceoryx2.list_keys(factory, UInt64) do key
        push!(keys, key)
        return :continue
    end
    @test UInt64(1) in keys

    Iceoryx2.writer_entry(writer, UInt64(1), UInt64) do entry_mut
        Iceoryx2.update!(entry_mut, UInt64(42))
    end

    value = Ref{UInt64}(0)
    generation = Ref{UInt64}(0)
    Iceoryx2.reader_entry(reader, UInt64(1), UInt64) do entry
        value[], generation[] = Iceoryx2.get(entry)
    end
    @test value[] == UInt64(42)
    @test generation[] isa UInt64

    entry_mut = Iceoryx2.writer_entry(writer, UInt64(1), UInt64)
    uninit = Iceoryx2.loan_uninit(entry_mut)
    ptr = Iceoryx2.value_mut(uninit)
    unsafe_store!(ptr, UInt64(77))
    entry_mut = Iceoryx2.update!(uninit)
    close(entry_mut)

    Iceoryx2.reader_entry(reader, UInt64(1), UInt64) do entry
        value[], generation[] = Iceoryx2.get(entry)
    end
    @test value[] == UInt64(77)

    close(reader)
    close(writer)
    close(factory)
    close(node)
end
