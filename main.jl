# push!(LOAD_PATH, "/home/renee/phd/src/ebit-evolution.project/ebit-ode-server/")
include("EbitCloudSpatialExtend.jl")
include("EbitODEMessages.jl")
include("EbitSolver.jl")
include("EbitODEServer.jl")
 
module EbitServer
using ArgParse
using DifferentialEquations

using Main.EbitSolver
using Main.EbitODEServer
using Main.EbitODEMessages


function parse_commandline(ARGS::Vector{String})
    s = ArgParseSettings(description="Kairos ODE Server", version = "0.0.1")
    @add_arg_table s begin
        "--port", "-p"
            help = "Port used to connect to server."
            arg_type = Int
            default = 2000
    end

    return parse_args(ARGS,s)
end



Base.@ccallable function julia_main(ARGS::Vector{String})::Cint
    arguments = parse_commandline(ARGS)
    Main.EbitODEServer.start_ode_server(arguments["port"])
    return 0
end

end
