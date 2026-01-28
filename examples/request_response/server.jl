include(joinpath(@__DIR__, "..", "common", "imports.jl"))

include(joinpath(@__DIR__, "transmission_data.jl"))

const CYCLE_SECONDS = 1

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(); service_type = :ipc)

    builder = request_response(service_builder(node, "My/Funk/ServiceName"), UInt64, TransmissionData)
    service = open_or_create(builder)
    server = create(server_builder(service))

    println("Server ready to receive requests!")

    while true
        Iceoryx2.wait(node, CYCLE_SECONDS, 0)
        active_request = receive(server)
        while active_request !== nothing
            println("received request: ", payload(active_request)[1])
            response = loan_uninit(active_request)
            write_payload!(response, TransmissionData(Int32(payload(active_request)[1]), Int32(0), 0.0))
            send!(response)
            active_request = receive(server)
        end
    end
end

main()
