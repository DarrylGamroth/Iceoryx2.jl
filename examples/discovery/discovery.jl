include(joinpath(@__DIR__, "..", "common", "imports.jl"))

function main()
    set_log_level_from_env_or(:info)
    list_services(service_type=ServiceType.IPC, config=global_config()) do cfg
        println("Service: ", name(cfg), " (id=", id(cfg), ", pattern=", messaging_pattern(cfg), ")")
        return :continue
    end
end

main()
