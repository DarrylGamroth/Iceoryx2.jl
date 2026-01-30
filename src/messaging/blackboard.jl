mutable struct PortFactoryBlackboard{K}
    handle::Iceoryx2FFI.iox2_port_factory_blackboard_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_blackboard_t}
    keepalive::Node
    values::Vector{Any}
    function PortFactoryBlackboard{K}(handle, storage, keepalive, values) where {K}
        obj = new{K}(handle, storage, keepalive, values)
        finalizer(_finalize_port_factory_blackboard, obj)
        return obj
    end
end

function _finalize_port_factory_blackboard(factory::PortFactoryBlackboard)
    if factory.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_port_factory_blackboard_drop(factory.handle)
        factory.handle = _IOX2_NULL
    end
    factory.storage = nothing
    empty!(factory.values)
    return nothing
end

function create(builder::BlackboardCreatorBuilder{K}) where {K}
    _require_valid(builder.handle, "blackboard creator")
    _require_isbits(K)
    storage = Ref{Iceoryx2FFI.iox2_port_factory_blackboard_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_blackboard_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_blackboard_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_blackboard_create_error_e)
    builder.handle = _IOX2_NULL
    values = builder.values
    builder.values = Any[]
    _finalize_service_builder_variant(builder)
    return PortFactoryBlackboard{K}(handle_ref[], storage, builder.keepalive, values)
end

function create(f::Function, builder::BlackboardCreatorBuilder)
    factory = create(builder)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function open(builder::BlackboardOpenerBuilder{K}) where {K}
    _require_valid(builder.handle, "blackboard opener")
    _require_isbits(K)
    storage = Ref{Iceoryx2FFI.iox2_port_factory_blackboard_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_blackboard_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_blackboard_open(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_blackboard_open_error_e)
    builder.handle = _IOX2_NULL
    _finalize_service_builder_variant(builder)
    return PortFactoryBlackboard{K}(handle_ref[], storage, builder.keepalive, Any[])
end

function open(f::Function, builder::BlackboardOpenerBuilder)
    factory = open(builder)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function _set_key_type!(builder::BlackboardCreatorBuilder{K}, ::Type{K}) where {K}
    _require_valid(builder.handle, "blackboard creator")
    _require_isbits(K)
    name, name_len, size, alignment = _type_details(K)
    push!(builder.values, name)
    GC.@preserve name begin
        ret = Iceoryx2FFI.iox2_service_builder_blackboard_creator_set_key_type_details(
            Ref{Iceoryx2FFI.iox2_service_builder_blackboard_creator_h}(builder.handle),
            Base.unsafe_convert(Cstring, name),
            name_len,
            size,
            alignment,
        )
        check_ok(ret, Iceoryx2FFI.iox2_type_detail_error_e)
    end
    return builder
end

function _set_key_type!(builder::BlackboardOpenerBuilder{K}, ::Type{K}) where {K}
    _require_valid(builder.handle, "blackboard opener")
    _require_isbits(K)
    name, name_len, size, alignment = _type_details(K)
    GC.@preserve name begin
        ret = Iceoryx2FFI.iox2_service_builder_blackboard_opener_set_key_type_details(
            Ref{Iceoryx2FFI.iox2_service_builder_blackboard_opener_h}(builder.handle),
            Base.unsafe_convert(Cstring, name),
            name_len,
            size,
            alignment,
        )
        check_ok(ret, Iceoryx2FFI.iox2_type_detail_error_e)
    end
    return builder
end

function _key_eq_comparison!(builder::BlackboardCreatorBuilder{K}) where {K}
    _require_valid(builder.handle, "blackboard creator")
    Iceoryx2FFI.iox2_service_builder_blackboard_creator_set_key_eq_comparison_function(
        Ref{Iceoryx2FFI.iox2_service_builder_blackboard_creator_h}(builder.handle),
        _blackboard_key_eq_cmp_cfunction(K),
    )
    return builder
end

### builder tuning setters generated in src/generated/wrappers.jl

function add!(builder::BlackboardCreatorBuilder{K}, key::K, value::V) where {K,V}
    _require_valid(builder.handle, "blackboard creator")
    _require_isbits(K)
    _require_isbits(V)
    key_ref = Ref{K}(key)
    value_ref = Ref{V}(value)
    push!(builder.values, key_ref)
    push!(builder.values, value_ref)
    name, name_len, size, alignment = _type_details(V)
    push!(builder.values, name)
    GC.@preserve key_ref value_ref name begin
        Iceoryx2FFI.iox2_service_builder_blackboard_creator_add(
            Ref{Iceoryx2FFI.iox2_service_builder_blackboard_creator_h}(builder.handle),
            Base.unsafe_convert(Ptr{Cvoid}, key_ref),
            Base.unsafe_convert(Ptr{Cvoid}, value_ref),
            C_NULL,
            Base.unsafe_convert(Cstring, name),
            name_len,
            size,
            alignment,
        )
    end
    return builder
end

function add_with_default!(builder::BlackboardCreatorBuilder{K}, key::K, ::Type{V}) where {K,V}
    return add!(builder, key, zero(V))
end

mutable struct WriterBuilder{K}
    handle::Iceoryx2FFI.iox2_port_factory_writer_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_writer_builder_t}
    keepalive::PortFactoryBlackboard{K}
    function WriterBuilder{K}(handle, storage, keepalive) where {K}
        obj = new{K}(handle, storage, keepalive)
        finalizer(_finalize_writer_builder, obj)
        return obj
    end
