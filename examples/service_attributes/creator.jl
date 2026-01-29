include(joinpath(@__DIR__, "..", "common", "imports.jl"))

const CYCLE_SECONDS = 1

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(); service_type = :ipc)

    specifier = AttributeSpecifier()
    define!(specifier, "dds_service_mapping", "my_funky_service_name")
    define!(specifier, "tcp_serialization_format", "cdr")
    define!(specifier, "someip_service_mapping", "1/2/3")
    define!(specifier, "camera_resolution", "1920x1080")

    builder = publish_subscribe(service_builder(node, "Service/With/Properties"), UInt64)
    service = create_with_attributes(builder, specifier)

    publisher = create(publisher_builder(service))

    println("defined service attributes: ", attributes(service))
    sample = SampleMut(publisher)

    while true
        sleep_or_interrupt(CYCLE_SECONDS) || break
        loan!(publisher, sample)
        payload_mut(sample)[1] = UInt64(0)
        send!(sample)
    end
end

main()
