include(joinpath(@__DIR__, "..", "common", "imports.jl"))

include(joinpath(@__DIR__, "transmission_data.jl"))

const CYCLE_SECONDS = 1

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(); service_type = :ipc)

    builder = publish_subscribe(service_builder(node, "My/Funk/ServiceName"), TransmissionData)
    service = open_or_create(builder)
    publisher = create(publisher_builder(service))

    counter = Int32(0)
    while true
        Iceoryx2.wait(node, CYCLE_SECONDS, 0)
        counter += 1

        sample = loan_uninit(publisher)
        write_payload!(sample, TransmissionData(counter, counter * 3, counter * 812.12))
        send!(sample)

        println("Send sample $(counter)...")
    end
end

main()
