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
    sample = SampleMut(publisher)
    while true
        sleep_or_interrupt(CYCLE_SECONDS) || break
        counter += 1

        loan_uninit!(publisher, sample)
        write_payload!(sample, TransmissionData(counter, counter * 3, counter * 812.12))
        send!(sample)

        println("Send sample $(counter)...")
    end
end

main()
