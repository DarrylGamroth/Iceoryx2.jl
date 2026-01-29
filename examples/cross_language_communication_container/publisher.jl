include(joinpath(@__DIR__, "..", "common", "imports.jl"))

include(joinpath(@__DIR__, "..", "common", "static_types.jl"))

const CYCLE_SECONDS = 1

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(); service_type = :ipc)

    builder = publish_subscribe(service_builder(node, "CrossLanguageContainer"), StaticVector{UInt64, 32})
    builder = user_header(builder, StaticString{64})
    history_size!(builder, 5)
    subscriber_max_buffer_size!(builder, 5)
    enable_safe_overflow!(builder, false)
    service = open_or_create(builder)

    publisher = create(publisher_builder(service))

    counter = UInt64(0)
    sample = SampleMut(publisher)
    while true
        sleep_or_interrupt(CYCLE_SECONDS) || break
        counter += 1

        loan_uninit!(publisher, sample)
        user_header_mut(sample)[1] = static_string(Val(64), "Why are Kermit and Miss Piggy no longer together?")
        payload_mut(sample)[1] = static_vector_from_value(UInt64, Val(32), 2, counter)
        send!(sample)

        println("Send sample $(counter)...")
    end
end

main()
