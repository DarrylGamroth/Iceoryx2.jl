module CommonTests

using Iceoryx2

include("common_suite.jl")

end

module IPCTransportTests

using Iceoryx2

const TEST_SERVICE_TYPE = Iceoryx2.ServiceType.IPC

include("service_type_suite.jl")

end

module LocalTransportTests

using Iceoryx2

const TEST_SERVICE_TYPE = Iceoryx2.ServiceType.LOCAL

include("service_type_suite.jl")

end
