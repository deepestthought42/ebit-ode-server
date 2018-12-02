# push!(LOAD_PATH, "/home/renee/phd/src/ebit-evolution.project/ebit-ode-server/")
include("EbitODEMessages.jl")
include("EbitSolver.jl")
include("EbitODEServer.jl")
 
module EbitServer
using LinearAlgebra
using Statistics
using Distances

using DifferentialEquations

using Main.EbitSolver
using Main.EbitODEServer
using Main.EbitODEMessages




Base.@ccallable function julia_main(ARGS::Vector{String})::Cint
    Main.EbitODEServer.start_ode_server()
    return 0
end

end
