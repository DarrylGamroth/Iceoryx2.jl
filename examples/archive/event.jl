#!/usr/bin/env julia

include(joinpath(@__DIR__, "..", "common", "imports.jl"))

function main()
    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, "iox2_julia_event_node")

    Iceoryx2.create(node_builder, ServiceType.IPC) do node
        service_builder = Iceoryx2.service_builder(node, "iox2_julia_event_service")
        event_builder = Iceoryx2.event(service_builder)

        Iceoryx2.open_or_create(event_builder) do factory
            Iceoryx2.create(Iceoryx2.notifier_builder(factory)) do notifier
                Iceoryx2.create(Iceoryx2.listener_builder(factory)) do listener
                    Iceoryx2.notify!(notifier, Iceoryx2.EventId(7))

                    received = Iceoryx2.timed_wait(listener, 1, 0) do event_id, count
                        println("received event: ", Int(event_id), " (", count, " times)")
                    end
                    if received == 0
                        println("no event received")
                    end
                end
            end
        end
    end
end

main()
