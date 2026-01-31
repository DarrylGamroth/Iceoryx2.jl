include(joinpath(@__DIR__, "..", "common", "imports.jl"))

const CYCLE_MILLIS = 100
const MAX_VALUE = UInt64(0xff)

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(), ServiceType.IPC)

    builder = request_response(service_builder(node, "My/Funk/ServiceName"),
        AbstractVector{UInt8}, AbstractVector{UInt8})
    service = open_or_create(builder)
    server_builder_obj = server_builder(service)
    initial_max_slice_len!(server_builder_obj, 16)
    allocation_strategy!(server_builder_obj, :power_of_two)
    server = create(server_builder_obj)

    println("Server ready to receive requests!")
    active_request = ActiveRequest(server)
    response = ResponseMut(active_request)

    counter = UInt64(1)
    try
        while true
            sleep(CYCLE_MILLIS / 1000)
            while receive!(server, active_request)
                try
                    println("received request with ", length(payload(active_request)), " bytes ...")
                    required_size = min(UInt64(1_000_000), counter * counter)
                    loan_slice_uninit!(active_request, response, required_size)
                    slice = payload_mut(response)
                    map!(
                        idx -> UInt8((UInt64(idx - 1) + counter) % MAX_VALUE),
                        slice,
                        Base.OneTo(length(slice)),
                    )
                    println("send response with ", length(payload_mut(response)), " bytes")
                    send!(response)
                finally
                    close(active_request)
                end
            end
            counter += 1
        end
    catch err
        err isa InterruptException || rethrow()
    finally
        close(response)
        close(active_request)
        close(server)
        close(service)
        close(node)
    end
end

main()
