# Docstrings for error types and enums (generated in src/generated/errors.jl).

"""
    check_ok(code, ::Type{T})

Validate a C error code and throw the corresponding `*Error` exception on
failure. `T` is the C enum type for the error category.
"""
@doc check_ok

const _ERROR_DOCS = Dict(
    :AttributeDefinitionError => "Error thrown when defining attributes fails.",
    :AttributeVerificationError => "Error thrown when attribute verification fails.",
    :BlackboardCreateError => "Error thrown when blackboard creation fails.",
    :BlackboardOpenError => "Error thrown when blackboard open fails.",
    :ClientCreateError => "Error thrown when creating a client fails.",
    :ConfigCreationError => "Error thrown when creating a config fails.",
    :EntryHandleError => "Error thrown when acquiring a reader entry fails.",
    :EntryHandleMutError => "Error thrown when acquiring a writer entry fails.",
    :EventOpenOrCreateError => "Error thrown when opening or creating an event service fails.",
    :ListenerCreateError => "Error thrown when creating a listener fails.",
    :ListenerWaitError => "Error thrown when waiting on a listener fails.",
    :LoanError => "Error thrown when a loan operation fails.",
    :NotifierCreateError => "Error thrown when creating a notifier fails.",
    :NotifierNotifyError => "Error thrown when notifying fails.",
    :PubSubOpenOrCreateError => "Error thrown when opening or creating a pub/sub service fails.",
    :PublisherCreateError => "Error thrown when creating a publisher fails.",
    :ReaderCreateError => "Error thrown when creating a reader fails.",
    :ReceiveError => "Error thrown when receiving fails.",
    :RequestResponseOpenOrCreateError => "Error thrown when opening or creating a request/response service fails.",
    :RequestSendError => "Error thrown when sending a request fails.",
    :SemanticStringError => "Error thrown when semantic string validation fails.",
    :SendError => "Error thrown when sending a sample fails.",
    :ServerCreateError => "Error thrown when creating a server fails.",
    :ServiceDetailsError => "Error thrown when fetching service details fails.",
    :ServiceListError => "Error thrown when listing services fails.",
    :SubscriberCreateError => "Error thrown when creating a subscriber fails.",
    :TypeDetailError => "Error thrown when setting type details fails.",
    :WaitsetAttachmentError => "Error thrown when attaching to a waitset fails.",
    :WaitsetCreateError => "Error thrown when creating a waitset fails.",
    :WaitsetRunError => "Error thrown when running a waitset fails.",
    :WriterCreateError => "Error thrown when creating a writer fails.",
)

for (name, text) in _ERROR_DOCS
    if isdefined(@__MODULE__, name)
        @doc text getfield(@__MODULE__, name)
    end
end

const _ERROR_ENUM_DOCS = Dict(
    :iox2_attribute_definition_error_e => "C error enum for attribute definition.",
    :iox2_attribute_verification_error_e => "C error enum for attribute verification.",
    :iox2_blackboard_create_error_e => "C error enum for blackboard creation.",
    :iox2_blackboard_open_error_e => "C error enum for blackboard open.",
    :iox2_client_create_error_e => "C error enum for client creation.",
    :iox2_config_creation_error_e => "C error enum for config creation.",
    :iox2_entry_handle_error_e => "C error enum for reader entry errors.",
    :iox2_entry_handle_mut_error_e => "C error enum for writer entry errors.",
    :iox2_event_open_or_create_error_e => "C error enum for event open/create.",
    :iox2_listener_create_error_e => "C error enum for listener creation.",
    :iox2_listener_wait_error_e => "C error enum for listener wait.",
    :iox2_loan_error_e => "C error enum for loan operations.",
    :iox2_notifier_create_error_e => "C error enum for notifier creation.",
    :iox2_notifier_notify_error_e => "C error enum for notifier notify.",
    :iox2_pub_sub_open_or_create_error_e => "C error enum for pub/sub open/create.",
    :iox2_publisher_create_error_e => "C error enum for publisher creation.",
    :iox2_reader_create_error_e => "C error enum for reader creation.",
    :iox2_receive_error_e => "C error enum for receive errors.",
    :iox2_request_response_open_or_create_error_e => "C error enum for request/response open/create.",
    :iox2_request_send_error_e => "C error enum for request send errors.",
    :iox2_semantic_string_error_e => "C error enum for semantic string errors.",
    :iox2_send_error_e => "C error enum for send errors.",
    :iox2_server_create_error_e => "C error enum for server creation.",
    :iox2_service_details_error_e => "C error enum for service details.",
    :iox2_service_list_error_e => "C error enum for service listing.",
    :iox2_subscriber_create_error_e => "C error enum for subscriber creation.",
    :iox2_type_detail_error_e => "C error enum for type detail errors.",
    :iox2_waitset_attachment_error_e => "C error enum for waitset attachment.",
    :iox2_waitset_create_error_e => "C error enum for waitset creation.",
    :iox2_waitset_run_error_e => "C error enum for waitset run.",
    :iox2_writer_create_error_e => "C error enum for writer creation.",
)

for (name, text) in _ERROR_ENUM_DOCS
    if isdefined(Iceoryx2FFI, name)
        @doc text getfield(Iceoryx2FFI, name)
    end
end
