push!(LOAD_PATH, "/home/renee/phd/src/ebit-evolution.project/ebit-ode-server/")
include("/home/renee/phd/src/ebit-evolution.project/ebit-ode-server/EbitODEMessages.jl")
include("/home/renee/phd/src/ebit-evolution.project/ebit-ode-server/EbitSolver.jl")
include("/home/renee/phd/src/ebit-evolution.project/ebit-ode-server/EbitODEServer.jl")

using Revise
using EbitODEServer
import Base.+, Base.*, Base./, Base.-, Base.zero, Base.transpose, Base.exp, Base.^





function join_symbol(a, b)
     return string(string(a), string(b))
end

function check_empty(a, b, default)
    if (a == "" && b != "")
        return b
    elseif (b == "" && a != "")
        return a
    elseif (b == "" && a == "")
        return ""
    else
        return default
    end
end

function (+)(a::Any, b::Any)
    return check_empty(a, b, String("($a + $b)"))
end

function (*)(a::Any, b::Any) 
    return check_empty(a, b, String("($a * $b)"))
end

function (/)(a::Any, b::Any) 
    return check_empty(a, b, String("($a / $b)"))
end

function (-)(a::Any, b::Any) 
    return check_empty(a, b, String("($a - $b)"))
end

function (-)(a::Any)
    return String("-$a)")
end

function (^)(a::Any, b::Any)
    return String("$a^{$b})")
end


function exp(a::Any)
    return String("exp[$a]")
end


transpose(str::String) = String(str)

function zero(a::String)
    return ""
end

function zero(a::Type{String}) "" end

function (^)(a::Any, p::Real)
    "$a^{$p}"
end


default_size = 2

function c1(symbol)
    ["$symbol\_$i" for i=1:default_size]
end

function c2(symbol)
    val = Array{String,2}(default_size,default_size)
    for i in 1:default_size
        for j in 1:default_size
            val[i,j] = "$symbol\_$i$j"
        end
    end
    return val
end


τ = c1(:τ)
A = c1(:A)
n = c1(:n)
Χ = c1(:Χ)
N = c1(:N)
CX = c2(:CX)

(τ.' .* CX)*N

(τ .+ τ')./A'

(τ./τ')*ones(2,1)

τ' .- τ

τ./A .+ (τ./A)'

qVₜ = c1(:qVₜ)

τ./qVₜ .+ (τ./qVₜ)'
