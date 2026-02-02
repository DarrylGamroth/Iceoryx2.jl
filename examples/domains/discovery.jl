include(joinpath(@__DIR__, "..", "common", "imports.jl"))

include(joinpath(@__DIR__, "..", "common", "cli.jl"))

function main()
    set_log_level_from_env_or(:info)

    show_help_if_requested(ARGS, [
        "Discovery of the domain example.",
        "",
        "Use '-d' or '--domain' to specify the name of the domain.",
    ])

    domain = parse_arg(ARGS, "-d", "--domain", "iox2_")
    cfg = config_from_ptr(global_config())
    global_prefix!(cfg, domain)

    println("Services running in domain \"$(domain)\":")
    list_services(service_type=ServiceType.IPC, config=cfg) do cfg_view
        println("Service: ", name(cfg_view), " (pattern=", messaging_pattern(cfg_view), ")")
        return :continue
    end
end

main()
