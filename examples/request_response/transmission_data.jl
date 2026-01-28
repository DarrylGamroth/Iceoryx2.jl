struct TransmissionData
    x::Int32
    y::Int32
    funky::Float64
end

function Base.show(io::IO, value::TransmissionData)
    print(io, "TransmissionData { x: ", value.x, ", y: ", value.y, ", funky: ", value.funky, " }")
end
