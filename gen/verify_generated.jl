using Pkg

Pkg.instantiate()

root = joinpath(@__DIR__, "..")
generated = joinpath(root, "src", "generated")
files = ["Iceoryx2FFI.jl", "handles.jl", "errors.jl", "wrappers.jl"]

mktempdir() do output_dir
    command = addenv(
        `$(Base.julia_cmd()) --startup-file=no --project=$(@__DIR__) $(joinpath(@__DIR__, "gen-bindings.jl"))`,
        "IOX2_GENERATED_DIR" => output_dir
    )
    run(command)

    stale = String[]
    for file in files
        read(joinpath(output_dir, file)) == read(joinpath(generated, file)) ||
            push!(stale, file)
    end

    isempty(stale) || error(
        "Generated files out of date ($(join(stale, ", "))). Run: " *
        "julia --startup-file=no --project=gen gen/gen-bindings.jl",
    )
end
