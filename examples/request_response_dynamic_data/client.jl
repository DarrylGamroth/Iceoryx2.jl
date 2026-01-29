include(joinpath(@__DIR__, "..", "common", "imports.jl"))

const CYCLE_SECONDS = 1
const MAX_VALUE = UInt64(0xff)

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(); service_type = :ipc)

    builder = request_response(service_builder(node, "My/Funk/ServiceName"), UInt8, UInt8;
        request_variant = :dynamic,
        response_variant = :dynamic,
    )
    service = open_or_create(builder)
    client_builder_obj = client_builder(service)
    initial_max_slice_len!(client_builder_obj, 16)
    allocation_strategy!(client_builder_obj, :power_of_two)
    client = create(client_builder_obj)

    counter = UInt64(1)
    request = RequestMut(client)
    pending = PendingResponse(client)
    response = Response(pending)

    while true
        required_size = min(UInt64(1_000_000), counter * counter)
        loan_slice_uninit!(client, request, required_size)
        write_from_fn!(request) do byte_idx
            return UInt8((UInt64(byte_idx) + counter) % MAX_VALUE)
        end
        send!(request, pending)
        println("send request $(counter) with $(required_size) bytes ...")

        Iceoryx2.wait(node, CYCLE_SECONDS, 0)

        while receive!(pending, response)
            try
                println("received response with ", length(payload(response)), " bytes")
            finally
                close(response)
            end
        end
        close(pending)

        counter += 1
    end
end

main()
