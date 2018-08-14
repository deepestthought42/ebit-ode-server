# just trying an example


push!(LOAD_PATH, "/home/renee/phd/src/charge-distribution.project/ebit-ode-server/")
include("EbitODE.jl")

using DifferentialEquations
using ProtoBuf
using SparseArrays
using ParameterizedFunctions


function getRatesList(filename)
    f = read(filename)
    list = readproto(PipeBuffer(f), InteractionRates.RateList())
    return list
end


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
        tspan = (problem.time_span.start, problem.time_span._end)
        return ODEProblem(f, problem.initial_values, tspan) 
    else
        throw(ErrorException("Unknown Problem type"))
    end
end

EbitODE_RetCodes = Dict(
    :Default => 0,
    :Success => 1,
    :MaxIters => 2,
    :DtLessThanMin => 3,
    :Unstable => 4,
    :InitialFailure => 5,
    :ConvergenceFailure => 6,
    :Failure => 7
)


function packODEResult(solution, problem, start, stop)
    values = map((t,vals) -> EbitODE.ValuesAtTime(time=t, values=vals), solution.t, solution.u)
    return EbitODE.Result(problem=problem, start_time=start, stop_time=stop, 
                          return_code=get(EbitODE_RetCodes, solution.retcode, 0),
                          times=solution.t, values=values)
end


function solveODE(problem)
    start = time()
    sol = solve(createDiffEqProb(problem), saveat=problem.saveat)
    stop = time()
    return packODEResult(sol, problem, start, stop)
end




res = solveODE(readproto(PipeBuffer(read("/home/renee/tmp/test2.serialize")), EbitODE.Problem()))

# plot(sol.t, transpose(convert(Array{Float64,2}, VectorOfArray(sol.u)))


