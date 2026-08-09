# Docstrings for error types and enums (generated in src/generated/errors.jl).

"""
    check_ok(code, ::Type{T})

Validate a C error code and throw the corresponding `*Error` exception on
failure. `T` is the C enum type for the error category.

Safe exceptions expose `err.code::Symbol` and `err.raw_code::UInt32`. The raw
C enum object is retained only inside the generated FFI/error-checking boundary.
"""
check_ok

"""
    AttributeDefinitionError

Error thrown when defining attributes fails.
"""
AttributeDefinitionError

"""
    AttributeVerificationError

Error thrown when attribute verification fails.
"""
AttributeVerificationError

"""
    BlackboardCreateError

Error thrown when blackboard creation fails.
"""
BlackboardCreateError

"""
    BlackboardOpenError

Error thrown when opening a blackboard fails.
"""
BlackboardOpenError

"""
    ClientCreateError

Error thrown when creating a client fails.
"""
ClientCreateError

"""
    ConfigCreationError

Error thrown when creating a config fails.
"""
ConfigCreationError

"""
    ConnectionFailure

Error thrown when a live port connection operation fails.
"""
ConnectionFailure

"""
    EntryHandleError

Error thrown when acquiring a reader entry fails.
"""
EntryHandleError

"""
    EntryHandleMutError

Error thrown when acquiring a writer entry fails.
"""
EntryHandleMutError

"""
    EventOpenOrCreateError

Error thrown when opening or creating an event service fails.
"""
EventOpenOrCreateError

"""
    ListenerCreateError

Error thrown when creating a listener fails.
"""
ListenerCreateError

"""
    ListenerWaitError

Error thrown when waiting on a listener fails.
"""
ListenerWaitError

"""
    LoanError

Error thrown when a loan operation fails.
"""
LoanError

"""
    NodeCleanupFailure

Error thrown when stale node resources cannot be cleaned up.
"""
NodeCleanupFailure

"""
    NodeCreationFailure

Error thrown when node creation fails.
"""
NodeCreationFailure

"""
    NodeListFailure

Error thrown when node discovery fails.
"""
NodeListFailure

"""
    NodeWaitFailure

Error thrown when a node wait operation fails.
"""
NodeWaitFailure

"""
    NotifierCreateError

Error thrown when creating a notifier fails.
"""
NotifierCreateError

"""
    NotifierNotifyError

Error thrown when notifying fails.
"""
NotifierNotifyError

"""
    PubSubOpenOrCreateError

Error thrown when opening or creating a pub/sub service fails.
"""
PubSubOpenOrCreateError

"""
    PublisherCreateError

Error thrown when creating a publisher fails.
"""
PublisherCreateError

"""
    ReaderCreateError

Error thrown when creating a reader fails.
"""
ReaderCreateError

"""
    ReceiveError

Error thrown when receiving fails.
"""
ReceiveError

"""
    RequestResponseOpenOrCreateError

Error thrown when opening or creating a request/response service fails.
"""
RequestResponseOpenOrCreateError

"""
    RequestSendError

Error thrown when sending a request fails.
"""
RequestSendError

"""
    SemanticStringError

Error thrown when semantic string validation fails.
"""
SemanticStringError

"""
    SendError

Error thrown when sending a sample fails.
"""
SendError

"""
    ServerCreateError

Error thrown when creating a server fails.
"""
ServerCreateError

"""
    ServiceDetailsError

Error thrown when fetching service details fails.
"""
ServiceDetailsError

"""
    ServiceListError

Error thrown when listing services fails.
"""
ServiceListError

"""
    ServiceRemoveError

Error thrown when force-removing a stale service fails.
"""
ServiceRemoveError

"""
    SubscriberCreateError

Error thrown when creating a subscriber fails.
"""
SubscriberCreateError

"""
    TypeDetailError

Error thrown when setting type details fails.
"""
TypeDetailError

"""
    WaitSetAttachmentError

Error thrown when attaching to a WaitSet fails.
"""
WaitSetAttachmentError

"""
    WaitSetCreateError

Error thrown when creating a WaitSet fails.
"""
WaitSetCreateError

"""
    WaitSetRunError

Error thrown when running a WaitSet fails.
"""
WaitSetRunError

"""
    WriterCreateError

Error thrown when creating a writer fails.
"""
WriterCreateError

"""
    Iceoryx2FFI.iox2_attribute_definition_error_e

C error enum for attribute definition.
"""
Iceoryx2FFI.iox2_attribute_definition_error_e

"""
    Iceoryx2FFI.iox2_attribute_verification_error_e

C error enum for attribute verification.
"""
Iceoryx2FFI.iox2_attribute_verification_error_e

"""
    Iceoryx2FFI.iox2_blackboard_create_error_e

C error enum for blackboard creation.
"""
Iceoryx2FFI.iox2_blackboard_create_error_e

"""
    Iceoryx2FFI.iox2_blackboard_open_error_e

C error enum for blackboard open.
"""
Iceoryx2FFI.iox2_blackboard_open_error_e

"""
    Iceoryx2FFI.iox2_client_create_error_e

C error enum for client creation.
"""
Iceoryx2FFI.iox2_client_create_error_e

"""
    Iceoryx2FFI.iox2_config_creation_error_e

C error enum for config creation.
"""
Iceoryx2FFI.iox2_config_creation_error_e

