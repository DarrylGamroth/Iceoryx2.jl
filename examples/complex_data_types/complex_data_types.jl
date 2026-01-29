include(joinpath(@__DIR__, "..", "common", "imports.jl"))

include(joinpath(@__DIR__, "..", "common", "static_types.jl"))

# Note: capacities are reduced from the C++ example to keep compile times reasonable.
const COMPLEX_CAPACITY = 16

struct ComplexData
    name::StaticString{4}
    data::StaticVector{UInt64, 4}
end

struct ComplexDataType
    plain_old_data::UInt64
    text::StaticString{8}
    vec_of_data::StaticVector{UInt64, 4}
    vec_of_complex_data::StaticVector{ComplexData, COMPLEX_CAPACITY}
end

Base.zero(::Type{ComplexData}) = ComplexData(static_string(Val(4), ""), static_vector_from_value(UInt64, Val(4), 0, 0))
Base.zero(::Type{ComplexDataType}) = ComplexDataType(0, static_string(Val(8), ""), static_vector_from_value(UInt64, Val(4), 0, 0), static_vector_from_value(ComplexData, Val(COMPLEX_CAPACITY), 0, zero(ComplexData)))

const CYCLE_SECONDS = 1

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(); service_type = :ipc)

    builder = publish_subscribe(service_builder(node, "My/Funk/ServiceName"), ComplexDataType)
    max_publishers!(builder, 16)
    max_subscribers!(builder, 16)
    service = open_or_create(builder)
    publisher = create(publisher_builder(service))
    subscriber = create(subscriber_builder(service))

    counter = UInt64(0)
    sample = SampleMut(publisher)
    recv_sample = Sample(subscriber)
    while true
        Iceoryx2.wait(node, CYCLE_SECONDS, 0)
        counter += 1

        loan_uninit!(publisher, sample)
        payload = ComplexDataType(
            counter,
            static_string(Val(8), "hello"),
            static_vector_from_value(UInt64, Val(4), 1, counter),
            static_vector_from_value(ComplexData, Val(COMPLEX_CAPACITY), 1,
                ComplexData(static_string(Val(4), "bla"), static_vector_from_value(UInt64, Val(4), 2, counter))),
        )
        payload_mut(sample)[1] = payload
        send!(sample)

        println("$counter :: send")

        while receive!(subscriber, recv_sample)
            try
                println("received: ", string(payload(recv_sample)[1].text))
            finally
                close(recv_sample)
            end
        end
    end
end

main()
