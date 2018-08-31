module EbitSolver
using Revise
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


function create_matrix(dim, sparse_values, f = (v, matrix) -> matrix[v.row,v.column] = v.value)
    matrix = zeros(dim, dim)
    map(v -> f(v,matrix), sparse_values)
    return matrix
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

    no_dimensions::UInt32

    min_N::Float64
    
    R_esc::Array{Float64,1}
    Σ::Array{Float64,2}
    τ::Array{Float64,1}
    arg::Array{Float64,2}

    function EbitParameters(dep::EbitODEMessages.DiffEqParameters)
        dim = dep.no_dimensions
        qVₑ = dep.qVe
        qVₜ = dep.qVt
        A = dep.mass_number
        ϕ = dep.spitzer_divided_by_overlap
        rₑ²_in_m = dep.electron_radius_in_m_squared
        Ł = dep.one_over_pi_times_L

        χ = create_matrix(dim, dep.inverted_collision_constant)
        dN = create_matrix(dim, dep.rate_of_change_divided_by_N,
                           (v, matrix) ->
                           begin
                             matrix[v.row,v.column] += v.value
                             matrix[v.column,v.column] -= v.value
                           end)

        CX = zeros(dim, dim)
        R_esc = zeros(dim)
        Σ = zeros(dim,dim)
        τ = zeros(dim)
        arg = zeros(dim,dim)

        return new(qVₑ, qVₜ, A, ϕ, rₑ²_in_m, Ł, χ, dN, 
                   CX, dep.no_dimensions, 0, R_esc, 
                   Σ, τ, arg)
    end
end


function du(du::Array{Float64, 1}, u::Array{Float64,1}, p::EbitParameters, t::Float64)
    N = view(u, 1:p.no_dimensions)
    Nτ = view(u, p.no_dimensions+1:p.no_dimensions*2)

    dN = view(du, 1:p.no_dimensions)
    dNτ = view(du, p.no_dimensions+1:p.no_dimensions*2)

    for i in 1:p.no_dimensions
        # order is important here
        Nτ[i] = max(0, Nτ[i])
        p.τ[i] = ( N[i] > p.min_N ) ? (2 * Nτ[i]) / (3 * N[i]) : 0.0
    end

    
    for i in 1:p.no_dimensions
        R_esc_sum_j = 0
        R_exchange_sum_j = 0
        dN[i] = 0
        dNτ[i] = 0
        
        for j in 1:p.no_dimensions
            arg = p.τ[i]/p.A[i] + p.τ[j]/p.A[j]

            if p.τ[j] > 0
                fij = min((p.τ[i]*p.qVₑ[j])/(p.τ[j]*p.qVₑ[i]), 1.0)
                Σ = p.χ[i,j] * ( N[j] * p.qVₑ[j] * p.Ł / ( p.rₑ²_in_m * p.τ[j] ) ) * ( arg^(-1.5) )

                if arg > 0.0
                    R_esc_sum_j += fij * Σ
                end

                if p.τ[i] > 0.0
                    R_exchange_sum_j +=  fij * Σ * (p.τ[j] - p.τ[i])
                end
            end
            
            dN[i] += p.dN[i,j]*N[j]
            dNτ[i] += p.dN[i,j]*Nτ[j]
        end
        
        R_esc = 3/sqrt(3) * R_esc_sum_j * exp(-p.qVₜ[i] / p.τ[i]) / ( p.qVₜ[i] / p.τ[i] )

        
        dN[i] -= N[i] * R_esc
        dNτ[i] +=  N[i] * ( min( p.qVₑ[i] / p.τ[i], 1.0) * p.ϕ[i] 
                            - ( p.τ[i] + p.qVₜ[i] ) * R_esc
                            + R_exchange_sum_j )
                     
    end

    # map(n -> if (isinf(n) || isnan(n)) @info "NaN or Inf" N Nτ p.τ t R_esc du end, du)
    
    return du
end




function create_initial_values(initial_values, dimensions)
    ret = zeros(2*dimensions)
    
    map((iv) ->
        begin
        ret[iv.index] = iv.number_of_particles;
        ret[dimensions+iv.index] = iv.number_of_particles * iv.temperature_in_ev;
        end,
        initial_values)
   
    return ret

end


@noinline function create_diffeq_prob(problem)
    if problem.problem_parameters.problem_type == EbitODEMessages.ProblemType.ODEProblem
        @info "Creating ODEProblem"
        p = EbitParameters(problem.diff_eq_parameters)

        @info "Created differential equation parameters" p.dN

        tspan = (problem.problem_parameters.time_span.start,
                 problem.problem_parameters.time_span.stop)

        
        initial_values = create_initial_values(
            problem.diff_eq_parameters.initial_values,
            problem.diff_eq_parameters.no_dimensions
        )

        @info "Created initial values from list" initial_values

        global last_p = p
        global last_initial_values = initial_values
        
        return ODEProblem(du, initial_values, tspan, p)
    else
        throw(ErrorException("Unknown Problem type"))
    end
end





function pack_values(solution, nuclides)
    s = solution
    len_t = length(s.t)
    len_i = length(nuclides)

    ret_n = [EbitODEMessages.ValuesPerNuclide(nuclide=nuclide, values=Array{Float64}(len_t))
             for nuclide in nuclides]
    ret_kT = [EbitODEMessages.ValuesPerNuclide(nuclide=nuclide, values=Array{Float64}(len_t))
              for nuclide in nuclides]

    for t in 1:len_t
        for i in 1:len_i
            ret_n[i].values[t] = s.u[t][i]
            ret_kT[i].values[t] = s.u[t][len_i + i]
        end
    end

    return ret_n, ret_kT
end



function pack_ode_result(solution, problem, start, stop)
    ns, kts = pack_values(solution, problem.nuclides)
    return EbitODEMessages.Result(problem=problem, start_time=start, stop_time=stop,
                                  return_code=get(_ret_codes_, solution.retcode, 0),
                                  times=solution.t, n=ns, kT=kts)
end

function pack_ode_msg(res)
    return EbitODEMessages.Message(msg_type=EbitODEMessages.MessageType.ODEResult, ode_result = res)
end

@noinline function solve_ode(problem)
    start_ = time()
    sol = solve(create_diffeq_prob(problem),
                saveat=problem.solver_parameters.saveat,
                force_dtmin=true,
                cb=GeneralDomain((resid, u, p, t) -> resid .= abs.(min.(0, u)))
                )
    stop = time()
    return pack_ode_msg(pack_ode_result(sol, problem, start_, stop))
end


end
