#!/usr/bin/env julia

include(joinpath(@__DIR__, "..", "common", "imports.jl"))

function main()
    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, "iox2_julia_pubsub_node")

    Iceoryx2.create(node_builder; service_type = :ipc) do node
        service_builder = Iceoryx2.service_builder(node, "iox2_julia_pubsub_service")
        pubsub_builder = Iceoryx2.publish_subscribe(service_builder, UInt64)

        Iceoryx2.open_or_create(pubsub_builder) do factory
            Iceoryx2.create(Iceoryx2.publisher_builder(factory)) do publisher
                Iceoryx2.create(Iceoryx2.subscriber_builder(factory)) do subscriber
                    Iceoryx2.send_copy(publisher, UInt64[0x1234_5678_9abc_def0])

                    sample = nothing
                    while sample === nothing
                        sample = Iceoryx2.receive(subscriber)
                        sample === nothing && yield()
                    end

                    slice = Iceoryx2.payload(sample)
                    println("received: ", slice[1])
                    close(sample)
                end
            end
        end
    end
end

main()
