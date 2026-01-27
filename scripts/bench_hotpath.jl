#!/usr/bin/env julia

using BenchmarkTools
using Iceoryx2

println("Slice getindex")
data = UInt64[0x1, 0x2, 0x3, 0x4]
slice = Iceoryx2.Slice{UInt64}(pointer(data), length(data))
display(@benchmark $slice[2])

println("Callback progression")
display(@benchmark Iceoryx2._callback_progression(:continue))
