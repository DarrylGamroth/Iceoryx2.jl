# Iceoryx2 C++ Wrapper Coverage Map (C ABI -> Julia)

Source:
- C++ wrappers: `../iceoryx2/iceoryx2-cxx/src`
- C ABI bindings: `src/Iceoryx2FFI.jl`

Notes:
- Julia mapping lists the primary implementation files.
- Handle types generally live in `src/handles.jl`; raw ABI bindings live in `src/Iceoryx2FFI.jl`.
- Some C ABI symbols are present but intentionally not wrapped yet; those are called out explicitly.

## core types
- `attribute.cpp`
  - C: `iox2_attribute_h_ref`, `iox2_attribute_key`, `iox2_attribute_value`
  - Julia: `src/handles.jl` (AttributeRef), `src/attributes.jl` (key/value + view helpers).
- `attribute_set.cpp`
  - C: `iox2_attribute_set_drop`, `iox2_attribute_set_h`, `iox2_attribute_set_index`, `iox2_attribute_set_iter_key_values`, `iox2_attribute_set_key_value`, `iox2_attribute_set_new_clone`, `iox2_attribute_set_number_of_attributes`, `iox2_attribute_set_number_of_key_values`, `iox2_attribute_set_ptr`, `iox2_callback_context`, `iox2_callback_progression_e`, `iox2_cast_attribute_set_ptr`
  - Julia: `src/handles.jl` (AttributeSet/AttributeSetView), `src/attributes.jl` (indexing + key/value access), `src/callbacks.jl` (each_attribute_value/attribute_values + callback progression).
- `attribute_specifier.cpp`
  - C: `iox2_attribute_specifier_attributes`, `iox2_attribute_specifier_define`, `iox2_attribute_specifier_drop`, `iox2_attribute_specifier_new`
  - Julia: `src/handles.jl` (AttributeSpecifier), `src/attributes.jl` (AttributeSpecifier(), define!, attributes).
- `attribute_verifier.cpp`
  - C: `iox2_attribute_verifier_attributes`, `iox2_attribute_verifier_drop`, `iox2_attribute_verifier_key`, `iox2_attribute_verifier_new`, `iox2_attribute_verifier_number_of_keys`, `iox2_attribute_verifier_require`, `iox2_attribute_verifier_require_key`, `iox2_attribute_verifier_verify_requirements`
  - Julia: `src/handles.jl` (AttributeVerifier), `src/attributes.jl` (AttributeVerifier(), require!/require_key!, verify_requirements, attributes).
- `event_id.cpp`
  - C: `iox2_event_id_t`
  - Julia: `src/messaging.jl` (EventId).
- `header_publish_subscribe.cpp`
  - C: `iox2_publish_subscribe_header_drop`, `iox2_publish_subscribe_header_h`, `iox2_publish_subscribe_header_number_of_elements`, `iox2_publish_subscribe_header_publisher_id`, `iox2_unique_publisher_id_h`
  - Julia: `src/handles.jl` (PublishSubscribeHeader/PublishSubscribeHeaderRef only). Header accessors not wrapped yet.
- `header_request_response.cpp`
  - C: `iox2_request_header_client_id`, `iox2_request_header_drop`, `iox2_request_header_h`, `iox2_response_header_drop`, `iox2_response_header_h`, `iox2_response_header_server_id`, `iox2_unique_client_id_h`, `iox2_unique_server_id_h`
  - Julia: `src/handles.jl` (RequestHeader/ResponseHeader + refs only). Header accessors not wrapped yet.
- `messaging_pattern.cpp`
  - C: (no iox2_* symbols found)
  - Julia: `src/config.jl` (_messaging_pattern helpers used by service_does_exist/service_details).
