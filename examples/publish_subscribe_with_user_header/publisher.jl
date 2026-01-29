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
    sample = SampleMut(publisher)
    while true
        sleep_or_interrupt(CYCLE_SECONDS) || break
        counter += 1
        loan_uninit!(publisher, sample)

        user_header_mut(sample)[1] = CustomHeader(Int32(123), UInt64(80337 + counter))
        write_payload!(sample, counter)
        send!(sample)

        println("Send sample $(counter)...")
    end
end

main()
