@testset "BlackboardEntries" begin
    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, unique_node_name())
    node = Iceoryx2.create(node_builder, Iceoryx2.ServiceType.IPC)

    service_builder = Iceoryx2.service_builder(node, unique_service_name())
    bb_builder = Iceoryx2.blackboard_creator(service_builder, UInt64)
    Iceoryx2.add!(bb_builder, UInt64(1), UInt64(0))

    factory = Iceoryx2.create(bb_builder)
    writer = Iceoryx2.create(Iceoryx2.writer_builder(factory))
    reader = Iceoryx2.create(Iceoryx2.reader_builder(factory))

    writer_seen = Ref(false)
    Iceoryx2.list_writers(factory) do writer_details
        writer_seen[] = true
        wid = Iceoryx2.writer_id(writer_details)
        @test isvalid(wid)
        close(wid)
        @test isvalid(Iceoryx2.node_id(writer_details))
        return true
    end
    @test writer_seen[]

    reader_seen = Ref(false)
    Iceoryx2.list_readers(factory) do reader_details
        reader_seen[] = true
        rid = Iceoryx2.reader_id(reader_details)
        @test isvalid(rid)
        close(rid)
        @test isvalid(Iceoryx2.node_id(reader_details))
        return true
    end
    @test reader_seen[]

    keys = UInt64[]
    Iceoryx2.list_keys(factory, UInt64) do key
        push!(keys, key)
        return :continue
    end
    @test UInt64(1) in keys

    entry_mut = Iceoryx2.EntryHandleMut(writer, UInt64)
    Iceoryx2.entry!(writer, entry_mut, UInt64(1))
    Iceoryx2.update!(entry_mut, UInt64(42))
    close(entry_mut)

    value = Ref{UInt64}(0)
    generation = Ref{UInt64}(0)
    entry = Iceoryx2.EntryHandle(reader, UInt64)
    Iceoryx2.entry!(reader, entry, UInt64(1))
    value[], generation[] = Iceoryx2.get(entry)
    close(entry)
    @test value[] == UInt64(42)
    @test generation[] isa UInt64

    Iceoryx2.entry!(writer, entry_mut, UInt64(1))
    uninit = Iceoryx2.EntryValueUninit(entry_mut)
    Iceoryx2.loan_uninit!(entry_mut, uninit)
    Iceoryx2.value!(uninit, UInt64(77))
    Iceoryx2.update!(uninit, entry_mut)
    close(entry_mut)

    Iceoryx2.entry!(reader, entry, UInt64(1))
    value[], generation[] = Iceoryx2.get(entry)
    close(entry)
    @test value[] == UInt64(77)

    close(reader)
    close(writer)
    close(factory)
    close(node)
end
