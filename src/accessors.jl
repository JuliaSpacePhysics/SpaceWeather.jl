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

"""
    xrsa(id, args...; kwargs...) :: KeyedArray

Get GOES-R XRS-A (0.05-0.4 nm) X-ray flux data.
"""
function xrsa(id, args...; kwargs...)
    return XRS(id, args...; kwargs...)["xrsa_flux"] |> _cfvar2keyedarray
end

"""
    xrsb(id, args...; kwargs...) :: KeyedArray

Get GOES-R XRS-B (0.1-0.8 nm) X-ray flux data.
"""
function xrsb(id, args...; kwargs...)
    return XRS(id, args...; kwargs...)["xrsb_flux"] |> _cfvar2keyedarray
end