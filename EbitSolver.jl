module EbitSolver
# using Revise
# using ProgressMeter
using Main.EbitODEMessages
# using MicroLogging

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


function create_matrix(dim, sparse_values, f = (v, matrix) -> matrix[v.row,v.column] += v.value)
    matrix = zeros(dim, dim)
    map(v -> f(v,matrix), sparse_values)
    return matrix
end



struct EbitParameters
    qVₑ::Array{Float64,1}
    qVₜ::Array{Float64,1}
    A::Array{Float64,1}
    ϕ::Array{Float64,1}
    qVe_over_Vol_x_kT::Array{Float64,1}
    source_n::Array{Float64,1}
    source_kT::Array{Float64,1}

    χ::Array{Float64,2}
    dN::Array{Float64,2}
    CX::Array{Float64,2}

    τ::Array{Float64,1}
    
    no_dimensions::UInt32
    min_N::Float64
    
    report_function
    
    function EbitParameters(dep::EbitODEMessages.DiffEqParameters, report_function)
        dim = dep.no_dimensions
        qVₑ = dep.qVe
        qVₜ = dep.qVt
        A = dep.mass_number
        ϕ = dep.spitzer_divided_by_overlap
        qVe_over_Vol_x_kT = dep.qVe_over_Vol_x_kT
        χ = create_matrix(dim, dep.inverted_collision_constant)
        dN = create_matrix(dim, dep.rate_of_change_divided_by_N)
        CX = create_matrix(dim, dep.dCharge_ex_divided_by_N_times_tau)

        return new(qVₑ, qVₜ, A, ϕ, qVe_over_Vol_x_kT,
                   dep.source_terms_n, dep.source_terms_kt, χ, dN, CX,
                   Array{Float64}(undef, dep.no_dimensions),
                   dep.no_dimensions, dep.minimum_N, report_function)
    end
end

function iserr(x::Float64, name::String)
    if isinf(x) || isnan(x) || iszero(x) || isless(x, 0)
        error("$name = $x")
    end
    x
end

function du(du::Array{Float64, 1}, u::Array{Float64,1}, p::EbitParameters, t::Float64)
    @inbounds begin
        N = view(u, 1:p.no_dimensions)
        Nτ = view(u, p.no_dimensions+1:p.no_dimensions*2)

        dN = view(du, 1:p.no_dimensions)
        dNτ = view(du, p.no_dimensions+1:p.no_dimensions*2)
        
        

        
        for i in 1:p.no_dimensions
            if N[i] > p.min_N 
                p.τ[i] = Nτ[i] / N[i]
            else
                p.τ[i] = 0.0
            end
        end

        
        @simd for i in 1:p.no_dimensions
            ν = 0.0
            R_exchange_sum_j = 0.0
            dN[i] = p.source_n[i]
            dNτ[i] = p.source_kT[i]


            @simd for j in 1:p.no_dimensions
                # calculate everything that is based on interaction of two states
                if (N[i] > p.min_N && N[j] > p.min_N && p.τ[j] > 0.0 && p.τ[i] > 0.0) 
                    fᵢⱼ = min((p.τ[i]*p.qVₑ[j])/(p.τ[j]*p.qVₑ[i]), 1.0)
                    nⱼ = N[j] * p.qVe_over_Vol_x_kT[j] / p.τ[j]
                    arg = (p.τ[i]/p.A[i] + p.τ[j]/p.A[j])
                    Σ = p.χ[i,j] * nⱼ * arg^(-1.5)
                    ν += Σ
                    R_exchange_sum_j += fᵢⱼ * Σ * (p.τ[j] - p.τ[i])

                    dN[i] += p.CX[i,j]*N[j]*sqrt(p.τ[j])
                    dNτ[i] += p.CX[i,j]*N[j]*sqrt(p.τ[j])*p.τ[j]
                end
                
                dN[i] += p.dN[i,j]*N[j]
                dNτ[i] += p.dN[i,j]*Nτ[j]
            end

            dNτ[i] += R_exchange_sum_j*N[i] 

            if N[i] > p.min_N && p.τ[i] > 0.0
                R_esc = 3/sqrt(2) * ν * ( p.τ[i] / p.qVₜ[i] ) * exp( - p.qVₜ[i] / p.τ[i] )
                dNτ[i] += N[i] * min( p.qVₑ[i] / p.τ[i], 1.0) * p.ϕ[i] 
                dN[i] -= N[i] * R_esc
                dNτ[i] -= N[i] * ( p.τ[i] + p.qVₜ[i] ) * R_esc
            end
            
        end

        return du
    end
end




function create_initial_values(initial_values, dimensions)
    ret = zeros(2*dimensions)
    
    map((iv) -> 
        begin
        ret[iv.index] = iv.number_of_particles
        ret[dimensions + iv.index] = iv.temperature_in_ev
        end,
        initial_values)

    return ret
end


@noinline function create_diffeq_prob(problem, report_function)
    if problem.problem_parameters.problem_type == EbitODEMessages.ProblemType.ODEProblem
        @debug "Creating ODEProblem"
        p = EbitParameters(problem.diff_eq_parameters, report_function)

        @debug "Created differential equation parameters" p.dN

        tspan = (problem.problem_parameters.time_span.start,
                 problem.problem_parameters.time_span.stop)

        initial_values = create_initial_values(
            problem.diff_eq_parameters.initial_values,
            problem.diff_eq_parameters.no_dimensions
        )

        @debug "Created initial values from list" initial_values

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

    ret_n = [EbitODEMessages.ValuesPerNuclide(nuclide=nuclide, values=Array{Float64}(undef, len_t))
             for nuclide in nuclides]
    ret_kT = [EbitODEMessages.ValuesPerNuclide(nuclide=nuclide, values=Array{Float64}(undef, len_t))
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


function callback(u,t,integrator)
    if integrator.p.report_function(t)
        terminate!(integrator)
        @info "Terminating integration" t
    end
end

function solve_ode(problem, report_progress)
    start_ = time()
    @info "Starting solver"
    sol = solve(create_diffeq_prob(problem, report_progress), 
                # alghints=[:stiff],
                saveat=problem.solver_parameters.saveat,
                # abstol=1e-3,
                callback=FunctionCallingCallback(callback, funcat=problem.solver_parameters.saveat),
                )
    stop = time()
    @info "Finished integration" start_ stop
    return pack_ode_msg(pack_ode_result(sol, problem, start_, stop))
end


end
