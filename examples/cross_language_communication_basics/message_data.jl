struct TransmissionData
    x::Int32
    y::Int32
    funky::Float64
end

struct CustomHeader
    version::Int32
    timestamp::UInt64
end

function Base.show(io::IO, value::TransmissionData)
    print(io, "TransmissionData { x: ", value.x, ", y: ", value.y, ", funky: ", value.funky, " }")
end

function Base.show(io::IO, value::CustomHeader)
    print(io, "CustomHeader { version: ", value.version, ", timestamp: ", value.timestamp, " }")
end

Iceoryx2.type_name(::Type{TransmissionData}) = "TransmissionData"
Iceoryx2.type_name(::Type{CustomHeader}) = "CustomHeader"