- `node.cpp`
  - C: `iox2_cast_node_name_ptr`, `iox2_node_builder_create`, `iox2_node_builder_new`, `iox2_node_builder_set_config`, `iox2_node_builder_set_name`, `iox2_node_builder_set_signal_handling_mode`, `iox2_node_config`, `iox2_node_drop`, `iox2_node_h`, `iox2_node_id`, `iox2_node_id_clone_from_ptr`, `iox2_node_id_h`, `iox2_node_list`, `iox2_node_name`, `iox2_node_signal_handling_mode`, `iox2_node_wait`, `iox2_service_type_e`, `iox2_signal_handling_mode_e`
  - Julia: `src/builders.jl` (NodeBuilder), `src/nodes.jl` (Node accessors + id), `src/callbacks.jl` (list_nodes), `src/strings.jl` (NodeName). `iox2_node_wait` is not wrapped yet.
- `node_id.cpp`
  - C: `iox2_node_id_clone_from_handle`, `iox2_node_id_creation_time`, `iox2_node_id_drop`, `iox2_node_id_h`, `iox2_node_id_pid`, `iox2_node_id_value_high`, `iox2_node_id_value_low`
  - Julia: `src/handles.jl` (NodeId/NodeIdView), `src/nodes.jl` (value_high/value_low/pid/creation_time/to_owned).
- `node_name.cpp`
  - C: `iox2_cast_node_name_ptr`, `iox2_node_name_as_chars`, `iox2_node_name_drop`, `iox2_node_name_h`, `iox2_node_name_new`, `iox2_node_name_ptr`
  - Julia: `src/handles.jl` (NodeName/NodeNameView), `src/strings.jl` (string conversions + constructors).
- `service.cpp`
  - C: `iox2_callback_progression_e`, `iox2_messaging_pattern_e`, `iox2_service_details`, `iox2_service_does_exist`, `iox2_service_list`, `iox2_service_type_e`, `iox2_static_config_t`
  - Julia: `src/config.jl` (service_does_exist/service_details/service_list + StaticConfig), `src/callbacks.jl` (service_list callback), `src/builders.jl`/`src/config.jl` (service_type/messaging_pattern helpers).
- `service_id.cpp`
  - C: (no iox2_* symbols found)
  - Julia: N/A.
- `service_name.cpp`
  - C: `iox2_cast_service_name_ptr`, `iox2_service_name_as_chars`, `iox2_service_name_drop`, `iox2_service_name_h`, `iox2_service_name_new`, `iox2_service_name_ptr`
  - Julia: `src/handles.jl` (ServiceName/ServiceNameView), `src/strings.jl` (string conversions + constructors).
- `unique_port_id.cpp`
  - C: `iox2_unique_client_id_drop`, `iox2_unique_client_id_eq`, `iox2_unique_client_id_h`, `iox2_unique_client_id_less`, `iox2_unique_client_id_value`, `iox2_unique_listener_id_drop`, `iox2_unique_listener_id_eq`, `iox2_unique_listener_id_h`, `iox2_unique_listener_id_less`, `iox2_unique_listener_id_value`, `iox2_unique_notifier_id_drop`, `iox2_unique_notifier_id_eq`, `iox2_unique_notifier_id_h`, `iox2_unique_notifier_id_less`, `iox2_unique_notifier_id_value`, `iox2_unique_publisher_id_drop`, `iox2_unique_publisher_id_eq`, `iox2_unique_publisher_id_h`, `iox2_unique_publisher_id_less`, `iox2_unique_publisher_id_value`, `iox2_unique_reader_id_drop`, `iox2_unique_reader_id_eq`, `iox2_unique_reader_id_h`, `iox2_unique_reader_id_less`, `iox2_unique_reader_id_value`, `iox2_unique_server_id_drop`, `iox2_unique_server_id_eq`, `iox2_unique_server_id_h`, `iox2_unique_server_id_less`, `iox2_unique_server_id_value`, `iox2_unique_subscriber_id_drop`, `iox2_unique_subscriber_id_eq`, `iox2_unique_subscriber_id_h`, `iox2_unique_subscriber_id_less`, `iox2_unique_subscriber_id_value`, `iox2_unique_writer_id_drop`, `iox2_unique_writer_id_eq`, `iox2_unique_writer_id_h`, `iox2_unique_writer_id_less`, `iox2_unique_writer_id_value`
  - Julia: `src/handles.jl` (Unique*Id handles), `src/ids.jl` (id() accessors, bytes(), ==, isless).

