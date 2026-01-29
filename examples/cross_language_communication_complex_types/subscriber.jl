include(joinpath(@__DIR__, "..", "common", "imports.jl"))

include(joinpath(@__DIR__, "complex_type.jl"))

const CYCLE_SECONDS = 1

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(); service_type = :ipc)

    builder = publish_subscribe(service_builder(node, "CrossLanguageComplexTypes"), ComplexType)
    service = open_or_create(builder)
    subscriber = create(subscriber_builder(service))

    println("Subscriber ready to receive data!")
    sample = Sample(subscriber)

    while true
        sleep_or_interrupt(CYCLE_SECONDS) || break
        while receive!(subscriber, sample)
            try
                payload = payload(sample)[1]
                println("received: some_value=", payload.some_value, ", another_value=", payload.another_value)
            finally
                close(sample)
            end
        end
    end
end

main()
