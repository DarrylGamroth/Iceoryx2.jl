module Iceoryx2FFI

using Iceoryx2_jll
export Iceoryx2_jll

using CEnum: CEnum, @cenum

const iox2_attribute_set_ptr_t = Cvoid

const iox2_client_details_ptr_t = Cvoid

const iox2_config_ptr_t = Cvoid

const iox2_listener_details_ptr_t = Cvoid

const iox2_node_id_ptr_t = Cvoid

const iox2_node_name_ptr_t = Cvoid

const iox2_notifier_details_ptr_t = Cvoid

const iox2_publisher_details_ptr_t = Cvoid

const iox2_reader_details_ptr_t = Cvoid

const iox2_server_details_ptr_t = Cvoid

const iox2_service_name_ptr_t = Cvoid

const iox2_subscriber_details_ptr_t = Cvoid

const iox2_writer_details_ptr_t = Cvoid

"""
    iox2_allocation_strategy_e

Describes generically an allocation strategy, meaning how the memory is increased when the available memory is insufficient.
"""
@cenum iox2_allocation_strategy_e::UInt32 begin
    iox2_allocation_strategy_e_BEST_FIT = 0
    iox2_allocation_strategy_e_POWER_OF_TWO = 1
    iox2_allocation_strategy_e_STATIC = 2
end

@cenum iox2_attribute_definition_error_e::UInt32 begin
    iox2_attribute_definition_error_e_EXCEEDS_MAX_SUPPORTED_ATTRIBUTES = 1
end

@cenum iox2_attribute_verification_error_e::UInt32 begin
    iox2_attribute_verification_error_e_NON_EXISTING_KEY = 1
    iox2_attribute_verification_error_e_INCOMPATIBLE_ATTRIBUTE = 2
end

@cenum iox2_blackboard_create_error_e::UInt32 begin
    iox2_blackboard_create_error_e_C_ALREADY_EXISTS = 1
    iox2_blackboard_create_error_e_C_IS_BEING_CREATED_BY_ANOTHER_INSTANCE = 2
    iox2_blackboard_create_error_e_C_INTERNAL_FAILURE = 3
    iox2_blackboard_create_error_e_C_INSUFFICIENT_PERMISSIONS = 4
    iox2_blackboard_create_error_e_C_SERVICE_IN_CORRUPTED_STATE = 5
    iox2_blackboard_create_error_e_C_HANGS_IN_CREATION = 6
    iox2_blackboard_create_error_e_C_NO_ENTRIES_PROVIDED = 7
end

@cenum iox2_blackboard_open_error_e::UInt32 begin
    iox2_blackboard_open_error_e_O_DOES_NOT_EXIST = 1
    iox2_blackboard_open_error_e_O_SERVICE_IN_CORRUPTED_STATE = 2
    iox2_blackboard_open_error_e_O_INCOMPATIBLE_KEYS = 3
    iox2_blackboard_open_error_e_O_INTERNAL_FAILURE = 4
    iox2_blackboard_open_error_e_O_INCOMPATIBLE_ATTRIBUTES = 5
    iox2_blackboard_open_error_e_O_INCOMPATIBLE_MESSAGING_PATTERN = 6
    iox2_blackboard_open_error_e_O_DOES_NOT_SUPPORT_REQUESTED_AMOUNT_OF_READERS = 7
    iox2_blackboard_open_error_e_O_INSUFFICIENT_PERMISSIONS = 8
    iox2_blackboard_open_error_e_O_HANGS_IN_CREATION = 9
    iox2_blackboard_open_error_e_O_IS_MARKED_FOR_DESTRUCTION = 10
    iox2_blackboard_open_error_e_O_EXCEEDS_MAX_NUMBER_OF_NODES = 11
    iox2_blackboard_open_error_e_O_DOES_NOT_SUPPORT_REQUESTED_AMOUNT_OF_NODES = 12
end

@cenum iox2_callback_progression_e::UInt32 begin
    iox2_callback_progression_e_STOP = 0
    iox2_callback_progression_e_CONTINUE = 1
end

@cenum iox2_client_create_error_e::UInt32 begin
    iox2_client_create_error_e_UNABLE_TO_CREATE_DATA_SEGMENT = 1
    iox2_client_create_error_e_EXCEEDS_MAX_SUPPORTED_CLIENTS = 2
    iox2_client_create_error_e_FAILED_TO_DEPLOY_THREAD_SAFETY_POLICY = 3
end

"""
    iox2_config_creation_error_e

Failures occurring while creating a new [[`iox2_config_t`](@ref)] object with [`[`iox2_config_from_file`](@ref)()`].
"""
@cenum iox2_config_creation_error_e::UInt32 begin
    iox2_config_creation_error_e_FAILED_TO_READ_CONFIG_FILE_CONTENTS = 1
    iox2_config_creation_error_e_UNABLE_TO_DESERIALIZE_CONTENTS = 2
    iox2_config_creation_error_e_INSUFFICIENT_PERMISSIONS = 3
    iox2_config_creation_error_e_CONFIG_FILE_DOES_NOT_EXIST = 4
    iox2_config_creation_error_e_UNABLE_TO_OPEN_CONFIG_FILE = 5
    iox2_config_creation_error_e_INVALID_FILE_PATH = 6
end

@cenum iox2_connection_failure_e::UInt32 begin
    iox2_connection_failure_e_FAILED_TO_ESTABLISH_CONNECTION = 0
    iox2_connection_failure_e_UNABLE_TO_MAP_SENDERS_DATA_SEGMENT = 1
end

@cenum iox2_entry_handle_error_e::UInt32 begin
    iox2_entry_handle_error_e_ENTRY_DOES_NOT_EXIST = 1
end

@cenum iox2_entry_handle_mut_error_e::UInt32 begin
    iox2_entry_handle_mut_error_e_ENTRY_DOES_NOT_EXIST = 1
    iox2_entry_handle_mut_error_e_HANDLE_ALREADY_EXISTS = 2
end

@cenum iox2_event_open_or_create_error_e::UInt32 begin
    iox2_event_open_or_create_error_e_O_DOES_NOT_EXIST = 1
    iox2_event_open_or_create_error_e_O_INSUFFICIENT_PERMISSIONS = 2
    iox2_event_open_or_create_error_e_O_SERVICE_IN_CORRUPTED_STATE = 3
    iox2_event_open_or_create_error_e_O_INCOMPATIBLE_MESSAGING_PATTERN = 4
    iox2_event_open_or_create_error_e_O_INCOMPATIBLE_ATTRIBUTES = 5
    iox2_event_open_or_create_error_e_O_INCOMPATIBLE_DEADLINE = 6
    iox2_event_open_or_create_error_e_O_INCOMPATIBLE_NOTIFIER_CREATED_EVENT = 7
    iox2_event_open_or_create_error_e_O_INCOMPATIBLE_NOTIFIER_DROPPED_EVENT = 8
    iox2_event_open_or_create_error_e_O_INCOMPATIBLE_NOTIFIER_DEAD_EVENT = 9
    iox2_event_open_or_create_error_e_O_INTERNAL_FAILURE = 10
    iox2_event_open_or_create_error_e_O_HANGS_IN_CREATION = 11
    iox2_event_open_or_create_error_e_O_DOES_NOT_SUPPORT_REQUESTED_AMOUNT_OF_NOTIFIERS = 12
    iox2_event_open_or_create_error_e_O_DOES_NOT_SUPPORT_REQUESTED_AMOUNT_OF_LISTENERS = 13
    iox2_event_open_or_create_error_e_O_DOES_NOT_SUPPORT_REQUESTED_MAX_EVENT_ID = 14
    iox2_event_open_or_create_error_e_O_DOES_NOT_SUPPORT_REQUESTED_AMOUNT_OF_NODES = 15
    iox2_event_open_or_create_error_e_O_EXCEEDS_MAX_NUMBER_OF_NODES = 16
    iox2_event_open_or_create_error_e_O_IS_MARKED_FOR_DESTRUCTION = 17
    iox2_event_open_or_create_error_e_C_SERVICE_IN_CORRUPTED_STATE = 18
    iox2_event_open_or_create_error_e_C_INTERNAL_FAILURE = 19
    iox2_event_open_or_create_error_e_C_IS_BEING_CREATED_BY_ANOTHER_INSTANCE = 20
    iox2_event_open_or_create_error_e_C_ALREADY_EXISTS = 21
    iox2_event_open_or_create_error_e_C_HANGS_IN_CREATION = 22
    iox2_event_open_or_create_error_e_C_INSUFFICIENT_PERMISSIONS = 23
    iox2_event_open_or_create_error_e_C_OLD_CONNECTION_STILL_ACTIVE = 24
    iox2_event_open_or_create_error_e_SYSTEM_IN_FLUX = 25
end

@cenum iox2_listener_create_error_e::UInt32 begin
    iox2_listener_create_error_e_EXCEEDS_MAX_SUPPORTED_LISTENERS = 1
    iox2_listener_create_error_e_RESOURCE_CREATION_FAILED = 2
    iox2_listener_create_error_e_FAILED_TO_DEPLOY_THREAD_SAFETY_POLICY = 3
end

@cenum iox2_listener_wait_error_e::UInt32 begin
    iox2_listener_wait_error_e_CONTRACT_VIOLATION = 1
    iox2_listener_wait_error_e_INTERNAL_FAILURE = 2
    iox2_listener_wait_error_e_INTERRUPT_SIGNAL = 3
end

@cenum iox2_loan_error_e::UInt32 begin
    iox2_loan_error_e_OUT_OF_MEMORY = 1
    iox2_loan_error_e_EXCEEDS_MAX_LOANED_SAMPLES = 2
    iox2_loan_error_e_EXCEEDS_MAX_LOAN_SIZE = 3
    iox2_loan_error_e_INTERNAL_FAILURE = 4
end

@cenum iox2_log_level_e::UInt32 begin
    iox2_log_level_e_TRACE = 0
    iox2_log_level_e_DEBUG = 1
    iox2_log_level_e_INFO = 2
    iox2_log_level_e_WARN = 3
    iox2_log_level_e_ERROR = 4
    iox2_log_level_e_FATAL = 5
end

@cenum iox2_messaging_pattern_e::UInt32 begin
    iox2_messaging_pattern_e_PUBLISH_SUBSCRIBE = 0
    iox2_messaging_pattern_e_EVENT = 1
    iox2_messaging_pattern_e_REQUEST_RESPONSE = 2
    iox2_messaging_pattern_e_BLACKBOARD = 3
end

"""
    iox2_node_cleanup_failure_e

Failures of [`[`iox2_dead_node_remove_stale_resources`](@ref)()`] that occur when the stale resources of a dead node are removed.
"""
@cenum iox2_node_cleanup_failure_e::UInt32 begin
    iox2_node_cleanup_failure_e_INTERRUPT = 1
    iox2_node_cleanup_failure_e_INTERNAL_ERROR = 2
    iox2_node_cleanup_failure_e_INSUFFICIENT_PERMISSIONS = 3
    iox2_node_cleanup_failure_e_VERSION_MISMATCH = 4
end

@cenum iox2_node_creation_failure_e::UInt32 begin
    iox2_node_creation_failure_e_INSUFFICIENT_PERMISSIONS = 1
    iox2_node_creation_failure_e_INTERNAL_ERROR = 2
end

"""
    iox2_node_list_failure_e

The failures that can occur when a list of node states is created with [`[`iox2_node_list`](@ref)()`].
"""
@cenum iox2_node_list_failure_e::UInt32 begin
    iox2_node_list_failure_e_INSUFFICIENT_PERMISSIONS = 1
    iox2_node_list_failure_e_INTERRUPT = 2
    iox2_node_list_failure_e_INTERNAL_ERROR = 3
end

@cenum iox2_node_state_e::UInt32 begin
    iox2_node_state_e_ALIVE = 0
    iox2_node_state_e_DEAD = 1
    iox2_node_state_e_INACCESSIBLE = 2
    iox2_node_state_e_UNDEFINED = 3
end

@cenum iox2_node_wait_failure_e::UInt32 begin
    iox2_node_wait_failure_e_INTERRUPT = 1
    iox2_node_wait_failure_e_TERMINATION_REQUEST = 2
end

@cenum iox2_notifier_create_error_e::UInt32 begin
    iox2_notifier_create_error_e_EXCEEDS_MAX_SUPPORTED_NOTIFIERS = 1
    iox2_notifier_create_error_e_FAILED_TO_DEPLOY_THREAD_SAFETY_POLICY = 2
end

@cenum iox2_notifier_notify_error_e::UInt32 begin
    iox2_notifier_notify_error_e_EVENT_ID_OUT_OF_BOUNDS = 1
    iox2_notifier_notify_error_e_MISSED_DEADLINE = 2
    iox2_notifier_notify_error_e_UNABLE_TO_ACQUIRE_ELAPSED_TIME = 3
end

@cenum iox2_pub_sub_open_or_create_error_e::UInt32 begin
    iox2_pub_sub_open_or_create_error_e_O_DOES_NOT_EXIST = 1
    iox2_pub_sub_open_or_create_error_e_O_INTERNAL_FAILURE = 2
    iox2_pub_sub_open_or_create_error_e_O_INCOMPATIBLE_TYPES = 3
    iox2_pub_sub_open_or_create_error_e_O_INCOMPATIBLE_MESSAGING_PATTERN = 4
    iox2_pub_sub_open_or_create_error_e_O_INCOMPATIBLE_ATTRIBUTES = 5
    iox2_pub_sub_open_or_create_error_e_O_DOES_NOT_SUPPORT_REQUESTED_MIN_BUFFER_SIZE = 6
    iox2_pub_sub_open_or_create_error_e_O_DOES_NOT_SUPPORT_REQUESTED_MIN_HISTORY_SIZE = 7
    iox2_pub_sub_open_or_create_error_e_O_DOES_NOT_SUPPORT_REQUESTED_MIN_SUBSCRIBER_BORROWED_SAMPLES = 8
    iox2_pub_sub_open_or_create_error_e_O_DOES_NOT_SUPPORT_REQUESTED_AMOUNT_OF_PUBLISHERS = 9
    iox2_pub_sub_open_or_create_error_e_O_DOES_NOT_SUPPORT_REQUESTED_AMOUNT_OF_SUBSCRIBERS = 10
    iox2_pub_sub_open_or_create_error_e_O_DOES_NOT_SUPPORT_REQUESTED_AMOUNT_OF_NODES = 11
    iox2_pub_sub_open_or_create_error_e_O_INCOMPATIBLE_OVERFLOW_BEHAVIOR = 12
    iox2_pub_sub_open_or_create_error_e_O_INSUFFICIENT_PERMISSIONS = 13
    iox2_pub_sub_open_or_create_error_e_O_SERVICE_IN_CORRUPTED_STATE = 14
    iox2_pub_sub_open_or_create_error_e_O_HANGS_IN_CREATION = 15
    iox2_pub_sub_open_or_create_error_e_O_EXCEEDS_MAX_NUMBER_OF_NODES = 16
    iox2_pub_sub_open_or_create_error_e_O_IS_MARKED_FOR_DESTRUCTION = 17
    iox2_pub_sub_open_or_create_error_e_C_SERVICE_IN_CORRUPTED_STATE = 18
    iox2_pub_sub_open_or_create_error_e_C_SUBSCRIBER_BUFFER_MUST_BE_LARGER_THAN_HISTORY_SIZE = 19
    iox2_pub_sub_open_or_create_error_e_C_ALREADY_EXISTS = 20
    iox2_pub_sub_open_or_create_error_e_C_INSUFFICIENT_PERMISSIONS = 21
    iox2_pub_sub_open_or_create_error_e_C_INTERNAL_FAILURE = 22
    iox2_pub_sub_open_or_create_error_e_C_IS_BEING_CREATED_BY_ANOTHER_INSTANCE = 23
    iox2_pub_sub_open_or_create_error_e_C_OLD_CONNECTION_STILL_ACTIVE = 24
    iox2_pub_sub_open_or_create_error_e_C_HANGS_IN_CREATION = 25
    iox2_pub_sub_open_or_create_error_e_SYSTEM_IN_FLUX = 26
end

@cenum iox2_publisher_create_error_e::UInt32 begin
    iox2_publisher_create_error_e_EXCEEDS_MAX_SUPPORTED_PUBLISHERS = 1
    iox2_publisher_create_error_e_UNABLE_TO_CREATE_DATA_SEGMENT = 2
    iox2_publisher_create_error_e_FAILED_TO_DEPLOY_THREAD_SAFETY_POLICY = 3
end

@cenum iox2_reader_create_error_e::UInt32 begin
    iox2_reader_create_error_e_EXCEEDS_MAX_SUPPORTED_READERS = 1
end

@cenum iox2_receive_error_e::UInt32 begin
    iox2_receive_error_e_EXCEEDS_MAX_BORROWS = 1
    iox2_receive_error_e_FAILED_TO_ESTABLISH_CONNECTION = 2
    iox2_receive_error_e_UNABLE_TO_MAP_SENDERS_DATA_SEGMENT = 3
end

@cenum iox2_request_response_open_or_create_error_e::UInt32 begin
    iox2_request_response_open_or_create_error_e_O_DOES_NOT_EXIST = 1
    iox2_request_response_open_or_create_error_e_O_DOES_NOT_SUPPORT_REQUESTED_AMOUNT_OF_CLIENT_REQUEST_LOANS = 2
    iox2_request_response_open_or_create_error_e_O_DOES_NOT_SUPPORT_REQUESTED_AMOUNT_OF_ACTIVE_REQUESTS_PER_CLIENT = 3
    iox2_request_response_open_or_create_error_e_O_DOES_NOT_SUPPORT_REQUESTED_RESPONSE_BUFFER_SIZE = 4
    iox2_request_response_open_or_create_error_e_O_DOES_NOT_SUPPORT_REQUESTED_AMOUNT_OF_SERVERS = 5
    iox2_request_response_open_or_create_error_e_O_DOES_NOT_SUPPORT_REQUESTED_AMOUNT_OF_CLIENTS = 6
    iox2_request_response_open_or_create_error_e_O_DOES_NOT_SUPPORT_REQUESTED_AMOUNT_OF_NODES = 7
    iox2_request_response_open_or_create_error_e_O_DOES_NOT_SUPPORT_REQUESTED_AMOUNT_OF_BORROWED_RESPONSES_PER_PENDING_RESPONSE = 8
    iox2_request_response_open_or_create_error_e_O_EXCEEDS_MAX_NUMBER_OF_NODES = 9
    iox2_request_response_open_or_create_error_e_O_HANGS_IN_CREATION = 10
    iox2_request_response_open_or_create_error_e_O_INCOMPATIBLE_REQUEST_TYPE = 11
    iox2_request_response_open_or_create_error_e_O_INCOMPATIBLE_RESPONSE_TYPE = 12
    iox2_request_response_open_or_create_error_e_O_INCOMPATIBLE_ATTRIBUTES = 13
    iox2_request_response_open_or_create_error_e_O_INCOMPATIBLE_MESSAGING_PATTERN = 14
    iox2_request_response_open_or_create_error_e_O_INCOMPATIBLE_OVERFLOW_BEHAVIOR_FOR_REQUESTS = 15
    iox2_request_response_open_or_create_error_e_O_INCOMPATIBLE_OVERFLOW_BEHAVIOR_FOR_RESPONSES = 16
    iox2_request_response_open_or_create_error_e_O_INCOMPATIBLE_BEHAVIOR_FOR_FIRE_AND_FORGET_REQUESTS = 17
    iox2_request_response_open_or_create_error_e_O_INSUFFICIENT_PERMISSIONS = 18
    iox2_request_response_open_or_create_error_e_O_INTERNAL_FAILURE = 19
    iox2_request_response_open_or_create_error_e_O_IS_MARKED_FOR_DESTRUCTION = 20
    iox2_request_response_open_or_create_error_e_O_SERVICE_IN_CORRUPTED_STATE = 21
    iox2_request_response_open_or_create_error_e_C_ALREADY_EXISTS = 22
    iox2_request_response_open_or_create_error_e_C_INTERNAL_FAILURE = 23
    iox2_request_response_open_or_create_error_e_C_IS_BEING_CREATED_BY_ANOTHER_INSTANCE = 24
    iox2_request_response_open_or_create_error_e_C_INSUFFICIENT_PERMISSIONS = 25
    iox2_request_response_open_or_create_error_e_C_HANGS_IN_CREATION = 26
    iox2_request_response_open_or_create_error_e_C_SERVICE_IN_CORRUPTED_STATE = 27
    iox2_request_response_open_or_create_error_e_SYSTEM_IN_FLUX = 28
end

@cenum iox2_request_send_error_e::UInt32 begin
    iox2_request_send_error_e_CONNECTION_BROKEN_SINCE_SENDER_NO_LONGER_EXISTS = 1
    iox2_request_send_error_e_CONNECTION_CORRUPTED = 2
    iox2_request_send_error_e_LOAN_ERROR_OUT_OF_MEMORY = 3
    iox2_request_send_error_e_LOAN_ERROR_EXCEEDS_MAX_LOANS = 4
    iox2_request_send_error_e_LOAN_ERROR_EXCEEDS_MAX_LOAN_SIZE = 5
    iox2_request_send_error_e_LOAN_ERROR_INTERNAL_FAILURE = 6
    iox2_request_send_error_e_CONNECTION_ERROR = 7
    iox2_request_send_error_e_EXCEEDS_MAX_ACTIVE_REQUESTS = 8
end

@cenum iox2_semantic_string_error_e::UInt32 begin
    iox2_semantic_string_error_e_INVALID_CONTENT = 1
    iox2_semantic_string_error_e_EXCEEDS_MAXIMUM_LENGTH = 2
end

@cenum iox2_send_error_e::UInt32 begin
    iox2_send_error_e_CONNECTION_BROKEN_SINCE_SENDER_NO_LONGER_EXISTS = 1
    iox2_send_error_e_CONNECTION_CORRUPTED = 2
    iox2_send_error_e_LOAN_ERROR_OUT_OF_MEMORY = 3
    iox2_send_error_e_LOAN_ERROR_EXCEEDS_MAX_LOANS = 4
    iox2_send_error_e_LOAN_ERROR_EXCEEDS_MAX_LOAN_SIZE = 5
    iox2_send_error_e_LOAN_ERROR_INTERNAL_FAILURE = 6
    iox2_send_error_e_CONNECTION_ERROR = 7
end

@cenum iox2_server_create_error_e::UInt32 begin
    iox2_server_create_error_e_EXCEEDS_MAX_SUPPORTED_SERVERS = 1
    iox2_server_create_error_e_UNABLE_TO_CREATE_DATA_SEGMENT = 2
    iox2_server_create_error_e_FAILED_TO_DEPLOY_THREAD_SAFETY_POLICY = 3
end

@cenum iox2_service_details_error_e::UInt32 begin
    iox2_service_details_error_e_FAILED_TO_OPEN_STATIC_SERVICE_INFO = 1
    iox2_service_details_error_e_FAILED_TO_READ_STATIC_SERVICE_INFO = 2
    iox2_service_details_error_e_FAILED_TO_DESERIALIZE_STATIC_SERVICE_INFO = 3
    iox2_service_details_error_e_SERVICE_IN_INCONSISTENT_STATE = 4
    iox2_service_details_error_e_VERSION_MISMATCH = 5
    iox2_service_details_error_e_INTERNAL_ERROR = 6
    iox2_service_details_error_e_FAILED_TO_ACQUIRE_NODE_STATE = 7
end

@cenum iox2_service_list_error_e::UInt32 begin
    iox2_service_list_error_e_INSUFFICIENT_PERMISSIONS = 1
    iox2_service_list_error_e_INTERNAL_ERROR = 2
end

@cenum iox2_service_type_e::UInt32 begin
    iox2_service_type_e_LOCAL = 0
    iox2_service_type_e_IPC = 1
end

"""
    iox2_signal_handling_mode_e

Defines how signals are handled by constructs that might register a custom signal handler.
"""
@cenum iox2_signal_handling_mode_e::UInt32 begin
    iox2_signal_handling_mode_e_HANDLE_TERMINATION_REQUESTS = 1
    iox2_signal_handling_mode_e_DISABLED = 2
end

@cenum iox2_subscriber_create_error_e::UInt32 begin
    iox2_subscriber_create_error_e_EXCEEDS_MAX_SUPPORTED_SUBSCRIBERS = 1
    iox2_subscriber_create_error_e_BUFFER_SIZE_EXCEEDS_MAX_SUPPORTED_BUFFER_SIZE_OF_SERVICE = 2
    iox2_subscriber_create_error_e_FAILED_TO_DEPLOY_THREAD_SAFETY_POLICY = 3
end

@cenum iox2_type_detail_error_e::UInt32 begin
    iox2_type_detail_error_e_INVALID_TYPE_NAME = 1
    iox2_type_detail_error_e_INVALID_SIZE_OR_ALIGNMENT_VALUE = 2
end

@cenum iox2_type_variant_e::UInt32 begin
    iox2_type_variant_e_FIXED_SIZE = 0
    iox2_type_variant_e_DYNAMIC = 1
end

@cenum iox2_unable_to_deliver_strategy_e::UInt32 begin
    iox2_unable_to_deliver_strategy_e_BLOCK = 0
    iox2_unable_to_deliver_strategy_e_DISCARD_SAMPLE = 1
end

@cenum iox2_waitset_attachment_error_e::UInt32 begin
    iox2_waitset_attachment_error_e_INSUFFICIENT_CAPACITY = 1
    iox2_waitset_attachment_error_e_ALREADY_ATTACHED = 2
    iox2_waitset_attachment_error_e_INTERNAL_ERROR = 3
    iox2_waitset_attachment_error_e_INSUFFICIENT_RESOURCES = 4
end

@cenum iox2_waitset_create_error_e::UInt32 begin
    iox2_waitset_create_error_e_INTERNAL_ERROR = 1
    iox2_waitset_create_error_e_INSUFFICIENT_RESOURCES = 2
end

@cenum iox2_waitset_run_error_e::UInt32 begin
    iox2_waitset_run_error_e_INSUFFICIENT_PERMISSIONS = 1
    iox2_waitset_run_error_e_INTERNAL_ERROR = 2
    iox2_waitset_run_error_e_NO_ATTACHMENTS = 3
    iox2_waitset_run_error_e_TERMINATION_REQUEST = 4
    iox2_waitset_run_error_e_INTERRUPT = 5
end

@cenum iox2_waitset_run_result_e::UInt32 begin
    iox2_waitset_run_result_e_TERMINATION_REQUEST = 1
    iox2_waitset_run_result_e_INTERRUPT = 2
    iox2_waitset_run_result_e_STOP_REQUEST = 3
    iox2_waitset_run_result_e_ALL_EVENTS_HANDLED = 4
end

@cenum iox2_writer_create_error_e::UInt32 begin
    iox2_writer_create_error_e_EXCEEDS_MAX_SUPPORTED_WRITERS = 1
    iox2_writer_create_error_e_INTERNAL_FAILURE = 2
end

const iox2_active_request_h_t = Cvoid

const iox2_attribute_h_t = Cvoid

const iox2_attribute_set_h_t = Cvoid

const iox2_attribute_specifier_h_t = Cvoid

const iox2_attribute_verifier_h_t = Cvoid

const iox2_client_h_t = Cvoid

const iox2_config_h_t = Cvoid

const iox2_entry_handle_h_t = Cvoid

const iox2_entry_handle_mut_h_t = Cvoid

const iox2_entry_value_uninit_h_t = Cvoid

const iox2_file_descriptor_h_t = Cvoid

const iox2_listener_h_t = Cvoid

const iox2_name_h_t = Cvoid

const iox2_node_builder_h_t = Cvoid

const iox2_node_id_h_t = Cvoid

const iox2_node_name_h_t = Cvoid

const iox2_notifier_h_t = Cvoid

const iox2_pending_response_h_t = Cvoid

const iox2_port_factory_blackboard_h_t = Cvoid

const iox2_port_factory_client_builder_h_t = Cvoid

const iox2_port_factory_event_h_t = Cvoid

const iox2_port_factory_listener_builder_h_t = Cvoid

const iox2_port_factory_notifier_builder_h_t = Cvoid

const iox2_port_factory_pub_sub_h_t = Cvoid

const iox2_port_factory_publisher_builder_h_t = Cvoid

const iox2_port_factory_reader_builder_h_t = Cvoid

const iox2_port_factory_request_response_h_t = Cvoid

const iox2_port_factory_server_builder_h_t = Cvoid

const iox2_port_factory_subscriber_builder_h_t = Cvoid

const iox2_port_factory_writer_builder_h_t = Cvoid

const iox2_publish_subscribe_header_h_t = Cvoid

const iox2_publisher_h_t = Cvoid

const iox2_reader_h_t = Cvoid

const iox2_request_header_h_t = Cvoid

const iox2_request_mut_h_t = Cvoid

const iox2_response_h_t = Cvoid

const iox2_response_header_h_t = Cvoid

const iox2_response_mut_h_t = Cvoid

const iox2_sample_h_t = Cvoid

const iox2_sample_mut_h_t = Cvoid

const iox2_server_h_t = Cvoid

const iox2_service_builder_blackboard_creator_h_t = Cvoid

const iox2_service_builder_blackboard_opener_h_t = Cvoid

const iox2_service_builder_event_h_t = Cvoid

const iox2_service_builder_h_t = Cvoid

const iox2_service_builder_pub_sub_h_t = Cvoid

const iox2_service_builder_request_response_h_t = Cvoid

const iox2_service_name_h_t = Cvoid

const iox2_subscriber_h_t = Cvoid

const iox2_unique_client_id_h_t = Cvoid

const iox2_unique_listener_id_h_t = Cvoid

const iox2_unique_notifier_id_h_t = Cvoid

const iox2_unique_publisher_id_h_t = Cvoid

const iox2_unique_reader_id_h_t = Cvoid

const iox2_unique_server_id_h_t = Cvoid

const iox2_unique_subscriber_id_h_t = Cvoid

const iox2_unique_writer_id_h_t = Cvoid

const iox2_waitset_attachment_id_h_t = Cvoid

const iox2_waitset_builder_h_t = Cvoid

const iox2_waitset_guard_h_t = Cvoid

const iox2_waitset_h_t = Cvoid

const iox2_writer_h_t = Cvoid

"""
The owning handle for [`iox2_active_request_t`](@ref). Passing the handle to a function transfers the ownership.
"""
const iox2_active_request_h = Ptr{iox2_active_request_h_t}

"""
The non-owning handle for [`iox2_active_request_t`](@ref). Passing the handle to a function does not transfer the ownership.
"""
const iox2_active_request_h_ref = Ptr{iox2_active_request_h}

"""
    iox2_request_header_storage_t

Sample header used by `MessagingPattern::RequestResponse`
"""
struct iox2_request_header_storage_t
    data::NTuple{64, UInt8}
end

function Base.getproperty(x::Ptr{iox2_request_header_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{64, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_request_header_storage_t, f::Symbol)
    r = Ref{iox2_request_header_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_request_header_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_request_header_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_request_header_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_request_header_t
    data::NTuple{72, UInt8}
end

function Base.getproperty(x::Ptr{iox2_request_header_t}, f::Symbol)
    f === :value && return Ptr{iox2_request_header_storage_t}(x + 0)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 64)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_request_header_t, f::Symbol)
    r = Ref{iox2_request_header_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_request_header_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_request_header_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_request_header_t, private::Bool = false)
    (:value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [[`iox2_request_header_t`](@ref)]. Passing the handle to a function transfers the ownership.
"""
const iox2_request_header_h = Ptr{iox2_request_header_h_t}

const c_size_t = Csize_t

struct iox2_response_mut_storage_t
    data::NTuple{88, UInt8}
end

function Base.getproperty(x::Ptr{iox2_response_mut_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{88, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_response_mut_storage_t, f::Symbol)
    r = Ref{iox2_response_mut_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_response_mut_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_response_mut_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_response_mut_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_response_mut_t
    data::NTuple{104, UInt8}
end

function Base.getproperty(x::Ptr{iox2_response_mut_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_response_mut_storage_t}(x + 8)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 96)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_response_mut_t, f::Symbol)
    r = Ref{iox2_response_mut_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_response_mut_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_response_mut_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_response_mut_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [`iox2_response_mut_t`](@ref). Passing the handle to a function transfer the ownership.
"""
const iox2_response_mut_h = Ptr{iox2_response_mut_h_t}

const iox2_attribute_h_ref = Ptr{iox2_attribute_h_t}

struct iox2_attribute_set_storage_t
    data::NTuple{5672, UInt8}
end

function Base.getproperty(x::Ptr{iox2_attribute_set_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{5672, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_attribute_set_storage_t, f::Symbol)
    r = Ref{iox2_attribute_set_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_attribute_set_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_attribute_set_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_attribute_set_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_attribute_set_t
    data::NTuple{5680, UInt8}
end

function Base.getproperty(x::Ptr{iox2_attribute_set_t}, f::Symbol)
    f === :value && return Ptr{iox2_attribute_set_storage_t}(x + 0)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 5672)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_attribute_set_t, f::Symbol)
    r = Ref{iox2_attribute_set_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_attribute_set_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_attribute_set_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_attribute_set_t, private::Bool = false)
    (:value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The immutable pointer to the underlying `AttributeSet`
"""
const iox2_attribute_set_ptr = Ptr{iox2_attribute_set_ptr_t}

"""
The owning handle for [`iox2_attribute_set_t`](@ref). Passing the handle to an function transfers the ownership.
"""
const iox2_attribute_set_h = Ptr{iox2_attribute_set_h_t}

"""
An alias to a `void *` which can be used to pass arbitrary data to the callback
"""
const iox2_callback_context = Ptr{Cvoid}

# typedef enum iox2_callback_progression_e ( * iox2_attribute_set_get_callback ) ( const char * , iox2_callback_context )
const iox2_attribute_set_get_callback = Ptr{Cvoid}

struct iox2_attribute_specifier_storage_t
    data::NTuple{5672, UInt8}
end

function Base.getproperty(x::Ptr{iox2_attribute_specifier_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{5672, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_attribute_specifier_storage_t, f::Symbol)
    r = Ref{iox2_attribute_specifier_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_attribute_specifier_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_attribute_specifier_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_attribute_specifier_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_attribute_specifier_t
    data::NTuple{5680, UInt8}
end

function Base.getproperty(x::Ptr{iox2_attribute_specifier_t}, f::Symbol)
    f === :value && return Ptr{iox2_attribute_specifier_storage_t}(x + 0)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 5672)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_attribute_specifier_t, f::Symbol)
    r = Ref{iox2_attribute_specifier_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_attribute_specifier_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_attribute_specifier_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_attribute_specifier_t, private::Bool = false)
    (:value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [`iox2_attribute_specifier_t`](@ref). Passing the handle to an function transfers the ownership.
"""
const iox2_attribute_specifier_h = Ptr{iox2_attribute_specifier_h_t}

"""
The non-owning handle for [`iox2_attribute_specifier_t`](@ref). Passing the handle to an function does not transfers the ownership.
"""
const iox2_attribute_specifier_h_ref = Ptr{iox2_attribute_specifier_h}

struct iox2_attribute_verifier_storage_t
    data::NTuple{6984, UInt8}
end

function Base.getproperty(x::Ptr{iox2_attribute_verifier_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{6984, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_attribute_verifier_storage_t, f::Symbol)
    r = Ref{iox2_attribute_verifier_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_attribute_verifier_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_attribute_verifier_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_attribute_verifier_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_attribute_verifier_t
    data::NTuple{6992, UInt8}
end

function Base.getproperty(x::Ptr{iox2_attribute_verifier_t}, f::Symbol)
    f === :value && return Ptr{iox2_attribute_verifier_storage_t}(x + 0)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 6984)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_attribute_verifier_t, f::Symbol)
    r = Ref{iox2_attribute_verifier_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_attribute_verifier_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_attribute_verifier_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_attribute_verifier_t, private::Bool = false)
    (:value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [`iox2_attribute_verifier_t`](@ref). Passing the handle to an function transfers the ownership.
"""
const iox2_attribute_verifier_h = Ptr{iox2_attribute_verifier_h_t}

"""
The non-owning handle for [`iox2_attribute_verifier_t`](@ref). Passing the handle to an function does not transfers the ownership.
"""
const iox2_attribute_verifier_h_ref = Ptr{iox2_attribute_verifier_h}

"""
The owning handle for [`iox2_client_t`](@ref). Passing the handle to a function transfers the ownership.
"""
const iox2_client_h = Ptr{iox2_client_h_t}

"""
The non-owning handle for [`iox2_client_t`](@ref). Passing the handle to a function does not transfer the ownership.
"""
const iox2_client_h_ref = Ptr{iox2_client_h}

"""
    iox2_unique_client_id_storage_t

The system-wide unique id of a [`iox2_client_t`](@ref).
"""
struct iox2_unique_client_id_storage_t
    data::NTuple{20, UInt8}
end

function Base.getproperty(x::Ptr{iox2_unique_client_id_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{20, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_unique_client_id_storage_t, f::Symbol)
    r = Ref{iox2_unique_client_id_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_unique_client_id_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_unique_client_id_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_unique_client_id_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_unique_client_id_t
    data::NTuple{32, UInt8}
end

function Base.getproperty(x::Ptr{iox2_unique_client_id_t}, f::Symbol)
    f === :value && return Ptr{iox2_unique_client_id_storage_t}(x + 0)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_unique_client_id_t, f::Symbol)
    r = Ref{iox2_unique_client_id_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_unique_client_id_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_unique_client_id_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_unique_client_id_t, private::Bool = false)
    (:value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [[`iox2_unique_client_id_t`](@ref)]. Passing the handle to an function transfers the ownership.
"""
const iox2_unique_client_id_h = Ptr{iox2_unique_client_id_h_t}

struct iox2_request_mut_storage_t
    data::NTuple{80, UInt8}
end

function Base.getproperty(x::Ptr{iox2_request_mut_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{80, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_request_mut_storage_t, f::Symbol)
    r = Ref{iox2_request_mut_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_request_mut_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_request_mut_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_request_mut_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_request_mut_t
    data::NTuple{96, UInt8}
end

function Base.getproperty(x::Ptr{iox2_request_mut_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_request_mut_storage_t}(x + 8)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 88)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_request_mut_t, f::Symbol)
    r = Ref{iox2_request_mut_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_request_mut_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_request_mut_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_request_mut_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [`iox2_request_mut_t`](@ref). Passing the handle to a function transfers the ownership.
"""
const iox2_request_mut_h = Ptr{iox2_request_mut_h_t}

struct iox2_pending_response_storage_t
    data::NTuple{88, UInt8}
end

function Base.getproperty(x::Ptr{iox2_pending_response_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{88, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_pending_response_storage_t, f::Symbol)
    r = Ref{iox2_pending_response_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_pending_response_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_pending_response_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_pending_response_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_pending_response_t
    data::NTuple{104, UInt8}
end

function Base.getproperty(x::Ptr{iox2_pending_response_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_pending_response_storage_t}(x + 8)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 96)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_pending_response_t, f::Symbol)
    r = Ref{iox2_pending_response_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_pending_response_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_pending_response_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_pending_response_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [`iox2_pending_response_t`](@ref). Passing the handle to a function transfers the ownership.
"""
const iox2_pending_response_h = Ptr{iox2_pending_response_h_t}

"""
The immutable pointer to the underlying `ClientDetails`
"""
const iox2_client_details_ptr = Ptr{iox2_client_details_ptr_t}

"""
The immutable pointer to the underlying `NodeId`
"""
const iox2_node_id_ptr = Ptr{iox2_node_id_ptr_t}

"""
The immutable pointer to the underlying `Config`
"""
const iox2_config_ptr = Ptr{iox2_config_ptr_t}

"""
The owning handle for [`iox2_config_t`](@ref). Passing the handle to an function transfers the ownership.
"""
const iox2_config_h = Ptr{iox2_config_h_t}

"""
    iox2_config_storage_t

A storage object that has the size to store a config
"""
struct iox2_config_storage_t
    data::NTuple{4256, UInt8}
end

function Base.getproperty(x::Ptr{iox2_config_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{4256, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_config_storage_t, f::Symbol)
    r = Ref{iox2_config_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_config_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_config_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_config_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
    iox2_config_t

Contains the iceoryx2 config
"""
struct iox2_config_t
    data::NTuple{4264, UInt8}
end

function Base.getproperty(x::Ptr{iox2_config_t}, f::Symbol)
    f === :value && return Ptr{iox2_config_storage_t}(x + 0)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 4256)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_config_t, f::Symbol)
    r = Ref{iox2_config_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_config_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_config_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_config_t, private::Bool = false)
    (:value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The non-owning handle for [`iox2_config_t`](@ref). Passing the handle to an function does not transfers the ownership.
"""
const iox2_config_h_ref = Ptr{iox2_config_h}

"""
The owning handle for [`iox2_entry_handle_t`](@ref). Passing the handle to an function transfers the ownership.
"""
const iox2_entry_handle_h = Ptr{iox2_entry_handle_h_t}

"""
The non-owning handle for [`iox2_entry_handle_t`](@ref). Passing the handle to an function does not transfers the ownership.
"""
const iox2_entry_handle_h_ref = Ptr{iox2_entry_handle_h}

struct iox2_event_id_t
    value::Csize_t
end

"""
The owning handle for [`iox2_entry_handle_mut_t`](@ref). Passing the handle to a function transfers the ownership.
"""
const iox2_entry_handle_mut_h = Ptr{iox2_entry_handle_mut_h_t}

struct iox2_entry_value_uninit_storage_t
    data::NTuple{48, UInt8}
end

function Base.getproperty(x::Ptr{iox2_entry_value_uninit_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{48, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_entry_value_uninit_storage_t, f::Symbol)
    r = Ref{iox2_entry_value_uninit_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_entry_value_uninit_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_entry_value_uninit_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_entry_value_uninit_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_entry_value_uninit_t
    data::NTuple{64, UInt8}
end

function Base.getproperty(x::Ptr{iox2_entry_value_uninit_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_entry_value_uninit_storage_t}(x + 8)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 56)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_entry_value_uninit_t, f::Symbol)
    r = Ref{iox2_entry_value_uninit_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_entry_value_uninit_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_entry_value_uninit_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_entry_value_uninit_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [`iox2_entry_value_uninit_t`](@ref). Passing the handle to a function transfers the ownership.
"""
const iox2_entry_value_uninit_h = Ptr{iox2_entry_value_uninit_h_t}

"""
The non-owning handle for [`iox2_entry_handle_mut_t`](@ref). Passing the handle to a function does not transfer the ownership.
"""
const iox2_entry_handle_mut_h_ref = Ptr{iox2_entry_handle_mut_h}

"""
The non-owning handle for [`iox2_entry_value_uninit_t`](@ref). Passing the handle to a function does not transfer the ownership.
"""
const iox2_entry_value_uninit_h_ref = Ptr{iox2_entry_value_uninit_h}

struct iox2_entry_handle_mut_storage_t
    data::NTuple{40, UInt8}
end

function Base.getproperty(x::Ptr{iox2_entry_handle_mut_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{40, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_entry_handle_mut_storage_t, f::Symbol)
    r = Ref{iox2_entry_handle_mut_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_entry_handle_mut_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_entry_handle_mut_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_entry_handle_mut_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_entry_handle_mut_t
    data::NTuple{56, UInt8}
end

function Base.getproperty(x::Ptr{iox2_entry_handle_mut_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_entry_handle_mut_storage_t}(x + 8)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 48)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_entry_handle_mut_t, f::Symbol)
    r = Ref{iox2_entry_handle_mut_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_entry_handle_mut_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_entry_handle_mut_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_entry_handle_mut_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct CFileDescriptor
    value::Int32
    is_owned::Bool
end

"""
The immutable pointer to the underlying `FileDescriptor`
"""
const iox2_file_descriptor_ptr = Ptr{CFileDescriptor}

"""
The owning handle for [`iox2_file_descriptor_t`](@ref). Passing the handle to an function transfers the ownership.
"""
const iox2_file_descriptor_h = Ptr{iox2_file_descriptor_h_t}

struct iox2_file_descriptor_storage_t
    data::NTuple{8, UInt8}
end

function Base.getproperty(x::Ptr{iox2_file_descriptor_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{8, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_file_descriptor_storage_t, f::Symbol)
    r = Ref{iox2_file_descriptor_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_file_descriptor_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_file_descriptor_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_file_descriptor_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_file_descriptor_t
    data::NTuple{16, UInt8}
end

function Base.getproperty(x::Ptr{iox2_file_descriptor_t}, f::Symbol)
    f === :value && return Ptr{iox2_file_descriptor_storage_t}(x + 0)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_file_descriptor_t, f::Symbol)
    r = Ref{iox2_file_descriptor_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_file_descriptor_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_file_descriptor_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_file_descriptor_t, private::Bool = false)
    (:value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [`iox2_listener_t`](@ref). Passing the handle to an function transfers the ownership.
"""
const iox2_listener_h = Ptr{iox2_listener_h_t}

"""
The non-owning handle for [`iox2_listener_t`](@ref). Passing the handle to an function does not transfers the ownership.
"""
const iox2_listener_h_ref = Ptr{iox2_listener_h}

# typedef void ( * iox2_listener_wait_all_callback ) ( const struct iox2_event_id_t * , iox2_callback_context )
const iox2_listener_wait_all_callback = Ptr{Cvoid}

"""
    iox2_unique_listener_id_storage_t

The system-wide unique id of a [`iox2_listener_t`](@ref).
"""
struct iox2_unique_listener_id_storage_t
    data::NTuple{20, UInt8}
end

function Base.getproperty(x::Ptr{iox2_unique_listener_id_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{20, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_unique_listener_id_storage_t, f::Symbol)
    r = Ref{iox2_unique_listener_id_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_unique_listener_id_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_unique_listener_id_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_unique_listener_id_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_unique_listener_id_t
    data::NTuple{32, UInt8}
end

function Base.getproperty(x::Ptr{iox2_unique_listener_id_t}, f::Symbol)
    f === :value && return Ptr{iox2_unique_listener_id_storage_t}(x + 0)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_unique_listener_id_t, f::Symbol)
    r = Ref{iox2_unique_listener_id_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_unique_listener_id_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_unique_listener_id_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_unique_listener_id_t, private::Bool = false)
    (:value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [[`iox2_unique_listener_id_t`](@ref)]. Passing the handle to an function transfers the ownership.
"""
const iox2_unique_listener_id_h = Ptr{iox2_unique_listener_id_h_t}

"""
The immutable pointer to the underlying `ListenerDetails`
"""
const iox2_listener_details_ptr = Ptr{iox2_listener_details_ptr_t}

# typedef void ( * iox2_log_callback ) ( enum iox2_log_level_e , const char * , const char * )
"""
The custom log callback for [[`iox2_set_logger`](@ref)]

# Arguments

1. The log level of the message 2. The origin of the message 3. The actual log message
"""
const iox2_log_callback = Ptr{Cvoid}

"""
The immutable pointer to the underlying `NodeName`
"""
const iox2_node_name_ptr = Ptr{iox2_node_name_ptr_t}

"""
The owning handle for [`iox2_node_t`](@ref). Passing the handle to an function transfers the ownership.
"""
const iox2_node_h = Ptr{iox2_name_h_t}

"""
The non-owning handle for [`iox2_node_t`](@ref). Passing the handle to an function does not transfers the ownership.
"""
const iox2_node_h_ref = Ptr{iox2_node_h}

"""
The owning handle for [`iox2_node_id_t`](@ref). Passing the handle to an function transfers the ownership.
"""
const iox2_node_id_h = Ptr{iox2_node_id_h_t}

"""
The non-owning handle for [`iox2_node_id_t`](@ref). Passing the handle to an function does not transfers the ownership.
"""
const iox2_node_id_h_ref = Ptr{iox2_node_id_h}

# typedef enum iox2_callback_progression_e ( * iox2_node_list_callback ) ( enum iox2_node_state_e , iox2_node_id_ptr , const char * , iox2_node_name_ptr , iox2_config_ptr , iox2_callback_context )
"""
The callback for [[`iox2_node_list`](@ref)]

# Arguments

* [[`iox2_node_state_e`](@ref)] * [[`iox2_node_id_ptr`](@ref)] * [[`iox2_node_name_ptr`](@ref)](crate::[`iox2_node_name_ptr`](@ref)) -> `NULL` for `[`iox2_node_state_e`](@ref)::INACCESSIBLE` and `[`iox2_node_state_e`](@ref)::UNDEFINED` * [[`iox2_config_ptr`](@ref)](crate::[`iox2_config_ptr`](@ref)) -> `NULL` for `[`iox2_node_state_e`](@ref)::INACCESSIBLE` and `[`iox2_node_state_e`](@ref)::UNDEFINED` * [[`iox2_callback_context`](@ref)] -> provided by the user to [[`iox2_node_list`](@ref)] and can be `NULL`

Returns a [[`iox2_callback_progression_e`](@ref)](crate::[`iox2_callback_progression_e`](@ref))
"""
const iox2_node_list_callback = Ptr{Cvoid}

"""
The owning handle for [`iox2_service_builder_t`](@ref). Passing the handle to an function transfers the ownership.
"""
const iox2_service_builder_h = Ptr{iox2_service_builder_h_t}

struct iox2_service_builder_storage_t
    data::NTuple{9104, UInt8}
end

function Base.getproperty(x::Ptr{iox2_service_builder_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{9104, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_service_builder_storage_t, f::Symbol)
    r = Ref{iox2_service_builder_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_service_builder_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_service_builder_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_service_builder_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_service_builder_t
    data::NTuple{9120, UInt8}
end

function Base.getproperty(x::Ptr{iox2_service_builder_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_service_builder_storage_t}(x + 8)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 9112)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_service_builder_t, f::Symbol)
    r = Ref{iox2_service_builder_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_service_builder_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_service_builder_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_service_builder_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The immutable pointer to the underlying `ServiceName`
"""
const iox2_service_name_ptr = Ptr{iox2_service_name_ptr_t}

"""
The owning handle for [`iox2_node_builder_t`](@ref). Passing the handle to an function transfers the ownership.
"""
const iox2_node_builder_h = Ptr{iox2_node_builder_h_t}

struct iox2_node_builder_storage_t
    data::NTuple{18696, UInt8}
end

function Base.getproperty(x::Ptr{iox2_node_builder_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{18696, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_node_builder_storage_t, f::Symbol)
    r = Ref{iox2_node_builder_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_node_builder_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_node_builder_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_node_builder_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_node_builder_t
    data::NTuple{18704, UInt8}
end

function Base.getproperty(x::Ptr{iox2_node_builder_t}, f::Symbol)
    f === :value && return Ptr{iox2_node_builder_storage_t}(x + 0)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 18696)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_node_builder_t, f::Symbol)
    r = Ref{iox2_node_builder_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_node_builder_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_node_builder_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_node_builder_t, private::Bool = false)
    (:value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The non-owning handle for [`iox2_node_builder_t`](@ref). Passing the handle to an function does not transfers the ownership.
"""
const iox2_node_builder_h_ref = Ptr{iox2_node_builder_h}

struct iox2_node_storage_t
    data::NTuple{16, UInt8}
end

function Base.getproperty(x::Ptr{iox2_node_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{16, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_node_storage_t, f::Symbol)
    r = Ref{iox2_node_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_node_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_node_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_node_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_node_t
    data::NTuple{32, UInt8}
end

function Base.getproperty(x::Ptr{iox2_node_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_node_storage_t}(x + 8)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_node_t, f::Symbol)
    r = Ref{iox2_node_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_node_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_node_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_node_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_node_id_storage_t
    data::NTuple{24, UInt8}
end

function Base.getproperty(x::Ptr{iox2_node_id_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{20, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_node_id_storage_t, f::Symbol)
    r = Ref{iox2_node_id_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_node_id_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_node_id_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_node_id_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_node_id_t
    data::NTuple{32, UInt8}
end

function Base.getproperty(x::Ptr{iox2_node_id_t}, f::Symbol)
    f === :value && return Ptr{iox2_node_id_storage_t}(x + 0)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_node_id_t, f::Symbol)
    r = Ref{iox2_node_id_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_node_id_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_node_id_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_node_id_t, private::Bool = false)
    (:value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_node_name_storage_t
    data::NTuple{152, UInt8}
end

function Base.getproperty(x::Ptr{iox2_node_name_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{152, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_node_name_storage_t, f::Symbol)
    r = Ref{iox2_node_name_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_node_name_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_node_name_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_node_name_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_node_name_t
    data::NTuple{160, UInt8}
end

function Base.getproperty(x::Ptr{iox2_node_name_t}, f::Symbol)
    f === :value && return Ptr{iox2_node_name_storage_t}(x + 0)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 152)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_node_name_t, f::Symbol)
    r = Ref{iox2_node_name_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_node_name_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_node_name_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_node_name_t, private::Bool = false)
    (:value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [`iox2_node_name_t`](@ref). Passing the handle to an function transfers the ownership.
"""
const iox2_node_name_h = Ptr{iox2_node_name_h_t}

"""
The owning handle for [`iox2_notifier_t`](@ref). Passing the handle to an function transfers the ownership.
"""
const iox2_notifier_h = Ptr{iox2_notifier_h_t}

"""
The non-owning handle for [`iox2_notifier_t`](@ref). Passing the handle to an function does not transfers the ownership.
"""
const iox2_notifier_h_ref = Ptr{iox2_notifier_h}

"""
    iox2_unique_notifier_id_storage_t

The system-wide unique id of a [`iox2_notifier_t`](@ref).
"""
struct iox2_unique_notifier_id_storage_t
    data::NTuple{20, UInt8}
end

function Base.getproperty(x::Ptr{iox2_unique_notifier_id_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{20, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_unique_notifier_id_storage_t, f::Symbol)
    r = Ref{iox2_unique_notifier_id_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_unique_notifier_id_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_unique_notifier_id_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_unique_notifier_id_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_unique_notifier_id_t
    data::NTuple{32, UInt8}
end

function Base.getproperty(x::Ptr{iox2_unique_notifier_id_t}, f::Symbol)
    f === :value && return Ptr{iox2_unique_notifier_id_storage_t}(x + 0)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_unique_notifier_id_t, f::Symbol)
    r = Ref{iox2_unique_notifier_id_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_unique_notifier_id_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_unique_notifier_id_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_unique_notifier_id_t, private::Bool = false)
    (:value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [[`iox2_unique_notifier_id_t`](@ref)]. Passing the handle to an function transfers the ownership.
"""
const iox2_unique_notifier_id_h = Ptr{iox2_unique_notifier_id_h_t}

"""
The immutable pointer to the underlying `NotifierDetails`
"""
const iox2_notifier_details_ptr = Ptr{iox2_notifier_details_ptr_t}

"""
The non-owning handle for [`iox2_pending_response_t`](@ref). Passing the handle to a function does not transfer the ownership.
"""
const iox2_pending_response_h_ref = Ptr{iox2_pending_response_h}

struct iox2_response_storage_t
    data::NTuple{96, UInt8}
end

function Base.getproperty(x::Ptr{iox2_response_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{96, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_response_storage_t, f::Symbol)
    r = Ref{iox2_response_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_response_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_response_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_response_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_response_t
    data::NTuple{128, UInt8}
end

function Base.getproperty(x::Ptr{iox2_response_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_response_storage_t}(x + 16)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 112)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_response_t, f::Symbol)
    r = Ref{iox2_response_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_response_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_response_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_response_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [`iox2_response_t`](@ref). Passing the handle to a function transfers the ownership.
"""
const iox2_response_h = Ptr{iox2_response_h_t}

"""
The owning handle for [`iox2_port_factory_writer_builder_t`](@ref). Passing the handle to a function transfers the ownership.
"""
const iox2_port_factory_writer_builder_h = Ptr{iox2_port_factory_writer_builder_h_t}

"""
The owning handle for [`iox2_port_factory_blackboard_t`](@ref). Passing the handle to a function transfers the ownership.
"""
const iox2_port_factory_blackboard_h = Ptr{iox2_port_factory_blackboard_h_t}

"""
The non-owning handle for [`iox2_port_factory_blackboard_t`](@ref). Passing the handle to a function does not transfer the ownership.
"""
const iox2_port_factory_blackboard_h_ref = Ptr{iox2_port_factory_blackboard_h}

struct iox2_port_factory_writer_builder_storage_t
    data::NTuple{16, UInt8}
end

function Base.getproperty(x::Ptr{iox2_port_factory_writer_builder_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{16, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_port_factory_writer_builder_storage_t, f::Symbol)
    r = Ref{iox2_port_factory_writer_builder_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_port_factory_writer_builder_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_port_factory_writer_builder_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_port_factory_writer_builder_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_port_factory_writer_builder_t
    data::NTuple{32, UInt8}
end

function Base.getproperty(x::Ptr{iox2_port_factory_writer_builder_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_port_factory_writer_builder_storage_t}(x + 8)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_port_factory_writer_builder_t, f::Symbol)
    r = Ref{iox2_port_factory_writer_builder_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_port_factory_writer_builder_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_port_factory_writer_builder_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_port_factory_writer_builder_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [`iox2_port_factory_reader_builder_t`](@ref). Passing the handle to a function transfers the ownership.
"""
const iox2_port_factory_reader_builder_h = Ptr{iox2_port_factory_reader_builder_h_t}

struct iox2_port_factory_reader_builder_storage_t
    data::NTuple{16, UInt8}
end

function Base.getproperty(x::Ptr{iox2_port_factory_reader_builder_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{16, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_port_factory_reader_builder_storage_t, f::Symbol)
    r = Ref{iox2_port_factory_reader_builder_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_port_factory_reader_builder_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_port_factory_reader_builder_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_port_factory_reader_builder_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_port_factory_reader_builder_t
    data::NTuple{32, UInt8}
end

function Base.getproperty(x::Ptr{iox2_port_factory_reader_builder_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_port_factory_reader_builder_storage_t}(x + 8)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_port_factory_reader_builder_t, f::Symbol)
    r = Ref{iox2_port_factory_reader_builder_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_port_factory_reader_builder_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_port_factory_reader_builder_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_port_factory_reader_builder_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_type_detail_t
    variant::iox2_type_variant_e
    type_name::NTuple{256, Cchar}
    size::Csize_t
    alignment::Csize_t
end

struct iox2_static_config_blackboard_t
    max_readers::Csize_t
    max_writers::Csize_t
    max_nodes::Csize_t
    type_details::iox2_type_detail_t
end

"""
The immutable pointer to the underlying `ReaderDetails`
"""
const iox2_reader_details_ptr = Ptr{iox2_reader_details_ptr_t}

# typedef enum iox2_callback_progression_e ( * iox2_list_readers_callback ) ( iox2_callback_context , iox2_reader_details_ptr )
"""
The callback for [`[`iox2_port_factory_blackboard_dynamic_config_list_readers`](@ref)()`]

# Arguments

* [[`iox2_callback_context`](@ref)] -> provided by the user and can be `NULL` * [[`iox2_reader_details_ptr`](@ref)] -> a pointer to the details struct of the port

Returns a [[`iox2_callback_progression_e`](@ref)](crate::[`iox2_callback_progression_e`](@ref))
"""
const iox2_list_readers_callback = Ptr{Cvoid}

"""
The immutable pointer to the underlying `WriterDetails`
"""
const iox2_writer_details_ptr = Ptr{iox2_writer_details_ptr_t}

# typedef enum iox2_callback_progression_e ( * iox2_list_writers_callback ) ( iox2_callback_context , iox2_writer_details_ptr )
"""
The callback for [`[`iox2_port_factory_blackboard_dynamic_config_list_writers`](@ref)()`]

# Arguments

* [[`iox2_callback_context`](@ref)] -> provided by the user and can be `NULL` * [[`iox2_writer_details_ptr`](@ref)] -> a pointer to the details struct of the port

Returns a [[`iox2_callback_progression_e`](@ref)](crate::[`iox2_callback_progression_e`](@ref))
"""
const iox2_list_writers_callback = Ptr{Cvoid}

# typedef enum iox2_callback_progression_e ( * iox2_port_factory_blackboard_list_keys_callback ) ( const void * , iox2_callback_context )
const iox2_port_factory_blackboard_list_keys_callback = Ptr{Cvoid}

"""
The owning handle for [`iox2_port_factory_client_builder_t`](@ref). Passing the handle to a function transfers the ownership.
"""
const iox2_port_factory_client_builder_h = Ptr{iox2_port_factory_client_builder_h_t}

"""
The non-owning handle for [`iox2_port_factory_client_builder_t`](@ref). Passing the handle to a function does not transfer the ownership.
"""
const iox2_port_factory_client_builder_h_ref = Ptr{iox2_port_factory_client_builder_h}

struct iox2_client_storage_t
    data::NTuple{256, UInt8}
end

function Base.getproperty(x::Ptr{iox2_client_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{248, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_client_storage_t, f::Symbol)
    r = Ref{iox2_client_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_client_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_client_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_client_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_client_t
    data::NTuple{288, UInt8}
end

function Base.getproperty(x::Ptr{iox2_client_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_client_storage_t}(x + 16)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 272)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_client_t, f::Symbol)
    r = Ref{iox2_client_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_client_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_client_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_client_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [`iox2_port_factory_event_t`](@ref). Passing the handle to an function transfers the ownership.
"""
const iox2_port_factory_event_h = Ptr{iox2_port_factory_event_h_t}

"""
The non-owning handle for [`iox2_port_factory_event_t`](@ref). Passing the handle to an function does not transfers the ownership.
"""
const iox2_port_factory_event_h_ref = Ptr{iox2_port_factory_event_h}

struct iox2_static_config_event_t
    max_notifiers::Csize_t
    max_listeners::Csize_t
    max_nodes::Csize_t
    event_id_max_value::Csize_t
    notifier_dead_event::Csize_t
    has_notifier_dead_event::Bool
    notifier_dropped_event::Csize_t
    has_notifier_dropped_event::Bool
    notifier_created_event::Csize_t
    has_notifier_created_event::Bool
    deadline_seconds::UInt64
    deadline_nanoseconds::UInt32
    has_deadline::Bool
end

"""
The owning handle for [`iox2_port_factory_notifier_builder_t`](@ref). Passing the handle to an function transfers the ownership.
"""
const iox2_port_factory_notifier_builder_h = Ptr{iox2_port_factory_notifier_builder_h_t}

struct iox2_port_factory_notifier_builder_storage_t
    data::NTuple{24, UInt8}
end

function Base.getproperty(x::Ptr{iox2_port_factory_notifier_builder_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{24, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_port_factory_notifier_builder_storage_t, f::Symbol)
    r = Ref{iox2_port_factory_notifier_builder_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_port_factory_notifier_builder_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_port_factory_notifier_builder_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_port_factory_notifier_builder_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_port_factory_notifier_builder_t
    data::NTuple{40, UInt8}
end

function Base.getproperty(x::Ptr{iox2_port_factory_notifier_builder_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_port_factory_notifier_builder_storage_t}(x + 8)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 32)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_port_factory_notifier_builder_t, f::Symbol)
    r = Ref{iox2_port_factory_notifier_builder_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_port_factory_notifier_builder_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_port_factory_notifier_builder_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_port_factory_notifier_builder_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [`iox2_port_factory_listener_builder_t`](@ref). Passing the handle to an function transfers the ownership.
"""
const iox2_port_factory_listener_builder_h = Ptr{iox2_port_factory_listener_builder_h_t}

struct iox2_port_factory_listener_builder_storage_t
    data::NTuple{24, UInt8}
end

function Base.getproperty(x::Ptr{iox2_port_factory_listener_builder_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{24, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_port_factory_listener_builder_storage_t, f::Symbol)
    r = Ref{iox2_port_factory_listener_builder_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_port_factory_listener_builder_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_port_factory_listener_builder_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_port_factory_listener_builder_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_port_factory_listener_builder_t
    data::NTuple{40, UInt8}
end

function Base.getproperty(x::Ptr{iox2_port_factory_listener_builder_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_port_factory_listener_builder_storage_t}(x + 8)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 32)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_port_factory_listener_builder_t, f::Symbol)
    r = Ref{iox2_port_factory_listener_builder_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_port_factory_listener_builder_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_port_factory_listener_builder_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_port_factory_listener_builder_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

# typedef enum iox2_callback_progression_e ( * iox2_list_listeners_callback ) ( iox2_callback_context , iox2_listener_details_ptr )
"""
The callback for [`[`iox2_port_factory_event_dynamic_config_list_listeners`](@ref)()`]

# Arguments

* [[`iox2_callback_context`](@ref)] -> provided by the user and can be `NULL` * [[`iox2_listener_details_ptr`](@ref)] -> a pointer to the details struct of the port

Returns a [[`iox2_callback_progression_e`](@ref)](crate::[`iox2_callback_progression_e`](@ref))
"""
const iox2_list_listeners_callback = Ptr{Cvoid}

# typedef enum iox2_callback_progression_e ( * iox2_list_notifiers_callback ) ( iox2_callback_context , iox2_notifier_details_ptr )
"""
The callback for [`[`iox2_port_factory_event_dynamic_config_list_notifiers`](@ref)()`]

# Arguments

* [[`iox2_callback_context`](@ref)] -> provided by the user and can be `NULL` * [[`iox2_notifier_details_ptr`](@ref)] -> a pointer to the details struct of the port

Returns a [[`iox2_callback_progression_e`](@ref)](crate::[`iox2_callback_progression_e`](@ref))
"""
const iox2_list_notifiers_callback = Ptr{Cvoid}

struct iox2_listener_storage_t
    data::NTuple{1656, UInt8}
end

function Base.getproperty(x::Ptr{iox2_listener_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{1656, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_listener_storage_t, f::Symbol)
    r = Ref{iox2_listener_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_listener_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_listener_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_listener_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_listener_t
    data::NTuple{1672, UInt8}
end

function Base.getproperty(x::Ptr{iox2_listener_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_listener_storage_t}(x + 8)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 1664)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_listener_t, f::Symbol)
    r = Ref{iox2_listener_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_listener_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_listener_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_listener_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The non-owning handle for [`iox2_port_factory_notifier_builder_t`](@ref). Passing the handle to an function does not transfers the ownership.
"""
const iox2_port_factory_notifier_builder_h_ref = Ptr{iox2_port_factory_notifier_builder_h}

struct iox2_notifier_storage_t
    data::NTuple{1656, UInt8}
end

function Base.getproperty(x::Ptr{iox2_notifier_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{1656, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_notifier_storage_t, f::Symbol)
    r = Ref{iox2_notifier_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_notifier_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_notifier_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_notifier_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_notifier_t
    data::NTuple{1672, UInt8}
end

function Base.getproperty(x::Ptr{iox2_notifier_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_notifier_storage_t}(x + 8)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 1664)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_notifier_t, f::Symbol)
    r = Ref{iox2_notifier_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_notifier_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_notifier_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_notifier_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [`iox2_port_factory_publisher_builder_t`](@ref). Passing the handle to an function transfers the ownership.
"""
const iox2_port_factory_publisher_builder_h = Ptr{iox2_port_factory_publisher_builder_h_t}

"""
The owning handle for [`iox2_port_factory_pub_sub_t`](@ref). Passing the handle to an function transfers the ownership.
"""
const iox2_port_factory_pub_sub_h = Ptr{iox2_port_factory_pub_sub_h_t}

"""
The non-owning handle for [`iox2_port_factory_pub_sub_t`](@ref). Passing the handle to an function does not transfers the ownership.
"""
const iox2_port_factory_pub_sub_h_ref = Ptr{iox2_port_factory_pub_sub_h}

struct iox2_port_factory_publisher_builder_storage_t
    data::NTuple{128, UInt8}
end

function Base.getproperty(x::Ptr{iox2_port_factory_publisher_builder_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{128, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_port_factory_publisher_builder_storage_t, f::Symbol)
    r = Ref{iox2_port_factory_publisher_builder_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_port_factory_publisher_builder_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_port_factory_publisher_builder_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_port_factory_publisher_builder_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_port_factory_publisher_builder_t
    data::NTuple{160, UInt8}
end

function Base.getproperty(x::Ptr{iox2_port_factory_publisher_builder_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_port_factory_publisher_builder_storage_t}(x + 16)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 144)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_port_factory_publisher_builder_t, f::Symbol)
    r = Ref{iox2_port_factory_publisher_builder_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_port_factory_publisher_builder_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_port_factory_publisher_builder_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_port_factory_publisher_builder_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [`iox2_port_factory_subscriber_builder_t`](@ref). Passing the handle to an function transfers the ownership.
"""
const iox2_port_factory_subscriber_builder_h = Ptr{iox2_port_factory_subscriber_builder_h_t}

struct iox2_port_factory_subscriber_builder_storage_t
    data::NTuple{112, UInt8}
end

function Base.getproperty(x::Ptr{iox2_port_factory_subscriber_builder_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{112, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_port_factory_subscriber_builder_storage_t, f::Symbol)
    r = Ref{iox2_port_factory_subscriber_builder_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_port_factory_subscriber_builder_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_port_factory_subscriber_builder_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_port_factory_subscriber_builder_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_port_factory_subscriber_builder_t
    data::NTuple{144, UInt8}
end

function Base.getproperty(x::Ptr{iox2_port_factory_subscriber_builder_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_port_factory_subscriber_builder_storage_t}(x + 16)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 128)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_port_factory_subscriber_builder_t, f::Symbol)
    r = Ref{iox2_port_factory_subscriber_builder_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_port_factory_subscriber_builder_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_port_factory_subscriber_builder_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_port_factory_subscriber_builder_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_message_type_details_t
    header::iox2_type_detail_t
    user_header::iox2_type_detail_t
    payload::iox2_type_detail_t
end

struct iox2_static_config_publish_subscribe_t
    max_subscribers::Csize_t
    max_publishers::Csize_t
    max_nodes::Csize_t
    history_size::Csize_t
    subscriber_max_buffer_size::Csize_t
    subscriber_max_borrowed_samples::Csize_t
    enable_safe_overflow::Bool
    message_type_details::iox2_message_type_details_t
end

"""
The immutable pointer to the underlying `SubscriberDetails`
"""
const iox2_subscriber_details_ptr = Ptr{iox2_subscriber_details_ptr_t}

# typedef enum iox2_callback_progression_e ( * iox2_list_subscribers_callback ) ( iox2_callback_context , iox2_subscriber_details_ptr )
"""
The callback for [`[`iox2_port_factory_pub_sub_dynamic_config_list_subscribers`](@ref)()`]

# Arguments

* [[`iox2_callback_context`](@ref)] -> provided by the user and can be `NULL` * [[`iox2_subscriber_details_ptr`](@ref)] -> a pointer to the details struct of the port

Returns a [[`iox2_callback_progression_e`](@ref)](crate::[`iox2_callback_progression_e`](@ref))
"""
const iox2_list_subscribers_callback = Ptr{Cvoid}

"""
The immutable pointer to the underlying `PublisherDetails`
"""
const iox2_publisher_details_ptr = Ptr{iox2_publisher_details_ptr_t}

# typedef enum iox2_callback_progression_e ( * iox2_list_publishers_callback ) ( iox2_callback_context , iox2_publisher_details_ptr )
"""
The callback for [`[`iox2_port_factory_pub_sub_dynamic_config_list_publishers`](@ref)()`]

# Arguments

* [[`iox2_callback_context`](@ref)] -> provided by the user and can be `NULL` * [[`iox2_publisher_details_ptr`](@ref)] -> a pointer to the details struct of the port

Returns a [[`iox2_callback_progression_e`](@ref)](crate::[`iox2_callback_progression_e`](@ref))
"""
const iox2_list_publishers_callback = Ptr{Cvoid}

"""
The non-owning handle for [`iox2_port_factory_publisher_builder_t`](@ref). Passing the handle to an function does not transfers the ownership.
"""
const iox2_port_factory_publisher_builder_h_ref = Ptr{iox2_port_factory_publisher_builder_h}

struct iox2_publisher_storage_t
    data::NTuple{256, UInt8}
end

function Base.getproperty(x::Ptr{iox2_publisher_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{248, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_publisher_storage_t, f::Symbol)
    r = Ref{iox2_publisher_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_publisher_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_publisher_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_publisher_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_publisher_t
    data::NTuple{288, UInt8}
end

function Base.getproperty(x::Ptr{iox2_publisher_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_publisher_storage_t}(x + 16)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 272)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_publisher_t, f::Symbol)
    r = Ref{iox2_publisher_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_publisher_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_publisher_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_publisher_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [`iox2_publisher_t`](@ref). Passing the handle to an function transfers the ownership.
"""
const iox2_publisher_h = Ptr{iox2_publisher_h_t}

struct iox2_reader_storage_t
    data::NTuple{32, UInt8}
end

function Base.getproperty(x::Ptr{iox2_reader_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{32, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_reader_storage_t, f::Symbol)
    r = Ref{iox2_reader_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_reader_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_reader_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_reader_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_reader_t
    data::NTuple{48, UInt8}
end

function Base.getproperty(x::Ptr{iox2_reader_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_reader_storage_t}(x + 8)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 40)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_reader_t, f::Symbol)
    r = Ref{iox2_reader_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_reader_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_reader_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_reader_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [`iox2_reader_t`](@ref). Passing the handle to a function transfers the ownership.
"""
const iox2_reader_h = Ptr{iox2_reader_h_t}

"""
The owning handle for [`iox2_port_factory_server_builder_t`](@ref). Passing the handle to a function transfers the ownership.
"""
const iox2_port_factory_server_builder_h = Ptr{iox2_port_factory_server_builder_h_t}

"""
The owning handle for [`iox2_port_factory_request_response_t`](@ref). Passing the handle to a function transfers the ownership.
"""
const iox2_port_factory_request_response_h = Ptr{iox2_port_factory_request_response_h_t}

"""
The non-owning handle for [`iox2_port_factory_request_response_t`](@ref). Passing the handle to a function does not transfer the ownership.
"""
const iox2_port_factory_request_response_h_ref = Ptr{iox2_port_factory_request_response_h}

struct iox2_port_factory_server_builder_storage_t
    data::NTuple{176, UInt8}
end

function Base.getproperty(x::Ptr{iox2_port_factory_server_builder_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{176, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_port_factory_server_builder_storage_t, f::Symbol)
    r = Ref{iox2_port_factory_server_builder_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_port_factory_server_builder_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_port_factory_server_builder_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_port_factory_server_builder_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_port_factory_server_builder_t
    data::NTuple{208, UInt8}
end

function Base.getproperty(x::Ptr{iox2_port_factory_server_builder_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_port_factory_server_builder_storage_t}(x + 16)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 192)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_port_factory_server_builder_t, f::Symbol)
    r = Ref{iox2_port_factory_server_builder_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_port_factory_server_builder_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_port_factory_server_builder_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_port_factory_server_builder_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_port_factory_client_builder_storage_t
    data::NTuple{176, UInt8}
end

function Base.getproperty(x::Ptr{iox2_port_factory_client_builder_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{176, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_port_factory_client_builder_storage_t, f::Symbol)
    r = Ref{iox2_port_factory_client_builder_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_port_factory_client_builder_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_port_factory_client_builder_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_port_factory_client_builder_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_port_factory_client_builder_t
    data::NTuple{208, UInt8}
end

function Base.getproperty(x::Ptr{iox2_port_factory_client_builder_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_port_factory_client_builder_storage_t}(x + 16)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 192)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_port_factory_client_builder_t, f::Symbol)
    r = Ref{iox2_port_factory_client_builder_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_port_factory_client_builder_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_port_factory_client_builder_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_port_factory_client_builder_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_static_config_request_response_t
    enable_safe_overflow_for_requests::Bool
    enable_safe_overflow_for_responses::Bool
    enable_fire_and_forget_requests::Bool
    max_active_requests_per_client::Csize_t
    max_loaned_requests::Csize_t
    max_response_buffer_size::Csize_t
    max_servers::Csize_t
    max_clients::Csize_t
    max_nodes::Csize_t
    max_borrowed_responses_per_pending_response::Csize_t
    request_message_type_details::iox2_message_type_details_t
    response_message_type_details::iox2_message_type_details_t
end

"""
The immutable pointer to the underlying `ServerDetails`
"""
const iox2_server_details_ptr = Ptr{iox2_server_details_ptr_t}

# typedef enum iox2_callback_progression_e ( * iox2_list_servers_callback ) ( iox2_callback_context , iox2_server_details_ptr )
"""
The callback for [`[`iox2_port_factory_request_response_dynamic_config_list_servers`](@ref)()`]

# Arguments

* [[`iox2_callback_context`](@ref)] -> provided by the user and can be `NULL` * [[`iox2_server_details_ptr`](@ref)] -> a pointer to the details struct of the port

Returns a [[`iox2_callback_progression_e`](@ref)](crate::[`iox2_callback_progression_e`](@ref))
"""
const iox2_list_servers_callback = Ptr{Cvoid}

# typedef enum iox2_callback_progression_e ( * iox2_list_clients_callback ) ( iox2_callback_context , iox2_client_details_ptr )
"""
The callback for [`[`iox2_port_factory_request_response_dynamic_config_list_clients`](@ref)()`]

# Arguments

* [[`iox2_callback_context`](@ref)] -> provided by the user and can be `NULL` * [[`iox2_client_details_ptr`](@ref)] -> a pointer to the details struct of the port

Returns a [[`iox2_callback_progression_e`](@ref)](crate::[`iox2_callback_progression_e`](@ref))
"""
const iox2_list_clients_callback = Ptr{Cvoid}

"""
The non-owning handle for [`iox2_port_factory_server_builder_t`](@ref). Passing the handle to a function does not transfer the ownership.
"""
const iox2_port_factory_server_builder_h_ref = Ptr{iox2_port_factory_server_builder_h}

struct iox2_server_storage_t
    data::NTuple{256, UInt8}
end

function Base.getproperty(x::Ptr{iox2_server_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{248, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_server_storage_t, f::Symbol)
    r = Ref{iox2_server_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_server_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_server_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_server_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_server_t
    data::NTuple{288, UInt8}
end

function Base.getproperty(x::Ptr{iox2_server_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_server_storage_t}(x + 16)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 272)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_server_t, f::Symbol)
    r = Ref{iox2_server_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_server_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_server_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_server_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [`iox2_server_t`](@ref). Passing the handle to a function transfers the ownership.
"""
const iox2_server_h = Ptr{iox2_server_h_t}

"""
The non-owning handle for [`iox2_port_factory_subscriber_builder_t`](@ref). Passing the handle to an function does not transfers the ownership.
"""
const iox2_port_factory_subscriber_builder_h_ref = Ptr{iox2_port_factory_subscriber_builder_h}

struct iox2_subscriber_storage_t
    data::NTuple{1232, UInt8}
end

function Base.getproperty(x::Ptr{iox2_subscriber_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{1232, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_subscriber_storage_t, f::Symbol)
    r = Ref{iox2_subscriber_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_subscriber_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_subscriber_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_subscriber_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_subscriber_t
    data::NTuple{1264, UInt8}
end

function Base.getproperty(x::Ptr{iox2_subscriber_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_subscriber_storage_t}(x + 16)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 1248)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_subscriber_t, f::Symbol)
    r = Ref{iox2_subscriber_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_subscriber_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_subscriber_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_subscriber_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [`iox2_subscriber_t`](@ref). Passing the handle to an function transfers the ownership.
"""
const iox2_subscriber_h = Ptr{iox2_subscriber_h_t}

struct iox2_writer_storage_t
    data::NTuple{32, UInt8}
end

function Base.getproperty(x::Ptr{iox2_writer_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{32, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_writer_storage_t, f::Symbol)
    r = Ref{iox2_writer_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_writer_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_writer_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_writer_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_writer_t
    data::NTuple{48, UInt8}
end

function Base.getproperty(x::Ptr{iox2_writer_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_writer_storage_t}(x + 8)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 40)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_writer_t, f::Symbol)
    r = Ref{iox2_writer_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_writer_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_writer_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_writer_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [`iox2_writer_t`](@ref). Passing the handle to a function transfers the ownership.
"""
const iox2_writer_h = Ptr{iox2_writer_h_t}

"""
The owning handle for [[`iox2_publish_subscribe_header_t`](@ref)]. Passing the handle to an function transfers the ownership.
"""
const iox2_publish_subscribe_header_h = Ptr{iox2_publish_subscribe_header_h_t}

"""
The non-owning handle for [[`iox2_publish_subscribe_header_t`](@ref)]. Passing the handle to an function does not transfers the ownership.
"""
const iox2_publish_subscribe_header_h_ref = Ptr{iox2_publish_subscribe_header_h}

"""
    iox2_unique_publisher_id_storage_t

The system-wide unique id of a [`iox2_publisher_t`](@ref).
"""
struct iox2_unique_publisher_id_storage_t
    data::NTuple{20, UInt8}
end

function Base.getproperty(x::Ptr{iox2_unique_publisher_id_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{20, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_unique_publisher_id_storage_t, f::Symbol)
    r = Ref{iox2_unique_publisher_id_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_unique_publisher_id_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_unique_publisher_id_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_unique_publisher_id_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_unique_publisher_id_t
    data::NTuple{32, UInt8}
end

function Base.getproperty(x::Ptr{iox2_unique_publisher_id_t}, f::Symbol)
    f === :value && return Ptr{iox2_unique_publisher_id_storage_t}(x + 0)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_unique_publisher_id_t, f::Symbol)
    r = Ref{iox2_unique_publisher_id_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_unique_publisher_id_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_unique_publisher_id_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_unique_publisher_id_t, private::Bool = false)
    (:value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [[`iox2_unique_publisher_id_t`](@ref)]. Passing the handle to an function transfers the ownership.
"""
const iox2_unique_publisher_id_h = Ptr{iox2_unique_publisher_id_h_t}

"""
The non-owning handle for [`iox2_publisher_t`](@ref). Passing the handle to an function does not transfers the ownership.
"""
const iox2_publisher_h_ref = Ptr{iox2_publisher_h}

struct iox2_sample_mut_storage_t
    data::NTuple{64, UInt8}
end

function Base.getproperty(x::Ptr{iox2_sample_mut_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{64, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_sample_mut_storage_t, f::Symbol)
    r = Ref{iox2_sample_mut_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_sample_mut_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_sample_mut_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_sample_mut_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_sample_mut_t
    data::NTuple{80, UInt8}
end

function Base.getproperty(x::Ptr{iox2_sample_mut_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_sample_mut_storage_t}(x + 8)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 72)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_sample_mut_t, f::Symbol)
    r = Ref{iox2_sample_mut_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_sample_mut_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_sample_mut_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_sample_mut_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [`iox2_sample_mut_t`](@ref). Passing the handle to an function transfers the ownership.
"""
const iox2_sample_mut_h = Ptr{iox2_sample_mut_h_t}

"""
The non-owning handle for [`iox2_reader_t`](@ref). Passing the handle to a function does not transfer the ownership.
"""
const iox2_reader_h_ref = Ptr{iox2_reader_h}

"""
    iox2_unique_reader_id_storage_t

The system-wide unique id of a [`iox2_reader_t`](@ref).
"""
struct iox2_unique_reader_id_storage_t
    data::NTuple{20, UInt8}
end

function Base.getproperty(x::Ptr{iox2_unique_reader_id_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{20, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_unique_reader_id_storage_t, f::Symbol)
    r = Ref{iox2_unique_reader_id_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_unique_reader_id_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_unique_reader_id_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_unique_reader_id_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_unique_reader_id_t
    data::NTuple{32, UInt8}
end

function Base.getproperty(x::Ptr{iox2_unique_reader_id_t}, f::Symbol)
    f === :value && return Ptr{iox2_unique_reader_id_storage_t}(x + 0)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_unique_reader_id_t, f::Symbol)
    r = Ref{iox2_unique_reader_id_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_unique_reader_id_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_unique_reader_id_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_unique_reader_id_t, private::Bool = false)
    (:value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [[`iox2_unique_reader_id_t`](@ref)]. Passing the handle to a function transfers the ownership.
"""
const iox2_unique_reader_id_h = Ptr{iox2_unique_reader_id_h_t}

struct iox2_entry_handle_storage_t
    data::NTuple{40, UInt8}
end

function Base.getproperty(x::Ptr{iox2_entry_handle_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{40, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_entry_handle_storage_t, f::Symbol)
    r = Ref{iox2_entry_handle_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_entry_handle_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_entry_handle_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_entry_handle_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_entry_handle_t
    data::NTuple{56, UInt8}
end

function Base.getproperty(x::Ptr{iox2_entry_handle_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_entry_handle_storage_t}(x + 8)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 48)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_entry_handle_t, f::Symbol)
    r = Ref{iox2_entry_handle_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_entry_handle_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_entry_handle_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_entry_handle_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The non-owning handle for [[`iox2_request_header_t`](@ref)]. Passing the handle to a function does not transfer the ownership.
"""
const iox2_request_header_h_ref = Ptr{iox2_request_header_h}

"""
The non-owning handle for [`iox2_request_mut_t`](@ref). Passing the handle to a function does not transfer the ownership.
"""
const iox2_request_mut_h_ref = Ptr{iox2_request_mut_h}

"""
The non-owning handle for [`iox2_response_t`](@ref). Passing the handle to a function does not transfer the ownership.
"""
const iox2_response_h_ref = Ptr{iox2_response_h}

"""
    iox2_response_header_storage_t

Response header used by `MessagingPattern::RequestResponse`
"""
struct iox2_response_header_storage_t
    data::NTuple{56, UInt8}
end

function Base.getproperty(x::Ptr{iox2_response_header_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{56, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_response_header_storage_t, f::Symbol)
    r = Ref{iox2_response_header_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_response_header_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_response_header_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_response_header_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_response_header_t
    data::NTuple{64, UInt8}
end

function Base.getproperty(x::Ptr{iox2_response_header_t}, f::Symbol)
    f === :value && return Ptr{iox2_response_header_storage_t}(x + 0)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 56)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_response_header_t, f::Symbol)
    r = Ref{iox2_response_header_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_response_header_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_response_header_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_response_header_t, private::Bool = false)
    (:value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [[`iox2_response_header_t`](@ref)]. Passing the handle to a function transfers the ownership.
"""
const iox2_response_header_h = Ptr{iox2_response_header_h_t}

"""
The non-owning handle for [[`iox2_response_header_t`](@ref)]. Passing the handle to a function does not transfer the ownership.
"""
const iox2_response_header_h_ref = Ptr{iox2_response_header_h}

"""
    iox2_unique_server_id_storage_t

The system-wide unique id of a [`iox2_server_t`](@ref).
"""
struct iox2_unique_server_id_storage_t
    data::NTuple{20, UInt8}
end

function Base.getproperty(x::Ptr{iox2_unique_server_id_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{20, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_unique_server_id_storage_t, f::Symbol)
    r = Ref{iox2_unique_server_id_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_unique_server_id_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_unique_server_id_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_unique_server_id_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_unique_server_id_t
    data::NTuple{32, UInt8}
end

function Base.getproperty(x::Ptr{iox2_unique_server_id_t}, f::Symbol)
    f === :value && return Ptr{iox2_unique_server_id_storage_t}(x + 0)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_unique_server_id_t, f::Symbol)
    r = Ref{iox2_unique_server_id_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_unique_server_id_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_unique_server_id_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_unique_server_id_t, private::Bool = false)
    (:value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [[`iox2_unique_server_id_t`](@ref)]. Passing the handle to an function transfers the ownership.
"""
const iox2_unique_server_id_h = Ptr{iox2_unique_server_id_h_t}

"""
The non-owning handle for [`iox2_response_mut_t`](@ref). Passing the handle to a function does not transfer the ownership.
"""
const iox2_response_mut_h_ref = Ptr{iox2_response_mut_h}

"""
The owning handle for [`iox2_sample_t`](@ref). Passing the handle to an function transfers the ownership.
"""
const iox2_sample_h = Ptr{iox2_sample_h_t}

"""
The non-owning handle for [`iox2_sample_t`](@ref). Passing the handle to an function does not transfers the ownership.
"""
const iox2_sample_h_ref = Ptr{iox2_sample_h}

"""
    iox2_publish_subscribe_header_storage_t

Sample header used by `MessagingPattern::PublishSubscribe`
"""
struct iox2_publish_subscribe_header_storage_t
    data::NTuple{48, UInt8}
end

function Base.getproperty(x::Ptr{iox2_publish_subscribe_header_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{48, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_publish_subscribe_header_storage_t, f::Symbol)
    r = Ref{iox2_publish_subscribe_header_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_publish_subscribe_header_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_publish_subscribe_header_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_publish_subscribe_header_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_publish_subscribe_header_t
    data::NTuple{56, UInt8}
end

function Base.getproperty(x::Ptr{iox2_publish_subscribe_header_t}, f::Symbol)
    f === :value && return Ptr{iox2_publish_subscribe_header_storage_t}(x + 0)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 48)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_publish_subscribe_header_t, f::Symbol)
    r = Ref{iox2_publish_subscribe_header_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_publish_subscribe_header_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_publish_subscribe_header_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_publish_subscribe_header_t, private::Bool = false)
    (:value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The non-owning handle for [`iox2_sample_mut_t`](@ref). Passing the handle to an function does not transfers the ownership.
"""
const iox2_sample_mut_h_ref = Ptr{iox2_sample_mut_h}

"""
The non-owning handle for [`iox2_server_t`](@ref). Passing the handle to a function does not transfer the ownership.
"""
const iox2_server_h_ref = Ptr{iox2_server_h}

struct iox2_active_request_storage_t
    data::NTuple{128, UInt8}
end

function Base.getproperty(x::Ptr{iox2_active_request_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{128, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_active_request_storage_t, f::Symbol)
    r = Ref{iox2_active_request_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_active_request_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_active_request_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_active_request_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_active_request_t
    data::NTuple{160, UInt8}
end

function Base.getproperty(x::Ptr{iox2_active_request_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_active_request_storage_t}(x + 16)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 144)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_active_request_t, f::Symbol)
    r = Ref{iox2_active_request_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_active_request_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_active_request_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_active_request_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_static_config_details_t
    data::NTuple{1744, UInt8}
end

function Base.getproperty(x::Ptr{iox2_static_config_details_t}, f::Symbol)
    f === :event && return Ptr{iox2_static_config_event_t}(x + 0)
    f === :publish_subscribe && return Ptr{iox2_static_config_publish_subscribe_t}(x + 0)
    f === :request_response && return Ptr{iox2_static_config_request_response_t}(x + 0)
    f === :blackboard && return Ptr{iox2_static_config_blackboard_t}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_static_config_details_t, f::Symbol)
    r = Ref{iox2_static_config_details_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_static_config_details_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_static_config_details_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_static_config_details_t, private::Bool = false)
    (:event, :publish_subscribe, :request_response, :blackboard, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_static_config_t
    data::NTuple{2080, UInt8}
end

function Base.getproperty(x::Ptr{iox2_static_config_t}, f::Symbol)
    f === :id && return Ptr{NTuple{64, Cchar}}(x + 0)
    f === :name && return Ptr{NTuple{255, Cchar}}(x + 64)
    f === :messaging_pattern && return Ptr{iox2_messaging_pattern_e}(x + 320)
    f === :details && return Ptr{iox2_static_config_details_t}(x + 328)
    f === :attributes && return Ptr{iox2_attribute_set_h}(x + 2072)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_static_config_t, f::Symbol)
    r = Ref{iox2_static_config_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_static_config_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_static_config_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_static_config_t, private::Bool = false)
    (:id, :name, :messaging_pattern, :details, :attributes, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

# typedef enum iox2_callback_progression_e ( * iox2_service_list_callback ) ( const struct iox2_static_config_t * , iox2_callback_context )
const iox2_service_list_callback = Ptr{Cvoid}

"""
The owning handle for [`iox2_service_builder_t`](@ref) which is already configured as event. Passing the handle to an function transfers the ownership.
"""
const iox2_service_builder_event_h = Ptr{iox2_service_builder_event_h_t}

"""
The owning handle for [`iox2_service_builder_t`](@ref) which is already configured as event. Passing the handle to an function transfers the ownership.
"""
const iox2_service_builder_pub_sub_h = Ptr{iox2_service_builder_pub_sub_h_t}

"""
The owning handle for [`iox2_service_builder_t`](@ref) which is already configured as event. Passing the handle to an function transfers the ownership.
"""
const iox2_service_builder_request_response_h = Ptr{iox2_service_builder_request_response_h_t}

"""
The owning handle for [`iox2_service_builder_t`](@ref) which is already configured as event. Passing the handle to a function transfers the ownership.
"""
const iox2_service_builder_blackboard_creator_h = Ptr{iox2_service_builder_blackboard_creator_h_t}

"""
The owning handle for [`iox2_service_builder_t`](@ref) which is already configured as event. Passing the handle to a function transfers the ownership.
"""
const iox2_service_builder_blackboard_opener_h = Ptr{iox2_service_builder_blackboard_opener_h_t}

"""
The non-owning handle for [`iox2_service_builder_t`](@ref) which is already configured as event. Passing the handle to a function does not transfer the ownership.
"""
const iox2_service_builder_blackboard_creator_h_ref = Ptr{iox2_service_builder_blackboard_creator_h}

"""
The non-owning handle for [`iox2_service_builder_t`](@ref) which is already configured as event. Passing the handle to a function does not transfer the ownership.
"""
const iox2_service_builder_blackboard_opener_h_ref = Ptr{iox2_service_builder_blackboard_opener_h}

# typedef bool ( * iox2_service_blackboard_key_eq_cmp_func ) ( const void * , const void * )
const iox2_service_blackboard_key_eq_cmp_func = Ptr{Cvoid}

# typedef void ( * iox2_service_blackboard_creator_add_release_callback ) ( void * )
const iox2_service_blackboard_creator_add_release_callback = Ptr{Cvoid}

struct iox2_port_factory_blackboard_storage_t
    data::NTuple{16, UInt8}
end

function Base.getproperty(x::Ptr{iox2_port_factory_blackboard_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{16, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_port_factory_blackboard_storage_t, f::Symbol)
    r = Ref{iox2_port_factory_blackboard_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_port_factory_blackboard_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_port_factory_blackboard_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_port_factory_blackboard_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_port_factory_blackboard_t
    data::NTuple{32, UInt8}
end

function Base.getproperty(x::Ptr{iox2_port_factory_blackboard_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_port_factory_blackboard_storage_t}(x + 8)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_port_factory_blackboard_t, f::Symbol)
    r = Ref{iox2_port_factory_blackboard_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_port_factory_blackboard_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_port_factory_blackboard_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_port_factory_blackboard_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The non-owning handle for [`iox2_service_builder_t`](@ref) which is already configured as event. Passing the handle to an function does not transfers the ownership.
"""
const iox2_service_builder_event_h_ref = Ptr{iox2_service_builder_event_h}

struct iox2_port_factory_event_storage_t
    data::NTuple{1656, UInt8}
end

function Base.getproperty(x::Ptr{iox2_port_factory_event_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{1656, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_port_factory_event_storage_t, f::Symbol)
    r = Ref{iox2_port_factory_event_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_port_factory_event_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_port_factory_event_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_port_factory_event_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_port_factory_event_t
    data::NTuple{1672, UInt8}
end

function Base.getproperty(x::Ptr{iox2_port_factory_event_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_port_factory_event_storage_t}(x + 8)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 1664)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_port_factory_event_t, f::Symbol)
    r = Ref{iox2_port_factory_event_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_port_factory_event_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_port_factory_event_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_port_factory_event_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The non-owning handle for [`iox2_service_builder_t`](@ref) which is already configured as event. Passing the handle to an function does not transfers the ownership.
"""
const iox2_service_builder_pub_sub_h_ref = Ptr{iox2_service_builder_pub_sub_h}

struct iox2_port_factory_pub_sub_storage_t
    data::NTuple{1656, UInt8}
end

function Base.getproperty(x::Ptr{iox2_port_factory_pub_sub_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{1656, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_port_factory_pub_sub_storage_t, f::Symbol)
    r = Ref{iox2_port_factory_pub_sub_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_port_factory_pub_sub_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_port_factory_pub_sub_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_port_factory_pub_sub_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_port_factory_pub_sub_t
    data::NTuple{1672, UInt8}
end

function Base.getproperty(x::Ptr{iox2_port_factory_pub_sub_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_port_factory_pub_sub_storage_t}(x + 8)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 1664)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_port_factory_pub_sub_t, f::Symbol)
    r = Ref{iox2_port_factory_pub_sub_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_port_factory_pub_sub_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_port_factory_pub_sub_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_port_factory_pub_sub_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The non-owning handle for [`iox2_service_builder_t`](@ref) which is already configured as event. Passing the handle to an function does not transfers the ownership.
"""
const iox2_service_builder_request_response_h_ref = Ptr{iox2_service_builder_request_response_h}

struct iox2_port_factory_request_response_storage_t
    data::NTuple{1656, UInt8}
end

function Base.getproperty(x::Ptr{iox2_port_factory_request_response_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{1656, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_port_factory_request_response_storage_t, f::Symbol)
    r = Ref{iox2_port_factory_request_response_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_port_factory_request_response_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_port_factory_request_response_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_port_factory_request_response_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_port_factory_request_response_t
    data::NTuple{1672, UInt8}
end

function Base.getproperty(x::Ptr{iox2_port_factory_request_response_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_port_factory_request_response_storage_t}(x + 8)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 1664)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_port_factory_request_response_t, f::Symbol)
    r = Ref{iox2_port_factory_request_response_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_port_factory_request_response_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_port_factory_request_response_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_port_factory_request_response_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_service_name_storage_t
    data::NTuple{272, UInt8}
end

function Base.getproperty(x::Ptr{iox2_service_name_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{272, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_service_name_storage_t, f::Symbol)
    r = Ref{iox2_service_name_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_service_name_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_service_name_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_service_name_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_service_name_t
    data::NTuple{280, UInt8}
end

function Base.getproperty(x::Ptr{iox2_service_name_t}, f::Symbol)
    f === :value && return Ptr{iox2_service_name_storage_t}(x + 0)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 272)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_service_name_t, f::Symbol)
    r = Ref{iox2_service_name_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_service_name_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_service_name_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_service_name_t, private::Bool = false)
    (:value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [`iox2_service_name_t`](@ref). Passing the handle to an function transfers the ownership.
"""
const iox2_service_name_h = Ptr{iox2_service_name_h_t}

"""
The non-owning handle for [`iox2_subscriber_t`](@ref). Passing the handle to an function does not transfers the ownership.
"""
const iox2_subscriber_h_ref = Ptr{iox2_subscriber_h}

"""
    iox2_unique_subscriber_id_storage_t

The system-wide unique id of a [`iox2_subscriber_t`](@ref).
"""
struct iox2_unique_subscriber_id_storage_t
    data::NTuple{20, UInt8}
end

function Base.getproperty(x::Ptr{iox2_unique_subscriber_id_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{20, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_unique_subscriber_id_storage_t, f::Symbol)
    r = Ref{iox2_unique_subscriber_id_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_unique_subscriber_id_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_unique_subscriber_id_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_unique_subscriber_id_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_unique_subscriber_id_t
    data::NTuple{32, UInt8}
end

function Base.getproperty(x::Ptr{iox2_unique_subscriber_id_t}, f::Symbol)
    f === :value && return Ptr{iox2_unique_subscriber_id_storage_t}(x + 0)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_unique_subscriber_id_t, f::Symbol)
    r = Ref{iox2_unique_subscriber_id_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_unique_subscriber_id_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_unique_subscriber_id_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_unique_subscriber_id_t, private::Bool = false)
    (:value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [[`iox2_unique_subscriber_id_t`](@ref)]. Passing the handle to an function transfers the ownership.
"""
const iox2_unique_subscriber_id_h = Ptr{iox2_unique_subscriber_id_h_t}

struct iox2_sample_storage_t
    data::NTuple{96, UInt8}
end

function Base.getproperty(x::Ptr{iox2_sample_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{96, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_sample_storage_t, f::Symbol)
    r = Ref{iox2_sample_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_sample_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_sample_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_sample_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_sample_t
    data::NTuple{128, UInt8}
end

function Base.getproperty(x::Ptr{iox2_sample_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_sample_storage_t}(x + 16)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 112)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_sample_t, f::Symbol)
    r = Ref{iox2_sample_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_sample_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_sample_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_sample_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The non-owning handle for [[`iox2_unique_client_id_t`](@ref)]. Passing the handle to an function does not transfers the ownership.
"""
const iox2_unique_client_id_h_ref = Ptr{iox2_unique_client_id_h}

"""
The non-owning handle for [[`iox2_unique_listener_id_t`](@ref)]. Passing the handle to an function does not transfers the ownership.
"""
const iox2_unique_listener_id_h_ref = Ptr{iox2_unique_listener_id_h}

"""
The non-owning handle for [[`iox2_unique_notifier_id_t`](@ref)]. Passing the handle to an function does not transfers the ownership.
"""
const iox2_unique_notifier_id_h_ref = Ptr{iox2_unique_notifier_id_h}

"""
The non-owning handle for [[`iox2_unique_publisher_id_t`](@ref)]. Passing the handle to an function does not transfers the ownership.
"""
const iox2_unique_publisher_id_h_ref = Ptr{iox2_unique_publisher_id_h}

"""
The non-owning handle for [[`iox2_unique_reader_id_t`](@ref)]. Passing the handle to a function does not transfer the ownership.
"""
const iox2_unique_reader_id_h_ref = Ptr{iox2_unique_reader_id_h}

"""
The non-owning handle for [[`iox2_unique_server_id_t`](@ref)]. Passing the handle to an function does not transfers the ownership.
"""
const iox2_unique_server_id_h_ref = Ptr{iox2_unique_server_id_h}

"""
The non-owning handle for [[`iox2_unique_subscriber_id_t`](@ref)]. Passing the handle to an function does not transfers the ownership.
"""
const iox2_unique_subscriber_id_h_ref = Ptr{iox2_unique_subscriber_id_h}

"""
The owning handle for [[`iox2_unique_writer_id_t`](@ref)]. Passing the handle to a function transfers the ownership.
"""
const iox2_unique_writer_id_h = Ptr{iox2_unique_writer_id_h_t}

"""
The non-owning handle for [[`iox2_unique_writer_id_t`](@ref)]. Passing the handle to a function does not transfer the ownership.
"""
const iox2_unique_writer_id_h_ref = Ptr{iox2_unique_writer_id_h}

"""
The owning handle for [`iox2_waitset_t`](@ref). Passing the handle to an function transfers the ownership.
"""
const iox2_waitset_h = Ptr{iox2_waitset_h_t}

"""
The non-owning handle for [`iox2_waitset_t`](@ref). Passing the handle to an function does not transfers the ownership.
"""
const iox2_waitset_h_ref = Ptr{iox2_waitset_h}

struct iox2_waitset_guard_storage_t
    data::NTuple{56, UInt8}
end

function Base.getproperty(x::Ptr{iox2_waitset_guard_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{56, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_waitset_guard_storage_t, f::Symbol)
    r = Ref{iox2_waitset_guard_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_waitset_guard_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_waitset_guard_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_waitset_guard_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_waitset_guard_t
    data::NTuple{72, UInt8}
end

function Base.getproperty(x::Ptr{iox2_waitset_guard_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_waitset_guard_storage_t}(x + 8)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 64)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_waitset_guard_t, f::Symbol)
    r = Ref{iox2_waitset_guard_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_waitset_guard_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_waitset_guard_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_waitset_guard_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [`iox2_waitset_guard_t`](@ref). Passing the handle to an function transfers the ownership.
"""
const iox2_waitset_guard_h = Ptr{iox2_waitset_guard_h_t}

"""
The owning handle for [`iox2_waitset_attachment_id_t`](@ref). Passing the handle to an function transfers the ownership.
"""
const iox2_waitset_attachment_id_h = Ptr{iox2_waitset_attachment_id_h_t}

# typedef enum iox2_callback_progression_e ( * iox2_waitset_run_callback ) ( iox2_waitset_attachment_id_h , iox2_callback_context )
const iox2_waitset_run_callback = Ptr{Cvoid}

"""
The non-owning handle for [`iox2_waitset_attachment_id_t`](@ref). Passing the handle to an function does not transfers the ownership.
"""
const iox2_waitset_attachment_id_h_ref = Ptr{iox2_waitset_attachment_id_h}

"""
The non-owning handle for `iox2_attachment_id_t`. Passing the handle to an function does not transfers the ownership.
"""
const iox2_waitset_guard_h_ref = Ptr{iox2_waitset_guard_h}

struct iox2_waitset_attachment_id_storage_t
    data::NTuple{32, UInt8}
end

function Base.getproperty(x::Ptr{iox2_waitset_attachment_id_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{32, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_waitset_attachment_id_storage_t, f::Symbol)
    r = Ref{iox2_waitset_attachment_id_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_waitset_attachment_id_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_waitset_attachment_id_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_waitset_attachment_id_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_waitset_attachment_id_t
    data::NTuple{48, UInt8}
end

function Base.getproperty(x::Ptr{iox2_waitset_attachment_id_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_waitset_attachment_id_storage_t}(x + 8)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 40)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_waitset_attachment_id_t, f::Symbol)
    r = Ref{iox2_waitset_attachment_id_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_waitset_attachment_id_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_waitset_attachment_id_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_waitset_attachment_id_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_waitset_builder_storage_t
    data::NTuple{1, UInt8}
end

function Base.getproperty(x::Ptr{iox2_waitset_builder_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{1, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_waitset_builder_storage_t, f::Symbol)
    r = Ref{iox2_waitset_builder_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_waitset_builder_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_waitset_builder_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_waitset_builder_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_waitset_builder_t
    data::NTuple{16, UInt8}
end

function Base.getproperty(x::Ptr{iox2_waitset_builder_t}, f::Symbol)
    f === :value && return Ptr{iox2_waitset_builder_storage_t}(x + 0)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_waitset_builder_t, f::Symbol)
    r = Ref{iox2_waitset_builder_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_waitset_builder_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_waitset_builder_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_waitset_builder_t, private::Bool = false)
    (:value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The owning handle for [`iox2_waitset_builder_t`](@ref). Passing the handle to an function transfers the ownership.
"""
const iox2_waitset_builder_h = Ptr{iox2_waitset_builder_h_t}

struct iox2_waitset_storage_t
    data::NTuple{784, UInt8}
end

function Base.getproperty(x::Ptr{iox2_waitset_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{784, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_waitset_storage_t, f::Symbol)
    r = Ref{iox2_waitset_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_waitset_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_waitset_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_waitset_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_waitset_t
    data::NTuple{816, UInt8}
end

function Base.getproperty(x::Ptr{iox2_waitset_t}, f::Symbol)
    f === :service_type && return Ptr{iox2_service_type_e}(x + 0)
    f === :value && return Ptr{iox2_waitset_storage_t}(x + 16)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 800)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_waitset_t, f::Symbol)
    r = Ref{iox2_waitset_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_waitset_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_waitset_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_waitset_t, private::Bool = false)
    (:service_type, :value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
The non-owning handle for [`iox2_waitset_builder_t`](@ref). Passing the handle to an function does not transfers the ownership.
"""
const iox2_waitset_builder_h_ref = Ptr{iox2_waitset_builder_h}

"""
The non-owning handle for [`iox2_writer_t`](@ref). Passing the handle to a function does not transfer the ownership.
"""
const iox2_writer_h_ref = Ptr{iox2_writer_h}

"""
    iox2_unique_writer_id_storage_t

The system-wide unique id of a [`iox2_writer_t`](@ref).
"""
struct iox2_unique_writer_id_storage_t
    data::NTuple{20, UInt8}
end

function Base.getproperty(x::Ptr{iox2_unique_writer_id_storage_t}, f::Symbol)
    f === :internal && return Ptr{NTuple{20, UInt8}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_unique_writer_id_storage_t, f::Symbol)
    r = Ref{iox2_unique_writer_id_storage_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_unique_writer_id_storage_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_unique_writer_id_storage_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_unique_writer_id_storage_t, private::Bool = false)
    (:internal, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

struct iox2_unique_writer_id_t
    data::NTuple{32, UInt8}
end

function Base.getproperty(x::Ptr{iox2_unique_writer_id_t}, f::Symbol)
    f === :value && return Ptr{iox2_unique_writer_id_storage_t}(x + 0)
    f === :deleter && return Ptr{Ptr{Cvoid}}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::iox2_unique_writer_id_t, f::Symbol)
    r = Ref{iox2_unique_writer_id_t}(x)
    ptr = Base.unsafe_convert(Ptr{iox2_unique_writer_id_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{iox2_unique_writer_id_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function Base.propertynames(x::iox2_unique_writer_id_t, private::Bool = false)
    (:value, :deleter, if private
            fieldnames(typeof(x))
        else
            ()
        end...)
end

"""
    iox2_semantic_string_error_string(error)

Returns a string literal describing the provided [[`iox2_semantic_string_error_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_semantic_string_error_string(enum iox2_semantic_string_error_e error);
```
"""
function iox2_semantic_string_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_semantic_string_error_string(error::iox2_semantic_string_error_e)::Cstring
end

"""
    iox2_active_request_has_disconnect_hint(handle)

Returns true if the client wants to gracefully disconnect. This allows the Server to send its last response and then drop the active request to signal the client that no more response will be sent.

# Arguments

* `handle` - Must be a valid [[`iox2_active_request_h_ref`](@ref)] obtained by [[`iox2_server_receive`](@ref)](crate::[`iox2_server_receive`](@ref)).

# Safety

* `handle` must be a valid handle

### Prototype
```c
bool iox2_active_request_has_disconnect_hint(iox2_active_request_h_ref handle);
```
"""
function iox2_active_request_has_disconnect_hint(handle)
    @ccall libiceoryx2_ffi_c.iox2_active_request_has_disconnect_hint(handle::iox2_active_request_h_ref)::Bool
end

"""
    iox2_active_request_is_connected(handle)

Returns true if the corresponding pending response is still connected anc can receive responses.

# Arguments

* `handle` - Must be a valid [[`iox2_active_request_h_ref`](@ref)] obtained by [[`iox2_server_receive`](@ref)](crate::[`iox2_server_receive`](@ref)).

# Safety

* `handle` must be a valid handle

### Prototype
```c
bool iox2_active_request_is_connected(iox2_active_request_h_ref handle);
```
"""
function iox2_active_request_is_connected(handle)
    @ccall libiceoryx2_ffi_c.iox2_active_request_is_connected(handle::iox2_active_request_h_ref)::Bool
end

"""
    iox2_active_request_header(handle, header_struct_ptr, header_handle_ptr)

Acquires the requests header.

# Safety

* `handle` - Must be a valid [[`iox2_active_request_h_ref`](@ref)] obtained by [[`iox2_server_receive`](@ref)](crate::[`iox2_server_receive`](@ref)). * `header_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_request_header_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `header_handle_ptr` valid pointer to a [[`iox2_request_header_h`](@ref)].

### Prototype
```c
void iox2_active_request_header(iox2_active_request_h_ref handle, struct iox2_request_header_t *header_struct_ptr, iox2_request_header_h *header_handle_ptr);
```
"""
function iox2_active_request_header(handle, header_struct_ptr, header_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_active_request_header(handle::iox2_active_request_h_ref, header_struct_ptr::Ptr{iox2_request_header_t}, header_handle_ptr::Ptr{iox2_request_header_h})::Cvoid
end

"""
    iox2_active_request_user_header(handle, header_ptr)

Acquires the request user header.

# Safety

* `handle` - Must be a valid [[`iox2_active_request_h_ref`](@ref)] obtained by [[`iox2_server_receive`](@ref)](crate::[`iox2_server_receive`](@ref)).

### Prototype
```c
void iox2_active_request_user_header(iox2_active_request_h_ref handle, const void **header_ptr);
```
"""
function iox2_active_request_user_header(handle, header_ptr)
    @ccall libiceoryx2_ffi_c.iox2_active_request_user_header(handle::iox2_active_request_h_ref, header_ptr::Ptr{Ptr{Cvoid}})::Cvoid
end

"""
    iox2_active_request_payload(handle, payload_ptr, number_of_elements)

Acquires the request payload.

# Safety

* `handle` - Must be a valid [[`iox2_active_request_h_ref`](@ref)] obtained by [[`iox2_server_receive`](@ref)](crate::[`iox2_server_receive`](@ref)). * `payload_ptr` a valid, non-null pointer pointing to a `*const c\\_void` pointer. * `number_of_elements` (optional) either a null pointer or a valid pointer pointing to a [[`c_size_t`](@ref)].

### Prototype
```c
void iox2_active_request_payload(iox2_active_request_h_ref handle, const void **payload_ptr, c_size_t *number_of_elements);
```
"""
function iox2_active_request_payload(handle, payload_ptr, number_of_elements)
    @ccall libiceoryx2_ffi_c.iox2_active_request_payload(handle::iox2_active_request_h_ref, payload_ptr::Ptr{Ptr{Cvoid}}, number_of_elements::Ptr{c_size_t})::Cvoid
end

"""
    iox2_active_request_loan_slice_uninit(active_request_handle, response_struct_ptr, response_handle_ptr, number_of_elements)

Loans memory from the servers data segment.

# Arguments

* `active_request_handle` - Must be a valid [[`iox2_active_request_h_ref`](@ref)] obtained by [[`iox2_server_receive`](@ref)](crate::[`iox2_server_receive`](@ref)). * `response_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_response_mut_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `response_handle_ptr` - An uninitialized or dangling [[`iox2_response_mut_h`](@ref)] handle which will be initialized by this function call if a response is obtained, otherwise it will be set to NULL. * `number_of_elements` - The number of elements to loan from the server's payload segment

Return [[`IOX2_OK`](@ref)] on success, otherwise [[`iox2_loan_error_e`](@ref)](crate::[`iox2_loan_error_e`](@ref)).

# Safety

* `active_request_handle` is valid and non-null * The `response_handle_ptr` is pointing to a valid [[`iox2_response_mut_h`](@ref)].

### Prototype
```c
int iox2_active_request_loan_slice_uninit(iox2_active_request_h_ref active_request_handle, struct iox2_response_mut_t *response_struct_ptr, iox2_response_mut_h *response_handle_ptr, size_t number_of_elements);
```
"""
function iox2_active_request_loan_slice_uninit(active_request_handle, response_struct_ptr, response_handle_ptr, number_of_elements)
    @ccall libiceoryx2_ffi_c.iox2_active_request_loan_slice_uninit(active_request_handle::iox2_active_request_h_ref, response_struct_ptr::Ptr{iox2_response_mut_t}, response_handle_ptr::Ptr{iox2_response_mut_h}, number_of_elements::Csize_t)::Cint
end

"""
    iox2_active_request_send_copy(active_request_handle, data_ptr, size_of_element, number_of_elements)

Sends a copy of the provided data via the server.

# Arguments

* `active_request_handle` - Must be a valid [[`iox2_active_request_h_ref`](@ref)] obtained by [[`iox2_server_receive`](@ref)](crate::[`iox2_server_receive`](@ref)). * `data_ptr` pointer to the payload that shall be transmitted * `size_of_element` the size of the payload in bytes * `number_of_elements` the number of elements stored in data\\_ptr

Return [[`IOX2_OK`](@ref)] on success, otherwise [[`iox2_send_error_e`](@ref)].

# Safety

* `active_request_handle` is valid and non-null * `data_ptr` non-null pointer to a valid position in memory

### Prototype
```c
int iox2_active_request_send_copy(iox2_active_request_h_ref active_request_handle, const void *data_ptr, size_t size_of_element, size_t number_of_elements);
```
"""
function iox2_active_request_send_copy(active_request_handle, data_ptr, size_of_element, number_of_elements)
    @ccall libiceoryx2_ffi_c.iox2_active_request_send_copy(active_request_handle::iox2_active_request_h_ref, data_ptr::Ptr{Cvoid}, size_of_element::Csize_t, number_of_elements::Csize_t)::Cint
end

"""
    iox2_active_request_drop(handle)

This function needs to be called to destroy the active\\_request!

# Arguments

* `handle` - A valid [[`iox2_active_request_h`](@ref)]

# Safety

* The `handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_active_request_t`](@ref)] can be re-used with a call to [[`iox2_server_receive`](@ref)](crate::[`iox2_server_receive`](@ref))!

### Prototype
```c
void iox2_active_request_drop(iox2_active_request_h handle);
```
"""
function iox2_active_request_drop(handle)
    @ccall libiceoryx2_ffi_c.iox2_active_request_drop(handle::iox2_active_request_h)::Cvoid
end

"""
    iox2_attribute_key_len(handle)

Returns the length of the attributes key.

# Safety

* The `handle` must be a valid handle.

### Prototype
```c
size_t iox2_attribute_key_len(iox2_attribute_h_ref handle);
```
"""
function iox2_attribute_key_len(handle)
    @ccall libiceoryx2_ffi_c.iox2_attribute_key_len(handle::iox2_attribute_h_ref)::Csize_t
end

"""
    iox2_attribute_key(handle, buffer, buffer_len)

Copies the keys value into the provided buffer.

# Safety

* `handle` - A valid [[`iox2_attribute_h_ref`](@ref)], * `buffer` - Must be non-null and pointing to a valid memory location, * `buffer_len` - Must be the length of the provided `buffer`.

### Prototype
```c
void iox2_attribute_key(iox2_attribute_h_ref handle, char *buffer, size_t buffer_len);
```
"""
function iox2_attribute_key(handle, buffer, buffer_len)
    @ccall libiceoryx2_ffi_c.iox2_attribute_key(handle::iox2_attribute_h_ref, buffer::Cstring, buffer_len::Csize_t)::Cvoid
end

"""
    iox2_attribute_value_len(handle)

Returns the length of the attributes value.

# Safety

* The `handle` must be a valid handle.

### Prototype
```c
size_t iox2_attribute_value_len(iox2_attribute_h_ref handle);
```
"""
function iox2_attribute_value_len(handle)
    @ccall libiceoryx2_ffi_c.iox2_attribute_value_len(handle::iox2_attribute_h_ref)::Csize_t
end

"""
    iox2_attribute_value(handle, buffer, buffer_len)

Copies the values value into the provided buffer.

# Safety

* `handle` - A valid [[`iox2_attribute_h_ref`](@ref)], * `buffer` - Must be non-null and pointing to a valid memory location, * `buffer_len` - Must be the length of the provided `buffer`.

### Prototype
```c
void iox2_attribute_value(iox2_attribute_h_ref handle, char *buffer, size_t buffer_len);
```
"""
function iox2_attribute_value(handle, buffer, buffer_len)
    @ccall libiceoryx2_ffi_c.iox2_attribute_value(handle::iox2_attribute_h_ref, buffer::Cstring, buffer_len::Csize_t)::Cvoid
end

"""
    iox2_attribute_definition_error_create_error_string(error)

Returns a string literal describing the provided [[`iox2_attribute_definition_error_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_attribute_definition_error_create_error_string(enum iox2_attribute_definition_error_e error);
```
"""
function iox2_attribute_definition_error_create_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_attribute_definition_error_create_error_string(error::iox2_attribute_definition_error_e)::Cstring
end

"""
    iox2_attribute_verification_error_create_error_string(error)

Returns a string literal describing the provided [[`iox2_attribute_verification_error_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_attribute_verification_error_create_error_string(enum iox2_attribute_verification_error_e error);
```
"""
function iox2_attribute_verification_error_create_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_attribute_verification_error_create_error_string(error::iox2_attribute_verification_error_e)::Cstring
end

"""
    iox2_attribute_set_new_clone(struct_ptr, source_ptr, handle_ptr)

This function create a new attribute\\_set by cloning an already existing one!

# Safety

* `struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_attribute_set_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `source_ptr` - Must be valid pointer to a [[`iox2_attribute_set_ptr`](@ref)]. * `handle_ptr` - An uninitialized or dangling [[`iox2_attribute_set_h`](@ref)] handle which will be initialized by this function call.

### Prototype
```c
void iox2_attribute_set_new_clone(struct iox2_attribute_set_t *struct_ptr, iox2_attribute_set_ptr source_ptr, iox2_attribute_set_h *handle_ptr);
```
"""
function iox2_attribute_set_new_clone(struct_ptr, source_ptr, handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_attribute_set_new_clone(struct_ptr::Ptr{iox2_attribute_set_t}, source_ptr::iox2_attribute_set_ptr, handle_ptr::Ptr{iox2_attribute_set_h})::Cvoid
end

"""
    iox2_attribute_set_drop(handle)

This function needs to be called to destroy the attribute set!

# Safety

* `handle` - A valid [[`iox2_attribute_set_h`](@ref)] created with [`[`iox2_attribute_set_new_clone`](@ref)()`]. * The `handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_attribute_set_t`](@ref)] can be re-used with a call to [`[`iox2_attribute_set_new_clone`](@ref)()`]!

### Prototype
```c
void iox2_attribute_set_drop(iox2_attribute_set_h handle);
```
"""
function iox2_attribute_set_drop(handle)
    @ccall libiceoryx2_ffi_c.iox2_attribute_set_drop(handle::iox2_attribute_set_h)::Cvoid
end

"""
    iox2_cast_attribute_set_ptr(handle)

This function casts a [[`iox2_attribute_set_h`](@ref)] into a [[`iox2_attribute_set_ptr`](@ref)]

Returns a [[`iox2_attribute_set_ptr`](@ref)]

# Safety

* `handle` obtained by [`[`iox2_attribute_set_new_clone`](@ref)()`] * The `handle` must be a valid handle. * The `handle` is still valid after the call to this function.

### Prototype
```c
iox2_attribute_set_ptr iox2_cast_attribute_set_ptr(iox2_attribute_set_h handle);
```
"""
function iox2_cast_attribute_set_ptr(handle)
    @ccall libiceoryx2_ffi_c.iox2_cast_attribute_set_ptr(handle::iox2_attribute_set_h)::iox2_attribute_set_ptr
end

"""
    iox2_attribute_set_number_of_attributes(handle)

Returns the number of attributes in the attribute set.

# Safety

* The `handle` must be a valid handle.

### Prototype
```c
size_t iox2_attribute_set_number_of_attributes(iox2_attribute_set_ptr handle);
```
"""
function iox2_attribute_set_number_of_attributes(handle)
    @ccall libiceoryx2_ffi_c.iox2_attribute_set_number_of_attributes(handle::iox2_attribute_set_ptr)::Csize_t
end

"""
    iox2_attribute_set_index(handle, index)

Returns a [[`iox2_attribute_h_ref`](@ref)] to the attribute stored at the provided index.

# Safety

* The `handle` must be a valid handle. * The `index` < [`[`iox2_attribute_set_number_of_attributes`](@ref)()`].

### Prototype
```c
iox2_attribute_h_ref iox2_attribute_set_index(iox2_attribute_set_ptr handle, size_t index);
```
"""
function iox2_attribute_set_index(handle, index)
    @ccall libiceoryx2_ffi_c.iox2_attribute_set_index(handle::iox2_attribute_set_ptr, index::Csize_t)::iox2_attribute_h_ref
end

"""
    iox2_attribute_set_number_of_key_values(handle, key)

Returns the number of values stored under a specific key. If the key does not exist it returns 0.

# Safety

* The `handle` must be a valid handle. * `key` must be non-zero and contain a null-terminated string

### Prototype
```c
size_t iox2_attribute_set_number_of_key_values(iox2_attribute_set_ptr handle, const char *key);
```
"""
function iox2_attribute_set_number_of_key_values(handle, key)
    @ccall libiceoryx2_ffi_c.iox2_attribute_set_number_of_key_values(handle::iox2_attribute_set_ptr, key::Cstring)::Csize_t
end

"""
    iox2_attribute_set_key_value(handle, key, index, buffer, buffer_len, has_value)

Returns a value of a key at a specific index. The index enumerates the values of the key if the key has multiple values. The values are always stored at the same position during the lifetime of the service but they can change when the process is recreated by another process when the system restarts.

# Safety

* The `handle` must be a valid handle. * `key` must be non-zero and contain a null-terminated string * `buffer` must point to a valid memory location * `buffer_len` must define the length of the memory pointed by `buffer`

### Prototype
```c
void iox2_attribute_set_key_value(iox2_attribute_set_ptr handle, const char *key, size_t index, char *buffer, size_t buffer_len, bool *has_value);
```
"""
function iox2_attribute_set_key_value(handle, key, index, buffer, buffer_len, has_value)
    @ccall libiceoryx2_ffi_c.iox2_attribute_set_key_value(handle::iox2_attribute_set_ptr, key::Cstring, index::Csize_t, buffer::Cstring, buffer_len::Csize_t, has_value::Ptr{Bool})::Cvoid
end

"""
    iox2_attribute_set_iter_key_values(handle, key, callback, callback_ctx)

Calls the provided callback for every value that is owned by the provided key.

# Safety

* The `handle` must be a valid handle. * The `key` must be a valid null-terminated string. * The `callback` must point to a function with the required signature.

### Prototype
```c
void iox2_attribute_set_iter_key_values(iox2_attribute_set_ptr handle, const char *key, iox2_attribute_set_get_callback callback, iox2_callback_context callback_ctx);
```
"""
function iox2_attribute_set_iter_key_values(handle, key, callback, callback_ctx)
    @ccall libiceoryx2_ffi_c.iox2_attribute_set_iter_key_values(handle::iox2_attribute_set_ptr, key::Cstring, callback::iox2_attribute_set_get_callback, callback_ctx::iox2_callback_context)::Cvoid
end

"""
    iox2_attribute_specifier_new(struct_ptr, handle_ptr)

Creates a new [[`iox2_attribute_specifier_h`](@ref)]. It must be cleaned up with [`[`iox2_attribute_specifier_drop`](@ref)()`]. If the `struct_ptr` is null, then the function will allocate memory.

# Safety

* The `handle_ptr` must point to an uninitialized [[`iox2_attribute_specifier_h`](@ref)].

### Prototype
```c
int iox2_attribute_specifier_new(struct iox2_attribute_specifier_t *struct_ptr, iox2_attribute_specifier_h *handle_ptr);
```
"""
function iox2_attribute_specifier_new(struct_ptr, handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_attribute_specifier_new(struct_ptr::Ptr{iox2_attribute_specifier_t}, handle_ptr::Ptr{iox2_attribute_specifier_h})::Cint
end

"""
    iox2_attribute_specifier_drop(handle)

Deletes a [[`iox2_attribute_specifier_h`](@ref)]. It must be created with [`[`iox2_attribute_specifier_new`](@ref)()`].

# Safety

* The `handle` must point to an initialized [[`iox2_attribute_specifier_h`](@ref)].

### Prototype
```c
void iox2_attribute_specifier_drop(iox2_attribute_specifier_h handle);
```
"""
function iox2_attribute_specifier_drop(handle)
    @ccall libiceoryx2_ffi_c.iox2_attribute_specifier_drop(handle::iox2_attribute_specifier_h)::Cvoid
end

"""
    iox2_attribute_specifier_define(handle, key, value)

Defines a attribute (key / value pair).

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_attribute_definition_error_e`](@ref)](crate::[`iox2_attribute_definition_error_e`](@ref)) otherwise.

# Safety

* The `handle` must point to an initialized [[`iox2_attribute_specifier_h`](@ref)]. * The `key` must point to a valid null-terminated string. * The `value` must point to a valid null-terminated string.

### Prototype
```c
int iox2_attribute_specifier_define(iox2_attribute_specifier_h_ref handle, const char *key, const char *value);
```
"""
function iox2_attribute_specifier_define(handle, key, value)
    @ccall libiceoryx2_ffi_c.iox2_attribute_specifier_define(handle::iox2_attribute_specifier_h_ref, key::Cstring, value::Cstring)::Cint
end

"""
    iox2_attribute_specifier_attributes(handle)

Returnes a [[`iox2_attribute_set_ptr`](@ref)] to the underlying attribute set.

# Safety

* The `handle` must point to an initialized [[`iox2_attribute_specifier_h`](@ref)]. * The `handle` must live at least as long as the returned [[`iox2_attribute_set_ptr`](@ref)].

### Prototype
```c
iox2_attribute_set_ptr iox2_attribute_specifier_attributes(iox2_attribute_specifier_h_ref handle);
```
"""
function iox2_attribute_specifier_attributes(handle)
    @ccall libiceoryx2_ffi_c.iox2_attribute_specifier_attributes(handle::iox2_attribute_specifier_h_ref)::iox2_attribute_set_ptr
end

"""
    iox2_attribute_verifier_new(struct_ptr, handle_ptr)

Creates a new [[`iox2_attribute_verifier_h`](@ref)]. It must be cleaned up with [`[`iox2_attribute_verifier_drop`](@ref)()`]. If the `struct_ptr` is null, then the function will allocate memory.

# Safety

* The `handle_ptr` must point to an uninitialized [[`iox2_attribute_verifier_h`](@ref)].

### Prototype
```c
int iox2_attribute_verifier_new(struct iox2_attribute_verifier_t *struct_ptr, iox2_attribute_verifier_h *handle_ptr);
```
"""
function iox2_attribute_verifier_new(struct_ptr, handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_attribute_verifier_new(struct_ptr::Ptr{iox2_attribute_verifier_t}, handle_ptr::Ptr{iox2_attribute_verifier_h})::Cint
end

"""
    iox2_attribute_verifier_drop(handle)

Deletes a [[`iox2_attribute_verifier_h`](@ref)]. It must be created with [`[`iox2_attribute_verifier_new`](@ref)()`].

# Safety

* The `handle` must point to an initialized [[`iox2_attribute_verifier_h`](@ref)].

### Prototype
```c
void iox2_attribute_verifier_drop(iox2_attribute_verifier_h handle);
```
"""
function iox2_attribute_verifier_drop(handle)
    @ccall libiceoryx2_ffi_c.iox2_attribute_verifier_drop(handle::iox2_attribute_verifier_h)::Cvoid
end

"""
    iox2_attribute_verifier_require(handle, key, value)

Defines a attribute (key / value pair) that is required.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_attribute_definition_error_e`](@ref)](crate::[`iox2_attribute_definition_error_e`](@ref)) otherwise.

# Safety

* The `handle` must point to an initialized [[`iox2_attribute_verifier_h`](@ref)]. * The `key` must point to a valid null-terminated string. * The `value` must point to a valid null-terminated string.

### Prototype
```c
int iox2_attribute_verifier_require(iox2_attribute_verifier_h_ref handle, const char *key, const char *value);
```
"""
function iox2_attribute_verifier_require(handle, key, value)
    @ccall libiceoryx2_ffi_c.iox2_attribute_verifier_require(handle::iox2_attribute_verifier_h_ref, key::Cstring, value::Cstring)::Cint
end

"""
    iox2_attribute_verifier_require_key(handle, key)

Defines a key that must be present.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_attribute_definition_error_e`](@ref)](crate::[`iox2_attribute_definition_error_e`](@ref)) otherwise.

# Safety

* The `handle` must point to an initialized [[`iox2_attribute_verifier_h`](@ref)]. * The `key` must point to a valid null-terminated string.

### Prototype
```c
int iox2_attribute_verifier_require_key(iox2_attribute_verifier_h_ref handle, const char *key);
```
"""
function iox2_attribute_verifier_require_key(handle, key)
    @ccall libiceoryx2_ffi_c.iox2_attribute_verifier_require_key(handle::iox2_attribute_verifier_h_ref, key::Cstring)::Cint
end

"""
    iox2_attribute_verifier_attributes(handle)

Returnes a [[`iox2_attribute_set_ptr`](@ref)] to the underlying attribute set.

# Safety

* The `handle` must point to an initialized [[`iox2_attribute_verifier_h`](@ref)]. * The `handle` must live at least as long as the returned [[`iox2_attribute_set_ptr`](@ref)].

### Prototype
```c
iox2_attribute_set_ptr iox2_attribute_verifier_attributes(iox2_attribute_verifier_h_ref handle);
```
"""
function iox2_attribute_verifier_attributes(handle)
    @ccall libiceoryx2_ffi_c.iox2_attribute_verifier_attributes(handle::iox2_attribute_verifier_h_ref)::iox2_attribute_set_ptr
end

"""
    iox2_attribute_verifier_verify_requirements(handle, rhs, incompatible_key_buffer, incompatible_key_buffer_len)

Verifies if the [[`iox2_attribute_set_ptr`](@ref)] contains all required keys and key-value pairs.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_attribute_verification_error_e`](@ref)](crate::[`iox2_attribute_verification_error_e`](@ref)) otherwise.

# Safety

* The `handle` must point to an initialized [[`iox2_attribute_verifier_h`](@ref)]. * The `rhs` must be valid. * `incompatible_key_buffer` must be either null or point to a valid memory location of size `incompatible_key_buffer_len`

### Prototype
```c
int iox2_attribute_verifier_verify_requirements(iox2_attribute_verifier_h_ref handle, iox2_attribute_set_ptr rhs, char *incompatible_key_buffer, size_t incompatible_key_buffer_len);
```
"""
function iox2_attribute_verifier_verify_requirements(handle, rhs, incompatible_key_buffer, incompatible_key_buffer_len)
    @ccall libiceoryx2_ffi_c.iox2_attribute_verifier_verify_requirements(handle::iox2_attribute_verifier_h_ref, rhs::iox2_attribute_set_ptr, incompatible_key_buffer::Cstring, incompatible_key_buffer_len::Csize_t)::Cint
end

"""
    iox2_attribute_verifier_number_of_keys(handle)

Returns the number of required keys.

# Safety

* The `handle` must point to an initialized [[`iox2_attribute_verifier_h`](@ref)].

### Prototype
```c
size_t iox2_attribute_verifier_number_of_keys(iox2_attribute_verifier_h_ref handle);
```
"""
function iox2_attribute_verifier_number_of_keys(handle)
    @ccall libiceoryx2_ffi_c.iox2_attribute_verifier_number_of_keys(handle::iox2_attribute_verifier_h_ref)::Csize_t
end

"""
    iox2_attribute_verifier_key_len(handle, key_index)

Returns the length of a required key at a specific key index.

# Safety

* The `handle` must point to an initialized [[`iox2_attribute_verifier_h`](@ref)]. * `key_index` < [`[`iox2_attribute_verifier_number_of_keys`](@ref)()`]

### Prototype
```c
size_t iox2_attribute_verifier_key_len(iox2_attribute_verifier_h_ref handle, size_t key_index);
```
"""
function iox2_attribute_verifier_key_len(handle, key_index)
    @ccall libiceoryx2_ffi_c.iox2_attribute_verifier_key_len(handle::iox2_attribute_verifier_h_ref, key_index::Csize_t)::Csize_t
end

"""
    iox2_attribute_verifier_key(handle, key_index, key_value_buffer, key_value_buffer_len)

Copies the key value at a specific key index into the provided buffer.

# Safety

* The `handle` must point to an initialized [[`iox2_attribute_verifier_h`](@ref)]. * `key_index` < [`[`iox2_attribute_verifier_number_of_keys`](@ref)()`] * `key_value_buffer` must point to a valid memory location of size `key_value_buffer_len`.

### Prototype
```c
size_t iox2_attribute_verifier_key(iox2_attribute_verifier_h_ref handle, size_t key_index, char *key_value_buffer, size_t key_value_buffer_len);
```
"""
function iox2_attribute_verifier_key(handle, key_index, key_value_buffer, key_value_buffer_len)
    @ccall libiceoryx2_ffi_c.iox2_attribute_verifier_key(handle::iox2_attribute_verifier_h_ref, key_index::Csize_t, key_value_buffer::Cstring, key_value_buffer_len::Csize_t)::Csize_t
end

"""
    iox2_client_unable_to_deliver_strategy(handle)

Returns the strategy the client follows when a request cannot be delivered since the servers buffer is full.

# Arguments

* `handle` obtained by [[`iox2_port_factory_client_builder_create`](@ref)](crate::[`iox2_port_factory_client_builder_create`](@ref))

Returns [[`iox2_unable_to_deliver_strategy_e`](@ref)].

# Safety

* `handle` is valid and non-null

### Prototype
```c
enum iox2_unable_to_deliver_strategy_e iox2_client_unable_to_deliver_strategy(iox2_client_h_ref handle);
```
"""
function iox2_client_unable_to_deliver_strategy(handle)
    @ccall libiceoryx2_ffi_c.iox2_client_unable_to_deliver_strategy(handle::iox2_client_h_ref)::iox2_unable_to_deliver_strategy_e
end

"""
    iox2_client_initial_max_slice_len(handle)

Returns the initial max slice len with which the client was created.

# Arguments

* `handle` obtained by [[`iox2_port_factory_client_builder_create`](@ref)](crate::[`iox2_port_factory_client_builder_create`](@ref))

# Safety

* `handle` is valid and non-null

### Prototype
```c
c_size_t iox2_client_initial_max_slice_len(iox2_client_h_ref handle);
```
"""
function iox2_client_initial_max_slice_len(handle)
    @ccall libiceoryx2_ffi_c.iox2_client_initial_max_slice_len(handle::iox2_client_h_ref)::c_size_t
end

"""
    iox2_client_id(handle, id_struct_ptr, id_handle_ptr)

Returns the unique port id of the client.

# Arguments

* `handle` obtained by [[`iox2_port_factory_client_builder_create`](@ref)](crate::[`iox2_port_factory_client_builder_create`](@ref)) * `id_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_unique_client_id_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `id_handle_ptr` valid pointer to a [[`iox2_unique_client_id_h`](@ref)].

# Safety

* `handle` is valid and non-null * `id` is valid and non-null

### Prototype
```c
void iox2_client_id(iox2_client_h_ref handle, struct iox2_unique_client_id_t *id_struct_ptr, iox2_unique_client_id_h *id_handle_ptr);
```
"""
function iox2_client_id(handle, id_struct_ptr, id_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_client_id(handle::iox2_client_h_ref, id_struct_ptr::Ptr{iox2_unique_client_id_t}, id_handle_ptr::Ptr{iox2_unique_client_id_h})::Cvoid
end

"""
    iox2_client_loan_slice_uninit(client_handle, request_struct_ptr, request_handle_ptr, number_of_elements)

Loans memory from the clients data segment.

# Arguments

* `client_handle` obtained by [[`iox2_port_factory_client_builder_create`](@ref)](crate::[`iox2_port_factory_client_builder_create`](@ref)) * `request_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_request_mut_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `request_handle_ptr` - An uninitialized or dangling [[`iox2_request_mut_h`](@ref)] handle which will be initialized by this function call if a request is obtained, otherwise it will be set to NULL. * `number_of_elements` - The number of elements to loan from the clients's payload segment

Return [[`IOX2_OK`](@ref)] on success, otherwise [[`iox2_loan_error_e`](@ref)](crate::[`iox2_loan_error_e`](@ref)).

# Safety

* `client_handle` is valid and non-null * The `request_handle_ptr` is pointing to a valid [[`iox2_request_mut_h`](@ref)].

### Prototype
```c
int iox2_client_loan_slice_uninit(iox2_client_h_ref client_handle, struct iox2_request_mut_t *request_struct_ptr, iox2_request_mut_h *request_handle_ptr, size_t number_of_elements);
```
"""
function iox2_client_loan_slice_uninit(client_handle, request_struct_ptr, request_handle_ptr, number_of_elements)
    @ccall libiceoryx2_ffi_c.iox2_client_loan_slice_uninit(client_handle::iox2_client_h_ref, request_struct_ptr::Ptr{iox2_request_mut_t}, request_handle_ptr::Ptr{iox2_request_mut_h}, number_of_elements::Csize_t)::Cint
end

"""
    iox2_client_send_copy(client_handle, data_ptr, size_of_element, number_of_elements, pending_response_struct_ptr, pending_response_handle_ptr)

Sends a copy of the provided data via the client and provides a [[`iox2_pending_response_h`](@ref)] to receive the corresponding responses.

# Arguments

* `client_handle` obtained by [[`iox2_port_factory_client_builder_create`](@ref)](crate::[`iox2_port_factory_client_builder_create`](@ref)) * `pending_response_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_pending_response_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `pending_response_handle_ptr` - An uninitialized or dangling [[`iox2_pending_response_h`](@ref)] handle which will be initialized by this function call. * `data_ptr` pointer to the payload that shall be transmitted * `size_of_element` the size of the payload in bytes * `number_of_elements` the number of elements in the payload

Return [[`IOX2_OK`](@ref)] on success, otherwise [[`iox2_send_error_e`](@ref)](crate::[`iox2_send_error_e`](@ref)).

# Safety

* `client_handle` is valid and non-null * `data_ptr` non-null pointer to a valid position in memory * `data_len` the size of the payload memory * The `pending_response_handle_ptr` is pointing to a valid [[`iox2_pending_response_h`](@ref)].

### Prototype
```c
int iox2_client_send_copy(iox2_client_h_ref client_handle, const void *data_ptr, size_t size_of_element, size_t number_of_elements, struct iox2_pending_response_t *pending_response_struct_ptr, iox2_pending_response_h *pending_response_handle_ptr);
```
"""
function iox2_client_send_copy(client_handle, data_ptr, size_of_element, number_of_elements, pending_response_struct_ptr, pending_response_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_client_send_copy(client_handle::iox2_client_h_ref, data_ptr::Ptr{Cvoid}, size_of_element::Csize_t, number_of_elements::Csize_t, pending_response_struct_ptr::Ptr{iox2_pending_response_t}, pending_response_handle_ptr::Ptr{iox2_pending_response_h})::Cint
end

"""
    iox2_client_drop(client_handle)

This function needs to be called to destroy the client!

# Arguments

* `client_handle` - A valid [[`iox2_client_h`](@ref)]

# Safety

* The `client_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_client_t`](@ref)] can be re-used with a call to [[`iox2_port_factory_client_builder_create`](@ref)](crate::[`iox2_port_factory_client_builder_create`](@ref))!

### Prototype
```c
void iox2_client_drop(iox2_client_h client_handle);
```
"""
function iox2_client_drop(client_handle)
    @ccall libiceoryx2_ffi_c.iox2_client_drop(client_handle::iox2_client_h)::Cvoid
end

"""
    iox2_client_details_client_id(handle, id_struct_ptr, id_handle_ptr)

Returns the unique port id of the client.

# Safety

* `handle` valid pointer to the client details * `id_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_unique_client_id_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `id_handle_ptr` valid pointer to a [[`iox2_unique_client_id_h`](@ref)].

### Prototype
```c
void iox2_client_details_client_id(iox2_client_details_ptr handle, struct iox2_unique_client_id_t *id_struct_ptr, iox2_unique_client_id_h *id_handle_ptr);
```
"""
function iox2_client_details_client_id(handle, id_struct_ptr, id_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_client_details_client_id(handle::iox2_client_details_ptr, id_struct_ptr::Ptr{iox2_unique_client_id_t}, id_handle_ptr::Ptr{iox2_unique_client_id_h})::Cvoid
end

"""
    iox2_client_details_node_id(handle)

Returns the [[`iox2_node_id_ptr`](@ref)](crate::[`iox2_node_id_ptr`](@ref)), an immutable pointer to the node id.

# Safety

* `handle` valid pointer to the client details

### Prototype
```c
iox2_node_id_ptr iox2_client_details_node_id(iox2_client_details_ptr handle);
```
"""
function iox2_client_details_node_id(handle)
    @ccall libiceoryx2_ffi_c.iox2_client_details_node_id(handle::iox2_client_details_ptr)::iox2_node_id_ptr
end

"""
    iox2_client_details_response_buffer_size(handle)

Returns the receive buffer size for incoming responses.

# Safety

* `handle` valid pointer to the client details

### Prototype
```c
c_size_t iox2_client_details_response_buffer_size(iox2_client_details_ptr handle);
```
"""
function iox2_client_details_response_buffer_size(handle)
    @ccall libiceoryx2_ffi_c.iox2_client_details_response_buffer_size(handle::iox2_client_details_ptr)::c_size_t
end

"""
    iox2_client_details_number_of_requests(handle)

The total number of requests available in the clients data segment

# Safety

* `handle` valid pointer to the client details

### Prototype
```c
c_size_t iox2_client_details_number_of_requests(iox2_client_details_ptr handle);
```
"""
function iox2_client_details_number_of_requests(handle)
    @ccall libiceoryx2_ffi_c.iox2_client_details_number_of_requests(handle::iox2_client_details_ptr)::c_size_t
end

"""
    iox2_client_details_max_slice_len(handle)

The current maximum length of a slice.

# Safety

* `handle` valid pointer to the client details

### Prototype
```c
c_size_t iox2_client_details_max_slice_len(iox2_client_details_ptr handle);
```
"""
function iox2_client_details_max_slice_len(handle)
    @ccall libiceoryx2_ffi_c.iox2_client_details_max_slice_len(handle::iox2_client_details_ptr)::c_size_t
end

"""
    iox2_config_creation_error_string(error)

Returns a string literal describing the provided [[`iox2_config_creation_error_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_config_creation_error_string(enum iox2_config_creation_error_e error);
```
"""
function iox2_config_creation_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_config_creation_error_string(error::iox2_config_creation_error_e)::Cstring
end

"""
    iox2_cast_config_ptr(config_handle)

This function casts a [[`iox2_config_h`](@ref)] into a [[`iox2_config_ptr`](@ref)]

# Arguments

* `handle` obtained by [`[`iox2_config_from_file`](@ref)()`], [`[`iox2_config_default`](@ref)()`], [`[`iox2_config_clone`](@ref)()`] or [`[`iox2_config_from_ptr`](@ref)()`]

Returns a [[`iox2_config_ptr`](@ref)]

# Safety

* The `config_handle` must be a valid handle. * The `config_handle` is still valid after the call to this function.

### Prototype
```c
iox2_config_ptr iox2_cast_config_ptr(iox2_config_h config_handle);
```
"""
function iox2_cast_config_ptr(config_handle)
    @ccall libiceoryx2_ffi_c.iox2_cast_config_ptr(config_handle::iox2_config_h)::iox2_config_ptr
end

"""
    iox2_config_global_config()

Returns a pointer to the global config

### Prototype
```c
iox2_config_ptr iox2_config_global_config(void);
```
"""
function iox2_config_global_config()
    @ccall libiceoryx2_ffi_c.iox2_config_global_config()::iox2_config_ptr
end

"""
    iox2_config_default(struct_ptr, handle_ptr)

Creates an iceoryx2 config populated with default values.

# Safety

* `struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_config_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `handle_ptr` - An uninitialized or dangling [[`iox2_config_h`](@ref)] handle which will be initialized by this function call.

### Prototype
```c
int iox2_config_default(struct iox2_config_t *struct_ptr, iox2_config_h *handle_ptr);
```
"""
function iox2_config_default(struct_ptr, handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_config_default(struct_ptr::Ptr{iox2_config_t}, handle_ptr::Ptr{iox2_config_h})::Cint
end

"""
    iox2_config_from_file(struct_ptr, handle_ptr, config_file)

Creates an iceoryx2 config populated values from the provided file.

# Safety

* `struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_config_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `handle_ptr` - An uninitialized or dangling [[`iox2_config_h`](@ref)] handle which will be initialized by this function call. * `config_file` - Must be a valid file path to an existing config file.

### Prototype
```c
int iox2_config_from_file(struct iox2_config_t *struct_ptr, iox2_config_h *handle_ptr, const char *config_file);
```
"""
function iox2_config_from_file(struct_ptr, handle_ptr, config_file)
    @ccall libiceoryx2_ffi_c.iox2_config_from_file(struct_ptr::Ptr{iox2_config_t}, handle_ptr::Ptr{iox2_config_h}, config_file::Cstring)::Cint
end

"""
    iox2_config_from_ptr(config, struct_ptr, handle_ptr)

Clones a config from the provided [[`iox2_config_ptr`](@ref)].

# Safety

* `handle` - Must be a valid pointer. * `struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_config_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `handle_ptr` - An uninitialized or dangling [[`iox2_config_h`](@ref)] handle which will be initialized by this function call.

### Prototype
```c
void iox2_config_from_ptr(iox2_config_ptr config, struct iox2_config_t *struct_ptr, iox2_config_h *handle_ptr);
```
"""
function iox2_config_from_ptr(config, struct_ptr, handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_config_from_ptr(config::iox2_config_ptr, struct_ptr::Ptr{iox2_config_t}, handle_ptr::Ptr{iox2_config_h})::Cvoid
end

"""
    iox2_config_clone(handle, struct_ptr, handle_ptr)

Clones a config from a given non-owning [[`iox2_config_h_ref`](@ref)].

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)]. * `struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_config_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `handle_ptr` - An uninitialized or dangling [[`iox2_config_h`](@ref)] handle which will be initialized by this function call.

### Prototype
```c
void iox2_config_clone(iox2_config_h_ref handle, struct iox2_config_t *struct_ptr, iox2_config_h *handle_ptr);
```
"""
function iox2_config_clone(handle, struct_ptr, handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_config_clone(handle::iox2_config_h_ref, struct_ptr::Ptr{iox2_config_t}, handle_ptr::Ptr{iox2_config_h})::Cvoid
end

"""
    iox2_config_drop(handle)

Takes ownership of the handle and releases all underlying resources.

# Safety

* `handle` - An initialized [[`iox2_config_h`](@ref)] handle which will be uninitialized after this function call.

### Prototype
```c
void iox2_config_drop(iox2_config_h handle);
```
"""
function iox2_config_drop(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_drop(handle::iox2_config_h)::Cvoid
end

"""
    iox2_config_global_prefix(handle)

Returns the prefix used for all files created during runtime

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
const char *iox2_config_global_prefix(iox2_config_h_ref handle);
```
"""
function iox2_config_global_prefix(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_global_prefix(handle::iox2_config_h_ref)::Cstring
end

"""
    iox2_config_global_set_prefix(handle, value)

Sets the prefix used for all files created during runtime

Returns: [[`iox2_semantic_string_error_e`](@ref)](crate::api::[`iox2_semantic_string_error_e`](@ref)) when an invalid file name was provided

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)]. * `value` - A valid file name containing the prefix

### Prototype
```c
int iox2_config_global_set_prefix(iox2_config_h_ref handle, const char *value);
```
"""
function iox2_config_global_set_prefix(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_global_set_prefix(handle::iox2_config_h_ref, value::Cstring)::Cint
end

"""
    iox2_config_global_root_path(handle)

Returns the path under which all other directories or files will be created

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
const char *iox2_config_global_root_path(iox2_config_h_ref handle);
```
"""
function iox2_config_global_root_path(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_global_root_path(handle::iox2_config_h_ref)::Cstring
end

"""
    iox2_config_global_set_root_path(handle, value)

Sets the path under which all other directories or files will be created

Returns: [[`iox2_semantic_string_error_e`](@ref)](crate::api::[`iox2_semantic_string_error_e`](@ref)) when an invalid path was provided

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)]. * `value` - A valid path

### Prototype
```c
int iox2_config_global_set_root_path(iox2_config_h_ref handle, const char *value);
```
"""
function iox2_config_global_set_root_path(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_global_set_root_path(handle::iox2_config_h_ref, value::Cstring)::Cint
end

"""
    iox2_config_global_node_directory(handle)

Returns the directory in which all node files are stored

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
const char *iox2_config_global_node_directory(iox2_config_h_ref handle);
```
"""
function iox2_config_global_node_directory(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_global_node_directory(handle::iox2_config_h_ref)::Cstring
end

"""
    iox2_config_global_node_set_directory(handle, value)

Sets the directory in which all node files are stored

Returns: [[`iox2_semantic_string_error_e`](@ref)](crate::api::[`iox2_semantic_string_error_e`](@ref)) when an invalid path was provided

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)]. * `value` - A valid path

### Prototype
```c
int iox2_config_global_node_set_directory(iox2_config_h_ref handle, const char *value);
```
"""
function iox2_config_global_node_set_directory(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_global_node_set_directory(handle::iox2_config_h_ref, value::Cstring)::Cint
end

"""
    iox2_config_global_node_monitor_suffix(handle)

Returns the suffix of the monitor token

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
const char *iox2_config_global_node_monitor_suffix(iox2_config_h_ref handle);
```
"""
function iox2_config_global_node_monitor_suffix(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_global_node_monitor_suffix(handle::iox2_config_h_ref)::Cstring
end

"""
    iox2_config_global_node_set_monitor_suffix(handle, value)

Sets the suffix of the monitor token

Returns: [[`iox2_semantic_string_error_e`](@ref)](crate::api::[`iox2_semantic_string_error_e`](@ref)) when an invalid file name was provided

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)]. * `value` - A valid file name containing the suffix

### Prototype
```c
int iox2_config_global_node_set_monitor_suffix(iox2_config_h_ref handle, const char *value);
```
"""
function iox2_config_global_node_set_monitor_suffix(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_global_node_set_monitor_suffix(handle::iox2_config_h_ref, value::Cstring)::Cint
end

"""
    iox2_config_global_node_static_config_suffix(handle)

Returns the suffix of the files where the node configuration is stored.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
const char *iox2_config_global_node_static_config_suffix(iox2_config_h_ref handle);
```
"""
function iox2_config_global_node_static_config_suffix(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_global_node_static_config_suffix(handle::iox2_config_h_ref)::Cstring
end

"""
    iox2_config_global_node_set_static_config_suffix(handle, value)

Sets the suffix of the files where the node configuration is stored.

Returns: [[`iox2_semantic_string_error_e`](@ref)](crate::api::[`iox2_semantic_string_error_e`](@ref)) when an invalid file name was provided

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)]. * `value` - A valid file name containing the suffix

### Prototype
```c
int iox2_config_global_node_set_static_config_suffix(iox2_config_h_ref handle, const char *value);
```
"""
function iox2_config_global_node_set_static_config_suffix(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_global_node_set_static_config_suffix(handle::iox2_config_h_ref, value::Cstring)::Cint
end

"""
    iox2_config_global_node_service_tag_suffix(handle)

Returns the suffix of the service tags.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
const char *iox2_config_global_node_service_tag_suffix(iox2_config_h_ref handle);
```
"""
function iox2_config_global_node_service_tag_suffix(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_global_node_service_tag_suffix(handle::iox2_config_h_ref)::Cstring
end

"""
    iox2_config_global_node_set_service_tag_suffix(handle, value)

Sets the suffix of the service tags.

Returns: [[`iox2_semantic_string_error_e`](@ref)](crate::api::[`iox2_semantic_string_error_e`](@ref)) when an invalid file name was provided

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)]. * `value` - A valid file name containing the suffix

### Prototype
```c
int iox2_config_global_node_set_service_tag_suffix(iox2_config_h_ref handle, const char *value);
```
"""
function iox2_config_global_node_set_service_tag_suffix(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_global_node_set_service_tag_suffix(handle::iox2_config_h_ref, value::Cstring)::Cint
end

"""
    iox2_config_global_node_cleanup_dead_nodes_on_creation(handle)

When true, [`[`iox2_node_builder_create`](@ref)()`](crate::api::[`iox2_node_builder_create`](@ref)) checks for dead nodes and cleans up all their stale resources whenever a new [[`iox2_node_h`](@ref)](crate::api::[`iox2_node_h`](@ref)) is created.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
bool iox2_config_global_node_cleanup_dead_nodes_on_creation(iox2_config_h_ref handle);
```
"""
function iox2_config_global_node_cleanup_dead_nodes_on_creation(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_global_node_cleanup_dead_nodes_on_creation(handle::iox2_config_h_ref)::Bool
end

"""
    iox2_config_global_node_set_cleanup_dead_nodes_on_creation(handle, value)

Enable/disable the cleanup dead nodes on creation

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_global_node_set_cleanup_dead_nodes_on_creation(iox2_config_h_ref handle, bool value);
```
"""
function iox2_config_global_node_set_cleanup_dead_nodes_on_creation(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_global_node_set_cleanup_dead_nodes_on_creation(handle::iox2_config_h_ref, value::Bool)::Cvoid
end

"""
    iox2_config_global_node_cleanup_dead_nodes_on_destruction(handle)

When true, the [`[`iox2_node_builder_create`](@ref)()`](crate::api::[`iox2_node_builder_create`](@ref)) checks for dead nodes and cleans up all their stale resources whenever an existing [[`iox2_node_h`](@ref)](crate::api::[`iox2_node_h`](@ref)) is going out of scope.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
bool iox2_config_global_node_cleanup_dead_nodes_on_destruction(iox2_config_h_ref handle);
```
"""
function iox2_config_global_node_cleanup_dead_nodes_on_destruction(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_global_node_cleanup_dead_nodes_on_destruction(handle::iox2_config_h_ref)::Bool
end

"""
    iox2_config_global_node_set_cleanup_dead_nodes_on_destruction(handle, value)

Enable/disable the cleanup dead nodes on destruction

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_global_node_set_cleanup_dead_nodes_on_destruction(iox2_config_h_ref handle, bool value);
```
"""
function iox2_config_global_node_set_cleanup_dead_nodes_on_destruction(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_global_node_set_cleanup_dead_nodes_on_destruction(handle::iox2_config_h_ref, value::Bool)::Cvoid
end

"""
    iox2_config_global_service_directory(handle)

Returns the directory in which all service files are stored

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
const char *iox2_config_global_service_directory(iox2_config_h_ref handle);
```
"""
function iox2_config_global_service_directory(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_global_service_directory(handle::iox2_config_h_ref)::Cstring
end

"""
    iox2_config_global_service_set_directory(handle, value)

Sets the directory in which all service files are stored

Returns: [[`iox2_semantic_string_error_e`](@ref)](crate::api::[`iox2_semantic_string_error_e`](@ref)) when an invalid path was provided

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)]. * `value` - A valid path

### Prototype
```c
int iox2_config_global_service_set_directory(iox2_config_h_ref handle, const char *value);
```
"""
function iox2_config_global_service_set_directory(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_global_service_set_directory(handle::iox2_config_h_ref, value::Cstring)::Cint
end

"""
    iox2_config_global_service_data_segment_suffix(handle)

Returns the suffix of the ports data segment

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
const char *iox2_config_global_service_data_segment_suffix(iox2_config_h_ref handle);
```
"""
function iox2_config_global_service_data_segment_suffix(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_global_service_data_segment_suffix(handle::iox2_config_h_ref)::Cstring
end

"""
    iox2_config_global_service_set_data_segment_suffix(handle, value)

Sets the suffix of the ports data segment

Returns: [[`iox2_semantic_string_error_e`](@ref)](crate::api::[`iox2_semantic_string_error_e`](@ref)) when an invalid file name was provided

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)]. * `value` - A valid file name containing the suffix

### Prototype
```c
int iox2_config_global_service_set_data_segment_suffix(iox2_config_h_ref handle, const char *value);
```
"""
function iox2_config_global_service_set_data_segment_suffix(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_global_service_set_data_segment_suffix(handle::iox2_config_h_ref, value::Cstring)::Cint
end

"""
    iox2_config_global_service_static_config_storage_suffix(handle)

Returns the suffix of the static config file

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
const char *iox2_config_global_service_static_config_storage_suffix(iox2_config_h_ref handle);
```
"""
function iox2_config_global_service_static_config_storage_suffix(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_global_service_static_config_storage_suffix(handle::iox2_config_h_ref)::Cstring
end

"""
    iox2_config_global_service_set_static_config_storage_suffix(handle, value)

Sets the suffix of the static config file

Returns: [[`iox2_semantic_string_error_e`](@ref)](crate::api::[`iox2_semantic_string_error_e`](@ref)) when an invalid file name was provided

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)]. * `value` - A valid file name containing the suffix

### Prototype
```c
int iox2_config_global_service_set_static_config_storage_suffix(iox2_config_h_ref handle, const char *value);
```
"""
function iox2_config_global_service_set_static_config_storage_suffix(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_global_service_set_static_config_storage_suffix(handle::iox2_config_h_ref, value::Cstring)::Cint
end

"""
    iox2_config_global_service_dynamic_config_storage_suffix(handle)

Returns the suffix of the dynamic config file

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
const char *iox2_config_global_service_dynamic_config_storage_suffix(iox2_config_h_ref handle);
```
"""
function iox2_config_global_service_dynamic_config_storage_suffix(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_global_service_dynamic_config_storage_suffix(handle::iox2_config_h_ref)::Cstring
end

"""
    iox2_config_global_service_set_dynamic_config_storage_suffix(handle, value)

Sets the suffix of the dynamic config file

Returns: [[`iox2_semantic_string_error_e`](@ref)](crate::api::[`iox2_semantic_string_error_e`](@ref)) when an invalid file name was provided

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)]. * `value` - A valid file name containing the suffix

### Prototype
```c
int iox2_config_global_service_set_dynamic_config_storage_suffix(iox2_config_h_ref handle, const char *value);
```
"""
function iox2_config_global_service_set_dynamic_config_storage_suffix(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_global_service_set_dynamic_config_storage_suffix(handle::iox2_config_h_ref, value::Cstring)::Cint
end

"""
    iox2_config_global_service_creation_timeout(handle, secs, nsecs)

Returns the duration how long another process will wait until the service creation is finalized

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)]. * `secs` - A valid pointer pointing to a [`u64`]. * `nsecs` - A valid pointer pointing to a [`u32`]

### Prototype
```c
void iox2_config_global_service_creation_timeout(iox2_config_h_ref handle, uint64_t *secs, uint32_t *nsecs);
```
"""
function iox2_config_global_service_creation_timeout(handle, secs, nsecs)
    @ccall libiceoryx2_ffi_c.iox2_config_global_service_creation_timeout(handle::iox2_config_h_ref, secs::Ptr{UInt64}, nsecs::Ptr{UInt32})::Cvoid
end

"""
    iox2_config_global_service_set_creation_timeout(handle, sec, nsec)

Sets the creation timeout

Returns: [[`iox2_semantic_string_error_e`](@ref)](crate::api::[`iox2_semantic_string_error_e`](@ref)) when an invalid file name was provided

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)]. * `value` - A valid file name containing the suffix

### Prototype
```c
void iox2_config_global_service_set_creation_timeout(iox2_config_h_ref handle, uint64_t sec, uint32_t nsec);
```
"""
function iox2_config_global_service_set_creation_timeout(handle, sec, nsec)
    @ccall libiceoryx2_ffi_c.iox2_config_global_service_set_creation_timeout(handle::iox2_config_h_ref, sec::UInt64, nsec::UInt32)::Cvoid
end

"""
    iox2_config_global_service_connection_suffix(handle)

The suffix of a one-to-one connection

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
const char *iox2_config_global_service_connection_suffix(iox2_config_h_ref handle);
```
"""
function iox2_config_global_service_connection_suffix(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_global_service_connection_suffix(handle::iox2_config_h_ref)::Cstring
end

"""
    iox2_config_global_service_set_connection_suffix(handle, value)

Set the suffix of a one-to-one connection

Returns: [[`iox2_semantic_string_error_e`](@ref)](crate::api::[`iox2_semantic_string_error_e`](@ref)) when an invalid file name was provided

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)]. * `value` - A valid file name containing the suffix

### Prototype
```c
int iox2_config_global_service_set_connection_suffix(iox2_config_h_ref handle, const char *value);
```
"""
function iox2_config_global_service_set_connection_suffix(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_global_service_set_connection_suffix(handle::iox2_config_h_ref, value::Cstring)::Cint
end

"""
    iox2_config_global_service_event_connection_suffix(handle)

Returns the suffix of a one-to-one connection

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
const char *iox2_config_global_service_event_connection_suffix(iox2_config_h_ref handle);
```
"""
function iox2_config_global_service_event_connection_suffix(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_global_service_event_connection_suffix(handle::iox2_config_h_ref)::Cstring
end

"""
    iox2_config_global_service_set_event_connection_suffix(handle, value)

Sets the suffix of a one-to-one connection

Returns: [[`iox2_semantic_string_error_e`](@ref)](crate::api::[`iox2_semantic_string_error_e`](@ref)) when an invalid file name was provided

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)]. * `value` - A valid file name containing the suffix

### Prototype
```c
int iox2_config_global_service_set_event_connection_suffix(iox2_config_h_ref handle, const char *value);
```
"""
function iox2_config_global_service_set_event_connection_suffix(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_global_service_set_event_connection_suffix(handle::iox2_config_h_ref, value::Cstring)::Cint
end

"""
    iox2_config_global_service_blackboard_mgmt_suffix(handle)

Returns the suffix of the blackboard management data segment

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
const char *iox2_config_global_service_blackboard_mgmt_suffix(iox2_config_h_ref handle);
```
"""
function iox2_config_global_service_blackboard_mgmt_suffix(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_global_service_blackboard_mgmt_suffix(handle::iox2_config_h_ref)::Cstring
end

"""
    iox2_config_global_service_set_blackboard_mgmt_suffix(handle, value)

Sets the suffix of the blackboard management data segment

Returns: [[`iox2_semantic_string_error_e`](@ref)](crate::api::[`iox2_semantic_string_error_e`](@ref)) when an invalid file name was provided

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)]. * `value` - A valid file name containing the suffix

### Prototype
```c
int iox2_config_global_service_set_blackboard_mgmt_suffix(iox2_config_h_ref handle, const char *value);
```
"""
function iox2_config_global_service_set_blackboard_mgmt_suffix(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_global_service_set_blackboard_mgmt_suffix(handle::iox2_config_h_ref, value::Cstring)::Cint
end

"""
    iox2_config_global_service_blackboard_data_suffix(handle)

Returns the suffix of the blackboard payload data segment

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
const char *iox2_config_global_service_blackboard_data_suffix(iox2_config_h_ref handle);
```
"""
function iox2_config_global_service_blackboard_data_suffix(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_global_service_blackboard_data_suffix(handle::iox2_config_h_ref)::Cstring
end

"""
    iox2_config_global_service_set_blackboard_data_suffix(handle, value)

Sets the suffix of the blackboard payload data segment

Returns: [[`iox2_semantic_string_error_e`](@ref)](crate::api::[`iox2_semantic_string_error_e`](@ref)) when an invalid file name was provided

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)]. * `value` - A valid file name containing the suffix

### Prototype
```c
int iox2_config_global_service_set_blackboard_data_suffix(iox2_config_h_ref handle, const char *value);
```
"""
function iox2_config_global_service_set_blackboard_data_suffix(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_global_service_set_blackboard_data_suffix(handle::iox2_config_h_ref, value::Cstring)::Cint
end

"""
    iox2_config_defaults_publish_subscribe_max_subscribers(handle)

Returns the maximum amount of supported [[`iox2_subscriber_h`](@ref)](crate::api::[`iox2_subscriber_h`](@ref))s

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
c_size_t iox2_config_defaults_publish_subscribe_max_subscribers(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_publish_subscribe_max_subscribers(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_publish_subscribe_max_subscribers(handle::iox2_config_h_ref)::c_size_t
end

"""
    iox2_config_defaults_publish_subscribe_set_max_subscribers(handle, value)

Sets the maximum amount of supported [[`iox2_subscriber_h`](@ref)](crate::api::[`iox2_subscriber_h`](@ref))s

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_publish_subscribe_set_max_subscribers(iox2_config_h_ref handle, c_size_t value);
```
"""
function iox2_config_defaults_publish_subscribe_set_max_subscribers(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_publish_subscribe_set_max_subscribers(handle::iox2_config_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_config_defaults_publish_subscribe_max_publishers(handle)

Returns maximum amount of supported [[`iox2_publisher_h`](@ref)](crate::api::[`iox2_publisher_h`](@ref))s

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
c_size_t iox2_config_defaults_publish_subscribe_max_publishers(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_publish_subscribe_max_publishers(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_publish_subscribe_max_publishers(handle::iox2_config_h_ref)::c_size_t
end

"""
    iox2_config_defaults_publish_subscribe_set_max_publishers(handle, value)

Sets the maximum amount of supported [[`iox2_publisher_h`](@ref)](crate::api::[`iox2_publisher_h`](@ref))s

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_publish_subscribe_set_max_publishers(iox2_config_h_ref handle, c_size_t value);
```
"""
function iox2_config_defaults_publish_subscribe_set_max_publishers(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_publish_subscribe_set_max_publishers(handle::iox2_config_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_config_defaults_publish_subscribe_max_nodes(handle)

Returns the maximum amount of supported [[`iox2_node_h`](@ref)](crate::api::[`iox2_node_h`](@ref))s. Defines indirectly how many processes can open the service at the same time.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
c_size_t iox2_config_defaults_publish_subscribe_max_nodes(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_publish_subscribe_max_nodes(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_publish_subscribe_max_nodes(handle::iox2_config_h_ref)::c_size_t
end

"""
    iox2_config_defaults_publish_subscribe_set_max_nodes(handle, value)

Sets the maximum amount of supported [[`iox2_node_h`](@ref)](crate::api::[`iox2_node_h`](@ref))s.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_publish_subscribe_set_max_nodes(iox2_config_h_ref handle, c_size_t value);
```
"""
function iox2_config_defaults_publish_subscribe_set_max_nodes(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_publish_subscribe_set_max_nodes(handle::iox2_config_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_config_defaults_publish_subscribe_subscriber_max_buffer_size(handle)

Returns the maximum buffer size a [[`iox2_subscriber_h`](@ref)](crate::api::[`iox2_subscriber_h`](@ref)) can have

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
c_size_t iox2_config_defaults_publish_subscribe_subscriber_max_buffer_size(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_publish_subscribe_subscriber_max_buffer_size(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_publish_subscribe_subscriber_max_buffer_size(handle::iox2_config_h_ref)::c_size_t
end

"""
    iox2_config_defaults_publish_subscribe_set_subscriber_max_buffer_size(handle, value)

Sets the maximum buffer size a [[`iox2_subscriber_h`](@ref)](crate::api::[`iox2_subscriber_h`](@ref)) can have

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_publish_subscribe_set_subscriber_max_buffer_size(iox2_config_h_ref handle, c_size_t value);
```
"""
function iox2_config_defaults_publish_subscribe_set_subscriber_max_buffer_size(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_publish_subscribe_set_subscriber_max_buffer_size(handle::iox2_config_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_config_defaults_publish_subscribe_subscriber_max_borrowed_samples(handle)

Returns the maximum amount of [[`iox2_sample_h`](@ref)](crate::api::[`iox2_sample_h`](@ref))s a [[`iox2_subscriber_h`](@ref)](crate::api::[`iox2_subscriber_h`](@ref)) can hold at the same time.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
c_size_t iox2_config_defaults_publish_subscribe_subscriber_max_borrowed_samples(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_publish_subscribe_subscriber_max_borrowed_samples(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_publish_subscribe_subscriber_max_borrowed_samples(handle::iox2_config_h_ref)::c_size_t
end

"""
    iox2_config_defaults_publish_subscribe_set_subscriber_max_borrowed_samples(handle, value)

Sets the maximum amount of [[`iox2_sample_h`](@ref)](crate::api::[`iox2_sample_h`](@ref))s a [[`iox2_subscriber_h`](@ref)](crate::api::[`iox2_subscriber_h`](@ref)) can hold at the same time.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_publish_subscribe_set_subscriber_max_borrowed_samples(iox2_config_h_ref handle, c_size_t value);
```
"""
function iox2_config_defaults_publish_subscribe_set_subscriber_max_borrowed_samples(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_publish_subscribe_set_subscriber_max_borrowed_samples(handle::iox2_config_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_config_defaults_publish_subscribe_publisher_max_loaned_samples(handle)

Returns the maximum amount of [[`iox2_sample_mut_h`](@ref)](crate::api::[`iox2_sample_mut_h`](@ref))s a [[`iox2_publisher_h`](@ref)](crate::api::[`iox2_publisher_h`](@ref)) can loan at the same time.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
c_size_t iox2_config_defaults_publish_subscribe_publisher_max_loaned_samples(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_publish_subscribe_publisher_max_loaned_samples(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_publish_subscribe_publisher_max_loaned_samples(handle::iox2_config_h_ref)::c_size_t
end

"""
    iox2_config_defaults_publish_subscribe_set_publisher_max_loaned_samples(handle, value)

Sets the maximum amount of [[`iox2_sample_mut_h`](@ref)](crate::api::[`iox2_sample_mut_h`](@ref))s a [[`iox2_publisher_h`](@ref)](crate::api::[`iox2_publisher_h`](@ref)) can loan at the same time.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_publish_subscribe_set_publisher_max_loaned_samples(iox2_config_h_ref handle, c_size_t value);
```
"""
function iox2_config_defaults_publish_subscribe_set_publisher_max_loaned_samples(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_publish_subscribe_set_publisher_max_loaned_samples(handle::iox2_config_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_config_defaults_publish_subscribe_publisher_history_size(handle)

Returns the maximum history size a [[`iox2_subscriber_h`](@ref)](crate::api::[`iox2_subscriber_h`](@ref)) can request from a [[`iox2_publisher_h`](@ref)](crate::api::[`iox2_publisher_h`](@ref)).

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
c_size_t iox2_config_defaults_publish_subscribe_publisher_history_size(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_publish_subscribe_publisher_history_size(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_publish_subscribe_publisher_history_size(handle::iox2_config_h_ref)::c_size_t
end

"""
    iox2_config_defaults_publish_subscribe_set_publisher_history_size(handle, value)

Sets the maximum history size a [[`iox2_subscriber_h`](@ref)](crate::api::[`iox2_subscriber_h`](@ref)) can request from a [[`iox2_publisher_h`](@ref)](crate::api::[`iox2_publisher_h`](@ref)).

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_publish_subscribe_set_publisher_history_size(iox2_config_h_ref handle, c_size_t value);
```
"""
function iox2_config_defaults_publish_subscribe_set_publisher_history_size(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_publish_subscribe_set_publisher_history_size(handle::iox2_config_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_config_defaults_publish_subscribe_enable_safe_overflow(handle)

Defines how the [[`iox2_subscriber_h`](@ref)](crate::api::[`iox2_subscriber_h`](@ref)) buffer behaves when it is full. When safe overflow is activated, the [[`iox2_publisher_h`](@ref)](crate::api::[`iox2_publisher_h`](@ref)) will replace the oldest [[`iox2_sample_h`](@ref)](crate::api::[`iox2_sample_h`](@ref)) with the newest one.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
bool iox2_config_defaults_publish_subscribe_enable_safe_overflow(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_publish_subscribe_enable_safe_overflow(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_publish_subscribe_enable_safe_overflow(handle::iox2_config_h_ref)::Bool
end

"""
    iox2_config_defaults_publish_subscribe_set_enable_safe_overflow(handle, value)

Enables/disables safe overflow

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_publish_subscribe_set_enable_safe_overflow(iox2_config_h_ref handle, bool value);
```
"""
function iox2_config_defaults_publish_subscribe_set_enable_safe_overflow(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_publish_subscribe_set_enable_safe_overflow(handle::iox2_config_h_ref, value::Bool)::Cvoid
end

"""
    iox2_config_defaults_publish_subscribe_unable_to_deliver_strategy(handle)

If safe overflow is deactivated it defines the deliver strategy of the [[`iox2_publisher_h`](@ref)](crate::api::[`iox2_publisher_h`](@ref)) when the [[`iox2_subscriber_h`](@ref)](crate::api::[`iox2_subscriber_h`](@ref))s buffer is full.

Returns [[`iox2_unable_to_deliver_strategy_e`](@ref)]

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
int iox2_config_defaults_publish_subscribe_unable_to_deliver_strategy(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_publish_subscribe_unable_to_deliver_strategy(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_publish_subscribe_unable_to_deliver_strategy(handle::iox2_config_h_ref)::Cint
end

"""
    iox2_config_defaults_publish_subscribe_set_unable_to_deliver_strategy(handle, value)

Define the unable to deliver strategy

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_publish_subscribe_set_unable_to_deliver_strategy(iox2_config_h_ref handle, enum iox2_unable_to_deliver_strategy_e value);
```
"""
function iox2_config_defaults_publish_subscribe_set_unable_to_deliver_strategy(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_publish_subscribe_set_unable_to_deliver_strategy(handle::iox2_config_h_ref, value::iox2_unable_to_deliver_strategy_e)::Cvoid
end

"""
    iox2_config_defaults_publish_subscribe_subscriber_expired_connection_buffer(handle)

Defines the size of the internal [[`iox2_subscriber_h`](@ref)](crate::api::[`iox2_subscriber_h`](@ref)) buffer that contains expired connections. An connection is expired when the [[`iox2_publisher_h`](@ref)](crate::api::[`iox2_publisher_h`](@ref)) disconnected from a service and the connection still contains unconsumed [[`iox2_sample_h`](@ref)](crate::api::[`iox2_sample_h`](@ref))s.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
c_size_t iox2_config_defaults_publish_subscribe_subscriber_expired_connection_buffer(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_publish_subscribe_subscriber_expired_connection_buffer(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_publish_subscribe_subscriber_expired_connection_buffer(handle::iox2_config_h_ref)::c_size_t
end

"""
    iox2_config_defaults_publish_subscribe_set_subscriber_expired_connection_buffer(handle, value)

Set the expired connection buffer size

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_publish_subscribe_set_subscriber_expired_connection_buffer(iox2_config_h_ref handle, c_size_t value);
```
"""
function iox2_config_defaults_publish_subscribe_set_subscriber_expired_connection_buffer(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_publish_subscribe_set_subscriber_expired_connection_buffer(handle::iox2_config_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_config_defaults_request_response_client_expired_connection_buffer(handle)

Returns the expired connection buffer size for [[`iox2_client_h`](@ref)](crate::api::[`iox2_client_h`](@ref)) to retrieve [[`iox2_response_h`](@ref)](crate::api::[`iox2_response_h`](@ref)) from disconnected [[`iox2_server_h`](@ref)](crate::api::[`iox2_server_h`](@ref))

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
c_size_t iox2_config_defaults_request_response_client_expired_connection_buffer(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_request_response_client_expired_connection_buffer(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_client_expired_connection_buffer(handle::iox2_config_h_ref)::c_size_t
end

"""
    iox2_config_defaults_request_response_set_client_expired_connection_buffer(handle, value)

Sets the expired connection buffer size for [[`iox2_client_h`](@ref)](crate::api::[`iox2_client_h`](@ref)).

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_request_response_set_client_expired_connection_buffer(iox2_config_h_ref handle, c_size_t value);
```
"""
function iox2_config_defaults_request_response_set_client_expired_connection_buffer(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_set_client_expired_connection_buffer(handle::iox2_config_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_config_defaults_request_response_server_expired_connection_buffer(handle)

Returns the expired connection buffer size for [`iox2_serve_h`](crate::api::[`iox2_server_h`](@ref)) to retrieve [[`iox2_active_request_h`](@ref)](crate::api::[`iox2_active_request_h`](@ref)) from disconnected [[`iox2_client_h`](@ref)](crate::api::[`iox2_client_h`](@ref))

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
c_size_t iox2_config_defaults_request_response_server_expired_connection_buffer(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_request_response_server_expired_connection_buffer(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_server_expired_connection_buffer(handle::iox2_config_h_ref)::c_size_t
end

"""
    iox2_config_defaults_request_response_set_server_expired_connection_buffer(handle, value)

Sets the expired connection buffer size for [[`iox2_server_h`](@ref)](crate::api::[`iox2_server_h`](@ref)).

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_request_response_set_server_expired_connection_buffer(iox2_config_h_ref handle, c_size_t value);
```
"""
function iox2_config_defaults_request_response_set_server_expired_connection_buffer(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_set_server_expired_connection_buffer(handle::iox2_config_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_config_defaults_request_response_client_unable_to_deliver_strategy(handle)

If safe overflow is deactivated it defines the deliver strategy of the [[`iox2_client_h`](@ref)](crate::api::[`iox2_client_h`](@ref)) when the [[`iox2_server_h`](@ref)](crate::api::[`iox2_server_h`](@ref))s request buffer is full.

Returns [[`iox2_unable_to_deliver_strategy_e`](@ref)]

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
int iox2_config_defaults_request_response_client_unable_to_deliver_strategy(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_request_response_client_unable_to_deliver_strategy(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_client_unable_to_deliver_strategy(handle::iox2_config_h_ref)::Cint
end

"""
    iox2_config_defaults_request_response_set_client_unable_to_deliver_strategy(handle, value)

Defines the unable to deliver strategy for the [[`iox2_client_h`](@ref)](crate::api::[`iox2_client_h`](@ref)).

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_request_response_set_client_unable_to_deliver_strategy(iox2_config_h_ref handle, enum iox2_unable_to_deliver_strategy_e value);
```
"""
function iox2_config_defaults_request_response_set_client_unable_to_deliver_strategy(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_set_client_unable_to_deliver_strategy(handle::iox2_config_h_ref, value::iox2_unable_to_deliver_strategy_e)::Cvoid
end

"""
    iox2_config_defaults_request_response_server_unable_to_deliver_strategy(handle)

If safe overflow is deactivated it defines the deliver strategy of the [[`iox2_server_h`](@ref)](crate::api::[`iox2_server_h`](@ref)) when the [[`iox2_client_h`](@ref)](crate::api::[`iox2_client_h`](@ref))s response buffer is full.

Returns [[`iox2_unable_to_deliver_strategy_e`](@ref)]

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
int iox2_config_defaults_request_response_server_unable_to_deliver_strategy(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_request_response_server_unable_to_deliver_strategy(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_server_unable_to_deliver_strategy(handle::iox2_config_h_ref)::Cint
end

"""
    iox2_config_defaults_request_response_set_server_unable_to_deliver_strategy(handle, value)

Defines the unable to deliver strategy for the [[`iox2_server_h`](@ref)](crate::api::[`iox2_server_h`](@ref)).

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_request_response_set_server_unable_to_deliver_strategy(iox2_config_h_ref handle, enum iox2_unable_to_deliver_strategy_e value);
```
"""
function iox2_config_defaults_request_response_set_server_unable_to_deliver_strategy(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_set_server_unable_to_deliver_strategy(handle::iox2_config_h_ref, value::iox2_unable_to_deliver_strategy_e)::Cvoid
end

"""
    iox2_config_defaults_request_response_has_fire_and_forget_requests(handle)

Returns if the service supports fire and forget requests. Those are requests where the [[`iox2_client_h`](@ref)](crate::api::[`iox2_client_h`](@ref)) does not expect a response.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
bool iox2_config_defaults_request_response_has_fire_and_forget_requests(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_request_response_has_fire_and_forget_requests(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_has_fire_and_forget_requests(handle::iox2_config_h_ref)::Bool
end

"""
    iox2_config_defaults_request_response_set_fire_and_forget_requests(handle, value)

Defines if request response services shall support fire and forget requests.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_request_response_set_fire_and_forget_requests(iox2_config_h_ref handle, bool value);
```
"""
function iox2_config_defaults_request_response_set_fire_and_forget_requests(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_set_fire_and_forget_requests(handle::iox2_config_h_ref, value::Bool)::Cvoid
end

"""
    iox2_config_defaults_request_response_enable_safe_overflow_for_requests(handle)

Defines how the [[`iox2_server_h`](@ref)](crate::api::[`iox2_server_h`](@ref)) buffer behaves when it is full. When safe overflow is activated, the [[`iox2_client_h`](@ref)](crate::api::[`iox2_client_h`](@ref)) will replace the oldest [[`iox2_request_mut_h`](@ref)](crate::api::[`iox2_request_mut_h`](@ref)) with the newest one.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
bool iox2_config_defaults_request_response_enable_safe_overflow_for_requests(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_request_response_enable_safe_overflow_for_requests(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_enable_safe_overflow_for_requests(handle::iox2_config_h_ref)::Bool
end

"""
    iox2_config_defaults_request_response_set_enable_safe_overflow_for_requests(handle, value)

Enables/disables safe overflow for requests

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_request_response_set_enable_safe_overflow_for_requests(iox2_config_h_ref handle, bool value);
```
"""
function iox2_config_defaults_request_response_set_enable_safe_overflow_for_requests(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_set_enable_safe_overflow_for_requests(handle::iox2_config_h_ref, value::Bool)::Cvoid
end

"""
    iox2_config_defaults_request_response_enable_safe_overflow_for_responses(handle)

Defines how the [[`iox2_client_h`](@ref)](crate::api::[`iox2_client_h`](@ref)) buffer behaves when it is full. When safe overflow is activated, the [[`iox2_server_h`](@ref)](crate::api::[`iox2_server_h`](@ref)) will replace the oldest [[`iox2_response_h`](@ref)](crate::api::[`iox2_response_h`](@ref)) with the newest one.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
bool iox2_config_defaults_request_response_enable_safe_overflow_for_responses(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_request_response_enable_safe_overflow_for_responses(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_enable_safe_overflow_for_responses(handle::iox2_config_h_ref)::Bool
end

"""
    iox2_config_defaults_request_response_set_enable_safe_overflow_for_responses(handle, value)

Enables/disables safe overflow for responses

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_request_response_set_enable_safe_overflow_for_responses(iox2_config_h_ref handle, bool value);
```
"""
function iox2_config_defaults_request_response_set_enable_safe_overflow_for_responses(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_set_enable_safe_overflow_for_responses(handle::iox2_config_h_ref, value::Bool)::Cvoid
end

"""
    iox2_config_defaults_request_response_max_active_requests_per_client(handle)

Returns how many active requests a [[`iox2_client_h`](@ref)](crate::api::[`iox2_client_h`](@ref)) can send out in parallel and expect responses from.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
c_size_t iox2_config_defaults_request_response_max_active_requests_per_client(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_request_response_max_active_requests_per_client(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_max_active_requests_per_client(handle::iox2_config_h_ref)::c_size_t
end

"""
    iox2_config_defaults_request_response_set_max_active_requests_per_client(handle, value)

Sets the max number of active requests.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_request_response_set_max_active_requests_per_client(iox2_config_h_ref handle, c_size_t value);
```
"""
function iox2_config_defaults_request_response_set_max_active_requests_per_client(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_set_max_active_requests_per_client(handle::iox2_config_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_config_defaults_request_response_max_response_buffer_size(handle)

Returns the size of the [[`iox2_response_h`](@ref)](crate::api::[`iox2_response_h`](@ref)) buffer per request on the [[`iox2_client_h`](@ref)](crate::api::[`iox2_client_h`](@ref)) side. This is an important setting when a stream of responses is expected.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
c_size_t iox2_config_defaults_request_response_max_response_buffer_size(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_request_response_max_response_buffer_size(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_max_response_buffer_size(handle::iox2_config_h_ref)::c_size_t
end

"""
    iox2_config_defaults_request_response_set_max_response_buffer_size(handle, value)

Sets the max response buffer size

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_request_response_set_max_response_buffer_size(iox2_config_h_ref handle, c_size_t value);
```
"""
function iox2_config_defaults_request_response_set_max_response_buffer_size(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_set_max_response_buffer_size(handle::iox2_config_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_config_defaults_request_response_max_servers(handle)

Returns how many [[`iox2_server_h`](@ref)](crate::api::[`iox2_server_h`](@ref))s can be connected to the same service at the same time.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
c_size_t iox2_config_defaults_request_response_max_servers(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_request_response_max_servers(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_max_servers(handle::iox2_config_h_ref)::c_size_t
end

"""
    iox2_config_defaults_request_response_set_max_servers(handle, value)

Sets the maximum number of servers per service

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_request_response_set_max_servers(iox2_config_h_ref handle, c_size_t value);
```
"""
function iox2_config_defaults_request_response_set_max_servers(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_set_max_servers(handle::iox2_config_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_config_defaults_request_response_max_clients(handle)

Returns how many [[`iox2_client_h`](@ref)](crate::api::[`iox2_client_h`](@ref))s can be connected to the same service at the same time.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
c_size_t iox2_config_defaults_request_response_max_clients(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_request_response_max_clients(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_max_clients(handle::iox2_config_h_ref)::c_size_t
end

"""
    iox2_config_defaults_request_response_set_max_clients(handle, value)

Sets the maximum number of clients per service

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_request_response_set_max_clients(iox2_config_h_ref handle, c_size_t value);
```
"""
function iox2_config_defaults_request_response_set_max_clients(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_set_max_clients(handle::iox2_config_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_config_defaults_request_response_max_nodes(handle)

Returns how many [[`iox2_node_h`](@ref)](crate::api::[`iox2_node_h`](@ref))s can open the same service at the same time.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
c_size_t iox2_config_defaults_request_response_max_nodes(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_request_response_max_nodes(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_max_nodes(handle::iox2_config_h_ref)::c_size_t
end

"""
    iox2_config_defaults_request_response_set_max_nodes(handle, value)

Sets the maximum number of nodes per service

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_request_response_set_max_nodes(iox2_config_h_ref handle, c_size_t value);
```
"""
function iox2_config_defaults_request_response_set_max_nodes(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_set_max_nodes(handle::iox2_config_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_config_defaults_request_response_max_borrowed_responses_per_pending_response(handle)

Returns how many [[`iox2_response_h`](@ref)](crate::api::[`iox2_response_h`](@ref))s can be borrowed per request.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
c_size_t iox2_config_defaults_request_response_max_borrowed_responses_per_pending_response(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_request_response_max_borrowed_responses_per_pending_response(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_max_borrowed_responses_per_pending_response(handle::iox2_config_h_ref)::c_size_t
end

"""
    iox2_config_defaults_request_response_set_max_borrowed_responses_per_pending_response(handle, value)

Sets the maximum number of borrowed responses per pending response

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_request_response_set_max_borrowed_responses_per_pending_response(iox2_config_h_ref handle, c_size_t value);
```
"""
function iox2_config_defaults_request_response_set_max_borrowed_responses_per_pending_response(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_set_max_borrowed_responses_per_pending_response(handle::iox2_config_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_config_defaults_request_response_max_loaned_requests(handle)

Returns how many [[`iox2_request_mut_h`](@ref)](crate::api::[`iox2_request_mut_h`](@ref))s can be loaned at most at the same time with a [[`iox2_client_h`](@ref)](crate::api::[`iox2_client_h`](@ref)).

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
c_size_t iox2_config_defaults_request_response_max_loaned_requests(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_request_response_max_loaned_requests(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_max_loaned_requests(handle::iox2_config_h_ref)::c_size_t
end

"""
    iox2_config_defaults_request_response_set_max_loaned_requests(handle, value)

Sets the maximum number of loaned requests

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_request_response_set_max_loaned_requests(iox2_config_h_ref handle, c_size_t value);
```
"""
function iox2_config_defaults_request_response_set_max_loaned_requests(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_set_max_loaned_requests(handle::iox2_config_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_config_defaults_request_response_server_max_loaned_responses_per_request(handle)

Returns how many [[`iox2_response_mut_h`](@ref)](crate::api::[`iox2_response_mut_h`](@ref))s can be loaned at most at the same time with a [[`iox2_server_h`](@ref)](crate::api::[`iox2_server_h`](@ref)) per request.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
c_size_t iox2_config_defaults_request_response_server_max_loaned_responses_per_request(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_request_response_server_max_loaned_responses_per_request(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_server_max_loaned_responses_per_request(handle::iox2_config_h_ref)::c_size_t
end

"""
    iox2_config_defaults_request_response_set_server_max_loaned_responses_per_request(handle, value)

Sets the maximum number of loaned responses per request

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_request_response_set_server_max_loaned_responses_per_request(iox2_config_h_ref handle, c_size_t value);
```
"""
function iox2_config_defaults_request_response_set_server_max_loaned_responses_per_request(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_request_response_set_server_max_loaned_responses_per_request(handle::iox2_config_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_config_defaults_event_max_listeners(handle)

Returns the maximum amount of supported [[`iox2_listener_h`](@ref)](crate::api::[`iox2_listener_h`](@ref))

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
c_size_t iox2_config_defaults_event_max_listeners(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_event_max_listeners(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_event_max_listeners(handle::iox2_config_h_ref)::c_size_t
end

"""
    iox2_config_defaults_event_set_max_listeners(handle, value)

Sets the maximum amount of supported [[`iox2_listener_h`](@ref)](crate::api::[`iox2_listener_h`](@ref))

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_event_set_max_listeners(iox2_config_h_ref handle, c_size_t value);
```
"""
function iox2_config_defaults_event_set_max_listeners(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_event_set_max_listeners(handle::iox2_config_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_config_defaults_event_deadline(handle, seconds, nanoseconds)

Returns the default deadline for event services. If there is a deadline set, the provided arguments `seconds` and `nanoseconds` will be set `true` is returned. Otherwise, false is returned and nothing is set.

# Safety

* `notifier_handle` is valid, non-null and was obtained via [[`iox2_port_factory_listener_builder_create`](@ref)](crate::[`iox2_port_factory_listener_builder_create`](@ref)) * `seconds` is pointing to a valid memory location and non-null * `nanoseconds` is pointing to a valid memory location and non-null

### Prototype
```c
bool iox2_config_defaults_event_deadline(iox2_config_h_ref handle, uint64_t *seconds, uint32_t *nanoseconds);
```
"""
function iox2_config_defaults_event_deadline(handle, seconds, nanoseconds)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_event_deadline(handle::iox2_config_h_ref, seconds::Ptr{UInt64}, nanoseconds::Ptr{UInt32})::Bool
end

"""
    iox2_config_defaults_event_set_deadline(handle, seconds, nanoseconds)

Sets the default deadline for event services. If `seconds` and `nanoseconds` is `NULL` the deadline will be disabled, otherwise the deadline will be set to the provided values.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)]. * `seconds` & `nanoseconds` - either both must be `NULL` or both must point to a valid memory location

### Prototype
```c
void iox2_config_defaults_event_set_deadline(iox2_config_h_ref handle, const uint64_t *seconds, const uint32_t *nanoseconds);
```
"""
function iox2_config_defaults_event_set_deadline(handle, seconds, nanoseconds)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_event_set_deadline(handle::iox2_config_h_ref, seconds::Ptr{UInt64}, nanoseconds::Ptr{UInt32})::Cvoid
end

"""
    iox2_config_defaults_event_notifier_created_event(handle, value)

Returns the event id value that is emitted when a new notifier is created. It returns `true` if a value is emitted and sets the provided `value`, otherwise it returns `false`.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)]. * `value` - points to a valid memory location

### Prototype
```c
bool iox2_config_defaults_event_notifier_created_event(iox2_config_h_ref handle, c_size_t *value);
```
"""
function iox2_config_defaults_event_notifier_created_event(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_event_notifier_created_event(handle::iox2_config_h_ref, value::Ptr{c_size_t})::Bool
end

"""
    iox2_config_defaults_event_set_notifier_created_event(handle, value)

Sets the event id value that is emitted when a new notifier is created. If `value` is `NULL` no event will be emitted, otherwise the provided value will be used.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_event_set_notifier_created_event(iox2_config_h_ref handle, const c_size_t *value);
```
"""
function iox2_config_defaults_event_set_notifier_created_event(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_event_set_notifier_created_event(handle::iox2_config_h_ref, value::Ptr{c_size_t})::Cvoid
end

"""
    iox2_config_defaults_event_notifier_dropped_event(handle, value)

Returns the event id value that is emitted when a notifier is dropped. It returns `true` if a value is emitted and sets the provided `value`, otherwise it returns `false`.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)]. * `value` - points to a valid memory location

### Prototype
```c
bool iox2_config_defaults_event_notifier_dropped_event(iox2_config_h_ref handle, c_size_t *value);
```
"""
function iox2_config_defaults_event_notifier_dropped_event(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_event_notifier_dropped_event(handle::iox2_config_h_ref, value::Ptr{c_size_t})::Bool
end

"""
    iox2_config_defaults_event_set_notifier_dropped_event(handle, value)

Sets the event id value that is emitted when a notifier is dropped. If `value` is `NULL` no event will be emitted, otherwise the provided value will be used.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_event_set_notifier_dropped_event(iox2_config_h_ref handle, const c_size_t *value);
```
"""
function iox2_config_defaults_event_set_notifier_dropped_event(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_event_set_notifier_dropped_event(handle::iox2_config_h_ref, value::Ptr{c_size_t})::Cvoid
end

"""
    iox2_config_defaults_event_notifier_dead_event(handle, value)

Returns the event id value that is emitted when a notifier is identified as dead. It returns `true` if a value is emitted and sets the provided `value`, otherwise it returns `false`.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)]. * `value` - points to a valid memory location

### Prototype
```c
bool iox2_config_defaults_event_notifier_dead_event(iox2_config_h_ref handle, c_size_t *value);
```
"""
function iox2_config_defaults_event_notifier_dead_event(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_event_notifier_dead_event(handle::iox2_config_h_ref, value::Ptr{c_size_t})::Bool
end

"""
    iox2_config_defaults_event_set_notifier_dead_event(handle, value)

Sets the event id value that is emitted when a notifier is identified as dead. If `value` is `NULL` no event will be emitted, otherwise the provided value will be used.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_event_set_notifier_dead_event(iox2_config_h_ref handle, const c_size_t *value);
```
"""
function iox2_config_defaults_event_set_notifier_dead_event(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_event_set_notifier_dead_event(handle::iox2_config_h_ref, value::Ptr{c_size_t})::Cvoid
end

"""
    iox2_config_defaults_event_max_notifiers(handle)

Returns the maximum amount of supported [[`iox2_notifier_h`](@ref)](crate::api::[`iox2_notifier_h`](@ref))

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
c_size_t iox2_config_defaults_event_max_notifiers(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_event_max_notifiers(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_event_max_notifiers(handle::iox2_config_h_ref)::c_size_t
end

"""
    iox2_config_defaults_event_set_max_notifiers(handle, value)

Sets the maximum amount of supported [[`iox2_notifier_h`](@ref)](crate::api::[`iox2_notifier_h`](@ref))

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_event_set_max_notifiers(iox2_config_h_ref handle, c_size_t value);
```
"""
function iox2_config_defaults_event_set_max_notifiers(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_event_set_max_notifiers(handle::iox2_config_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_config_defaults_event_max_nodes(handle)

Returns the maximum amount of supported [[`iox2_node_h`](@ref)](crate::api::[`iox2_node_h`](@ref))s. Defines indirectly how many processes can open the service at the same time.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
c_size_t iox2_config_defaults_event_max_nodes(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_event_max_nodes(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_event_max_nodes(handle::iox2_config_h_ref)::c_size_t
end

"""
    iox2_config_defaults_event_set_max_nodes(handle, value)

Sets the maximum amount of supported [[`iox2_node_h`](@ref)](crate::api::[`iox2_node_h`](@ref))s.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_event_set_max_nodes(iox2_config_h_ref handle, c_size_t value);
```
"""
function iox2_config_defaults_event_set_max_nodes(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_event_set_max_nodes(handle::iox2_config_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_config_defaults_event_event_id_max_value(handle)

Returns the largest event id supported by the event service

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
c_size_t iox2_config_defaults_event_event_id_max_value(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_event_event_id_max_value(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_event_event_id_max_value(handle::iox2_config_h_ref)::c_size_t
end

"""
    iox2_config_defaults_event_set_event_id_max_value(handle, value)

Sets the largest event id supported by the event service

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_event_set_event_id_max_value(iox2_config_h_ref handle, c_size_t value);
```
"""
function iox2_config_defaults_event_set_event_id_max_value(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_event_set_event_id_max_value(handle::iox2_config_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_config_defaults_blackboard_max_readers(handle)

Returns the maximum amount of supported [[`iox2_reader_h`](@ref)](crate::api::[`iox2_reader_h`](@ref))s

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
c_size_t iox2_config_defaults_blackboard_max_readers(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_blackboard_max_readers(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_blackboard_max_readers(handle::iox2_config_h_ref)::c_size_t
end

"""
    iox2_config_defaults_blackboard_set_max_readers(handle, value)

Sets the maximum amount of supported [[`iox2_reader_h`](@ref)](crate::api::[`iox2_reader_h`](@ref))s

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_blackboard_set_max_readers(iox2_config_h_ref handle, c_size_t value);
```
"""
function iox2_config_defaults_blackboard_set_max_readers(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_blackboard_set_max_readers(handle::iox2_config_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_config_defaults_blackboard_max_nodes(handle)

Returns the maximum amount of supported [[`iox2_node_h`](@ref)](crate::api::[`iox2_node_h`](@ref))s. Defines indirectly how many processes can open the service at the same time.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
c_size_t iox2_config_defaults_blackboard_max_nodes(iox2_config_h_ref handle);
```
"""
function iox2_config_defaults_blackboard_max_nodes(handle)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_blackboard_max_nodes(handle::iox2_config_h_ref)::c_size_t
end

"""
    iox2_config_defaults_blackboard_set_max_nodes(handle, value)

Sets the maximum amount of supported [[`iox2_node_h`](@ref)](crate::api::[`iox2_node_h`](@ref))s.

# Safety

* `handle` - A valid non-owning [[`iox2_config_h_ref`](@ref)].

### Prototype
```c
void iox2_config_defaults_blackboard_set_max_nodes(iox2_config_h_ref handle, c_size_t value);
```
"""
function iox2_config_defaults_blackboard_set_max_nodes(handle, value)
    @ccall libiceoryx2_ffi_c.iox2_config_defaults_blackboard_set_max_nodes(handle::iox2_config_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_entry_handle_get(entry_handle_handle, value_ptr, value_size, value_alignment, generation_counter_ptr)

Copies the value to `value_ptr`. If a `generation_counter_ptr` is passed, a copy of the value's generation counter is stored in it which can be used to check for value updates.

# Safety

* `entry_handle_handle` obtained by [`[`iox2_reader_entry`](@ref)()`](crate::[`iox2_reader_entry`](@ref)()) * `value_ptr` a valid, non-null [`*mut c\\_void`] pointer * `value_size` the size of the value type * `value_alignment` the alignment of the value type

### Prototype
```c
void iox2_entry_handle_get(iox2_entry_handle_h_ref entry_handle_handle, void *value_ptr, c_size_t value_size, c_size_t value_alignment, void *generation_counter_ptr);
```
"""
function iox2_entry_handle_get(entry_handle_handle, value_ptr, value_size, value_alignment, generation_counter_ptr)
    @ccall libiceoryx2_ffi_c.iox2_entry_handle_get(entry_handle_handle::iox2_entry_handle_h_ref, value_ptr::Ptr{Cvoid}, value_size::c_size_t, value_alignment::c_size_t, generation_counter_ptr::Ptr{Cvoid})::Cvoid
end

"""
    iox2_entry_handle_is_up_to_date(entry_handle_handle, generation_counter)

Checks if the blackboard value that corresponds to the `generation_counter` is up-to-date.

# Safety

* `entry_handle_handle` obtained by [`[`iox2_reader_entry`](@ref)()`](crate::[`iox2_reader_entry`](@ref)())

### Prototype
```c
bool iox2_entry_handle_is_up_to_date(iox2_entry_handle_h_ref entry_handle_handle, uint64_t generation_counter);
```
"""
function iox2_entry_handle_is_up_to_date(entry_handle_handle, generation_counter)
    @ccall libiceoryx2_ffi_c.iox2_entry_handle_is_up_to_date(entry_handle_handle::iox2_entry_handle_h_ref, generation_counter::UInt64)::Bool
end

"""
    iox2_entry_handle_entry_id(entry_handle_handle, entry_id)

Returns an id corresponding to the entry which can be used in an event based communication setup.

# Safety

* `entry_handle_handle` obtained by [`[`iox2_reader_entry`](@ref)()`](crate::[`iox2_reader_entry`](@ref)()) * `entry_id` a valid, non-null pointer pointing to a [[`iox2_event_id_t`](@ref)]

### Prototype
```c
void iox2_entry_handle_entry_id(iox2_entry_handle_h_ref entry_handle_handle, struct iox2_event_id_t *entry_id);
```
"""
function iox2_entry_handle_entry_id(entry_handle_handle, entry_id)
    @ccall libiceoryx2_ffi_c.iox2_entry_handle_entry_id(entry_handle_handle::iox2_entry_handle_h_ref, entry_id::Ptr{iox2_event_id_t})::Cvoid
end

"""
    iox2_entry_handle_drop(entry_handle_handle)

This function needs to be called to destroy the entry handle!

# Arguments

* `entry_handle_handle` - A valid [[`iox2_entry_handle_h`](@ref)]

# Safety

* The `entry_handle_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_entry_handle_t`](@ref)] can be re-used with a call to [[`iox2_reader_entry`](@ref)](crate::[`iox2_reader_entry`](@ref))!

### Prototype
```c
void iox2_entry_handle_drop(iox2_entry_handle_h entry_handle_handle);
```
"""
function iox2_entry_handle_drop(entry_handle_handle)
    @ccall libiceoryx2_ffi_c.iox2_entry_handle_drop(entry_handle_handle::iox2_entry_handle_h)::Cvoid
end

"""
    iox2_entry_handle_mut_loan_uninit(entry_handle_mut_handle, entry_value_uninit_struct_ptr, entry_value_uninit_handle_ptr, value_size, value_alignment)

Consumes the `iox2_entry_handle_mut` and loans an uninitialized entry value that can be used to update without copy.

# Safety

* `entry_handle_mut_handle` obtained by [`[`iox2_writer_entry`](@ref)()`](crate::[`iox2_writer_entry`](@ref)()), is invalid after the return of this function * `entry_value_uninit_struct_ptr` must be either a NULL pointer or a pointer to a valid [[`iox2_entry_value_uninit_t`](@ref)] * `entry_value_uninit_handle_ptr` a valid, non-null [`*mut [`iox2_entry_value_uninit_h`](@ref)`] pointer which will be initialized by this function call * `value_size` the size of the value type that shall be stored in the entry value * `value_alignment` the alignment of the value type that shall be stored in the entry value

### Prototype
```c
void iox2_entry_handle_mut_loan_uninit(iox2_entry_handle_mut_h entry_handle_mut_handle, struct iox2_entry_value_uninit_t *entry_value_uninit_struct_ptr, iox2_entry_value_uninit_h *entry_value_uninit_handle_ptr, size_t value_size, size_t value_alignment);
```
"""
function iox2_entry_handle_mut_loan_uninit(entry_handle_mut_handle, entry_value_uninit_struct_ptr, entry_value_uninit_handle_ptr, value_size, value_alignment)
    @ccall libiceoryx2_ffi_c.iox2_entry_handle_mut_loan_uninit(entry_handle_mut_handle::iox2_entry_handle_mut_h, entry_value_uninit_struct_ptr::Ptr{iox2_entry_value_uninit_t}, entry_value_uninit_handle_ptr::Ptr{iox2_entry_value_uninit_h}, value_size::Csize_t, value_alignment::Csize_t)::Cvoid
end

"""
    iox2_entry_handle_mut_update_with_copy(entry_handle_mut_handle, value_ptr, value_size, value_alignment)

Updates the entry value by copying the value pointed to by `value_ptr`

# Safety

* `entry_handle_mut_handle` obtained by [`[`iox2_writer_entry`](@ref)()`](crate::[`iox2_writer_entry`](@ref)()) * `value_ptr` a valid, non-null [`*mut c\\_void`] pointer which points to the value to be stored * `value_size` the size of the value type that shall be stored in the entry value * `value_alignment` the alignment of the value type that shall be stored in the entry value

### Prototype
```c
void iox2_entry_handle_mut_update_with_copy(iox2_entry_handle_mut_h_ref entry_handle_mut_handle, void *value_ptr, size_t value_size, size_t value_alignment);
```
"""
function iox2_entry_handle_mut_update_with_copy(entry_handle_mut_handle, value_ptr, value_size, value_alignment)
    @ccall libiceoryx2_ffi_c.iox2_entry_handle_mut_update_with_copy(entry_handle_mut_handle::iox2_entry_handle_mut_h_ref, value_ptr::Ptr{Cvoid}, value_size::Csize_t, value_alignment::Csize_t)::Cvoid
end

"""
    iox2_entry_handle_mut_entry_id(entry_handle_mut_handle, entry_id)

Returns an id corresponding to the entry which can be used in an event based communication setup.

# Safety

* `entry_handle_mut_handle` obtained by [`[`iox2_writer_entry`](@ref)()`](crate::[`iox2_writer_entry`](@ref)()) * `entry_id` a valid, non-null pointer pointing to a [[`iox2_event_id_t`](@ref)]

### Prototype
```c
void iox2_entry_handle_mut_entry_id(iox2_entry_handle_mut_h_ref entry_handle_mut_handle, struct iox2_event_id_t *entry_id);
```
"""
function iox2_entry_handle_mut_entry_id(entry_handle_mut_handle, entry_id)
    @ccall libiceoryx2_ffi_c.iox2_entry_handle_mut_entry_id(entry_handle_mut_handle::iox2_entry_handle_mut_h_ref, entry_id::Ptr{iox2_event_id_t})::Cvoid
end

"""
    iox2_entry_handle_mut_drop(entry_handle_mut_handle)

This function needs to be called to destroy the entry handle mut!

# Arguments

* `entry_handle_mut_handle` - A valid [[`iox2_entry_handle_mut_h`](@ref)]

# Safety

* The `entry_handle_mut_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_entry_handle_mut_t`](@ref)] can be re-used with a call to [[`iox2_writer_entry`](@ref)](crate::[`iox2_writer_entry`](@ref))!

### Prototype
```c
void iox2_entry_handle_mut_drop(iox2_entry_handle_mut_h entry_handle_mut_handle);
```
"""
function iox2_entry_handle_mut_drop(entry_handle_mut_handle)
    @ccall libiceoryx2_ffi_c.iox2_entry_handle_mut_drop(entry_handle_mut_handle::iox2_entry_handle_mut_h)::Cvoid
end

"""
    iox2_entry_value_uninit_value_mut(entry_value_uninit_handle, value_ptr)

Acquires the entrie's mutable value. After writing the value, [`[`iox2_entry_value_uninit_update`](@ref)()`] must be called.

# Safety

* `entry_value_uninit_handle` obtained by [`[`iox2_entry_handle_mut_loan_uninit`](@ref)()`](crate::[`iox2_entry_handle_mut_loan_uninit`](@ref)()) * `value_ptr` a valid, non-null pointer pointing to a [`*mut c\\_void`] pointer.

### Prototype
```c
void iox2_entry_value_uninit_value_mut(iox2_entry_value_uninit_h_ref entry_value_uninit_handle, void **value_ptr);
```
"""
function iox2_entry_value_uninit_value_mut(entry_value_uninit_handle, value_ptr)
    @ccall libiceoryx2_ffi_c.iox2_entry_value_uninit_value_mut(entry_value_uninit_handle::iox2_entry_value_uninit_h_ref, value_ptr::Ptr{Ptr{Cvoid}})::Cvoid
end

"""
    iox2_entry_value_uninit_update(entry_value_uninit_handle, entry_handle_mut_struct_ptr, entry_handle_mut_handle_ptr)

Consumes the entry value, makes the new value readable for [[`iox2_reader_t`](@ref)](crate::[`iox2_reader_t`](@ref)) and returns the original entry handle mut.

# Safety

* `entry_value_uninit_handle` obtained by [`[`iox2_entry_handle_mut_loan_uninit`](@ref)()`](crate::[`iox2_entry_handle_mut_loan_uninit`](@ref)()), it's invalid after the return of this function * `entry_handle_mut_struct_ptr` must be either a NULL pointer or a pointer to a valid [[`iox2_entry_handle_mut_t`](@ref)](crate::[`iox2_entry_handle_mut_t`](@ref)) * `entry_handle_mut_handle_ptr` a valid, non-null [`*mut [`iox2_entry_handle_mut_h`](@ref)`] pointer which will be initialized by this function call

### Prototype
```c
void iox2_entry_value_uninit_update(iox2_entry_value_uninit_h entry_value_uninit_handle, struct iox2_entry_handle_mut_t *entry_handle_mut_struct_ptr, iox2_entry_handle_mut_h *entry_handle_mut_handle_ptr);
```
"""
function iox2_entry_value_uninit_update(entry_value_uninit_handle, entry_handle_mut_struct_ptr, entry_handle_mut_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_entry_value_uninit_update(entry_value_uninit_handle::iox2_entry_value_uninit_h, entry_handle_mut_struct_ptr::Ptr{iox2_entry_handle_mut_t}, entry_handle_mut_handle_ptr::Ptr{iox2_entry_handle_mut_h})::Cvoid
end

"""
    iox2_entry_value_uninit_discard(entry_value_uninit_handle, entry_handle_mut_struct_ptr, entry_handle_mut_handle_ptr)

Consumes and discards the entry value and returns the original entry handle mut.

# Safety

* `entry_value_uninit_handle` obtained by [`[`iox2_entry_handle_mut_loan_uninit`](@ref)()`](crate::[`iox2_entry_handle_mut_loan_uninit`](@ref)()), it's invalid after the return of this function * `entry_handle_mut_struct_ptr` must be either a NULL pointer or a pointer to a valid [[`iox2_entry_handle_mut_t`](@ref)] * `entry_handle_mut_handle_ptr` a valid, non-null [`*mut [`iox2_entry_handle_mut_h`](@ref)`] pointer which will be initialized by this function call

### Prototype
```c
void iox2_entry_value_uninit_discard(iox2_entry_value_uninit_h entry_value_uninit_handle, struct iox2_entry_handle_mut_t *entry_handle_mut_struct_ptr, iox2_entry_handle_mut_h *entry_handle_mut_handle_ptr);
```
"""
function iox2_entry_value_uninit_discard(entry_value_uninit_handle, entry_handle_mut_struct_ptr, entry_handle_mut_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_entry_value_uninit_discard(entry_value_uninit_handle::iox2_entry_value_uninit_h, entry_handle_mut_struct_ptr::Ptr{iox2_entry_handle_mut_t}, entry_handle_mut_handle_ptr::Ptr{iox2_entry_handle_mut_h})::Cvoid
end

"""
    iox2_entry_value_uninit_drop(entry_value_uninit_handle)

This function needs to be called to destroy the entry value!

# Arguments

* `entry_value_uninit_handle` - A valid [[`iox2_entry_value_uninit_h`](@ref)]

# Safety

* The `entry_value_uninit_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_entry_value_uninit_t`](@ref)] can be re-used with a call to [`[`iox2_entry_handle_mut_loan_uninit`](@ref)()`](crate::[`iox2_entry_handle_mut_loan_uninit`](@ref)())!

### Prototype
```c
void iox2_entry_value_uninit_drop(iox2_entry_value_uninit_h entry_value_uninit_handle);
```
"""
function iox2_entry_value_uninit_drop(entry_value_uninit_handle)
    @ccall libiceoryx2_ffi_c.iox2_entry_value_uninit_drop(entry_value_uninit_handle::iox2_entry_value_uninit_h)::Cvoid
end

"""
    iox2_cast_file_descriptor_ptr(handle)

Casts a [[`iox2_file_descriptor_h`](@ref)] into an [[`iox2_file_descriptor_ptr`](@ref)]. The result is valid as long as the source is valid.

# Safety

* `handle` must be valid and acquired with [`[`iox2_file_descriptor_new`](@ref)()`].

### Prototype
```c
iox2_file_descriptor_ptr iox2_cast_file_descriptor_ptr(iox2_file_descriptor_h handle);
```
"""
function iox2_cast_file_descriptor_ptr(handle)
    @ccall libiceoryx2_ffi_c.iox2_cast_file_descriptor_ptr(handle::iox2_file_descriptor_h)::iox2_file_descriptor_ptr
end

"""
    iox2_file_descriptor_drop(handle)

Releases a [[`iox2_file_descriptor_h`](@ref)].

# Safety

* `handle` must be valid and acquired with [`[`iox2_file_descriptor_new`](@ref)()`].

### Prototype
```c
void iox2_file_descriptor_drop(iox2_file_descriptor_h handle);
```
"""
function iox2_file_descriptor_drop(handle)
    @ccall libiceoryx2_ffi_c.iox2_file_descriptor_drop(handle::iox2_file_descriptor_h)::Cvoid
end

"""
    iox2_file_descriptor_native_handle(handle)

Returns the underlying native file descriptor value. When the [`iox2_file_descriptor_h_ref`] is owning the file descriptor, the native value is valid until [`[`iox2_file_descriptor_drop`](@ref)()`] is called.

# Safety

* `handle` must be valid and acquired with [`[`iox2_file_descriptor_new`](@ref)()`].

### Prototype
```c
int32_t iox2_file_descriptor_native_handle(iox2_file_descriptor_ptr handle);
```
"""
function iox2_file_descriptor_native_handle(handle)
    @ccall libiceoryx2_ffi_c.iox2_file_descriptor_native_handle(handle::iox2_file_descriptor_ptr)::Int32
end

"""
    iox2_file_descriptor_new(value, is_owned, struct_ptr, handle_ptr)

Creates a new [[`iox2_file_descriptor_t`](@ref)].

# Return

Returns true, when the [[`iox2_file_descriptor_h`](@ref)] was initialized successfully. If the user provided an invalid file descriptor it returns false.

# Safety

* `struct_ptr` must be either null or pointing to a valid uninitialized memory location * `handle_ptr` must be non-null and pointing to valid uninitialized memory * `handle_ptr` must be cleaned up with [`[`iox2_file_descriptor_drop`](@ref)()`]

### Prototype
```c
bool iox2_file_descriptor_new(int32_t value, bool is_owned, struct iox2_file_descriptor_t *struct_ptr, iox2_file_descriptor_h *handle_ptr);
```
"""
function iox2_file_descriptor_new(value, is_owned, struct_ptr, handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_file_descriptor_new(value::Int32, is_owned::Bool, struct_ptr::Ptr{iox2_file_descriptor_t}, handle_ptr::Ptr{iox2_file_descriptor_h})::Bool
end

"""
    iox2_listener_wait_error_string(error)

Returns a string representation of the provided [[`iox2_listener_wait_error_e`](@ref)] error code.

# Arguments

* `error` - The error code that should be converted into a string

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

* The returned pointer must not be modified or freed and is only valid as long as the program runs

### Prototype
```c
const char *iox2_listener_wait_error_string(enum iox2_listener_wait_error_e error);
```
"""
function iox2_listener_wait_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_listener_wait_error_string(error::iox2_listener_wait_error_e)::Cstring
end

"""
    iox2_listener_drop(listener_handle)

This function needs to be called to destroy the listener!

# Arguments

* `listener_handle` - A valid [[`iox2_listener_h`](@ref)]

# Safety

* The `listener_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_listener_t`](@ref)] can be re-used with a call to [[`iox2_port_factory_listener_builder_create`](@ref)](crate::[`iox2_port_factory_listener_builder_create`](@ref))!

### Prototype
```c
void iox2_listener_drop(iox2_listener_h listener_handle);
```
"""
function iox2_listener_drop(listener_handle)
    @ccall libiceoryx2_ffi_c.iox2_listener_drop(listener_handle::iox2_listener_h)::Cvoid
end

"""
    iox2_listener_get_file_descriptor(listener_handle)

Returns the underlying non-owning file descriptor of the [[`iox2_listener_h`](@ref)] if the [[`iox2_listener_h`](@ref)] is file descriptor based, otherwise it returns NULL.

# Arguments

* `listener_handle` - A valid [[`iox2_listener_h_ref`](@ref)],

# Safety

* The `listener_handle` must be a valid handle.

### Prototype
```c
iox2_file_descriptor_ptr iox2_listener_get_file_descriptor(iox2_listener_h_ref listener_handle);
```
"""
function iox2_listener_get_file_descriptor(listener_handle)
    @ccall libiceoryx2_ffi_c.iox2_listener_get_file_descriptor(listener_handle::iox2_listener_h_ref)::iox2_file_descriptor_ptr
end

"""
    iox2_listener_try_wait_all(listener_handle, callback, callback_ctx)

Tries to wait on the listener and calls the callback for every received event providing the corresponding [[`iox2_event_id_t`](@ref)] pointer to the event. On error it returns [[`iox2_listener_wait_error_e`](@ref)].

# Arguments

* `listener_handle` - A valid [[`iox2_listener_h_ref`](@ref)], * `callback` - A valid callback with [[`iox2_listener_wait_all_callback`](@ref)} signature * `callback_ctx` - An optional callback context [[`iox2_callback_context`](@ref)} to e.g. store information across callback iterations

# Safety

* The `listener_handle` must be a valid handle. * The `callback` must be a valid function pointer.

### Prototype
```c
int iox2_listener_try_wait_all(iox2_listener_h_ref listener_handle, iox2_listener_wait_all_callback callback, iox2_callback_context callback_ctx);
```
"""
function iox2_listener_try_wait_all(listener_handle, callback, callback_ctx)
    @ccall libiceoryx2_ffi_c.iox2_listener_try_wait_all(listener_handle::iox2_listener_h_ref, callback::iox2_listener_wait_all_callback, callback_ctx::iox2_callback_context)::Cint
end

"""
    iox2_listener_timed_wait_all(listener_handle, callback, callback_ctx, seconds, nanoseconds)

Blocks the listener until at least one event was received or the provided timeout has passed. When an event was received then it calls the callback for every received event providing the corresponding [[`iox2_event_id_t`](@ref)] pointer to the event. On error it returns [[`iox2_listener_wait_error_e`](@ref)].

# Arguments

* `listener_handle` - A valid [[`iox2_listener_h_ref`](@ref)], * `callback` - A valid callback with [[`iox2_listener_wait_all_callback`](@ref)} signature * `callback_ctx` - An optional callback context [[`iox2_callback_context`](@ref)} to e.g. store information across callback iterations

# Safety

* The `listener_handle` must be a valid handle. * The `callback` must be a valid function pointer.

### Prototype
```c
int iox2_listener_timed_wait_all(iox2_listener_h_ref listener_handle, iox2_listener_wait_all_callback callback, iox2_callback_context callback_ctx, uint64_t seconds, uint32_t nanoseconds);
```
"""
function iox2_listener_timed_wait_all(listener_handle, callback, callback_ctx, seconds, nanoseconds)
    @ccall libiceoryx2_ffi_c.iox2_listener_timed_wait_all(listener_handle::iox2_listener_h_ref, callback::iox2_listener_wait_all_callback, callback_ctx::iox2_callback_context, seconds::UInt64, nanoseconds::UInt32)::Cint
end

"""
    iox2_listener_id(listener_handle, id_struct_ptr, id_handle_ptr)

Returns the unique port id of the listener.

# Arguments

* `handle` obtained by [[`iox2_port_factory_listener_builder_create`](@ref)](crate::[`iox2_port_factory_listener_builder_create`](@ref)) * `id_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_unique_listener_id_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `id_handle_ptr` valid pointer to a [[`iox2_unique_listener_id_h`](@ref)].

# Safety

* `listener_handle` is valid, non-null and was obtained via [[`iox2_port_factory_listener_builder_create`](@ref)](crate::[`iox2_port_factory_listener_builder_create`](@ref)) * `id` is valid and non-null

### Prototype
```c
void iox2_listener_id(iox2_listener_h_ref listener_handle, struct iox2_unique_listener_id_t *id_struct_ptr, iox2_unique_listener_id_h *id_handle_ptr);
```
"""
function iox2_listener_id(listener_handle, id_struct_ptr, id_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_listener_id(listener_handle::iox2_listener_h_ref, id_struct_ptr::Ptr{iox2_unique_listener_id_t}, id_handle_ptr::Ptr{iox2_unique_listener_id_h})::Cvoid
end

"""
    iox2_listener_deadline(listener_handle, seconds, nanoseconds)

Returns the deadline of the listener's service. If there is a deadline set, the provided arguments `seconds` and `nanoseconds` will be set `true` is returned. Otherwise, false is returned and nothing is set.

# Safety

* `listener_handle` is valid, non-null and was obtained via [[`iox2_port_factory_listener_builder_create`](@ref)](crate::[`iox2_port_factory_listener_builder_create`](@ref)) * `seconds` is pointing to a valid memory location and non-null * `nanoseconds` is pointing to a valid memory location and non-null

### Prototype
```c
bool iox2_listener_deadline(iox2_listener_h_ref listener_handle, uint64_t *seconds, uint32_t *nanoseconds);
```
"""
function iox2_listener_deadline(listener_handle, seconds, nanoseconds)
    @ccall libiceoryx2_ffi_c.iox2_listener_deadline(listener_handle::iox2_listener_h_ref, seconds::Ptr{UInt64}, nanoseconds::Ptr{UInt32})::Bool
end

"""
    iox2_listener_blocking_wait_all(listener_handle, callback, callback_ctx)

Blocks the listener until at least one event was received and then calls the callback for every received event providing the corresponding [[`iox2_event_id_t`](@ref)] pointer to the event. On error it returns [[`iox2_listener_wait_error_e`](@ref)].

# Arguments

* `listener_handle` - A valid [[`iox2_listener_h_ref`](@ref)], * `callback` - A valid callback with [[`iox2_listener_wait_all_callback`](@ref)} signature * `callback_ctx` - An optional callback context [[`iox2_callback_context`](@ref)} to e.g. store information across callback iterations

# Safety

* The `listener_handle` must be a valid handle. * The `callback` must be a valid function pointer.

### Prototype
```c
int iox2_listener_blocking_wait_all(iox2_listener_h_ref listener_handle, iox2_listener_wait_all_callback callback, iox2_callback_context callback_ctx);
```
"""
function iox2_listener_blocking_wait_all(listener_handle, callback, callback_ctx)
    @ccall libiceoryx2_ffi_c.iox2_listener_blocking_wait_all(listener_handle::iox2_listener_h_ref, callback::iox2_listener_wait_all_callback, callback_ctx::iox2_callback_context)::Cint
end

"""
    iox2_listener_try_wait_one(listener_handle, event_id, has_received_one)

Tries to wait on the listener. If there is no event id present it returns immediately and sets the out parameter `has_received_one` to false. Otherwise, it sets the `event_id` out parameter and `has_received_one` to true. On error it returns [[`iox2_listener_wait_error_e`](@ref)].

# Arguments

* `listener_handle` - A valid [[`iox2_listener_h_ref`](@ref)], * `event_id` - A pointer to an [[`iox2_event_id_t`](@ref)] to store the received id. * `has_received_one` - A pointer to a [`bool`] that signals if an event id was received or not

# Safety

* All input arguments must be non-null.

### Prototype
```c
int iox2_listener_try_wait_one(iox2_listener_h_ref listener_handle, struct iox2_event_id_t *event_id, bool *has_received_one);
```
"""
function iox2_listener_try_wait_one(listener_handle, event_id, has_received_one)
    @ccall libiceoryx2_ffi_c.iox2_listener_try_wait_one(listener_handle::iox2_listener_h_ref, event_id::Ptr{iox2_event_id_t}, has_received_one::Ptr{Bool})::Cint
end

"""
    iox2_listener_timed_wait_one(listener_handle, event_id, has_received_one, seconds, nanoseconds)

Blocks on the listener until an event id was received or the provided timeout has passed. When no event id was received and the function was interrupted by a signal, `has_received_one` is set to false. Otherwise, it sets the `event_id` out parameter and `has_received_one` to true. On error it returns [[`iox2_listener_wait_error_e`](@ref)].

# Arguments

* `listener_handle` - A valid [[`iox2_listener_h_ref`](@ref)], * `event_id` - A pointer to an [[`iox2_event_id_t`](@ref)] to store the received id. * `has_received_one` - A pointer to a [`bool`] that signals if an event id was received or not * `seconds` - The timeout seconds part * `nanoseconds` - The timeout nanoseconds part

# Safety

* All input arguments must be non-null.

### Prototype
```c
int iox2_listener_timed_wait_one(iox2_listener_h_ref listener_handle, struct iox2_event_id_t *event_id, bool *has_received_one, uint64_t seconds, uint32_t nanoseconds);
```
"""
function iox2_listener_timed_wait_one(listener_handle, event_id, has_received_one, seconds, nanoseconds)
    @ccall libiceoryx2_ffi_c.iox2_listener_timed_wait_one(listener_handle::iox2_listener_h_ref, event_id::Ptr{iox2_event_id_t}, has_received_one::Ptr{Bool}, seconds::UInt64, nanoseconds::UInt32)::Cint
end

"""
    iox2_listener_blocking_wait_one(listener_handle, event_id, has_received_one)

Blocks on the listener until an event id was received. When no event id was received and the function was interrupted by a signal, `has_received_one` is set to false. Otherwise, it sets the `event_id` out parameter and `has_received_one` to true. On error it returns [[`iox2_listener_wait_error_e`](@ref)].

# Arguments

* `listener_handle` - A valid [[`iox2_listener_h_ref`](@ref)], * `event_id` - A pointer to an [[`iox2_event_id_t`](@ref)] to store the received id. * `has_received_one` - A pointer to a [`bool`] that signals if an event id was received or not

# Safety

* All input arguments must be non-null.

### Prototype
```c
int iox2_listener_blocking_wait_one(iox2_listener_h_ref listener_handle, struct iox2_event_id_t *event_id, bool *has_received_one);
```
"""
function iox2_listener_blocking_wait_one(listener_handle, event_id, has_received_one)
    @ccall libiceoryx2_ffi_c.iox2_listener_blocking_wait_one(listener_handle::iox2_listener_h_ref, event_id::Ptr{iox2_event_id_t}, has_received_one::Ptr{Bool})::Cint
end

"""
    iox2_listener_details_listener_id(handle, id_struct_ptr, id_handle_ptr)

Returns the unique port id of the listener.

# Safety

* `handle` valid pointer to the listener details * `id_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_unique_listener_id_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `id_handle_ptr` valid pointer to a [[`iox2_unique_listener_id_h`](@ref)].

### Prototype
```c
void iox2_listener_details_listener_id(iox2_listener_details_ptr handle, struct iox2_unique_listener_id_t *id_struct_ptr, iox2_unique_listener_id_h *id_handle_ptr);
```
"""
function iox2_listener_details_listener_id(handle, id_struct_ptr, id_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_listener_details_listener_id(handle::iox2_listener_details_ptr, id_struct_ptr::Ptr{iox2_unique_listener_id_t}, id_handle_ptr::Ptr{iox2_unique_listener_id_h})::Cvoid
end

"""
    iox2_listener_details_node_id(handle)

Returns the [[`iox2_node_id_ptr`](@ref)](crate::[`iox2_node_id_ptr`](@ref)), an immutable pointer to the node id.

# Safety

* `handle` valid pointer to the listener details

### Prototype
```c
iox2_node_id_ptr iox2_listener_details_node_id(iox2_listener_details_ptr handle);
```
"""
function iox2_listener_details_node_id(handle)
    @ccall libiceoryx2_ffi_c.iox2_listener_details_node_id(handle::iox2_listener_details_ptr)::iox2_node_id_ptr
end

"""
    iox2_log(log_level, origin, message)

Adds a log message to the logger.

# Safety

* origin must be either NULL or a valid pointer to a string. * message must be a valid pointer to a string

### Prototype
```c
void iox2_log(enum iox2_log_level_e log_level, const char *origin, const char *message);
```
"""
function iox2_log(log_level, origin, message)
    @ccall libiceoryx2_ffi_c.iox2_log(log_level::iox2_log_level_e, origin::Cstring, message::Cstring)::Cvoid
end

"""
    iox2_set_log_level_from_env_or_default()

Sets the log level from environment variable or defaults it if variable does not exist

### Prototype
```c
void iox2_set_log_level_from_env_or_default(void);
```
"""
function iox2_set_log_level_from_env_or_default()
    @ccall libiceoryx2_ffi_c.iox2_set_log_level_from_env_or_default()::Cvoid
end

"""
    iox2_set_log_level_from_env_or(v)

Sets the log level from environment variable or to a user given value if variable does not exist

### Prototype
```c
void iox2_set_log_level_from_env_or(enum iox2_log_level_e v);
```
"""
function iox2_set_log_level_from_env_or(v)
    @ccall libiceoryx2_ffi_c.iox2_set_log_level_from_env_or(v::iox2_log_level_e)::Cvoid
end

"""
    iox2_set_log_level(v)

Sets the log level.

### Prototype
```c
void iox2_set_log_level(enum iox2_log_level_e v);
```
"""
function iox2_set_log_level(v)
    @ccall libiceoryx2_ffi_c.iox2_set_log_level(v::iox2_log_level_e)::Cvoid
end

"""
    iox2_get_log_level()

Returns the current log level.

### Prototype
```c
enum iox2_log_level_e iox2_get_log_level(void);
```
"""
function iox2_get_log_level()
    @ccall libiceoryx2_ffi_c.iox2_get_log_level()::iox2_log_level_e
end

"""
    iox2_set_logger(logger)

Sets the logger that shall be used. This function can only be called once and must be called before any log message was created. It returns true if the logger was set, otherwise false.

### Prototype
```c
bool iox2_set_logger(iox2_log_callback logger);
```
"""
function iox2_set_logger(logger)
    @ccall libiceoryx2_ffi_c.iox2_set_logger(logger::iox2_log_callback)::Bool
end

"""
    iox2_node_list_failure_string(error)

Returns a string representation of the [[`iox2_node_list_failure_e`](@ref)] error code.

# Arguments

* `error` - The error value for which a description should be returned

Returns a pointer to a null-terminated string containing the error description.

# Safety

* The returned pointer is valid as long as the program runs and must not be modified or freed

### Prototype
```c
const char *iox2_node_list_failure_string(enum iox2_node_list_failure_e error);
```
"""
function iox2_node_list_failure_string(error)
    @ccall libiceoryx2_ffi_c.iox2_node_list_failure_string(error::iox2_node_list_failure_e)::Cstring
end

"""
    iox2_node_wait_failure_string(error)

Returns a string representation of the [[`iox2_node_wait_failure_e`](@ref)] error code.

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

* The returned pointer is valid as long as the program runs and must not be modified or freed

### Prototype
```c
const char *iox2_node_wait_failure_string(enum iox2_node_wait_failure_e error);
```
"""
function iox2_node_wait_failure_string(error)
    @ccall libiceoryx2_ffi_c.iox2_node_wait_failure_string(error::iox2_node_wait_failure_e)::Cstring
end

"""
    iox2_node_name(node_handle)

Returns the [[`iox2_node_name_ptr`](@ref)](crate::[`iox2_node_name_ptr`](@ref)), an immutable pointer to the node name.

# Safety

* The `node_handle` must be valid and obtained by [[`iox2_node_builder_create`](@ref)](crate::[`iox2_node_builder_create`](@ref))!

### Prototype
```c
iox2_node_name_ptr iox2_node_name(iox2_node_h_ref node_handle);
```
"""
function iox2_node_name(node_handle)
    @ccall libiceoryx2_ffi_c.iox2_node_name(node_handle::iox2_node_h_ref)::iox2_node_name_ptr
end

"""
    iox2_node_wait(node_handle, cycle_time_sec, cycle_time_nsec)

Wait until the provided cycle time has passed and returns a [[`iox2_node_wait_failure_e`](@ref)] enum containing the event that has occurred.

# Safety

* The `node_handle` must be valid and obtained by [[`iox2_node_builder_create`](@ref)](crate::[`iox2_node_builder_create`](@ref))!

### Prototype
```c
int iox2_node_wait(iox2_node_h_ref node_handle, uint64_t cycle_time_sec, uint32_t cycle_time_nsec);
```
"""
function iox2_node_wait(node_handle, cycle_time_sec, cycle_time_nsec)
    @ccall libiceoryx2_ffi_c.iox2_node_wait(node_handle::iox2_node_h_ref, cycle_time_sec::UInt64, cycle_time_nsec::UInt32)::Cint
end

"""
    iox2_node_config(node_handle)

Returns the [[`iox2_config_ptr`](@ref)](crate::[`iox2_config_ptr`](@ref)), an immutable pointer to the config.

# Safety

* The `node_handle` must be valid and obtained by [[`iox2_node_builder_create`](@ref)](crate::[`iox2_node_builder_create`](@ref))!

### Prototype
```c
iox2_config_ptr iox2_node_config(iox2_node_h_ref node_handle);
```
"""
function iox2_node_config(node_handle)
    @ccall libiceoryx2_ffi_c.iox2_node_config(node_handle::iox2_node_h_ref)::iox2_config_ptr
end

"""
    iox2_node_signal_handling_mode(node_handle)

Returns the [[`iox2_signal_handling_mode_e`](@ref)] with which the node was created.

# Safety

* The `node_handle` must be valid and obtained by [[`iox2_node_builder_create`](@ref)](crate::[`iox2_node_builder_create`](@ref))!

### Prototype
```c
enum iox2_signal_handling_mode_e iox2_node_signal_handling_mode(iox2_node_h_ref node_handle);
```
"""
function iox2_node_signal_handling_mode(node_handle)
    @ccall libiceoryx2_ffi_c.iox2_node_signal_handling_mode(node_handle::iox2_node_h_ref)::iox2_signal_handling_mode_e
end

"""
    iox2_node_id(node_handle, service_type)

Returns the [[`iox2_node_id_ptr`](@ref)](crate::[`iox2_node_id_ptr`](@ref)), an immutable pointer to the node id.

# Safety

* The `node_handle` must be valid and obtained by [[`iox2_node_builder_create`](@ref)](crate::[`iox2_node_builder_create`](@ref))!

### Prototype
```c
iox2_node_id_ptr iox2_node_id(iox2_node_h_ref node_handle, enum iox2_service_type_e service_type);
```
"""
function iox2_node_id(node_handle, service_type)
    @ccall libiceoryx2_ffi_c.iox2_node_id(node_handle::iox2_node_h_ref, service_type::iox2_service_type_e)::iox2_node_id_ptr
end

"""
    iox2_dead_node_remove_stale_resources(service_type, node_id, config, has_success)

Removes all stale resources of a dead node under a provided config.

Returns [[`IOX2_OK`](@ref)] on success, otherwise [[`iox2_node_cleanup_failure_e`](@ref)].

# Safety

* The `node_handle` must be valid and obtained by [[`iox2_node_builder_create`](@ref)](crate::[`iox2_node_builder_create`](@ref))! * The `node_id` must be valid * The `config` must be valid * `has_success` must point to a valid memory location

### Prototype
```c
int iox2_dead_node_remove_stale_resources(enum iox2_service_type_e service_type, iox2_node_id_h_ref node_id, iox2_config_h_ref config, bool *has_success);
```
"""
function iox2_dead_node_remove_stale_resources(service_type, node_id, config, has_success)
    @ccall libiceoryx2_ffi_c.iox2_dead_node_remove_stale_resources(service_type::iox2_service_type_e, node_id::iox2_node_id_h_ref, config::iox2_config_h_ref, has_success::Ptr{Bool})::Cint
end

"""
    iox2_node_list(service_type, config_ptr, callback, callback_ctx)

Calls the callback repeatedly with an [[`iox2_node_state_e`](@ref)], [[`iox2_node_id_ptr`](@ref)], [´[`iox2_node_name_ptr`](@ref)´] and [[`iox2_config_ptr`](@ref)] for all [`Node`](iceoryx2::node::Node)s in the system under a given [`Config`](iceoryx2::config::Config).

# Arguments

* `service_type` - A [[`iox2_service_type_e`](@ref)] * `config_ptr` - A valid [[`iox2_config_ptr`](@ref)](crate::[`iox2_config_ptr`](@ref)) * `callback` - A valid callback with [[`iox2_node_list_callback`](@ref)} signature * `callback_ctx` - An optional callback context [[`iox2_callback_context`](@ref)} to e.g. store information across callback iterations

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_node_list_failure_e`](@ref)] otherwise.

# Safety

* The `config_ptr` must be valid and obtained by ether [[`iox2_node_config`](@ref)] or [[`iox2_config_global_config`](@ref)](crate::[`iox2_config_global_config`](@ref))!

### Prototype
```c
int iox2_node_list(enum iox2_service_type_e service_type, iox2_config_ptr config_ptr, iox2_node_list_callback callback, iox2_callback_context callback_ctx);
```
"""
function iox2_node_list(service_type, config_ptr, callback, callback_ctx)
    @ccall libiceoryx2_ffi_c.iox2_node_list(service_type::iox2_service_type_e, config_ptr::iox2_config_ptr, callback::iox2_node_list_callback, callback_ctx::iox2_callback_context)::Cint
end

"""
    iox2_node_service_builder(node_handle, service_builder_struct_ptr, service_name_ptr)

Instantiates a [[`iox2_service_builder_h`](@ref)] for a service with the provided name.

# Arguments

* `node_handle` - Must be a valid [[`iox2_node_h_ref`](@ref)] obtained by [[`iox2_node_builder_create`](@ref)](crate::[`iox2_node_builder_create`](@ref)) * `service_builder_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_service_builder_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `service_name_ptr` - Must be a valid [[`iox2_service_name_ptr`](@ref)] obtained by [[`iox2_service_name_new`](@ref)](crate::[`iox2_service_name_new`](@ref)) and casted by [[`iox2_cast_service_name_ptr`](@ref)](crate::[`iox2_cast_service_name_ptr`](@ref))

Returns the [`iox2_service_builder_h`](@ref) handle for the service builder.

# Safety

* The `node_handle` is still valid after the return of this function and can be use in another function call.

### Prototype
```c
iox2_service_builder_h iox2_node_service_builder(iox2_node_h_ref node_handle, struct iox2_service_builder_t *service_builder_struct_ptr, iox2_service_name_ptr service_name_ptr);
```
"""
function iox2_node_service_builder(node_handle, service_builder_struct_ptr, service_name_ptr)
    @ccall libiceoryx2_ffi_c.iox2_node_service_builder(node_handle::iox2_node_h_ref, service_builder_struct_ptr::Ptr{iox2_service_builder_t}, service_name_ptr::iox2_service_name_ptr)::iox2_service_builder_h
end

"""
    iox2_node_drop(node_handle)

This function needs to be called to destroy the node!

# Arguments

* `node_handle` - A valid [[`iox2_node_h`](@ref)]

# Safety

* The `node_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_node_t`](@ref)] can be re-used with a call to [[`iox2_node_builder_create`](@ref)](crate::[`iox2_node_builder_create`](@ref))!

### Prototype
```c
void iox2_node_drop(iox2_node_h node_handle);
```
"""
function iox2_node_drop(node_handle)
    @ccall libiceoryx2_ffi_c.iox2_node_drop(node_handle::iox2_node_h)::Cvoid
end

"""
    iox2_node_creation_failure_string(error)

Returns a string literal describing the provided [[`iox2_node_creation_failure_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_node_creation_failure_string(enum iox2_node_creation_failure_e error);
```
"""
function iox2_node_creation_failure_string(error)
    @ccall libiceoryx2_ffi_c.iox2_node_creation_failure_string(error::iox2_node_creation_failure_e)::Cstring
end

"""
    iox2_node_builder_new(node_builder_struct_ptr)

Creates a builder for nodes

# Arguments

* `node_builder_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_node_builder_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap.

# Returns

A [[`iox2_node_builder_h`](@ref)] handle to build the actual node.

# Safety

* The same [[`iox2_node_builder_t`](@ref)] cannot be used in subsequent calls to this function, unless [[`iox2_node_builder_create`](@ref)] was called before!

### Prototype
```c
iox2_node_builder_h iox2_node_builder_new(struct iox2_node_builder_t *node_builder_struct_ptr);
```
"""
function iox2_node_builder_new(node_builder_struct_ptr)
    @ccall libiceoryx2_ffi_c.iox2_node_builder_new(node_builder_struct_ptr::Ptr{iox2_node_builder_t})::iox2_node_builder_h
end

"""
    iox2_node_builder_set_name(node_builder_handle, node_name_ptr)

Sets the node name for the builder

# Arguments

* `node_builder_handle` - Must be a valid [[`iox2_node_builder_h_ref`](@ref)] obtained by [[`iox2_node_builder_new`](@ref)]. * `node_name_ptr` - Must be a valid [[`iox2_node_name_ptr`](@ref)], e.g. obtained by [[`iox2_node_name_new`](@ref)](crate::[`iox2_node_name_new`](@ref)) and converted by [[`iox2_cast_node_name_ptr`](@ref)](crate::[`iox2_cast_node_name_ptr`](@ref))

# Safety

* `node_builder_handle` as well as `node_name_ptr` must be valid handles

### Prototype
```c
void iox2_node_builder_set_name(iox2_node_builder_h_ref node_builder_handle, iox2_node_name_ptr node_name_ptr);
```
"""
function iox2_node_builder_set_name(node_builder_handle, node_name_ptr)
    @ccall libiceoryx2_ffi_c.iox2_node_builder_set_name(node_builder_handle::iox2_node_builder_h_ref, node_name_ptr::iox2_node_name_ptr)::Cvoid
end

"""
    iox2_node_builder_set_signal_handling_mode(node_builder_handle, signal_handling_mode)

Sets the [[`iox2_signal_handling_mode_e`](@ref)] for the [[`iox2_node_h`](@ref)].

# Arguments

* `node_builder_handle` - Must be a valid [[`iox2_node_builder_h_ref`](@ref)] obtained by [[`iox2_node_builder_new`](@ref)].

# Safety

* `node_builder_handle` must be a valid handle

### Prototype
```c
void iox2_node_builder_set_signal_handling_mode(iox2_node_builder_h_ref node_builder_handle, enum iox2_signal_handling_mode_e signal_handling_mode);
```
"""
function iox2_node_builder_set_signal_handling_mode(node_builder_handle, signal_handling_mode)
    @ccall libiceoryx2_ffi_c.iox2_node_builder_set_signal_handling_mode(node_builder_handle::iox2_node_builder_h_ref, signal_handling_mode::iox2_signal_handling_mode_e)::Cvoid
end

"""
    iox2_node_builder_set_config(node_builder_handle, config_handle)

Sets the node config for the builder

Returns [`IOX2_OK`](@ref)

# Safety

* `node_builder_handle` - Must be a valid [[`iox2_node_builder_h_ref`](@ref)] obtained by [[`iox2_node_builder_new`](@ref)]. * `config_handle` - Must be a valid [[`iox2_config_h_ref`](@ref)]

### Prototype
```c
void iox2_node_builder_set_config(iox2_node_builder_h_ref node_builder_handle, iox2_config_h_ref config_handle);
```
"""
function iox2_node_builder_set_config(node_builder_handle, config_handle)
    @ccall libiceoryx2_ffi_c.iox2_node_builder_set_config(node_builder_handle::iox2_node_builder_h_ref, config_handle::iox2_config_h_ref)::Cvoid
end

"""
    iox2_node_builder_create(node_builder_handle, node_struct_ptr, service_type, node_handle_ptr)

Creates a node and consumes the builder

# Arguments

* `node_builder_handle` - Must be a valid [[`iox2_node_builder_h`](@ref)] obtained by [[`iox2_node_builder_new`](@ref)]. * `node_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_node_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `service_type` - The [[`iox2_service_type_e`](@ref)] for the node to be created. * `node_handle_ptr` - An uninitialized or dangling [[`iox2_node_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_node_creation_failure_e`](@ref)] otherwise.

# Safety

* The `node_builder_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_node_builder_t`](@ref)] can be re-used with a call to [[`iox2_node_builder_new`](@ref)]!

### Prototype
```c
int iox2_node_builder_create(iox2_node_builder_h node_builder_handle, struct iox2_node_t *node_struct_ptr, enum iox2_service_type_e service_type, iox2_node_h *node_handle_ptr);
```
"""
function iox2_node_builder_create(node_builder_handle, node_struct_ptr, service_type, node_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_node_builder_create(node_builder_handle::iox2_node_builder_h, node_struct_ptr::Ptr{iox2_node_t}, service_type::iox2_service_type_e, node_handle_ptr::Ptr{iox2_node_h})::Cint
end

"""
    iox2_node_id_clone_from_ptr(node_id_struct_ptr, node_id_ptr, node_id_handle_ptr)

Creates a new [[`iox2_node_id_h`](@ref)] by cloning a [[`iox2_node_id_ptr`](@ref)].

# Safety

* `node_id_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_node_id_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `node_id_ptr` - Must be a valid [[`iox2_node_id_ptr`](@ref)] * `node_id_handle_ptr` - Must point to a valid [[`iox2_node_id_h`](@ref)].

### Prototype
```c
void iox2_node_id_clone_from_ptr(struct iox2_node_id_t *node_id_struct_ptr, iox2_node_id_ptr node_id_ptr, iox2_node_id_h *node_id_handle_ptr);
```
"""
function iox2_node_id_clone_from_ptr(node_id_struct_ptr, node_id_ptr, node_id_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_node_id_clone_from_ptr(node_id_struct_ptr::Ptr{iox2_node_id_t}, node_id_ptr::iox2_node_id_ptr, node_id_handle_ptr::Ptr{iox2_node_id_h})::Cvoid
end

"""
    iox2_node_id_clone_from_handle(node_id_struct_ptr, node_id_handle, node_id_handle_ptr)

Creates a new [[`iox2_node_id_h`](@ref)] by cloning a [[`iox2_node_id_h_ref`](@ref)].

# Safety

* `node_id_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_node_id_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `node_id_handle` - Must be a valid [[`iox2_node_id_h_ref`](@ref)] * `node_id_handle_ptr` - Must point to a valid [[`iox2_node_id_h`](@ref)].

### Prototype
```c
void iox2_node_id_clone_from_handle(struct iox2_node_id_t *node_id_struct_ptr, iox2_node_id_h_ref node_id_handle, iox2_node_id_h *node_id_handle_ptr);
```
"""
function iox2_node_id_clone_from_handle(node_id_struct_ptr, node_id_handle, node_id_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_node_id_clone_from_handle(node_id_struct_ptr::Ptr{iox2_node_id_t}, node_id_handle::iox2_node_id_h_ref, node_id_handle_ptr::Ptr{iox2_node_id_h})::Cvoid
end

"""
    iox2_node_id_value_high(node_id_handle)

Returns the high bits of the underlying value of the [[`iox2_node_id_h`](@ref)].

# Safety

* `node_id_handle` - Must be a valid [[`iox2_node_id_h_ref`](@ref)]

### Prototype
```c
uint64_t iox2_node_id_value_high(iox2_node_id_h_ref node_id_handle);
```
"""
function iox2_node_id_value_high(node_id_handle)
    @ccall libiceoryx2_ffi_c.iox2_node_id_value_high(node_id_handle::iox2_node_id_h_ref)::UInt64
end

"""
    iox2_node_id_value_low(node_id_handle)

Returns the low bits of the underlying value of the [[`iox2_node_id_h`](@ref)].

# Safety

* `node_id_handle` - Must be a valid [[`iox2_node_id_h_ref`](@ref)]

### Prototype
```c
uint64_t iox2_node_id_value_low(iox2_node_id_h_ref node_id_handle);
```
"""
function iox2_node_id_value_low(node_id_handle)
    @ccall libiceoryx2_ffi_c.iox2_node_id_value_low(node_id_handle::iox2_node_id_h_ref)::UInt64
end

"""
    iox2_node_id_pid(node_id_handle)

Returns the process id of the [[`iox2_node_id_h`](@ref)].

# Safety

* `node_id_handle` - Must be a valid [[`iox2_node_id_h_ref`](@ref)]

### Prototype
```c
int32_t iox2_node_id_pid(iox2_node_id_h_ref node_id_handle);
```
"""
function iox2_node_id_pid(node_id_handle)
    @ccall libiceoryx2_ffi_c.iox2_node_id_pid(node_id_handle::iox2_node_id_h_ref)::Int32
end

"""
    iox2_node_id_creation_time(node_id_handle, seconds, nanoseconds)

Returns the creation time of the [[`iox2_node_id_h`](@ref)].

# Safety

* `node_id_handle` - Must be a valid [[`iox2_node_id_h_ref`](@ref)] * `seconds` - Must point to a valid memory location * `nanoseconds` - Must point to a valid memory location

### Prototype
```c
void iox2_node_id_creation_time(iox2_node_id_h_ref node_id_handle, uint64_t *seconds, uint32_t *nanoseconds);
```
"""
function iox2_node_id_creation_time(node_id_handle, seconds, nanoseconds)
    @ccall libiceoryx2_ffi_c.iox2_node_id_creation_time(node_id_handle::iox2_node_id_h_ref, seconds::Ptr{UInt64}, nanoseconds::Ptr{UInt32})::Cvoid
end

"""
    iox2_node_id_drop(node_id_handle)

Takes ownership of the handle to delete and remove the underlying resources of a [[`iox2_node_id_h`](@ref)].

# Safety

* `node_id_handle` - Must be a valid [[`iox2_node_id_h`](@ref)]

### Prototype
```c
void iox2_node_id_drop(iox2_node_id_h node_id_handle);
```
"""
function iox2_node_id_drop(node_id_handle)
    @ccall libiceoryx2_ffi_c.iox2_node_id_drop(node_id_handle::iox2_node_id_h)::Cvoid
end

"""
    iox2_node_name_new(node_name_struct_ptr, node_name_str, node_name_len, node_name_handle_ptr)

This function create a new node name!

# Arguments

* `node_name_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_node_name_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `node_name_str` - Must be valid node name string. * `node_name_len` - The length of the node name string, not including a null termination. * `node_name_handle_ptr` - An uninitialized or dangling [[`iox2_node_name_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_semantic_string_error_e`](@ref)](crate::[`iox2_semantic_string_error_e`](@ref)) otherwise.

# Safety

* Terminates if `node_name_str` or `node_name_handle_ptr` is a NULL pointer! * It is undefined behavior to pass a `node_name_len` which is larger than the actual length of `node_name_str`!

### Prototype
```c
int iox2_node_name_new(struct iox2_node_name_t *node_name_struct_ptr, const char *node_name_str, c_size_t node_name_len, iox2_node_name_h *node_name_handle_ptr);
```
"""
function iox2_node_name_new(node_name_struct_ptr, node_name_str, node_name_len, node_name_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_node_name_new(node_name_struct_ptr::Ptr{iox2_node_name_t}, node_name_str::Cstring, node_name_len::c_size_t, node_name_handle_ptr::Ptr{iox2_node_name_h})::Cint
end

"""
    iox2_cast_node_name_ptr(node_name_handle)

This function casts a [[`iox2_node_name_h`](@ref)] into a [[`iox2_node_name_ptr`](@ref)]

# Arguments

* `node_name_handle` obtained by [[`iox2_node_name_new`](@ref)]

Returns a [[`iox2_node_name_ptr`](@ref)]

# Safety

* The `node_name_handle` must be a valid handle. * The `node_name_handle` is still valid after the call to this function.

### Prototype
```c
iox2_node_name_ptr iox2_cast_node_name_ptr(iox2_node_name_h node_name_handle);
```
"""
function iox2_cast_node_name_ptr(node_name_handle)
    @ccall libiceoryx2_ffi_c.iox2_cast_node_name_ptr(node_name_handle::iox2_node_name_h)::iox2_node_name_ptr
end

"""
    iox2_node_name_as_chars(node_name_ptr, node_name_len)

This function gives access to the node name as a non-zero-terminated char array

# Arguments

* `node_name_ptr` obtained by e.g. [[`iox2_cast_node_name_ptr`](@ref)] or a function returning a [[`iox2_node_name_ptr`](@ref)] * `node_name_len` must be used to get the length of the char array

Returns a non-zero-terminated char array

# Safety

* The `node_name_ptr` must be a valid pointer to a node name. * The `node_name_len` must be a valid pointer to a size\\_t.

### Prototype
```c
const char *iox2_node_name_as_chars(iox2_node_name_ptr node_name_ptr, c_size_t *node_name_len);
```
"""
function iox2_node_name_as_chars(node_name_ptr, node_name_len)
    @ccall libiceoryx2_ffi_c.iox2_node_name_as_chars(node_name_ptr::iox2_node_name_ptr, node_name_len::Ptr{c_size_t})::Cstring
end

"""
    iox2_node_name_drop(node_name_handle)

This function needs to be called to destroy the node name!

In general, this function is not required to call, since [[`iox2_node_builder_set_name`](@ref)](crate::[`iox2_node_builder_set_name`](@ref)) will consume the [[`iox2_node_name_h`](@ref)] handle.

# Arguments

* `node_name_handle` - A valid [[`iox2_node_name_h`](@ref)]

# Safety

* The `node_name_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_node_name_t`](@ref)] can be re-used with a call to [[`iox2_node_name_new`](@ref)]!

### Prototype
```c
void iox2_node_name_drop(iox2_node_name_h node_name_handle);
```
"""
function iox2_node_name_drop(node_name_handle)
    @ccall libiceoryx2_ffi_c.iox2_node_name_drop(node_name_handle::iox2_node_name_h)::Cvoid
end

"""
    iox2_notifier_notify_error_string(error)

Returns a string literal describing the provided [[`iox2_notifier_notify_error_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_notifier_notify_error_string(enum iox2_notifier_notify_error_e error);
```
"""
function iox2_notifier_notify_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_notifier_notify_error_string(error::iox2_notifier_notify_error_e)::Cstring
end

"""
    iox2_notifier_id(notifier_handle, id_struct_ptr, id_handle_ptr)

Returns the unique port id of the notifier.

# Safety

* `notifier_handle` is valid, non-null and was obtained via [[`iox2_port_factory_notifier_builder_create`](@ref)](crate::[`iox2_port_factory_notifier_builder_create`](@ref)). * `id_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_unique_notifier_id_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `id_handle_ptr` valid pointer to a [[`iox2_unique_notifier_id_h`](@ref)].

### Prototype
```c
void iox2_notifier_id(iox2_notifier_h_ref notifier_handle, struct iox2_unique_notifier_id_t *id_struct_ptr, iox2_unique_notifier_id_h *id_handle_ptr);
```
"""
function iox2_notifier_id(notifier_handle, id_struct_ptr, id_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_notifier_id(notifier_handle::iox2_notifier_h_ref, id_struct_ptr::Ptr{iox2_unique_notifier_id_t}, id_handle_ptr::Ptr{iox2_unique_notifier_id_h})::Cvoid
end

"""
    iox2_notifier_deadline(notifier_handle, seconds, nanoseconds)

Returns the deadline of the notifier's service. If there is a deadline set, the provided arguments `seconds` and `nanoseconds` will be set `true` is returned. Otherwise, false is returned and nothing is set.

# Safety

* `notifier_handle` is valid, non-null and was obtained via [[`iox2_port_factory_listener_builder_create`](@ref)](crate::[`iox2_port_factory_listener_builder_create`](@ref)) * `seconds` is pointing to a valid memory location and non-null * `nanoseconds` is pointing to a valid memory location and non-null

### Prototype
```c
bool iox2_notifier_deadline(iox2_notifier_h_ref notifier_handle, uint64_t *seconds, uint32_t *nanoseconds);
```
"""
function iox2_notifier_deadline(notifier_handle, seconds, nanoseconds)
    @ccall libiceoryx2_ffi_c.iox2_notifier_deadline(notifier_handle::iox2_notifier_h_ref, seconds::Ptr{UInt64}, nanoseconds::Ptr{UInt32})::Bool
end

"""
    iox2_notifier_notify(notifier_handle, number_of_notified_listener_ptr)

Notifies all [[`iox2_listener_h`](@ref)](crate::[`iox2_listener_h`](@ref)) connected to the service with the default event id provided on creation.

# Arguments

* notifier\\_handle - Must be a valid [[`iox2_notifier_h_ref`](@ref)] obtained by [[`iox2_port_factory_notifier_builder_create`](@ref)](crate::[`iox2_port_factory_notifier_builder_create`](@ref)) * number\\_of\\_notified\\_listener\\_ptr - Must be either a NULL pointer or a pointer to a `size_t` to store the number of notified listener

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_notifier_notify_error_e`](@ref)] otherwise.

# Safety

`notifier_handle` must be a valid handle and is still valid after the return of this function and can be use in another function call.

### Prototype
```c
int iox2_notifier_notify(iox2_notifier_h_ref notifier_handle, c_size_t *number_of_notified_listener_ptr);
```
"""
function iox2_notifier_notify(notifier_handle, number_of_notified_listener_ptr)
    @ccall libiceoryx2_ffi_c.iox2_notifier_notify(notifier_handle::iox2_notifier_h_ref, number_of_notified_listener_ptr::Ptr{c_size_t})::Cint
end

"""
    iox2_notifier_notify_with_custom_event_id(notifier_handle, custom_event_id_ptr, number_of_notified_listener_ptr)

Notifies all [[`iox2_listener_h`](@ref)](crate::[`iox2_listener_h`](@ref)) connected to the service with the custom event id.

# Arguments

* notifier\\_handle - Must be a valid [[`iox2_notifier_h_ref`](@ref)] obtained by [[`iox2_port_factory_notifier_builder_create`](@ref)](crate::[`iox2_port_factory_notifier_builder_create`](@ref)) * custom\\_event\\_id\\_ptr - Must be a pointer to an initialized [[`iox2_event_id_t`](@ref)](crate::[`iox2_event_id_t`](@ref)) * number\\_of\\_notified\\_listener\\_ptr - Must be either a NULL pointer or a pointer to a `size_t` to store the number of notified listener

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_notifier_notify_error_e`](@ref)] otherwise.

# Safety

`notifier_handle` must be a valid handle and is still valid after the return of this function and can be use in another function call. `custom_event_id_ptr` must not be a NULL pointer.

### Prototype
```c
int iox2_notifier_notify_with_custom_event_id(iox2_notifier_h_ref notifier_handle, const struct iox2_event_id_t *custom_event_id_ptr, c_size_t *number_of_notified_listener_ptr);
```
"""
function iox2_notifier_notify_with_custom_event_id(notifier_handle, custom_event_id_ptr, number_of_notified_listener_ptr)
    @ccall libiceoryx2_ffi_c.iox2_notifier_notify_with_custom_event_id(notifier_handle::iox2_notifier_h_ref, custom_event_id_ptr::Ptr{iox2_event_id_t}, number_of_notified_listener_ptr::Ptr{c_size_t})::Cint
end

"""
    iox2_notifier_drop(notifier_handle)

This function needs to be called to destroy the notifier!

# Arguments

* `notifier_handle` - A valid [[`iox2_notifier_h`](@ref)]

# Safety

* The `notifier_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_notifier_t`](@ref)] can be re-used with a call to [[`iox2_port_factory_notifier_builder_create`](@ref)](crate::[`iox2_port_factory_notifier_builder_create`](@ref))!

### Prototype
```c
void iox2_notifier_drop(iox2_notifier_h notifier_handle);
```
"""
function iox2_notifier_drop(notifier_handle)
    @ccall libiceoryx2_ffi_c.iox2_notifier_drop(notifier_handle::iox2_notifier_h)::Cvoid
end

"""
    iox2_notifier_details_notifier_id(handle, id_struct_ptr, id_handle_ptr)

Returns the unique port id of the notifier.

# Safety

* `handle` valid pointer to the notifier details * `id_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_unique_notifier_id_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `id_handle_ptr` valid pointer to a [[`iox2_unique_notifier_id_h`](@ref)].

### Prototype
```c
void iox2_notifier_details_notifier_id(iox2_notifier_details_ptr handle, struct iox2_unique_notifier_id_t *id_struct_ptr, iox2_unique_notifier_id_h *id_handle_ptr);
```
"""
function iox2_notifier_details_notifier_id(handle, id_struct_ptr, id_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_notifier_details_notifier_id(handle::iox2_notifier_details_ptr, id_struct_ptr::Ptr{iox2_unique_notifier_id_t}, id_handle_ptr::Ptr{iox2_unique_notifier_id_h})::Cvoid
end

"""
    iox2_notifier_details_node_id(handle)

Returns the [[`iox2_node_id_ptr`](@ref)](crate::[`iox2_node_id_ptr`](@ref)), an immutable pointer to the node id.

# Safety

* `handle` valid pointer to the notifier details

### Prototype
```c
iox2_node_id_ptr iox2_notifier_details_node_id(iox2_notifier_details_ptr handle);
```
"""
function iox2_notifier_details_node_id(handle)
    @ccall libiceoryx2_ffi_c.iox2_notifier_details_node_id(handle::iox2_notifier_details_ptr)::iox2_node_id_ptr
end

"""
    iox2_pending_response_is_connected(handle)

Returns true if the corresponding active request is still connected and responses can send further responses, otherwise false.

# Arguments

* `handle` - Must be a valid [[`iox2_pending_response_h_ref`](@ref)] obtained by [[`iox2_request_mut_send`](@ref)](crate::[`iox2_request_mut_send`](@ref)).

# Safety

* `handle` must be valid a handle

### Prototype
```c
bool iox2_pending_response_is_connected(iox2_pending_response_h_ref handle);
```
"""
function iox2_pending_response_is_connected(handle)
    @ccall libiceoryx2_ffi_c.iox2_pending_response_is_connected(handle::iox2_pending_response_h_ref)::Bool
end

"""
    iox2_pending_response_set_disconnect_hint(handle)

Marks the connection state that the Client wants to gracefully disconnect. When the server reads it, it can send the last response and drop the corresponding active request to terminate the connection ensuring that no response is lost on the client side.

# Arguments

* `handle` - Must be a valid [[`iox2_pending_response_h_ref`](@ref)] obtained by [[`iox2_request_mut_send`](@ref)](crate::[`iox2_request_mut_send`](@ref)).

# Safety

* `handle` must be valid a handle

### Prototype
```c
void iox2_pending_response_set_disconnect_hint(iox2_pending_response_h_ref handle);
```
"""
function iox2_pending_response_set_disconnect_hint(handle)
    @ccall libiceoryx2_ffi_c.iox2_pending_response_set_disconnect_hint(handle::iox2_pending_response_h_ref)::Cvoid
end

"""
    iox2_pending_response_number_of_server_connections(handle)

Returns how many servers received the corresponding request initially.

# Arguments

* `handle` - Must be a valid [[`iox2_pending_response_h_ref`](@ref)] obtained by [[`iox2_request_mut_send`](@ref)](crate::[`iox2_request_mut_send`](@ref)).

# Safety

* `handle` must be valid a handle

### Prototype
```c
c_size_t iox2_pending_response_number_of_server_connections(iox2_pending_response_h_ref handle);
```
"""
function iox2_pending_response_number_of_server_connections(handle)
    @ccall libiceoryx2_ffi_c.iox2_pending_response_number_of_server_connections(handle::iox2_pending_response_h_ref)::c_size_t
end

"""
    iox2_pending_response_has_response(handle)

Returns true if there is a response in the buffer, otherwise false.

# Arguments

* `handle` - Must be a valid [[`iox2_pending_response_h_ref`](@ref)] obtained by [[`iox2_request_mut_send`](@ref)](crate::[`iox2_request_mut_send`](@ref)).

# Safety

* `handle` must be valid a handle

### Prototype
```c
bool iox2_pending_response_has_response(iox2_pending_response_h_ref handle);
```
"""
function iox2_pending_response_has_response(handle)
    @ccall libiceoryx2_ffi_c.iox2_pending_response_has_response(handle::iox2_pending_response_h_ref)::Bool
end

"""
    iox2_pending_response_header(handle, header_struct_ptr, header_handle_ptr)

Acquires the requests header.

# Safety

* `handle` - Must be a valid [[`iox2_pending_response_h_ref`](@ref)] obtained by [[`iox2_request_mut_send`](@ref)](crate::[`iox2_request_mut_send`](@ref)). * `header_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_request_header_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `header_handle_ptr` valid pointer to a [[`iox2_request_header_h`](@ref)].

### Prototype
```c
void iox2_pending_response_header(iox2_pending_response_h_ref handle, struct iox2_request_header_t *header_struct_ptr, iox2_request_header_h *header_handle_ptr);
```
"""
function iox2_pending_response_header(handle, header_struct_ptr, header_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_pending_response_header(handle::iox2_pending_response_h_ref, header_struct_ptr::Ptr{iox2_request_header_t}, header_handle_ptr::Ptr{iox2_request_header_h})::Cvoid
end

"""
    iox2_pending_response_user_header(handle, header_ptr)

Acquires the requests user header.

# Safety

* `handle` - Must be a valid [[`iox2_pending_response_h_ref`](@ref)] obtained by [[`iox2_request_mut_send`](@ref)](crate::[`iox2_request_mut_send`](@ref)). * `header_ptr` a valid, non-null pointer pointing to a `*const c\\_void` pointer.

### Prototype
```c
void iox2_pending_response_user_header(iox2_pending_response_h_ref handle, const void **header_ptr);
```
"""
function iox2_pending_response_user_header(handle, header_ptr)
    @ccall libiceoryx2_ffi_c.iox2_pending_response_user_header(handle::iox2_pending_response_h_ref, header_ptr::Ptr{Ptr{Cvoid}})::Cvoid
end

"""
    iox2_pending_response_payload(handle, payload_ptr, number_of_elements)

Acquires the requests payload.

# Safety

* `handle` - Must be a valid [[`iox2_pending_response_h_ref`](@ref)] obtained by [[`iox2_request_mut_send`](@ref)](crate::[`iox2_request_mut_send`](@ref)). * `payload_ptr` a valid, non-null pointer pointing to a `*const c\\_void` pointer. * `number_of_elements` (optional) either a null pointer or a valid pointer pointing to a [[`c_size_t`](@ref)].

### Prototype
```c
void iox2_pending_response_payload(iox2_pending_response_h_ref handle, const void **payload_ptr, c_size_t *number_of_elements);
```
"""
function iox2_pending_response_payload(handle, payload_ptr, number_of_elements)
    @ccall libiceoryx2_ffi_c.iox2_pending_response_payload(handle::iox2_pending_response_h_ref, payload_ptr::Ptr{Ptr{Cvoid}}, number_of_elements::Ptr{c_size_t})::Cvoid
end

"""
    iox2_pending_response_receive(handle, response_struct_ptr, response_handle_ptr)

Takes a response out of the buffer.

# Arguments

* `handle` - Must be a valid [[`iox2_pending_response_h_ref`](@ref)] obtained by [[`iox2_request_mut_send`](@ref)](crate::[`iox2_request_mut_send`](@ref)). * `response_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_response_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `response_handle_ptr` - An uninitialized or dangling [[`iox2_response_h`](@ref)] handle which will be initialized by this function call if a sample is obtained, otherwise it will be set to NULL.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_receive_error_e`](@ref)](crate::[`iox2_receive_error_e`](@ref)) otherwise. Attention, an empty response buffer is not an error and even with [`IOX2_OK`](@ref) it is possible to get a NULL in `response_handle_ptr`.

# Safety

* The `handle` is still valid after the return of this function and can be use in another function call. * The `response_handle_ptr` is pointing to a valid [[`iox2_response_h`](@ref)].

### Prototype
```c
int iox2_pending_response_receive(iox2_pending_response_h_ref handle, struct iox2_response_t *response_struct_ptr, iox2_response_h *response_handle_ptr);
```
"""
function iox2_pending_response_receive(handle, response_struct_ptr, response_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_pending_response_receive(handle::iox2_pending_response_h_ref, response_struct_ptr::Ptr{iox2_response_t}, response_handle_ptr::Ptr{iox2_response_h})::Cint
end

"""
    iox2_pending_response_drop(handle)

This function needs to be called to destroy the pending response!

# Arguments

* `handle` - A valid [[`iox2_pending_response_h`](@ref)]

# Safety

* The `handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_pending_response_t`](@ref)] can be re-used with a call to [[`iox2_request_mut_send`](@ref)](crate::[`iox2_request_mut_send`](@ref))!

### Prototype
```c
void iox2_pending_response_drop(iox2_pending_response_h handle);
```
"""
function iox2_pending_response_drop(handle)
    @ccall libiceoryx2_ffi_c.iox2_pending_response_drop(handle::iox2_pending_response_h)::Cvoid
end

"""
    iox2_port_factory_blackboard_writer_builder(port_factory_handle, writer_builder_struct_ptr)

Instantiates a [[`iox2_port_factory_writer_builder_h`](@ref)] to build a writer.

# Arguments

* `port_factory_handle` - Must be a valid [[`iox2_port_factory_blackboard_h_ref`](@ref)] obtained by e.g. [[`iox2_service_builder_blackboard_create`](@ref)](crate::[`iox2_service_builder_blackboard_create`](@ref)). * `writer_builder_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_writer_builder_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap.

Returns the [`iox2_port_factory_writer_builder_h`](@ref) handle for the writer builder.

# Safety

* The `port_factory_handle` is still valid after the return of this function and can be used in another function call.

### Prototype
```c
iox2_port_factory_writer_builder_h iox2_port_factory_blackboard_writer_builder(iox2_port_factory_blackboard_h_ref port_factory_handle, struct iox2_port_factory_writer_builder_t *writer_builder_struct_ptr);
```
"""
function iox2_port_factory_blackboard_writer_builder(port_factory_handle, writer_builder_struct_ptr)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_blackboard_writer_builder(port_factory_handle::iox2_port_factory_blackboard_h_ref, writer_builder_struct_ptr::Ptr{iox2_port_factory_writer_builder_t})::iox2_port_factory_writer_builder_h
end

"""
    iox2_port_factory_blackboard_reader_builder(port_factory_handle, reader_builder_struct_ptr)

Instantiates a [[`iox2_port_factory_reader_builder_h`](@ref)] to build a reader.

# Arguments

* `port_factory_handle` - Must be a valid [[`iox2_port_factory_blackboard_h_ref`](@ref)] obtained by e.g. [[`iox2_service_builder_blackboard_create`](@ref)](crate::[`iox2_service_builder_blackboard_create`](@ref)). * `reader_builder_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_reader_builder_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap.

Returns the [[`iox2_port_factory_reader_builder_h`](@ref)] handle for the reader builder.

# Safety

* The `port_factory_handle` is still valid after the return of this function and can be used in another function call.

### Prototype
```c
iox2_port_factory_reader_builder_h iox2_port_factory_blackboard_reader_builder(iox2_port_factory_blackboard_h_ref port_factory_handle, struct iox2_port_factory_reader_builder_t *reader_builder_struct_ptr);
```
"""
function iox2_port_factory_blackboard_reader_builder(port_factory_handle, reader_builder_struct_ptr)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_blackboard_reader_builder(port_factory_handle::iox2_port_factory_blackboard_h_ref, reader_builder_struct_ptr::Ptr{iox2_port_factory_reader_builder_t})::iox2_port_factory_reader_builder_h
end

"""
    iox2_port_factory_blackboard_attributes(port_factory_handle)

Returns the service attributes.

# Safety

* The `port_factory_handle` must live longer than the returned [`iox2_attribute_set_ptr`](@ref).

### Prototype
```c
iox2_attribute_set_ptr iox2_port_factory_blackboard_attributes(iox2_port_factory_blackboard_h_ref port_factory_handle);
```
"""
function iox2_port_factory_blackboard_attributes(port_factory_handle)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_blackboard_attributes(port_factory_handle::iox2_port_factory_blackboard_h_ref)::iox2_attribute_set_ptr
end

"""
    iox2_port_factory_blackboard_static_config(port_factory_handle, static_config)

Sets the values in the provided [[`iox2_static_config_blackboard_t`](@ref)] pointer.

# Safety

* The `port_factory_handle` must be valid and obtained by [[`iox2_service_builder_blackboard_open`](@ref)](crate::[`iox2_service_builder_blackboard_open`](@ref)) or [[`iox2_service_builder_blackboard_create`](@ref)](crate::[`iox2_service_builder_blackboard_create`](@ref))! * The `static_config` must be a valid pointer and non-null.

### Prototype
```c
void iox2_port_factory_blackboard_static_config(iox2_port_factory_blackboard_h_ref port_factory_handle, struct iox2_static_config_blackboard_t *static_config);
```
"""
function iox2_port_factory_blackboard_static_config(port_factory_handle, static_config)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_blackboard_static_config(port_factory_handle::iox2_port_factory_blackboard_h_ref, static_config::Ptr{iox2_static_config_blackboard_t})::Cvoid
end

"""
    iox2_port_factory_blackboard_dynamic_config_number_of_writers(handle)

Returns how many writer ports are currently connected.

# Safety

* The `handle` must be valid and obtained by [[`iox2_service_builder_blackboard_open`](@ref)](crate::[`iox2_service_builder_blackboard_open`](@ref)) or [[`iox2_service_builder_blackboard_create`](@ref)](crate::[`iox2_service_builder_blackboard_create`](@ref))!

### Prototype
```c
size_t iox2_port_factory_blackboard_dynamic_config_number_of_writers(iox2_port_factory_blackboard_h_ref handle);
```
"""
function iox2_port_factory_blackboard_dynamic_config_number_of_writers(handle)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_blackboard_dynamic_config_number_of_writers(handle::iox2_port_factory_blackboard_h_ref)::Csize_t
end

"""
    iox2_port_factory_blackboard_nodes(handle, callback, callback_ctx)

Calls the callback repeatedly with an [[`iox2_node_state_e`](@ref)](crate::api::[`iox2_node_state_e`](@ref)), [[`iox2_node_id_ptr`](@ref)](crate::api::[`iox2_node_id_ptr`](@ref)), [´[`iox2_node_name_ptr`](@ref)´](crate::api::[`iox2_node_name_ptr`](@ref)) and [[`iox2_config_ptr`](@ref)](crate::api::[`iox2_config_ptr`](@ref)) for all [`Node`](iceoryx2::node::Node)s that have opened the service.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_node_list_failure_e`](@ref)](crate::api::[`iox2_node_list_failure_e`](@ref)) otherwise.

# Safety

* The `handle` must be valid and obtained by [[`iox2_service_builder_blackboard_open`](@ref)](crate::[`iox2_service_builder_blackboard_open`](@ref)) or [[`iox2_service_builder_blackboard_create`](@ref)](crate::[`iox2_service_builder_blackboard_create`](@ref))! * `callback` - A valid callback with [[`iox2_node_list_callback`](@ref)} signature * `callback_ctx` - An optional callback context [[`iox2_callback_context`](@ref)} to e.g. store information across callback iterations

### Prototype
```c
int iox2_port_factory_blackboard_nodes(iox2_port_factory_blackboard_h_ref handle, iox2_node_list_callback callback, iox2_callback_context callback_ctx);
```
"""
function iox2_port_factory_blackboard_nodes(handle, callback, callback_ctx)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_blackboard_nodes(handle::iox2_port_factory_blackboard_h_ref, callback::iox2_node_list_callback, callback_ctx::iox2_callback_context)::Cint
end

"""
    iox2_port_factory_blackboard_service_name(handle)

Returns the [[`iox2_service_name_ptr`](@ref)], an immutable pointer to the service name.

# Safety

* The `handle` must be valid and obtained by [[`iox2_service_builder_blackboard_open`](@ref)](crate::[`iox2_service_builder_blackboard_open`](@ref)) or [[`iox2_service_builder_blackboard_create`](@ref)](crate::[`iox2_service_builder_blackboard_create`](@ref))!

### Prototype
```c
iox2_service_name_ptr iox2_port_factory_blackboard_service_name(iox2_port_factory_blackboard_h_ref handle);
```
"""
function iox2_port_factory_blackboard_service_name(handle)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_blackboard_service_name(handle::iox2_port_factory_blackboard_h_ref)::iox2_service_name_ptr
end

"""
    iox2_port_factory_blackboard_service_id(handle, buffer, buffer_len)

Stores the service id in the provided buffer

# Safety

* The `handle` must be valid and obtained by [[`iox2_service_builder_blackboard_open`](@ref)](crate::[`iox2_service_builder_blackboard_open`](@ref)) or [[`iox2_service_builder_blackboard_create`](@ref)](crate::[`iox2_service_builder_blackboard_create`](@ref))! * `buffer` must be non-zero and point to a valid memory location * `buffer_len` must define the actual size of the memory location `buffer` is pointing to

### Prototype
```c
void iox2_port_factory_blackboard_service_id(iox2_port_factory_blackboard_h_ref handle, char *buffer, size_t buffer_len);
```
"""
function iox2_port_factory_blackboard_service_id(handle, buffer, buffer_len)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_blackboard_service_id(handle::iox2_port_factory_blackboard_h_ref, buffer::Cstring, buffer_len::Csize_t)::Cvoid
end

"""
    iox2_port_factory_blackboard_dynamic_config_number_of_readers(handle)

Returns how many reader ports are currently connected.

# Safety

* The `handle` must be valid and obtained by [[`iox2_service_builder_blackboard_open`](@ref)](crate::[`iox2_service_builder_blackboard_open`](@ref)) or [[`iox2_service_builder_blackboard_create`](@ref)](crate::[`iox2_service_builder_blackboard_create`](@ref))!

### Prototype
```c
size_t iox2_port_factory_blackboard_dynamic_config_number_of_readers(iox2_port_factory_blackboard_h_ref handle);
```
"""
function iox2_port_factory_blackboard_dynamic_config_number_of_readers(handle)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_blackboard_dynamic_config_number_of_readers(handle::iox2_port_factory_blackboard_h_ref)::Csize_t
end

"""
    iox2_port_factory_blackboard_dynamic_config_list_readers(handle, callback, callback_ctx)

Calls the callback repeatedly for every connected [[`iox2_reader_h`](@ref)](crate::[`iox2_reader_h`](@ref)) and provides all communcation details with a [[`iox2_reader_details_ptr`](@ref)].

# Safety

* [[`iox2_reader_details_ptr`](@ref)] - Provides a view to the reader details. Data must not be accessed outside of the callback. * `callback` - A valid callback with [[`iox2_list_readers_callback`](@ref)] signature * `callback_ctx` - An optional callback context [[`iox2_callback_context`](@ref)] to e.g. store information across callback iterations. Must be either `NULL` or point to a valid memory location

### Prototype
```c
void iox2_port_factory_blackboard_dynamic_config_list_readers(iox2_port_factory_blackboard_h_ref handle, iox2_list_readers_callback callback, iox2_callback_context callback_ctx);
```
"""
function iox2_port_factory_blackboard_dynamic_config_list_readers(handle, callback, callback_ctx)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_blackboard_dynamic_config_list_readers(handle::iox2_port_factory_blackboard_h_ref, callback::iox2_list_readers_callback, callback_ctx::iox2_callback_context)::Cvoid
end

"""
    iox2_port_factory_blackboard_dynamic_config_list_writers(handle, callback, callback_ctx)

Calls the callback repeatedly for every connected [[`iox2_writer_h`](@ref)](crate::[`iox2_writer_h`](@ref)) and provides all communcation details with a [[`iox2_writer_details_ptr`](@ref)].

# Safety

* [[`iox2_writer_details_ptr`](@ref)] - Provides a view to the writer details. Data must not be accessed outside of the callback. * `callback` - A valid callback with [[`iox2_list_writers_callback`](@ref)] signature * `callback_ctx` - An optional callback context [[`iox2_callback_context`](@ref)] to e.g. store information across callback iterations. Must be either `NULL` or point to a valid memory location

### Prototype
```c
void iox2_port_factory_blackboard_dynamic_config_list_writers(iox2_port_factory_blackboard_h_ref handle, iox2_list_writers_callback callback, iox2_callback_context callback_ctx);
```
"""
function iox2_port_factory_blackboard_dynamic_config_list_writers(handle, callback, callback_ctx)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_blackboard_dynamic_config_list_writers(handle::iox2_port_factory_blackboard_h_ref, callback::iox2_list_writers_callback, callback_ctx::iox2_callback_context)::Cvoid
end

"""
    iox2_port_factory_blackboard_drop(port_factory_handle)

This function needs to be called to destroy the port factory!

# Arguments

* `port_factory_handle` - A valid [[`iox2_port_factory_blackboard_h`](@ref)]

# Safety

* The `port_factory_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_port_factory_blackboard_t`](@ref)] can be re-used with a call to [[`iox2_service_builder_blackboard_create`](@ref)](crate::[`iox2_service_builder_blackboard_create`](@ref)) or [[`iox2_service_builder_blackboard_open`](@ref)](crate::[`iox2_service_builder_blackboard_open`](@ref))!

### Prototype
```c
void iox2_port_factory_blackboard_drop(iox2_port_factory_blackboard_h port_factory_handle);
```
"""
function iox2_port_factory_blackboard_drop(port_factory_handle)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_blackboard_drop(port_factory_handle::iox2_port_factory_blackboard_h)::Cvoid
end

"""
    iox2_port_factory_blackboard_list_keys(handle, callback, callback_ctx)

Iterates over all keys of the blackboard and calls the provided callback with a void pointer to the key as argument.

# Safety

* The `handle` must be valid and obtained by [[`iox2_service_builder_blackboard_open`](@ref)](crate::[`iox2_service_builder_blackboard_open`](@ref)) or [[`iox2_service_builder_blackboard_create`](@ref)](crate::[`iox2_service_builder_blackboard_create`](@ref))! * `callback` - A valid callback with [[`iox2_port_factory_blackboard_list_keys_callback`](@ref)} signature * `callback_ctx` - An optional callback context [[`iox2_callback_context`](@ref)} to e.g. store information across callback iterations

### Prototype
```c
void iox2_port_factory_blackboard_list_keys(iox2_port_factory_blackboard_h_ref handle, iox2_port_factory_blackboard_list_keys_callback callback, iox2_callback_context callback_ctx);
```
"""
function iox2_port_factory_blackboard_list_keys(handle, callback, callback_ctx)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_blackboard_list_keys(handle::iox2_port_factory_blackboard_h_ref, callback::iox2_port_factory_blackboard_list_keys_callback, callback_ctx::iox2_callback_context)::Cvoid
end

"""
    iox2_client_create_error_string(error)

Returns a string literal describing the provided [[`iox2_client_create_error_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_client_create_error_string(enum iox2_client_create_error_e error);
```
"""
function iox2_client_create_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_client_create_error_string(error::iox2_client_create_error_e)::Cstring
end

"""
    iox2_port_factory_client_builder_set_allocation_strategy(port_factory_handle, value)

Sets the [[`iox2_allocation_strategy_e`](@ref)] for the client

# Arguments

* `port_factory_handle` - Must be a valid [[`iox2_port_factory_client_builder_h_ref`](@ref)] obtained by [[`iox2_port_factory_request_response_client_builder`](@ref)](crate::[`iox2_port_factory_request_response_client_builder`](@ref)). * `value` - The value to set the allocation strategy to

# Safety

* `port_factory_handle` must be a valid handle

### Prototype
```c
void iox2_port_factory_client_builder_set_allocation_strategy(iox2_port_factory_client_builder_h_ref port_factory_handle, enum iox2_allocation_strategy_e value);
```
"""
function iox2_port_factory_client_builder_set_allocation_strategy(port_factory_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_client_builder_set_allocation_strategy(port_factory_handle::iox2_port_factory_client_builder_h_ref, value::iox2_allocation_strategy_e)::Cvoid
end

"""
    iox2_port_factory_client_builder_set_initial_max_slice_len(port_factory_handle, value)

Sets the max slice length for the client

# Arguments

* `port_factory_handle` - Must be a valid [[`iox2_port_factory_client_builder_h_ref`](@ref)] obtained by [[`iox2_port_factory_request_response_client_builder`](@ref)](crate::[`iox2_port_factory_request_response_client_builder`](@ref)). * `value` - The value to set max slice length to

# Safety

* `port_factory_handle` must be valid handles

### Prototype
```c
void iox2_port_factory_client_builder_set_initial_max_slice_len(iox2_port_factory_client_builder_h_ref port_factory_handle, c_size_t value);
```
"""
function iox2_port_factory_client_builder_set_initial_max_slice_len(port_factory_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_client_builder_set_initial_max_slice_len(port_factory_handle::iox2_port_factory_client_builder_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_port_factory_client_builder_unable_to_deliver_strategy(port_factory_handle, value)

Sets the unable to deliver strategy for the client

# Arguments

* `port_factory_handle` - Must be a valid [[`iox2_port_factory_client_builder_h_ref`](@ref)] obtained by [[`iox2_port_factory_request_response_client_builder`](@ref)](crate::[`iox2_port_factory_request_response_client_builder`](@ref)). * `value` - The value to set the unable to deliver strategy to

# Safety

* `port_factory_handle` must be valid handles

### Prototype
```c
void iox2_port_factory_client_builder_unable_to_deliver_strategy(iox2_port_factory_client_builder_h_ref port_factory_handle, enum iox2_unable_to_deliver_strategy_e value);
```
"""
function iox2_port_factory_client_builder_unable_to_deliver_strategy(port_factory_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_client_builder_unable_to_deliver_strategy(port_factory_handle::iox2_port_factory_client_builder_h_ref, value::iox2_unable_to_deliver_strategy_e)::Cvoid
end

"""
    iox2_port_factory_client_builder_create(port_factory_handle, struct_ptr, handle_ptr)

Creates a client and consumes the builder

# Arguments

* `port_factory_handle` - Must be a valid [[`iox2_port_factory_client_builder_h`](@ref)] obtained by [[`iox2_port_factory_request_response_client_builder`](@ref)](crate::[`iox2_port_factory_request_response_client_builder`](@ref)). * `struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_client_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `handle_ptr` - An uninitialized or dangling [[`iox2_client_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_client_create_error_e`](@ref)] otherwise.

# Safety

* The `port_factory_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_port_factory_client_builder_t`](@ref)] can be re-used with a call to [[`iox2_port_factory_request_response_client_builder`](@ref)](crate::[`iox2_port_factory_request_response_client_builder`](@ref))!

### Prototype
```c
int iox2_port_factory_client_builder_create(iox2_port_factory_client_builder_h port_factory_handle, struct iox2_client_t *struct_ptr, iox2_client_h *handle_ptr);
```
"""
function iox2_port_factory_client_builder_create(port_factory_handle, struct_ptr, handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_client_builder_create(port_factory_handle::iox2_port_factory_client_builder_h, struct_ptr::Ptr{iox2_client_t}, handle_ptr::Ptr{iox2_client_h})::Cint
end

"""
    iox2_port_factory_event_service_name(port_factory_handle)

Returns the [[`iox2_service_name_ptr`](@ref)], an immutable pointer to the service name.

# Safety

* The `_handle` must be valid and obtained by [[`iox2_service_builder_event_open`](@ref)](crate::[`iox2_service_builder_event_open`](@ref)) or [[`iox2_service_builder_event_open_or_create`](@ref)](crate::[`iox2_service_builder_event_open_or_create`](@ref))!

### Prototype
```c
iox2_service_name_ptr iox2_port_factory_event_service_name(iox2_port_factory_event_h_ref port_factory_handle);
```
"""
function iox2_port_factory_event_service_name(port_factory_handle)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_event_service_name(port_factory_handle::iox2_port_factory_event_h_ref)::iox2_service_name_ptr
end

"""
    iox2_port_factory_event_static_config(port_factory_handle, static_config)

Set the values in the provided [[`iox2_static_config_event_t`](@ref)] pointer.

# Safety

* The `_handle` must be valid and obtained by [[`iox2_service_builder_event_open`](@ref)](crate::[`iox2_service_builder_event_open`](@ref)) or [[`iox2_service_builder_event_open_or_create`](@ref)](crate::[`iox2_service_builder_event_open_or_create`](@ref))! * The `static_config` must be a valid pointer and non-null.

### Prototype
```c
void iox2_port_factory_event_static_config(iox2_port_factory_event_h_ref port_factory_handle, struct iox2_static_config_event_t *static_config);
```
"""
function iox2_port_factory_event_static_config(port_factory_handle, static_config)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_event_static_config(port_factory_handle::iox2_port_factory_event_h_ref, static_config::Ptr{iox2_static_config_event_t})::Cvoid
end

"""
    iox2_port_factory_event_notifier_builder(port_factory_handle, notifier_builder_struct_ptr)

Instantiates a [[`iox2_port_factory_notifier_builder_h`](@ref)] to build a notifier.

# Arguments

* `port_factory_handle` - Must be a valid [[`iox2_port_factory_event_h_ref`](@ref)] obtained by e.g. [[`iox2_service_builder_event_open_or_create`](@ref)](crate::[`iox2_service_builder_event_open_or_create`](@ref)) * `notifier_builder_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_notifier_builder_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap.

Returns the [`iox2_port_factory_notifier_builder_h`](@ref) handle for the notifier builder.

# Safety

* The `port_factory_handle` is still valid after the return of this function and can be use in another function call.

### Prototype
```c
iox2_port_factory_notifier_builder_h iox2_port_factory_event_notifier_builder(iox2_port_factory_event_h_ref port_factory_handle, struct iox2_port_factory_notifier_builder_t *notifier_builder_struct_ptr);
```
"""
function iox2_port_factory_event_notifier_builder(port_factory_handle, notifier_builder_struct_ptr)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_event_notifier_builder(port_factory_handle::iox2_port_factory_event_h_ref, notifier_builder_struct_ptr::Ptr{iox2_port_factory_notifier_builder_t})::iox2_port_factory_notifier_builder_h
end

"""
    iox2_port_factory_event_listener_builder(port_factory_handle, listener_builder_struct_ptr)

Instantiates a [[`iox2_port_factory_listener_builder_h`](@ref)] to build a listener.

# Arguments

* `port_factory_handle` - Must be a valid [[`iox2_port_factory_event_h_ref`](@ref)] obtained by e.g. [[`iox2_service_builder_event_open_or_create`](@ref)](crate::[`iox2_service_builder_event_open_or_create`](@ref)) * `listener_builder_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_listener_builder_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap.

Returns the [[`iox2_port_factory_listener_builder_h`](@ref)] handle for the listener builder.

# Safety

* The `port_factory_handle` is still valid after the return of this function and can be use in another function call.

### Prototype
```c
iox2_port_factory_listener_builder_h iox2_port_factory_event_listener_builder(iox2_port_factory_event_h_ref port_factory_handle, struct iox2_port_factory_listener_builder_t *listener_builder_struct_ptr);
```
"""
function iox2_port_factory_event_listener_builder(port_factory_handle, listener_builder_struct_ptr)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_event_listener_builder(port_factory_handle::iox2_port_factory_event_h_ref, listener_builder_struct_ptr::Ptr{iox2_port_factory_listener_builder_t})::iox2_port_factory_listener_builder_h
end

"""
    iox2_port_factory_event_attributes(port_factory_handle)

Returnes the services attributes.

# Safety

* The `port_factory_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The `port_factory_handle` must live longer than the returned `iox2_attribute_set_h_ref`.

### Prototype
```c
iox2_attribute_set_ptr iox2_port_factory_event_attributes(iox2_port_factory_event_h_ref port_factory_handle);
```
"""
function iox2_port_factory_event_attributes(port_factory_handle)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_event_attributes(port_factory_handle::iox2_port_factory_event_h_ref)::iox2_attribute_set_ptr
end

"""
    iox2_port_factory_event_dynamic_config_number_of_listeners(handle)

Returns how many listener ports are currently connected.

# Safety

* The `handle` must be valid and obtained by [[`iox2_service_builder_event_open`](@ref)](crate::[`iox2_service_builder_event_open`](@ref)) or [[`iox2_service_builder_event_open_or_create`](@ref)](crate::[`iox2_service_builder_event_open_or_create`](@ref))!

### Prototype
```c
size_t iox2_port_factory_event_dynamic_config_number_of_listeners(iox2_port_factory_event_h_ref handle);
```
"""
function iox2_port_factory_event_dynamic_config_number_of_listeners(handle)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_event_dynamic_config_number_of_listeners(handle::iox2_port_factory_event_h_ref)::Csize_t
end

"""
    iox2_port_factory_event_dynamic_config_number_of_notifiers(handle)

Returns how many notifier ports are currently connected.

# Safety

* The `handle` must be valid and obtained by [[`iox2_service_builder_event_open`](@ref)](crate::[`iox2_service_builder_event_open`](@ref)) or [[`iox2_service_builder_event_open_or_create`](@ref)](crate::[`iox2_service_builder_event_open_or_create`](@ref))!

### Prototype
```c
size_t iox2_port_factory_event_dynamic_config_number_of_notifiers(iox2_port_factory_event_h_ref handle);
```
"""
function iox2_port_factory_event_dynamic_config_number_of_notifiers(handle)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_event_dynamic_config_number_of_notifiers(handle::iox2_port_factory_event_h_ref)::Csize_t
end

"""
    iox2_port_factory_event_service_id(handle, buffer, buffer_len)

Stores the service id in the provided buffer

# Safety

* The `handle` must be valid and obtained by [[`iox2_service_builder_event_open`](@ref)](crate::[`iox2_service_builder_event_open`](@ref)) or [[`iox2_service_builder_event_open_or_create`](@ref)](crate::[`iox2_service_builder_event_open_or_create`](@ref))! * `buffer` must be non-zero and point to a valid memory location * `buffer_len` must define the actual size of the memory location `buffer` is pointing to

### Prototype
```c
void iox2_port_factory_event_service_id(iox2_port_factory_event_h_ref handle, char *buffer, size_t buffer_len);
```
"""
function iox2_port_factory_event_service_id(handle, buffer, buffer_len)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_event_service_id(handle::iox2_port_factory_event_h_ref, buffer::Cstring, buffer_len::Csize_t)::Cvoid
end

"""
    iox2_port_factory_event_nodes(handle, callback, callback_ctx)

Calls the callback repeatedly with an [[`iox2_node_state_e`](@ref)](crate::api::[`iox2_node_state_e`](@ref)), [[`iox2_node_id_ptr`](@ref)](crate::api::[`iox2_node_id_ptr`](@ref)), [´[`iox2_node_name_ptr`](@ref)´](crate::api::[`iox2_node_name_ptr`](@ref)) and [[`iox2_config_ptr`](@ref)](crate::api::[`iox2_config_ptr`](@ref)) for all [`Node`](iceoryx2::node::Node)s that have opened the service.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_node_list_failure_e`](@ref)](crate::api::[`iox2_node_list_failure_e`](@ref)) otherwise.

# Safety

* The `handle` must be valid and obtained by [[`iox2_service_builder_pub_sub_open`](@ref)](crate::[`iox2_service_builder_pub_sub_open`](@ref)) or [[`iox2_service_builder_pub_sub_open_or_create`](@ref)](crate::[`iox2_service_builder_pub_sub_open_or_create`](@ref))! * `callback` - A valid callback with [[`iox2_node_list_callback`](@ref)] signature * `callback_ctx` - An optional callback context [[`iox2_callback_context`](@ref)] to e.g. store information across callback iterations

### Prototype
```c
int iox2_port_factory_event_nodes(iox2_port_factory_event_h_ref handle, iox2_node_list_callback callback, iox2_callback_context callback_ctx);
```
"""
function iox2_port_factory_event_nodes(handle, callback, callback_ctx)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_event_nodes(handle::iox2_port_factory_event_h_ref, callback::iox2_node_list_callback, callback_ctx::iox2_callback_context)::Cint
end

"""
    iox2_port_factory_event_dynamic_config_list_listeners(handle, callback, callback_ctx)

Calls the callback repeatedly for every connected [[`iox2_listener_h`](@ref)](crate::[`iox2_listener_h`](@ref)) and provides all communcation details with a [[`iox2_listener_details_ptr`](@ref)].

# Safety

* [[`iox2_listener_details_ptr`](@ref)] - Provides a view to the listener details. Data must not be accessed outside of the callback. * `callback` - A valid callback with [[`iox2_list_listeners_callback`](@ref)] signature * `callback_ctx` - An optional callback context [[`iox2_callback_context`](@ref)] to e.g. store information across callback iterations. Must be either `NULL` or point to a valid memory location

### Prototype
```c
void iox2_port_factory_event_dynamic_config_list_listeners(iox2_port_factory_event_h_ref handle, iox2_list_listeners_callback callback, iox2_callback_context callback_ctx);
```
"""
function iox2_port_factory_event_dynamic_config_list_listeners(handle, callback, callback_ctx)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_event_dynamic_config_list_listeners(handle::iox2_port_factory_event_h_ref, callback::iox2_list_listeners_callback, callback_ctx::iox2_callback_context)::Cvoid
end

"""
    iox2_port_factory_event_dynamic_config_list_notifiers(handle, callback, callback_ctx)

Calls the callback repeatedly for every connected [[`iox2_notifier_h`](@ref)](crate::[`iox2_notifier_h`](@ref)) and provides all communcation details with a [[`iox2_notifier_details_ptr`](@ref)].

# Safety

* [[`iox2_notifier_details_ptr`](@ref)] - Provides a view to the notifier details. Data must not be accessed outside of the callback. * `callback` - A valid callback with [[`iox2_list_notifiers_callback`](@ref)] signature * `callback_ctx` - An optional callback context [[`iox2_callback_context`](@ref)] to e.g. store information across callback iterations. Must be either `NULL` or point to a valid memory location

### Prototype
```c
void iox2_port_factory_event_dynamic_config_list_notifiers(iox2_port_factory_event_h_ref handle, iox2_list_notifiers_callback callback, iox2_callback_context callback_ctx);
```
"""
function iox2_port_factory_event_dynamic_config_list_notifiers(handle, callback, callback_ctx)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_event_dynamic_config_list_notifiers(handle::iox2_port_factory_event_h_ref, callback::iox2_list_notifiers_callback, callback_ctx::iox2_callback_context)::Cvoid
end

"""
    iox2_port_factory_event_drop(port_factory_handle)

This function needs to be called to destroy the port factory!

# Arguments

* `port_factory_handle` - A valid [[`iox2_port_factory_event_h`](@ref)]

# Safety

* The `port_factory_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_port_factory_event_t`](@ref)] can be re-used with a call to [[`iox2_service_builder_event_open_or_create`](@ref)](crate::[`iox2_service_builder_event_open_or_create`](@ref)) or [[`iox2_service_builder_event_open`](@ref)](crate::[`iox2_service_builder_event_open`](@ref))!

### Prototype
```c
void iox2_port_factory_event_drop(iox2_port_factory_event_h port_factory_handle);
```
"""
function iox2_port_factory_event_drop(port_factory_handle)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_event_drop(port_factory_handle::iox2_port_factory_event_h)::Cvoid
end

"""
    iox2_listener_create_error_string(error)

Returns a string literal describing the provided [[`iox2_listener_create_error_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_listener_create_error_string(enum iox2_listener_create_error_e error);
```
"""
function iox2_listener_create_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_listener_create_error_string(error::iox2_listener_create_error_e)::Cstring
end

"""
    iox2_port_factory_listener_builder_create(port_factory_handle, listener_struct_ptr, listener_handle_ptr)

Creates a listener and consumes the builder

# Arguments

* `port_factory_handle` - Must be a valid [[`iox2_port_factory_listener_builder_h`](@ref)] obtained by [[`iox2_port_factory_event_notifier_builder`](@ref)](crate::[`iox2_port_factory_event_listener_builder`](@ref)). * `listener_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_listener_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `listener_handle_ptr` - An uninitialized or dangling [[`iox2_listener_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_listener_create_error_e`](@ref)] otherwise.

# Safety

* The `port_factory_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_port_factory_listener_builder_t`](@ref)](crate::[`iox2_port_factory_listener_builder_t`](@ref)) can be re-used with a call to [[`iox2_port_factory_event_listener_builder`](@ref)](crate::[`iox2_port_factory_event_listener_builder`](@ref))!

### Prototype
```c
int iox2_port_factory_listener_builder_create(iox2_port_factory_listener_builder_h port_factory_handle, struct iox2_listener_t *listener_struct_ptr, iox2_listener_h *listener_handle_ptr);
```
"""
function iox2_port_factory_listener_builder_create(port_factory_handle, listener_struct_ptr, listener_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_listener_builder_create(port_factory_handle::iox2_port_factory_listener_builder_h, listener_struct_ptr::Ptr{iox2_listener_t}, listener_handle_ptr::Ptr{iox2_listener_h})::Cint
end

"""
    iox2_notifier_create_error_string(error)

Returns a string literal describing the provided [[`iox2_notifier_create_error_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_notifier_create_error_string(enum iox2_notifier_create_error_e error);
```
"""
function iox2_notifier_create_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_notifier_create_error_string(error::iox2_notifier_create_error_e)::Cstring
end

"""
    iox2_port_factory_notifier_builder_set_default_event_id(port_factory_handle, value)

Sets the default event id for the builder

# Arguments

* `port_factory_handle` - Must be a valid [[`iox2_port_factory_notifier_builder_h_ref`](@ref)] obtained by [[`iox2_port_factory_event_notifier_builder`](@ref)](crate::[`iox2_port_factory_event_notifier_builder`](@ref)). * `value` - The value to set the default event id to

# Safety

* `port_factory_handle` must be valid handles * `value` must not be a NULL pointer but a pointer to an initialized [`iox2_event_id_t`](@ref)

### Prototype
```c
void iox2_port_factory_notifier_builder_set_default_event_id(iox2_port_factory_notifier_builder_h_ref port_factory_handle, const struct iox2_event_id_t *value);
```
"""
function iox2_port_factory_notifier_builder_set_default_event_id(port_factory_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_notifier_builder_set_default_event_id(port_factory_handle::iox2_port_factory_notifier_builder_h_ref, value::Ptr{iox2_event_id_t})::Cvoid
end

"""
    iox2_port_factory_notifier_builder_create(port_factory_handle, notifier_struct_ptr, notifier_handle_ptr)

Creates a notifier and consumes the builder

# Arguments

* `port_factory_handle` - Must be a valid [[`iox2_port_factory_notifier_builder_h`](@ref)] obtained by [[`iox2_port_factory_event_notifier_builder`](@ref)](crate::[`iox2_port_factory_event_notifier_builder`](@ref)). * `notifier_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_notifier_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `notifier_handle_ptr` - An uninitialized or dangling [[`iox2_notifier_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_notifier_create_error_e`](@ref)] otherwise.

# Safety

* The `port_factory_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_port_factory_notifier_builder_t`](@ref)] can be re-used with a call to [[`iox2_port_factory_event_notifier_builder`](@ref)](crate::[`iox2_port_factory_event_notifier_builder`](@ref))!

### Prototype
```c
int iox2_port_factory_notifier_builder_create(iox2_port_factory_notifier_builder_h port_factory_handle, struct iox2_notifier_t *notifier_struct_ptr, iox2_notifier_h *notifier_handle_ptr);
```
"""
function iox2_port_factory_notifier_builder_create(port_factory_handle, notifier_struct_ptr, notifier_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_notifier_builder_create(port_factory_handle::iox2_port_factory_notifier_builder_h, notifier_struct_ptr::Ptr{iox2_notifier_t}, notifier_handle_ptr::Ptr{iox2_notifier_h})::Cint
end

"""
    iox2_port_factory_pub_sub_publisher_builder(port_factory_handle, publisher_builder_struct_ptr)

Instantiates a [[`iox2_port_factory_publisher_builder_h`](@ref)] to build a publisher.

# Arguments

* `port_factory_handle` - Must be a valid [[`iox2_port_factory_pub_sub_h_ref`](@ref)] obtained by e.g. [[`iox2_service_builder_pub_sub_open_or_create`](@ref)](crate::[`iox2_service_builder_pub_sub_open_or_create`](@ref)). * `publisher_builder_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_publisher_builder_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap.

Returns the [`iox2_port_factory_publisher_builder_h`](@ref) handle for the publisher builder.

# Safety

* The `port_factory_handle` is still valid after the return of this function and can be use in another function call.

### Prototype
```c
iox2_port_factory_publisher_builder_h iox2_port_factory_pub_sub_publisher_builder(iox2_port_factory_pub_sub_h_ref port_factory_handle, struct iox2_port_factory_publisher_builder_t *publisher_builder_struct_ptr);
```
"""
function iox2_port_factory_pub_sub_publisher_builder(port_factory_handle, publisher_builder_struct_ptr)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_pub_sub_publisher_builder(port_factory_handle::iox2_port_factory_pub_sub_h_ref, publisher_builder_struct_ptr::Ptr{iox2_port_factory_publisher_builder_t})::iox2_port_factory_publisher_builder_h
end

"""
    iox2_port_factory_pub_sub_subscriber_builder(port_factory_handle, subscriber_builder_struct_ptr)

Instantiates a [[`iox2_port_factory_subscriber_builder_h`](@ref)] to build a subscriber.

# Arguments

* `port_factory_handle` - Must be a valid [[`iox2_port_factory_pub_sub_h_ref`](@ref)] obtained by e.g. [[`iox2_service_builder_pub_sub_open_or_create`](@ref)](crate::[`iox2_service_builder_pub_sub_open_or_create`](@ref)). * `subscriber_builder_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_subscriber_builder_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap.

Returns the [[`iox2_port_factory_subscriber_builder_h`](@ref)] handle for the subscriber builder.

# Safety

* The `port_factory_handle` is still valid after the return of this function and can be use in another function call.

### Prototype
```c
iox2_port_factory_subscriber_builder_h iox2_port_factory_pub_sub_subscriber_builder(iox2_port_factory_pub_sub_h_ref port_factory_handle, struct iox2_port_factory_subscriber_builder_t *subscriber_builder_struct_ptr);
```
"""
function iox2_port_factory_pub_sub_subscriber_builder(port_factory_handle, subscriber_builder_struct_ptr)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_pub_sub_subscriber_builder(port_factory_handle::iox2_port_factory_pub_sub_h_ref, subscriber_builder_struct_ptr::Ptr{iox2_port_factory_subscriber_builder_t})::iox2_port_factory_subscriber_builder_h
end

"""
    iox2_port_factory_pub_sub_attributes(port_factory_handle)

Returnes the services attributes.

# Safety

* The `port_factory_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The `port_factory_handle` must live longer than the returned `iox2_attribute_set_h_ref`.

### Prototype
```c
iox2_attribute_set_ptr iox2_port_factory_pub_sub_attributes(iox2_port_factory_pub_sub_h_ref port_factory_handle);
```
"""
function iox2_port_factory_pub_sub_attributes(port_factory_handle)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_pub_sub_attributes(port_factory_handle::iox2_port_factory_pub_sub_h_ref)::iox2_attribute_set_ptr
end

"""
    iox2_port_factory_pub_sub_static_config(port_factory_handle, static_config)

Set the values in the provided [[`iox2_static_config_publish_subscribe_t`](@ref)] pointer.

# Safety

* The `_handle` must be valid and obtained by [[`iox2_service_builder_pub_sub_open`](@ref)](crate::[`iox2_service_builder_pub_sub_open`](@ref)) or [[`iox2_service_builder_pub_sub_open_or_create`](@ref)](crate::[`iox2_service_builder_pub_sub_open_or_create`](@ref))! * The `static_config` must be a valid pointer and non-null.

### Prototype
```c
void iox2_port_factory_pub_sub_static_config(iox2_port_factory_pub_sub_h_ref port_factory_handle, struct iox2_static_config_publish_subscribe_t *static_config);
```
"""
function iox2_port_factory_pub_sub_static_config(port_factory_handle, static_config)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_pub_sub_static_config(port_factory_handle::iox2_port_factory_pub_sub_h_ref, static_config::Ptr{iox2_static_config_publish_subscribe_t})::Cvoid
end

"""
    iox2_port_factory_pub_sub_dynamic_config_number_of_publishers(handle)

Returns how many publisher ports are currently connected.

# Safety

* The `handle` must be valid and obtained by [[`iox2_service_builder_pub_sub_open`](@ref)](crate::[`iox2_service_builder_pub_sub_open`](@ref)) or [[`iox2_service_builder_pub_sub_open_or_create`](@ref)](crate::[`iox2_service_builder_pub_sub_open_or_create`](@ref))!

### Prototype
```c
size_t iox2_port_factory_pub_sub_dynamic_config_number_of_publishers(iox2_port_factory_pub_sub_h_ref handle);
```
"""
function iox2_port_factory_pub_sub_dynamic_config_number_of_publishers(handle)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_pub_sub_dynamic_config_number_of_publishers(handle::iox2_port_factory_pub_sub_h_ref)::Csize_t
end

"""
    iox2_port_factory_pub_sub_nodes(handle, callback, callback_ctx)

Calls the callback repeatedly with an [[`iox2_node_state_e`](@ref)](crate::api::[`iox2_node_state_e`](@ref)), [[`iox2_node_id_ptr`](@ref)](crate::api::[`iox2_node_id_ptr`](@ref)), [´[`iox2_node_name_ptr`](@ref)´](crate::api::[`iox2_node_name_ptr`](@ref)) and [[`iox2_config_ptr`](@ref)](crate::api::[`iox2_config_ptr`](@ref)) for all [`Node`](iceoryx2::node::Node)s that have opened the service.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_node_list_failure_e`](@ref)](crate::api::[`iox2_node_list_failure_e`](@ref)) otherwise.

# Safety

* The `handle` must be valid and obtained by [[`iox2_service_builder_pub_sub_open`](@ref)](crate::[`iox2_service_builder_pub_sub_open`](@ref)) or [[`iox2_service_builder_pub_sub_open_or_create`](@ref)](crate::[`iox2_service_builder_pub_sub_open_or_create`](@ref))! * `callback` - A valid callback with [[`iox2_node_list_callback`](@ref)} signature * `callback_ctx` - An optional callback context [[`iox2_callback_context`](@ref)} to e.g. store information across callback iterations

### Prototype
```c
int iox2_port_factory_pub_sub_nodes(iox2_port_factory_pub_sub_h_ref handle, iox2_node_list_callback callback, iox2_callback_context callback_ctx);
```
"""
function iox2_port_factory_pub_sub_nodes(handle, callback, callback_ctx)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_pub_sub_nodes(handle::iox2_port_factory_pub_sub_h_ref, callback::iox2_node_list_callback, callback_ctx::iox2_callback_context)::Cint
end

"""
    iox2_port_factory_pub_sub_service_name(handle)

Returns the [[`iox2_service_name_ptr`](@ref)], an immutable pointer to the service name.

# Safety

* The `handle` must be valid and obtained by [[`iox2_service_builder_pub_sub_open`](@ref)](crate::[`iox2_service_builder_pub_sub_open`](@ref)) or [[`iox2_service_builder_pub_sub_open_or_create`](@ref)](crate::[`iox2_service_builder_pub_sub_open_or_create`](@ref))!

### Prototype
```c
iox2_service_name_ptr iox2_port_factory_pub_sub_service_name(iox2_port_factory_pub_sub_h_ref handle);
```
"""
function iox2_port_factory_pub_sub_service_name(handle)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_pub_sub_service_name(handle::iox2_port_factory_pub_sub_h_ref)::iox2_service_name_ptr
end

"""
    iox2_port_factory_pub_sub_service_id(handle, buffer, buffer_len)

Stores the service id in the provided buffer

# Safety

* The `handle` must be valid and obtained by [[`iox2_service_builder_pub_sub_open`](@ref)](crate::[`iox2_service_builder_pub_sub_open`](@ref)) or [[`iox2_service_builder_pub_sub_open_or_create`](@ref)](crate::[`iox2_service_builder_pub_sub_open_or_create`](@ref))! * `buffer` must be non-zero and point to a valid memory location * `buffer_len` must define the actual size of the memory location `buffer` is pointing to

### Prototype
```c
void iox2_port_factory_pub_sub_service_id(iox2_port_factory_pub_sub_h_ref handle, char *buffer, size_t buffer_len);
```
"""
function iox2_port_factory_pub_sub_service_id(handle, buffer, buffer_len)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_pub_sub_service_id(handle::iox2_port_factory_pub_sub_h_ref, buffer::Cstring, buffer_len::Csize_t)::Cvoid
end

"""
    iox2_port_factory_pub_sub_dynamic_config_number_of_subscribers(handle)

Returns how many subscriber ports are currently connected.

# Safety

* The `handle` must be valid and obtained by [[`iox2_service_builder_pub_sub_open`](@ref)](crate::[`iox2_service_builder_pub_sub_open`](@ref)) or [[`iox2_service_builder_pub_sub_open_or_create`](@ref)](crate::[`iox2_service_builder_pub_sub_open_or_create`](@ref))!

### Prototype
```c
size_t iox2_port_factory_pub_sub_dynamic_config_number_of_subscribers(iox2_port_factory_pub_sub_h_ref handle);
```
"""
function iox2_port_factory_pub_sub_dynamic_config_number_of_subscribers(handle)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_pub_sub_dynamic_config_number_of_subscribers(handle::iox2_port_factory_pub_sub_h_ref)::Csize_t
end

"""
    iox2_port_factory_pub_sub_dynamic_config_list_subscribers(handle, callback, callback_ctx)

Calls the callback repeatedly for every connected [[`iox2_subscriber_h`](@ref)](crate::[`iox2_subscriber_h`](@ref)) and provides all communcation details with a [[`iox2_subscriber_details_ptr`](@ref)].

# Safety

* [[`iox2_subscriber_details_ptr`](@ref)] - Provides a view to the subscriber details. Data must not be accessed outside of the callback. * `callback` - A valid callback with [[`iox2_list_subscribers_callback`](@ref)] signature * `callback_ctx` - An optional callback context [[`iox2_callback_context`](@ref)] to e.g. store information across callback iterations. Must be either `NULL` or point to a valid memory location

### Prototype
```c
void iox2_port_factory_pub_sub_dynamic_config_list_subscribers(iox2_port_factory_pub_sub_h_ref handle, iox2_list_subscribers_callback callback, iox2_callback_context callback_ctx);
```
"""
function iox2_port_factory_pub_sub_dynamic_config_list_subscribers(handle, callback, callback_ctx)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_pub_sub_dynamic_config_list_subscribers(handle::iox2_port_factory_pub_sub_h_ref, callback::iox2_list_subscribers_callback, callback_ctx::iox2_callback_context)::Cvoid
end

"""
    iox2_port_factory_pub_sub_dynamic_config_list_publishers(handle, callback, callback_ctx)

Calls the callback repeatedly for every connected [[`iox2_publisher_h`](@ref)](crate::[`iox2_publisher_h`](@ref)) and provides all communcation details with a [[`iox2_publisher_details_ptr`](@ref)].

# Safety

* [[`iox2_publisher_details_ptr`](@ref)] - Provides a view to the publisher details. Data must not be accessed outside of the callback. * `callback` - A valid callback with [[`iox2_list_publishers_callback`](@ref)] signature * `callback_ctx` - An optional callback context [[`iox2_callback_context`](@ref)] to e.g. store information across callback iterations. Must be either `NULL` or point to a valid memory location

### Prototype
```c
void iox2_port_factory_pub_sub_dynamic_config_list_publishers(iox2_port_factory_pub_sub_h_ref handle, iox2_list_publishers_callback callback, iox2_callback_context callback_ctx);
```
"""
function iox2_port_factory_pub_sub_dynamic_config_list_publishers(handle, callback, callback_ctx)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_pub_sub_dynamic_config_list_publishers(handle::iox2_port_factory_pub_sub_h_ref, callback::iox2_list_publishers_callback, callback_ctx::iox2_callback_context)::Cvoid
end

"""
    iox2_port_factory_pub_sub_drop(port_factory_handle)

This function needs to be called to destroy the port factory!

# Arguments

* `port_factory_handle` - A valid [[`iox2_port_factory_pub_sub_h`](@ref)]

# Safety

* The `port_factory_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_port_factory_pub_sub_t`](@ref)] can be re-used with a call to [[`iox2_service_builder_pub_sub_open_or_create`](@ref)](crate::[`iox2_service_builder_pub_sub_open_or_create`](@ref)) or [[`iox2_service_builder_pub_sub_open`](@ref)](crate::[`iox2_service_builder_pub_sub_open`](@ref))!

### Prototype
```c
void iox2_port_factory_pub_sub_drop(iox2_port_factory_pub_sub_h port_factory_handle);
```
"""
function iox2_port_factory_pub_sub_drop(port_factory_handle)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_pub_sub_drop(port_factory_handle::iox2_port_factory_pub_sub_h)::Cvoid
end

"""
    iox2_publisher_create_error_string(error)

Returns a string literal describing the provided [[`iox2_publisher_create_error_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_publisher_create_error_string(enum iox2_publisher_create_error_e error);
```
"""
function iox2_publisher_create_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_publisher_create_error_string(error::iox2_publisher_create_error_e)::Cstring
end

"""
    iox2_port_factory_publisher_builder_set_allocation_strategy(port_factory_handle, value)

Sets the [[`iox2_allocation_strategy_e`](@ref)] for the publisher

# Arguments

* `port_factory_handle` - Must be a valid [[`iox2_port_factory_publisher_builder_h_ref`](@ref)] obtained by [[`iox2_port_factory_pub_sub_publisher_builder`](@ref)](crate::[`iox2_port_factory_pub_sub_publisher_builder`](@ref)). * `value` - The value to set max slice length to

# Safety

* `port_factory_handle` must be valid handles

### Prototype
```c
void iox2_port_factory_publisher_builder_set_allocation_strategy(iox2_port_factory_publisher_builder_h_ref port_factory_handle, enum iox2_allocation_strategy_e value);
```
"""
function iox2_port_factory_publisher_builder_set_allocation_strategy(port_factory_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_publisher_builder_set_allocation_strategy(port_factory_handle::iox2_port_factory_publisher_builder_h_ref, value::iox2_allocation_strategy_e)::Cvoid
end

"""
    iox2_port_factory_publisher_builder_set_initial_max_slice_len(port_factory_handle, value)

Sets the max slice length for the publisher

# Arguments

* `port_factory_handle` - Must be a valid [[`iox2_port_factory_publisher_builder_h_ref`](@ref)] obtained by [[`iox2_port_factory_pub_sub_publisher_builder`](@ref)](crate::[`iox2_port_factory_pub_sub_publisher_builder`](@ref)). * `value` - The value to set max slice length to

# Safety

* `port_factory_handle` must be valid handles

### Prototype
```c
void iox2_port_factory_publisher_builder_set_initial_max_slice_len(iox2_port_factory_publisher_builder_h_ref port_factory_handle, c_size_t value);
```
"""
function iox2_port_factory_publisher_builder_set_initial_max_slice_len(port_factory_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_publisher_builder_set_initial_max_slice_len(port_factory_handle::iox2_port_factory_publisher_builder_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_port_factory_publisher_builder_set_max_loaned_samples(port_factory_handle, value)

Sets the max loaned samples for the publisher

# Arguments

* `port_factory_handle` - Must be a valid [[`iox2_port_factory_publisher_builder_h_ref`](@ref)] obtained by [[`iox2_port_factory_pub_sub_publisher_builder`](@ref)](crate::[`iox2_port_factory_pub_sub_publisher_builder`](@ref)). * `value` - The value to set max loaned samples to

# Safety

* `port_factory_handle` must be valid handles

### Prototype
```c
void iox2_port_factory_publisher_builder_set_max_loaned_samples(iox2_port_factory_publisher_builder_h_ref port_factory_handle, c_size_t value);
```
"""
function iox2_port_factory_publisher_builder_set_max_loaned_samples(port_factory_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_publisher_builder_set_max_loaned_samples(port_factory_handle::iox2_port_factory_publisher_builder_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_port_factory_publisher_builder_unable_to_deliver_strategy(port_factory_handle, value)

Sets the unable to deliver strategy for the publisher

# Arguments

* `port_factory_handle` - Must be a valid [[`iox2_port_factory_publisher_builder_h_ref`](@ref)] obtained by [[`iox2_port_factory_pub_sub_publisher_builder`](@ref)](crate::[`iox2_port_factory_pub_sub_publisher_builder`](@ref)). * `value` - The value to set the strategy to

# Safety

* `port_factory_handle` must be valid handles

### Prototype
```c
void iox2_port_factory_publisher_builder_unable_to_deliver_strategy(iox2_port_factory_publisher_builder_h_ref port_factory_handle, enum iox2_unable_to_deliver_strategy_e value);
```
"""
function iox2_port_factory_publisher_builder_unable_to_deliver_strategy(port_factory_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_publisher_builder_unable_to_deliver_strategy(port_factory_handle::iox2_port_factory_publisher_builder_h_ref, value::iox2_unable_to_deliver_strategy_e)::Cvoid
end

"""
    iox2_port_factory_publisher_builder_create(port_factory_handle, publisher_struct_ptr, publisher_handle_ptr)

Creates a publisher and consumes the builder

# Arguments

* `port_factory_handle` - Must be a valid [[`iox2_port_factory_publisher_builder_h`](@ref)] obtained by [[`iox2_port_factory_pub_sub_publisher_builder`](@ref)](crate::[`iox2_port_factory_pub_sub_publisher_builder`](@ref)). * `publisher_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_publisher_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `publisher_handle_ptr` - An uninitialized or dangling [[`iox2_publisher_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_publisher_create_error_e`](@ref)] otherwise.

# Safety

* The `port_factory_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_port_factory_publisher_builder_t`](@ref)] can be re-used with a call to [[`iox2_port_factory_pub_sub_publisher_builder`](@ref)](crate::[`iox2_port_factory_pub_sub_publisher_builder`](@ref))!

### Prototype
```c
int iox2_port_factory_publisher_builder_create(iox2_port_factory_publisher_builder_h port_factory_handle, struct iox2_publisher_t *publisher_struct_ptr, iox2_publisher_h *publisher_handle_ptr);
```
"""
function iox2_port_factory_publisher_builder_create(port_factory_handle, publisher_struct_ptr, publisher_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_publisher_builder_create(port_factory_handle::iox2_port_factory_publisher_builder_h, publisher_struct_ptr::Ptr{iox2_publisher_t}, publisher_handle_ptr::Ptr{iox2_publisher_h})::Cint
end

"""
    iox2_reader_create_error_string(error)

Returns a string literal describing the provided [[`iox2_reader_create_error_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_reader_create_error_string(enum iox2_reader_create_error_e error);
```
"""
function iox2_reader_create_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_reader_create_error_string(error::iox2_reader_create_error_e)::Cstring
end

"""
    iox2_port_factory_reader_builder_create(port_factory_handle, reader_struct_ptr, reader_handle_ptr)

Creates a reader and consumes the builder

# Arguments

* `port_factory_handle` - Must be a valid [[`iox2_port_factory_reader_builder_h`](@ref)] obtained by [[`iox2_port_factory_blackboard_reader_builder`](@ref)](crate::[`iox2_port_factory_blackboard_reader_builder`](@ref)). * `reader_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_reader_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `reader_handle_ptr` - An uninitialized or dangling [[`iox2_reader_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_reader_create_error_e`](@ref)] otherwise.

# Safety

* The `port_factory_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_port_factory_reader_builder_t`](@ref)] can be re-used with a call to [[`iox2_port_factory_blackboard_reader_builder`](@ref)](crate::[`iox2_port_factory_blackboard_reader_builder`](@ref))!

### Prototype
```c
int iox2_port_factory_reader_builder_create(iox2_port_factory_reader_builder_h port_factory_handle, struct iox2_reader_t *reader_struct_ptr, iox2_reader_h *reader_handle_ptr);
```
"""
function iox2_port_factory_reader_builder_create(port_factory_handle, reader_struct_ptr, reader_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_reader_builder_create(port_factory_handle::iox2_port_factory_reader_builder_h, reader_struct_ptr::Ptr{iox2_reader_t}, reader_handle_ptr::Ptr{iox2_reader_h})::Cint
end

"""
    iox2_port_factory_request_response_server_builder(port_factory_handle, builder_struct_ptr)

Instantiates a [[`iox2_port_factory_server_builder_h`](@ref)] to build a server.

# Arguments

* `port_factory_handle` - Must be a valid [[`iox2_port_factory_request_response_h_ref`](@ref)] obtained by e.g. [[`iox2_service_builder_request_response_open_or_create`](@ref)](crate::[`iox2_service_builder_request_response_open_or_create`](@ref)). * `builder_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_server_builder_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap.

Returns the [`iox2_port_factory_server_builder_h`](@ref) handle for the server builder.

# Safety

* The `port_factory_handle` is still valid after the return of this function and can be used in another function call.

### Prototype
```c
iox2_port_factory_server_builder_h iox2_port_factory_request_response_server_builder(iox2_port_factory_request_response_h_ref port_factory_handle, struct iox2_port_factory_server_builder_t *builder_struct_ptr);
```
"""
function iox2_port_factory_request_response_server_builder(port_factory_handle, builder_struct_ptr)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_request_response_server_builder(port_factory_handle::iox2_port_factory_request_response_h_ref, builder_struct_ptr::Ptr{iox2_port_factory_server_builder_t})::iox2_port_factory_server_builder_h
end

"""
    iox2_port_factory_request_response_client_builder(port_factory_handle, builder_struct_ptr)

Instantiates a [[`iox2_port_factory_client_builder_h`](@ref)] to build a client.

# Arguments

* `port_factory_handle` - Must be a valid [[`iox2_port_factory_request_response_h_ref`](@ref)] obtained by e.g. [[`iox2_service_builder_request_response_open_or_create`](@ref)](crate::[`iox2_service_builder_request_response_open_or_create`](@ref)). * `builder_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_client_builder_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap.

Returns the [`iox2_port_factory_client_builder_h`](@ref) handle for the client builder.

# Safety

* The `port_factory_handle` is still valid after the return of this function and can be used in another function call.

### Prototype
```c
iox2_port_factory_client_builder_h iox2_port_factory_request_response_client_builder(iox2_port_factory_request_response_h_ref port_factory_handle, struct iox2_port_factory_client_builder_t *builder_struct_ptr);
```
"""
function iox2_port_factory_request_response_client_builder(port_factory_handle, builder_struct_ptr)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_request_response_client_builder(port_factory_handle::iox2_port_factory_request_response_h_ref, builder_struct_ptr::Ptr{iox2_port_factory_client_builder_t})::iox2_port_factory_client_builder_h
end

"""
    iox2_port_factory_request_response_attributes(port_factory_handle)

Returns the services attributes.

# Safety

* The `port_factory_handle` is still valid after the return of this function and can be used in another function call. * The `port_factory_handle` must live longer than the returned `iox2_attribute_set_h_ref`.

### Prototype
```c
iox2_attribute_set_ptr iox2_port_factory_request_response_attributes(iox2_port_factory_request_response_h_ref port_factory_handle);
```
"""
function iox2_port_factory_request_response_attributes(port_factory_handle)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_request_response_attributes(port_factory_handle::iox2_port_factory_request_response_h_ref)::iox2_attribute_set_ptr
end

"""
    iox2_port_factory_request_response_static_config(port_factory_handle, static_config)

Set the values in the provided [[`iox2_static_config_request_response_t`](@ref)] pointer.

# Safety

* The `port_factory_handle` must be valid and obtained by [[`iox2_service_builder_request_response_open`](@ref)](crate::[`iox2_service_builder_request_response_open`](@ref)) or [[`iox2_service_builder_request_response_open_or_create`](@ref)](crate::[`iox2_service_builder_request_response_open_or_create`](@ref))! * The `static_config` must be a valid pointer and non-null.

### Prototype
```c
void iox2_port_factory_request_response_static_config(iox2_port_factory_request_response_h_ref port_factory_handle, struct iox2_static_config_request_response_t *static_config);
```
"""
function iox2_port_factory_request_response_static_config(port_factory_handle, static_config)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_request_response_static_config(port_factory_handle::iox2_port_factory_request_response_h_ref, static_config::Ptr{iox2_static_config_request_response_t})::Cvoid
end

"""
    iox2_port_factory_request_response_dynamic_config_number_of_servers(handle)

Returns how many server ports are currently connected.

# Safety

* The `handle` must be valid and obtained by [[`iox2_service_builder_request_response_open`](@ref)](crate::[`iox2_service_builder_request_response_open`](@ref)) or [[`iox2_service_builder_request_response_open_or_create`](@ref)](crate::[`iox2_service_builder_request_response_open_or_create`](@ref))!

### Prototype
```c
size_t iox2_port_factory_request_response_dynamic_config_number_of_servers(iox2_port_factory_request_response_h_ref handle);
```
"""
function iox2_port_factory_request_response_dynamic_config_number_of_servers(handle)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_request_response_dynamic_config_number_of_servers(handle::iox2_port_factory_request_response_h_ref)::Csize_t
end

"""
    iox2_port_factory_request_response_dynamic_config_number_of_clients(handle)

Returns how many client ports are currently connected.

# Safety

* The `handle` must be valid and obtained by [[`iox2_service_builder_request_response_open`](@ref)](crate::[`iox2_service_builder_request_response_open`](@ref)) or [[`iox2_service_builder_request_response_open_or_create`](@ref)](crate::[`iox2_service_builder_request_response_open_or_create`](@ref))!

### Prototype
```c
size_t iox2_port_factory_request_response_dynamic_config_number_of_clients(iox2_port_factory_request_response_h_ref handle);
```
"""
function iox2_port_factory_request_response_dynamic_config_number_of_clients(handle)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_request_response_dynamic_config_number_of_clients(handle::iox2_port_factory_request_response_h_ref)::Csize_t
end

"""
    iox2_port_factory_request_response_nodes(handle, callback, callback_ctx)

Calls the callback repeatedly with an [[`iox2_node_state_e`](@ref)](crate::api::[`iox2_node_state_e`](@ref)), [[`iox2_node_id_ptr`](@ref)](crate::api::[`iox2_node_id_ptr`](@ref)), [´[`iox2_node_name_ptr`](@ref)´](crate::api::[`iox2_node_name_ptr`](@ref)) and [[`iox2_config_ptr`](@ref)](crate::api::[`iox2_config_ptr`](@ref)) for all [`Node`](iceoryx2::node::Node)s that have opened the service.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_node_list_failure_e`](@ref)](crate::api::[`iox2_node_list_failure_e`](@ref)) otherwise.

# Safety

* The `handle` must be valid and obtained by [[`iox2_service_builder_request_response_open`](@ref)](crate::[`iox2_service_builder_request_response_open`](@ref)) or [[`iox2_service_builder_request_response_open_or_create`](@ref)](crate::[`iox2_service_builder_request_response_open_or_create`](@ref))! * `callback` - A valid callback with [[`iox2_node_list_callback`](@ref)} signature * `callback_ctx` - An optional callback context [[`iox2_callback_context`](@ref)} to e.g. store information across callback iterations

### Prototype
```c
int iox2_port_factory_request_response_nodes(iox2_port_factory_request_response_h_ref handle, iox2_node_list_callback callback, iox2_callback_context callback_ctx);
```
"""
function iox2_port_factory_request_response_nodes(handle, callback, callback_ctx)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_request_response_nodes(handle::iox2_port_factory_request_response_h_ref, callback::iox2_node_list_callback, callback_ctx::iox2_callback_context)::Cint
end

"""
    iox2_port_factory_request_response_service_name(handle)

Returns the [[`iox2_service_name_ptr`](@ref)], an immutable pointer to the service name.

# Safety

* The `handle` must be valid and obtained by [[`iox2_service_builder_request_response_open`](@ref)](crate::[`iox2_service_builder_request_response_open`](@ref)) or [[`iox2_service_builder_request_response_open_or_create`](@ref)](crate::[`iox2_service_builder_request_response_open_or_create`](@ref))!

### Prototype
```c
iox2_service_name_ptr iox2_port_factory_request_response_service_name(iox2_port_factory_request_response_h_ref handle);
```
"""
function iox2_port_factory_request_response_service_name(handle)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_request_response_service_name(handle::iox2_port_factory_request_response_h_ref)::iox2_service_name_ptr
end

"""
    iox2_port_factory_request_response_service_id(handle, buffer, buffer_len)

Stores the service id in the provided buffer

# Safety

* The `handle` must be valid and obtained by [[`iox2_service_builder_request_response_open`](@ref)](crate::[`iox2_service_builder_request_response_open`](@ref)) or [[`iox2_service_builder_request_response_open_or_create`](@ref)](crate::[`iox2_service_builder_request_response_open_or_create`](@ref))! * `buffer` must be non-zero and point to a valid memory location * `buffer_len` must define the actual size of the memory location `buffer` is pointing to

### Prototype
```c
void iox2_port_factory_request_response_service_id(iox2_port_factory_request_response_h_ref handle, char *buffer, size_t buffer_len);
```
"""
function iox2_port_factory_request_response_service_id(handle, buffer, buffer_len)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_request_response_service_id(handle::iox2_port_factory_request_response_h_ref, buffer::Cstring, buffer_len::Csize_t)::Cvoid
end

"""
    iox2_port_factory_request_response_dynamic_config_list_servers(handle, callback, callback_ctx)

Calls the callback repeatedly for every connected [[`iox2_server_h`](@ref)](crate::[`iox2_server_h`](@ref)) and provides all communcation details with a [[`iox2_server_details_ptr`](@ref)].

# Safety

* [[`iox2_server_details_ptr`](@ref)] - Provides a view to the server details. Data must not be accessed outside of the callback. * `callback` - A valid callback with [[`iox2_list_servers_callback`](@ref)] signature * `callback_ctx` - An optional callback context [[`iox2_callback_context`](@ref)] to e.g. store information across callback iterations. Must be either `NULL` or point to a valid memory location

### Prototype
```c
void iox2_port_factory_request_response_dynamic_config_list_servers(iox2_port_factory_request_response_h_ref handle, iox2_list_servers_callback callback, iox2_callback_context callback_ctx);
```
"""
function iox2_port_factory_request_response_dynamic_config_list_servers(handle, callback, callback_ctx)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_request_response_dynamic_config_list_servers(handle::iox2_port_factory_request_response_h_ref, callback::iox2_list_servers_callback, callback_ctx::iox2_callback_context)::Cvoid
end

"""
    iox2_port_factory_request_response_dynamic_config_list_clients(handle, callback, callback_ctx)

Calls the callback repeatedly with for every connected [[`iox2_client_h`](@ref)](crate::[`iox2_client_h`](@ref)) and provides all communcation details with a [[`iox2_client_details_ptr`](@ref)].

# Safety

* [[`iox2_client_details_ptr`](@ref)] - Provides a view to the client details. Data must not be accessed outside of the callback. * `callback` - A valid callback with [[`iox2_list_clients_callback`](@ref)] signature * `callback_ctx` - An optional callback context [[`iox2_callback_context`](@ref)] to e.g. store information across callback iterations. Must be either `NULL` or point to a valid memory location

### Prototype
```c
void iox2_port_factory_request_response_dynamic_config_list_clients(iox2_port_factory_request_response_h_ref handle, iox2_list_clients_callback callback, iox2_callback_context callback_ctx);
```
"""
function iox2_port_factory_request_response_dynamic_config_list_clients(handle, callback, callback_ctx)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_request_response_dynamic_config_list_clients(handle::iox2_port_factory_request_response_h_ref, callback::iox2_list_clients_callback, callback_ctx::iox2_callback_context)::Cvoid
end

"""
    iox2_port_factory_request_response_drop(port_factory_handle)

This function needs to be called to destroy the port factory!

# Arguments

* `port_factory_handle` - A valid [[`iox2_port_factory_request_response_h`](@ref)]

# Safety

* The `port_factory_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_port_factory_request_response_t`](@ref)] can be re-used with a call to [[`iox2_service_builder_request_response_open_or_create`](@ref)](crate::[`iox2_service_builder_request_response_open_or_create`](@ref)) or [[`iox2_service_builder_request_response_open`](@ref)](crate::[`iox2_service_builder_request_response_open`](@ref))!

### Prototype
```c
void iox2_port_factory_request_response_drop(iox2_port_factory_request_response_h port_factory_handle);
```
"""
function iox2_port_factory_request_response_drop(port_factory_handle)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_request_response_drop(port_factory_handle::iox2_port_factory_request_response_h)::Cvoid
end

"""
    iox2_server_create_error_string(error)

Returns a string literal describing the provided [[`iox2_server_create_error_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_server_create_error_string(enum iox2_server_create_error_e error);
```
"""
function iox2_server_create_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_server_create_error_string(error::iox2_server_create_error_e)::Cstring
end

"""
    iox2_port_factory_server_builder_set_allocation_strategy(port_factory_handle, value)

Sets the [[`iox2_allocation_strategy_e`](@ref)] for the server

# Arguments

* `port_factory_handle` - Must be a valid [[`iox2_port_factory_server_builder_h_ref`](@ref)] obtained by [[`iox2_port_factory_request_response_server_builder`](@ref)](crate::[`iox2_port_factory_request_response_server_builder`](@ref)). * `value` - The value to set the allocation strategy to

# Safety

* `port_factory_handle` must be valid handles

### Prototype
```c
void iox2_port_factory_server_builder_set_allocation_strategy(iox2_port_factory_server_builder_h_ref port_factory_handle, enum iox2_allocation_strategy_e value);
```
"""
function iox2_port_factory_server_builder_set_allocation_strategy(port_factory_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_server_builder_set_allocation_strategy(port_factory_handle::iox2_port_factory_server_builder_h_ref, value::iox2_allocation_strategy_e)::Cvoid
end

"""
    iox2_port_factory_server_builder_set_initial_max_slice_len(port_factory_handle, value)

Sets the initial max slice length for the server

# Arguments

* `port_factory_handle` - Must be a valid [[`iox2_port_factory_server_builder_h_ref`](@ref)] obtained by [[`iox2_port_factory_request_response_server_builder`](@ref)](crate::[`iox2_port_factory_request_response_server_builder`](@ref)). * `value` - The value to set max slice length to

# Safety

* `port_factory_handle` must be valid handles

### Prototype
```c
void iox2_port_factory_server_builder_set_initial_max_slice_len(iox2_port_factory_server_builder_h_ref port_factory_handle, c_size_t value);
```
"""
function iox2_port_factory_server_builder_set_initial_max_slice_len(port_factory_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_server_builder_set_initial_max_slice_len(port_factory_handle::iox2_port_factory_server_builder_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_port_factory_server_builder_set_max_loaned_responses_per_request(port_factory_handle, value)

Defines how many responses the server can loan per request

# Arguments

* `port_factory_handle` - Must be a valid [[`iox2_port_factory_server_builder_h_ref`](@ref)] obtained by [[`iox2_port_factory_request_response_server_builder`](@ref)](crate::[`iox2_port_factory_request_response_server_builder`](@ref)). * `value` - The value to set max loaned responses to

# Safety

* `port_factory_handle` must be valid handles

### Prototype
```c
void iox2_port_factory_server_builder_set_max_loaned_responses_per_request(iox2_port_factory_server_builder_h_ref port_factory_handle, c_size_t value);
```
"""
function iox2_port_factory_server_builder_set_max_loaned_responses_per_request(port_factory_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_server_builder_set_max_loaned_responses_per_request(port_factory_handle::iox2_port_factory_server_builder_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_port_factory_server_builder_unable_to_deliver_strategy(port_factory_handle, value)

Sets the unable to deliver strategy for the server

# Arguments

* `port_factory_handle` - Must be a valid [[`iox2_port_factory_server_builder_h_ref`](@ref)] obtained by [[`iox2_port_factory_request_response_server_builder`](@ref)](crate::[`iox2_port_factory_request_response_server_builder`](@ref)). * `value` - The value to set the strategy to

# Safety

* `port_factory_handle` must be valid handles

### Prototype
```c
void iox2_port_factory_server_builder_unable_to_deliver_strategy(iox2_port_factory_server_builder_h_ref port_factory_handle, enum iox2_unable_to_deliver_strategy_e value);
```
"""
function iox2_port_factory_server_builder_unable_to_deliver_strategy(port_factory_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_server_builder_unable_to_deliver_strategy(port_factory_handle::iox2_port_factory_server_builder_h_ref, value::iox2_unable_to_deliver_strategy_e)::Cvoid
end

"""
    iox2_port_factory_server_builder_create(port_factory_handle, struct_ptr, handle_ptr)

Creates a server and consumes the builder

# Arguments

* `port_factory_handle` - Must be a valid [[`iox2_port_factory_server_builder_h`](@ref)] obtained by [[`iox2_port_factory_request_response_server_builder`](@ref)](crate::[`iox2_port_factory_request_response_server_builder`](@ref)). * `struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_server_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `handle_ptr` - An uninitialized or dangling [[`iox2_server_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_server_create_error_e`](@ref)] otherwise.

# Safety

* The `port_factory_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_port_factory_server_builder_t`](@ref)] can be re-used with a call to [[`iox2_port_factory_request_response_server_builder`](@ref)](crate::[`iox2_port_factory_request_response_server_builder`](@ref))!

### Prototype
```c
int iox2_port_factory_server_builder_create(iox2_port_factory_server_builder_h port_factory_handle, struct iox2_server_t *struct_ptr, iox2_server_h *handle_ptr);
```
"""
function iox2_port_factory_server_builder_create(port_factory_handle, struct_ptr, handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_server_builder_create(port_factory_handle::iox2_port_factory_server_builder_h, struct_ptr::Ptr{iox2_server_t}, handle_ptr::Ptr{iox2_server_h})::Cint
end

"""
    iox2_subscriber_create_error_string(error)

Returns a string literal describing the provided [[`iox2_subscriber_create_error_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_subscriber_create_error_string(enum iox2_subscriber_create_error_e error);
```
"""
function iox2_subscriber_create_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_subscriber_create_error_string(error::iox2_subscriber_create_error_e)::Cstring
end

"""
    iox2_port_factory_subscriber_builder_set_buffer_size(port_factory_handle, value)

Sets the buffer size for the subscriber

# Arguments

* `port_factory_handle` - Must be a valid [[`iox2_port_factory_subscriber_builder_h_ref`](@ref)] obtained by [[`iox2_port_factory_pub_sub_subscriber_builder`](@ref)](crate::[`iox2_port_factory_pub_sub_subscriber_builder`](@ref)). * `value` - The value to set buffer size to

# Safety

* `port_factory_handle` must be valid handles

### Prototype
```c
void iox2_port_factory_subscriber_builder_set_buffer_size(iox2_port_factory_subscriber_builder_h_ref port_factory_handle, c_size_t value);
```
"""
function iox2_port_factory_subscriber_builder_set_buffer_size(port_factory_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_subscriber_builder_set_buffer_size(port_factory_handle::iox2_port_factory_subscriber_builder_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_port_factory_subscriber_builder_create(port_factory_handle, subscriber_struct_ptr, subscriber_handle_ptr)

Creates a subscriber and consumes the builder

# Arguments

* `port_factory_handle` - Must be a valid [[`iox2_port_factory_subscriber_builder_h`](@ref)] obtained by [[`iox2_port_factory_pub_sub_subscriber_builder`](@ref)](crate::[`iox2_port_factory_pub_sub_subscriber_builder`](@ref)). * `subscriber_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_subscriber_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `subscriber_handle_ptr` - An uninitialized or dangling [[`iox2_subscriber_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_subscriber_create_error_e`](@ref)] otherwise.

# Safety

* The `port_factory_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_port_factory_subscriber_builder_t`](@ref)] can be re-used with a call to [[`iox2_port_factory_pub_sub_subscriber_builder`](@ref)](crate::[`iox2_port_factory_pub_sub_subscriber_builder`](@ref))!

### Prototype
```c
int iox2_port_factory_subscriber_builder_create(iox2_port_factory_subscriber_builder_h port_factory_handle, struct iox2_subscriber_t *subscriber_struct_ptr, iox2_subscriber_h *subscriber_handle_ptr);
```
"""
function iox2_port_factory_subscriber_builder_create(port_factory_handle, subscriber_struct_ptr, subscriber_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_subscriber_builder_create(port_factory_handle::iox2_port_factory_subscriber_builder_h, subscriber_struct_ptr::Ptr{iox2_subscriber_t}, subscriber_handle_ptr::Ptr{iox2_subscriber_h})::Cint
end

"""
    iox2_writer_create_error_string(error)

Returns a string literal describing the provided [[`iox2_writer_create_error_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_writer_create_error_string(enum iox2_writer_create_error_e error);
```
"""
function iox2_writer_create_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_writer_create_error_string(error::iox2_writer_create_error_e)::Cstring
end

"""
    iox2_port_factory_writer_builder_create(port_factory_handle, writer_struct_ptr, writer_handle_ptr)

Creates a writer and consumes the builder

# Arguments

* `port_factory_handle` - Must be a valid [[`iox2_port_factory_writer_builder_h`](@ref)] obtained by [[`iox2_port_factory_blackboard_writer_builder`](@ref)](crate::[`iox2_port_factory_blackboard_writer_builder`](@ref)). * `writer_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_writer_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `writer_handle_ptr` - An uninitialized or dangling [[`iox2_writer_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_writer_create_error_e`](@ref)] otherwise.

# Safety

* The `port_factory_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_port_factory_writer_builder_t`](@ref)] can be re-used with a call to [[`iox2_port_factory_blackboard_writer_builder`](@ref)](crate::[`iox2_port_factory_blackboard_writer_builder`](@ref))!

### Prototype
```c
int iox2_port_factory_writer_builder_create(iox2_port_factory_writer_builder_h port_factory_handle, struct iox2_writer_t *writer_struct_ptr, iox2_writer_h *writer_handle_ptr);
```
"""
function iox2_port_factory_writer_builder_create(port_factory_handle, writer_struct_ptr, writer_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_port_factory_writer_builder_create(port_factory_handle::iox2_port_factory_writer_builder_h, writer_struct_ptr::Ptr{iox2_writer_t}, writer_handle_ptr::Ptr{iox2_writer_h})::Cint
end

"""
    iox2_publish_subscribe_header_drop(handle)

This function needs to be called to destroy the publish\\_subscribe\\_header!

# Safety

* The `handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_publish_subscribe_header_t`](@ref)] can be re-used

### Prototype
```c
void iox2_publish_subscribe_header_drop(iox2_publish_subscribe_header_h handle);
```
"""
function iox2_publish_subscribe_header_drop(handle)
    @ccall libiceoryx2_ffi_c.iox2_publish_subscribe_header_drop(handle::iox2_publish_subscribe_header_h)::Cvoid
end

"""
    iox2_publish_subscribe_header_publisher_id(header_handle, id_struct_ptr, id_handle_ptr)

Returns the unique publisher id of the source of the sample.

# Arguments

* `handle` is valid, non-null and was initialized with [`[`iox2_sample_header`](@ref)()`](crate::[`iox2_sample_header`](@ref)) * `id_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_unique_publisher_id_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `id_handle_ptr` valid pointer to a [[`iox2_unique_publisher_id_h`](@ref)].

# Safety

* `header_handle` is valid and non-null * `id_struct_ptr` is either null or valid and non-null * `id_handle_ptr` is valid and non-null

### Prototype
```c
void iox2_publish_subscribe_header_publisher_id(iox2_publish_subscribe_header_h_ref header_handle, struct iox2_unique_publisher_id_t *id_struct_ptr, iox2_unique_publisher_id_h *id_handle_ptr);
```
"""
function iox2_publish_subscribe_header_publisher_id(header_handle, id_struct_ptr, id_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_publish_subscribe_header_publisher_id(header_handle::iox2_publish_subscribe_header_h_ref, id_struct_ptr::Ptr{iox2_unique_publisher_id_t}, id_handle_ptr::Ptr{iox2_unique_publisher_id_h})::Cvoid
end

"""
    iox2_publish_subscribe_header_number_of_elements(header_handle)

Returns the number of elements of the payload. The element size is defined via this call when creating a new service [`crate::[`iox2_service_builder_pub_sub_set_payload_type_details`](@ref)()`]. So if the payload is defined with alignment 8 and size 16 and this function returns 5. It means that the payload consists of 5 elements of size 16 and every element is 8 byte aligned. Therefore, the payload pointer points to a memory region with 5 * 16 = 80 bytes.

# Arguments

* `handle` is valid, non-null and was initialized with [`[`iox2_sample_header`](@ref)()`](crate::[`iox2_sample_header`](@ref))

# Safety

* `header_handle` is valid and non-null

### Prototype
```c
uint64_t iox2_publish_subscribe_header_number_of_elements(iox2_publish_subscribe_header_h_ref header_handle);
```
"""
function iox2_publish_subscribe_header_number_of_elements(header_handle)
    @ccall libiceoryx2_ffi_c.iox2_publish_subscribe_header_number_of_elements(header_handle::iox2_publish_subscribe_header_h_ref)::UInt64
end

"""
    iox2_send_error_string(error)

Returns a string literal describing the provided [[`iox2_send_error_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_send_error_string(enum iox2_send_error_e error);
```
"""
function iox2_send_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_send_error_string(error::iox2_send_error_e)::Cstring
end

"""
    iox2_loan_error_string(error)

Returns a string literal describing the provided [[`iox2_loan_error_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_loan_error_string(enum iox2_loan_error_e error);
```
"""
function iox2_loan_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_loan_error_string(error::iox2_loan_error_e)::Cstring
end

"""
    iox2_publisher_unable_to_deliver_strategy(publisher_handle)

Returns the strategy the publisher follows when a sample cannot be delivered since the subscribers buffer is full.

# Arguments

* `handle` obtained by [[`iox2_port_factory_publisher_builder_create`](@ref)](crate::[`iox2_port_factory_publisher_builder_create`](@ref))

Returns [[`iox2_unable_to_deliver_strategy_e`](@ref)].

# Safety

* `publisher_handle` is valid and non-null

### Prototype
```c
enum iox2_unable_to_deliver_strategy_e iox2_publisher_unable_to_deliver_strategy(iox2_publisher_h_ref publisher_handle);
```
"""
function iox2_publisher_unable_to_deliver_strategy(publisher_handle)
    @ccall libiceoryx2_ffi_c.iox2_publisher_unable_to_deliver_strategy(publisher_handle::iox2_publisher_h_ref)::iox2_unable_to_deliver_strategy_e
end

"""
    iox2_publisher_initial_max_slice_len(publisher_handle)

Returns the maximum `[u8]` length that can be loaned in one sample, i.e. the max number of elements in the `[u8]` payload type used by the C binding.

# Arguments

* `publisher_handle` obtained by [[`iox2_port_factory_publisher_builder_create`](@ref)](crate::[`iox2_port_factory_publisher_builder_create`](@ref))

Returns the maximum number of elements as a [[`c_size_t`](@ref)].

# Safety

* `publisher_handle` is valid and non-null

### Prototype
```c
c_size_t iox2_publisher_initial_max_slice_len(iox2_publisher_h_ref publisher_handle);
```
"""
function iox2_publisher_initial_max_slice_len(publisher_handle)
    @ccall libiceoryx2_ffi_c.iox2_publisher_initial_max_slice_len(publisher_handle::iox2_publisher_h_ref)::c_size_t
end

"""
    iox2_publisher_id(publisher_handle, id_struct_ptr, id_handle_ptr)

Returns the unique port id of the publisher.

# Arguments

* `handle` obtained by [[`iox2_port_factory_publisher_builder_create`](@ref)](crate::[`iox2_port_factory_publisher_builder_create`](@ref)) * `id_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_unique_publisher_id_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `id_handle_ptr` valid pointer to a [[`iox2_unique_publisher_id_h`](@ref)].

# Safety

* `publisher_handle` is valid and non-null * `id` is valid and non-null

### Prototype
```c
void iox2_publisher_id(iox2_publisher_h_ref publisher_handle, struct iox2_unique_publisher_id_t *id_struct_ptr, iox2_unique_publisher_id_h *id_handle_ptr);
```
"""
function iox2_publisher_id(publisher_handle, id_struct_ptr, id_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_publisher_id(publisher_handle::iox2_publisher_h_ref, id_struct_ptr::Ptr{iox2_unique_publisher_id_t}, id_handle_ptr::Ptr{iox2_unique_publisher_id_h})::Cvoid
end

"""
    iox2_publisher_send_slice_copy(publisher_handle, data_ptr, size_of_element, number_of_elements, number_of_recipients)

Sends a copy of the provided slice data via the publisher.

# Arguments

* `publisher_handle` - Handle to the publisher obtained from [`iox2_port_factory_publisher_builder_create`](@ref) * `data_ptr` - Pointer to the start of the slice data to be sent * `size_of_element` - Size of each element in the slice in bytes * `number_of_elements` - Number of elements in the slice * `number_of_recipients` - Optional pointer to store the number of subscribers that received the data

# Returns

Returns [`IOX2_OK`](@ref) on success, otherwise an error code from [`iox2_send_error_e`](@ref)

# Safety

* `publisher_handle` must be valid and non-null * `data_ptr` must be a valid pointer to the start of the slice data * `size_of_element` must be the correct size of each element in bytes * `number_of_elements` must accurately represent the number of elements in the slice * `number_of_recipients` can be null, otherwise it must be a valid pointer to a `usize`

### Prototype
```c
int iox2_publisher_send_slice_copy(iox2_publisher_h_ref publisher_handle, const void *data_ptr, size_t size_of_element, size_t number_of_elements, size_t *number_of_recipients);
```
"""
function iox2_publisher_send_slice_copy(publisher_handle, data_ptr, size_of_element, number_of_elements, number_of_recipients)
    @ccall libiceoryx2_ffi_c.iox2_publisher_send_slice_copy(publisher_handle::iox2_publisher_h_ref, data_ptr::Ptr{Cvoid}, size_of_element::Csize_t, number_of_elements::Csize_t, number_of_recipients::Ptr{Csize_t})::Cint
end

"""
    iox2_publisher_send_copy(publisher_handle, data_ptr, data_len, number_of_recipients)

Sends a copy of the provided data via the publisher. The data must be copyable via `memcpy`.

# Arguments

* `handle` obtained by [[`iox2_port_factory_publisher_builder_create`](@ref)](crate::[`iox2_port_factory_publisher_builder_create`](@ref)) * `data_ptr` pointer to the payload that shall be transmitted * `data_len` the size of the payload in bytes * `number_of_recipients` (optional) used to store the number of subscriber that received the data

Return [[`IOX2_OK`](@ref)] on success, otherwise [[`iox2_send_error_e`](@ref)].

# Safety

* `publisher_handle` is valid and non-null * `data_ptr` non-null pointer to a valid position in memory * `data_len` the size of the payload memory * `number_of_recipients` can be null, otherwise a valid pointer to an [`usize`]

### Prototype
```c
int iox2_publisher_send_copy(iox2_publisher_h_ref publisher_handle, const void *data_ptr, size_t data_len, size_t *number_of_recipients);
```
"""
function iox2_publisher_send_copy(publisher_handle, data_ptr, data_len, number_of_recipients)
    @ccall libiceoryx2_ffi_c.iox2_publisher_send_copy(publisher_handle::iox2_publisher_h_ref, data_ptr::Ptr{Cvoid}, data_len::Csize_t, number_of_recipients::Ptr{Csize_t})::Cint
end

"""
    iox2_publisher_loan_slice_uninit(publisher_handle, sample_struct_ptr, sample_handle_ptr, number_of_elements)

Loans memory from the publishers data segment.

# Arguments

* `handle` obtained by [[`iox2_port_factory_publisher_builder_create`](@ref)](crate::[`iox2_port_factory_publisher_builder_create`](@ref)) * `sample_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_sample_mut_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `sample_handle_ptr` - An uninitialized or dangling [[`iox2_sample_mut_h`](@ref)] handle which will be initialized by this function call if a sample is obtained, otherwise it will be set to NULL. * `number_of_bytes` - The number of bytes to loan from the publisher's payload segment

Return [[`IOX2_OK`](@ref)] on success, otherwise [[`iox2_loan_error_e`](@ref)].

# Safety

* `publisher_handle` is valid and non-null * The `sample_handle_ptr` is pointing to a valid [[`iox2_sample_mut_h`](@ref)].

### Prototype
```c
int iox2_publisher_loan_slice_uninit(iox2_publisher_h_ref publisher_handle, struct iox2_sample_mut_t *sample_struct_ptr, iox2_sample_mut_h *sample_handle_ptr, size_t number_of_elements);
```
"""
function iox2_publisher_loan_slice_uninit(publisher_handle, sample_struct_ptr, sample_handle_ptr, number_of_elements)
    @ccall libiceoryx2_ffi_c.iox2_publisher_loan_slice_uninit(publisher_handle::iox2_publisher_h_ref, sample_struct_ptr::Ptr{iox2_sample_mut_t}, sample_handle_ptr::Ptr{iox2_sample_mut_h}, number_of_elements::Csize_t)::Cint
end

"""
    iox2_publisher_update_connections(publisher_handle)

Updates all connections to new and obsolete subscriber ports and automatically delivery the history if requested.

# Arguments

* `publisher_handle` - Must be a valid [[`iox2_publisher_h`](@ref)] obtained by [[`iox2_port_factory_publisher_builder_create`](@ref)](crate::[`iox2_port_factory_publisher_builder_create`](@ref)).

# Safety

* The `publisher_handle` is still valid after the return of this function and can be use in another function call.

### Prototype
```c
int iox2_publisher_update_connections(iox2_publisher_h_ref publisher_handle);
```
"""
function iox2_publisher_update_connections(publisher_handle)
    @ccall libiceoryx2_ffi_c.iox2_publisher_update_connections(publisher_handle::iox2_publisher_h_ref)::Cint
end

"""
    iox2_publisher_drop(publisher_handle)

This function needs to be called to destroy the publisher!

# Arguments

* `publisher_handle` - A valid [[`iox2_publisher_h`](@ref)]

# Safety

* The `publisher_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_publisher_t`](@ref)] can be re-used with a call to [[`iox2_port_factory_publisher_builder_create`](@ref)](crate::[`iox2_port_factory_publisher_builder_create`](@ref))!

### Prototype
```c
void iox2_publisher_drop(iox2_publisher_h publisher_handle);
```
"""
function iox2_publisher_drop(publisher_handle)
    @ccall libiceoryx2_ffi_c.iox2_publisher_drop(publisher_handle::iox2_publisher_h)::Cvoid
end

"""
    iox2_publisher_details_publisher_id(handle, id_struct_ptr, id_handle_ptr)

Returns the unique port id of the publisher.

# Safety

* `handle` valid pointer to the publisher details * `id_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_unique_publisher_id_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `id_handle_ptr` valid pointer to a [[`iox2_unique_publisher_id_h`](@ref)].

### Prototype
```c
void iox2_publisher_details_publisher_id(iox2_publisher_details_ptr handle, struct iox2_unique_publisher_id_t *id_struct_ptr, iox2_unique_publisher_id_h *id_handle_ptr);
```
"""
function iox2_publisher_details_publisher_id(handle, id_struct_ptr, id_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_publisher_details_publisher_id(handle::iox2_publisher_details_ptr, id_struct_ptr::Ptr{iox2_unique_publisher_id_t}, id_handle_ptr::Ptr{iox2_unique_publisher_id_h})::Cvoid
end

"""
    iox2_publisher_details_node_id(handle)

Returns the [[`iox2_node_id_ptr`](@ref)](crate::[`iox2_node_id_ptr`](@ref)), an immutable pointer to the node id.

# Safety

* `handle` valid pointer to the publisher details

### Prototype
```c
iox2_node_id_ptr iox2_publisher_details_node_id(iox2_publisher_details_ptr handle);
```
"""
function iox2_publisher_details_node_id(handle)
    @ccall libiceoryx2_ffi_c.iox2_publisher_details_node_id(handle::iox2_publisher_details_ptr)::iox2_node_id_ptr
end

"""
    iox2_publisher_details_number_of_samples(handle)

Returns the total number of samples contained in the publishers data segment.

# Safety

* `handle` valid pointer to the publisher details

### Prototype
```c
c_size_t iox2_publisher_details_number_of_samples(iox2_publisher_details_ptr handle);
```
"""
function iox2_publisher_details_number_of_samples(handle)
    @ccall libiceoryx2_ffi_c.iox2_publisher_details_number_of_samples(handle::iox2_publisher_details_ptr)::c_size_t
end

"""
    iox2_publisher_details_max_slice_len(handle)

Returns the current maximum length of a slice.

# Safety

* `handle` valid pointer to the publisher details

### Prototype
```c
c_size_t iox2_publisher_details_max_slice_len(iox2_publisher_details_ptr handle);
```
"""
function iox2_publisher_details_max_slice_len(handle)
    @ccall libiceoryx2_ffi_c.iox2_publisher_details_max_slice_len(handle::iox2_publisher_details_ptr)::c_size_t
end

"""
    __iox2_internal_semantic_string_error_stub()

### Prototype
```c
enum iox2_semantic_string_error_e __iox2_internal_semantic_string_error_stub(void);
```
"""
function __iox2_internal_semantic_string_error_stub()
    @ccall libiceoryx2_ffi_c.__iox2_internal_semantic_string_error_stub()::iox2_semantic_string_error_e
end

"""
    __iox2_internal_node_creation_failure_stub()

### Prototype
```c
enum iox2_node_creation_failure_e __iox2_internal_node_creation_failure_stub(void);
```
"""
function __iox2_internal_node_creation_failure_stub()
    @ccall libiceoryx2_ffi_c.__iox2_internal_node_creation_failure_stub()::iox2_node_creation_failure_e
end

"""
    __iox2_internal_node_list_failure_stub()

### Prototype
```c
enum iox2_node_list_failure_e __iox2_internal_node_list_failure_stub(void);
```
"""
function __iox2_internal_node_list_failure_stub()
    @ccall libiceoryx2_ffi_c.__iox2_internal_node_list_failure_stub()::iox2_node_list_failure_e
end

"""
    __iox2_internal_node_wait_failure_stub()

### Prototype
```c
enum iox2_node_wait_failure_e __iox2_internal_node_wait_failure_stub(void);
```
"""
function __iox2_internal_node_wait_failure_stub()
    @ccall libiceoryx2_ffi_c.__iox2_internal_node_wait_failure_stub()::iox2_node_wait_failure_e
end

"""
    __iox2_internal_service_details_error_stub()

### Prototype
```c
enum iox2_service_details_error_e __iox2_internal_service_details_error_stub(void);
```
"""
function __iox2_internal_service_details_error_stub()
    @ccall libiceoryx2_ffi_c.__iox2_internal_service_details_error_stub()::iox2_service_details_error_e
end

"""
    __iox2_internal_event_open_or_create_error_stub()

### Prototype
```c
enum iox2_event_open_or_create_error_e __iox2_internal_event_open_or_create_error_stub(void);
```
"""
function __iox2_internal_event_open_or_create_error_stub()
    @ccall libiceoryx2_ffi_c.__iox2_internal_event_open_or_create_error_stub()::iox2_event_open_or_create_error_e
end

"""
    __iox2_internal_pub_sub_open_or_create_error_stub()

### Prototype
```c
enum iox2_pub_sub_open_or_create_error_e __iox2_internal_pub_sub_open_or_create_error_stub(void);
```
"""
function __iox2_internal_pub_sub_open_or_create_error_stub()
    @ccall libiceoryx2_ffi_c.__iox2_internal_pub_sub_open_or_create_error_stub()::iox2_pub_sub_open_or_create_error_e
end

"""
    __iox2_internal_notifier_create_error_stub()

### Prototype
```c
enum iox2_notifier_create_error_e __iox2_internal_notifier_create_error_stub(void);
```
"""
function __iox2_internal_notifier_create_error_stub()
    @ccall libiceoryx2_ffi_c.__iox2_internal_notifier_create_error_stub()::iox2_notifier_create_error_e
end

"""
    __iox2_internal_type_detail_error_stub()

### Prototype
```c
enum iox2_type_detail_error_e __iox2_internal_type_detail_error_stub(void);
```
"""
function __iox2_internal_type_detail_error_stub()
    @ccall libiceoryx2_ffi_c.__iox2_internal_type_detail_error_stub()::iox2_type_detail_error_e
end

"""
    __iox2_internal_listener_create_error_stub()

### Prototype
```c
enum iox2_listener_create_error_e __iox2_internal_listener_create_error_stub(void);
```
"""
function __iox2_internal_listener_create_error_stub()
    @ccall libiceoryx2_ffi_c.__iox2_internal_listener_create_error_stub()::iox2_listener_create_error_e
end

"""
    __iox2_internal_notifier_notify_error_stub()

### Prototype
```c
enum iox2_notifier_notify_error_e __iox2_internal_notifier_notify_error_stub(void);
```
"""
function __iox2_internal_notifier_notify_error_stub()
    @ccall libiceoryx2_ffi_c.__iox2_internal_notifier_notify_error_stub()::iox2_notifier_notify_error_e
end

"""
    __iox2_internal_listener_wait_error_stub()

### Prototype
```c
enum iox2_listener_wait_error_e __iox2_internal_listener_wait_error_stub(void);
```
"""
function __iox2_internal_listener_wait_error_stub()
    @ccall libiceoryx2_ffi_c.__iox2_internal_listener_wait_error_stub()::iox2_listener_wait_error_e
end

"""
    __iox2_internal_publisher_create_error_stub()

### Prototype
```c
enum iox2_publisher_create_error_e __iox2_internal_publisher_create_error_stub(void);
```
"""
function __iox2_internal_publisher_create_error_stub()
    @ccall libiceoryx2_ffi_c.__iox2_internal_publisher_create_error_stub()::iox2_publisher_create_error_e
end

"""
    __iox2_internal_subscriber_create_error_stub()

### Prototype
```c
enum iox2_subscriber_create_error_e __iox2_internal_subscriber_create_error_stub(void);
```
"""
function __iox2_internal_subscriber_create_error_stub()
    @ccall libiceoryx2_ffi_c.__iox2_internal_subscriber_create_error_stub()::iox2_subscriber_create_error_e
end

"""
    __iox2_internal_send_error_stub()

### Prototype
```c
enum iox2_send_error_e __iox2_internal_send_error_stub(void);
```
"""
function __iox2_internal_send_error_stub()
    @ccall libiceoryx2_ffi_c.__iox2_internal_send_error_stub()::iox2_send_error_e
end

"""
    __iox2_internal_loan_error_stub()

### Prototype
```c
enum iox2_loan_error_e __iox2_internal_loan_error_stub(void);
```
"""
function __iox2_internal_loan_error_stub()
    @ccall libiceoryx2_ffi_c.__iox2_internal_loan_error_stub()::iox2_loan_error_e
end

"""
    __iox2_internal_receive_error_stub()

### Prototype
```c
enum iox2_receive_error_e __iox2_internal_receive_error_stub(void);
```
"""
function __iox2_internal_receive_error_stub()
    @ccall libiceoryx2_ffi_c.__iox2_internal_receive_error_stub()::iox2_receive_error_e
end

"""
    __iox2_internal_service_list_error_stub()

### Prototype
```c
enum iox2_service_list_error_e __iox2_internal_service_list_error_stub(void);
```
"""
function __iox2_internal_service_list_error_stub()
    @ccall libiceoryx2_ffi_c.__iox2_internal_service_list_error_stub()::iox2_service_list_error_e
end

"""
    __iox2_internal_connection_failure_stub()

### Prototype
```c
enum iox2_connection_failure_e __iox2_internal_connection_failure_stub(void);
```
"""
function __iox2_internal_connection_failure_stub()
    @ccall libiceoryx2_ffi_c.__iox2_internal_connection_failure_stub()::iox2_connection_failure_e
end

"""
    __iox2_internal_config_creation_error_stub()

### Prototype
```c
enum iox2_config_creation_error_e __iox2_internal_config_creation_error_stub(void);
```
"""
function __iox2_internal_config_creation_error_stub()
    @ccall libiceoryx2_ffi_c.__iox2_internal_config_creation_error_stub()::iox2_config_creation_error_e
end

"""
    __iox2_internal_waitset_create_error_stub()

### Prototype
```c
enum iox2_waitset_create_error_e __iox2_internal_waitset_create_error_stub(void);
```
"""
function __iox2_internal_waitset_create_error_stub()
    @ccall libiceoryx2_ffi_c.__iox2_internal_waitset_create_error_stub()::iox2_waitset_create_error_e
end

"""
    __iox2_internal_waitset_run_error_stub()

### Prototype
```c
enum iox2_waitset_run_error_e __iox2_internal_waitset_run_error_stub(void);
```
"""
function __iox2_internal_waitset_run_error_stub()
    @ccall libiceoryx2_ffi_c.__iox2_internal_waitset_run_error_stub()::iox2_waitset_run_error_e
end

"""
    __iox2_internal_waitset_run_result_stub()

### Prototype
```c
enum iox2_waitset_run_result_e __iox2_internal_waitset_run_result_stub(void);
```
"""
function __iox2_internal_waitset_run_result_stub()
    @ccall libiceoryx2_ffi_c.__iox2_internal_waitset_run_result_stub()::iox2_waitset_run_result_e
end

"""
    __iox2_internal_waitset_attachment_error_stub()

### Prototype
```c
enum iox2_waitset_attachment_error_e __iox2_internal_waitset_attachment_error_stub(void);
```
"""
function __iox2_internal_waitset_attachment_error_stub()
    @ccall libiceoryx2_ffi_c.__iox2_internal_waitset_attachment_error_stub()::iox2_waitset_attachment_error_e
end

"""
    __iox2_internal_node_cleanup_failure_stub()

### Prototype
```c
enum iox2_node_cleanup_failure_e __iox2_internal_node_cleanup_failure_stub(void);
```
"""
function __iox2_internal_node_cleanup_failure_stub()
    @ccall libiceoryx2_ffi_c.__iox2_internal_node_cleanup_failure_stub()::iox2_node_cleanup_failure_e
end

"""
    __iox2_internal_request_response_open_or_create_error_stub()

### Prototype
```c
enum iox2_request_response_open_or_create_error_e __iox2_internal_request_response_open_or_create_error_stub(void);
```
"""
function __iox2_internal_request_response_open_or_create_error_stub()
    @ccall libiceoryx2_ffi_c.__iox2_internal_request_response_open_or_create_error_stub()::iox2_request_response_open_or_create_error_e
end

"""
    __iox2_internal_client_create_error_stub()

### Prototype
```c
enum iox2_client_create_error_e __iox2_internal_client_create_error_stub(void);
```
"""
function __iox2_internal_client_create_error_stub()
    @ccall libiceoryx2_ffi_c.__iox2_internal_client_create_error_stub()::iox2_client_create_error_e
end

"""
    __iox2_internal_server_create_error_stub()

### Prototype
```c
enum iox2_server_create_error_e __iox2_internal_server_create_error_stub(void);
```
"""
function __iox2_internal_server_create_error_stub()
    @ccall libiceoryx2_ffi_c.__iox2_internal_server_create_error_stub()::iox2_server_create_error_e
end

"""
    __iox2_internal_request_send_error_stub()

### Prototype
```c
enum iox2_request_send_error_e __iox2_internal_request_send_error_stub(void);
```
"""
function __iox2_internal_request_send_error_stub()
    @ccall libiceoryx2_ffi_c.__iox2_internal_request_send_error_stub()::iox2_request_send_error_e
end

"""
    iox2_entry_handle_error_string(error)

Returns a string literal describing the provided [[`iox2_entry_handle_error_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_entry_handle_error_string(enum iox2_entry_handle_error_e error);
```
"""
function iox2_entry_handle_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_entry_handle_error_string(error::iox2_entry_handle_error_e)::Cstring
end

"""
    iox2_reader_id(reader_handle, id_struct_ptr, id_handle_ptr)

Returns the unique port id of the reader.

# Arguments

* `reader_handle` obtained by [[`iox2_port_factory_reader_builder_create`](@ref)](crate::[`iox2_port_factory_reader_builder_create`](@ref)) * `id_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_unique_reader_id_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `id_handle_ptr` valid pointer to a [[`iox2_unique_reader_id_h`](@ref)].

# Safety

* `reader_handle` is valid, non-null and was obtained via [[`iox2_port_factory_reader_builder_create`](@ref)](crate::[`iox2_port_factory_reader_builder_create`](@ref)) * `id` is valid and non-null

### Prototype
```c
void iox2_reader_id(iox2_reader_h_ref reader_handle, struct iox2_unique_reader_id_t *id_struct_ptr, iox2_unique_reader_id_h *id_handle_ptr);
```
"""
function iox2_reader_id(reader_handle, id_struct_ptr, id_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_reader_id(reader_handle::iox2_reader_h_ref, id_struct_ptr::Ptr{iox2_unique_reader_id_t}, id_handle_ptr::Ptr{iox2_unique_reader_id_h})::Cvoid
end

"""
    iox2_reader_entry(reader_handle, entry_handle_struct_ptr, entry_handle_handle_ptr, key, value_type_name_str, value_type_name_len, value_size, value_alignment)

Acquires an entry handle for direct read access to the stored value.

# Arguments

* `reader_handle` obtained by [[`iox2_port_factory_reader_builder_create`](@ref)](crate::[`iox2_port_factory_reader_builder_create`](@ref)) * `entry_handle_struct_ptr` must be either a NULL pointer or a pointer to a valid [[`iox2_entry_handle_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `entry_handle_handle_ptr` valid pointer to a [[`iox2_entry_handle_h`](@ref)] * `key` the key of the key-value pair for which the entry handle shall be acquired * `value_type_name_str` the type name of the value type of the key-value-pair for which the entry handle shall be acquired * `value_type_name_len` the length of `value_type_name_str` * `value_size` the size of the value type of the key-value-pair for which the entry handle shall be acquired * `value_alignment` the alignment of the value type of the key-value-pair for which the entry handle shall be acquired

# Safety

* `reader_handle` must be non-null and valid * `entry_handle_handle_ptr` must be non-null and valid

### Prototype
```c
int iox2_reader_entry(iox2_reader_h_ref reader_handle, struct iox2_entry_handle_t *entry_handle_struct_ptr, iox2_entry_handle_h *entry_handle_handle_ptr, const void *key, const char *value_type_name_str, c_size_t value_type_name_len, c_size_t value_size, c_size_t value_alignment);
```
"""
function iox2_reader_entry(reader_handle, entry_handle_struct_ptr, entry_handle_handle_ptr, key, value_type_name_str, value_type_name_len, value_size, value_alignment)
    @ccall libiceoryx2_ffi_c.iox2_reader_entry(reader_handle::iox2_reader_h_ref, entry_handle_struct_ptr::Ptr{iox2_entry_handle_t}, entry_handle_handle_ptr::Ptr{iox2_entry_handle_h}, key::Ptr{Cvoid}, value_type_name_str::Cstring, value_type_name_len::c_size_t, value_size::c_size_t, value_alignment::c_size_t)::Cint
end

"""
    iox2_reader_drop(reader_handle)

This function needs to be called to destroy the reader!

# Arguments

* `reader_handle` - A valid [[`iox2_reader_h`](@ref)]

# Safety

* The `reader_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_reader_t`](@ref)] can be re-used with a call to [[`iox2_port_factory_reader_builder_create`](@ref)](crate::[`iox2_port_factory_reader_builder_create`](@ref))!

### Prototype
```c
void iox2_reader_drop(iox2_reader_h reader_handle);
```
"""
function iox2_reader_drop(reader_handle)
    @ccall libiceoryx2_ffi_c.iox2_reader_drop(reader_handle::iox2_reader_h)::Cvoid
end

"""
    iox2_reader_details_reader_id(handle, id_struct_ptr, id_handle_ptr)

Returns the unique port id of the reader.

# Safety

* `handle` valid pointer to the reader details * `id_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_unique_reader_id_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `id_handle_ptr` valid pointer to a [[`iox2_unique_reader_id_h`](@ref)].

### Prototype
```c
void iox2_reader_details_reader_id(iox2_reader_details_ptr handle, struct iox2_unique_reader_id_t *id_struct_ptr, iox2_unique_reader_id_h *id_handle_ptr);
```
"""
function iox2_reader_details_reader_id(handle, id_struct_ptr, id_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_reader_details_reader_id(handle::iox2_reader_details_ptr, id_struct_ptr::Ptr{iox2_unique_reader_id_t}, id_handle_ptr::Ptr{iox2_unique_reader_id_h})::Cvoid
end

"""
    iox2_reader_details_node_id(handle)

Returns the [[`iox2_node_id_ptr`](@ref)](crate::[`iox2_node_id_ptr`](@ref)), an immutable pointer to the node id.

# Safety

* `handle` valid pointer to the reader details

### Prototype
```c
iox2_node_id_ptr iox2_reader_details_node_id(iox2_reader_details_ptr handle);
```
"""
function iox2_reader_details_node_id(handle)
    @ccall libiceoryx2_ffi_c.iox2_reader_details_node_id(handle::iox2_reader_details_ptr)::iox2_node_id_ptr
end

"""
    iox2_request_header_drop(handle)

This function needs to be called to destroy the request\\_header!

# Safety

* The `handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_request_header_t`](@ref)] can be re-used

### Prototype
```c
void iox2_request_header_drop(iox2_request_header_h handle);
```
"""
function iox2_request_header_drop(handle)
    @ccall libiceoryx2_ffi_c.iox2_request_header_drop(handle::iox2_request_header_h)::Cvoid
end

"""
    iox2_request_header_client_id(header_handle, id_struct_ptr, id_handle_ptr)

Returns the unique client id of the source of the request.

# Arguments

* `header_handle` is valid, non-null and is initialized * `id_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_unique_client_id_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `id_handle_ptr` valid pointer to a [[`iox2_unique_client_id_h`](@ref)].

# Safety

* `header_handle` is valid and non-null * `id_struct_ptr` is either null or valid and non-null * `id_handle_ptr` is valid and non-null

### Prototype
```c
void iox2_request_header_client_id(iox2_request_header_h_ref header_handle, struct iox2_unique_client_id_t *id_struct_ptr, iox2_unique_client_id_h *id_handle_ptr);
```
"""
function iox2_request_header_client_id(header_handle, id_struct_ptr, id_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_request_header_client_id(header_handle::iox2_request_header_h_ref, id_struct_ptr::Ptr{iox2_unique_client_id_t}, id_handle_ptr::Ptr{iox2_unique_client_id_h})::Cvoid
end

"""
    iox2_request_header_number_of_elements(header_handle)

Returns the number of elements of the payload. The element size is defined via this call when creating a new service [`crate::[`iox2_service_builder_request_response_set_request_payload_type_details`](@ref)()`]. So if the payload is defined with alignment 8 and size 16 and this function returns 5. It means that the payload consists of 5 elements of size 16 and every element is 8 byte aligned. Therefore, the payload pointer points to a memory region with 5 * 16 = 80 bytes.

# Arguments

* `header_handle` is valid, non-null and initialized

# Safety

* `header_handle` is valid and non-null

### Prototype
```c
uint64_t iox2_request_header_number_of_elements(iox2_request_header_h_ref header_handle);
```
"""
function iox2_request_header_number_of_elements(header_handle)
    @ccall libiceoryx2_ffi_c.iox2_request_header_number_of_elements(header_handle::iox2_request_header_h_ref)::UInt64
end

"""
    iox2_request_send_error_string(error)

Returns a string literal describing the provided [[`iox2_request_send_error_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_request_send_error_string(enum iox2_request_send_error_e error);
```
"""
function iox2_request_send_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_request_send_error_string(error::iox2_request_send_error_e)::Cstring
end

"""
    iox2_request_mut_user_header(handle, header_ptr)

Acquires the requests user header.

# Safety

* `handle` obtained by [`[`iox2_client_loan_slice_uninit`](@ref)()`](crate::[`iox2_client_loan_slice_uninit`](@ref)()) * `header_ptr` a valid, non-null pointer pointing to a `*const c\\_void` pointer.

### Prototype
```c
void iox2_request_mut_user_header(iox2_request_mut_h_ref handle, const void **header_ptr);
```
"""
function iox2_request_mut_user_header(handle, header_ptr)
    @ccall libiceoryx2_ffi_c.iox2_request_mut_user_header(handle::iox2_request_mut_h_ref, header_ptr::Ptr{Ptr{Cvoid}})::Cvoid
end

"""
    iox2_request_mut_header(handle, header_struct_ptr, header_handle_ptr)

Acquires the requests header.

# Safety

* `handle` obtained by [`[`iox2_client_loan_slice_uninit`](@ref)()`](crate::[`iox2_client_loan_slice_uninit`](@ref)()) * `header_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_request_header_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `header_handle_ptr` valid pointer to a [[`iox2_request_header_h`](@ref)].

### Prototype
```c
void iox2_request_mut_header(iox2_request_mut_h_ref handle, struct iox2_request_header_t *header_struct_ptr, iox2_request_header_h *header_handle_ptr);
```
"""
function iox2_request_mut_header(handle, header_struct_ptr, header_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_request_mut_header(handle::iox2_request_mut_h_ref, header_struct_ptr::Ptr{iox2_request_header_t}, header_handle_ptr::Ptr{iox2_request_header_h})::Cvoid
end

"""
    iox2_request_mut_user_header_mut(handle, header_ptr)

Acquires the requests mutable user header.

# Safety

* `handle` obtained by [`[`iox2_client_loan_slice_uninit`](@ref)()`](crate::[`iox2_client_loan_slice_uninit`](@ref)()) * `header_ptr` a valid, non-null pointer pointing to a [`*const c\\_void`] pointer.

### Prototype
```c
void iox2_request_mut_user_header_mut(iox2_request_mut_h_ref handle, void **header_ptr);
```
"""
function iox2_request_mut_user_header_mut(handle, header_ptr)
    @ccall libiceoryx2_ffi_c.iox2_request_mut_user_header_mut(handle::iox2_request_mut_h_ref, header_ptr::Ptr{Ptr{Cvoid}})::Cvoid
end

"""
    iox2_request_mut_payload_mut(handle, payload_ptr, number_of_elements)

Acquires the requests mutable payload.

# Safety

* `handle` obtained by [`[`iox2_client_loan_slice_uninit`](@ref)()`](crate::[`iox2_client_loan_slice_uninit`](@ref)()) * `payload_ptr` a valid, non-null pointer pointing to a `*mut c\\_void` pointer. * `number_of_elements` (optional) either a null pointer or a valid pointer pointing to a [[`c_size_t`](@ref)].

### Prototype
```c
void iox2_request_mut_payload_mut(iox2_request_mut_h_ref handle, void **payload_ptr, c_size_t *number_of_elements);
```
"""
function iox2_request_mut_payload_mut(handle, payload_ptr, number_of_elements)
    @ccall libiceoryx2_ffi_c.iox2_request_mut_payload_mut(handle::iox2_request_mut_h_ref, payload_ptr::Ptr{Ptr{Cvoid}}, number_of_elements::Ptr{c_size_t})::Cvoid
end

"""
    iox2_request_mut_payload(handle, payload_ptr, number_of_elements)

Acquires the request payload.

# Safety

* `handle` obtained by [`[`iox2_client_loan_slice_uninit`](@ref)()`](crate::[`iox2_client_loan_slice_uninit`](@ref)()) * `payload_ptr` a valid, non-null pointer pointing to a [`*const c\\_void`] pointer. * `number_of_elements` (optional) either a null pointer or a valid pointer pointing to a [[`c_size_t`](@ref)].

### Prototype
```c
void iox2_request_mut_payload(iox2_request_mut_h_ref handle, const void **payload_ptr, c_size_t *number_of_elements);
```
"""
function iox2_request_mut_payload(handle, payload_ptr, number_of_elements)
    @ccall libiceoryx2_ffi_c.iox2_request_mut_payload(handle::iox2_request_mut_h_ref, payload_ptr::Ptr{Ptr{Cvoid}}, number_of_elements::Ptr{c_size_t})::Cvoid
end

"""
    iox2_request_mut_send(handle, pending_response_struct_ptr, pending_response_handle_ptr)

Takes the ownership of the request and sends it

# Safety

* `handle` obtained by [`[`iox2_client_loan_slice_uninit`](@ref)()`](crate::[`iox2_client_loan_slice_uninit`](@ref)()) * The `pending_response_handle_ptr` is pointing to a valid [[`iox2_pending_response_h`](@ref)].

### Prototype
```c
int iox2_request_mut_send(iox2_request_mut_h handle, struct iox2_pending_response_t *pending_response_struct_ptr, iox2_pending_response_h *pending_response_handle_ptr);
```
"""
function iox2_request_mut_send(handle, pending_response_struct_ptr, pending_response_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_request_mut_send(handle::iox2_request_mut_h, pending_response_struct_ptr::Ptr{iox2_pending_response_t}, pending_response_handle_ptr::Ptr{iox2_pending_response_h})::Cint
end

"""
    iox2_request_mut_drop(handle)

This function needs to be called to destroy the request!

# Arguments

* `handle` - A valid [[`iox2_request_mut_h`](@ref)]

# Safety

* The `handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_request_mut_t`](@ref)] can be re-used with a call to [[`iox2_client_loan_slice_uninit`](@ref)](crate::[`iox2_client_loan_slice_uninit`](@ref))!

### Prototype
```c
void iox2_request_mut_drop(iox2_request_mut_h handle);
```
"""
function iox2_request_mut_drop(handle)
    @ccall libiceoryx2_ffi_c.iox2_request_mut_drop(handle::iox2_request_mut_h)::Cvoid
end

"""
    iox2_response_header(handle, header_struct_ptr, header_handle_ptr)

Acquires the responses header.

# Safety

* `handle` obtained by [`[`iox2_pending_response_receive`](@ref)()`](crate::[`iox2_pending_response_receive`](@ref)()) * `header_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_response_header_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `header_handle_ptr` valid pointer to a [[`iox2_response_header_h`](@ref)].

### Prototype
```c
void iox2_response_header(iox2_response_h_ref handle, struct iox2_response_header_t *header_struct_ptr, iox2_response_header_h *header_handle_ptr);
```
"""
function iox2_response_header(handle, header_struct_ptr, header_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_response_header(handle::iox2_response_h_ref, header_struct_ptr::Ptr{iox2_response_header_t}, header_handle_ptr::Ptr{iox2_response_header_h})::Cvoid
end

"""
    iox2_response_user_header(handle, header_ptr)

Acquires the responses user header.

# Safety

* `handle` obtained by [`[`iox2_pending_response_receive`](@ref)()`](crate::[`iox2_pending_response_receive`](@ref)()) * `header_ptr` valid pointer to a `*const c\\_void`.

### Prototype
```c
void iox2_response_user_header(iox2_response_h_ref handle, const void **header_ptr);
```
"""
function iox2_response_user_header(handle, header_ptr)
    @ccall libiceoryx2_ffi_c.iox2_response_user_header(handle::iox2_response_h_ref, header_ptr::Ptr{Ptr{Cvoid}})::Cvoid
end

"""
    iox2_response_payload(handle, payload_ptr, number_of_elements)

Acquires the responses payload.

# Safety

* `handle` obtained by [`[`iox2_pending_response_receive`](@ref)()`](crate::[`iox2_pending_response_receive`](@ref)()) * `payload_ptr` valid pointer to a `*const c\\_void`.

### Prototype
```c
void iox2_response_payload(iox2_response_h_ref handle, const void **payload_ptr, c_size_t *number_of_elements);
```
"""
function iox2_response_payload(handle, payload_ptr, number_of_elements)
    @ccall libiceoryx2_ffi_c.iox2_response_payload(handle::iox2_response_h_ref, payload_ptr::Ptr{Ptr{Cvoid}}, number_of_elements::Ptr{c_size_t})::Cvoid
end

"""
    iox2_response_drop(handle)

Destroys the response.

# Safety

* `handle` obtained by [`[`iox2_pending_response_receive`](@ref)()`](crate::[`iox2_pending_response_receive`](@ref)())

### Prototype
```c
void iox2_response_drop(iox2_response_h handle);
```
"""
function iox2_response_drop(handle)
    @ccall libiceoryx2_ffi_c.iox2_response_drop(handle::iox2_response_h)::Cvoid
end

"""
    iox2_response_header_drop(handle)

This function needs to be called to destroy the response\\_header!

# Safety

* The `handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_response_header_t`](@ref)] can be re-used

### Prototype
```c
void iox2_response_header_drop(iox2_response_header_h handle);
```
"""
function iox2_response_header_drop(handle)
    @ccall libiceoryx2_ffi_c.iox2_response_header_drop(handle::iox2_response_header_h)::Cvoid
end

"""
    iox2_response_header_server_id(header_handle, id_struct_ptr, id_handle_ptr)

Returns the unique server id of the source of the response.

# Arguments

* `header_handle` is valid, non-null and was initialized with [`[`iox2_response_header`](@ref)()`](crate::[`iox2_response_header`](@ref)) * `id_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_unique_server_id_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `id_handle_ptr` valid pointer to a [[`iox2_unique_server_id_h`](@ref)].

# Safety

* `header_handle` is valid and non-null * `id_struct_ptr` is either null or valid and non-null * `id_handle_ptr` is valid and non-null

### Prototype
```c
void iox2_response_header_server_id(iox2_response_header_h_ref header_handle, struct iox2_unique_server_id_t *id_struct_ptr, iox2_unique_server_id_h *id_handle_ptr);
```
"""
function iox2_response_header_server_id(header_handle, id_struct_ptr, id_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_response_header_server_id(header_handle::iox2_response_header_h_ref, id_struct_ptr::Ptr{iox2_unique_server_id_t}, id_handle_ptr::Ptr{iox2_unique_server_id_h})::Cvoid
end

"""
    iox2_response_header_number_of_elements(header_handle)

Returns the number of elements of the payload. The element size is defined via this call when creating a new service [`crate::[`iox2_service_builder_request_response_set_response_payload_type_details`](@ref)()`]. So if the payload is defined with alignment 8 and size 16 and this function returns 5. It means that the payload consists of 5 elements of size 16 and every element is 8 byte aligned. Therefore, the payload pointer points to a memory region with 5 * 16 = 80 bytes.

# Arguments

* `header_handle` is valid, non-null and was initialized with [`[`iox2_response_header`](@ref)()`](crate::[`iox2_response_header`](@ref))

# Safety

* `header_handle` is valid and non-null

### Prototype
```c
uint64_t iox2_response_header_number_of_elements(iox2_response_header_h_ref header_handle);
```
"""
function iox2_response_header_number_of_elements(header_handle)
    @ccall libiceoryx2_ffi_c.iox2_response_header_number_of_elements(header_handle::iox2_response_header_h_ref)::UInt64
end

"""
    iox2_response_mut_header(handle, header_struct_ptr, header_handle_ptr)

Acquires the responses header.

# Safety

* `handle` obtained by [`[`iox2_active_request_loan_slice_uninit`](@ref)()`](crate::[`iox2_active_request_loan_slice_uninit`](@ref)()) * `header_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_response_header_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `header_handle_ptr` valid pointer to a [[`iox2_response_header_h`](@ref)].

### Prototype
```c
void iox2_response_mut_header(iox2_response_mut_h_ref handle, struct iox2_response_header_t *header_struct_ptr, iox2_response_header_h *header_handle_ptr);
```
"""
function iox2_response_mut_header(handle, header_struct_ptr, header_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_response_mut_header(handle::iox2_response_mut_h_ref, header_struct_ptr::Ptr{iox2_response_header_t}, header_handle_ptr::Ptr{iox2_response_header_h})::Cvoid
end

"""
    iox2_response_mut_user_header(handle, header_ptr)

Acquires the responses user header.

# Safety

* `handle` obtained by [`[`iox2_active_request_loan_slice_uninit`](@ref)()`](crate::[`iox2_active_request_loan_slice_uninit`](@ref)()) * `header_ptr` valid pointer to a `*const c\\_void`.

### Prototype
```c
void iox2_response_mut_user_header(iox2_response_mut_h_ref handle, const void **header_ptr);
```
"""
function iox2_response_mut_user_header(handle, header_ptr)
    @ccall libiceoryx2_ffi_c.iox2_response_mut_user_header(handle::iox2_response_mut_h_ref, header_ptr::Ptr{Ptr{Cvoid}})::Cvoid
end

"""
    iox2_response_mut_user_header_mut(handle, header_ptr)

Acquires the responses mutable user header.

# Safety

* `handle` obtained by [`[`iox2_active_request_loan_slice_uninit`](@ref)()`](crate::[`iox2_active_request_loan_slice_uninit`](@ref)()) * `header_ptr` valid pointer to a `*mut c\\_void`.

### Prototype
```c
void iox2_response_mut_user_header_mut(iox2_response_mut_h_ref handle, void **header_ptr);
```
"""
function iox2_response_mut_user_header_mut(handle, header_ptr)
    @ccall libiceoryx2_ffi_c.iox2_response_mut_user_header_mut(handle::iox2_response_mut_h_ref, header_ptr::Ptr{Ptr{Cvoid}})::Cvoid
end

"""
    iox2_response_mut_payload(handle, payload_ptr, number_of_elements)

Acquires the responses payload.

# Safety

* `handle` obtained by [`[`iox2_active_request_loan_slice_uninit`](@ref)()`](crate::[`iox2_active_request_loan_slice_uninit`](@ref)()) * `payload_ptr` valid pointer to a `*const c\\_void`.

### Prototype
```c
void iox2_response_mut_payload(iox2_response_mut_h_ref handle, const void **payload_ptr, c_size_t *number_of_elements);
```
"""
function iox2_response_mut_payload(handle, payload_ptr, number_of_elements)
    @ccall libiceoryx2_ffi_c.iox2_response_mut_payload(handle::iox2_response_mut_h_ref, payload_ptr::Ptr{Ptr{Cvoid}}, number_of_elements::Ptr{c_size_t})::Cvoid
end

"""
    iox2_response_mut_payload_mut(handle, payload_ptr, number_of_elements)

Acquires the responses mutable payload.

# Safety

* `handle` obtained by [`[`iox2_active_request_loan_slice_uninit`](@ref)()`](crate::[`iox2_active_request_loan_slice_uninit`](@ref)()) * `payload_ptr` valid pointer to a `*mut c\\_void`.

### Prototype
```c
void iox2_response_mut_payload_mut(iox2_response_mut_h_ref handle, void **payload_ptr, c_size_t *number_of_elements);
```
"""
function iox2_response_mut_payload_mut(handle, payload_ptr, number_of_elements)
    @ccall libiceoryx2_ffi_c.iox2_response_mut_payload_mut(handle::iox2_response_mut_h_ref, payload_ptr::Ptr{Ptr{Cvoid}}, number_of_elements::Ptr{c_size_t})::Cvoid
end

"""
    iox2_response_mut_send(response_handle)

Sends the response. Returns [`IOX2_OK`](@ref) on success otherwise [[`iox2_send_error_e`](@ref)](crate::api::[`iox2_send_error_e`](@ref)).

# Safety

* `response_handle` obtained by [`[`iox2_active_request_loan_slice_uninit`](@ref)()`](crate::[`iox2_active_request_loan_slice_uninit`](@ref)())

### Prototype
```c
int iox2_response_mut_send(iox2_response_mut_h response_handle);
```
"""
function iox2_response_mut_send(response_handle)
    @ccall libiceoryx2_ffi_c.iox2_response_mut_send(response_handle::iox2_response_mut_h)::Cint
end

"""
    iox2_response_mut_drop(response_handle)

Destroys the response without sending it.

# Safety

* `response_handle` obtained by [`[`iox2_active_request_loan_slice_uninit`](@ref)()`](crate::[`iox2_active_request_loan_slice_uninit`](@ref)())

### Prototype
```c
void iox2_response_mut_drop(iox2_response_mut_h response_handle);
```
"""
function iox2_response_mut_drop(response_handle)
    @ccall libiceoryx2_ffi_c.iox2_response_mut_drop(response_handle::iox2_response_mut_h)::Cvoid
end

"""
    iox2_sample_header(handle, header_struct_ptr, header_handle_ptr)

Acquires the samples header.

# Safety

* `handle` obtained by [`[`iox2_subscriber_receive`](@ref)()`](crate::[`iox2_subscriber_receive`](@ref)()) * `header_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_publish_subscribe_header_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `header_handle_ptr` valid pointer to a [[`iox2_publish_subscribe_header_h`](@ref)].

### Prototype
```c
void iox2_sample_header(iox2_sample_h_ref handle, struct iox2_publish_subscribe_header_t *header_struct_ptr, iox2_publish_subscribe_header_h *header_handle_ptr);
```
"""
function iox2_sample_header(handle, header_struct_ptr, header_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_sample_header(handle::iox2_sample_h_ref, header_struct_ptr::Ptr{iox2_publish_subscribe_header_t}, header_handle_ptr::Ptr{iox2_publish_subscribe_header_h})::Cvoid
end

"""
    iox2_sample_user_header(handle, header_ptr)

Acquires the samples user header.

# Safety

* `handle` obtained by [`[`iox2_subscriber_receive`](@ref)()`](crate::[`iox2_subscriber_receive`](@ref)()) * `header_ptr` a valid, non-null pointer pointing to a [`*const c\\_void`] pointer.

### Prototype
```c
void iox2_sample_user_header(iox2_sample_h_ref handle, const void **header_ptr);
```
"""
function iox2_sample_user_header(handle, header_ptr)
    @ccall libiceoryx2_ffi_c.iox2_sample_user_header(handle::iox2_sample_h_ref, header_ptr::Ptr{Ptr{Cvoid}})::Cvoid
end

"""
    iox2_sample_payload(handle, payload_ptr, number_of_elements)

Acquires the samples payload.

# Safety

* `handle` obtained by [`[`iox2_subscriber_receive`](@ref)()`](crate::[`iox2_subscriber_receive`](@ref)()) * `payload_ptr` a valid, non-null pointer pointing to a [`*const c\\_void`] pointer. * `number_of_elements` (optional) either a null poitner or a valid pointer pointing to a [[`c_size_t`](@ref)] with the number of elements of the underlying type

### Prototype
```c
void iox2_sample_payload(iox2_sample_h_ref handle, const void **payload_ptr, c_size_t *number_of_elements);
```
"""
function iox2_sample_payload(handle, payload_ptr, number_of_elements)
    @ccall libiceoryx2_ffi_c.iox2_sample_payload(handle::iox2_sample_h_ref, payload_ptr::Ptr{Ptr{Cvoid}}, number_of_elements::Ptr{c_size_t})::Cvoid
end

"""
    iox2_sample_drop(sample_handle)

This function needs to be called to destroy the sample!

# Arguments

* `sample_handle` - A valid [[`iox2_sample_h`](@ref)]

# Safety

* The `sample_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_sample_t`](@ref)] can be re-used with a call to [[`iox2_subscriber_receive`](@ref)](crate::[`iox2_subscriber_receive`](@ref))!

### Prototype
```c
void iox2_sample_drop(iox2_sample_h sample_handle);
```
"""
function iox2_sample_drop(sample_handle)
    @ccall libiceoryx2_ffi_c.iox2_sample_drop(sample_handle::iox2_sample_h)::Cvoid
end

"""
    iox2_sample_mut_user_header(handle, header_ptr)

Acquires the samples user header.

# Safety

* `handle` obtained by [`[`iox2_publisher_loan_slice_uninit`](@ref)()`](crate::[`iox2_publisher_loan_slice_uninit`](@ref)()) * `header_ptr` a valid, non-null pointer pointing to a [`*const c\\_void`] pointer.

### Prototype
```c
void iox2_sample_mut_user_header(iox2_sample_mut_h_ref handle, const void **header_ptr);
```
"""
function iox2_sample_mut_user_header(handle, header_ptr)
    @ccall libiceoryx2_ffi_c.iox2_sample_mut_user_header(handle::iox2_sample_mut_h_ref, header_ptr::Ptr{Ptr{Cvoid}})::Cvoid
end

"""
    iox2_sample_mut_header(handle, header_struct_ptr, header_handle_ptr)

Acquires the samples header.

# Safety

* `handle` obtained by [`[`iox2_publisher_loan_slice_uninit`](@ref)()`](crate::[`iox2_publisher_loan_slice_uninit`](@ref)()) * `header_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_publish_subscribe_header_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `header_handle_ptr` valid pointer to a [[`iox2_publish_subscribe_header_h`](@ref)].

### Prototype
```c
void iox2_sample_mut_header(iox2_sample_mut_h_ref handle, struct iox2_publish_subscribe_header_t *header_struct_ptr, iox2_publish_subscribe_header_h *header_handle_ptr);
```
"""
function iox2_sample_mut_header(handle, header_struct_ptr, header_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_sample_mut_header(handle::iox2_sample_mut_h_ref, header_struct_ptr::Ptr{iox2_publish_subscribe_header_t}, header_handle_ptr::Ptr{iox2_publish_subscribe_header_h})::Cvoid
end

"""
    iox2_sample_mut_user_header_mut(handle, header_ptr)

Acquires the samples mutable user header.

# Safety

* `handle` obtained by [`[`iox2_publisher_loan_slice_uninit`](@ref)()`](crate::[`iox2_publisher_loan_slice_uninit`](@ref)()) * `header_ptr` a valid, non-null pointer pointing to a [`*const c\\_void`] pointer.

### Prototype
```c
void iox2_sample_mut_user_header_mut(iox2_sample_mut_h_ref handle, void **header_ptr);
```
"""
function iox2_sample_mut_user_header_mut(handle, header_ptr)
    @ccall libiceoryx2_ffi_c.iox2_sample_mut_user_header_mut(handle::iox2_sample_mut_h_ref, header_ptr::Ptr{Ptr{Cvoid}})::Cvoid
end

"""
    iox2_sample_mut_payload_mut(handle, payload_ptr, number_of_elements)

Acquires the samples mutable payload.

# Safety

* `handle` obtained by [`[`iox2_publisher_loan_slice_uninit`](@ref)()`](crate::[`iox2_publisher_loan_slice_uninit`](@ref)()) * `payload_ptr` a valid, non-null pointer pointing to a [`*const c\\_void`] pointer. * `payload_len` (optional) either a null poitner or a valid pointer pointing to a [[`c_size_t`](@ref)].

### Prototype
```c
void iox2_sample_mut_payload_mut(iox2_sample_mut_h_ref handle, void **payload_ptr, c_size_t *number_of_elements);
```
"""
function iox2_sample_mut_payload_mut(handle, payload_ptr, number_of_elements)
    @ccall libiceoryx2_ffi_c.iox2_sample_mut_payload_mut(handle::iox2_sample_mut_h_ref, payload_ptr::Ptr{Ptr{Cvoid}}, number_of_elements::Ptr{c_size_t})::Cvoid
end

"""
    iox2_sample_mut_payload(handle, payload_ptr, number_of_elements)

Acquires the samples payload.

# Safety

* `handle` obtained by [`[`iox2_publisher_loan_slice_uninit`](@ref)()`](crate::[`iox2_publisher_loan_slice_uninit`](@ref)()) * `payload_ptr` a valid, non-null pointer pointing to a [`*const c\\_void`] pointer. * `payload_len` (optional) either a null poitner or a valid pointer pointing to a [[`c_size_t`](@ref)].

### Prototype
```c
void iox2_sample_mut_payload(iox2_sample_mut_h_ref handle, const void **payload_ptr, c_size_t *number_of_elements);
```
"""
function iox2_sample_mut_payload(handle, payload_ptr, number_of_elements)
    @ccall libiceoryx2_ffi_c.iox2_sample_mut_payload(handle::iox2_sample_mut_h_ref, payload_ptr::Ptr{Ptr{Cvoid}}, number_of_elements::Ptr{c_size_t})::Cvoid
end

"""
    iox2_sample_mut_send(sample_handle, number_of_recipients)

Takes the ownership of the sample and sends it

# Safety

* `handle` obtained by [`[`iox2_publisher_loan_slice_uninit`](@ref)()`](crate::[`iox2_publisher_loan_slice_uninit`](@ref)()) * `number_of_recipients`, can be null or must point to a valid [[`c_size_t`](@ref)] to store the number of subscribers that received the sample

### Prototype
```c
int iox2_sample_mut_send(iox2_sample_mut_h sample_handle, c_size_t *number_of_recipients);
```
"""
function iox2_sample_mut_send(sample_handle, number_of_recipients)
    @ccall libiceoryx2_ffi_c.iox2_sample_mut_send(sample_handle::iox2_sample_mut_h, number_of_recipients::Ptr{c_size_t})::Cint
end

"""
    iox2_sample_mut_drop(sample_handle)

This function needs to be called to destroy the sample!

# Arguments

* `sample_handle` - A valid [[`iox2_sample_mut_h`](@ref)]

# Safety

* The `sample_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_sample_mut_t`](@ref)] can be re-used with a call to [[`iox2_subscriber_receive`](@ref)](crate::[`iox2_subscriber_receive`](@ref))!

### Prototype
```c
void iox2_sample_mut_drop(iox2_sample_mut_h sample_handle);
```
"""
function iox2_sample_mut_drop(sample_handle)
    @ccall libiceoryx2_ffi_c.iox2_sample_mut_drop(sample_handle::iox2_sample_mut_h)::Cvoid
end

"""
    iox2_server_id(handle, id_struct_ptr, id_handle_ptr)

Returns the unique port id of the server.

# Arguments

* `handle` obtained by [[`iox2_port_factory_server_builder_create`](@ref)](crate::[`iox2_port_factory_server_builder_create`](@ref)) * `id_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_unique_server_id_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `id_handle_ptr` valid pointer to a [[`iox2_unique_server_id_h`](@ref)].

# Safety

* `handle` is valid, non-null and was obtained via [[`iox2_port_factory_server_builder_create`](@ref)](crate::[`iox2_port_factory_server_builder_create`](@ref)) * `id_handle_ptr` is valid and non-null

### Prototype
```c
void iox2_server_id(iox2_server_h_ref handle, struct iox2_unique_server_id_t *id_struct_ptr, iox2_unique_server_id_h *id_handle_ptr);
```
"""
function iox2_server_id(handle, id_struct_ptr, id_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_server_id(handle::iox2_server_h_ref, id_struct_ptr::Ptr{iox2_unique_server_id_t}, id_handle_ptr::Ptr{iox2_unique_server_id_h})::Cvoid
end

"""
    iox2_server_has_requests(handle, result_ptr)

Returns true when the server has requests that can be acquired with [[`iox2_server_receive`](@ref)], otherwise false.

# Arguments

* `handle` - Must be a valid [[`iox2_server_h_ref`](@ref)] obtained by [[`iox2_port_factory_subscriber_builder_create`](@ref)](crate::[`iox2_port_factory_subscriber_builder_create`](@ref)). * `result_ptr` - A non-null pointer to a bool that will contain the result.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_connection_failure_e`](@ref)](crate::[`iox2_connection_failure_e`](@ref)) otherwise. Attention, an empty server queue is not an error and even with [`IOX2_OK`](@ref) it is possible to get a NULL in `request_handle_ptr`.

# Safety

* The `handle` is still valid after the return of this function and can be use in another function call. * The `result_ptr` is pointing to a valid bool.

### Prototype
```c
int iox2_server_has_requests(iox2_server_h_ref handle, bool *result_ptr);
```
"""
function iox2_server_has_requests(handle, result_ptr)
    @ccall libiceoryx2_ffi_c.iox2_server_has_requests(handle::iox2_server_h_ref, result_ptr::Ptr{Bool})::Cint
end

"""
    iox2_server_initial_max_slice_len(handle)

Returns the initial max slice len of the server. In the dynamic memory case, slice lenght might increase over time.

# Safety

* `handle` - Must be a valid [[`iox2_server_h_ref`](@ref)] obtained by [[`iox2_port_factory_server_builder_create`](@ref)](crate::[`iox2_port_factory_server_builder_create`](@ref)).

### Prototype
```c
c_size_t iox2_server_initial_max_slice_len(iox2_server_h_ref handle);
```
"""
function iox2_server_initial_max_slice_len(handle)
    @ccall libiceoryx2_ffi_c.iox2_server_initial_max_slice_len(handle::iox2_server_h_ref)::c_size_t
end

"""
    iox2_server_receive(server_handle, active_request_struct_ptr, active_request_handle_ptr)

Takes a request ouf of the server queue.

# Arguments

* `server_handle` - Must be a valid [[`iox2_server_h_ref`](@ref)] obtained by [[`iox2_port_factory_server_builder_create`](@ref)](crate::[`iox2_port_factory_server_builder_create`](@ref)). * `active_request_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_active_request_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `active_request_handle_ptr` - An uninitialized or dangling [[`iox2_active_request_h`](@ref)] handle which will be initialized by this function call if a request is obtained, otherwise it will be set to NULL.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_receive_error_e`](@ref)](crate::[`iox2_receive_error_e`](@ref)) otherwise. Attention, an empty server queue is not an error and even with [`IOX2_OK`](@ref) it is possible to get a NULL in `active_request_handle_ptr`.

# Safety

* The `server_handle` is still valid after the return of this function and can be used in another function call. * The `active_request_handle_ptr` is pointing to a valid [[`iox2_active_request_h`](@ref)].

### Prototype
```c
int iox2_server_receive(iox2_server_h_ref server_handle, struct iox2_active_request_t *active_request_struct_ptr, iox2_active_request_h *active_request_handle_ptr);
```
"""
function iox2_server_receive(server_handle, active_request_struct_ptr, active_request_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_server_receive(server_handle::iox2_server_h_ref, active_request_struct_ptr::Ptr{iox2_active_request_t}, active_request_handle_ptr::Ptr{iox2_active_request_h})::Cint
end

"""
    iox2_server_drop(handle)

This function needs to be called to destroy the server!

# Arguments

* `handle` - A valid [[`iox2_server_h`](@ref)]

# Safety

* The `handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_server_t`](@ref)] can be re-used with a call to [[`iox2_port_factory_subscriber_builder_create`](@ref)](crate::[`iox2_port_factory_subscriber_builder_create`](@ref))!

### Prototype
```c
void iox2_server_drop(iox2_server_h handle);
```
"""
function iox2_server_drop(handle)
    @ccall libiceoryx2_ffi_c.iox2_server_drop(handle::iox2_server_h)::Cvoid
end

"""
    iox2_server_details_server_id(handle, id_struct_ptr, id_handle_ptr)

Returns the unique port id of the server.

# Safety

* `handle` valid pointer to the server details * `id_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_unique_server_id_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `id_handle_ptr` valid pointer to a [[`iox2_unique_server_id_h`](@ref)].

### Prototype
```c
void iox2_server_details_server_id(iox2_server_details_ptr handle, struct iox2_unique_server_id_t *id_struct_ptr, iox2_unique_server_id_h *id_handle_ptr);
```
"""
function iox2_server_details_server_id(handle, id_struct_ptr, id_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_server_details_server_id(handle::iox2_server_details_ptr, id_struct_ptr::Ptr{iox2_unique_server_id_t}, id_handle_ptr::Ptr{iox2_unique_server_id_h})::Cvoid
end

"""
    iox2_server_details_node_id(handle)

Returns the [[`iox2_node_id_ptr`](@ref)](crate::[`iox2_node_id_ptr`](@ref)), an immutable pointer to the node id.

# Safety

* `handle` valid pointer to the server details

### Prototype
```c
iox2_node_id_ptr iox2_server_details_node_id(iox2_server_details_ptr handle);
```
"""
function iox2_server_details_node_id(handle)
    @ccall libiceoryx2_ffi_c.iox2_server_details_node_id(handle::iox2_server_details_ptr)::iox2_node_id_ptr
end

"""
    iox2_server_details_request_buffer_size(handle)

Returns the receive buffer size for incoming requests.

# Safety

* `handle` valid pointer to the server details

### Prototype
```c
c_size_t iox2_server_details_request_buffer_size(iox2_server_details_ptr handle);
```
"""
function iox2_server_details_request_buffer_size(handle)
    @ccall libiceoryx2_ffi_c.iox2_server_details_request_buffer_size(handle::iox2_server_details_ptr)::c_size_t
end

"""
    iox2_server_details_number_of_responses(handle)

Returns the total number of responses available in the servers data segment

# Safety

* `handle` valid pointer to the server details

### Prototype
```c
c_size_t iox2_server_details_number_of_responses(iox2_server_details_ptr handle);
```
"""
function iox2_server_details_number_of_responses(handle)
    @ccall libiceoryx2_ffi_c.iox2_server_details_number_of_responses(handle::iox2_server_details_ptr)::c_size_t
end

"""
    iox2_server_details_max_slice_len(handle)

The current maximum length of a slice.

# Safety

* `handle` valid pointer to the server details

### Prototype
```c
c_size_t iox2_server_details_max_slice_len(iox2_server_details_ptr handle);
```
"""
function iox2_server_details_max_slice_len(handle)
    @ccall libiceoryx2_ffi_c.iox2_server_details_max_slice_len(handle::iox2_server_details_ptr)::c_size_t
end

"""
    iox2_service_details_error_string(error)

Returns a string literal describing the provided [[`iox2_service_details_error_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_service_details_error_string(enum iox2_service_details_error_e error);
```
"""
function iox2_service_details_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_service_details_error_string(error::iox2_service_details_error_e)::Cstring
end

"""
    iox2_service_list_error_string(error)

Returns a string literal describing the provided [[`iox2_service_list_error_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_service_list_error_string(enum iox2_service_list_error_e error);
```
"""
function iox2_service_list_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_service_list_error_string(error::iox2_service_list_error_e)::Cstring
end

"""
    iox2_service_does_exist(service_type, service_name, config, messaging_pattern, does_exist)

Checks if a specified service exists. If the service exists `does_exist` will contain true, otherwise false after the call. On error it returns [`iox2_service_details_error_e`](@ref), on success [`IOX2_OK`](@ref).

# Safety

* The `service_name` must be valid and non-null * The `config` must be valid and non-null * The `does_exist` must be valid and non-null

### Prototype
```c
int iox2_service_does_exist(enum iox2_service_type_e service_type, iox2_service_name_ptr service_name, iox2_config_ptr config, enum iox2_messaging_pattern_e messaging_pattern, bool *does_exist);
```
"""
function iox2_service_does_exist(service_type, service_name, config, messaging_pattern, does_exist)
    @ccall libiceoryx2_ffi_c.iox2_service_does_exist(service_type::iox2_service_type_e, service_name::iox2_service_name_ptr, config::iox2_config_ptr, messaging_pattern::iox2_messaging_pattern_e, does_exist::Ptr{Bool})::Cint
end

"""
    iox2_service_details(service_type, service_name, config, messaging_pattern, service_details, does_exist)

Acquires the service details of a specified service. If the service exists `service_details` will contain the requested information, otherwise it is NULL. On error it returns [`iox2_service_details_error_e`](@ref), on success [`IOX2_OK`](@ref).

# Safety

* The `service_name` must be valid and non-null * The `config` must be valid and non-null * The `service_details` must be valid and non-null * The `does_exist` must be valid and non-null

### Prototype
```c
int iox2_service_details(enum iox2_service_type_e service_type, iox2_service_name_ptr service_name, iox2_config_ptr config, enum iox2_messaging_pattern_e messaging_pattern, struct iox2_static_config_t *service_details, bool *does_exist);
```
"""
function iox2_service_details(service_type, service_name, config, messaging_pattern, service_details, does_exist)
    @ccall libiceoryx2_ffi_c.iox2_service_details(service_type::iox2_service_type_e, service_name::iox2_service_name_ptr, config::iox2_config_ptr, messaging_pattern::iox2_messaging_pattern_e, service_details::Ptr{iox2_static_config_t}, does_exist::Ptr{Bool})::Cint
end

"""
    iox2_service_list(service_type, config_ptr, callback, callback_ctx)

Iterates over the all accessible services and calls the provided callback for every service with [`iox2_service_details`](@ref) as input argument. On error it returns [`iox2_service_list_error_e`](@ref), otherwise [`IOX2_OK`](@ref).

# Safety

* The `config` must be valid and non-null * The `callback` must be valid and non-null

### Prototype
```c
int iox2_service_list(enum iox2_service_type_e service_type, iox2_config_ptr config_ptr, iox2_service_list_callback callback, iox2_callback_context callback_ctx);
```
"""
function iox2_service_list(service_type, config_ptr, callback, callback_ctx)
    @ccall libiceoryx2_ffi_c.iox2_service_list(service_type::iox2_service_type_e, config_ptr::iox2_config_ptr, callback::iox2_service_list_callback, callback_ctx::iox2_callback_context)::Cint
end

"""
    iox2_service_builder_event(service_builder_handle)

This function transform the [[`iox2_service_builder_h`](@ref)] to an event service builder.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_event_h`](@ref)] obtained by [[`iox2_node_service_builder`](@ref)](crate::[`iox2_node_service_builder`](@ref))

Returns a [[`iox2_service_builder_event_h`](@ref)] for the event service builder

# Safety

* The `service_builder_handle` is invalid after this call; The corresponding [`iox2_service_builder_t`](@ref) is now owned by the returned handle.

### Prototype
```c
iox2_service_builder_event_h iox2_service_builder_event(iox2_service_builder_h service_builder_handle);
```
"""
function iox2_service_builder_event(service_builder_handle)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_event(service_builder_handle::iox2_service_builder_h)::iox2_service_builder_event_h
end

"""
    iox2_service_builder_pub_sub(service_builder_handle)

This function transform the [[`iox2_service_builder_h`](@ref)] to a publish-subscribe service builder.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_pub_sub_h`](@ref)] obtained by [[`iox2_node_service_builder`](@ref)](crate::[`iox2_node_service_builder`](@ref))

Returns a [[`iox2_service_builder_pub_sub_h`](@ref)] for the publish-subscribe service builder

# Safety

* The `service_builder_handle` is invalid after this call; The corresponding [`iox2_service_builder_t`](@ref) is now owned by the returned handle.

### Prototype
```c
iox2_service_builder_pub_sub_h iox2_service_builder_pub_sub(iox2_service_builder_h service_builder_handle);
```
"""
function iox2_service_builder_pub_sub(service_builder_handle)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_pub_sub(service_builder_handle::iox2_service_builder_h)::iox2_service_builder_pub_sub_h
end

"""
    iox2_service_builder_request_response(service_builder_handle)

This function transform the [[`iox2_service_builder_h`](@ref)] to a request-response service builder.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_h`](@ref)] obtained by [[`iox2_node_service_builder`](@ref)](crate::[`iox2_node_service_builder`](@ref))

Returns a [[`iox2_service_builder_request_response_h`](@ref)] for the request-response service builder

# Safety

* The `service_builder_handle` is invalid after this call; The corresponding [`iox2_service_builder_t`](@ref) is now owned by the returned handle.

### Prototype
```c
iox2_service_builder_request_response_h iox2_service_builder_request_response(iox2_service_builder_h service_builder_handle);
```
"""
function iox2_service_builder_request_response(service_builder_handle)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_request_response(service_builder_handle::iox2_service_builder_h)::iox2_service_builder_request_response_h
end

"""
    iox2_service_builder_blackboard_creator(service_builder_handle)

This function transforms the [[`iox2_service_builder_h`](@ref)] to a blackboard service creator.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_h`](@ref)] obtained by [[`iox2_node_service_builder`](@ref)](crate::[`iox2_node_service_builder`](@ref))

Returns a [[`iox2_service_builder_blackboard_creator_h`](@ref)] for the blackboard service creator

# Safety

* The `service_builder_handle` is invalid after this call; The corresponding [`iox2_service_builder_t`](@ref) is now owned by the returned handle.

### Prototype
```c
iox2_service_builder_blackboard_creator_h iox2_service_builder_blackboard_creator(iox2_service_builder_h service_builder_handle);
```
"""
function iox2_service_builder_blackboard_creator(service_builder_handle)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_blackboard_creator(service_builder_handle::iox2_service_builder_h)::iox2_service_builder_blackboard_creator_h
end

"""
    iox2_service_builder_blackboard_opener(service_builder_handle)

This function transforms the [[`iox2_service_builder_h`](@ref)] to a blackboard service opener.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_h`](@ref)] obtained by [[`iox2_node_service_builder`](@ref)](crate::[`iox2_node_service_builder`](@ref))

Returns a [[`iox2_service_builder_blackboard_opener_h`](@ref)] for the blackboard service opener

# Safety

* The `service_builder_handle` is invalid after this call; The corresponding [`iox2_service_builder_t`](@ref) is now owned by the returned handle.

### Prototype
```c
iox2_service_builder_blackboard_opener_h iox2_service_builder_blackboard_opener(iox2_service_builder_h service_builder_handle);
```
"""
function iox2_service_builder_blackboard_opener(service_builder_handle)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_blackboard_opener(service_builder_handle::iox2_service_builder_h)::iox2_service_builder_blackboard_opener_h
end

"""
    iox2_blackboard_open_error_string(error)

Returns a string literal describing the provided [[`iox2_blackboard_open_error_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_blackboard_open_error_string(enum iox2_blackboard_open_error_e error);
```
"""
function iox2_blackboard_open_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_blackboard_open_error_string(error::iox2_blackboard_open_error_e)::Cstring
end

"""
    iox2_blackboard_create_error_string(error)

Returns a string literal describing the provided [[`iox2_blackboard_create_error_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_blackboard_create_error_string(enum iox2_blackboard_create_error_e error);
```
"""
function iox2_blackboard_create_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_blackboard_create_error_string(error::iox2_blackboard_create_error_e)::Cstring
end

"""
    iox2_service_builder_blackboard_creator_set_key_type_details(service_builder_handle, type_name_str, type_name_len, size, alignment)

Sets the key type details for the creator. The key type must be fixed size.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_blackboard_creator_h_ref`](@ref)] obtained by [[`iox2_service_builder_blackboard_creator`](@ref)](crate::[`iox2_service_builder_blackboard_creator`](@ref)). * `type_name_str` - Name of the key type. * `type_name_len` - The length of the type name string, not including a null * `size` - The size of the key type * `alignment` - The alignment of the key type

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_type_detail_error_e`](@ref)](crate::[`iox2_type_detail_error_e`](@ref)) otherwise.

# Safety

* `service_builder_handle` must be a valid handle * `type_name_str` must be a valid pointer to an utf8 string * `size` and `alignment` must satisfy the Rust `Layout` type requirements

### Prototype
```c
int iox2_service_builder_blackboard_creator_set_key_type_details(iox2_service_builder_blackboard_creator_h_ref service_builder_handle, const char *type_name_str, c_size_t type_name_len, c_size_t size, c_size_t alignment);
```
"""
function iox2_service_builder_blackboard_creator_set_key_type_details(service_builder_handle, type_name_str, type_name_len, size, alignment)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_blackboard_creator_set_key_type_details(service_builder_handle::iox2_service_builder_blackboard_creator_h_ref, type_name_str::Cstring, type_name_len::c_size_t, size::c_size_t, alignment::c_size_t)::Cint
end

"""
    iox2_service_builder_blackboard_opener_set_key_type_details(service_builder_handle, type_name_str, type_name_len, size, alignment)

Sets the key type details for the opener. The key type must be fixed size.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_blackboard_opener_h_ref`](@ref)] obtained by [[`iox2_service_builder_blackboard_opener`](@ref)](crate::[`iox2_service_builder_blackboard_opener`](@ref)). * `type_name_str` - Name of the key type. * `type_name_len` - The length of the type name string, not including a null * `size` - The size of the key type * `alignment` - The alignment of the key type

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_type_detail_error_e`](@ref)](crate::[`iox2_type_detail_error_e`](@ref)) otherwise.

# Safety

* `service_builder_handle` must be a valid handle * `type_name_str` must be a valid pointer to an utf8 string * `size` and `alignment` must satisfy the Rust `Layout` type requirements

### Prototype
```c
int iox2_service_builder_blackboard_opener_set_key_type_details(iox2_service_builder_blackboard_opener_h_ref service_builder_handle, const char *type_name_str, c_size_t type_name_len, c_size_t size, c_size_t alignment);
```
"""
function iox2_service_builder_blackboard_opener_set_key_type_details(service_builder_handle, type_name_str, type_name_len, size, alignment)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_blackboard_opener_set_key_type_details(service_builder_handle::iox2_service_builder_blackboard_opener_h_ref, type_name_str::Cstring, type_name_len::c_size_t, size::c_size_t, alignment::c_size_t)::Cint
end

"""
    iox2_service_builder_blackboard_creator_set_key_eq_comparison_function(service_builder_handle, key_eq_func)

Sets the key eqaulity comparison function.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_blackboard_creator_h_ref`](@ref)] obtained by [[`iox2_service_builder_blackboard_creator`](@ref)](crate::[`iox2_service_builder_blackboard_creator`](@ref)). * `key_eq_func` - The function to compare blackboard keys.

# Safety

* `service_builder_handle` must be a valid handle

### Prototype
```c
void iox2_service_builder_blackboard_creator_set_key_eq_comparison_function(iox2_service_builder_blackboard_creator_h_ref service_builder_handle, iox2_service_blackboard_key_eq_cmp_func key_eq_func);
```
"""
function iox2_service_builder_blackboard_creator_set_key_eq_comparison_function(service_builder_handle, key_eq_func)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_blackboard_creator_set_key_eq_comparison_function(service_builder_handle::iox2_service_builder_blackboard_creator_h_ref, key_eq_func::iox2_service_blackboard_key_eq_cmp_func)::Cvoid
end

"""
    iox2_service_builder_blackboard_creator_set_max_readers(service_builder_handle, value)

Sets the max readers for the creator

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_blackboard_creator_h_ref`](@ref)] obtained by [[`iox2_service_builder_blackboard_creator`](@ref)](crate::[`iox2_service_builder_blackboard_creator`](@ref)). * `value` - The value to set the max readers to

# Safety

* `service_builder_handle` must be a valid and non-null handle

### Prototype
```c
void iox2_service_builder_blackboard_creator_set_max_readers(iox2_service_builder_blackboard_creator_h_ref service_builder_handle, c_size_t value);
```
"""
function iox2_service_builder_blackboard_creator_set_max_readers(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_blackboard_creator_set_max_readers(service_builder_handle::iox2_service_builder_blackboard_creator_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_service_builder_blackboard_opener_set_max_readers(service_builder_handle, value)

Sets the max readers for the opener

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_blackboard_opener_h_ref`](@ref)] obtained by [[`iox2_service_builder_blackboard_opener`](@ref)](crate::[`iox2_service_builder_blackboard_opener`](@ref)). * `value` - The value to set the max readers to

# Safety

* `service_builder_handle` must be a valid and non-null handle

### Prototype
```c
void iox2_service_builder_blackboard_opener_set_max_readers(iox2_service_builder_blackboard_opener_h_ref service_builder_handle, c_size_t value);
```
"""
function iox2_service_builder_blackboard_opener_set_max_readers(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_blackboard_opener_set_max_readers(service_builder_handle::iox2_service_builder_blackboard_opener_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_service_builder_blackboard_creator_set_max_nodes(service_builder_handle, value)

Sets the max nodes for the creator

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_blackboard_creator_h_ref`](@ref)] obtained by [[`iox2_service_builder_blackboard_creator`](@ref)](crate::[`iox2_service_builder_blackboard_creator`](@ref)). * `value` - The value to set the max nodes to

# Safety

* `service_builder_handle` must be a valid and non-null handle

### Prototype
```c
void iox2_service_builder_blackboard_creator_set_max_nodes(iox2_service_builder_blackboard_creator_h_ref service_builder_handle, c_size_t value);
```
"""
function iox2_service_builder_blackboard_creator_set_max_nodes(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_blackboard_creator_set_max_nodes(service_builder_handle::iox2_service_builder_blackboard_creator_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_service_builder_blackboard_opener_set_max_nodes(service_builder_handle, value)

Sets the max nodes for the opener

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_blackboard_opener_h_ref`](@ref)] obtained by [[`iox2_service_builder_blackboard_opener`](@ref)](crate::[`iox2_service_builder_blackboard_opener`](@ref)). * `value` - The value to set the max nodes to

# Safety

* `service_builder_handle` must be a valid and non-null handle

### Prototype
```c
void iox2_service_builder_blackboard_opener_set_max_nodes(iox2_service_builder_blackboard_opener_h_ref service_builder_handle, c_size_t value);
```
"""
function iox2_service_builder_blackboard_opener_set_max_nodes(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_blackboard_opener_set_max_nodes(service_builder_handle::iox2_service_builder_blackboard_opener_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_service_builder_blackboard_creator_add(service_builder_handle, key, value_ptr, release_callback, type_name, type_name_len, type_size, type_align)

Adds key-value pairs to the blackboard.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_blackboard_creator_h_ref`](@ref)] obtained by [[`iox2_service_builder_blackboard_creator`](@ref)](crate::[`iox2_service_builder_blackboard_creator`](@ref)). * `key` - The key that shall be added to the blackboard * `value_ptr` - a valid, non-null [`*mut c\\_void`] pointer which points to the value to be stored * `release_callback` - a valid callback with [[`iox2_service_blackboard_creator_add_release_callback`](@ref)] signature for the `value_ptr` cleanup * `type_name` - the name of the value type * `type_name_len` - the length of `type_name` * `type_size` - the size of the value type to be added to the blackboard * `type_alignment` - the alignment of the value type to be added to the blackboard

# Safety

* `service_builder_handle` must be a valid and non-null handle * `value_ptr` is valid and non-null * `release_callback` must take care of the cleanup for `value_ptr` * `type_name`, `type_name_len`, `type_size` and `type_align` must satisfy the type details of the value type

### Prototype
```c
void iox2_service_builder_blackboard_creator_add(iox2_service_builder_blackboard_creator_h_ref service_builder_handle, const void *key, void *value_ptr, iox2_service_blackboard_creator_add_release_callback release_callback, const char *type_name, size_t type_name_len, size_t type_size, size_t type_align);
```
"""
function iox2_service_builder_blackboard_creator_add(service_builder_handle, key, value_ptr, release_callback, type_name, type_name_len, type_size, type_align)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_blackboard_creator_add(service_builder_handle::iox2_service_builder_blackboard_creator_h_ref, key::Ptr{Cvoid}, value_ptr::Ptr{Cvoid}, release_callback::iox2_service_blackboard_creator_add_release_callback, type_name::Cstring, type_name_len::Csize_t, type_size::Csize_t, type_align::Csize_t)::Cvoid
end

"""
    iox2_service_builder_blackboard_open(service_builder_handle, port_factory_struct_ptr, port_factory_handle_ptr)

Opens a blackboard service and returns a port factory to create writers and readers.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_blackboard_opener_h`](@ref)] obtained by [[`iox2_service_builder_blackboard_opener`](@ref)](crate::[`iox2_service_builder_blackboard_opener`](@ref)) * `port_factory_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_blackboard_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `port_factory_handle_ptr` - An uninitialized or dangling [[`iox2_port_factory_blackboard_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_blackboard_open_error_e`](@ref)] otherwise.

# Safety

* The `service_builder_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call!

### Prototype
```c
int iox2_service_builder_blackboard_open(iox2_service_builder_blackboard_opener_h service_builder_handle, struct iox2_port_factory_blackboard_t *port_factory_struct_ptr, iox2_port_factory_blackboard_h *port_factory_handle_ptr);
```
"""
function iox2_service_builder_blackboard_open(service_builder_handle, port_factory_struct_ptr, port_factory_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_blackboard_open(service_builder_handle::iox2_service_builder_blackboard_opener_h, port_factory_struct_ptr::Ptr{iox2_port_factory_blackboard_t}, port_factory_handle_ptr::Ptr{iox2_port_factory_blackboard_h})::Cint
end

"""
    iox2_service_builder_blackboard_open_with_attributes(service_builder_handle, attribute_verifier_handle, port_factory_struct_ptr, port_factory_handle_ptr)

Opens a blackboard service and returns a port factory to create writers and readers. The provided attributes are considered as requirements.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_blackboard_opener_h`](@ref)] obtained by [[`iox2_service_builder_blackboard_opener`](@ref)](crate::[`iox2_service_builder_blackboard_opener`](@ref)) * `attribute_verifier_handle` - Must be a valid [[`iox2_attribute_verifier_h_ref`](@ref)] * `port_factory_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_blackboard_t`](@ref)]). If it is a NULL pointer, the storage will be allocated on the heap. * `port_factory_handle_ptr` - An uninitialized or dangling [[`iox2_port_factory_blackboard_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_blackboard_open_error_e`](@ref)] otherwise.

# Safety

* The `service_builder_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The `attribute_verifier_handle` must be valid.

### Prototype
```c
int iox2_service_builder_blackboard_open_with_attributes(iox2_service_builder_blackboard_opener_h service_builder_handle, iox2_attribute_verifier_h_ref attribute_verifier_handle, struct iox2_port_factory_blackboard_t *port_factory_struct_ptr, iox2_port_factory_blackboard_h *port_factory_handle_ptr);
```
"""
function iox2_service_builder_blackboard_open_with_attributes(service_builder_handle, attribute_verifier_handle, port_factory_struct_ptr, port_factory_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_blackboard_open_with_attributes(service_builder_handle::iox2_service_builder_blackboard_opener_h, attribute_verifier_handle::iox2_attribute_verifier_h_ref, port_factory_struct_ptr::Ptr{iox2_port_factory_blackboard_t}, port_factory_handle_ptr::Ptr{iox2_port_factory_blackboard_h})::Cint
end

"""
    iox2_service_builder_blackboard_create(service_builder_handle, port_factory_struct_ptr, port_factory_handle_ptr)

Creates a blackboard service and returns a port factory to create writers and readers.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_blackboard_creator_h`](@ref)](crate::[`iox2_service_builder_blackboard_creator_h`](@ref)) obtained by [[`iox2_service_builder_blackboard_creator`](@ref)](crate::[`iox2_service_builder_blackboard_creator`](@ref)) * `port_factory_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_blackboard_t`](@ref)](crate::[`iox2_port_factory_blackboard_t`](@ref)). If it is a NULL pointer, the storage will be allocated on the heap. * `port_factory_handle_ptr` - An uninitialized or dangling [[`iox2_port_factory_blackboard_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_blackboard_create_error_e`](@ref)] otherwise.

# Safety

* The `service_builder_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call!

### Prototype
```c
int iox2_service_builder_blackboard_create(iox2_service_builder_blackboard_creator_h service_builder_handle, struct iox2_port_factory_blackboard_t *port_factory_struct_ptr, iox2_port_factory_blackboard_h *port_factory_handle_ptr);
```
"""
function iox2_service_builder_blackboard_create(service_builder_handle, port_factory_struct_ptr, port_factory_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_blackboard_create(service_builder_handle::iox2_service_builder_blackboard_creator_h, port_factory_struct_ptr::Ptr{iox2_port_factory_blackboard_t}, port_factory_handle_ptr::Ptr{iox2_port_factory_blackboard_h})::Cint
end

"""
    iox2_service_builder_blackboard_create_with_attributes(service_builder_handle, attribute_specifier_handle, port_factory_struct_ptr, port_factory_handle_ptr)

Creates a service if it does not exist and returns a port factory to create writers and readers. The provided arguments are stored inside the services.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_blackboard_creator_h`](@ref)] obtained by [[`iox2_service_builder_blackboard_creator`](@ref)](crate::[`iox2_service_builder_blackboard_creator`](@ref)) * `attribute_specifier_handle` - Must be a valid [[`iox2_attribute_specifier_h_ref`](@ref)] * `port_factory_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_blackboard_t`](@ref)]). If it is a NULL pointer, the storage will be allocated on the heap. * `port_factory_handle_ptr` - An uninitialized or dangling [[`iox2_port_factory_blackboard_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_blackboard_create_error_e`](@ref)] otherwise.

# Safety

* The `service_builder_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_service_builder_t`](@ref)](crate::[`iox2_service_builder_t`](@ref)) can be re-used with a call to [[`iox2_node_service_builder`](@ref)](crate::[`iox2_node_service_builder`](@ref))! * The `attribute_verifier_handle` must be valid.

### Prototype
```c
int iox2_service_builder_blackboard_create_with_attributes(iox2_service_builder_blackboard_creator_h service_builder_handle, iox2_attribute_specifier_h_ref attribute_specifier_handle, struct iox2_port_factory_blackboard_t *port_factory_struct_ptr, iox2_port_factory_blackboard_h *port_factory_handle_ptr);
```
"""
function iox2_service_builder_blackboard_create_with_attributes(service_builder_handle, attribute_specifier_handle, port_factory_struct_ptr, port_factory_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_blackboard_create_with_attributes(service_builder_handle::iox2_service_builder_blackboard_creator_h, attribute_specifier_handle::iox2_attribute_specifier_h_ref, port_factory_struct_ptr::Ptr{iox2_port_factory_blackboard_t}, port_factory_handle_ptr::Ptr{iox2_port_factory_blackboard_h})::Cint
end

"""
    iox2_event_open_or_create_error_string(error)

Returns a string literal describing the provided [[`iox2_event_open_or_create_error_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_event_open_or_create_error_string(enum iox2_event_open_or_create_error_e error);
```
"""
function iox2_event_open_or_create_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_event_open_or_create_error_string(error::iox2_event_open_or_create_error_e)::Cstring
end

"""
    iox2_service_builder_event_set_deadline(service_builder_handle, seconds, nanoseconds)

Enables the deadline property of the service. There must be a notification emitted by any notifier after at least the provided `deadline`.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_event_h_ref`](@ref)] obtained by [[`iox2_service_builder_event`](@ref)](crate::[`iox2_service_builder_event`](@ref)). * `seconds` - the second part of the deadline * `nanoseconds` - the nanosecond part of the deadline

# Safety

* `service_builder_handle` must be valid handles

### Prototype
```c
void iox2_service_builder_event_set_deadline(iox2_service_builder_event_h_ref service_builder_handle, uint64_t seconds, uint32_t nanoseconds);
```
"""
function iox2_service_builder_event_set_deadline(service_builder_handle, seconds, nanoseconds)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_event_set_deadline(service_builder_handle::iox2_service_builder_event_h_ref, seconds::UInt64, nanoseconds::UInt32)::Cvoid
end

"""
    iox2_service_builder_event_disable_deadline(service_builder_handle)

Disables the deadline property of the service.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_event_h_ref`](@ref)] obtained by [[`iox2_service_builder_event`](@ref)](crate::[`iox2_service_builder_event`](@ref)).

# Safety

* `service_builder_handle` must be valid handles

### Prototype
```c
void iox2_service_builder_event_disable_deadline(iox2_service_builder_event_h_ref service_builder_handle);
```
"""
function iox2_service_builder_event_disable_deadline(service_builder_handle)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_event_disable_deadline(service_builder_handle::iox2_service_builder_event_h_ref)::Cvoid
end

"""
    iox2_service_builder_event_set_notifier_dead_event(service_builder_handle, value)

Sets the event id value that shall be emitted if a notifier was identified as dead.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_event_h_ref`](@ref)] obtained by [[`iox2_service_builder_event`](@ref)](crate::[`iox2_service_builder_event`](@ref)). * `value` - the value of the event id that will be emitted.

# Safety

* `service_builder_handle` must be valid handles

### Prototype
```c
void iox2_service_builder_event_set_notifier_dead_event(iox2_service_builder_event_h_ref service_builder_handle, c_size_t value);
```
"""
function iox2_service_builder_event_set_notifier_dead_event(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_event_set_notifier_dead_event(service_builder_handle::iox2_service_builder_event_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_service_builder_event_disable_notifier_dead_event(service_builder_handle)

Disables event id notification when a notifier was identified as dead.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_event_h_ref`](@ref)] obtained by [[`iox2_service_builder_event`](@ref)](crate::[`iox2_service_builder_event`](@ref)).

# Safety

* `service_builder_handle` must be valid handles

### Prototype
```c
void iox2_service_builder_event_disable_notifier_dead_event(iox2_service_builder_event_h_ref service_builder_handle);
```
"""
function iox2_service_builder_event_disable_notifier_dead_event(service_builder_handle)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_event_disable_notifier_dead_event(service_builder_handle::iox2_service_builder_event_h_ref)::Cvoid
end

"""
    iox2_service_builder_event_set_notifier_created_event(service_builder_handle, value)

Sets the event id value that shall be emitted after a notifier was created.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_event_h_ref`](@ref)] obtained by [[`iox2_service_builder_event`](@ref)](crate::[`iox2_service_builder_event`](@ref)). * `value` - the value of the event id that will be emitted.

# Safety

* `service_builder_handle` must be valid handles

### Prototype
```c
void iox2_service_builder_event_set_notifier_created_event(iox2_service_builder_event_h_ref service_builder_handle, c_size_t value);
```
"""
function iox2_service_builder_event_set_notifier_created_event(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_event_set_notifier_created_event(service_builder_handle::iox2_service_builder_event_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_service_builder_event_disable_notifier_created_event(service_builder_handle)

Disables the event id value that shall be emitted after a notifier was created.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_event_h_ref`](@ref)] obtained by [[`iox2_service_builder_event`](@ref)](crate::[`iox2_service_builder_event`](@ref)).

# Safety

* `service_builder_handle` must be valid handles

### Prototype
```c
void iox2_service_builder_event_disable_notifier_created_event(iox2_service_builder_event_h_ref service_builder_handle);
```
"""
function iox2_service_builder_event_disable_notifier_created_event(service_builder_handle)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_event_disable_notifier_created_event(service_builder_handle::iox2_service_builder_event_h_ref)::Cvoid
end

"""
    iox2_service_builder_event_set_notifier_dropped_event(service_builder_handle, value)

Sets the event id value that shall be emitted before a notifier is dropped.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_event_h_ref`](@ref)] obtained by [[`iox2_service_builder_event`](@ref)](crate::[`iox2_service_builder_event`](@ref)). * `value` - the value of the event id that will be emitted.

# Safety

* `service_builder_handle` must be valid handles

### Prototype
```c
void iox2_service_builder_event_set_notifier_dropped_event(iox2_service_builder_event_h_ref service_builder_handle, c_size_t value);
```
"""
function iox2_service_builder_event_set_notifier_dropped_event(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_event_set_notifier_dropped_event(service_builder_handle::iox2_service_builder_event_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_service_builder_event_disable_notifier_dropped_event(service_builder_handle)

Disables the event id value that shall be emitted before a notifier is dropped.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_event_h_ref`](@ref)] obtained by [[`iox2_service_builder_event`](@ref)](crate::[`iox2_service_builder_event`](@ref)).

# Safety

* `service_builder_handle` must be valid handles

### Prototype
```c
void iox2_service_builder_event_disable_notifier_dropped_event(iox2_service_builder_event_h_ref service_builder_handle);
```
"""
function iox2_service_builder_event_disable_notifier_dropped_event(service_builder_handle)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_event_disable_notifier_dropped_event(service_builder_handle::iox2_service_builder_event_h_ref)::Cvoid
end

"""
    iox2_service_builder_event_set_max_notifiers(service_builder_handle, value)

Sets the max notifiers for the builder

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_event_h_ref`](@ref)] obtained by [[`iox2_service_builder_event`](@ref)](crate::[`iox2_service_builder_event`](@ref)). * `value` - The value to set the max notifiers to

# Safety

* `service_builder_handle` must be valid handles

### Prototype
```c
void iox2_service_builder_event_set_max_notifiers(iox2_service_builder_event_h_ref service_builder_handle, c_size_t value);
```
"""
function iox2_service_builder_event_set_max_notifiers(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_event_set_max_notifiers(service_builder_handle::iox2_service_builder_event_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_service_builder_event_set_max_nodes(service_builder_handle, value)

Sets the max nodes for the builder

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_event_h_ref`](@ref)] obtained by [[`iox2_service_builder_event`](@ref)](crate::[`iox2_service_builder_event`](@ref)). * `value` - The value to set the max notifiers to

# Safety

* `service_builder_handle` must be valid handles

### Prototype
```c
void iox2_service_builder_event_set_max_nodes(iox2_service_builder_event_h_ref service_builder_handle, c_size_t value);
```
"""
function iox2_service_builder_event_set_max_nodes(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_event_set_max_nodes(service_builder_handle::iox2_service_builder_event_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_service_builder_event_set_event_id_max_value(service_builder_handle, value)

Sets the max event id value for the builder

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_event_h_ref`](@ref)] obtained by [[`iox2_service_builder_event`](@ref)](crate::[`iox2_service_builder_event`](@ref)). * `value` - The value to set the max notifiers to

# Safety

* `service_builder_handle` must be valid handles

### Prototype
```c
void iox2_service_builder_event_set_event_id_max_value(iox2_service_builder_event_h_ref service_builder_handle, c_size_t value);
```
"""
function iox2_service_builder_event_set_event_id_max_value(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_event_set_event_id_max_value(service_builder_handle::iox2_service_builder_event_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_service_builder_event_set_max_listeners(service_builder_handle, value)

Sets the max listeners for the builder

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_event_h_ref`](@ref)] obtained by [[`iox2_service_builder_event`](@ref)](crate::[`iox2_service_builder_event`](@ref)). * `value` - The value to set the max listeners to

# Safety

* `service_builder_handle` must be valid handles

### Prototype
```c
void iox2_service_builder_event_set_max_listeners(iox2_service_builder_event_h_ref service_builder_handle, c_size_t value);
```
"""
function iox2_service_builder_event_set_max_listeners(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_event_set_max_listeners(service_builder_handle::iox2_service_builder_event_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_service_builder_event_open_or_create(service_builder_handle, port_factory_struct_ptr, port_factory_handle_ptr)

Opens an event service or creates the service if it does not exist and returns a port factory to create notifiers and listeners.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_event_h`](@ref)] obtained by [[`iox2_service_builder_event`](@ref)](crate::[`iox2_service_builder_event`](@ref)) * `port_factory_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_event_t`](@ref)]). If it is a NULL pointer, the storage will be allocated on the heap. * `port_factory_handle_ptr` - An uninitialized or dangling [[`iox2_port_factory_event_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_event_open_or_create_error_e`](@ref)] otherwise.

# Safety

* The `service_builder_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_service_builder_t`](@ref)](crate::[`iox2_service_builder_t`](@ref)) can be re-used with a call to [[`iox2_node_service_builder`](@ref)](crate::[`iox2_node_service_builder`](@ref))!

### Prototype
```c
int iox2_service_builder_event_open_or_create(iox2_service_builder_event_h service_builder_handle, struct iox2_port_factory_event_t *port_factory_struct_ptr, iox2_port_factory_event_h *port_factory_handle_ptr);
```
"""
function iox2_service_builder_event_open_or_create(service_builder_handle, port_factory_struct_ptr, port_factory_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_event_open_or_create(service_builder_handle::iox2_service_builder_event_h, port_factory_struct_ptr::Ptr{iox2_port_factory_event_t}, port_factory_handle_ptr::Ptr{iox2_port_factory_event_h})::Cint
end

"""
    iox2_service_builder_event_open_or_create_with_attributes(service_builder_handle, attribute_verifier_handle, port_factory_struct_ptr, port_factory_handle_ptr)

Opens an event service or creates the service if it does not exist and returns a port factory to create notifiers and listeners. If the service does not exist, the provided arguments are stored inside the services, if the service already exists, the provided attributes are considered as requirements.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_event_h`](@ref)] obtained by [[`iox2_service_builder_event`](@ref)](crate::[`iox2_service_builder_event`](@ref)) * `port_factory_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_event_t`](@ref)]). If it is a NULL pointer, the storage will be allocated on the heap. * `port_factory_handle_ptr` - An uninitialized or dangling [[`iox2_port_factory_event_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_event_open_or_create_error_e`](@ref)] otherwise.

# Safety

* The `service_builder_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_service_builder_t`](@ref)](crate::[`iox2_service_builder_t`](@ref)) can be re-used with a call to [[`iox2_node_service_builder`](@ref)](crate::[`iox2_node_service_builder`](@ref))! * The `attribute_verifier_handle` must be valid.

### Prototype
```c
int iox2_service_builder_event_open_or_create_with_attributes(iox2_service_builder_event_h service_builder_handle, iox2_attribute_verifier_h_ref attribute_verifier_handle, struct iox2_port_factory_event_t *port_factory_struct_ptr, iox2_port_factory_event_h *port_factory_handle_ptr);
```
"""
function iox2_service_builder_event_open_or_create_with_attributes(service_builder_handle, attribute_verifier_handle, port_factory_struct_ptr, port_factory_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_event_open_or_create_with_attributes(service_builder_handle::iox2_service_builder_event_h, attribute_verifier_handle::iox2_attribute_verifier_h_ref, port_factory_struct_ptr::Ptr{iox2_port_factory_event_t}, port_factory_handle_ptr::Ptr{iox2_port_factory_event_h})::Cint
end

"""
    iox2_service_builder_event_open(service_builder_handle, port_factory_struct_ptr, port_factory_handle_ptr)

Opens an event service and returns a port factory to create notifiers and listeners.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_event_h`](@ref)] obtained by [[`iox2_service_builder_event`](@ref)](crate::[`iox2_service_builder_event`](@ref)) * `port_factory_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_event_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `port_factory_handle_ptr` - An uninitialized or dangling [[`iox2_port_factory_event_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_event_open_or_create_error_e`](@ref)] otherwise. Note, only the errors annotated with `O_` are relevant.

# Safety

* The `service_builder_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_service_builder_t`](@ref)](crate::[`iox2_service_builder_t`](@ref)) can be re-used with a call to [[`iox2_node_service_builder`](@ref)](crate::[`iox2_node_service_builder`](@ref))!

### Prototype
```c
int iox2_service_builder_event_open(iox2_service_builder_event_h service_builder_handle, struct iox2_port_factory_event_t *port_factory_struct_ptr, iox2_port_factory_event_h *port_factory_handle_ptr);
```
"""
function iox2_service_builder_event_open(service_builder_handle, port_factory_struct_ptr, port_factory_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_event_open(service_builder_handle::iox2_service_builder_event_h, port_factory_struct_ptr::Ptr{iox2_port_factory_event_t}, port_factory_handle_ptr::Ptr{iox2_port_factory_event_h})::Cint
end

"""
    iox2_service_builder_event_open_with_attributes(service_builder_handle, attribute_verifier_handle, port_factory_struct_ptr, port_factory_handle_ptr)

Opens an event service and returns a port factory to create notifiers and listeners. The provided attributes are considered as requirements.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_event_h`](@ref)] obtained by [[`iox2_service_builder_event`](@ref)](crate::[`iox2_service_builder_event`](@ref)) * `port_factory_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_event_t`](@ref)]). If it is a NULL pointer, the storage will be allocated on the heap. * `port_factory_handle_ptr` - An uninitialized or dangling [[`iox2_port_factory_event_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_event_open_or_create_error_e`](@ref)] otherwise.

# Safety

* The `service_builder_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_service_builder_t`](@ref)](crate::[`iox2_service_builder_t`](@ref)) can be re-used with a call to [[`iox2_node_service_builder`](@ref)](crate::[`iox2_node_service_builder`](@ref))! * The `attribute_verifier_handle` must be valid.

### Prototype
```c
int iox2_service_builder_event_open_with_attributes(iox2_service_builder_event_h service_builder_handle, iox2_attribute_verifier_h_ref attribute_verifier_handle, struct iox2_port_factory_event_t *port_factory_struct_ptr, iox2_port_factory_event_h *port_factory_handle_ptr);
```
"""
function iox2_service_builder_event_open_with_attributes(service_builder_handle, attribute_verifier_handle, port_factory_struct_ptr, port_factory_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_event_open_with_attributes(service_builder_handle::iox2_service_builder_event_h, attribute_verifier_handle::iox2_attribute_verifier_h_ref, port_factory_struct_ptr::Ptr{iox2_port_factory_event_t}, port_factory_handle_ptr::Ptr{iox2_port_factory_event_h})::Cint
end

"""
    iox2_service_builder_event_create(service_builder_handle, port_factory_struct_ptr, port_factory_handle_ptr)

Creates an event service and returns a port factory to create notifiers and listeners.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_event_h`](@ref)](crate::[`iox2_service_builder_event_h`](@ref)) obtained by [[`iox2_service_builder_event`](@ref)](crate::[`iox2_service_builder_event`](@ref)) * `port_factory_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_event_t`](@ref)](crate::[`iox2_port_factory_event_t`](@ref)). If it is a NULL pointer, the storage will be allocated on the heap. * `port_factory_handle_ptr` - An uninitialized or dangling [[`iox2_port_factory_event_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_event_open_or_create_error_e`](@ref)] otherwise. Note, only the errors annotated with `O_` are relevant.

# Safety

* The `service_builder_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_service_builder_t`](@ref)](crate::[`iox2_service_builder_t`](@ref)) can be re-used with a call to [[`iox2_node_service_builder`](@ref)](crate::[`iox2_node_service_builder`](@ref))!

### Prototype
```c
int iox2_service_builder_event_create(iox2_service_builder_event_h service_builder_handle, struct iox2_port_factory_event_t *port_factory_struct_ptr, iox2_port_factory_event_h *port_factory_handle_ptr);
```
"""
function iox2_service_builder_event_create(service_builder_handle, port_factory_struct_ptr, port_factory_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_event_create(service_builder_handle::iox2_service_builder_event_h, port_factory_struct_ptr::Ptr{iox2_port_factory_event_t}, port_factory_handle_ptr::Ptr{iox2_port_factory_event_h})::Cint
end

"""
    iox2_service_builder_event_create_with_attributes(service_builder_handle, attribute_specifier_handle, port_factory_struct_ptr, port_factory_handle_ptr)

Creates a service if it does not exist and returns a port factory to create notifiers and listeners. The provided arguments are stored inside the services.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_event_h`](@ref)] obtained by [[`iox2_service_builder_event`](@ref)](crate::[`iox2_service_builder_event`](@ref)) * `port_factory_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_event_t`](@ref)]). If it is a NULL pointer, the storage will be allocated on the heap. * `port_factory_handle_ptr` - An uninitialized or dangling [[`iox2_port_factory_event_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_event_open_or_create_error_e`](@ref)] otherwise.

# Safety

* The `service_builder_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_service_builder_t`](@ref)](crate::[`iox2_service_builder_t`](@ref)) can be re-used with a call to [[`iox2_node_service_builder`](@ref)](crate::[`iox2_node_service_builder`](@ref))! * The `attribute_verifier_handle` must be valid.

### Prototype
```c
int iox2_service_builder_event_create_with_attributes(iox2_service_builder_event_h service_builder_handle, iox2_attribute_specifier_h_ref attribute_specifier_handle, struct iox2_port_factory_event_t *port_factory_struct_ptr, iox2_port_factory_event_h *port_factory_handle_ptr);
```
"""
function iox2_service_builder_event_create_with_attributes(service_builder_handle, attribute_specifier_handle, port_factory_struct_ptr, port_factory_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_event_create_with_attributes(service_builder_handle::iox2_service_builder_event_h, attribute_specifier_handle::iox2_attribute_specifier_h_ref, port_factory_struct_ptr::Ptr{iox2_port_factory_event_t}, port_factory_handle_ptr::Ptr{iox2_port_factory_event_h})::Cint
end

"""
    iox2_pub_sub_open_or_create_error_string(error)

Returns a string literal describing the provided [[`iox2_pub_sub_open_or_create_error_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_pub_sub_open_or_create_error_string(enum iox2_pub_sub_open_or_create_error_e error);
```
"""
function iox2_pub_sub_open_or_create_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_pub_sub_open_or_create_error_string(error::iox2_pub_sub_open_or_create_error_e)::Cstring
end

"""
    iox2_service_builder_pub_sub_set_user_header_type_details(service_builder_handle, type_variant, type_name_str, type_name_len, size, alignment)

Sets the user header type details for the builder

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_pub_sub_h_ref`](@ref)] obtained by [[`iox2_service_builder_pub_sub`](@ref)](crate::[`iox2_service_builder_pub_sub`](@ref)). * `type_variant` - The [[`iox2_type_variant_e`](@ref)] for the payload * `type_name_str` - Must string for the type name. * `type_name_len` - The length of the type name string, not including a null * `size` - The size of the payload * `alignment` - The alignment of the payload

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_type_detail_error_e`](@ref)] otherwise.

# Safety

* `service_builder_handle` must be valid handles * `type_name_str` must be a valid pointer to an utf8 string * `size` and `alignment` must satisfy the Rust `Layout` type requirements

### Prototype
```c
int iox2_service_builder_pub_sub_set_user_header_type_details(iox2_service_builder_pub_sub_h_ref service_builder_handle, enum iox2_type_variant_e type_variant, const char *type_name_str, c_size_t type_name_len, c_size_t size, c_size_t alignment);
```
"""
function iox2_service_builder_pub_sub_set_user_header_type_details(service_builder_handle, type_variant, type_name_str, type_name_len, size, alignment)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_pub_sub_set_user_header_type_details(service_builder_handle::iox2_service_builder_pub_sub_h_ref, type_variant::iox2_type_variant_e, type_name_str::Cstring, type_name_len::c_size_t, size::c_size_t, alignment::c_size_t)::Cint
end

"""
    iox2_service_builder_pub_sub_set_payload_type_details(service_builder_handle, type_variant, type_name_str, type_name_len, size, alignment)

Sets the payload type details for the builder

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_pub_sub_h_ref`](@ref)] obtained by [[`iox2_service_builder_pub_sub`](@ref)](crate::[`iox2_service_builder_pub_sub`](@ref)). * `type_variant` - The [[`iox2_type_variant_e`](@ref)] for the payload * `type_name_str` - Must string for the type name. * `type_name_len` - The length of the type name string, not including a null * `size` - The size of the payload * `alignment` - The alignment of the payload

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_type_detail_error_e`](@ref)] otherwise.

# Safety

* `service_builder_handle` must be valid handles * `type_name_str` must be a valid pointer to an utf8 string * `size` and `alignment` must satisfy the Rust `Layout` type requirements

### Prototype
```c
int iox2_service_builder_pub_sub_set_payload_type_details(iox2_service_builder_pub_sub_h_ref service_builder_handle, enum iox2_type_variant_e type_variant, const char *type_name_str, c_size_t type_name_len, c_size_t size, c_size_t alignment);
```
"""
function iox2_service_builder_pub_sub_set_payload_type_details(service_builder_handle, type_variant, type_name_str, type_name_len, size, alignment)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_pub_sub_set_payload_type_details(service_builder_handle::iox2_service_builder_pub_sub_h_ref, type_variant::iox2_type_variant_e, type_name_str::Cstring, type_name_len::c_size_t, size::c_size_t, alignment::c_size_t)::Cint
end

"""
    iox2_service_builder_pub_sub_set_max_nodes(service_builder_handle, value)

Sets the max nodes for the builder

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_pub_sub_h_ref`](@ref)] obtained by [[`iox2_service_builder_pub_sub`](@ref)](crate::[`iox2_service_builder_pub_sub`](@ref)). * `value` - The value to set the max nodes to

# Safety

* `service_builder_handle` must be valid handles

### Prototype
```c
void iox2_service_builder_pub_sub_set_max_nodes(iox2_service_builder_pub_sub_h_ref service_builder_handle, c_size_t value);
```
"""
function iox2_service_builder_pub_sub_set_max_nodes(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_pub_sub_set_max_nodes(service_builder_handle::iox2_service_builder_pub_sub_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_service_builder_pub_sub_set_max_publishers(service_builder_handle, value)

Sets the max publishers for the builder

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_pub_sub_h_ref`](@ref)] obtained by [[`iox2_service_builder_pub_sub`](@ref)](crate::[`iox2_service_builder_pub_sub`](@ref)). * `value` - The value to set the max publishers to

# Safety

* `service_builder_handle` must be valid handles

### Prototype
```c
void iox2_service_builder_pub_sub_set_max_publishers(iox2_service_builder_pub_sub_h_ref service_builder_handle, c_size_t value);
```
"""
function iox2_service_builder_pub_sub_set_max_publishers(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_pub_sub_set_max_publishers(service_builder_handle::iox2_service_builder_pub_sub_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_service_builder_pub_sub_set_max_subscribers(service_builder_handle, value)

Sets the max subscribers for the builder

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_pub_sub_h_ref`](@ref)] obtained by [[`iox2_service_builder_pub_sub`](@ref)](crate::[`iox2_service_builder_pub_sub`](@ref)). * `value` - The value to set the max subscribers to

# Safety

* `service_builder_handle` must be valid handles

### Prototype
```c
void iox2_service_builder_pub_sub_set_max_subscribers(iox2_service_builder_pub_sub_h_ref service_builder_handle, c_size_t value);
```
"""
function iox2_service_builder_pub_sub_set_max_subscribers(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_pub_sub_set_max_subscribers(service_builder_handle::iox2_service_builder_pub_sub_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_service_builder_pub_sub_set_payload_alignment(service_builder_handle, value)

Sets the payload alignment for the builder

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_pub_sub_h_ref`](@ref)] obtained by [[`iox2_service_builder_pub_sub`](@ref)](crate::[`iox2_service_builder_pub_sub`](@ref)). * `value` - The value to set the payload alignment to

# Safety

* `service_builder_handle` must be valid handles

### Prototype
```c
void iox2_service_builder_pub_sub_set_payload_alignment(iox2_service_builder_pub_sub_h_ref service_builder_handle, c_size_t value);
```
"""
function iox2_service_builder_pub_sub_set_payload_alignment(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_pub_sub_set_payload_alignment(service_builder_handle::iox2_service_builder_pub_sub_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_service_builder_pub_sub_set_history_size(service_builder_handle, value)

Sets the history size

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_pub_sub_h_ref`](@ref)] obtained by [[`iox2_service_builder_pub_sub`](@ref)](crate::[`iox2_service_builder_pub_sub`](@ref)). * `value` - The value to set the history size to

# Safety

* `service_builder_handle` must be valid handles

### Prototype
```c
void iox2_service_builder_pub_sub_set_history_size(iox2_service_builder_pub_sub_h_ref service_builder_handle, c_size_t value);
```
"""
function iox2_service_builder_pub_sub_set_history_size(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_pub_sub_set_history_size(service_builder_handle::iox2_service_builder_pub_sub_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_service_builder_pub_sub_set_subscriber_max_buffer_size(service_builder_handle, value)

Sets the subscriber max buffer size

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_pub_sub_h_ref`](@ref)] obtained by [[`iox2_service_builder_pub_sub`](@ref)](crate::[`iox2_service_builder_pub_sub`](@ref)). * `value` - The value to set the subscriber max buffer size to

# Safety

* `service_builder_handle` must be valid handles

### Prototype
```c
void iox2_service_builder_pub_sub_set_subscriber_max_buffer_size(iox2_service_builder_pub_sub_h_ref service_builder_handle, c_size_t value);
```
"""
function iox2_service_builder_pub_sub_set_subscriber_max_buffer_size(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_pub_sub_set_subscriber_max_buffer_size(service_builder_handle::iox2_service_builder_pub_sub_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_service_builder_pub_sub_set_subscriber_max_borrowed_samples(service_builder_handle, value)

Sets the subscriber max borrowed samples

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_pub_sub_h_ref`](@ref)] obtained by [[`iox2_service_builder_pub_sub`](@ref)](crate::[`iox2_service_builder_pub_sub`](@ref)). * `value` - The value to set the subscriber max borrowed samples to

# Safety

* `service_builder_handle` must be valid handles

### Prototype
```c
void iox2_service_builder_pub_sub_set_subscriber_max_borrowed_samples(iox2_service_builder_pub_sub_h_ref service_builder_handle, c_size_t value);
```
"""
function iox2_service_builder_pub_sub_set_subscriber_max_borrowed_samples(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_pub_sub_set_subscriber_max_borrowed_samples(service_builder_handle::iox2_service_builder_pub_sub_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_service_builder_pub_sub_set_enable_safe_overflow(service_builder_handle, value)

Enables/disables safe overflow for the service

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_pub_sub_h_ref`](@ref)] obtained by [[`iox2_service_builder_pub_sub`](@ref)](crate::[`iox2_service_builder_pub_sub`](@ref)). * `value` - defines if safe overflow shall be enabled (true) or not (false)

# Safety

* `service_builder_handle` must be valid handles

### Prototype
```c
void iox2_service_builder_pub_sub_set_enable_safe_overflow(iox2_service_builder_pub_sub_h_ref service_builder_handle, bool value);
```
"""
function iox2_service_builder_pub_sub_set_enable_safe_overflow(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_pub_sub_set_enable_safe_overflow(service_builder_handle::iox2_service_builder_pub_sub_h_ref, value::Bool)::Cvoid
end

"""
    iox2_service_builder_pub_sub_open_or_create(service_builder_handle, port_factory_struct_ptr, port_factory_handle_ptr)

Opens a publish-subscribe service or creates the service if it does not exist and returns a port factory to create publishers and subscribers.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_pub_sub_h`](@ref)] obtained by [[`iox2_service_builder_pub_sub`](@ref)](crate::[`iox2_service_builder_pub_sub`](@ref)) * `port_factory_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_pub_sub_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `port_factory_handle_ptr` - An uninitialized or dangling [[`iox2_port_factory_pub_sub_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_pub_sub_open_or_create_error_e`](@ref)] otherwise.

# Safety

* The `service_builder_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_service_builder_t`](@ref)](crate::[`iox2_service_builder_t`](@ref)) can be re-used with a call to [[`iox2_node_service_builder`](@ref)](crate::[`iox2_node_service_builder`](@ref))!

### Prototype
```c
int iox2_service_builder_pub_sub_open_or_create(iox2_service_builder_pub_sub_h service_builder_handle, struct iox2_port_factory_pub_sub_t *port_factory_struct_ptr, iox2_port_factory_pub_sub_h *port_factory_handle_ptr);
```
"""
function iox2_service_builder_pub_sub_open_or_create(service_builder_handle, port_factory_struct_ptr, port_factory_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_pub_sub_open_or_create(service_builder_handle::iox2_service_builder_pub_sub_h, port_factory_struct_ptr::Ptr{iox2_port_factory_pub_sub_t}, port_factory_handle_ptr::Ptr{iox2_port_factory_pub_sub_h})::Cint
end

"""
    iox2_service_builder_pub_sub_open_or_create_with_attributes(service_builder_handle, attribute_verifier_handle, port_factory_struct_ptr, port_factory_handle_ptr)

Opens a publish-subscribe service or creates the service if it does not exist and returns a port factory to create publishers and subscribers. If the service does not exist, the provided arguments are stored inside the services, if the service already exists, the provided attributes are considered as requirements.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_pub_sub_h`](@ref)] obtained by [[`iox2_service_builder_pub_sub`](@ref)](crate::[`iox2_service_builder_pub_sub`](@ref)) * `port_factory_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_pub_sub_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `port_factory_handle_ptr` - An uninitialized or dangling [[`iox2_port_factory_pub_sub_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_pub_sub_open_or_create_error_e`](@ref)] otherwise.

# Safety

* The `service_builder_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_service_builder_t`](@ref)](crate::[`iox2_service_builder_t`](@ref)) can be re-used with a call to [[`iox2_node_service_builder`](@ref)](crate::[`iox2_node_service_builder`](@ref))! * The `attribute_verifier_handle` must be valid.

### Prototype
```c
int iox2_service_builder_pub_sub_open_or_create_with_attributes(iox2_service_builder_pub_sub_h service_builder_handle, iox2_attribute_verifier_h_ref attribute_verifier_handle, struct iox2_port_factory_pub_sub_t *port_factory_struct_ptr, iox2_port_factory_pub_sub_h *port_factory_handle_ptr);
```
"""
function iox2_service_builder_pub_sub_open_or_create_with_attributes(service_builder_handle, attribute_verifier_handle, port_factory_struct_ptr, port_factory_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_pub_sub_open_or_create_with_attributes(service_builder_handle::iox2_service_builder_pub_sub_h, attribute_verifier_handle::iox2_attribute_verifier_h_ref, port_factory_struct_ptr::Ptr{iox2_port_factory_pub_sub_t}, port_factory_handle_ptr::Ptr{iox2_port_factory_pub_sub_h})::Cint
end

"""
    iox2_service_builder_pub_sub_open(service_builder_handle, port_factory_struct_ptr, port_factory_handle_ptr)

Opens a publish-subscribe service and returns a port factory to create publishers and subscribers.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_pub_sub_h`](@ref)] obtained by [[`iox2_service_builder_pub_sub`](@ref)](crate::[`iox2_service_builder_pub_sub`](@ref)) * `port_factory_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_pub_sub_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `port_factory_handle_ptr` - An uninitialized or dangling [[`iox2_port_factory_pub_sub_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_pub_sub_open_or_create_error_e`](@ref)] otherwise. Note, only the errors annotated with `O_` are relevant.

# Safety

* The `service_builder_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_service_builder_t`](@ref)](crate::[`iox2_service_builder_t`](@ref)) can be re-used with a call to [[`iox2_node_service_builder`](@ref)](crate::[`iox2_node_service_builder`](@ref))!

### Prototype
```c
int iox2_service_builder_pub_sub_open(iox2_service_builder_pub_sub_h service_builder_handle, struct iox2_port_factory_pub_sub_t *port_factory_struct_ptr, iox2_port_factory_pub_sub_h *port_factory_handle_ptr);
```
"""
function iox2_service_builder_pub_sub_open(service_builder_handle, port_factory_struct_ptr, port_factory_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_pub_sub_open(service_builder_handle::iox2_service_builder_pub_sub_h, port_factory_struct_ptr::Ptr{iox2_port_factory_pub_sub_t}, port_factory_handle_ptr::Ptr{iox2_port_factory_pub_sub_h})::Cint
end

"""
    iox2_service_builder_pub_sub_open_with_attributes(service_builder_handle, attribute_verifier_handle, port_factory_struct_ptr, port_factory_handle_ptr)

Opens a publish-subscribe service and returns a port factory to create publishers and subscribers. The provided attributes are considered as requirements.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_pub_sub_h`](@ref)] obtained by [[`iox2_service_builder_pub_sub`](@ref)](crate::[`iox2_service_builder_pub_sub`](@ref)) * `port_factory_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_pub_sub_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `port_factory_handle_ptr` - An uninitialized or dangling [[`iox2_port_factory_pub_sub_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_pub_sub_open_or_create_error_e`](@ref)] otherwise. Note, only the errors annotated with `O_` are relevant.

# Safety

* The `service_builder_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_service_builder_t`](@ref)](crate::[`iox2_service_builder_t`](@ref)) can be re-used with a call to [[`iox2_node_service_builder`](@ref)](crate::[`iox2_node_service_builder`](@ref))! * The `attribute_verifier_handle` must be valid.

### Prototype
```c
int iox2_service_builder_pub_sub_open_with_attributes(iox2_service_builder_pub_sub_h service_builder_handle, iox2_attribute_verifier_h_ref attribute_verifier_handle, struct iox2_port_factory_pub_sub_t *port_factory_struct_ptr, iox2_port_factory_pub_sub_h *port_factory_handle_ptr);
```
"""
function iox2_service_builder_pub_sub_open_with_attributes(service_builder_handle, attribute_verifier_handle, port_factory_struct_ptr, port_factory_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_pub_sub_open_with_attributes(service_builder_handle::iox2_service_builder_pub_sub_h, attribute_verifier_handle::iox2_attribute_verifier_h_ref, port_factory_struct_ptr::Ptr{iox2_port_factory_pub_sub_t}, port_factory_handle_ptr::Ptr{iox2_port_factory_pub_sub_h})::Cint
end

"""
    iox2_service_builder_pub_sub_create(service_builder_handle, port_factory_struct_ptr, port_factory_handle_ptr)

Creates a publish-subscribe service and returns a port factory to create publishers and subscribers.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_pub_sub_h`](@ref)] obtained by [[`iox2_service_builder_pub_sub`](@ref)](crate::[`iox2_service_builder_pub_sub`](@ref)) * `port_factory_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_pub_sub_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `port_factory_handle_ptr` - An uninitialized or dangling [[`iox2_port_factory_pub_sub_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_pub_sub_open_or_create_error_e`](@ref)] otherwise. Note, only the errors annotated with `C_` are relevant.

# Safety

* The `service_builder_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_service_builder_t`](@ref)](crate::[`iox2_service_builder_t`](@ref)) can be re-used with a call to [[`iox2_node_service_builder`](@ref)](crate::[`iox2_node_service_builder`](@ref))!

### Prototype
```c
int iox2_service_builder_pub_sub_create(iox2_service_builder_pub_sub_h service_builder_handle, struct iox2_port_factory_pub_sub_t *port_factory_struct_ptr, iox2_port_factory_pub_sub_h *port_factory_handle_ptr);
```
"""
function iox2_service_builder_pub_sub_create(service_builder_handle, port_factory_struct_ptr, port_factory_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_pub_sub_create(service_builder_handle::iox2_service_builder_pub_sub_h, port_factory_struct_ptr::Ptr{iox2_port_factory_pub_sub_t}, port_factory_handle_ptr::Ptr{iox2_port_factory_pub_sub_h})::Cint
end

"""
    iox2_service_builder_pub_sub_create_with_attributes(service_builder_handle, attribute_specifier_handle, port_factory_struct_ptr, port_factory_handle_ptr)

Creates a publish-subscribe service and returns a port factory to create publishers and subscribers. The provided arguments are stored inside the services.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_pub_sub_h`](@ref)] obtained by [[`iox2_service_builder_pub_sub`](@ref)](crate::[`iox2_service_builder_pub_sub`](@ref)) * `port_factory_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_pub_sub_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `port_factory_handle_ptr` - An uninitialized or dangling [[`iox2_port_factory_pub_sub_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_pub_sub_open_or_create_error_e`](@ref)] otherwise. Note, only the errors annotated with `C_` are relevant.

# Safety

* The `service_builder_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_service_builder_t`](@ref)](crate::[`iox2_service_builder_t`](@ref)) can be re-used with a call to [[`iox2_node_service_builder`](@ref)](crate::[`iox2_node_service_builder`](@ref))! * The `attribute_verifier_handle` must be valid.

### Prototype
```c
int iox2_service_builder_pub_sub_create_with_attributes(iox2_service_builder_pub_sub_h service_builder_handle, iox2_attribute_specifier_h_ref attribute_specifier_handle, struct iox2_port_factory_pub_sub_t *port_factory_struct_ptr, iox2_port_factory_pub_sub_h *port_factory_handle_ptr);
```
"""
function iox2_service_builder_pub_sub_create_with_attributes(service_builder_handle, attribute_specifier_handle, port_factory_struct_ptr, port_factory_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_pub_sub_create_with_attributes(service_builder_handle::iox2_service_builder_pub_sub_h, attribute_specifier_handle::iox2_attribute_specifier_h_ref, port_factory_struct_ptr::Ptr{iox2_port_factory_pub_sub_t}, port_factory_handle_ptr::Ptr{iox2_port_factory_pub_sub_h})::Cint
end

"""
    iox2_request_response_open_or_create_error_string(error)

Returns a string literal describing the provided [[`iox2_request_response_open_or_create_error_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_request_response_open_or_create_error_string(enum iox2_request_response_open_or_create_error_e error);
```
"""
function iox2_request_response_open_or_create_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_request_response_open_or_create_error_string(error::iox2_request_response_open_or_create_error_e)::Cstring
end

"""
    iox2_service_builder_request_response_set_request_header_type_details(service_builder_handle, type_variant, type_name_str, type_name_len, size, alignment)

Sets the request header type details for the builder

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_request_response_h_ref`](@ref)] obtained by [[`iox2_service_builder_request_response`](@ref)](crate::[`iox2_service_builder_request_response`](@ref)). * `type_variant` - The [[`iox2_type_variant_e`](@ref)] for the payload * `type_name_str` - string for the type name. * `type_name_len` - The length of the type name string, not including a null * `size` - The size of the payload * `alignment` - The alignment of the payload

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_type_detail_error_e`](@ref)] otherwise.

# Safety

* `service_builder_handle` must be valid handles * `type_name_str` must be a valid pointer to an utf8 string * `size` and `alignment` must satisfy the Rust `Layout` type requirements

### Prototype
```c
int iox2_service_builder_request_response_set_request_header_type_details(iox2_service_builder_request_response_h_ref service_builder_handle, enum iox2_type_variant_e type_variant, const char *type_name_str, c_size_t type_name_len, c_size_t size, c_size_t alignment);
```
"""
function iox2_service_builder_request_response_set_request_header_type_details(service_builder_handle, type_variant, type_name_str, type_name_len, size, alignment)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_request_response_set_request_header_type_details(service_builder_handle::iox2_service_builder_request_response_h_ref, type_variant::iox2_type_variant_e, type_name_str::Cstring, type_name_len::c_size_t, size::c_size_t, alignment::c_size_t)::Cint
end

"""
    iox2_service_builder_request_response_set_response_header_type_details(service_builder_handle, type_variant, type_name_str, type_name_len, size, alignment)

Sets the response header type details for the builder

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_request_response_h_ref`](@ref)] obtained by [[`iox2_service_builder_request_response`](@ref)](crate::[`iox2_service_builder_request_response`](@ref)). * `type_variant` - The [[`iox2_type_variant_e`](@ref)] for the payload * `type_name_str` - string for the type name. * `type_name_len` - The length of the type name string, not including a null * `size` - The size of the payload * `alignment` - The alignment of the payload

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_type_detail_error_e`](@ref)] otherwise.

# Safety

* `service_builder_handle` must be valid handles * `type_name_str` must be a valid pointer to an utf8 string * `size` and `alignment` must satisfy the Rust `Layout` type requirements

### Prototype
```c
int iox2_service_builder_request_response_set_response_header_type_details(iox2_service_builder_request_response_h_ref service_builder_handle, enum iox2_type_variant_e type_variant, const char *type_name_str, c_size_t type_name_len, c_size_t size, c_size_t alignment);
```
"""
function iox2_service_builder_request_response_set_response_header_type_details(service_builder_handle, type_variant, type_name_str, type_name_len, size, alignment)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_request_response_set_response_header_type_details(service_builder_handle::iox2_service_builder_request_response_h_ref, type_variant::iox2_type_variant_e, type_name_str::Cstring, type_name_len::c_size_t, size::c_size_t, alignment::c_size_t)::Cint
end

"""
    iox2_service_builder_request_response_set_request_payload_type_details(service_builder_handle, type_variant, type_name_str, type_name_len, size, alignment)

Sets the request payload type details for the builder

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_request_response_h_ref`](@ref)] obtained by [[`iox2_service_builder_request_response`](@ref)](crate::[`iox2_service_builder_request_response`](@ref)). * `type_variant` - The [[`iox2_type_variant_e`](@ref)] for the payload * `type_name_str` - Must string for the type name. * `type_name_len` - The length of the type name string, not including a null * `size` - The size of the payload * `alignment` - The alignment of the payload

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_type_detail_error_e`](@ref)] otherwise.

# Safety

* `service_builder_handle` must be valid handles * `type_name_str` must be a valid pointer to an utf8 string * `size` and `alignment` must satisfy the Rust `Layout` type requirements

### Prototype
```c
int iox2_service_builder_request_response_set_request_payload_type_details(iox2_service_builder_request_response_h_ref service_builder_handle, enum iox2_type_variant_e type_variant, const char *type_name_str, c_size_t type_name_len, c_size_t size, c_size_t alignment);
```
"""
function iox2_service_builder_request_response_set_request_payload_type_details(service_builder_handle, type_variant, type_name_str, type_name_len, size, alignment)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_request_response_set_request_payload_type_details(service_builder_handle::iox2_service_builder_request_response_h_ref, type_variant::iox2_type_variant_e, type_name_str::Cstring, type_name_len::c_size_t, size::c_size_t, alignment::c_size_t)::Cint
end

"""
    iox2_service_builder_request_response_set_response_payload_type_details(service_builder_handle, type_variant, type_name_str, type_name_len, size, alignment)

Sets the response payload type details for the builder

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_request_response_h_ref`](@ref)] obtained by [[`iox2_service_builder_request_response`](@ref)](crate::[`iox2_service_builder_request_response`](@ref)). * `type_variant` - The [[`iox2_type_variant_e`](@ref)] for the payload * `type_name_str` - Must string for the type name. * `type_name_len` - The length of the type name string, not including a null * `size` - The size of the payload * `alignment` - The alignment of the payload

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_type_detail_error_e`](@ref)] otherwise.

# Safety

* `service_builder_handle` must be valid handles * `type_name_str` must be a valid pointer to an utf8 string * `size` and `alignment` must satisfy the Rust `Layout` type requirements

### Prototype
```c
int iox2_service_builder_request_response_set_response_payload_type_details(iox2_service_builder_request_response_h_ref service_builder_handle, enum iox2_type_variant_e type_variant, const char *type_name_str, c_size_t type_name_len, c_size_t size, c_size_t alignment);
```
"""
function iox2_service_builder_request_response_set_response_payload_type_details(service_builder_handle, type_variant, type_name_str, type_name_len, size, alignment)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_request_response_set_response_payload_type_details(service_builder_handle::iox2_service_builder_request_response_h_ref, type_variant::iox2_type_variant_e, type_name_str::Cstring, type_name_len::c_size_t, size::c_size_t, alignment::c_size_t)::Cint
end

"""
    iox2_service_builder_request_response_enable_fire_and_forget_requests(service_builder_handle, value)

Enables/disables fire and forget requests

# Safety

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_request_response_h_ref`](@ref)] obtained by [[`iox2_service_builder_request_response`](@ref)](crate::[`iox2_service_builder_request_response`](@ref)).

### Prototype
```c
void iox2_service_builder_request_response_enable_fire_and_forget_requests(iox2_service_builder_request_response_h_ref service_builder_handle, bool value);
```
"""
function iox2_service_builder_request_response_enable_fire_and_forget_requests(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_request_response_enable_fire_and_forget_requests(service_builder_handle::iox2_service_builder_request_response_h_ref, value::Bool)::Cvoid
end

"""
    iox2_service_builder_request_response_enable_safe_overflow_for_requests(service_builder_handle, value)

Enables/disables safe overflow for requests

# Safety

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_request_response_h_ref`](@ref)] obtained by [[`iox2_service_builder_request_response`](@ref)](crate::[`iox2_service_builder_request_response`](@ref)).

### Prototype
```c
void iox2_service_builder_request_response_enable_safe_overflow_for_requests(iox2_service_builder_request_response_h_ref service_builder_handle, bool value);
```
"""
function iox2_service_builder_request_response_enable_safe_overflow_for_requests(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_request_response_enable_safe_overflow_for_requests(service_builder_handle::iox2_service_builder_request_response_h_ref, value::Bool)::Cvoid
end

"""
    iox2_service_builder_request_response_enable_safe_overflow_for_responses(service_builder_handle, value)

Enables/disables safe overflow for responses

# Safety

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_request_response_h_ref`](@ref)] obtained by [[`iox2_service_builder_request_response`](@ref)](crate::[`iox2_service_builder_request_response`](@ref)).

### Prototype
```c
void iox2_service_builder_request_response_enable_safe_overflow_for_responses(iox2_service_builder_request_response_h_ref service_builder_handle, bool value);
```
"""
function iox2_service_builder_request_response_enable_safe_overflow_for_responses(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_request_response_enable_safe_overflow_for_responses(service_builder_handle::iox2_service_builder_request_response_h_ref, value::Bool)::Cvoid
end

"""
    iox2_service_builder_request_response_max_active_requests_per_client(service_builder_handle, value)

Sets the maximum amount of active requests a client can have

# Safety

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_request_response_h_ref`](@ref)] obtained by [[`iox2_service_builder_request_response`](@ref)](crate::[`iox2_service_builder_request_response`](@ref)).

### Prototype
```c
void iox2_service_builder_request_response_max_active_requests_per_client(iox2_service_builder_request_response_h_ref service_builder_handle, c_size_t value);
```
"""
function iox2_service_builder_request_response_max_active_requests_per_client(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_request_response_max_active_requests_per_client(service_builder_handle::iox2_service_builder_request_response_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_service_builder_request_response_max_borrowed_responses_per_pending_response(service_builder_handle, value)

Sets the maximum amount responses a client can borrow from a pending response

# Safety

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_request_response_h_ref`](@ref)] obtained by [[`iox2_service_builder_request_response`](@ref)](crate::[`iox2_service_builder_request_response`](@ref)).

### Prototype
```c
void iox2_service_builder_request_response_max_borrowed_responses_per_pending_response(iox2_service_builder_request_response_h_ref service_builder_handle, c_size_t value);
```
"""
function iox2_service_builder_request_response_max_borrowed_responses_per_pending_response(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_request_response_max_borrowed_responses_per_pending_response(service_builder_handle::iox2_service_builder_request_response_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_service_builder_request_response_max_clients(service_builder_handle, value)

Sets the maximum number of clients the service will support

# Safety

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_request_response_h_ref`](@ref)] obtained by [[`iox2_service_builder_request_response`](@ref)](crate::[`iox2_service_builder_request_response`](@ref)).

### Prototype
```c
void iox2_service_builder_request_response_max_clients(iox2_service_builder_request_response_h_ref service_builder_handle, c_size_t value);
```
"""
function iox2_service_builder_request_response_max_clients(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_request_response_max_clients(service_builder_handle::iox2_service_builder_request_response_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_service_builder_request_response_max_loaned_requests(service_builder_handle, value)

Sets the maximum number of requests a client can loan at the same time

# Safety

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_request_response_h_ref`](@ref)] obtained by [[`iox2_service_builder_request_response`](@ref)](crate::[`iox2_service_builder_request_response`](@ref)).

### Prototype
```c
void iox2_service_builder_request_response_max_loaned_requests(iox2_service_builder_request_response_h_ref service_builder_handle, c_size_t value);
```
"""
function iox2_service_builder_request_response_max_loaned_requests(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_request_response_max_loaned_requests(service_builder_handle::iox2_service_builder_request_response_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_service_builder_request_response_set_max_nodes(service_builder_handle, value)

Sets the maximum number of nodes that can open the service

# Safety

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_request_response_h_ref`](@ref)] obtained by [[`iox2_service_builder_request_response`](@ref)](crate::[`iox2_service_builder_request_response`](@ref)).

### Prototype
```c
void iox2_service_builder_request_response_set_max_nodes(iox2_service_builder_request_response_h_ref service_builder_handle, c_size_t value);
```
"""
function iox2_service_builder_request_response_set_max_nodes(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_request_response_set_max_nodes(service_builder_handle::iox2_service_builder_request_response_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_service_builder_request_response_max_response_buffer_size(service_builder_handle, value)

Sets the maximum buffer size for responses on the client side

# Safety

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_request_response_h_ref`](@ref)] obtained by [[`iox2_service_builder_request_response`](@ref)](crate::[`iox2_service_builder_request_response`](@ref)).

### Prototype
```c
void iox2_service_builder_request_response_max_response_buffer_size(iox2_service_builder_request_response_h_ref service_builder_handle, c_size_t value);
```
"""
function iox2_service_builder_request_response_max_response_buffer_size(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_request_response_max_response_buffer_size(service_builder_handle::iox2_service_builder_request_response_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_service_builder_request_response_max_servers(service_builder_handle, value)

Sets the maximum number of servers the service will support

# Safety

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_request_response_h_ref`](@ref)] obtained by [[`iox2_service_builder_request_response`](@ref)](crate::[`iox2_service_builder_request_response`](@ref)).

### Prototype
```c
void iox2_service_builder_request_response_max_servers(iox2_service_builder_request_response_h_ref service_builder_handle, c_size_t value);
```
"""
function iox2_service_builder_request_response_max_servers(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_request_response_max_servers(service_builder_handle::iox2_service_builder_request_response_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_service_builder_request_response_request_payload_alignment(service_builder_handle, value)

Overrides the alignment of the provided request payload.

# Safety

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_request_response_h_ref`](@ref)] obtained by [[`iox2_service_builder_request_response`](@ref)](crate::[`iox2_service_builder_request_response`](@ref)).

### Prototype
```c
void iox2_service_builder_request_response_request_payload_alignment(iox2_service_builder_request_response_h_ref service_builder_handle, c_size_t value);
```
"""
function iox2_service_builder_request_response_request_payload_alignment(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_request_response_request_payload_alignment(service_builder_handle::iox2_service_builder_request_response_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_service_builder_request_response_response_payload_alignment(service_builder_handle, value)

Overrides the alignment of the provided response payload.

# Safety

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_request_response_h_ref`](@ref)] obtained by [[`iox2_service_builder_request_response`](@ref)](crate::[`iox2_service_builder_request_response`](@ref)).

### Prototype
```c
void iox2_service_builder_request_response_response_payload_alignment(iox2_service_builder_request_response_h_ref service_builder_handle, c_size_t value);
```
"""
function iox2_service_builder_request_response_response_payload_alignment(service_builder_handle, value)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_request_response_response_payload_alignment(service_builder_handle::iox2_service_builder_request_response_h_ref, value::c_size_t)::Cvoid
end

"""
    iox2_service_builder_request_response_open_or_create(service_builder_handle, port_factory_struct_ptr, port_factory_handle_ptr)

Opens a request-response service or creates the service if it does not exist and returns a port factory to create servers and clients.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_request_response_h`](@ref)] obtained by [[`iox2_service_builder_request_response`](@ref)](crate::[`iox2_service_builder_request_response`](@ref)) * `port_factory_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_request_response_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `port_factory_handle_ptr` - An uninitialized or dangling [[`iox2_port_factory_request_response_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_request_response_open_or_create_error_e`](@ref)] otherwise.

# Safety

* The `service_builder_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_service_builder_t`](@ref)](crate::[`iox2_service_builder_t`](@ref)) can be re-used with a call to [[`iox2_node_service_builder`](@ref)](crate::[`iox2_node_service_builder`](@ref))!

### Prototype
```c
int iox2_service_builder_request_response_open_or_create(iox2_service_builder_request_response_h service_builder_handle, struct iox2_port_factory_request_response_t *port_factory_struct_ptr, iox2_port_factory_request_response_h *port_factory_handle_ptr);
```
"""
function iox2_service_builder_request_response_open_or_create(service_builder_handle, port_factory_struct_ptr, port_factory_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_request_response_open_or_create(service_builder_handle::iox2_service_builder_request_response_h, port_factory_struct_ptr::Ptr{iox2_port_factory_request_response_t}, port_factory_handle_ptr::Ptr{iox2_port_factory_request_response_h})::Cint
end

"""
    iox2_service_builder_request_response_open_or_create_with_attributes(service_builder_handle, attribute_verifier_handle, port_factory_struct_ptr, port_factory_handle_ptr)

Opens a request-response service or creates the service if it does not exist and returns a port factory to create servers and clients. If the service does not exist, the provided arguments are stored inside the services, if the service already exists, the provided attributes are considered as requirements.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_request_response_h`](@ref)] obtained by [[`iox2_service_builder_request_response`](@ref)](crate::[`iox2_service_builder_request_response`](@ref)) * `port_factory_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_request_response_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `attribute_verifier_handle` - An initialized valid handle to an [[`iox2_attribute_verifier_h_ref`](@ref)]. * `port_factory_handle_ptr` - An uninitialized or dangling [[`iox2_port_factory_request_response_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_request_response_open_or_create_error_e`](@ref)] otherwise.

# Safety

* The `service_builder_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_service_builder_t`](@ref)](crate::[`iox2_service_builder_t`](@ref)) can be re-used with a call to [[`iox2_node_service_builder`](@ref)](crate::[`iox2_node_service_builder`](@ref))! * The `attribute_verifier_handle` must be valid.

### Prototype
```c
int iox2_service_builder_request_response_open_or_create_with_attributes(iox2_service_builder_request_response_h service_builder_handle, iox2_attribute_verifier_h_ref attribute_verifier_handle, struct iox2_port_factory_request_response_t *port_factory_struct_ptr, iox2_port_factory_request_response_h *port_factory_handle_ptr);
```
"""
function iox2_service_builder_request_response_open_or_create_with_attributes(service_builder_handle, attribute_verifier_handle, port_factory_struct_ptr, port_factory_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_request_response_open_or_create_with_attributes(service_builder_handle::iox2_service_builder_request_response_h, attribute_verifier_handle::iox2_attribute_verifier_h_ref, port_factory_struct_ptr::Ptr{iox2_port_factory_request_response_t}, port_factory_handle_ptr::Ptr{iox2_port_factory_request_response_h})::Cint
end

"""
    iox2_service_builder_request_response_open(service_builder_handle, port_factory_struct_ptr, port_factory_handle_ptr)

Opens a request-response service and returns a port factory to create servers and clients.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_request_response_h`](@ref)] obtained by [[`iox2_service_builder_request_response`](@ref)](crate::[`iox2_service_builder_request_response`](@ref)) * `port_factory_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_request_response_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `port_factory_handle_ptr` - An uninitialized or dangling [[`iox2_port_factory_request_response_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_request_response_open_or_create_error_e`](@ref)] otherwise. Note, only the errors annotated with `O_` are relevant.

# Safety

* The `service_builder_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_service_builder_t`](@ref)](crate::[`iox2_service_builder_t`](@ref)) can be re-used with a call to [[`iox2_node_service_builder`](@ref)](crate::[`iox2_node_service_builder`](@ref))!

### Prototype
```c
int iox2_service_builder_request_response_open(iox2_service_builder_request_response_h service_builder_handle, struct iox2_port_factory_request_response_t *port_factory_struct_ptr, iox2_port_factory_request_response_h *port_factory_handle_ptr);
```
"""
function iox2_service_builder_request_response_open(service_builder_handle, port_factory_struct_ptr, port_factory_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_request_response_open(service_builder_handle::iox2_service_builder_request_response_h, port_factory_struct_ptr::Ptr{iox2_port_factory_request_response_t}, port_factory_handle_ptr::Ptr{iox2_port_factory_request_response_h})::Cint
end

"""
    iox2_service_builder_request_response_open_with_attributes(service_builder_handle, attribute_verifier_handle, port_factory_struct_ptr, port_factory_handle_ptr)

Opens a request-response service and returns a port factory to create servers and clients. The provided attributes are considered as requirements.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_request_response_h`](@ref)] obtained by [[`iox2_service_builder_request_response`](@ref)](crate::[`iox2_service_builder_request_response`](@ref)) * `port_factory_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_request_response_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `attribute_verifier_handle` - An initialized valid handle to an [[`iox2_attribute_verifier_h_ref`](@ref)]. * `port_factory_handle_ptr` - An uninitialized or dangling [[`iox2_port_factory_request_response_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_request_response_open_or_create_error_e`](@ref)] otherwise. Note, only the errors annotated with `O_` are relevant.

# Safety

* The `service_builder_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_service_builder_t`](@ref)](crate::[`iox2_service_builder_t`](@ref)) can be re-used with a call to [[`iox2_node_service_builder`](@ref)](crate::[`iox2_node_service_builder`](@ref))! * The `attribute_verifier_handle` must be valid.

### Prototype
```c
int iox2_service_builder_request_response_open_with_attributes(iox2_service_builder_request_response_h service_builder_handle, iox2_attribute_verifier_h_ref attribute_verifier_handle, struct iox2_port_factory_request_response_t *port_factory_struct_ptr, iox2_port_factory_request_response_h *port_factory_handle_ptr);
```
"""
function iox2_service_builder_request_response_open_with_attributes(service_builder_handle, attribute_verifier_handle, port_factory_struct_ptr, port_factory_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_request_response_open_with_attributes(service_builder_handle::iox2_service_builder_request_response_h, attribute_verifier_handle::iox2_attribute_verifier_h_ref, port_factory_struct_ptr::Ptr{iox2_port_factory_request_response_t}, port_factory_handle_ptr::Ptr{iox2_port_factory_request_response_h})::Cint
end

"""
    iox2_service_builder_request_response_create(service_builder_handle, port_factory_struct_ptr, port_factory_handle_ptr)

Creates a request-response service and returns a port factory to create servers and clients.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_request_response_h`](@ref)] obtained by [[`iox2_service_builder_request_response`](@ref)](crate::[`iox2_service_builder_request_response`](@ref)) * `port_factory_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_request_response_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `port_factory_handle_ptr` - An uninitialized or dangling [[`iox2_port_factory_request_response_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_request_response_open_or_create_error_e`](@ref)] otherwise. Note, only the errors annotated with `C_` are relevant.

# Safety

* The `service_builder_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_service_builder_t`](@ref)](crate::[`iox2_service_builder_t`](@ref)) can be re-used with a call to [[`iox2_node_service_builder`](@ref)](crate::[`iox2_node_service_builder`](@ref))!

### Prototype
```c
int iox2_service_builder_request_response_create(iox2_service_builder_request_response_h service_builder_handle, struct iox2_port_factory_request_response_t *port_factory_struct_ptr, iox2_port_factory_request_response_h *port_factory_handle_ptr);
```
"""
function iox2_service_builder_request_response_create(service_builder_handle, port_factory_struct_ptr, port_factory_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_request_response_create(service_builder_handle::iox2_service_builder_request_response_h, port_factory_struct_ptr::Ptr{iox2_port_factory_request_response_t}, port_factory_handle_ptr::Ptr{iox2_port_factory_request_response_h})::Cint
end

"""
    iox2_service_builder_request_response_create_with_attributes(service_builder_handle, attribute_specifier_handle, port_factory_struct_ptr, port_factory_handle_ptr)

Creates a request-response service and returns a port factory to create servers and clients. The provided arguments are stored inside the services.

# Arguments

* `service_builder_handle` - Must be a valid [[`iox2_service_builder_request_response_h`](@ref)] obtained by [[`iox2_service_builder_request_response`](@ref)](crate::[`iox2_service_builder_request_response`](@ref)) * `port_factory_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_port_factory_request_response_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `attribute_specifier_handle` - An initialized valid handle to an [[`iox2_attribute_specifier_h_ref`](@ref)]. * `port_factory_handle_ptr` - An uninitialized or dangling [[`iox2_port_factory_request_response_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_request_response_open_or_create_error_e`](@ref)] otherwise. Note, only the errors annotated with `C_` are relevant.

# Safety

* The `service_builder_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_service_builder_t`](@ref)](crate::[`iox2_service_builder_t`](@ref)) can be re-used with a call to [[`iox2_node_service_builder`](@ref)](crate::[`iox2_node_service_builder`](@ref))! * The `attribute_specifier_handle` must be valid.

### Prototype
```c
int iox2_service_builder_request_response_create_with_attributes(iox2_service_builder_request_response_h service_builder_handle, iox2_attribute_specifier_h_ref attribute_specifier_handle, struct iox2_port_factory_request_response_t *port_factory_struct_ptr, iox2_port_factory_request_response_h *port_factory_handle_ptr);
```
"""
function iox2_service_builder_request_response_create_with_attributes(service_builder_handle, attribute_specifier_handle, port_factory_struct_ptr, port_factory_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_service_builder_request_response_create_with_attributes(service_builder_handle::iox2_service_builder_request_response_h, attribute_specifier_handle::iox2_attribute_specifier_h_ref, port_factory_struct_ptr::Ptr{iox2_port_factory_request_response_t}, port_factory_handle_ptr::Ptr{iox2_port_factory_request_response_h})::Cint
end

"""
    iox2_service_name_new(service_name_struct_ptr, service_name_str, service_name_len, service_name_handle_ptr)

This function create a new node name!

# Arguments

* `service_name_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_service_name_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `service_name_str` - Must be valid node name string. * `service_name_len` - The length of the node name string, not including a null termination. * `service_name_handle_ptr` - An uninitialized or dangling [[`iox2_service_name_h`](@ref)] handle which will be initialized by this function call.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_semantic_string_error_e`](@ref)](crate::[`iox2_semantic_string_error_e`](@ref)) otherwise.

# Safety

* Terminates if `service_name_str` or `service_name_handle_ptr` is a NULL pointer! * It is undefined behavior to pass a `service_name_len` which is larger than the actual length of `service_name_str`!

### Prototype
```c
int iox2_service_name_new(struct iox2_service_name_t *service_name_struct_ptr, const char *service_name_str, c_size_t service_name_len, iox2_service_name_h *service_name_handle_ptr);
```
"""
function iox2_service_name_new(service_name_struct_ptr, service_name_str, service_name_len, service_name_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_service_name_new(service_name_struct_ptr::Ptr{iox2_service_name_t}, service_name_str::Cstring, service_name_len::c_size_t, service_name_handle_ptr::Ptr{iox2_service_name_h})::Cint
end

"""
    iox2_cast_service_name_ptr(service_name_handle)

This function casts a [[`iox2_service_name_h`](@ref)] into a [[`iox2_service_name_ptr`](@ref)]

# Arguments

* `service_name_handle` obtained by [[`iox2_service_name_new`](@ref)]

Returns a [[`iox2_service_name_ptr`](@ref)]

# Safety

* The `service_name_handle` must be a valid handle. * The `service_name_handle` is still valid after the call to this function.

### Prototype
```c
iox2_service_name_ptr iox2_cast_service_name_ptr(iox2_service_name_h service_name_handle);
```
"""
function iox2_cast_service_name_ptr(service_name_handle)
    @ccall libiceoryx2_ffi_c.iox2_cast_service_name_ptr(service_name_handle::iox2_service_name_h)::iox2_service_name_ptr
end

"""
    iox2_service_name_as_chars(service_name_ptr, service_name_len)

This function gives access to the node name as a non-zero-terminated char array

# Arguments

* `service_name_ptr` obtained by e.g. [[`iox2_cast_service_name_ptr`](@ref)] or a function returning a [[`iox2_service_name_ptr`](@ref)] * `service_name_len` must be used to get the length of the char array

Returns non-zero-terminated char array

# Safety

* The `service_name_ptr` must be a valid pointer to a node name. * The `service_name_len` must be a valid pointer to a size\\_t.

### Prototype
```c
const char *iox2_service_name_as_chars(iox2_service_name_ptr service_name_ptr, c_size_t *service_name_len);
```
"""
function iox2_service_name_as_chars(service_name_ptr, service_name_len)
    @ccall libiceoryx2_ffi_c.iox2_service_name_as_chars(service_name_ptr::iox2_service_name_ptr, service_name_len::Ptr{c_size_t})::Cstring
end

"""
    iox2_service_name_drop(service_name_handle)

This function needs to be called to destroy the node name!

In general, this function is not required to call, since [[`iox2_node_builder_set_name`](@ref)](crate::[`iox2_node_builder_set_name`](@ref)) will consume the [[`iox2_service_name_h`](@ref)] handle.

# Arguments

* `service_name_handle` - A valid [[`iox2_service_name_h`](@ref)]

# Safety

* The `service_name_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_service_name_t`](@ref)] can be re-used with a call to [[`iox2_service_name_new`](@ref)]!

### Prototype
```c
void iox2_service_name_drop(iox2_service_name_h service_name_handle);
```
"""
function iox2_service_name_drop(service_name_handle)
    @ccall libiceoryx2_ffi_c.iox2_service_name_drop(service_name_handle::iox2_service_name_h)::Cvoid
end

"""
    iox2_receive_error_string(error)

Returns a string literal describing the provided [[`iox2_receive_error_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_receive_error_string(enum iox2_receive_error_e error);
```
"""
function iox2_receive_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_receive_error_string(error::iox2_receive_error_e)::Cstring
end

"""
    iox2_connection_failure_string(error)

Returns a string literal describing the provided [[`iox2_connection_failure_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_connection_failure_string(enum iox2_connection_failure_e error);
```
"""
function iox2_connection_failure_string(error)
    @ccall libiceoryx2_ffi_c.iox2_connection_failure_string(error::iox2_connection_failure_e)::Cstring
end

"""
    iox2_subscriber_buffer_size(subscriber_handle)

Returns the buffer size of the subscriber

# Arguments

* `subscriber_handle` - Must be a valid [[`iox2_subscriber_h_ref`](@ref)] obtained by [[`iox2_port_factory_subscriber_builder_create`](@ref)](crate::[`iox2_port_factory_subscriber_builder_create`](@ref)).

# Safety

* `subscriber_handle` must be valid handles

### Prototype
```c
c_size_t iox2_subscriber_buffer_size(iox2_subscriber_h_ref subscriber_handle);
```
"""
function iox2_subscriber_buffer_size(subscriber_handle)
    @ccall libiceoryx2_ffi_c.iox2_subscriber_buffer_size(subscriber_handle::iox2_subscriber_h_ref)::c_size_t
end

"""
    iox2_subscriber_id(subscriber_handle, id_struct_ptr, id_handle_ptr)

Returns the unique port id of the subscriber.

# Arguments

* `subscriber_handle` obtained by [[`iox2_port_factory_subscriber_builder_create`](@ref)](crate::[`iox2_port_factory_subscriber_builder_create`](@ref)) * `id_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_unique_subscriber_id_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `id_handle_ptr` valid pointer to a [[`iox2_unique_subscriber_id_h`](@ref)].

# Safety

* `subscriber_handle` is valid, non-null and was obtained via [[`iox2_port_factory_subscriber_builder_create`](@ref)](crate::[`iox2_port_factory_subscriber_builder_create`](@ref)) * `id` is valid and non-null

### Prototype
```c
void iox2_subscriber_id(iox2_subscriber_h_ref subscriber_handle, struct iox2_unique_subscriber_id_t *id_struct_ptr, iox2_unique_subscriber_id_h *id_handle_ptr);
```
"""
function iox2_subscriber_id(subscriber_handle, id_struct_ptr, id_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_subscriber_id(subscriber_handle::iox2_subscriber_h_ref, id_struct_ptr::Ptr{iox2_unique_subscriber_id_t}, id_handle_ptr::Ptr{iox2_unique_subscriber_id_h})::Cvoid
end

"""
    iox2_subscriber_receive(subscriber_handle, sample_struct_ptr, sample_handle_ptr)

Takes a sample ouf of the subscriber queue.

# Arguments

* `subscriber_handle` - Must be a valid [[`iox2_subscriber_h_ref`](@ref)] obtained by [[`iox2_port_factory_subscriber_builder_create`](@ref)](crate::[`iox2_port_factory_subscriber_builder_create`](@ref)). * `sample_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_sample_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `sample_handle_ptr` - An uninitialized or dangling [[`iox2_sample_h`](@ref)] handle which will be initialized by this function call if a sample is obtained, otherwise it will be set to NULL.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_receive_error_e`](@ref)] otherwise. Attention, an empty subscriber queue is not an error and even with [`IOX2_OK`](@ref) it is possible to get a NULL in `sample_handle_ptr`.

# Safety

* The `subscriber_handle` is still valid after the return of this function and can be use in another function call. * The `sample_handle_ptr` is pointing to a valid [[`iox2_sample_h`](@ref)].

### Prototype
```c
int iox2_subscriber_receive(iox2_subscriber_h_ref subscriber_handle, struct iox2_sample_t *sample_struct_ptr, iox2_sample_h *sample_handle_ptr);
```
"""
function iox2_subscriber_receive(subscriber_handle, sample_struct_ptr, sample_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_subscriber_receive(subscriber_handle::iox2_subscriber_h_ref, sample_struct_ptr::Ptr{iox2_sample_t}, sample_handle_ptr::Ptr{iox2_sample_h})::Cint
end

"""
    iox2_subscriber_has_samples(subscriber_handle, result_ptr)

Returns true when the subscriber has samples that can be acquired with [[`iox2_subscriber_receive`](@ref)], otherwise false.

# Arguments

* `subscriber_handle` - Must be a valid [[`iox2_subscriber_h_ref`](@ref)] obtained by [[`iox2_port_factory_subscriber_builder_create`](@ref)](crate::[`iox2_port_factory_subscriber_builder_create`](@ref)). * `result_ptr` - A non-null pointer to a bool that will contain the result.

Returns [`IOX2_OK`](@ref) on success, an [[`iox2_connection_failure_e`](@ref)] otherwise. Attention, an empty subscriber queue is not an error and even with [`IOX2_OK`](@ref) it is possible to get a NULL in `sample_handle_ptr`.

# Safety

* The `subscriber_handle` is still valid after the return of this function and can be use in another function call. * The `result_ptr` is pointing to a valid bool.

### Prototype
```c
int iox2_subscriber_has_samples(iox2_subscriber_h_ref subscriber_handle, bool *result_ptr);
```
"""
function iox2_subscriber_has_samples(subscriber_handle, result_ptr)
    @ccall libiceoryx2_ffi_c.iox2_subscriber_has_samples(subscriber_handle::iox2_subscriber_h_ref, result_ptr::Ptr{Bool})::Cint
end

"""
    iox2_subscriber_drop(subscriber_handle)

This function needs to be called to destroy the subscriber!

# Arguments

* `subscriber_handle` - A valid [[`iox2_subscriber_h`](@ref)]

# Safety

* The `subscriber_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_subscriber_t`](@ref)] can be re-used with a call to [[`iox2_port_factory_subscriber_builder_create`](@ref)](crate::[`iox2_port_factory_subscriber_builder_create`](@ref))!

### Prototype
```c
void iox2_subscriber_drop(iox2_subscriber_h subscriber_handle);
```
"""
function iox2_subscriber_drop(subscriber_handle)
    @ccall libiceoryx2_ffi_c.iox2_subscriber_drop(subscriber_handle::iox2_subscriber_h)::Cvoid
end

"""
    iox2_subscriber_details_subscriber_id(handle, id_struct_ptr, id_handle_ptr)

Returns the unique port id of the subscriber.

# Safety

* `handle` valid pointer to the subscriber details * `id_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_unique_subscriber_id_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `id_handle_ptr` valid pointer to a [[`iox2_unique_subscriber_id_h`](@ref)].

### Prototype
```c
void iox2_subscriber_details_subscriber_id(iox2_subscriber_details_ptr handle, struct iox2_unique_subscriber_id_t *id_struct_ptr, iox2_unique_subscriber_id_h *id_handle_ptr);
```
"""
function iox2_subscriber_details_subscriber_id(handle, id_struct_ptr, id_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_subscriber_details_subscriber_id(handle::iox2_subscriber_details_ptr, id_struct_ptr::Ptr{iox2_unique_subscriber_id_t}, id_handle_ptr::Ptr{iox2_unique_subscriber_id_h})::Cvoid
end

"""
    iox2_subscriber_details_node_id(handle)

Returns the [[`iox2_node_id_ptr`](@ref)](crate::[`iox2_node_id_ptr`](@ref)), an immutable pointer to the node id.

# Safety

* `handle` valid pointer to the subscriber details

### Prototype
```c
iox2_node_id_ptr iox2_subscriber_details_node_id(iox2_subscriber_details_ptr handle);
```
"""
function iox2_subscriber_details_node_id(handle)
    @ccall libiceoryx2_ffi_c.iox2_subscriber_details_node_id(handle::iox2_subscriber_details_ptr)::iox2_node_id_ptr
end

"""
    iox2_subscriber_details_buffer_size(handle)

Returns the size of the receive buffer that stores the incoming samples.

# Safety

* `handle` valid pointer to the subscriber details

### Prototype
```c
c_size_t iox2_subscriber_details_buffer_size(iox2_subscriber_details_ptr handle);
```
"""
function iox2_subscriber_details_buffer_size(handle)
    @ccall libiceoryx2_ffi_c.iox2_subscriber_details_buffer_size(handle::iox2_subscriber_details_ptr)::c_size_t
end

"""
    iox2_unique_client_id_value(handle, id_ptr, id_length)

Retrieves the value of a unique client ID.

# Arguments

* `handle` - A valid [[`iox2_unique_client_id_h`](@ref)] * `id_ptr` - Pointer to a buffer where the ID value will be written * `id_length` - The length of the buffer pointed to by `id_ptr`

# Safety

* `handle` must be a valid, non-null pointer * `id_ptr` must be a valid, non-null pointer to a buffer of at least `id_length` bytes * `id_length` must be large enough to hold the ID value

### Prototype
```c
void iox2_unique_client_id_value(iox2_unique_client_id_h handle, uint8_t *id_ptr, size_t id_length);
```
"""
function iox2_unique_client_id_value(handle, id_ptr, id_length)
    @ccall libiceoryx2_ffi_c.iox2_unique_client_id_value(handle::iox2_unique_client_id_h, id_ptr::Ptr{UInt8}, id_length::Csize_t)::Cvoid
end

"""
    iox2_unique_client_id_drop(handle)

This function needs to be called to destroy the unique client id!

# Arguments

* `handle` - A valid [[`iox2_unique_client_id_h`](@ref)]

# Safety

* The `handle` is invalid after the return of this function and leads to undefined behavior if used in another function call!

### Prototype
```c
void iox2_unique_client_id_drop(iox2_unique_client_id_h handle);
```
"""
function iox2_unique_client_id_drop(handle)
    @ccall libiceoryx2_ffi_c.iox2_unique_client_id_drop(handle::iox2_unique_client_id_h)::Cvoid
end

"""
    iox2_unique_client_id_eq(lhs, rhs)

Checks two [[`iox2_unique_client_id_t`](@ref)] for equality.

# Safety

* `lhs` - Must be a valid [[`iox2_unique_client_id_h_ref`](@ref)] * `rhs` - Must be a valid [[`iox2_unique_client_id_h_ref`](@ref)]

### Prototype
```c
bool iox2_unique_client_id_eq(iox2_unique_client_id_h_ref lhs, iox2_unique_client_id_h_ref rhs);
```
"""
function iox2_unique_client_id_eq(lhs, rhs)
    @ccall libiceoryx2_ffi_c.iox2_unique_client_id_eq(lhs::iox2_unique_client_id_h_ref, rhs::iox2_unique_client_id_h_ref)::Bool
end

"""
    iox2_unique_client_id_less(lhs, rhs)

Checks the ordering of two [[`iox2_unique_client_id_t`](@ref)].

# Safety

* `lhs` - Must be a valid [[`iox2_unique_client_id_h_ref`](@ref)] * `rhs` - Must be a valid [[`iox2_unique_client_id_h_ref`](@ref)]

### Prototype
```c
bool iox2_unique_client_id_less(iox2_unique_client_id_h_ref lhs, iox2_unique_client_id_h_ref rhs);
```
"""
function iox2_unique_client_id_less(lhs, rhs)
    @ccall libiceoryx2_ffi_c.iox2_unique_client_id_less(lhs::iox2_unique_client_id_h_ref, rhs::iox2_unique_client_id_h_ref)::Bool
end

"""
    iox2_unique_listener_id_value(handle, id_ptr, id_length)

Retrieves the value of a unique listener ID.

# Arguments

* `handle` - A valid [[`iox2_unique_listener_id_h`](@ref)] * `id_ptr` - Pointer to a buffer where the ID value will be written * `id_length` - The length of the buffer pointed to by `id_ptr`

# Safety

* `handle` must be a valid, non-null pointer * `id_ptr` must be a valid, non-null pointer to a buffer of at least `id_length` bytes * `id_length` must be large enough to hold the ID value

### Prototype
```c
void iox2_unique_listener_id_value(iox2_unique_listener_id_h handle, uint8_t *id_ptr, size_t id_length);
```
"""
function iox2_unique_listener_id_value(handle, id_ptr, id_length)
    @ccall libiceoryx2_ffi_c.iox2_unique_listener_id_value(handle::iox2_unique_listener_id_h, id_ptr::Ptr{UInt8}, id_length::Csize_t)::Cvoid
end

"""
    iox2_unique_listener_id_drop(handle)

This function needs to be called to destroy the unique listener id!

# Arguments

* `handle` - A valid [[`iox2_unique_listener_id_h`](@ref)]

# Safety

* The `handle` is invalid after the return of this function and leads to undefined behavior if used in another function call!

### Prototype
```c
void iox2_unique_listener_id_drop(iox2_unique_listener_id_h handle);
```
"""
function iox2_unique_listener_id_drop(handle)
    @ccall libiceoryx2_ffi_c.iox2_unique_listener_id_drop(handle::iox2_unique_listener_id_h)::Cvoid
end

"""
    iox2_unique_listener_id_eq(lhs, rhs)

Checks two [[`iox2_unique_listener_id_t`](@ref)] for equality.

# Safety

* `lhs` - Must be a valid [[`iox2_unique_listener_id_h_ref`](@ref)] * `rhs` - Must be a valid [[`iox2_unique_listener_id_h_ref`](@ref)]

### Prototype
```c
bool iox2_unique_listener_id_eq(iox2_unique_listener_id_h_ref lhs, iox2_unique_listener_id_h_ref rhs);
```
"""
function iox2_unique_listener_id_eq(lhs, rhs)
    @ccall libiceoryx2_ffi_c.iox2_unique_listener_id_eq(lhs::iox2_unique_listener_id_h_ref, rhs::iox2_unique_listener_id_h_ref)::Bool
end

"""
    iox2_unique_listener_id_less(lhs, rhs)

Checks the ordering of two [[`iox2_unique_listener_id_t`](@ref)].

# Safety

* `lhs` - Must be a valid [[`iox2_unique_listener_id_h_ref`](@ref)] * `rhs` - Must be a valid [[`iox2_unique_listener_id_h_ref`](@ref)]

### Prototype
```c
bool iox2_unique_listener_id_less(iox2_unique_listener_id_h_ref lhs, iox2_unique_listener_id_h_ref rhs);
```
"""
function iox2_unique_listener_id_less(lhs, rhs)
    @ccall libiceoryx2_ffi_c.iox2_unique_listener_id_less(lhs::iox2_unique_listener_id_h_ref, rhs::iox2_unique_listener_id_h_ref)::Bool
end

"""
    iox2_unique_notifier_id_value(handle, id_ptr, id_length)

Retrieves the value of a unique notifier ID.

# Arguments

* `handle` - A valid [[`iox2_unique_notifier_id_h`](@ref)] * `id_ptr` - Pointer to a buffer where the ID value will be written * `id_length` - The length of the buffer pointed to by `id_ptr`

# Safety

* `handle` must be a valid, non-null pointer * `id_ptr` must be a valid, non-null pointer to a buffer of at least `id_length` bytes * `id_length` must be large enough to hold the ID value

### Prototype
```c
void iox2_unique_notifier_id_value(iox2_unique_notifier_id_h handle, uint8_t *id_ptr, size_t id_length);
```
"""
function iox2_unique_notifier_id_value(handle, id_ptr, id_length)
    @ccall libiceoryx2_ffi_c.iox2_unique_notifier_id_value(handle::iox2_unique_notifier_id_h, id_ptr::Ptr{UInt8}, id_length::Csize_t)::Cvoid
end

"""
    iox2_unique_notifier_id_drop(handle)

This function needs to be called to destroy the unique notifier id!

# Arguments

* `handle` - A valid [[`iox2_unique_notifier_id_h`](@ref)]

# Safety

* The `handle` is invalid after the return of this function and leads to undefined behavior if used in another function call!

### Prototype
```c
void iox2_unique_notifier_id_drop(iox2_unique_notifier_id_h handle);
```
"""
function iox2_unique_notifier_id_drop(handle)
    @ccall libiceoryx2_ffi_c.iox2_unique_notifier_id_drop(handle::iox2_unique_notifier_id_h)::Cvoid
end

"""
    iox2_unique_notifier_id_eq(lhs, rhs)

Checks two [[`iox2_unique_notifier_id_t`](@ref)] for equality.

# Safety

* `lhs` - Must be a valid [[`iox2_unique_notifier_id_h_ref`](@ref)] * `rhs` - Must be a valid [[`iox2_unique_notifier_id_h_ref`](@ref)]

### Prototype
```c
bool iox2_unique_notifier_id_eq(iox2_unique_notifier_id_h_ref lhs, iox2_unique_notifier_id_h_ref rhs);
```
"""
function iox2_unique_notifier_id_eq(lhs, rhs)
    @ccall libiceoryx2_ffi_c.iox2_unique_notifier_id_eq(lhs::iox2_unique_notifier_id_h_ref, rhs::iox2_unique_notifier_id_h_ref)::Bool
end

"""
    iox2_unique_notifier_id_less(lhs, rhs)

Checks the ordering of two [[`iox2_unique_notifier_id_t`](@ref)].

# Safety

* `lhs` - Must be a valid [[`iox2_unique_notifier_id_h_ref`](@ref)] * `rhs` - Must be a valid [[`iox2_unique_notifier_id_h_ref`](@ref)]

### Prototype
```c
bool iox2_unique_notifier_id_less(iox2_unique_notifier_id_h_ref lhs, iox2_unique_notifier_id_h_ref rhs);
```
"""
function iox2_unique_notifier_id_less(lhs, rhs)
    @ccall libiceoryx2_ffi_c.iox2_unique_notifier_id_less(lhs::iox2_unique_notifier_id_h_ref, rhs::iox2_unique_notifier_id_h_ref)::Bool
end

"""
    iox2_unique_publisher_id_value(handle, id_ptr, id_length)

Retrieves the value of a unique publisher ID.

# Arguments

* `handle` - A valid [[`iox2_unique_publisher_id_h`](@ref)] * `id_ptr` - Pointer to a buffer where the ID value will be written * `id_length` - The length of the buffer pointed to by `id_ptr`

# Safety

* `handle` must be a valid, non-null pointer * `id_ptr` must be a valid, non-null pointer to a buffer of at least `id_length` bytes * `id_length` must be large enough to hold the ID value

### Prototype
```c
void iox2_unique_publisher_id_value(iox2_unique_publisher_id_h handle, uint8_t *id_ptr, size_t id_length);
```
"""
function iox2_unique_publisher_id_value(handle, id_ptr, id_length)
    @ccall libiceoryx2_ffi_c.iox2_unique_publisher_id_value(handle::iox2_unique_publisher_id_h, id_ptr::Ptr{UInt8}, id_length::Csize_t)::Cvoid
end

"""
    iox2_unique_publisher_id_drop(handle)

This function needs to be called to destroy the unique publisher id!

# Arguments

* `handle` - A valid [[`iox2_unique_publisher_id_h`](@ref)]

# Safety

* The `handle` is invalid after the return of this function and leads to undefined behavior if used in another function call!

### Prototype
```c
void iox2_unique_publisher_id_drop(iox2_unique_publisher_id_h handle);
```
"""
function iox2_unique_publisher_id_drop(handle)
    @ccall libiceoryx2_ffi_c.iox2_unique_publisher_id_drop(handle::iox2_unique_publisher_id_h)::Cvoid
end

"""
    iox2_unique_publisher_id_eq(lhs, rhs)

Checks two [[`iox2_unique_publisher_id_t`](@ref)] for equality.

# Safety

* `lhs` - Must be a valid [[`iox2_unique_publisher_id_h_ref`](@ref)] * `rhs` - Must be a valid [[`iox2_unique_publisher_id_h_ref`](@ref)]

### Prototype
```c
bool iox2_unique_publisher_id_eq(iox2_unique_publisher_id_h_ref lhs, iox2_unique_publisher_id_h_ref rhs);
```
"""
function iox2_unique_publisher_id_eq(lhs, rhs)
    @ccall libiceoryx2_ffi_c.iox2_unique_publisher_id_eq(lhs::iox2_unique_publisher_id_h_ref, rhs::iox2_unique_publisher_id_h_ref)::Bool
end

"""
    iox2_unique_publisher_id_less(lhs, rhs)

Checks the ordering of two [[`iox2_unique_publisher_id_t`](@ref)].

# Safety

* `lhs` - Must be a valid [[`iox2_unique_publisher_id_h_ref`](@ref)] * `rhs` - Must be a valid [[`iox2_unique_publisher_id_h_ref`](@ref)]

### Prototype
```c
bool iox2_unique_publisher_id_less(iox2_unique_publisher_id_h_ref lhs, iox2_unique_publisher_id_h_ref rhs);
```
"""
function iox2_unique_publisher_id_less(lhs, rhs)
    @ccall libiceoryx2_ffi_c.iox2_unique_publisher_id_less(lhs::iox2_unique_publisher_id_h_ref, rhs::iox2_unique_publisher_id_h_ref)::Bool
end

"""
    iox2_unique_reader_id_value(handle, id_ptr, id_length)

Retrieves the value of a unique reader ID.

# Arguments

* `handle` - A valid [[`iox2_unique_reader_id_h`](@ref)] * `id_ptr` - Pointer to a buffer where the ID value will be written * `id_length` - The length of the buffer pointed to by `id_ptr`

# Safety

* `handle` must be a valid, non-null pointer * `id_ptr` must be a valid, non-null pointer to a buffer of at least `id_length` bytes * `id_length` must be large enough to hold the ID value

### Prototype
```c
void iox2_unique_reader_id_value(iox2_unique_reader_id_h handle, uint8_t *id_ptr, size_t id_length);
```
"""
function iox2_unique_reader_id_value(handle, id_ptr, id_length)
    @ccall libiceoryx2_ffi_c.iox2_unique_reader_id_value(handle::iox2_unique_reader_id_h, id_ptr::Ptr{UInt8}, id_length::Csize_t)::Cvoid
end

"""
    iox2_unique_reader_id_drop(handle)

This function needs to be called to destroy the unique reader id!

# Arguments

* `handle` - A valid [[`iox2_unique_reader_id_h`](@ref)]

# Safety

* The `handle` is invalid after the return of this function and leads to undefined behavior if used in another function call!

### Prototype
```c
void iox2_unique_reader_id_drop(iox2_unique_reader_id_h handle);
```
"""
function iox2_unique_reader_id_drop(handle)
    @ccall libiceoryx2_ffi_c.iox2_unique_reader_id_drop(handle::iox2_unique_reader_id_h)::Cvoid
end

"""
    iox2_unique_reader_id_eq(lhs, rhs)

Checks two [[`iox2_unique_reader_id_t`](@ref)] for equality.

# Safety

* `lhs` - Must be a valid [[`iox2_unique_reader_id_h_ref`](@ref)] * `rhs` - Must be a valid [[`iox2_unique_reader_id_h_ref`](@ref)]

### Prototype
```c
bool iox2_unique_reader_id_eq(iox2_unique_reader_id_h_ref lhs, iox2_unique_reader_id_h_ref rhs);
```
"""
function iox2_unique_reader_id_eq(lhs, rhs)
    @ccall libiceoryx2_ffi_c.iox2_unique_reader_id_eq(lhs::iox2_unique_reader_id_h_ref, rhs::iox2_unique_reader_id_h_ref)::Bool
end

"""
    iox2_unique_reader_id_less(lhs, rhs)

Checks the ordering of two [[`iox2_unique_reader_id_t`](@ref)].

# Safety

* `lhs` - Must be a valid [[`iox2_unique_reader_id_h_ref`](@ref)] * `rhs` - Must be a valid [[`iox2_unique_reader_id_h_ref`](@ref)]

### Prototype
```c
bool iox2_unique_reader_id_less(iox2_unique_reader_id_h_ref lhs, iox2_unique_reader_id_h_ref rhs);
```
"""
function iox2_unique_reader_id_less(lhs, rhs)
    @ccall libiceoryx2_ffi_c.iox2_unique_reader_id_less(lhs::iox2_unique_reader_id_h_ref, rhs::iox2_unique_reader_id_h_ref)::Bool
end

"""
    iox2_unique_server_id_value(handle, id_ptr, id_length)

Retrieves the value of a unique server ID.

# Arguments

* `handle` - A valid [[`iox2_unique_server_id_h`](@ref)] * `id_ptr` - Pointer to a buffer where the ID value will be written * `id_length` - The length of the buffer pointed to by `id_ptr`

# Safety

* `handle` must be a valid, non-null pointer * `id_ptr` must be a valid, non-null pointer to a buffer of at least `id_length` bytes * `id_length` must be large enough to hold the ID value

### Prototype
```c
void iox2_unique_server_id_value(iox2_unique_server_id_h handle, uint8_t *id_ptr, size_t id_length);
```
"""
function iox2_unique_server_id_value(handle, id_ptr, id_length)
    @ccall libiceoryx2_ffi_c.iox2_unique_server_id_value(handle::iox2_unique_server_id_h, id_ptr::Ptr{UInt8}, id_length::Csize_t)::Cvoid
end

"""
    iox2_unique_server_id_drop(handle)

This function needs to be called to destroy the unique server id!

# Arguments

* `handle` - A valid [[`iox2_unique_server_id_h`](@ref)]

# Safety

* The `handle` is invalid after the return of this function and leads to undefined behavior if used in another function call!

### Prototype
```c
void iox2_unique_server_id_drop(iox2_unique_server_id_h handle);
```
"""
function iox2_unique_server_id_drop(handle)
    @ccall libiceoryx2_ffi_c.iox2_unique_server_id_drop(handle::iox2_unique_server_id_h)::Cvoid
end

"""
    iox2_unique_server_id_eq(lhs, rhs)

Checks two [[`iox2_unique_server_id_t`](@ref)] for equality.

# Safety

* `lhs` - Must be a valid [[`iox2_unique_server_id_h_ref`](@ref)] * `rhs` - Must be a valid [[`iox2_unique_server_id_h_ref`](@ref)]

### Prototype
```c
bool iox2_unique_server_id_eq(iox2_unique_server_id_h_ref lhs, iox2_unique_server_id_h_ref rhs);
```
"""
function iox2_unique_server_id_eq(lhs, rhs)
    @ccall libiceoryx2_ffi_c.iox2_unique_server_id_eq(lhs::iox2_unique_server_id_h_ref, rhs::iox2_unique_server_id_h_ref)::Bool
end

"""
    iox2_unique_server_id_less(lhs, rhs)

Checks the ordering of two [[`iox2_unique_server_id_t`](@ref)].

# Safety

* `lhs` - Must be a valid [[`iox2_unique_server_id_h_ref`](@ref)] * `rhs` - Must be a valid [[`iox2_unique_server_id_h_ref`](@ref)]

### Prototype
```c
bool iox2_unique_server_id_less(iox2_unique_server_id_h_ref lhs, iox2_unique_server_id_h_ref rhs);
```
"""
function iox2_unique_server_id_less(lhs, rhs)
    @ccall libiceoryx2_ffi_c.iox2_unique_server_id_less(lhs::iox2_unique_server_id_h_ref, rhs::iox2_unique_server_id_h_ref)::Bool
end

"""
    iox2_unique_subscriber_id_value(handle, id_ptr, id_length)

Retrieves the value of a unique subscriber ID.

# Arguments

* `handle` - A valid [[`iox2_unique_subscriber_id_h`](@ref)] * `id_ptr` - Pointer to a buffer where the ID value will be written * `id_length` - The length of the buffer pointed to by `id_ptr`

# Safety

* `handle` must be a valid, non-null pointer * `id_ptr` must be a valid, non-null pointer to a buffer of at least `id_length` bytes * `id_length` must be large enough to hold the ID value

### Prototype
```c
void iox2_unique_subscriber_id_value(iox2_unique_subscriber_id_h handle, uint8_t *id_ptr, size_t id_length);
```
"""
function iox2_unique_subscriber_id_value(handle, id_ptr, id_length)
    @ccall libiceoryx2_ffi_c.iox2_unique_subscriber_id_value(handle::iox2_unique_subscriber_id_h, id_ptr::Ptr{UInt8}, id_length::Csize_t)::Cvoid
end

"""
    iox2_unique_subscriber_id_drop(handle)

This function needs to be called to destroy the unique subscriber id!

# Arguments

* `handle` - A valid [[`iox2_unique_subscriber_id_h`](@ref)]

# Safety

* The `handle` is invalid after the return of this function and leads to undefined behavior if used in another function call!

### Prototype
```c
void iox2_unique_subscriber_id_drop(iox2_unique_subscriber_id_h handle);
```
"""
function iox2_unique_subscriber_id_drop(handle)
    @ccall libiceoryx2_ffi_c.iox2_unique_subscriber_id_drop(handle::iox2_unique_subscriber_id_h)::Cvoid
end

"""
    iox2_unique_subscriber_id_eq(lhs, rhs)

Checks two [[`iox2_unique_subscriber_id_t`](@ref)] for equality.

# Safety

* `lhs` - Must be a valid [[`iox2_unique_subscriber_id_h_ref`](@ref)] * `rhs` - Must be a valid [[`iox2_unique_subscriber_id_h_ref`](@ref)]

### Prototype
```c
bool iox2_unique_subscriber_id_eq(iox2_unique_subscriber_id_h_ref lhs, iox2_unique_subscriber_id_h_ref rhs);
```
"""
function iox2_unique_subscriber_id_eq(lhs, rhs)
    @ccall libiceoryx2_ffi_c.iox2_unique_subscriber_id_eq(lhs::iox2_unique_subscriber_id_h_ref, rhs::iox2_unique_subscriber_id_h_ref)::Bool
end

"""
    iox2_unique_subscriber_id_less(lhs, rhs)

Checks the ordering of two [[`iox2_unique_subscriber_id_t`](@ref)].

# Safety

* `lhs` - Must be a valid [[`iox2_unique_subscriber_id_h_ref`](@ref)] * `rhs` - Must be a valid [[`iox2_unique_subscriber_id_h_ref`](@ref)]

### Prototype
```c
bool iox2_unique_subscriber_id_less(iox2_unique_subscriber_id_h_ref lhs, iox2_unique_subscriber_id_h_ref rhs);
```
"""
function iox2_unique_subscriber_id_less(lhs, rhs)
    @ccall libiceoryx2_ffi_c.iox2_unique_subscriber_id_less(lhs::iox2_unique_subscriber_id_h_ref, rhs::iox2_unique_subscriber_id_h_ref)::Bool
end

"""
    iox2_unique_writer_id_value(handle, id_ptr, id_length)

Retrieves the value of a unique writer ID.

# Arguments

* `handle` - A valid [[`iox2_unique_writer_id_h`](@ref)] * `id_ptr` - Pointer to a buffer where the ID value will be written * `id_length` - The length of the buffer pointed to by `id_ptr`

# Safety

* `handle` must be a valid, non-null pointer * `id_ptr` must be a valid, non-null pointer to a buffer of at least `id_length` bytes * `id_length` must be large enough to hold the ID value

### Prototype
```c
void iox2_unique_writer_id_value(iox2_unique_writer_id_h handle, uint8_t *id_ptr, size_t id_length);
```
"""
function iox2_unique_writer_id_value(handle, id_ptr, id_length)
    @ccall libiceoryx2_ffi_c.iox2_unique_writer_id_value(handle::iox2_unique_writer_id_h, id_ptr::Ptr{UInt8}, id_length::Csize_t)::Cvoid
end

"""
    iox2_unique_writer_id_drop(handle)

This function needs to be called to destroy the unique writer id!

# Arguments

* `handle` - A valid [[`iox2_unique_writer_id_h`](@ref)]

# Safety

* The `handle` is invalid after the return of this function and leads to undefined behavior if used in another function call!

### Prototype
```c
void iox2_unique_writer_id_drop(iox2_unique_writer_id_h handle);
```
"""
function iox2_unique_writer_id_drop(handle)
    @ccall libiceoryx2_ffi_c.iox2_unique_writer_id_drop(handle::iox2_unique_writer_id_h)::Cvoid
end

"""
    iox2_unique_writer_id_eq(lhs, rhs)

Checks two [[`iox2_unique_writer_id_t`](@ref)] for equality.

# Safety

* `lhs` - Must be a valid [[`iox2_unique_writer_id_h_ref`](@ref)] * `rhs` - Must be a valid [[`iox2_unique_writer_id_h_ref`](@ref)]

### Prototype
```c
bool iox2_unique_writer_id_eq(iox2_unique_writer_id_h_ref lhs, iox2_unique_writer_id_h_ref rhs);
```
"""
function iox2_unique_writer_id_eq(lhs, rhs)
    @ccall libiceoryx2_ffi_c.iox2_unique_writer_id_eq(lhs::iox2_unique_writer_id_h_ref, rhs::iox2_unique_writer_id_h_ref)::Bool
end

"""
    iox2_unique_writer_id_less(lhs, rhs)

Checks the ordering of two [[`iox2_unique_writer_id_t`](@ref)].

# Safety

* `lhs` - Must be a valid [[`iox2_unique_writer_id_h_ref`](@ref)] * `rhs` - Must be a valid [[`iox2_unique_writer_id_h_ref`](@ref)]

### Prototype
```c
bool iox2_unique_writer_id_less(iox2_unique_writer_id_h_ref lhs, iox2_unique_writer_id_h_ref rhs);
```
"""
function iox2_unique_writer_id_less(lhs, rhs)
    @ccall libiceoryx2_ffi_c.iox2_unique_writer_id_less(lhs::iox2_unique_writer_id_h_ref, rhs::iox2_unique_writer_id_h_ref)::Bool
end

"""
    iox2_waitset_create_error_string(error)

Returns a string literal describing the provided [[`iox2_waitset_create_error_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_waitset_create_error_string(enum iox2_waitset_create_error_e error);
```
"""
function iox2_waitset_create_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_waitset_create_error_string(error::iox2_waitset_create_error_e)::Cstring
end

"""
    iox2_waitset_attachment_error_string(error)

Returns a string literal describing the provided [[`iox2_waitset_attachment_error_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_waitset_attachment_error_string(enum iox2_waitset_attachment_error_e error);
```
"""
function iox2_waitset_attachment_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_waitset_attachment_error_string(error::iox2_waitset_attachment_error_e)::Cstring
end

"""
    iox2_waitset_run_error_string(error)

Returns a string literal describing the provided [[`iox2_waitset_run_error_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_waitset_run_error_string(enum iox2_waitset_run_error_e error);
```
"""
function iox2_waitset_run_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_waitset_run_error_string(error::iox2_waitset_run_error_e)::Cstring
end

"""
    iox2_waitset_drop(handle)

Drops a [[`iox2_waitset_h`](@ref)] and calls all corresponding cleanup functions.

# Safety

* `handle` must be valid and acquired with [`[`iox2_waitset_builder_create`](@ref)()`](crate::[`iox2_waitset_builder_create`](@ref)())

### Prototype
```c
void iox2_waitset_drop(iox2_waitset_h handle);
```
"""
function iox2_waitset_drop(handle)
    @ccall libiceoryx2_ffi_c.iox2_waitset_drop(handle::iox2_waitset_h)::Cvoid
end

"""
    iox2_waitset_is_empty(handle)

Returns `true` if the [[`iox2_waitset_h`](@ref)] is empty, otherwise false.

# Safety

* `handle` must be valid and acquired with [`[`iox2_waitset_builder_create`](@ref)()`](crate::[`iox2_waitset_builder_create`](@ref)())

### Prototype
```c
bool iox2_waitset_is_empty(iox2_waitset_h_ref handle);
```
"""
function iox2_waitset_is_empty(handle)
    @ccall libiceoryx2_ffi_c.iox2_waitset_is_empty(handle::iox2_waitset_h_ref)::Bool
end

"""
    iox2_waitset_signal_handling_mode(handle)

Returns the [[`iox2_signal_handling_mode_e`](@ref)] with which the waitset was created.

# Safety

* `handle` must be valid and acquired with [`[`iox2_waitset_builder_create`](@ref)()`](crate::[`iox2_waitset_builder_create`](@ref)())

### Prototype
```c
enum iox2_signal_handling_mode_e iox2_waitset_signal_handling_mode(iox2_waitset_h_ref handle);
```
"""
function iox2_waitset_signal_handling_mode(handle)
    @ccall libiceoryx2_ffi_c.iox2_waitset_signal_handling_mode(handle::iox2_waitset_h_ref)::iox2_signal_handling_mode_e
end

"""
    iox2_waitset_len(handle)

Returns the number of attachments of the [[`iox2_waitset_h`](@ref)].

# Safety

* `handle` must be valid and acquired with [`[`iox2_waitset_builder_create`](@ref)()`](crate::[`iox2_waitset_builder_create`](@ref)())

### Prototype
```c
c_size_t iox2_waitset_len(iox2_waitset_h_ref handle);
```
"""
function iox2_waitset_len(handle)
    @ccall libiceoryx2_ffi_c.iox2_waitset_len(handle::iox2_waitset_h_ref)::c_size_t
end

"""
    iox2_waitset_capacity(handle)

Returns the capacity of the [[`iox2_waitset_h`](@ref)].

# Safety

* `handle` must be valid and acquired with [`[`iox2_waitset_builder_create`](@ref)()`](crate::[`iox2_waitset_builder_create`](@ref)())

### Prototype
```c
c_size_t iox2_waitset_capacity(iox2_waitset_h_ref handle);
```
"""
function iox2_waitset_capacity(handle)
    @ccall libiceoryx2_ffi_c.iox2_waitset_capacity(handle::iox2_waitset_h_ref)::c_size_t
end

"""
    iox2_waitset_attach_notification(handle, fd, guard_struct_ptr, guard_handle_ptr)

Attaches a provided [[`iox2_file_descriptor_ptr`](@ref)] as notification to the [[`iox2_waitset_h`](@ref)]. As soon as the attachment receives data, the WaitSet wakes up in [`[`iox2_waitset_wait_and_process`](@ref)()`] and informs the user.

With [`[`iox2_waitset_attachment_id_has_event_from`](@ref)()`](crate::[`iox2_waitset_attachment_id_has_event_from`](@ref)()) the origin of the event can be determined from its corresponding [[`iox2_waitset_guard_h`](@ref)].

# Return

[`IOX2_OK`](@ref) on success, otherwise [[`iox2_waitset_attachment_error_e`](@ref)].

# Safety

* `handle` must be valid and acquired with [`[`iox2_waitset_builder_create`](@ref)()`](crate::[`iox2_waitset_builder_create`](@ref)()) * `guard_struct_ptr` must be either pointing to a valid uninitialized memory position or `null` * `guard_handle_ptr` must be pointing to valid uninitialized memory. * `guard_handle_ptr` must be released with [`[`iox2_waitset_guard_drop`](@ref)()`](crate::[`iox2_waitset_guard_drop`](@ref)()).

### Prototype
```c
int iox2_waitset_attach_notification(iox2_waitset_h_ref handle, iox2_file_descriptor_ptr fd, struct iox2_waitset_guard_t *guard_struct_ptr, iox2_waitset_guard_h *guard_handle_ptr);
```
"""
function iox2_waitset_attach_notification(handle, fd, guard_struct_ptr, guard_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_waitset_attach_notification(handle::iox2_waitset_h_ref, fd::iox2_file_descriptor_ptr, guard_struct_ptr::Ptr{iox2_waitset_guard_t}, guard_handle_ptr::Ptr{iox2_waitset_guard_h})::Cint
end

"""
    iox2_waitset_attach_deadline(handle, fd, seconds, nanoseconds, guard_struct_ptr, guard_handle_ptr)

Attaches a provided [[`iox2_file_descriptor_ptr`](@ref)] as deadline to the [[`iox2_waitset_h`](@ref)]. As soon as the attachment receives data or the deadline was missed, the WaitSet wakes up in [`[`iox2_waitset_wait_and_process`](@ref)()`] and informs the user.

With [`[`iox2_waitset_attachment_id_has_event_from`](@ref)()`](crate::[`iox2_waitset_attachment_id_has_event_from`](@ref)()) the origin of the event can be determined from its corresponding [[`iox2_waitset_guard_h`](@ref)]. If the deadline was hit the function [`[`iox2_waitset_attachment_id_has_missed_deadline`](@ref)()`](crate::[`iox2_waitset_attachment_id_has_missed_deadline`](@ref)()) can be used to identify it.

# Return

[`IOX2_OK`](@ref) on success, otherwise [[`iox2_waitset_attachment_error_e`](@ref)].

# Safety

* `handle` must be valid and acquired with [`[`iox2_waitset_builder_create`](@ref)()`](crate::[`iox2_waitset_builder_create`](@ref)()) * `guard_struct_ptr` must be either pointing to a valid uninitialized memory position or `null` * `guard_handle_ptr` must be pointing to valid uninitialized memory. * `guard_handle_ptr` must be released with [`[`iox2_waitset_guard_drop`](@ref)()`](crate::[`iox2_waitset_guard_drop`](@ref)()).

### Prototype
```c
int iox2_waitset_attach_deadline(iox2_waitset_h_ref handle, iox2_file_descriptor_ptr fd, uint64_t seconds, uint32_t nanoseconds, struct iox2_waitset_guard_t *guard_struct_ptr, iox2_waitset_guard_h *guard_handle_ptr);
```
"""
function iox2_waitset_attach_deadline(handle, fd, seconds, nanoseconds, guard_struct_ptr, guard_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_waitset_attach_deadline(handle::iox2_waitset_h_ref, fd::iox2_file_descriptor_ptr, seconds::UInt64, nanoseconds::UInt32, guard_struct_ptr::Ptr{iox2_waitset_guard_t}, guard_handle_ptr::Ptr{iox2_waitset_guard_h})::Cint
end

"""
    iox2_waitset_attach_interval(handle, seconds, nanoseconds, guard_struct_ptr, guard_handle_ptr)

Attaches an interval to the [[`iox2_waitset_h`](@ref)]. As soon as the interval has passed the WaitSet wakes up in [`[`iox2_waitset_wait_and_process`](@ref)()`] and informs the user.

With [`[`iox2_waitset_attachment_id_has_event_from`](@ref)()`](crate::[`iox2_waitset_attachment_id_has_event_from`](@ref)()) the origin of the event can be determined from its corresponding [[`iox2_waitset_guard_h`](@ref)].

# Return

[`IOX2_OK`](@ref) on success, otherwise [[`iox2_waitset_attachment_error_e`](@ref)].

# Safety

* `handle` must be valid and acquired with [`[`iox2_waitset_builder_create`](@ref)()`](crate::[`iox2_waitset_builder_create`](@ref)()) * `guard_struct_ptr` must be either pointing to a valid uninitialized memory position or `null` * `guard_handle_ptr` must be pointing to valid uninitialized memory. * `guard_handle_ptr` must be released with [`[`iox2_waitset_guard_drop`](@ref)()`](crate::[`iox2_waitset_guard_drop`](@ref)()).

### Prototype
```c
int iox2_waitset_attach_interval(iox2_waitset_h_ref handle, uint64_t seconds, uint32_t nanoseconds, struct iox2_waitset_guard_t *guard_struct_ptr, iox2_waitset_guard_h *guard_handle_ptr);
```
"""
function iox2_waitset_attach_interval(handle, seconds, nanoseconds, guard_struct_ptr, guard_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_waitset_attach_interval(handle::iox2_waitset_h_ref, seconds::UInt64, nanoseconds::UInt32, guard_struct_ptr::Ptr{iox2_waitset_guard_t}, guard_handle_ptr::Ptr{iox2_waitset_guard_h})::Cint
end

"""
    iox2_waitset_wait_and_process_once(handle, callback, callback_ctx, result)

Waits until an event arrives on the [[`iox2_waitset_h`](@ref)], then collects all events by calling the provided `fn_call` callback with the corresponding [[`iox2_waitset_attachment_id_h`](@ref)] and then returns. This makes it ideal to be called in some kind of event-loop.

The provided callback must return [`[`iox2_callback_progression_e`](@ref)::CONTINUE`] to continue the event processing and handle the next event or [`[`iox2_callback_progression_e`](@ref)::STOP`] to return from this call immediately. All unhandled events will be lost forever and the call will return [`[`iox2_waitset_run_result_e`](@ref)::STOP\\_REQUEST`].

If an interrupt- (`SIGINT`) or a termination-signal (`SIGTERM`) was received, it will exit the loop and inform the user with [`[`iox2_waitset_run_result_e`](@ref)::INTERRUPT`] or [`[`iox2_waitset_run_result_e`](@ref)::TERMINATION\\_REQUEST`].

When no signal was received and all events were handled, it will return [`[`iox2_waitset_run_result_e`](@ref)::ALL\\_EVENTS\\_HANDLED`]. # Return

[`IOX2_OK`](@ref) on success, otherwise [[`iox2_waitset_run_error_e`](@ref)].

# Safety

* `handle` must be valid and acquired with [`[`iox2_waitset_builder_create`](@ref)()`](crate::[`iox2_waitset_builder_create`](@ref)()) * the provided [[`iox2_waitset_attachment_id_h`](@ref)] in the callback must be released via [`[`iox2_waitset_attachment_id_drop`](@ref)()`](crate::[`iox2_waitset_attachment_id_drop`](@ref)())

### Prototype
```c
int iox2_waitset_wait_and_process_once(iox2_waitset_h_ref handle, iox2_waitset_run_callback callback, iox2_callback_context callback_ctx, enum iox2_waitset_run_result_e *result);
```
"""
function iox2_waitset_wait_and_process_once(handle, callback, callback_ctx, result)
    @ccall libiceoryx2_ffi_c.iox2_waitset_wait_and_process_once(handle::iox2_waitset_h_ref, callback::iox2_waitset_run_callback, callback_ctx::iox2_callback_context, result::Ptr{iox2_waitset_run_result_e})::Cint
end

"""
    iox2_waitset_wait_and_process_once_with_timeout(handle, callback, callback_ctx, seconds, nanoseconds, result)

Waits until an event arrives on the [[`iox2_waitset_h`](@ref)] or the provided timeout has passed, then collects all events by calling the provided `fn_call` callback with the corresponding [[`iox2_waitset_attachment_id_h`](@ref)] and then returns. This makes it ideal to be called in some kind of event-loop.

The provided callback must return [`[`iox2_callback_progression_e`](@ref)::CONTINUE`] to continue the event processing and handle the next event or [`[`iox2_callback_progression_e`](@ref)::STOP`] to return from this call immediately. All unhandled events will be lost forever and the call will return [`[`iox2_waitset_run_result_e`](@ref)::STOP\\_REQUEST`].

If an interrupt- (`SIGINT`) or a termination-signal (`SIGTERM`) was received, it will exit the loop and inform the user with [`[`iox2_waitset_run_result_e`](@ref)::INTERRUPT`] or [`[`iox2_waitset_run_result_e`](@ref)::TERMINATION\\_REQUEST`].

When no signal was received and all events were handled, it will return [`[`iox2_waitset_run_result_e`](@ref)::ALL\\_EVENTS\\_HANDLED`]. # Return

[`IOX2_OK`](@ref) on success, otherwise [[`iox2_waitset_run_error_e`](@ref)].

# Safety

* `handle` must be valid and acquired with [`[`iox2_waitset_builder_create`](@ref)()`](crate::[`iox2_waitset_builder_create`](@ref)()) * the provided [[`iox2_waitset_attachment_id_h`](@ref)] in the callback must be released via [`[`iox2_waitset_attachment_id_drop`](@ref)()`](crate::[`iox2_waitset_attachment_id_drop`](@ref)())

### Prototype
```c
int iox2_waitset_wait_and_process_once_with_timeout(iox2_waitset_h_ref handle, iox2_waitset_run_callback callback, iox2_callback_context callback_ctx, uint64_t seconds, uint32_t nanoseconds, enum iox2_waitset_run_result_e *result);
```
"""
function iox2_waitset_wait_and_process_once_with_timeout(handle, callback, callback_ctx, seconds, nanoseconds, result)
    @ccall libiceoryx2_ffi_c.iox2_waitset_wait_and_process_once_with_timeout(handle::iox2_waitset_h_ref, callback::iox2_waitset_run_callback, callback_ctx::iox2_callback_context, seconds::UInt64, nanoseconds::UInt32, result::Ptr{iox2_waitset_run_result_e})::Cint
end

"""
    iox2_waitset_wait_and_process(handle, callback, callback_ctx, result)

Checks the [[`iox2_waitset_h`](@ref)] for new events in an infinite loop. The provided `callback` is called for every events that was received and the corresponding owning [[`iox2_waitset_attachment_id_h`](@ref)] is provided as input argument, as well as the `callback_ctx`. The infinite loop is interrupted either by a `SIGINT` or `SIGTERM` signal or when the user callback returned [`[`iox2_callback_progression_e`](@ref)::STOP`].

With [`[`iox2_waitset_attachment_id_has_event_from`](@ref)()`](crate::[`iox2_waitset_attachment_id_has_event_from`](@ref)()) the origin of the event can be determined from its corresponding [[`iox2_waitset_guard_h`](@ref)]. If the deadline was hit the function [`[`iox2_waitset_attachment_id_has_missed_deadline`](@ref)()`](crate::[`iox2_waitset_attachment_id_has_missed_deadline`](@ref)()) can be used to identify it.

# Return

[`IOX2_OK`](@ref) on success, otherwise [[`iox2_waitset_run_error_e`](@ref)].

# Safety

* `handle` must be valid and acquired with [`[`iox2_waitset_builder_create`](@ref)()`](crate::[`iox2_waitset_builder_create`](@ref)()) * the provided [[`iox2_waitset_attachment_id_h`](@ref)] in the callback must be released via [`[`iox2_waitset_attachment_id_drop`](@ref)()`](crate::[`iox2_waitset_attachment_id_drop`](@ref)())

### Prototype
```c
int iox2_waitset_wait_and_process(iox2_waitset_h_ref handle, iox2_waitset_run_callback callback, iox2_callback_context callback_ctx, enum iox2_waitset_run_result_e *result);
```
"""
function iox2_waitset_wait_and_process(handle, callback, callback_ctx, result)
    @ccall libiceoryx2_ffi_c.iox2_waitset_wait_and_process(handle::iox2_waitset_h_ref, callback::iox2_waitset_run_callback, callback_ctx::iox2_callback_context, result::Ptr{iox2_waitset_run_result_e})::Cint
end

"""
    iox2_waitset_attachment_id_drop(handle)

Release an [[`iox2_waitset_attachment_id_h`](@ref)] that was acquired by calling either * [`[`iox2_waitset_wait_and_process`](@ref)()`](crate::[`iox2_waitset_wait_and_process`](@ref)()) * [`[`iox2_waitset_wait_and_process_once`](@ref)()`](crate::[`iox2_waitset_wait_and_process_once`](@ref)())

# Safety * `handle` must be valid and provided by the previously mentioned functions.

### Prototype
```c
void iox2_waitset_attachment_id_drop(iox2_waitset_attachment_id_h handle);
```
"""
function iox2_waitset_attachment_id_drop(handle)
    @ccall libiceoryx2_ffi_c.iox2_waitset_attachment_id_drop(handle::iox2_waitset_attachment_id_h)::Cvoid
end

"""
    iox2_waitset_attachment_id_equal(lhs, rhs)

Checks if two provided [[`iox2_waitset_attachment_id_h_ref`](@ref)] are semantically equal.

# Safety * `lhs` must be valid and non-null. * `rhs` must be valid and non-null.

### Prototype
```c
bool iox2_waitset_attachment_id_equal(iox2_waitset_attachment_id_h_ref lhs, iox2_waitset_attachment_id_h_ref rhs);
```
"""
function iox2_waitset_attachment_id_equal(lhs, rhs)
    @ccall libiceoryx2_ffi_c.iox2_waitset_attachment_id_equal(lhs::iox2_waitset_attachment_id_h_ref, rhs::iox2_waitset_attachment_id_h_ref)::Bool
end

"""
    iox2_waitset_attachment_id_less(lhs, rhs)

Checks the ordering of two provided [[`iox2_waitset_attachment_id_h_ref`](@ref)].

# Safety * `lhs` must be valid and non-null. * `rhs` must be valid and non-null.

### Prototype
```c
bool iox2_waitset_attachment_id_less(iox2_waitset_attachment_id_h_ref lhs, iox2_waitset_attachment_id_h_ref rhs);
```
"""
function iox2_waitset_attachment_id_less(lhs, rhs)
    @ccall libiceoryx2_ffi_c.iox2_waitset_attachment_id_less(lhs::iox2_waitset_attachment_id_h_ref, rhs::iox2_waitset_attachment_id_h_ref)::Bool
end

"""
    iox2_waitset_attachment_id_has_event_from(handle, guard)

Checks if the event corresponding to [[`iox2_waitset_guard_h_ref`](@ref)] was originating from the provided [[`iox2_waitset_attachment_id_h_ref`](@ref)].

# Safety * `handle` must be valid and non-null. * `guard` must be valid and non-null.

### Prototype
```c
bool iox2_waitset_attachment_id_has_event_from(iox2_waitset_attachment_id_h_ref handle, iox2_waitset_guard_h_ref guard);
```
"""
function iox2_waitset_attachment_id_has_event_from(handle, guard)
    @ccall libiceoryx2_ffi_c.iox2_waitset_attachment_id_has_event_from(handle::iox2_waitset_attachment_id_h_ref, guard::iox2_waitset_guard_h_ref)::Bool
end

"""
    iox2_waitset_attachment_id_has_missed_deadline(handle, guard)

Checks if the deadline corresponding to [[`iox2_waitset_guard_h_ref`](@ref)] was originating from the provided [[`iox2_waitset_attachment_id_h_ref`](@ref)].

# Safety * `handle` must be valid and non-null. * `guard` must be valid and non-null.

### Prototype
```c
bool iox2_waitset_attachment_id_has_missed_deadline(iox2_waitset_attachment_id_h_ref handle, iox2_waitset_guard_h_ref guard);
```
"""
function iox2_waitset_attachment_id_has_missed_deadline(handle, guard)
    @ccall libiceoryx2_ffi_c.iox2_waitset_attachment_id_has_missed_deadline(handle::iox2_waitset_attachment_id_h_ref, guard::iox2_waitset_guard_h_ref)::Bool
end

"""
    iox2_waitset_attachment_id_from_guard(guard, attachment_id_struct_ptr, attachment_id_handle_ptr)

Creates a new [[`iox2_waitset_attachment_id_t`](@ref)] from an existing [[`iox2_waitset_guard_h_ref`](@ref)].

# Safety * `guard` must be valid and non-null. * `attachment_id_struct_ptr` must be either null or pointing to a valid uninitialized memory location. * `attachment_id_handle_ptr` must point to a valid uninitialized memory location * `attachment_id_handle_ptr` must be released with [`[`iox2_waitset_attachment_id_drop`](@ref)()`]

### Prototype
```c
void iox2_waitset_attachment_id_from_guard(iox2_waitset_guard_h_ref guard, struct iox2_waitset_attachment_id_t *attachment_id_struct_ptr, iox2_waitset_attachment_id_h *attachment_id_handle_ptr);
```
"""
function iox2_waitset_attachment_id_from_guard(guard, attachment_id_struct_ptr, attachment_id_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_waitset_attachment_id_from_guard(guard::iox2_waitset_guard_h_ref, attachment_id_struct_ptr::Ptr{iox2_waitset_attachment_id_t}, attachment_id_handle_ptr::Ptr{iox2_waitset_attachment_id_h})::Cvoid
end

"""
    iox2_waitset_attachment_id_debug(handle, debug_output, debug_len)

Stores the debug output in the provided `debug_output` variable that must provide enough memory to store the content. The content length can be acquired with [`[`iox2_waitset_attachment_id_debug_len`](@ref)()`]

# Safety * `handle` must be valid and non-null. * `debug_output` must be valid and provide enough memory * `debug_len` the provided memory length of `debug_output`

### Prototype
```c
bool iox2_waitset_attachment_id_debug(iox2_waitset_attachment_id_h_ref handle, char *debug_output, c_size_t debug_len);
```
"""
function iox2_waitset_attachment_id_debug(handle, debug_output, debug_len)
    @ccall libiceoryx2_ffi_c.iox2_waitset_attachment_id_debug(handle::iox2_waitset_attachment_id_h_ref, debug_output::Cstring, debug_len::c_size_t)::Bool
end

"""
    iox2_waitset_attachment_id_debug_len(handle)

Returns the length of the debug output. Shall be used before calling [`[`iox2_waitset_attachment_id_debug`](@ref)()`] to acquire enough memory to store the output.

# Safety * `handle` must be valid and non-null.

### Prototype
```c
c_size_t iox2_waitset_attachment_id_debug_len(iox2_waitset_attachment_id_h_ref handle);
```
"""
function iox2_waitset_attachment_id_debug_len(handle)
    @ccall libiceoryx2_ffi_c.iox2_waitset_attachment_id_debug_len(handle::iox2_waitset_attachment_id_h_ref)::c_size_t
end

"""
    iox2_waitset_builder_new(struct_ptr, handle_ptr)

Creates a new [[`iox2_waitset_builder_t`](@ref)] to create a [[`iox2_waitset_t`](@ref)] with [`[`iox2_waitset_builder_create`](@ref)()`]

# Safety

* `struct_ptr` must be either a valid pointer to uninitialized memory or `null` * `handle_ptr` must point to a valid uninitialized memory location * The acquire handle must be cleaned up with [`[`iox2_waitset_builder_drop`](@ref)()`].

### Prototype
```c
void iox2_waitset_builder_new(struct iox2_waitset_builder_t *struct_ptr, iox2_waitset_builder_h *handle_ptr);
```
"""
function iox2_waitset_builder_new(struct_ptr, handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_waitset_builder_new(struct_ptr::Ptr{iox2_waitset_builder_t}, handle_ptr::Ptr{iox2_waitset_builder_h})::Cvoid
end

"""
    iox2_waitset_builder_drop(handle)

Drops a [[`iox2_waitset_builder_h`](@ref)] and calls all corresponding cleanup functions.

# Safety

* `handle` must be acquired with [`[`iox2_waitset_builder_new`](@ref)()`]

### Prototype
```c
void iox2_waitset_builder_drop(iox2_waitset_builder_h handle);
```
"""
function iox2_waitset_builder_drop(handle)
    @ccall libiceoryx2_ffi_c.iox2_waitset_builder_drop(handle::iox2_waitset_builder_h)::Cvoid
end

"""
    iox2_waitset_builder_create(handle, service_type, struct_ptr, handle_ptr)

Creates a new [[`iox2_waitset_t`](@ref)].

# Returns

[[`IOX2_OK`](@ref)] on success otherwise [[`iox2_waitset_create_error_e`](@ref)](crate::[`iox2_waitset_create_error_e`](@ref)).

# Safety

* `handle` must be acquired with [`[`iox2_waitset_builder_new`](@ref)()`] and valid * `handle` is invalidated after a successful operation and cannot used again with this function. * `struct_ptr` must be either a valid pointer to uninitialized memory or `null` * `handle_ptr` must point to a valid uninitialized memory location

### Prototype
```c
int iox2_waitset_builder_create(iox2_waitset_builder_h handle, enum iox2_service_type_e service_type, struct iox2_waitset_t *struct_ptr, iox2_waitset_h *handle_ptr);
```
"""
function iox2_waitset_builder_create(handle, service_type, struct_ptr, handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_waitset_builder_create(handle::iox2_waitset_builder_h, service_type::iox2_service_type_e, struct_ptr::Ptr{iox2_waitset_t}, handle_ptr::Ptr{iox2_waitset_h})::Cint
end

"""
    iox2_waitset_builder_set_signal_handling_mode(waitset_builder_handle, signal_handling_mode)

Sets the [[`iox2_signal_handling_mode_e`](@ref)] for the [[`iox2_waitset_h`](@ref)].

# Arguments

* `waitset_builder_handle` - Must be a valid [[`iox2_waitset_builder_h_ref`](@ref)] obtained by [[`iox2_waitset_builder_new`](@ref)].

# Safety

* `waitset_builder_handle` must be a valid handle

### Prototype
```c
void iox2_waitset_builder_set_signal_handling_mode(iox2_waitset_builder_h_ref waitset_builder_handle, enum iox2_signal_handling_mode_e signal_handling_mode);
```
"""
function iox2_waitset_builder_set_signal_handling_mode(waitset_builder_handle, signal_handling_mode)
    @ccall libiceoryx2_ffi_c.iox2_waitset_builder_set_signal_handling_mode(waitset_builder_handle::iox2_waitset_builder_h_ref, signal_handling_mode::iox2_signal_handling_mode_e)::Cvoid
end

"""
    iox2_waitset_guard_drop(handle)

Drops a [[`iox2_waitset_guard_h`](@ref)] that was successfully acquired with * [`[`iox2_waitset_attach_interval`](@ref)()`](crate::[`iox2_waitset_attach_interval`](@ref)()) * [`[`iox2_waitset_attach_deadline`](@ref)()`](crate::[`iox2_waitset_attach_deadline`](@ref)()) * [`[`iox2_waitset_attach_notification`](@ref)()`](crate::[`iox2_waitset_attach_notification`](@ref)())

# Safety

* `handle` must be valid and non null

### Prototype
```c
void iox2_waitset_guard_drop(iox2_waitset_guard_h handle);
```
"""
function iox2_waitset_guard_drop(handle)
    @ccall libiceoryx2_ffi_c.iox2_waitset_guard_drop(handle::iox2_waitset_guard_h)::Cvoid
end

"""
    iox2_entry_handle_mut_error_string(error)

Returns a string literal describing the provided [[`iox2_entry_handle_mut_error_e`](@ref)].

# Arguments

* `error` - The error value for which a description should be returned

# Returns

A pointer to a null-terminated string containing the error message. The string is stored in the .rodata section of the binary.

# Safety

The returned pointer must not be modified or freed and is valid as long as the program runs.

### Prototype
```c
const char *iox2_entry_handle_mut_error_string(enum iox2_entry_handle_mut_error_e error);
```
"""
function iox2_entry_handle_mut_error_string(error)
    @ccall libiceoryx2_ffi_c.iox2_entry_handle_mut_error_string(error::iox2_entry_handle_mut_error_e)::Cstring
end

"""
    iox2_writer_id(writer_handle, id_struct_ptr, id_handle_ptr)

Returns the unique port id of the writer.

# Arguments

* `writer_handle` obtained by [[`iox2_port_factory_writer_builder_create`](@ref)](crate::[`iox2_port_factory_writer_builder_create`](@ref)) * `id_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_unique_writer_id_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `id_handle_ptr` valid pointer to a [[`iox2_unique_writer_id_h`](@ref)].

# Safety

* `writer_handle` is valid, non-null and was obtained via [[`iox2_port_factory_writer_builder_create`](@ref)](crate::[`iox2_port_factory_writer_builder_create`](@ref)) * `id` is valid and non-null

### Prototype
```c
void iox2_writer_id(iox2_writer_h_ref writer_handle, struct iox2_unique_writer_id_t *id_struct_ptr, iox2_unique_writer_id_h *id_handle_ptr);
```
"""
function iox2_writer_id(writer_handle, id_struct_ptr, id_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_writer_id(writer_handle::iox2_writer_h_ref, id_struct_ptr::Ptr{iox2_unique_writer_id_t}, id_handle_ptr::Ptr{iox2_unique_writer_id_h})::Cvoid
end

"""
    iox2_writer_entry(writer_handle, entry_handle_mut_struct_ptr, entry_handle_mut_handle_ptr, key, value_type_name_str, value_type_name_len, value_size, value_alignment)

Acquires an entry handle mut for direct write access to the stored value.

# Arguments

* `writer_handle` obtained by [[`iox2_port_factory_writer_builder_create`](@ref)](crate::[`iox2_port_factory_writer_builder_create`](@ref)) * `entry_handle_mut_struct_ptr` must be either a NULL pointer or a pointer to a valid [[`iox2_entry_handle_mut_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `entry_handle_mut_handle_ptr` valid pointer to a [[`iox2_entry_handle_mut_h`](@ref)] * `key` the key of the key-value pair for which the entry handle shall be acquired * `value_type_name_str` the type name of the value type of the key-value-pair for which the entry handle shall be acquired * `value_type_name_len` the length of `value_type_name_str` * `value_size` the size of the value type of the key-value-pair for which the entry handle shall be acquired * `value_alignment` the alignment of the value type of the key-value-pair for which the entry handle shall be acquired

# Safety

* `writer_handle` must be non-null and valid * `entry_handle_mut_handle_ptr` must be non-null and valid

### Prototype
```c
int iox2_writer_entry(iox2_writer_h_ref writer_handle, struct iox2_entry_handle_mut_t *entry_handle_mut_struct_ptr, iox2_entry_handle_mut_h *entry_handle_mut_handle_ptr, const void *key, const char *value_type_name_str, c_size_t value_type_name_len, c_size_t value_size, c_size_t value_alignment);
```
"""
function iox2_writer_entry(writer_handle, entry_handle_mut_struct_ptr, entry_handle_mut_handle_ptr, key, value_type_name_str, value_type_name_len, value_size, value_alignment)
    @ccall libiceoryx2_ffi_c.iox2_writer_entry(writer_handle::iox2_writer_h_ref, entry_handle_mut_struct_ptr::Ptr{iox2_entry_handle_mut_t}, entry_handle_mut_handle_ptr::Ptr{iox2_entry_handle_mut_h}, key::Ptr{Cvoid}, value_type_name_str::Cstring, value_type_name_len::c_size_t, value_size::c_size_t, value_alignment::c_size_t)::Cint
end

"""
    iox2_writer_drop(writer_handle)

This function needs to be called to destroy the writer!

# Arguments

* `writer_handle` - A valid [[`iox2_writer_h`](@ref)]

# Safety

* The `writer_handle` is invalid after the return of this function and leads to undefined behavior if used in another function call! * The corresponding [[`iox2_writer_t`](@ref)] can be re-used with a call to [[`iox2_port_factory_writer_builder_create`](@ref)](crate::[`iox2_port_factory_writer_builder_create`](@ref))!

### Prototype
```c
void iox2_writer_drop(iox2_writer_h writer_handle);
```
"""
function iox2_writer_drop(writer_handle)
    @ccall libiceoryx2_ffi_c.iox2_writer_drop(writer_handle::iox2_writer_h)::Cvoid
end

"""
    iox2_writer_details_writer_id(handle, id_struct_ptr, id_handle_ptr)

Returns the unique port id of the writer.

# Safety

* `handle` valid pointer to the writer details * `id_struct_ptr` - Must be either a NULL pointer or a pointer to a valid [[`iox2_unique_writer_id_t`](@ref)]. If it is a NULL pointer, the storage will be allocated on the heap. * `id_handle_ptr` valid pointer to a [[`iox2_unique_writer_id_h`](@ref)].

### Prototype
```c
void iox2_writer_details_writer_id(iox2_writer_details_ptr handle, struct iox2_unique_writer_id_t *id_struct_ptr, iox2_unique_writer_id_h *id_handle_ptr);
```
"""
function iox2_writer_details_writer_id(handle, id_struct_ptr, id_handle_ptr)
    @ccall libiceoryx2_ffi_c.iox2_writer_details_writer_id(handle::iox2_writer_details_ptr, id_struct_ptr::Ptr{iox2_unique_writer_id_t}, id_handle_ptr::Ptr{iox2_unique_writer_id_h})::Cvoid
end

"""
    iox2_writer_details_node_id(handle)

Returns the [[`iox2_node_id_ptr`](@ref)](crate::[`iox2_node_id_ptr`](@ref)), an immutable pointer to the node id.

# Safety

* `handle` valid pointer to the writer details

### Prototype
```c
iox2_node_id_ptr iox2_writer_details_node_id(iox2_writer_details_ptr handle);
```
"""
function iox2_writer_details_node_id(handle)
    @ccall libiceoryx2_ffi_c.iox2_writer_details_node_id(handle::iox2_writer_details_ptr)::iox2_node_id_ptr
end

const IOX2_OK = 0

const IOX2_ATTRIBUTE_KEY_LENGTH = 64

const IOX2_ATTRIBUTE_VALUE_LENGTH = 256

const IOX2_MAX_ATTRIBUTES_PER_SERVICE = 8

const IOX2_NODE_NAME_LENGTH = 128

const IOX2_SERVICE_NAME_LENGTH = 255

const IOX2_SERVICE_ID_LENGTH = 64

const IOX2_TYPE_NAME_LENGTH = 256

const IOX2_MAX_BLACKBOARD_KEY_SIZE = 64

const IOX2_MAX_BLACKBOARD_KEY_ALIGNMENT = 8

const IOX2_IS_IPC_LISTENER_FD_BASED = true

const IOX2_IS_LOCAL_LISTENER_FD_BASED = true

# exports
const PREFIXES = ["iox2_", "IOX2_"]
for name in names(@__MODULE__; all=true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

end # module
