push!(LOAD_PATH, "/home/renee/phd/src/charge-distribution.project/ebit-ode-server/")

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


@noinline function dtau(τ, N, qVe, qVt, A, ϕ, χ, re2, L)
    ri2 = re2.*(τ./qVt) # ion radius squared
    n = (1/(L*π)).*(N./ri2) # ion density
    Σ = (χ.*n) .* ( τ./A .+ (τ./A).' ).^(-3/2) # 1 / relaxation time

    ν = sum(Σ,2) # collision frequency
    ω = qVt./τ # thermodynamic temperature scaled by trap depth
    Resc = 3/sqrt(3) .* ν .* exp.(-ω) ./ ω # rate of escape

    fe = qVe./τ # electron-ion overlap
    fij = (τ.'./τ).*(qVe.'./qVe)  # ion-ion overlap

    dBeam = (fe .* ϕ) # Spitzer heating
    dEscape = - Resc .* (τ .+ qVt) # heat loss due to escape
    dExchange = sum(fij .* Σ .* (τ.' .- τ), 2) # heat exchange
    return dBeam .+ dEscape .+ dExchange 
end


function test()
    dtau(c1(:τ), c1(:N), c1(:qVe), c1(:qVt), c1(:A), c1(:ϕ), c2(:χ), "re2", "L")
end

τ = c1(:τ)
A = c1(:A)
sum((τ./A .+ (τ./A).').*(τ.' .- τ), 2)

