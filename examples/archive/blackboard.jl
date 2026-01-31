#!/usr/bin/env julia

include(joinpath(@__DIR__, "..", "common", "imports.jl"))

function main()
    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, "iox2_julia_blackboard_node")

    Iceoryx2.create(node_builder, ServiceType.IPC) do node
        service_builder = Iceoryx2.service_builder(node, "iox2_julia_blackboard_service")
        bb_builder = Iceoryx2.blackboard_creator(service_builder, UInt64)
        Iceoryx2.add!(bb_builder, UInt64(1), UInt64(0))

        Iceoryx2.create(bb_builder) do factory
                Iceoryx2.create(Iceoryx2.writer_builder(factory)) do writer
                Iceoryx2.create(Iceoryx2.reader_builder(factory)) do reader
                    entry_mut = Iceoryx2.EntryHandleMut(writer, UInt64)
                    Iceoryx2.writer_entry!(writer, entry_mut, UInt64(1))
                    Iceoryx2.update!(entry_mut, UInt64(42))
                    close(entry_mut)

                    entry = Iceoryx2.EntryHandle(reader, UInt64)
                    Iceoryx2.reader_entry!(reader, entry, UInt64(1))
                    value, _generation = Iceoryx2.get(entry)
                    println("blackboard value: ", value)
                    close(entry)
                end
            end
        end
    end
end

main()
