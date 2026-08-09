struct TestBlackboardKey
    first::Int32
    second::Int32
    third::Int32
end

Iceoryx2.type_name(::Type{TestBlackboardKey}) = "TestBlackboardKey"

@testset "BlackboardEntries" begin
    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, unique_node_name())
    node = Iceoryx2.create(node_builder, TEST_SERVICE_TYPE)

    try
        service_builder = Iceoryx2.service_builder(node, unique_service_name())
        bb_builder = Iceoryx2.blackboard_creator(service_builder, UInt64)
        Iceoryx2.add!(bb_builder, UInt64(1), UInt64(0))

        factory = Iceoryx2.create(bb_builder)
        try
            writer = Iceoryx2.create(Iceoryx2.writer_builder(factory))
            reader = Iceoryx2.create(Iceoryx2.reader_builder(factory))
            try
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

                missing_reader_entry = Iceoryx2.EntryHandle(reader, UInt64)
                @test !Iceoryx2.try_entry!(reader, missing_reader_entry, UInt64(9))
                @test !isvalid(missing_reader_entry)
                @test_throws Iceoryx2.EntryHandleError Iceoryx2.entry!(
                    reader,
                    missing_reader_entry,
                    UInt64(9),
                )

                wrong_reader_entry = Iceoryx2.EntryHandle(reader, Int64)
                @test !Iceoryx2.try_entry!(reader, wrong_reader_entry, UInt64(1))
                @test !isvalid(wrong_reader_entry)
                @test_throws Iceoryx2.EntryHandleError Iceoryx2.entry!(
                    reader,
                    wrong_reader_entry,
                    UInt64(1),
                )

                missing_writer_entry = Iceoryx2.EntryHandleMut(writer, UInt64)
                @test !Iceoryx2.try_entry!(writer, missing_writer_entry, UInt64(9))
                @test !isvalid(missing_writer_entry)
                @test_throws Iceoryx2.EntryHandleMutError Iceoryx2.entry!(
                    writer,
                    missing_writer_entry,
                    UInt64(9),
                )

                wrong_writer_entry = Iceoryx2.EntryHandleMut(writer, Int64)
                @test !Iceoryx2.try_entry!(writer, wrong_writer_entry, UInt64(1))
                @test !isvalid(wrong_writer_entry)
                @test_throws Iceoryx2.EntryHandleMutError Iceoryx2.entry!(
                    writer,
                    wrong_writer_entry,
                    UInt64(1),
                )

                entry_mut = Iceoryx2.EntryHandleMut(writer, UInt64)
                duplicate_entry_mut = Iceoryx2.EntryHandleMut(writer, UInt64)
                Iceoryx2.entry!(writer, entry_mut, UInt64(1))
                @test_throws Iceoryx2.EntryHandleMutError Iceoryx2.entry!(
                    writer,
                    duplicate_entry_mut,
                    UInt64(1),
                )
                @test !isvalid(duplicate_entry_mut)
                close(entry_mut)
                @test Iceoryx2.try_entry!(writer, duplicate_entry_mut, UInt64(1))
                close(duplicate_entry_mut)

                entry_mut = Iceoryx2.EntryHandleMut(writer, UInt64)
                Iceoryx2.entry!(writer, entry_mut, UInt64(1))
                Iceoryx2.update!(entry_mut, UInt64(42))
                close(entry_mut)

                value = Ref{UInt64}(0)
                generation = Ref{UInt64}(0)
                entry = Iceoryx2.EntryHandle(reader, UInt64)
                Iceoryx2.entry!(reader, entry, UInt64(1))
                Iceoryx2.get!(entry, value, generation)
                @test value[] == UInt64(42)
                @test Iceoryx2.is_up_to_date(entry, generation[])

                entry_mut = Iceoryx2.EntryHandleMut(writer, UInt64)
                Iceoryx2.entry!(writer, entry_mut, UInt64(1))
                Iceoryx2.update!(entry_mut, UInt64(77))
                close(entry_mut)
                @test !Iceoryx2.is_up_to_date(entry, generation[])
                Iceoryx2.get!(entry, value, generation)
                @test value[] == UInt64(77)
                @test Iceoryx2.is_up_to_date(entry, generation[])

                entry_mut = Iceoryx2.EntryHandleMut(writer, UInt64)
                Iceoryx2.entry!(writer, entry_mut, UInt64(1))
                uninit = Iceoryx2.EntryValueUninit(entry_mut)
                Iceoryx2.loan_uninit!(entry_mut, uninit)
                Iceoryx2.value!(uninit, UInt64(99))
                Iceoryx2.discard!(uninit, entry_mut)
                @test isvalid(entry_mut)
                @test !isvalid(uninit)
                close(entry_mut)
                Iceoryx2.get!(entry, value, generation)
                @test value[] == UInt64(77)

                entry_mut = Iceoryx2.EntryHandleMut(writer, UInt64)
                Iceoryx2.entry!(writer, entry_mut, UInt64(1))
                Iceoryx2.loan_uninit!(entry_mut, uninit)
                Iceoryx2.value!(uninit, UInt64(101))
                Iceoryx2.update!(uninit, entry_mut)
                @test isvalid(entry_mut)
                @test !isvalid(uninit)
                close(entry_mut)

                Iceoryx2.get!(entry, value, generation)
                @test value[] == UInt64(101)
                close(entry)
            finally
                close(reader)
                close(writer)
            end
        finally
            close(factory)
        end

        key_0 = TestBlackboardKey(Int32(0), Int32(-4), Int32(4))
        key_1 = TestBlackboardKey(Int32(1), Int32(-4), Int32(4))
        keyed_builder = Iceoryx2.blackboard_creator(
            Iceoryx2.service_builder(node, unique_service_name()),
            TestBlackboardKey,
        )
        Iceoryx2.add!(keyed_builder, key_0, Int32(3))
        Iceoryx2.add!(keyed_builder, key_1, Float64(1.5))
        keyed_factory = Iceoryx2.create(keyed_builder)
        try
            keyed_writer = Iceoryx2.create(Iceoryx2.writer_builder(keyed_factory))
            keyed_reader = Iceoryx2.create(Iceoryx2.reader_builder(keyed_factory))
            try
                custom_keys = TestBlackboardKey[]
                Iceoryx2.list_keys(keyed_factory, TestBlackboardKey) do key
                    push!(custom_keys, key)
                    return :continue
                end
                @test key_0 in custom_keys
                @test key_1 in custom_keys

                int_entry_mut = Iceoryx2.EntryHandleMut(keyed_writer, Int32)
                float_entry_mut = Iceoryx2.EntryHandleMut(keyed_writer, Float64)
                Iceoryx2.entry!(keyed_writer, int_entry_mut, key_0)
                Iceoryx2.entry!(keyed_writer, float_entry_mut, key_1)
                Iceoryx2.update!(int_entry_mut, Int32(7))
                Iceoryx2.update!(float_entry_mut, Float64(2.5))
                close(float_entry_mut)
                close(int_entry_mut)

                int_entry = Iceoryx2.EntryHandle(keyed_reader, Int32)
                float_entry = Iceoryx2.EntryHandle(keyed_reader, Float64)
                Iceoryx2.entry!(keyed_reader, int_entry, key_0)
                Iceoryx2.entry!(keyed_reader, float_entry, key_1)
                int_value, int_generation = Iceoryx2.get(int_entry)
                float_value, float_generation = Iceoryx2.get(float_entry)
                @test int_value == Int32(7)
                @test float_value == Float64(2.5)
                @test Iceoryx2.is_up_to_date(int_entry, int_generation)
                @test Iceoryx2.is_up_to_date(float_entry, float_generation)
                close(float_entry)
                close(int_entry)
            finally
                close(keyed_reader)
                close(keyed_writer)
            end
        finally
            close(keyed_factory)
        end
    finally
        close(node)
    end
end