## builders
- `port_factory_event.cpp`
  - C: `iox2_port_factory_event_attributes`, `iox2_port_factory_event_drop`, `iox2_port_factory_event_h`, `iox2_port_factory_event_listener_builder`, `iox2_port_factory_event_nodes`, `iox2_port_factory_event_notifier_builder`, `iox2_port_factory_event_service_id`, `iox2_port_factory_event_service_name`, `iox2_port_factory_event_static_config`, `iox2_static_config_event_t`
  - Julia: `src/messaging.jl` (PortFactoryEvent + listener/notifier builders), `src/handles.jl` (handle refs). Missing: attributes/nodes/service_name/service_id/static_config accessors.
- `port_factory_notifier.cpp`
  - C: `iox2_notifier_h`, `iox2_port_factory_notifier_builder_create`, `iox2_port_factory_notifier_builder_h`, `iox2_port_factory_notifier_builder_set_default_event_id`
  - Julia: `src/messaging.jl` (NotifierBuilder + default_event_id!), `src/handles.jl` (Notifier handle).
- `service_builder_event.cpp`
  - C: `iox2_port_factory_event_h`, `iox2_service_builder_event`, `iox2_service_builder_event_create`, `iox2_service_builder_event_create_with_attributes`, `iox2_service_builder_event_disable_deadline`, `iox2_service_builder_event_disable_notifier_created_event`, `iox2_service_builder_event_disable_notifier_dead_event`, `iox2_service_builder_event_disable_notifier_dropped_event`, `iox2_service_builder_event_open`, `iox2_service_builder_event_open_or_create`, `iox2_service_builder_event_open_or_create_with_attributes`, `iox2_service_builder_event_open_with_attributes`, `iox2_service_builder_event_set_deadline`, `iox2_service_builder_event_set_event_id_max_value`, `iox2_service_builder_event_set_max_listeners`, `iox2_service_builder_event_set_max_nodes`, `iox2_service_builder_event_set_max_notifiers`, `iox2_service_builder_event_set_notifier_created_event`, `iox2_service_builder_event_set_notifier_dead_event`, `iox2_service_builder_event_set_notifier_dropped_event`, `iox2_service_builder_h`
  - Julia: `src/builders.jl` (EventServiceBuilder), `src/messaging.jl` (settings + open/open_or_create/create). Attribute-based open/create and some enable/disable toggles are not wrapped yet.

## messaging patterns
- `notifier.cpp`
  - C: `iox2_notifier_deadline`, `iox2_notifier_drop`, `iox2_notifier_h`, `iox2_notifier_id`, `iox2_notifier_notify`, `iox2_notifier_notify_with_custom_event_id`, `iox2_unique_notifier_id_h`
  - Julia: `src/messaging.jl` (Notifier + notify!/notify!(id)), `src/ids.jl` (id()). Notifier deadline accessor not wrapped yet.

## waitset
- `waitset.cpp`
  - C: `iox2_callback_progression_e`, `iox2_listener_get_file_descriptor`, `iox2_service_type_e`, `iox2_signal_handling_mode_e`, `iox2_waitset_attach_deadline`, `iox2_waitset_attach_interval`, `iox2_waitset_attach_notification`, `iox2_waitset_attachment_id_debug`, `iox2_waitset_attachment_id_debug_len`, `iox2_waitset_attachment_id_drop`, `iox2_waitset_attachment_id_equal`, `iox2_waitset_attachment_id_from_guard`, `iox2_waitset_attachment_id_h`, `iox2_waitset_attachment_id_has_event_from`, `iox2_waitset_attachment_id_has_missed_deadline`, `iox2_waitset_attachment_id_less`, `iox2_waitset_builder_create`, `iox2_waitset_builder_h`, `iox2_waitset_builder_new`, `iox2_waitset_builder_set_signal_handling_mode`, `iox2_waitset_capacity`, `iox2_waitset_drop`, `iox2_waitset_guard_drop`, `iox2_waitset_guard_h`, `iox2_waitset_h`, `iox2_waitset_is_empty`, `iox2_waitset_len`, `iox2_waitset_run_result_e`, `iox2_waitset_run_result_e_STOP_REQUEST`, `iox2_waitset_signal_handling_mode`, `iox2_waitset_wait_and_process`, `iox2_waitset_wait_and_process_once`, `iox2_waitset_wait_and_process_once_with_timeout`
  - Julia: `src/waitset.jl` (Waitset + builder + attach_* + wait_and_process* + attachment IDs/guards), `src/handles.jl` (waitset handle types).

