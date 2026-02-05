"""
    PortFactoryBlackboard{S,K}

Factory for readers and writers bound to a blackboard service.
"""
mutable struct PortFactoryBlackboard{S,K}
    handle::Iceoryx2FFI.iox2_port_factory_blackboard_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_blackboard_t}
    keepalive::Node{S}
    values::Vector{Any}
    function PortFactoryBlackboard{S,K}(handle, storage, keepalive, values) where {S,K}
        obj = new{S,K}(handle, storage, keepalive, values)
        finalizer(Base.close, obj)
        return obj
    end
end

function Base.close(factory::PortFactoryBlackboard)
    if factory.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_port_factory_blackboard_drop(factory.handle)
        factory.handle = _IOX2_NULL
    end
    factory.storage = nothing
    empty!(factory.values)
    return nothing
end

"""
    create(builder::BlackboardCreatorBuilder) -> PortFactoryBlackboard

Create a new blackboard service.
"""
function create(builder::BlackboardCreatorBuilder{S,K}) where {S,K}
    _require_valid(builder.handle, "blackboard creator")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_blackboard_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_blackboard_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_blackboard_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_blackboard_create_error_e)
    values = builder.values
    builder.values = Any[]
    close(builder)
    return PortFactoryBlackboard{S,K}(handle_ref[], storage, builder.keepalive, values)
end

function create(builder::BlackboardCreatorBuilder{S,K}, specifier::AttributeSpecifier) where {S,K}
    _require_valid(builder.handle, "blackboard creator")
    _require_valid(unsafe_handle(specifier), "attribute specifier")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_blackboard_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_blackboard_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_blackboard_create_with_attributes(
        builder.handle,
        Ref{Iceoryx2FFI.iox2_attribute_specifier_h}(unsafe_handle(specifier)),
        storage,
        handle_ref,
    )
    check_ok(ret, Iceoryx2FFI.iox2_blackboard_create_error_e)
    values = builder.values
    builder.values = Any[]
    close(builder)
    return PortFactoryBlackboard{S,K}(handle_ref[], storage, builder.keepalive, values)
end

function create(f::Function, builder::BlackboardCreatorBuilder{S,K}) where {S,K}
    factory = create(builder)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function create(f::Function, builder::BlackboardCreatorBuilder{S,K}, specifier::AttributeSpecifier) where {S,K}
    factory = create(builder, specifier)
    try
        return f(factory)
    finally
        close(factory)
    end
end

"""
    open(builder::BlackboardOpenerBuilder) -> PortFactoryBlackboard

Open an existing blackboard service.
"""
function open(builder::BlackboardOpenerBuilder{S,K}) where {S,K}
    _require_valid(builder.handle, "blackboard opener")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_blackboard_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_blackboard_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_blackboard_open(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_blackboard_open_error_e)
    close(builder)
    return PortFactoryBlackboard{S,K}(handle_ref[], storage, builder.keepalive, Any[])
end

function open(builder::BlackboardOpenerBuilder{S,K}, verifier::AttributeVerifier) where {S,K}
    _require_valid(builder.handle, "blackboard opener")
    _require_valid(unsafe_handle(verifier), "attribute verifier")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_blackboard_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_port_factory_blackboard_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_service_builder_blackboard_open_with_attributes(
        builder.handle,
        Ref{Iceoryx2FFI.iox2_attribute_verifier_h}(unsafe_handle(verifier)),
        storage,
        handle_ref,
    )
    check_ok(ret, Iceoryx2FFI.iox2_blackboard_open_error_e)
    close(builder)
    return PortFactoryBlackboard{S,K}(handle_ref[], storage, builder.keepalive, Any[])
end

function open(f::Function, builder::BlackboardOpenerBuilder{S,K}) where {S,K}
    factory = open(builder)
    try
        return f(factory)
    finally
        close(factory)
    end
end

function open(f::Function, builder::BlackboardOpenerBuilder{S,K}, verifier::AttributeVerifier) where {S,K}
    factory = open(builder, verifier)
    try
        return f(factory)
    finally
        close(factory)
    end
end

