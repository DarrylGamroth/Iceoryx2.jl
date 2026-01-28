include(joinpath(@__DIR__, "..", "common", "imports.jl"))

include(joinpath(@__DIR__, "custom_header.jl"))

const CYCLE_SECONDS = 1

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(); service_type = :ipc)

    builder = publish_subscribe(service_builder(node, "My/Funk/ServiceName"), UInt64)
    builder = user_header(builder, CustomHeader)
    service = open_or_create(builder)

    publisher = create(publisher_builder(service))

    counter = UInt64(0)
    while true
        Iceoryx2.wait(node, CYCLE_SECONDS, 0)
        counter += 1
        sample = loan_uninit(publisher)

        user_header_mut(sample)[1] = CustomHeader(Int32(123), UInt64(80337 + counter))
        write_payload!(sample, counter)
        send!(sample)

        println("Send sample $(counter)...")
    end
end

main()
