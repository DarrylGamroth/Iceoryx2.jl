const _name_counter = Ref(0)

function unique_name(prefix::AbstractString)
    _name_counter[] += 1
    return string(prefix, "_", getpid(), "_", time_ns(), "_", _name_counter[])
end

unique_service_name() = unique_name("iox2_jl_service")
unique_node_name() = unique_name("iox2_jl_node")
