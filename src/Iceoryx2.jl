module Iceoryx2

include("Iceoryx2FFI.jl")
using .Iceoryx2FFI

include("handles.jl")
include("errors.jl")
include("strings.jl")
include("builders.jl")

end # module Iceoryx2
