include(joinpath(@__DIR__, "..", "common", "imports.jl"))

include(joinpath(@__DIR__, "complex_type.jl"))

const CYCLE_SECONDS = 1

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(); service_type = :ipc)

    builder = publish_subscribe(service_builder(node, "CrossLanguageComplexTypes"), ComplexType)
    service = open_or_create(builder)
    publisher = create(publisher_builder(service))

    counter = UInt16(0)
    while true
        Iceoryx2.wait(node, CYCLE_SECONDS, 0)
        counter += 1

        sample = loan_uninit(publisher)
        name = FullName(static_string(Val(256), "Ada"), static_string(Val(256), "Lovelace"))
        address_book = static_vector_from_value(FullName, Val(ADDRESS_BOOK_CAPACITY), 1, name)
        row = static_vector_from_value(Float64, Val(8), 8, 1.0)
        matrix = static_vector_from_value(StaticVector{Float64, 8}, Val(8), 1, row)
        payload = ComplexType(address_book, matrix, counter, UInt32(counter) * 2)
        payload_mut(sample)[1] = payload
        send!(sample)

        println("Send sample $(counter)...")
    end
end

main()
