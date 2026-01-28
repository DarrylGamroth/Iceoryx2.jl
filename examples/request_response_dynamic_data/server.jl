include(joinpath(@__DIR__, "..", "common", "imports.jl"))

const CYCLE_MILLIS = 100
const MAX_VALUE = UInt64(0xff)

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(); service_type = :ipc)

    builder = request_response(service_builder(node, "My/Funk/ServiceName"), UInt8, UInt8;
        request_variant = :dynamic,
        response_variant = :dynamic,
    )
    service = open_or_create(builder)
    server_builder_obj = server_builder(service)
    initial_max_slice_len!(server_builder_obj, 16)
    allocation_strategy!(server_builder_obj, :power_of_two)
    server = create(server_builder_obj)

    println("Server ready to receive requests!")

    counter = UInt64(1)
    while true
        Iceoryx2.wait(node, 0, CYCLE_MILLIS * 1_000_000)
        active_request = receive(server)
        while active_request !== nothing
            println("received request with ", length(payload(active_request)), " bytes ...")
            required_size = min(UInt64(1_000_000), counter * counter)
            response = loan_slice_uninit(active_request, required_size)
            write_from_fn!(response) do byte_idx
                return UInt8((UInt64(byte_idx) + counter) % MAX_VALUE)
            end
            println("send response with ", length(payload_mut(response)), " bytes")
            send!(response)
            active_request = receive(server)
        end
        counter += 1
    end
end

main()
