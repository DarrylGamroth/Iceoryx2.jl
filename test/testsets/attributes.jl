@testset "Attributes" begin
    verifier = Iceoryx2.AttributeVerifier()
    Iceoryx2.require!(verifier, "some_key", "some_value")
    attrs = Iceoryx2.attributes(verifier)
    @test Iceoryx2.number_of_attributes(attrs) == 1
    @test Iceoryx2.key(attrs[1]) == "some_key"
    @test Iceoryx2.value(attrs[1]) == "some_value"

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
    @test Set([Iceoryx2.key(spec_attrs[1]), Iceoryx2.key(spec_attrs[2])]) == Set(["key_a", "key_b"])
    @test Set([Iceoryx2.value(spec_attrs[1]), Iceoryx2.value(spec_attrs[2])]) == Set(["value_a", "value_b"])

    Iceoryx2.define!(specifier, "multi", "v1")
    Iceoryx2.define!(specifier, "multi", "v2")
    spec_attrs = Iceoryx2.attributes(specifier)
    @test Iceoryx2.number_of_key_values(spec_attrs, "multi") == 2
    v1 = Iceoryx2.key_value(spec_attrs, "multi", 1)
    v2 = Iceoryx2.key_value(spec_attrs, "multi", 2)
    @test v1 !== nothing
    @test v2 !== nothing
    @test Set([v1, v2]) == Set(["v1", "v2"])
    @test Iceoryx2.key_value(spec_attrs, "multi", 3) === nothing

    owned = Iceoryx2.to_owned(spec_attrs)
    @test Iceoryx2.number_of_attributes(owned) == Iceoryx2.number_of_attributes(spec_attrs)
end