## config
- `config.cpp`
  - C: `iox2_cast_config_ptr`, `iox2_config_clone`, `iox2_config_default`, `iox2_config_defaults_blackboard_max_nodes`, `iox2_config_defaults_blackboard_max_readers`, `iox2_config_defaults_blackboard_set_max_nodes`, `iox2_config_defaults_blackboard_set_max_readers`, `iox2_config_defaults_event_deadline`, `iox2_config_defaults_event_event_id_max_value`, `iox2_config_defaults_event_max_listeners`, `iox2_config_defaults_event_max_nodes`, `iox2_config_defaults_event_max_notifiers`, `iox2_config_defaults_event_notifier_created_event`, `iox2_config_defaults_event_notifier_dead_event`, `iox2_config_defaults_event_notifier_dropped_event`, `iox2_config_defaults_event_set_deadline`, `iox2_config_defaults_event_set_event_id_max_value`, `iox2_config_defaults_event_set_max_listeners`, `iox2_config_defaults_event_set_max_nodes`, `iox2_config_defaults_event_set_max_notifiers`, `iox2_config_defaults_event_set_notifier_created_event`, `iox2_config_defaults_event_set_notifier_dead_event`, `iox2_config_defaults_event_set_notifier_dropped_event`, `iox2_config_defaults_publish_subscribe_enable_safe_overflow`, `iox2_config_defaults_publish_subscribe_max_nodes`, `iox2_config_defaults_publish_subscribe_max_publishers`, `iox2_config_defaults_publish_subscribe_max_subscribers`, `iox2_config_defaults_publish_subscribe_publisher_history_size`, `iox2_config_defaults_publish_subscribe_publisher_max_loaned_samples`, `iox2_config_defaults_publish_subscribe_set_enable_safe_overflow`, `iox2_config_defaults_publish_subscribe_set_max_nodes`, `iox2_config_defaults_publish_subscribe_set_max_publishers`, `iox2_config_defaults_publish_subscribe_set_max_subscribers`, `iox2_config_defaults_publish_subscribe_set_publisher_history_size`, `iox2_config_defaults_publish_subscribe_set_publisher_max_loaned_samples`, `iox2_config_defaults_publish_subscribe_set_subscriber_expired_connection_buffer`, `iox2_config_defaults_publish_subscribe_set_subscriber_max_borrowed_samples`, `iox2_config_defaults_publish_subscribe_set_subscriber_max_buffer_size`, `iox2_config_defaults_publish_subscribe_set_unable_to_deliver_strategy`, `iox2_config_defaults_publish_subscribe_subscriber_expired_connection_buffer`, `iox2_config_defaults_publish_subscribe_subscriber_max_borrowed_samples`, `iox2_config_defaults_publish_subscribe_subscriber_max_buffer_size`, `iox2_config_defaults_publish_subscribe_unable_to_deliver_strategy`, `iox2_config_defaults_request_response_client_expired_connection_buffer`, `iox2_config_defaults_request_response_client_unable_to_deliver_strategy`, `iox2_config_defaults_request_response_enable_safe_overflow_for_requests`, `iox2_config_defaults_request_response_enable_safe_overflow_for_responses`, `iox2_config_defaults_request_response_has_fire_and_forget_requests`, `iox2_config_defaults_request_response_max_active_requests_per_client`, `iox2_config_defaults_request_response_max_borrowed_responses_per_pending_response`, `iox2_config_defaults_request_response_max_clients`, `iox2_config_defaults_request_response_max_loaned_requests`, `iox2_config_defaults_request_response_max_nodes`, `iox2_config_defaults_request_response_max_response_buffer_size`, `iox2_config_defaults_request_response_max_servers`, `iox2_config_defaults_request_response_server_expired_connection_buffer`, `iox2_config_defaults_request_response_server_max_loaned_responses_per_request`, `iox2_config_defaults_request_response_server_unable_to_deliver_strategy`, `iox2_config_defaults_request_response_set_client_expired_connection_buffer`, `iox2_config_defaults_request_response_set_client_unable_to_deliver_strategy`, `iox2_config_defaults_request_response_set_enable_safe_overflow_for_requests`, `iox2_config_defaults_request_response_set_enable_safe_overflow_for_responses`, `iox2_config_defaults_request_response_set_fire_and_forget_requests`, `iox2_config_defaults_request_response_set_max_active_requests_per_client`, `iox2_config_defaults_request_response_set_max_borrowed_responses_per_pending_response`, `iox2_config_defaults_request_response_set_max_clients`, `iox2_config_defaults_request_response_set_max_loaned_requests`, `iox2_config_defaults_request_response_set_max_nodes`, `iox2_config_defaults_request_response_set_max_response_buffer_size`, `iox2_config_defaults_request_response_set_max_servers`, `iox2_config_defaults_request_response_set_server_expired_connection_buffer`, `iox2_config_defaults_request_response_set_server_max_loaned_responses_per_request`, `iox2_config_defaults_request_response_set_server_unable_to_deliver_strategy`, `iox2_config_drop`, `iox2_config_from_file`, `iox2_config_from_ptr`, `iox2_config_global_config`, `iox2_config_global_node_cleanup_dead_nodes_on_creation`, `iox2_config_global_node_cleanup_dead_nodes_on_destruction`, `iox2_config_global_node_directory`, `iox2_config_global_node_monitor_suffix`, `iox2_config_global_node_service_tag_suffix`, `iox2_config_global_node_set_cleanup_dead_nodes_on_creation`, `iox2_config_global_node_set_cleanup_dead_nodes_on_destruction`, `iox2_config_global_node_set_directory`, `iox2_config_global_node_set_monitor_suffix`, `iox2_config_global_node_set_service_tag_suffix`, `iox2_config_global_node_set_static_config_suffix`, `iox2_config_global_node_static_config_suffix`, `iox2_config_global_prefix`, `iox2_config_global_root_path`, `iox2_config_global_service_connection_suffix`, `iox2_config_global_service_creation_timeout`, `iox2_config_global_service_data_segment_suffix`, `iox2_config_global_service_directory`, `iox2_config_global_service_dynamic_config_storage_suffix`, `iox2_config_global_service_event_connection_suffix`, `iox2_config_global_service_set_connection_suffix`, `iox2_config_global_service_set_creation_timeout`, `iox2_config_global_service_set_data_segment_suffix`, `iox2_config_global_service_set_directory`, `iox2_config_global_service_set_dynamic_config_storage_suffix`, `iox2_config_global_service_set_event_connection_suffix`, `iox2_config_global_service_set_static_config_storage_suffix`, `iox2_config_global_service_static_config_storage_suffix`, `iox2_config_global_set_prefix`, `iox2_config_global_set_root_path`, `iox2_config_h`, `iox2_config_ptr`, `iox2_unable_to_deliver_strategy_e`
  - Julia: `src/config.jl` (Config/ConfigView + default_config/global_config + service_* helpers), `src/handles.jl` (Config handles). Most defaults and global setters are not wrapped yet.
