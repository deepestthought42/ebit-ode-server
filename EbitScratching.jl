push!(LOAD_PATH, "/home/renee/phd/src/ebit-evolution.project/ebit-ode-server/")
include("/home/renee/phd/src/ebit-evolution.project/ebit-ode-server/EbitODEMessages.jl")
include("/home/renee/phd/src/ebit-evolution.project/ebit-ode-server/EbitSolver.jl")
include("/home/renee/phd/src/ebit-evolution.project/ebit-ode-server/EbitODEServer.jl")


module EbitScratching

# using Revise
using Main.EbitSolver
using Main.EbitODEServer
using Main.EbitODEMessages
using ProtoBuf


function test()
    msg = Any
    open("/home/renee/tmp/leigh_talk.proto") do file
        msg = EbitSolver.solve_ode(ProtoBuf.readproto(file, EbitODEMessages.Message()).ode_problem,
                                   t -> @info t)
    end

    open("/home/renee/tmp/test_leigh_talk_answer.proto", "w+") do file
        ProtoBuf.writeproto(file, msg)
    end
end

end