open_with_attributes(builder::BlackboardOpenerBuilder{S,K}, verifier::AttributeVerifier) where {S,K} = open(builder, verifier)
open_with_attributes(f::Function, builder::BlackboardOpenerBuilder{S,K}, verifier::AttributeVerifier) where {S,K} = open(f, builder, verifier)
create_with_attributes(builder::BlackboardCreatorBuilder{S,K}, specifier::AttributeSpecifier) where {S,K} = create(builder, specifier)
create_with_attributes(f::Function, builder::BlackboardCreatorBuilder{S,K}, specifier::AttributeSpecifier) where {S,K} = create(f, builder, specifier)

function _set_key_type!(builder::BlackboardCreatorBuilder{S,K}, ::Type{K}) where {S,K}
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

function _set_key_type!(builder::BlackboardOpenerBuilder{S,K}, ::Type{K}) where {S,K}
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

function _key_eq_comparison!(builder::BlackboardCreatorBuilder{S,K}) where {S,K}
    _require_valid(builder.handle, "blackboard creator")
    Iceoryx2FFI.iox2_service_builder_blackboard_creator_set_key_eq_comparison_function(
        Ref{Iceoryx2FFI.iox2_service_builder_blackboard_creator_h}(builder.handle),
        _blackboard_key_eq_cmp_cfunction(K),
    )
    return builder
end

### builder tuning setters generated in src/generated/wrappers.jl

"""
    add!(builder::BlackboardCreatorBuilder, key, value)

Add a key/value entry to a blackboard being created.
"""
function add!(builder::BlackboardCreatorBuilder{S,K}, key::K, value::V) where {S,K,V}
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

function add_with_default!(builder::BlackboardCreatorBuilder{S,K}, key::K, ::Type{V}) where {S,K,V}
    return add!(builder, key, zero(V))
end

