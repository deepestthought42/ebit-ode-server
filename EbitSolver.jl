module EbitSolver

using EbitODEMessages
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


function create_ebit_parameters(ret_val, dep::EbitODEMessages.DiffEqParameters)
    dim = dep.no_dimensions
    ret_val.dN = zeros(dim, dim)
    ret_val.qVₑ = dep.qVe
    ret_val.qVₜ = dep.qVt
    ret_val.A = dep.mass_number
    ret_val.ϕ = dep.spitzer_divided_by_overlap
    ret_val.rₑ²_in_m = dep.electron_radius_in_m_squared
    ret_val.Ł = dep.one_over_pi_times_L

    ret_val.χ = reshape(dep.inverted_collision_constant, (dim,dim))
    ret_val.dN = zeros(dim, dim)
    ret_val.CX = zeros(dim, dim)

    for r in dep.rate_of_change_divided_by_N
        ret_val.dN[r.row,r.column] += r.value
        ret_val.dN[r.column,r.column] -= r.value
    end

    ret_val
end



struct EbitParameters
    qVₑ::Array{Float64,1}
    qVₜ::Array{Float64,1}
    A::Array{Float64,1}
    ϕ::Array{Float64,1}
    rₑ²_in_m::Float64
    Ł::Float64

    χ::Array{Float64,2}
    dN::Array{Float64,2}
    CX::Array{Float64,2}

    function EbitParameters(DiffEqParameters::EbitODEMessages.DiffEqParameters) 
        x = new()
        create_ebit_parameters(x, DiffEqParameters)
    end
end




function create_initial_value_vector(problem::EbitODEMessages.SolveODEProblem)
    initial_values = zeros(problem.rate_list.dimension)
    for init in problem.initial_population
        initial_values[init.nuclide.i] = init.value
    end
    return initial_values
end

@inline function not_zero(a, when_not_zero, when_zero)
    iszero(a) ? when_zero : when_not_zero
end


function du(du::Array{Float64, 1}, u::Array{Float64,1}, p::EbitParameters, ::Any)
    N = view(u, 1:p.dimension)
    τ = view(u, p.dimension+1:p.dimension*2)
    dN = view(du, 1:p.dimension)
    dτ = view(du, p.dimension+1:p.dimension*2)

    
    ion_r² = p.rₑ²_in_m .* (τ./p.qVₜ) # ion radius squared
    n = p.Ł .* ( N./ion_r² ) # ion density
    Σ = (p.χ .* n.') .* ( τ./p.A .+ (τ./p.A).' ).^(-3/2) # 1 / relaxation time

    ν = sum(Σ,2) # collision frequency
    ω = p.qVₜ ./ τ # thermodynamic temperature scaled by trap depth
    R_esc = 3/sqrt(3) .* ν .* exp.(-ω) ./ ω # rate of escape

    fe = p.qVₑ ./ τ # electron-ion overlap
    fij = (τ.'./τ) .* ((p.qVₑ).' ./ p.qVₑ)  # ion-ion overlap

    dBeam = (fe .* p.ϕ) # Spitzer heating
    dEscape = - R_esc .* (τ .+ p.qVₜ) # heat loss due to escape
    dExchange = sum(fij .* Σ .* (τ.' .- τ), 2) # heat exchange

    dτ = N .* (dBeam .+ dEscape .+ dExchange)
    dN = N .* ( (- R_esc) .- not_zero(τ, (p.CX.*τ), 0.0) )
end


function create_diffeq_prob(problem)
    if problem.problem_type == EbitODEMessages.ProblemType.ODEProblem
        p = EbitParameters(problem.diff_eq_parameters)
        
        tspan = (problem.problem_parameters.time_span.start, 
                 problem.problem_parameters.time_span.stop)

        initial_values = vcat(problem.diff_eq_parameters.initial_population,
                              problem.diff_eq_parameters.initial_temperature)
        
        @info "Created initial values from list" initial_values
        return ODEProblem(du, initial_values, tspan, p) 
    else
        throw(ErrorException("Unknown Problem type"))
    end
end





function pack_values(solution, nuclides)
    s = solution
    len_t = length(s.t)
    len_i = length(nuclides)

    ret = [EbitODEMessages.ValuesPerNuclide(nuclide=nuclide, values=Array{Float64}(len_t)) 
           for nuclide in nuclides]

    for t in 1:len_t
        for i in 1:len_i
            ret[i].values[t] = s.u[t][i]
        end
    end
    
    return ret;
end



function pack_ode_result(solution, problem, start, stop)
    vals = pack_values(solution, problem.nuclides)
    return EbitODEMessages.Result(problem=problem, start_time=start, stop_time=stop, 
                                  return_code=get(_ret_codes_, solution.retcode, 0),
                                  times=solution.t, values=vals)
end

function pack_ode_msg(res)
    return EbitODEMessages.Message(MsgType=EbitODEMessages.MessageType.ODEResult, ODEResult = res)
end

@noinline function solve_ode(problem)
    start_ = time()
    sol = solve(create_diffeq_prob(problem), saveat=problem.saveat)
    stop = time()
    return pack_ode_msg(pack_ode_result(sol, problem, start_, stop))
end


end
