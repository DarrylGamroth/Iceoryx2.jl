_attribute_key_view_alloc(buffer, attr) = @allocated Iceoryx2.key_view!(buffer, attr)
_attribute_value_view_alloc(buffer, attr) = @allocated Iceoryx2.value_view!(buffer, attr)
function _attribute_key_value_view_alloc(buffer, attrs, key, index)
    @allocated Iceoryx2.key_value_view!(buffer, attrs, key, index)
end

@testset "Attributes" begin
    verifier = Iceoryx2.AttributeVerifier()
    Iceoryx2.require!(verifier, "some_key", "some_value")
    attrs = Iceoryx2.attributes(verifier)
    @test Iceoryx2.number_of_attributes(attrs) == 1
    @test Iceoryx2.key(attrs[1]) == "some_key"
    @test Iceoryx2.value(attrs[1]) == "some_value"
    key_buffer = Vector{UInt8}(undef, Int(Iceoryx2.Iceoryx2FFI.IOX2_ATTRIBUTE_KEY_LENGTH) +
                                      1)
    value_buffer = Vector{UInt8}(undef, Int(Iceoryx2.Iceoryx2FFI.IOX2_ATTRIBUTE_VALUE_LENGTH) +
                                        1)
    @test String(Iceoryx2.key_view!(key_buffer, attrs[1])) == "some_key"
    @test String(Iceoryx2.value_view!(value_buffer, attrs[1])) == "some_value"
    @test _attribute_key_view_alloc(key_buffer, attrs[1]) == 0
    @test _attribute_value_view_alloc(value_buffer, attrs[1]) == 0
    @test_throws ArgumentError Iceoryx2.key_view!(Vector{UInt8}(undef, 1), attrs[1])

    verifier_keys = Iceoryx2.AttributeVerifier()
    Iceoryx2.require_key!(verifier_keys, "key_1")
    Iceoryx2.require_key!(verifier_keys, "key_2")
    keys = Iceoryx2.keys(verifier_keys)
    @test length(keys) == 2
    @test Set(keys) == Set(["key_1", "key_2"])

    compatible = Iceoryx2.AttributeVerifier()
    Iceoryx2.require!(compatible, "k", "v")
    compatible_attrs = Iceoryx2.attributes(compatible)
    @test Iceoryx2.verify_requirements(compatible, compatible_attrs) === nothing

    incompatible = Iceoryx2.AttributeVerifier()
    Iceoryx2.require!(incompatible, "k", "v")
    Iceoryx2.require_key!(incompatible, "missing")
    incompatible_attrs = Iceoryx2.attributes(compatible)
    missing = Iceoryx2.verify_requirements(incompatible, incompatible_attrs)
    @test missing == "missing"

    specifier = Iceoryx2.AttributeSpecifier()
    Iceoryx2.define!(specifier, "key_a", "value_a")
    Iceoryx2.define!(specifier, "key_b", "value_b")
    spec_attrs = Iceoryx2.attributes(specifier)
    @test Iceoryx2.number_of_attributes(spec_attrs) == 2
    @test length(spec_attrs) == Iceoryx2.number_of_attributes(spec_attrs)
    @test firstindex(spec_attrs) == 1
    @test lastindex(spec_attrs) == length(spec_attrs)
    @test eltype(spec_attrs) == Iceoryx2.AttributeRef
    @test eltype(typeof(spec_attrs)) == Iceoryx2.AttributeRef
    @test collect(spec_attrs) isa Vector{Iceoryx2.AttributeRef}
    @test length(collect(spec_attrs)) == length(spec_attrs)
    @test Set([Iceoryx2.key(spec_attrs[1]), Iceoryx2.key(spec_attrs[2])]) ==
          Set(["key_a", "key_b"])
    @test Set([Iceoryx2.value(spec_attrs[1]), Iceoryx2.value(spec_attrs[2])]) ==
          Set(["value_a", "value_b"])

    Iceoryx2.define!(specifier, "multi", "v1")
    Iceoryx2.define!(specifier, "multi", "v2")
    spec_attrs = Iceoryx2.attributes(specifier)
    @test Iceoryx2.number_of_key_values(spec_attrs, "multi") == 2
    @test Set(Iceoryx2.attribute_values(spec_attrs, "multi")) == Set(["v1", "v2"])
    @test_throws ErrorException Iceoryx2.each_attribute_value(spec_attrs, "multi") do _
        error("attribute callback failure")
    end
    v1 = Iceoryx2.key_value(spec_attrs, "multi", 1)
    v2 = Iceoryx2.key_value(spec_attrs, "multi", 2)
    @test v1 !== nothing
    @test v2 !== nothing
    @test Set([v1, v2]) == Set(["v1", "v2"])
    @test Iceoryx2.key_value(spec_attrs, "multi", 3) === nothing
    kv1_found, kv1 = Iceoryx2.key_value_view!(value_buffer, spec_attrs, "multi", 1)
    @test kv1_found
    kv1_str = String(kv1)
    kv2_found, kv2 = Iceoryx2.key_value_view!(value_buffer, spec_attrs, "multi", 2)
    @test kv2_found
    kv2_str = String(kv2)
    @test _attribute_key_value_view_alloc(value_buffer, spec_attrs, "multi", 1) == 0
    @test Set([kv1_str, kv2_str]) == Set(["v1", "v2"])
    kv3_found, kv3 = Iceoryx2.key_value_view!(value_buffer, spec_attrs, "multi", 3)
    @test !kv3_found
    @test isempty(kv3)

    owned = Iceoryx2.to_owned(spec_attrs)
    @test Iceoryx2.number_of_attributes(owned) == Iceoryx2.number_of_attributes(spec_attrs)
end
