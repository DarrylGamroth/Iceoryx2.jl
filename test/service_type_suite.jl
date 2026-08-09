using Test
using Iceoryx2

include("testutils.jl")

# Mirror the upstream C++ typed-test and Python pytest matrices: every test in
# this suite must use TEST_SERVICE_TYPE instead of selecting a backend directly.
@testset "ServiceType.$(TEST_SERVICE_TYPE)" begin
    include("type_variants.jl")
    include("node_builder.jl")
    include("node.jl")
    include("node_state.jl")
    include("service_builder.jl")
    include("builder_tuning.jl")
    include("callback_handlers.jl")
    include("pubsub.jl")
    include("progressive_pubsub.jl")
    include("request_response.jl")
    include("service_event.jl")
    include("service_hash.jl")
    include("service_compatibility.jl")
    include("cleanup_state.jl")
    include("static_config.jl")
    include("dynamic_config.jl")
    include("listener_wait.jl")
    include("service_blackboard.jl")
    include("blackboard_entries.jl")
    include("list_nodes.jl")
    include("service_listing.jl")
    include("waitset_interval.jl")
    include("waitset_notification.jl")
    include("waitset_lifecycle.jl")
    include("unique_port_id.jl")
    include("config.jl")
    include("perf_gates.jl")
    include("allocations_hotpath.jl")
end
