"""
    Kp(t0, t1; source=:celestrak, kwargs...)

Get Planetary K-index data from `source`.

https://www.swpc.noaa.gov/products/planetary-k-index
"""
function Kp(t0, t1; source = :celestrak, kwargs...)
    return source == :celestrak && celestrak(t0, t1; kwargs...).Kp
end

"""
    Ap(args...; source=:celestrak, kwargs...)

Get Ap index data from `source`.
"""
function Ap(args...; source = :celestrak, kwargs...)
    return source == :celestrak && celestrak(args...; kwargs...).Ap
end
