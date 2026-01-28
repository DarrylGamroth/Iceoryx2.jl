include(joinpath(@__DIR__, "..", "common", "imports.jl"))

const CYCLE_SECONDS = 1
const MAX_VALUE = 0xff

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(); service_type = :ipc)

    builder = publish_subscribe(service_builder(node, "Service With Dynamic Data"), UInt8; variant = :dynamic)
    service = open_or_create(builder)

    pub_builder = publisher_builder(service)
    initial_max_slice_len!(pub_builder, 16)
    publisher = create(pub_builder)

    counter = UInt64(0)

    while true
        Iceoryx2.wait(node, CYCLE_SECONDS, 0)
        required_size = (counter + 1) * (counter + 1)
        sample = loan_slice_uninit(publisher, required_size)
        slice = payload_mut(sample)
        @inbounds for idx in 1:length(slice)
            slice[idx] = UInt8((idx - 1 + counter) % MAX_VALUE)
        end
        send!(sample)

        println("Send sample $(counter) with $(required_size) bytes...")
        counter += 1
    end
end

main()