- `dynamic_config_blackboard.cpp`
  - C: `iox2_port_factory_blackboard_dynamic_config_list_readers`, `iox2_port_factory_blackboard_dynamic_config_list_writers`, `iox2_port_factory_blackboard_dynamic_config_number_of_readers`, `iox2_port_factory_blackboard_dynamic_config_number_of_writers`, `iox2_port_factory_blackboard_h`, `iox2_reader_details_ptr`, `iox2_writer_details_ptr`
  - Julia: `src/config.jl` (list_readers/list_writers/number_of_*), `src/handles.jl` (ReaderDetailsView/WriterDetailsView). Per-detail accessors not wrapped yet.
- `dynamic_config_event.cpp`
  - C: `iox2_listener_details_ptr`, `iox2_notifier_details_ptr`, `iox2_port_factory_event_dynamic_config_list_listeners`, `iox2_port_factory_event_dynamic_config_list_notifiers`, `iox2_port_factory_event_dynamic_config_number_of_listeners`, `iox2_port_factory_event_dynamic_config_number_of_notifiers`, `iox2_port_factory_event_h`
  - Julia: `src/config.jl` (list_listeners/list_notifiers/number_of_*), `src/handles.jl` (ListenerDetailsView/NotifierDetailsView). Per-detail accessors not wrapped yet.
