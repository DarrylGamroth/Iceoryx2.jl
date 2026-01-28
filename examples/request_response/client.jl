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

    println("send request $(request_counter) ...")
    pending = send_copy(client, [request_counter])

    while true
        Iceoryx2.wait(node, CYCLE_SECONDS, 0)

        response = receive(pending)
        while response !== nothing
            println("received response $(response_counter): ", payload(response)[1])
            response_counter += 1
            response = receive(pending)
        end

        request_counter += 1
        request = loan_uninit(client)
        write_payload!(request, request_counter)
        pending = send!(request)
        println("send request $(request_counter) ...")
    end
end

main()
