include(joinpath(@__DIR__, "..", "common", "imports.jl"))

include(joinpath(@__DIR__, "transmission_data.jl"))

const CYCLE_SECONDS = 1

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(); service_type = :ipc)

    builder = request_response(service_builder(node, "My/Funk/ServiceName"), UInt64, TransmissionData)
    service = open_or_create(builder)
    client = create(client_builder(service))

    request_counter = UInt64(0)
    response_counter = UInt64(0)
    request = RequestMut(client)
    pending = PendingResponse(client)
    response = Response(pending)

    println("send request $(request_counter) ...")
    send_copy!(client, request_counter, pending)

    while true
        Iceoryx2.wait(node, CYCLE_SECONDS, 0)

        while receive!(pending, response)
            try
                println("received response $(response_counter): ", payload(response)[1])
                response_counter += 1
            finally
                close(response)
            end
        end
        close(pending)

        request_counter += 1
        loan_uninit!(client, request)
        write_payload!(request, request_counter)
        send!(request, pending)
        println("send request $(request_counter) ...")
    end
end

main()
