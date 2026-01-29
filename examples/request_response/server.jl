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
    active_request = ActiveRequest(server)
    response = ResponseMut(active_request)

    while true
        sleep_or_interrupt(CYCLE_SECONDS) || break
        while receive!(server, active_request)
            try
                println("received request: ", payload(active_request)[1])
                loan_uninit!(active_request, response)
                write_payload!(response, TransmissionData(Int32(payload(active_request)[1]), Int32(0), 0.0))
                send!(response)
            finally
                close(active_request)
            end
        end
    end
end

main()