"""
    Iceoryx2FFI.iox2_connection_failure_e

C error enum for connection operations.
"""
Iceoryx2FFI.iox2_connection_failure_e

"""
    Iceoryx2FFI.iox2_entry_handle_error_e

C error enum for reader entry errors.
"""
Iceoryx2FFI.iox2_entry_handle_error_e

"""
    Iceoryx2FFI.iox2_entry_handle_mut_error_e

C error enum for writer entry errors.
"""
Iceoryx2FFI.iox2_entry_handle_mut_error_e

"""
    Iceoryx2FFI.iox2_event_open_or_create_error_e

C error enum for event open/create.
"""
Iceoryx2FFI.iox2_event_open_or_create_error_e

"""
    Iceoryx2FFI.iox2_listener_create_error_e

C error enum for listener creation.
"""
Iceoryx2FFI.iox2_listener_create_error_e

"""
    Iceoryx2FFI.iox2_listener_wait_error_e

C error enum for listener wait.
"""
Iceoryx2FFI.iox2_listener_wait_error_e

"""
    Iceoryx2FFI.iox2_loan_error_e

C error enum for loan operations.
"""
Iceoryx2FFI.iox2_loan_error_e

"""
    Iceoryx2FFI.iox2_node_cleanup_failure_e

C error enum for stale node cleanup.
"""
Iceoryx2FFI.iox2_node_cleanup_failure_e

"""
    Iceoryx2FFI.iox2_node_creation_failure_e

C error enum for node creation.
"""
Iceoryx2FFI.iox2_node_creation_failure_e

"""
    Iceoryx2FFI.iox2_node_list_failure_e

C error enum for node discovery.
"""
Iceoryx2FFI.iox2_node_list_failure_e

"""
    Iceoryx2FFI.iox2_node_wait_failure_e

C error enum for node wait operations.
"""
Iceoryx2FFI.iox2_node_wait_failure_e

"""
    Iceoryx2FFI.iox2_notifier_create_error_e

C error enum for notifier creation.
"""
Iceoryx2FFI.iox2_notifier_create_error_e

"""
    Iceoryx2FFI.iox2_notifier_notify_error_e

C error enum for notifier notify.
"""
Iceoryx2FFI.iox2_notifier_notify_error_e

"""
    Iceoryx2FFI.iox2_pub_sub_open_or_create_error_e

C error enum for pub/sub open/create.
"""
Iceoryx2FFI.iox2_pub_sub_open_or_create_error_e

"""
    Iceoryx2FFI.iox2_publisher_create_error_e

C error enum for publisher creation.
"""
Iceoryx2FFI.iox2_publisher_create_error_e

"""
    Iceoryx2FFI.iox2_reader_create_error_e

C error enum for reader creation.
"""
Iceoryx2FFI.iox2_reader_create_error_e

"""
    Iceoryx2FFI.iox2_receive_error_e

C error enum for receive errors.
"""
Iceoryx2FFI.iox2_receive_error_e

"""
    Iceoryx2FFI.iox2_request_response_open_or_create_error_e

C error enum for request/response open/create.
"""
Iceoryx2FFI.iox2_request_response_open_or_create_error_e

"""
    Iceoryx2FFI.iox2_request_send_error_e

C error enum for request send errors.
"""
Iceoryx2FFI.iox2_request_send_error_e

"""
    Iceoryx2FFI.iox2_semantic_string_error_e

C error enum for semantic string errors.
"""
Iceoryx2FFI.iox2_semantic_string_error_e

"""
    Iceoryx2FFI.iox2_send_error_e

C error enum for send errors.
"""
Iceoryx2FFI.iox2_send_error_e

"""
    Iceoryx2FFI.iox2_server_create_error_e

C error enum for server creation.
"""
Iceoryx2FFI.iox2_server_create_error_e

"""
    Iceoryx2FFI.iox2_service_details_error_e

C error enum for service details.
"""
Iceoryx2FFI.iox2_service_details_error_e

"""
    Iceoryx2FFI.iox2_service_list_error_e

C error enum for service listing.
"""
Iceoryx2FFI.iox2_service_list_error_e

"""
    Iceoryx2FFI.iox2_service_remove_error_e

C error enum for force-removing a stale service.
"""
Iceoryx2FFI.iox2_service_remove_error_e

"""
    Iceoryx2FFI.iox2_subscriber_create_error_e

C error enum for subscriber creation.
"""
Iceoryx2FFI.iox2_subscriber_create_error_e

"""
    Iceoryx2FFI.iox2_type_detail_error_e

C error enum for type detail errors.
"""
Iceoryx2FFI.iox2_type_detail_error_e

"""
    Iceoryx2FFI.iox2_waitset_attachment_error_e

C error enum for waitset attachment.
"""
Iceoryx2FFI.iox2_waitset_attachment_error_e

"""
    Iceoryx2FFI.iox2_waitset_create_error_e

C error enum for waitset creation.
"""
Iceoryx2FFI.iox2_waitset_create_error_e

"""
    Iceoryx2FFI.iox2_waitset_run_error_e

C error enum for waitset run.
"""
Iceoryx2FFI.iox2_waitset_run_error_e

"""
    Iceoryx2FFI.iox2_writer_create_error_e

C error enum for writer creation.
"""
Iceoryx2FFI.iox2_writer_create_error_e