"""
    EntryWriterBuilder{S,K}

Builder for `EntryWriter{S,K}`.
"""
mutable struct EntryWriterBuilder{S,K}
    handle::Iceoryx2FFI.iox2_port_factory_writer_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_writer_builder_t}
    keepalive::PortFactoryBlackboard{S,K}
    function EntryWriterBuilder{S,K}(handle, storage, keepalive) where {S,K}
        obj = new{S,K}(handle, storage, keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

function Base.close(builder::EntryWriterBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

"""
    writer_builder(factory::PortFactoryBlackboard) -> EntryWriterBuilder

Create a writer builder from a blackboard factory.
"""
function writer_builder(factory::PortFactoryBlackboard{S,K}) where {S,K}
    _require_valid(factory.handle, "blackboard port factory")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_writer_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_blackboard_writer_builder(Ref{Iceoryx2FFI.iox2_port_factory_blackboard_h}(factory.handle), storage)
    return EntryWriterBuilder{S,K}(handle, storage, factory)
end

"""
    EntryReaderBuilder{S,K}

Builder for `EntryReader{S,K}`.
"""
mutable struct EntryReaderBuilder{S,K}
    handle::Iceoryx2FFI.iox2_port_factory_reader_builder_h
    storage::_StorageRef{Iceoryx2FFI.iox2_port_factory_reader_builder_t}
    keepalive::PortFactoryBlackboard{S,K}
    function EntryReaderBuilder{S,K}(handle, storage, keepalive) where {S,K}
        obj = new{S,K}(handle, storage, keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

function Base.close(builder::EntryReaderBuilder)
    builder.handle = _IOX2_NULL
    builder.storage = nothing
    return nothing
end

"""
    reader_builder(factory::PortFactoryBlackboard) -> EntryReaderBuilder

Create a reader builder from a blackboard factory.
"""
function reader_builder(factory::PortFactoryBlackboard{S,K}) where {S,K}
    _require_valid(factory.handle, "blackboard port factory")
    storage = Ref{Iceoryx2FFI.iox2_port_factory_reader_builder_t}()
    handle = Iceoryx2FFI.iox2_port_factory_blackboard_reader_builder(Ref{Iceoryx2FFI.iox2_port_factory_blackboard_h}(factory.handle), storage)
    return EntryReaderBuilder{S,K}(handle, storage, factory)
end

"""
    EntryWriter{S,K}

Entry writer for blackboard entries.
"""
mutable struct EntryWriter{S,K}
    handle::Iceoryx2FFI.iox2_writer_h
    storage::_StorageRef{Iceoryx2FFI.iox2_writer_t}
    keepalive::PortFactoryBlackboard{S,K}
    function EntryWriter{S,K}(handle, storage, keepalive) where {S,K}
        obj = new{S,K}(handle, storage, keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

function Base.close(writer::EntryWriter)
    if writer.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_writer_drop(writer.handle)
        writer.handle = _IOX2_NULL
    end
    writer.storage = nothing
    return nothing
end

"""
    create(builder::EntryWriterBuilder) -> EntryWriter

Create a writer and consume the builder.
"""
function create(builder::EntryWriterBuilder{S,K}) where {S,K}
    _require_valid(builder.handle, "writer builder")
    storage = Ref{Iceoryx2FFI.iox2_writer_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_writer_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_writer_builder_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_writer_create_error_e)
    close(builder)
    return EntryWriter{S,K}(handle_ref[], storage, builder.keepalive)
end

"""
    create(f::Function, builder::EntryWriterBuilder)

Create a writer, call `f(writer)`, and close it in a `finally` block.
"""
function create(f::Function, builder::EntryWriterBuilder{S,K}) where {S,K}
    writer = create(builder)
    try
        return f(writer)
    finally
        close(writer)
    end
end

"""
    EntryReader{S,K}

Entry reader for blackboard entries.
"""
mutable struct EntryReader{S,K}
    handle::Iceoryx2FFI.iox2_reader_h
    storage::_StorageRef{Iceoryx2FFI.iox2_reader_t}
    keepalive::PortFactoryBlackboard{S,K}
    function EntryReader{S,K}(handle, storage, keepalive) where {S,K}
        obj = new{S,K}(handle, storage, keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

function Base.close(reader::EntryReader)
    if reader.handle != _IOX2_NULL
        Iceoryx2FFI.iox2_reader_drop(reader.handle)
        reader.handle = _IOX2_NULL
    end
    reader.storage = nothing
    return nothing
end

"""
    create(builder::EntryReaderBuilder) -> EntryReader

Create a reader and consume the builder.
"""
function create(builder::EntryReaderBuilder{S,K}) where {S,K}
    _require_valid(builder.handle, "reader builder")
    storage = Ref{Iceoryx2FFI.iox2_reader_t}()
    handle_ref = Ref{Iceoryx2FFI.iox2_reader_h}(_IOX2_NULL)
    ret = Iceoryx2FFI.iox2_port_factory_reader_builder_create(builder.handle, storage, handle_ref)
    check_ok(ret, Iceoryx2FFI.iox2_reader_create_error_e)
    close(builder)
    return EntryReader{S,K}(handle_ref[], storage, builder.keepalive)
end

"""
    create(f::Function, builder::EntryReaderBuilder)

Create a reader, call `f(reader)`, and close it in a `finally` block.
"""
function create(f::Function, builder::EntryReaderBuilder{S,K}) where {S,K}
    reader = create(builder)
    try
        return f(reader)
    finally
        close(reader)
    end
end

"""
    EntryHandle{S,K,V}

Handle for reading a specific key/value entry.
"""
mutable struct EntryHandle{S,K,V}
    handle_ref::Base.RefValue{Iceoryx2FFI.iox2_entry_handle_h}
    storage::Base.RefValue{Iceoryx2FFI.iox2_entry_handle_t}
    keepalive::EntryReader{S,K}
    function EntryHandle{S,K,V}(handle_ref, storage, keepalive) where {S,K,V}
        _require_isbits(K)
        _require_isbits(V)
        obj = new{S,K,V}(handle_ref, storage, keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

function EntryHandle{S,K,V}(reader::EntryReader{S,K}) where {S,K,V}
    return EntryHandle{S,K,V}(Ref{Iceoryx2FFI.iox2_entry_handle_h}(_IOX2_NULL), Ref{Iceoryx2FFI.iox2_entry_handle_t}(), reader)
end

EntryHandle(reader::EntryReader{S,K}, ::Type{V}) where {S,K,V} = EntryHandle{S,K,V}(reader)

function Base.close(entry::EntryHandle)
    if entry.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_entry_handle_drop(entry.handle_ref[])
        entry.handle_ref[] = _IOX2_NULL
    end
    return nothing
end

"""
    EntryHandleMut{S,K,V}

Handle for updating a specific key/value entry.
"""
mutable struct EntryHandleMut{S,K,V}
    handle_ref::Base.RefValue{Iceoryx2FFI.iox2_entry_handle_mut_h}
    storage::Base.RefValue{Iceoryx2FFI.iox2_entry_handle_mut_t}
    keepalive::EntryWriter{S,K}
    function EntryHandleMut{S,K,V}(handle_ref, storage, keepalive) where {S,K,V}
        _require_isbits(K)
        _require_isbits(V)
        obj = new{S,K,V}(handle_ref, storage, keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

function EntryHandleMut{S,K,V}(writer::EntryWriter{S,K}) where {S,K,V}
    return EntryHandleMut{S,K,V}(Ref{Iceoryx2FFI.iox2_entry_handle_mut_h}(_IOX2_NULL), Ref{Iceoryx2FFI.iox2_entry_handle_mut_t}(), writer)
end

EntryHandleMut(writer::EntryWriter{S,K}, ::Type{V}) where {S,K,V} = EntryHandleMut{S,K,V}(writer)

function Base.close(entry::EntryHandleMut)
    if entry.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_entry_handle_mut_drop(entry.handle_ref[])
        entry.handle_ref[] = _IOX2_NULL
    end
    return nothing
end

"""
    EntryValueUninit{S,K,V}

Temporary value slot for uninitialized blackboard updates.
"""
mutable struct EntryValueUninit{S,K,V}
    handle_ref::Base.RefValue{Iceoryx2FFI.iox2_entry_value_uninit_h}
    storage::Base.RefValue{Iceoryx2FFI.iox2_entry_value_uninit_t}
    keepalive::EntryWriter{S,K}
    function EntryValueUninit{S,K,V}(handle_ref, storage, keepalive) where {S,K,V}
        _require_isbits(K)
        _require_isbits(V)
        obj = new{S,K,V}(handle_ref, storage, keepalive)
        finalizer(Base.close, obj)
        return obj
    end
end

function EntryValueUninit{S,K,V}(writer::EntryWriter{S,K}) where {S,K,V}
    return EntryValueUninit{S,K,V}(Ref{Iceoryx2FFI.iox2_entry_value_uninit_h}(_IOX2_NULL), Ref{Iceoryx2FFI.iox2_entry_value_uninit_t}(), writer)
end

EntryValueUninit(writer::EntryWriter{S,K}, ::Type{V}) where {S,K,V} = EntryValueUninit{S,K,V}(writer)
EntryValueUninit(entry::EntryHandleMut{S,K,V}) where {S,K,V} = EntryValueUninit{S,K,V}(entry.keepalive)

@inline _slice_mutable(::Type{<:EntryValueUninit}) = true

function Base.close(value::EntryValueUninit)
    if value.handle_ref[] != _IOX2_NULL
        Iceoryx2FFI.iox2_entry_value_uninit_drop(value.handle_ref[])
        value.handle_ref[] = _IOX2_NULL
    end
    return nothing
end

"""
    loan_uninit!(entry, value)

Loan an uninitialized value slot for the entry.
"""
function loan_uninit!(entry::EntryHandleMut{S,K,V}, value::EntryValueUninit{S,K,V}) where {S,K,V}
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

function loan_uninit!(f::Function, entry::EntryHandleMut{S,K,V}, value::EntryValueUninit{S,K,V}) where {S,K,V}
    loan_uninit!(entry, value)
    try
        return f(value)
    finally
        isvalid(value) && close(value)
    end
end

"""
    unsafe_value_mut_ptr(value::EntryValueUninit) -> Ptr

Return a raw pointer to the uninitialized value slot (unsafe).
"""
@inline function unsafe_value_mut_ptr(value::EntryValueUninit{S,K,V}) where {S,K,V}
    ptr_ref = Ref{Ptr{Cvoid}}()
    Iceoryx2FFI.iox2_entry_value_uninit_value_mut(
        value.handle_ref,
        ptr_ref,
    )
    return Ptr{V}(ptr_ref[])
end

"""
    value!(value::EntryValueUninit, data)

Write data into the uninitialized value slot.
"""
@inline function value!(value::EntryValueUninit{S,K,V}, data::V) where {S,K,V}
    ptr = unsafe_value_mut_ptr(value)
    unsafe_store!(ptr, data)
    return value
end

"""
    update!(value, entry) -> EntryHandleMut

Commit an uninitialized value slot into the blackboard entry.
"""
function update!(value::EntryValueUninit{S,K,V}, entry::EntryHandleMut{S,K,V}) where {S,K,V}
    _require_inactive(entry, "entry handle mut")
    entry.handle_ref[] = _IOX2_NULL
    Iceoryx2FFI.iox2_entry_value_uninit_update(value.handle_ref[], entry.storage, entry.handle_ref)
    value.handle_ref[] = _IOX2_NULL
    entry.keepalive = value.keepalive
    return entry
end

"""
    discard!(value, entry) -> EntryHandleMut

Discard an uninitialized value slot without updating the entry.
"""
function discard!(value::EntryValueUninit{S,K,V}, entry::EntryHandleMut{S,K,V}) where {S,K,V}
    _require_inactive(entry, "entry handle mut")
    entry.handle_ref[] = _IOX2_NULL
    Iceoryx2FFI.iox2_entry_value_uninit_discard(value.handle_ref[], entry.storage, entry.handle_ref)
    value.handle_ref[] = _IOX2_NULL
    entry.keepalive = value.keepalive
    return entry
end

"""
    entry!(reader, entry, key) -> EntryHandle

Acquire a reader entry handle for a given key.
"""
function entry!(reader::EntryReader{S,K}, entry::EntryHandle{S,K,V}, key::K) where {S,K,V}
    _require_valid(reader.handle, "reader")
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

function entry!(f::Function, reader::EntryReader{S,K}, entry::EntryHandle{S,K,V}, key::K) where {S,K,V}
    entry!(reader, entry, key)
    try
        return f(entry)
    finally
        close(entry)
    end
end

function try_entry!(reader::EntryReader{S,K}, entry::EntryHandle{S,K,V}, key::K) where {S,K,V}
    _require_valid(reader.handle, "reader")
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

function try_entry!(f::Function, reader::EntryReader{S,K}, entry::EntryHandle{S,K,V}, key::K) where {S,K,V}
    try_entry!(reader, entry, key) || return nothing
    try
        return f(entry)
    finally
        close(entry)
    end
end

"""
    entry!(writer, entry, key) -> EntryHandleMut

Acquire a writer entry handle for a given key.
"""
function entry!(writer::EntryWriter{S,K}, entry::EntryHandleMut{S,K,V}, key::K) where {S,K,V}
    _require_valid(writer.handle, "writer")
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

function entry!(f::Function, writer::EntryWriter{S,K}, entry::EntryHandleMut{S,K,V}, key::K) where {S,K,V}
    entry!(writer, entry, key)
    try
        return f(entry)
    finally
        close(entry)
    end
end

function try_entry!(writer::EntryWriter{S,K}, entry::EntryHandleMut{S,K,V}, key::K) where {S,K,V}
    _require_valid(writer.handle, "writer")
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

function try_entry!(f::Function, writer::EntryWriter{S,K}, entry::EntryHandleMut{S,K,V}, key::K) where {S,K,V}
    try_entry!(writer, entry, key) || return nothing
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

function get!(entry::EntryHandle{S,K,V}, value_ref::Base.RefValue{V}, generation_ref::Base.RefValue{UInt64}) where {S,K,V}
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

function get!(entry::EntryHandle{S,K,V}, value_ref::Base.RefValue{V}) where {S,K,V}
    generation_ref = Ref{UInt64}(0)
    get!(entry, value_ref, generation_ref)
    return generation_ref[]
end

"""
    get(entry::EntryHandle) -> (value, generation)

Fetch the current value and generation for an entry.
"""
function get(entry::EntryHandle{S,K,V}) where {S,K,V}
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

"""
    update!(entry::EntryHandleMut, value)

Update a blackboard entry with the provided value.
"""
function update!(entry::EntryHandleMut{S,K,V}, value_ref::Base.RefValue{V}) where {S,K,V}
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

function update!(entry::EntryHandleMut{S,K,V}, value::V) where {S,K,V}
    value_ref = Ref{V}(value)
    update!(entry, value_ref)
    return nothing
end

@inline update_with_copy(entry::EntryHandleMut{S,K,V}, value_ref::Base.RefValue{V}) where {S,K,V} = update!(entry, value_ref)
@inline update_with_copy(entry::EntryHandleMut{S,K,V}, value::V) where {S,K,V} = update!(entry, value)

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
@inline Base.isvalid(obj::EntryWriter) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::EntryReader) = obj.handle != _IOX2_NULL
@inline Base.isvalid(obj::EntryHandle) = obj.handle_ref[] != _IOX2_NULL
@inline Base.isvalid(obj::EntryHandleMut) = obj.handle_ref[] != _IOX2_NULL
@inline Base.isvalid(obj::EntryValueUninit) = obj.handle_ref[] != _IOX2_NULL
