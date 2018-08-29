module EbitScratching

using Revise
using EbitSolver
using EbitODEServer
using EbitODEMessages
using ProtoBuf


function test()
    msg = Any
    open("/home/renee/tmp/test_ode.proto") do file
        msg = EbitSolver.solve_ode(ProtoBuf.readproto(file, EbitODEMessages.Message()).ode_problem)
    end

    open("/home/renee/tmp/test_ode_answer.proto", "w+") do file
        ProtoBuf.writeproto(file, msg)
    end
end

end
