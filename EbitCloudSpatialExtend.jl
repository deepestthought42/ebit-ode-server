module EbitCloudSpatialExtend

using Revise
using QuadGK
using Interpolations
using Memoize

function phi(r, r_e, V_0)
    if r < r_e
        return V_0*(r/r_e)^2
    else
        return V_0*(2*log(r/r_e) + 1) 
    end
end


function eta(qe_over_kT, r_stop, r_e, V_0, rtol=1e-6)
    f(r) = exp(-qe_over_kT*phi(r, r_e, V_0))*r
    quadgk(f, 0, r_stop, rtol=rtol, order=15)[1]
end


function ion_ion_overlap(qe_over_kT_i, qe_over_kT_j, r_stop, r_e, V_0, rtol=1e-6)
    retval = min(1.0, eta(qe_over_kT_i,  r_stop, r_e, V_0, rtol) / eta(qe_over_kT_j, r_stop, r_e, V_0, rtol))
    if isnan(retval)
        return 1.0
    else
        return retval
    end
end

function electron_ion_overlap(qe_over_kT, r_stop, r_e, V_0, rtol=1e-6)
    retval = min(1.0, eta(qe_over_kT, r_e, r_e, V_0, rtol) / eta(qe_over_kT, r_stop, r_e, V_0, rtol))
    if isnan(retval)
        return 1.0
    else
        return retval
    end
end


function effective_radius(qe_over_kT, r_stop, r_e, V_0; rtol=1e-6, change_to_simple=100)
    if ( V_0 * qe_over_kT > change_to_simple)
        return r_e * sqrt(1/(V_0 * qe_over_kT))
    else
        f(r) = exp(-qe_over_kT*phi(r, r_e, V_0))*r
        g(r) = exp(-qe_over_kT*phi(r, r_e, V_0))*r*r
    
        return quadgk(g, 0, r_stop, rtol=rtol, order=21)[1] / quadgk(f, 0, r_stop, rtol=rtol, order=21)[1]
    end
end


function simple_effective_radius(qe_over_kT, r_e, V_0)
    if ( V_0 * qe_over_kT > 1)
        return r_e * sqrt(1/(V_0 * qe_over_kT))
    else
        return r_e * exp(0.5*(1/(V_0*qe_over_kT) - 1))
    end
end

# comparison function
function create_interpolation(f, no_of_log_divisions=100, 
                              q_over_kT_start=1e-12, q_over_kT_stop=1e12)
    
    _start = no_of_log_divisions*log10(q_over_kT_start)
    _end = no_of_log_divisions*log10(q_over_kT_stop)
    
    xs = vcat([0], [exp10(x/no_of_log_divisions) for x in _start:_end], [Inf])
    ys = [f(x) for x in xs]
    
    return LinearInterpolation(xs, ys)
end


function create_2d_interpolation(f, no_of_log_divisions=10, 
                                 q_over_kT_start=1e-12, q_over_kT_stop=1e12)
    
    _start = no_of_log_divisions*log10(q_over_kT_start)
    _end = no_of_log_divisions*log10(q_over_kT_stop)
    
    xs = vcat([0], [exp10(x/no_of_log_divisions) for x in _start:_end], [Inf])
    zs = [f(x, y) for x in xs, y in xs]
    
    return LinearInterpolation((xs, xs), zs)
end



end