- `dynamic_config_publish_subscribe.cpp`
  - C: `iox2_port_factory_pub_sub_dynamic_config_list_publishers`, `iox2_port_factory_pub_sub_dynamic_config_list_subscribers`, `iox2_port_factory_pub_sub_dynamic_config_number_of_publishers`, `iox2_port_factory_pub_sub_dynamic_config_number_of_subscribers`, `iox2_port_factory_pub_sub_h`, `iox2_publisher_details_ptr`, `iox2_subscriber_details_ptr`
  - Julia: `src/config.jl` (list_publishers/list_subscribers/number_of_*), `src/handles.jl` (PublisherDetailsView/SubscriberDetailsView). Per-detail accessors not wrapped yet.
- `dynamic_config_request_response.cpp`
  - C: `iox2_client_details_ptr`, `iox2_port_factory_request_response_dynamic_config_list_clients`, `iox2_port_factory_request_response_dynamic_config_list_servers`, `iox2_port_factory_request_response_dynamic_config_number_of_clients`, `iox2_port_factory_request_response_dynamic_config_number_of_servers`, `iox2_port_factory_request_response_h`, `iox2_server_details_ptr`
  - Julia: `src/config.jl` (list_clients/list_servers/number_of_*), `src/handles.jl` (ClientDetailsView/ServerDetailsView). Per-detail accessors not wrapped yet.
- `static_config.cpp`
  - C: `iox2_attribute_set_drop`, `iox2_cast_attribute_set_ptr`, `iox2_static_config_t`
  - Julia: `src/config.jl` (StaticConfig + attributes).
- `static_config_blackboard.cpp`
  - C: `iox2_static_config_blackboard_t`
  - Julia: `src/config.jl` (StaticConfigBlackboard).
- `static_config_event.cpp`
  - C: `iox2_static_config_event_t`
  - Julia: `src/config.jl` (StaticConfigEvent).
- `static_config_publish_subscribe.cpp`
  - C: `iox2_static_config_publish_subscribe_t`
  - Julia: `src/config.jl` (StaticConfigPublishSubscribe).
- `static_config_request_response.cpp`
  - C: `iox2_static_config_request_response_t`
  - Julia: `src/config.jl` (StaticConfigRequestResponse).

## IDs/details
- `client_details.cpp`
  - C: `iox2_client_details_client_id`, `iox2_client_details_max_slice_len`, `iox2_client_details_node_id`, `iox2_client_details_number_of_requests`, `iox2_client_details_ptr`, `iox2_client_details_response_buffer_size`, `iox2_node_id_clone_from_ptr`, `iox2_node_id_h`, `iox2_unique_client_id_h`
  - Julia: `src/handles.jl` (ClientDetailsView), `src/config.jl` (list_clients). Per-field accessors not wrapped yet.
- `listener_details.cpp`
  - C: `iox2_listener_details_listener_id`, `iox2_listener_details_node_id`, `iox2_listener_details_ptr`, `iox2_node_id_clone_from_ptr`, `iox2_node_id_h`, `iox2_unique_listener_id_h`
  - Julia: `src/handles.jl` (ListenerDetailsView), `src/config.jl` (list_listeners). Per-field accessors not wrapped yet.
- `message_type_details.cpp`
  - C: `iox2_message_type_details_t`, `iox2_type_detail_t`
  - Julia: `src/messaging.jl` (internal TypeDetails used for builder payload/header type details). No direct MessageTypeDetails wrapper yet.
- `node_details.cpp`
  - C: (no iox2_* symbols found)
  - Julia: N/A.
