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
    I::Array{Float64,2}

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
        I = ones(dim,1)

        return new(qVₑ, qVₜ, A, ϕ, rₑ²_in_m, Ł, χ, dN, CX, dep.no_dimensions, 1e-2, I)
    end
end


@inline function ifLarger(x, than, if_larger, else_larger)
    if x > than
        if_larger
    else
        else_larger
    end
end

function du(du::Array{Float64, 1}, u::Array{Float64,1}, p::EbitParameters, ::Any)
    N = view(u, 1:p.no_dimensions, 1:1)
    τ = view(u, p.no_dimensions+1:p.no_dimensions*2, 1:1)

    dN = view(du, 1:p.no_dimensions, 1:1)
    dτ = view(du, p.no_dimensions+1:p.no_dimensions*2, 1:1)


    # 1 / relaxation time
    Σ = ( p.χ .* (p.Ł .* N./(p.rₑ²_in_m .* (τ./p.qVₜ)))' ) .* 
        ( ((τ ./ p.A) .+ (τ ./ p.A)') .^ (-1.5) ) 


    # rate of escape
    R_esc = (3/sqrt(3) .* 
             (( (min.(( τ./τ' ) .* ( p.qVₑ' ./ xp.qVₑ ), 1.0)) .* Σ) * p.I) .* 
             exp.(.- p.qVₜ ./ τ) ./ p.qVₜ ./ τ) 

    dN .= ( p.dN * N )  -  N .* R_esc #.- not_zero(τ, (p.CX.*τ), 0.0) ) )
    
    dτ .= ( min.(p.qVₑ ./ τ, 1.0) .* p.ϕ ) .- 
          ( R_esc .* (τ .+ p.qVₜ) ) .+ 
          (((min.(( τ./τ' ) .* ( p.qVₑ' ./ p.qVₑ ), 1.0)) .* Σ .* (τ' .- τ)) * p.I)

    return du
end




function create_initial_values(initial_values, dimensions)
    ret = zeros(2*dimensions)
    
    map((iv) ->
        begin
        ret[iv.index] = iv.number_of_particles;
        # initializing with T = 10 eV
        # ret[dimensions+iv.index] = 10.0
        end,
        initial_values)
   
    # initializing with T = 10 eV
    for i in dimensions+1:dimensions*2
        ret[i] = 10.0
    end

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
                saveat=problem.solver_parameters.saveat)
    stop = time()
    return pack_ode_msg(pack_ode_result(sol, problem, start_, stop))
end


end
