@testset "WaitsetNotification" begin
    node_builder = Iceoryx2.NodeBuilder()
    Iceoryx2.name!(node_builder, unique_node_name())
    node = Iceoryx2.create(node_builder, Iceoryx2.ServiceType.IPC)

    service_name = unique_service_name()
    event_builder = Iceoryx2.event(Iceoryx2.service_builder(node, service_name))
    factory = Iceoryx2.open_or_create(event_builder)
    notifier = Iceoryx2.create(Iceoryx2.notifier_builder(factory))
    listener = Iceoryx2.create(Iceoryx2.listener_builder(factory))

    waitset = Iceoryx2.create(Iceoryx2.WaitsetBuilder(Iceoryx2.ServiceType.IPC))
    guard = Iceoryx2.attach_notification(waitset, Iceoryx2.file_descriptor(listener))

    Iceoryx2.notify!(notifier)

    called = Ref(false)
    Iceoryx2.wait_and_process_once(waitset, 0, 200_000_000) do attachment
        if Iceoryx2.has_event_from(attachment, guard)
            called[] = true
        end
        return :stop
    end

    @test called[]

    close(guard)
    close(waitset)
    close(listener)
    close(notifier)
    close(factory)
    close(node)
end