end

function _finalize_writer_builder(builder::WriterBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

function writer_builder(factory::PortFactoryBlackboard{K}) where {K}
    _require_valid(factory.handle, "blackboard port factory")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_writer_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_blackboard_writer_builder(Ref{Iceoryx2FFI.iox2_port_factory_blackboard_h}(factory.handle), storage)
    return WriterBuilder{K}(handle, storage, factory)
end

mutable struct ReaderBuilder{K}
    handle::Iceoryx2FFI.iox2_port_factory_reader_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_reader_builder_t}
    keepalive::PortFactoryBlackboard{K}
    function ReaderBuilder{K}(handle, storage, keepalive) where {K}
        obj = new{K}(handle, storage, keepalive)
        finalizer(_finalize_reader_builder, obj)
        return obj
    end
end

function _finalize_reader_builder(builder::ReaderBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

function reader_builder(factory::PortFactoryBlackboard{K}) where {K}
    _require_valid(factory.handle, "blackboard port factory")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_reader_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_blackboard_reader_builder(Ref{Iceoryx2FFI.iox2_port_factory_blackboard_h}(factory.handle), storage)
    return ReaderBuilder{K}(handle, storage, factory)
end

mutable struct Writer{K}
    handle::Iceoryx2FFI.iox2_writer_h
    storage::_StorageRef{Iceoryx2FFI.iox2_writer_t}
    keepalive::PortFactoryBlackboard{K}
    function Writer{K}(handle, storage, keepalive) where {K}
        obj = new{K}(handle, storage, keepalive)
        finalizer(_finalize_writer, obj)
        return obj
    end
end

function _finalize_writer(writer::Writer)
    if writer.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_writer_drop(writer.handle)
        writer.handle = _IOX2_NULL
    end
    writer.storage = nothing
    return nothing
end

function create(builder::WriterBuilder{K}) where {K}
    _require_valid(builder.handle, "writer builder")
    storage = Ref{Iceoryx2FFI.iox2_writer_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_writer_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_writer_builder_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_writer_create_error_e)
    _finalize_writer_builder(builder)
    return Writer{K}(handle_ref[], storage, builder.keepalive)
end

function create(f::Function, builder::WriterBuilder{K}) where {K}
    writer = create(builder)
    try
        return f(writer)
    finally
        close(writer)
    end
end

mutable struct Reader{K}
    handle::Iceoryx2FFI.iox2_reader_h
    storage::_StorageRef{Iceoryx2FFI.iox2_reader_t}
    keepalive::PortFactoryBlackboard{K}
    function Reader{K}(handle, storage, keepalive) where {K}
        obj = new{K}(handle, storage, keepalive)
        finalizer(_finalize_reader, obj)
        return obj
    end
end

function _finalize_reader(reader::Reader)
    if reader.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_reader_drop(reader.handle)
        reader.handle = _IOX2_NULL
    end
    reader.storage = nothing
    return nothing
end

function create(builder::ReaderBuilder{K}) where {K}
    _require_valid(builder.handle, "reader builder")
    storage = Ref{Iceoryx2FFI.iox2_reader_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_reader_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_reader_builder_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_reader_create_error_e)
    _finalize_reader_builder(builder)
    return Reader{K}(handle_ref[], storage, builder.keepalive)
end

function create(f::Function, builder::ReaderBuilder{K}) where {K}
    reader = create(builder)
    try
        return f(reader)
    finally
        close(reader)
    end
end

mutable struct EntryHandle{K,V}
    handle_ref::Base.RefValue{Iceoryx2FFI.iox2_entry_handle_h}
    storage::Base.RefValue{Iceoryx2FFI.iox2_entry_handle_t}
    keepalive::Reader{K}
    function EntryHandle{K,V}(handle_ref, storage, keepalive) where {K,V}
        obj = new{K,V}(handle_ref, storage, keepalive)
        finalizer(_finalize_entry_handle, obj)
        return obj
    end
end

function EntryHandle{K,V}(reader::Reader{K}) where {K,V}
    return EntryHandle{K,V}(Ref{Iceoryx2FFI.iox2_entry_handle_h}(_IOX2_NULL), Ref{Iceoryx2FFI.iox2_entry_handle_t}(), reader)
end

EntryHandle(reader::Reader{K}, ::Type{V}) where {K,V} = EntryHandle{K,V}(reader)

function _finalize_entry_handle(entry::EntryHandle)
    if entry.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_entry_handle_drop(entry.handle_ref[])
        entry.handle_ref[] = _IOX2_NULL
    end
    return nothing
end

mutable struct EntryHandleMut{K,V}
    handle_ref::Base.RefValue{Iceoryx2FFI.iox2_entry_handle_mut_h}
    storage::Base.RefValue{Iceoryx2FFI.iox2_entry_handle_mut_t}
    keepalive::Writer{K}
    function EntryHandleMut{K,V}(handle_ref, storage, keepalive) where {K,V}
        obj = new{K,V}(handle_ref, storage, keepalive)
        finalizer(_finalize_entry_handle_mut, obj)
        return obj
    end
end

function EntryHandleMut{K,V}(writer::Writer{K}) where {K,V}
    return EntryHandleMut{K,V}(Ref{Iceoryx2FFI.iox2_entry_handle_mut_h}(_IOX2_NULL), Ref{Iceoryx2FFI.iox2_entry_handle_mut_t}(), writer)
end

EntryHandleMut(writer::Writer{K}, ::Type{V}) where {K,V} = EntryHandleMut{K,V}(writer)

function _finalize_entry_handle_mut(entry::EntryHandleMut)
    if entry.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_entry_handle_mut_drop(entry.handle_ref[])
        entry.handle_ref[] = _IOX2_NULL
    end
    return nothing
end

mutable struct EntryValueUninit{K,V}
    handle_ref::Base.RefValue{Iceoryx2FFI.iox2_entry_value_uninit_h}
    storage::Base.RefValue{Iceoryx2FFI.iox2_entry_value_uninit_t}
    keepalive::Writer{K}
    function EntryValueUninit{K,V}(handle_ref, storage, keepalive) where {K,V}
        obj = new{K,V}(handle_ref, storage, keepalive)
        finalizer(_finalize_entry_value_uninit, obj)
        return obj
    end
end

function EntryValueUninit{K,V}(writer::Writer{K}) where {K,V}
    return EntryValueUninit{K,V}(Ref{Iceoryx2FFI.iox2_entry_value_uninit_h}(_IOX2_NULL), Ref{Iceoryx2FFI.iox2_entry_value_uninit_t}(), writer)
end

EntryValueUninit(writer::Writer{K}, ::Type{V}) where {K,V} = EntryValueUninit{K,V}(writer)
EntryValueUninit(entry::EntryHandleMut{K,V}) where {K,V} = EntryValueUninit{K,V}(entry.keepalive)

@inline _slice_mutable(::Type{<:EntryValueUninit}) = true

function _finalize_entry_value_uninit(value::EntryValueUninit)
    if value.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_entry_value_uninit_drop(value.handle_ref[])
        value.handle_ref[] = _IOX2_NULL
    end
    return nothing
end

function loan_uninit!(entry::EntryHandleMut{K,V}, value::EntryValueUninit{K,V}) where {K,V}
    _require_valid(entry.handle_ref[], "entry handle mut")
    _require_inactive(value, "entry value")
    value.handle_ref[] = _IOX2_NULL
    size = Iceoryx2FFI.c_size_t(sizeof(V))
    alignment = Iceoryx2FFI.c_size_t(Base.datatype_alignment(V))
    Iceoryx2FFI.iox2_entry_handle_mut_loan_uninit(entry.handle_ref[], value.storage, value.handle_ref, size, alignment)
    entry.handle_ref[] = _IOX2_NULL
    value.keepalive = entry.keepalive
    return value
end

function loan_uninit!(f::Function, entry::EntryHandleMut{K,V}, value::EntryValueUninit{K,V}) where {K,V}
    loan_uninit!(entry, value)
    try
        return f(value)
    finally
        isvalid(value) && close(value)
    end
end

@inline function value_mut(value::EntryValueUninit{K,V}) where {K,V}
    ptr_ref = Ref{Ptr{Cvoid}}()
    Iceoryx2FFI.iox2_entry_value_uninit_value_mut(
        value.handle_ref,
        ptr_ref,
    )
    return Ptr{V}(ptr_ref[])
end

@inline function value!(value::EntryValueUninit{K,V}, data::V) where {K,V}
    ptr = value_mut(value)
    unsafe_store!(ptr, data)
    return value
end

function update!(value::EntryValueUninit{K,V}, entry::EntryHandleMut{K,V}) where {K,V}
    _require_inactive(entry, "entry handle mut")
    entry.handle_ref[] = _IOX2_NULL
    Iceoryx2FFI.iox2_entry_value_uninit_update(value.handle_ref[], entry.storage, entry.handle_ref)
    value.handle_ref[] = _IOX2_NULL
    entry.keepalive = value.keepalive
    return entry
end

function discard!(value::EntryValueUninit{K,V}, entry::EntryHandleMut{K,V}) where {K,V}
    _require_inactive(entry, "entry handle mut")
    entry.handle_ref[] = _IOX2_NULL
    Iceoryx2FFI.iox2_entry_value_uninit_discard(value.handle_ref[], entry.storage, entry.handle_ref)
    value.handle_ref[] = _IOX2_NULL
    entry.keepalive = value.keepalive
    return entry
end

function reader_entry!(reader::Reader{K}, entry::EntryHandle{K,V}, key::K) where {K,V}
    _require_valid(reader.handle, "reader")
    _require_isbits(K)
    _require_isbits(V)
    _require_inactive(entry, "entry handle")
    entry.handle_ref[] = _IOX2_NULL
    key_ref = Ref{K}(key)
    name, name_len, size, alignment = _type_details(V)
    GC.@preserve key_ref name begin
        ret = Iceoryx2FFI.iox2_reader_entry(
            Ref{Iceoryx2FFI.iox2_reader_h}(reader.handle),
            entry.storage,
            entry.handle_ref,
            Base.unsafe_convert(Ptr{Cvoid}, key_ref),
            Base.unsafe_convert(Cstring, name),
            name_len,
            size,
            alignment,
        )
        check_ok(ret, Iceoryx2FFI.iox2_entry_handle_error_e)
    end
    entry.keepalive = reader
    return entry
end

function reader_entry!(f::Function, reader::Reader{K}, entry::EntryHandle{K,V}, key::K) where {K,V}
    reader_entry!(reader, entry, key)
    try
        return f(entry)
    finally
        close(entry)
    end
end

function try_reader_entry!(reader::Reader{K}, entry::EntryHandle{K,V}, key::K) where {K,V}
    _require_valid(reader.handle, "reader")
    _require_isbits(K)
    _require_isbits(V)
    _require_inactive(entry, "entry handle")
    entry.handle_ref[] = _IOX2_NULL
    key_ref = Ref{K}(key)
    name, name_len, size, alignment = _type_details(V)
    GC.@preserve key_ref name begin
        ret = Iceoryx2FFI.iox2_reader_entry(
            Ref{Iceoryx2FFI.iox2_reader_h}(reader.handle),
            entry.storage,
            entry.handle_ref,
            Base.unsafe_convert(Ptr{Cvoid}, key_ref),
            Base.unsafe_convert(Cstring, name),
            name_len,
            size,
            alignment,
        )
        err = Iceoryx2FFI.iox2_entry_handle_error_e(ret)
        if err == Iceoryx2FFI.iox2_entry_handle_error_e_ENTRY_DOES_NOT_EXIST
            return false
        end
        check_ok(ret, Iceoryx2FFI.iox2_entry_handle_error_e)
    end
    entry.keepalive = reader
    return true
end

function try_reader_entry!(f::Function, reader::Reader{K}, entry::EntryHandle{K,V}, key::K) where {K,V}
    try_reader_entry!(reader, entry, key) || return nothing
    try
        return f(entry)
    finally
        close(entry)
    end
end

function writer_entry!(writer::Writer{K}, entry::EntryHandleMut{K,V}, key::K) where {K,V}
    _require_valid(writer.handle, "writer")
    _require_isbits(K)
    _require_isbits(V)
    _require_inactive(entry, "entry handle mut")
    entry.handle_ref[] = _IOX2_NULL
    key_ref = Ref{K}(key)
    name, name_len, size, alignment = _type_details(V)
    GC.@preserve key_ref name begin
        ret = Iceoryx2FFI.iox2_writer_entry(
            Ref{Iceoryx2FFI.iox2_writer_h}(writer.handle),
            entry.storage,
            entry.handle_ref,
            Base.unsafe_convert(Ptr{Cvoid}, key_ref),
            Base.unsafe_convert(Cstring, name),
            name_len,
            size,
            alignment,
        )
        check_ok(ret, Iceoryx2FFI.iox2_entry_handle_mut_error_e)
    end
    entry.keepalive = writer
    return entry
end

function writer_entry!(f::Function, writer::Writer{K}, entry::EntryHandleMut{K,V}, key::K) where {K,V}
    writer_entry!(writer, entry, key)
    try
        return f(entry)
    finally
        close(entry)
    end
end

function try_writer_entry!(writer::Writer{K}, entry::EntryHandleMut{K,V}, key::K) where {K,V}
    _require_valid(writer.handle, "writer")
    _require_isbits(K)
    _require_isbits(V)
    _require_inactive(entry, "entry handle mut")
    entry.handle_ref[] = _IOX2_NULL
    key_ref = Ref{K}(key)
    name, name_len, size, alignment = _type_details(V)
    GC.@preserve key_ref name begin
        ret = Iceoryx2FFI.iox2_writer_entry(
            Ref{Iceoryx2FFI.iox2_writer_h}(writer.handle),
            entry.storage,
            entry.handle_ref,
            Base.unsafe_convert(Ptr{Cvoid}, key_ref),
            Base.unsafe_convert(Cstring, name),
            name_len,
            size,
            alignment,
        )
        err = Iceoryx2FFI.iox2_entry_handle_mut_error_e(ret)
        if err == Iceoryx2FFI.iox2_entry_handle_mut_error_e_ENTRY_DOES_NOT_EXIST
            return false
        end
        check_ok(ret, Iceoryx2FFI.iox2_entry_handle_mut_error_e)
    end
    entry.keepalive = writer
    return true
end

function try_writer_entry!(f::Function, writer::Writer{K}, entry::EntryHandleMut{K,V}, key::K) where {K,V}
    try_writer_entry!(writer, entry, key) || return nothing
    try
        return f(entry)
    finally
        close(entry)
    end
end

@inline function entry_id(entry::EntryHandle)
    id_ref = Ref{Iceoryx2FFI.iox2_event_id_t}()
    Iceoryx2FFI.iox2_entry_handle_entry_id(entry.handle_ref, id_ref)
    return EventId(id_ref[])
end

@inline function entry_id(entry::EntryHandleMut)
    id_ref = Ref{Iceoryx2FFI.iox2_event_id_t}()
    Iceoryx2FFI.iox2_entry_handle_mut_entry_id(entry.handle_ref, id_ref)
    return EventId(id_ref[])
end

function get!(entry::EntryHandle{K,V}, value_ref::Base.RefValue{V}, generation_ref::Base.RefValue{UInt64}) where {K,V}
    size = Iceoryx2FFI.c_size_t(sizeof(V))
    alignment = Iceoryx2FFI.c_size_t(Base.datatype_alignment(V))
    GC.@preserve value_ref generation_ref begin
        Iceoryx2FFI.iox2_entry_handle_get(
            entry.handle_ref,
            Base.unsafe_convert(Ptr{Cvoid}, value_ref),
            size,
            alignment,
            Base.unsafe_convert(Ptr{Cvoid}, generation_ref),
        )
    end
    return nothing
end

function get!(entry::EntryHandle{K,V}, value_ref::Base.RefValue{V}) where {K,V}
    generation_ref = Ref{UInt64}(0)
    get!(entry, value_ref, generation_ref)
    return generation_ref[]
end

function get(entry::EntryHandle{K,V}) where {K,V}
    value_ref = Ref{V}()
    generation_ref = Ref{UInt64}(0)
    get!(entry, value_ref, generation_ref)
    return value_ref[], generation_ref[]
end

@inline function is_up_to_date(entry::EntryHandle, generation_counter::UInt64)
    return Iceoryx2FFI.iox2_entry_handle_is_up_to_date(
        entry.handle_ref,
        generation_counter,
    )
end

function update!(entry::EntryHandleMut{K,V}, value_ref::Base.RefValue{V}) where {K,V}
    size = Iceoryx2FFI.c_size_t(sizeof(V))
    alignment = Iceoryx2FFI.c_size_t(Base.datatype_alignment(V))
    GC.@preserve value_ref begin
        Iceoryx2FFI.iox2_entry_handle_mut_update_with_copy(
            entry.handle_ref,
            Base.unsafe_convert(Ptr{Cvoid}, value_ref),
            size,
            alignment,
        )
    end
    return nothing
end

function update!(entry::EntryHandleMut{K,V}, value::V) where {K,V}
    value_ref = Ref{V}(value)
    update!(entry, value_ref)
    return nothing
end

@inline update_with_copy(entry::EntryHandleMut{K,V}, value_ref::Base.RefValue{V}) where {K,V} = update!(entry, value_ref)
@inline update_with_copy(entry::EntryHandleMut{K,V}, value::V) where {K,V} = update!(entry, value)

@inline Base.isvalid(obj::PortFactoryPubSub) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::Publisher) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::Subscriber) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::Sample) = obj.handle_ref[] != _IOX2_NULL
@inline Base.isvalid(obj::SampleMut) = obj.handle_ref[] != _IOX2_NULL
@inline Base.isvalid(obj::PortFactoryRequestResponse) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::Client) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::Server) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::RequestMut) = obj.handle_ref[] != _IOX2_NULL
@inline Base.isvalid(obj::PendingResponse) = obj.handle_ref[] != _IOX2_NULL
@inline Base.isvalid(obj::Response) = obj.handle_ref[] != _IOX2_NULL
@inline Base.isvalid(obj::ActiveRequest) = obj.handle_ref[] != _IOX2_NULL
@inline Base.isvalid(obj::ResponseMut) = obj.handle_ref[] != _IOX2_NULL
@inline Base.isvalid(obj::PortFactoryEvent) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::Notifier) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::Listener) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::PortFactoryBlackboard) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::Writer) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::Reader) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::EntryHandle) = obj.handle_ref[] != _IOX2_NULL
@inline Base.isvalid(obj::EntryHandleMut) = obj.handle_ref[] != _IOX2_NULL
@inline Base.isvalid(obj::EntryValueUninit) = obj.handle_ref[] != _IOX2_NULL

