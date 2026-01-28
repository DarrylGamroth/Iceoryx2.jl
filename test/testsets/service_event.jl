@testset "ServiceEvent" begin
    service_name = unique_service_name()
    @test !Iceoryx2.service_does_exist(service_name; service_type=:ipc, messaging_pattern=:event)

    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, unique_node_name())
    node = Iceoryx2.create(node_builder; service_type=:ipc)

    svc_builder = Iceoryx2.service_builder(node, service_name)
    event_builder = Iceoryx2.event(svc_builder)
    Iceoryx2.deadline!(event_builder, 1, 0)
    Iceoryx2.disable_deadline!(event_builder)
    Iceoryx2.notifier_created_event!(event_builder, 1)
    Iceoryx2.disable_notifier_created_event!(event_builder)
    Iceoryx2.notifier_dead_event!(event_builder, 1)
    Iceoryx2.disable_notifier_dead_event!(event_builder)
    Iceoryx2.notifier_dropped_event!(event_builder, 1)
    Iceoryx2.disable_notifier_dropped_event!(event_builder)
    factory = Iceoryx2.open_or_create(event_builder)

    @test Iceoryx2.service_does_exist(service_name; service_type=:ipc, messaging_pattern=:event)
    @test string(Iceoryx2.service_name(factory)) == service_name
    @test !isempty(Iceoryx2.service_id(factory))
    @test Iceoryx2.static_config(factory) isa Iceoryx2.StaticConfigEvent
    @test Iceoryx2.number_of_attributes(Iceoryx2.attributes(factory)) >= 0

    count = Ref(0)
    Iceoryx2.list_nodes(factory) do _, _, _, _, _
        count[] += 1
        return true
    end
    @test count[] >= 1

    notifier = Iceoryx2.create(Iceoryx2.notifier_builder(factory))
    listener = Iceoryx2.create(Iceoryx2.listener_builder(factory))

    @test Iceoryx2.number_of_notifiers(factory) >= 1
    @test Iceoryx2.number_of_listeners(factory) >= 1
    @test Iceoryx2.notify!(notifier) >= 0
    deadline = Iceoryx2.deadline(notifier)
    @test deadline === nothing || deadline isa Tuple{UInt64, UInt32}

    notifier_seen = Ref(false)
    Iceoryx2.list_notifiers(factory) do notifier_details
        notifier_seen[] = true
        nid = Iceoryx2.notifier_id(notifier_details)
        @test isvalid(nid)
        close(nid)
        @test isvalid(Iceoryx2.node_id(notifier_details))
        return true
    end
    @test notifier_seen[]

    listener_seen = Ref(false)
    Iceoryx2.list_listeners(factory) do listener_details
        listener_seen[] = true
        lid = Iceoryx2.listener_id(listener_details)
        @test isvalid(lid)
        close(lid)
        @test isvalid(Iceoryx2.node_id(listener_details))
        return true
    end
    @test listener_seen[]

    close(listener)
    close(notifier)
    close(factory)
    close(node)
end

@testset "ServiceEventAttributes" begin
    service_name = unique_service_name()

    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, unique_node_name())
    node = Iceoryx2.create(node_builder; service_type=:ipc)

    specifier = Iceoryx2.AttributeSpecifier()
    Iceoryx2.define!(specifier, "role", "primary")
    builder_create = Iceoryx2.event(Iceoryx2.service_builder(node, service_name))
    factory_create = Iceoryx2.create(builder_create, specifier)
    close(factory_create)
    close(specifier)

    verifier = Iceoryx2.AttributeVerifier()
    Iceoryx2.require!(verifier, "role", "primary")
    builder_open = Iceoryx2.event(Iceoryx2.service_builder(node, service_name))
    factory_open = Iceoryx2.open(builder_open, verifier)
    close(factory_open)
    close(verifier)
    close(node)
end