- `notifier_details.cpp`
  - C: `iox2_node_id_clone_from_ptr`, `iox2_node_id_h`, `iox2_notifier_details_node_id`, `iox2_notifier_details_notifier_id`, `iox2_notifier_details_ptr`, `iox2_unique_notifier_id_h`
  - Julia: `src/handles.jl` (NotifierDetailsView), `src/config.jl` (list_notifiers). Per-field accessors not wrapped yet.
- `publisher_details.cpp`
  - C: `iox2_node_id_clone_from_ptr`, `iox2_node_id_h`, `iox2_publisher_details_max_slice_len`, `iox2_publisher_details_node_id`, `iox2_publisher_details_number_of_samples`, `iox2_publisher_details_ptr`, `iox2_publisher_details_publisher_id`, `iox2_unique_publisher_id_h`
  - Julia: `src/handles.jl` (PublisherDetailsView), `src/config.jl` (list_publishers). Per-field accessors not wrapped yet.
- `reader_details.cpp`
  - C: `iox2_node_id_clone_from_ptr`, `iox2_node_id_h`, `iox2_reader_details_node_id`, `iox2_reader_details_ptr`, `iox2_reader_details_reader_id`, `iox2_unique_reader_id_h`
  - Julia: `src/handles.jl` (ReaderDetailsView), `src/config.jl` (list_readers). Per-field accessors not wrapped yet.
- `server_details.cpp`
  - C: `iox2_node_id_clone_from_ptr`, `iox2_node_id_h`, `iox2_server_details_max_slice_len`, `iox2_server_details_node_id`, `iox2_server_details_number_of_responses`, `iox2_server_details_ptr`, `iox2_server_details_request_buffer_size`, `iox2_server_details_server_id`, `iox2_unique_server_id_h`
  - Julia: `src/handles.jl` (ServerDetailsView), `src/config.jl` (list_servers). Per-field accessors not wrapped yet.
- `subscriber_details.cpp`
  - C: `iox2_node_id_clone_from_ptr`, `iox2_node_id_h`, `iox2_subscriber_details_buffer_size`, `iox2_subscriber_details_node_id`, `iox2_subscriber_details_ptr`, `iox2_subscriber_details_subscriber_id`, `iox2_unique_subscriber_id_h`
  - Julia: `src/handles.jl` (SubscriberDetailsView), `src/config.jl` (list_subscribers). Per-field accessors not wrapped yet.
- `writer_details.cpp`
  - C: `iox2_node_id_clone_from_ptr`, `iox2_node_id_h`, `iox2_unique_writer_id_h`, `iox2_writer_details_node_id`, `iox2_writer_details_ptr`, `iox2_writer_details_writer_id`
  - Julia: `src/handles.jl` (WriterDetailsView), `src/config.jl` (list_writers). Per-field accessors not wrapped yet.

## logging
- `log.cpp`
  - C: `iox2_get_log_level`, `iox2_log`, `iox2_log_level_e`, `iox2_set_log_level`, `iox2_set_log_level_from_env_or`, `iox2_set_log_level_from_env_or_default`, `iox2_set_logger`
  - Julia: `src/logging.jl`.

## utilities
- `file_descriptor.cpp`
  - C: `iox2_cast_file_descriptor_ptr`, `iox2_file_descriptor_drop`, `iox2_file_descriptor_h`, `iox2_file_descriptor_native_handle`, `iox2_file_descriptor_new`, `iox2_file_descriptor_ptr`
  - Julia: `src/handles.jl` (FileDescriptor/FileDescriptorView), `src/waitset.jl` (listener file_descriptor + waitset attach). `file_descriptor_new` and native_handle accessors are not wrapped yet.
- `node_state.cpp`
  - C: `iox2_dead_node_remove_stale_resources`, `iox2_node_state_e`, `iox2_node_state_e_INACCESSIBLE`, `iox2_node_state_e_UNDEFINED`, `iox2_service_type_e`
  - Julia: `src/callbacks.jl` (node_state enum used in list_nodes). `dead_node_remove_stale_resources` not wrapped yet.
