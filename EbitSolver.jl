module EbitSolver

using EbitODE
using MicroLogging

export solve_ode, pack_ode_result
    
using DifferentialEquations
using ProtoBuf
# using SparseArrays
using ParameterizedFunctions




_ret_codes_ = Dict(
    :Default => 0,
    :Success => 1,
    :MaxIters => 2,
    :DtLessThanMin => 3,
    :Unstable => 4,
    :InitialFailure => 5,
    :ConvergenceFailure => 6,
    :Failure => 7
)



function create_matrix(rate_list)
    ret_val = zeros(rate_list.dimension, rate_list.dimension)
    for r in rate_list.rates
        ret_val[r.destination.i,r.origin.i] += r.RateInHz
        ret_val[r.origin.i,r.origin.i] -= r.RateInHz
    end
    return ret_val
end

function create_initial_value_vector(problem::EbitODE.Problem)
    initial_values = zeros(problem.rate_list.dimension)
    for init in problem.initial_population
        initial_values[init.index.i] = init.value
    end
    return initial_values
end

function create_diffeq_prob(problem::EbitODE.Problem)
    if problem.problem_type == EbitODE.ProblemType.ODEProblem
        A = create_matrix(problem.rate_list)
        f(u,p,t) = A*u
        tspan = (problem.time_span.start, problem.time_span.stop)
        initial_values = create_initial_value_vector(problem)
        @info "Created initial values from list" initial_values
        return ODEProblem(f, initial_values, tspan) 
    else
        throw(ErrorException("Unknown Problem type"))
    end
end


function pack_values(solution, indices)
    s = solution
    len_t = length(s.t)
    len_i = length(indices)

    ret = [EbitODE.ValuesPerIndex(index=index, values=Array{Float64}(len_t)) for index in indices]

    for t in 1:len_t
        for i in 1:len_i
            ret[i].values[t] = s.u[t][i]
        end
    end
    
    return ret;
end



function pack_ode_result(solution, problem, start, stop)
    vals = pack_values(solution, problem.indices)
    return EbitODE.Result(problem=problem, start_time=start, stop_time=stop, 
                          return_code=get(_ret_codes_, solution.retcode, 0),
                          times=solution.t, values=vals)
end

function pack_ode_msg(res)
    return EbitODE.Message(MsgType=EbitODE.MessageType.ODEResult, ODEResult = res)
end

@noinline function solve_ode(problem)
    start_ = time()
    sol = solve(create_diffeq_prob(problem), saveat=problem.saveat)
    stop = time()
    return pack_ode_msg(pack_ode_result(sol, problem, start_, stop))
end


end
