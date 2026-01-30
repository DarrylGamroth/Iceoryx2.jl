include(joinpath(@__DIR__, "..", "common", "imports.jl"))

const CYCLE_SECONDS = 1
const MAX_VALUE = UInt64(0xff)

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(); service_type = :ipc)

    builder = publish_subscribe(service_builder(node, "Service With Dynamic Data"), AbstractVector{UInt8})
    service = open_or_create(builder)

    pub_builder = publisher_builder(service)
    initial_max_slice_len!(pub_builder, 16)
    allocation_strategy!(pub_builder, :power_of_two)
    publisher = create(pub_builder)

    counter = UInt64(0)
    sample = SampleMut(publisher)

    try
        while true
            sleep(CYCLE_SECONDS)
            required_size = (counter + 1) * (counter + 1)
            loan_slice_uninit!(publisher, sample, required_size)
            write_from_fn!(sample) do byte_idx
                return UInt8((UInt64(byte_idx) + counter) % MAX_VALUE)
            end
            send!(sample)

            println("Send sample $(counter) with $(required_size) bytes...")
            counter += 1
        end
    catch err
        err isa InterruptException || rethrow()
    finally
        close(sample)
        close(publisher)
        close(service)
        close(node)
    end
end

main()
