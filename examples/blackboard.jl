#!/usr/bin/env julia

using Iceoryx2

function main()
    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, "iox2_julia_blackboard_node")

    Iceoryx2.create(node_builder; service_type = :ipc) do node
        service_builder = Iceoryx2.service_builder(node, "iox2_julia_blackboard_service")
        bb_builder = Iceoryx2.blackboard_creator(service_builder)
        Iceoryx2.add_with_default!(bb_builder, UInt64(1), UInt64(0))

        Iceoryx2.create(bb_builder) do factory
            Iceoryx2.create(Iceoryx2.writer_builder(factory)) do _writer
                Iceoryx2.create(Iceoryx2.reader_builder(factory)) do _reader
                    println("blackboard created with writer/reader handles")
                end
            end
        end
    end
end

main()
