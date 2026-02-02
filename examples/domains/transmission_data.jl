struct TransmissionData
    x::Int32
    y::Int32
    funky::Float64
end

Iceoryx2.type_name(::Type{TransmissionData}) = "TransmissionData"

function Base.show(io::IO, value::TransmissionData)
    print(io, "TransmissionData { x: ", value.x, ", y: ", value.y, ", funky: ", value.funky, " }")
end
