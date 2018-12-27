# push!(LOAD_PATH, "/home/renee/phd/src/ebit-evolution.project/ebit-ode-server/")
include("/home/renee/phd/src/ebit-evolution.project/ebit-ode-server/EbitODEMessages.jl")
include("/home/renee/phd/src/ebit-evolution.project/ebit-ode-server/EbitCloudSpatialExtend.jl")
include("/home/renee/phd/src/ebit-evolution.project/ebit-ode-server/EbitSolver.jl")
include("/home/renee/phd/src/ebit-evolution.project/ebit-ode-server/EbitODEServer.jl")


module EbitScratching

# using Revise
using Revise
using Main.EbitSolver
using Main.EbitODEServer
using Main.EbitODEMessages
using ProtoBuf


function test()
    msg = Any
    open("testdata/simple_test.kairos") do file
        msg = EbitSolver.solve_ode(ProtoBuf.readproto(file, EbitODEMessages.Message()).ode_problem, ::Any -> false)
    end

    open("testdata/simpe_test_result.kairos", "w+") do file
        ProtoBuf.writeproto(file, msg)
    end
end

end
