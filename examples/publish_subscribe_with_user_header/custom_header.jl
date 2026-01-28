struct CustomHeader
    version::Int32
    timestamp::UInt64
end

function Base.show(io::IO, value::CustomHeader)
    print(io, "CustomHeader { version: ", value.version, ", timestamp: ", value.timestamp, " }")
end
