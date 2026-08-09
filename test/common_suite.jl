using Test
using Iceoryx2
using StaticArrays

include("testutils.jl")

Iceoryx2.type_name(::Type{StaticArrays.SVector{4, UInt8}}) = "SVector4UInt8"

@testset "Transport-independent" begin
    include("abi_version.jl")
    include("node_name.jl")
    include("type_names.jl")
    include("service_name.jl")
    include("enum_conversion.jl")
    include("logging.jl")
    include("slice.jl")
    include("file_descriptor.jl")
    include("attributes.jl")
end
