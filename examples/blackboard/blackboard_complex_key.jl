struct BlackboardKey
    first::Int32
    second::Int32
    third::Int32
end

Iceoryx2.type_name(::Type{BlackboardKey}) = "BlackboardKey"
