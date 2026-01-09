const CELESTRAK_URL = "https://celestrak.com/SpaceData/SW-All.csv"

"""
Celestrak space weather data.

- Source: https://celestrak.com/SpaceData/
- Documentation: https://celestrak.org/SpaceData/SpaceWx-format.php

Provides:
- `data.Kp`: KeyedArray vector of 3-hourly Kp values indexed by timestamps
- `data.Ap`: KeyedArray vector of 3-hourly Ap values indexed by timestamps
- All CSV columns: `data.DATE`, `data.ISN`, `data.F10_7_OBS`, etc.
"""
struct Celestrak{D}
    data::D
end

Base.getindex(d::Celestrak, i::Int) = getfield(d, :data)[i]
Base.parent(d::Celestrak) = getfield(d, :data)

@inline function Base.getproperty(d::Celestrak, sym::Symbol)
    sym === :data && return parent(d)
    data = parent(d)
    times = if sym === :Kp || sym === :Ap
        # Build 3-hourly timestamps using range
        start_time = DateTime(first(data.DATE)) + Minute(90)
        start_time:Hour(3):(DateTime(last(data.DATE)) + Hour(21) + Minute(90))
    else
        data.DATE
    end
    arr = if sym === :Kp
        vec(hcat(data.KP1, data.KP2, data.KP3, data.KP4, data.KP5, data.KP6, data.KP7, data.KP8)')
    elseif sym === :Ap
        vec(hcat(data.AP1, data.AP2, data.AP3, data.AP4, data.AP5, data.AP6, data.AP7, data.AP8)')
    else
        getproperty(data, sym)
    end
    return KeyedArray(arr; time = times)
end

Base.propertynames(d::Celestrak) = (:Kp, :Ap, propertynames(parent(d))...)

# Cached data storage
const _CELESTRAK_CACHE = Ref{Union{Nothing, Celestrak{DataFrame}}}(nothing)

"""
    celestrak(; update=false) :: Celestrak

Load daily space weather data from Celestrak.

Set `update=true` to refresh data from the server.

# Example
```julia
data = celestrak()
data.Kp                           # KeyedArray with 3h timestamps
data.Kp(DateTime(2023,1,1,1,30))  # Access by timestamp
data.KP1                          # First 3h interval (daily)
data.ISN                          # Sunspot numbers
```
"""
function celestrak(; url = CELESTRAK_URL, update = false)
    if isnothing(_CELESTRAK_CACHE[]) || update
        path = joinpath(datadir(), basename(url))
        download_file(url, path; update, min_age = Day(30))

        # Read and filter to exclude preliminary data
        all_data = CSV.read(path, DataFrame; typemap = IdDict(Int => Float64))
        csv_data = dropmissing!(all_data, :KP1)

        # Scale Kp values from 0-90 to 0-9
        for sym in (:KP1, :KP2, :KP3, :KP4, :KP5, :KP6, :KP7, :KP8, :KP_SUM)
            col = csv_data[!, sym]
            col ./= 10.0
        end

        _CELESTRAK_CACHE[] = Celestrak(csv_data)
    end

    return _CELESTRAK_CACHE[]
end

"""
    celestrak(t0, t1; update=false) :: Celestrak

Load and filter Celestrak data between dates `t0` and `t1` (inclusive).

# Example
```julia
# Get data for year 2023
data_2023 = celestrak(Date(2023,1,1), Date(2023,12,31))
```
"""
function celestrak(t0, t1; update = false)
    data = celestrak(; update)
    df = parent(data)
    i0 = searchsortedfirst(df.DATE, Date(_time(t0)))
    i1 = searchsortedlast(df.DATE, Date(_time(t1)))
    return Celestrak(df[i0:i1, :])
end

_time(t) = DateTime(t)