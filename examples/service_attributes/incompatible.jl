include(joinpath(@__DIR__, "..", "common", "imports.jl"))

function main()
    set_log_level_from_env_or(:info)
    node = create(NodeBuilder(), ServiceType.IPC)

    verifier = AttributeVerifier()
    require!(verifier, "camera_resolution", "3840x2160")

    try
        builder = publish_subscribe(service_builder(node, "Service/With/Properties"), UInt64)
        _service = open_with_attributes(builder, verifier)
    catch
        println("camera_resolution: 3840x2160 -> not available")
    end

    verifier = AttributeVerifier()
    require_key!(verifier, "camera_type")

    try
        builder = publish_subscribe(service_builder(node, "My/Funk/ServiceName"), UInt64)
        _service = open_with_attributes(builder, verifier)
    catch
        println("camera_type -> not available")
    end
end

main()
