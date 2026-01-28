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

    while true
        required_size = min(UInt64(1_000_000), counter * counter)
        request = loan_slice_uninit(client, required_size)
        write_from_fn!(request) do byte_idx
            return UInt8((UInt64(byte_idx) + counter) % MAX_VALUE)
        end
        pending = send!(request)
        println("send request $(counter) with $(required_size) bytes ...")

        Iceoryx2.wait(node, CYCLE_SECONDS, 0)

        response = receive(pending)
        while response !== nothing
            println("received response with ", length(payload(response)), " bytes")
            response = receive(pending)
        end

        counter += 1
    end
end

main()
