module EbitSolver

using EbitODE

export solveODE, packODEResult
    
using DifferentialEquations
using ProtoBuf
using SparseArrays
using ParameterizedFunctions




RetCodes = Dict(
    :Default => 0,
    :Success => 1,
    :MaxIters => 2,
    :DtLessThanMin => 3,
    :Unstable => 4,
    :InitialFailure => 5,
    :ConvergenceFailure => 6,
    :Failure => 7
)



function createMatrix(rateList)
    retVal = zeros(rateList.dimension, rateList.dimension)
    for r in rateList.rates
        retVal[r.destination.i,r.origin.i] += r.RateInHz
        retVal[r.origin.i,r.origin.i] -= r.RateInHz
    end
    return retVal
end


function createDiffEqProb(problem)
    if problem.problem_type == EbitODE.ProblemType.ODEProblem
        A = createMatrix(problem.rate_list)
        f(u,p,t) = A*u
        tspan = (problem.time_span.start, problem.time_span.stop)
        return ODEProblem(f, problem.initial_values, tspan) 
    else
        throw(ErrorException("Unknown Problem type"))
    end
end


function packValues(solution, indices)
    s = solution
    len_t = length(s.t)
    len_i = length(indices)

    ret = [EbitODE.ValuesPerIndex(index=index, values=Array{Float64}(undef, len_t)) for index in indices]

    for t in 1:len_t
        for i in 1:len_i
            ret[i].values[t] = s.u[t][i]
        end
    end
    
    return ret;
end



function packODEResult(solution, problem, start, stop)
    values = packValues(solution, problem.indices)
    return EbitODE.Result(problem=problem, start_time=start, stop_time=stop, 
                          return_code=get(RetCodes, solution.retcode, 0),
                          times=solution.t, values=values)
end


function solveODE(problem)
    start = time()
    sol = solve(createDiffEqProb(problem), saveat=problem.saveat)
    stop = time()
    return packODEResult(sol, problem, start, stop)
end



function writeResult(res, filename)
    iob = PipeBuffer()
    writeproto(iob, res)
    write(filename, iob)
end


end
