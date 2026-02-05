using Pkg

Pkg.instantiate()

include(joinpath(@__DIR__, "gen-bindings.jl"))

root = joinpath(@__DIR__, "..")
files = [
    "src/generated/Iceoryx2FFI.jl",
    "src/generated/handles.jl",
    "src/generated/errors.jl",
    "src/generated/wrappers.jl",
]

cd(root) do
    if !success(`git diff --exit-code -- $(files...)`)
        run(`git --no-pager diff --stat -- $(files...)`)
        error("Generated files out of date. Run: julia --project=gen gen/gen-bindings.jl")
    end
end
