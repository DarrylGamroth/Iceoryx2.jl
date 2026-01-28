#!/usr/bin/env julia

using Iceoryx2

function main()
    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, "iox2_julia_request_response_node")

    Iceoryx2.create(node_builder; service_type = :ipc) do node
        service_builder = Iceoryx2.service_builder(node, "iox2_julia_request_response_service")
        rr_builder = Iceoryx2.request_response(service_builder, UInt64, UInt64)

        Iceoryx2.open_or_create(rr_builder) do factory
            Iceoryx2.create(Iceoryx2.server_builder(factory)) do server
                server_task = @async begin
                    request = nothing
                    while request === nothing
                        request = Iceoryx2.receive(server)
                        request === nothing && yield()
                    end

                    response_data = UInt64[0x2a]
                    GC.@preserve response_data begin
                        Iceoryx2.send_copy(request, pointer(response_data), length(response_data))
                    end
                    close(request)
                end

                Iceoryx2.create(Iceoryx2.client_builder(factory)) do client
                    pending = Iceoryx2.send_copy(client, UInt64[0x01])

                    response = nothing
                    while response === nothing
                        response = Iceoryx2.receive(pending)
                        response === nothing && yield()
                    end

                    slice = Iceoryx2.payload(response)
                    println("response: ", slice[1])

                    close(response)
                    close(pending)
                end

                wait(server_task)
            end
        end
    end
end

main()