function Base.close(obj::PortFactoryPubSub)
    _finalize_port_factory_pub_sub(obj)
    return nothing
end

function Base.close(obj::Publisher)
    _finalize_publisher(obj)
    return nothing
end

function Base.close(obj::Subscriber)
    _finalize_subscriber(obj)
    return nothing
end

function Base.close(obj::Sample)
    _finalize_sample(obj)
    return nothing
end

function Base.close(obj::SampleMut)
    _finalize_sample_mut(obj)
    return nothing
end

function Base.close(obj::PortFactoryRequestResponse)
    _finalize_port_factory_request_response(obj)
    return nothing
end

function Base.close(obj::Client)
    _finalize_client(obj)
    return nothing
end

function Base.close(obj::Server)
    _finalize_server(obj)
    return nothing
end

function Base.close(obj::RequestMut)
    _finalize_request_mut(obj)
    return nothing
end

function Base.close(obj::PendingResponse)
    _finalize_pending_response(obj)
    return nothing
end

function Base.close(obj::Response)
    _finalize_response(obj)
    return nothing
end

function Base.close(obj::ActiveRequest)
    _finalize_active_request(obj)
    return nothing
end

function Base.close(obj::ResponseMut)
    _finalize_response_mut(obj)
    return nothing
end

Base.close(::PublishSubscribeHeaderRef) = nothing
Base.close(::RequestHeaderRef) = nothing
Base.close(::ResponseHeaderRef) = nothing

function Base.close(obj::PortFactoryEvent)
    _finalize_port_factory_event(obj)
    return nothing
end

function Base.close(obj::Notifier)
    _finalize_notifier(obj)
    return nothing
end

function Base.close(obj::Listener)
    _finalize_listener(obj)
    return nothing
end

function Base.close(obj::PortFactoryBlackboard)
    _finalize_port_factory_blackboard(obj)
    return nothing
end

function Base.close(obj::Writer)
    _finalize_writer(obj)
    return nothing
end

function Base.close(obj::Reader)
    _finalize_reader(obj)
    return nothing
end

function Base.close(obj::EntryHandle)
    _finalize_entry_handle(obj)
    return nothing
end

function Base.close(obj::EntryHandleMut)
    _finalize_entry_handle_mut(obj)
    return nothing
end

function Base.close(obj::EntryValueUninit)
    _finalize_entry_value_uninit(obj)
    return nothing
end
