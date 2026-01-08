# Source: [NOAA GOES-R Data](https://data.ngdc.noaa.gov/platforms/solar-space-observing-satellites/goes/)
# Documentation: [GOES-R EXIS Information](https://www.ngdc.noaa.gov/stp/satellite/goes-r.html)

# GOES-R EXIS (Extreme Ultraviolet and X-ray Irradiance Sensors) data

# Base URL for GOES-R XRS data (1-minute averages)
const GOESR_XRS_BASE_URL = "https://data.ngdc.noaa.gov/platforms/solar-space-observing-satellites/goes"

"""
GOES-R EXIS X-Ray Sensor (XRS) data.

- Source: https://data.ngdc.noaa.gov/platforms/solar-space-observing-satellites/goes/
- Documentation: https://www.ngdc.noaa.gov/stp/satellite/goes-r.html
"""
struct GoesrXrs{D, T}
    data::D
    time::T
    id::Int
end

Base.parent(d::GoesrXrs) = getfield(d, :data)

@inline function Base.getproperty(d::GoesrXrs, sym::Symbol)
    sym in fieldnames(GoesrXrs) && return getfield(d, sym)
    ds = getfield(d, :data)
    return KeyedArray(ds[sym][:]; time = d.time)
end

Base.getindex(d::GoesrXrs, key) = parent(d)[key]
Base.keys(d::GoesrXrs) = keys(parent(d))

# Construct the URL for GOES-R XRS data file
function goesr_xrs_url(id, date; datatype = "avg1m", version = "v2-2-0")
    year = Dates.year(date)
    month = lpad(Dates.month(date), 2, '0')
    day = lpad(Dates.day(date), 2, '0')
    datestr = "$(year)$(month)$(day)"

    # Filename format: sci_xrsf-l2-avg1m_g16_d20200601_v2-2-0.nc
    filename = "sci_xrsf-l2-$(datatype)_g$(id)_d$(datestr)_$(version).nc"

    return (
        base = "$(GOESR_XRS_BASE_URL)/goes$(id)/l2/data/xrsf-l2-$(datatype)_science/$(year)/$(month)/",
        filename = filename,
    )
end

"""
    goesr_xrs(id, time; update=false) :: GoesrXrs

Download and load GOES-R XRS data for a specific `id` and `time`.

# Example
```julia
data = goesr_xrs(16, Date(2020, 6, 1))
data.xrsa_flux  # Short wavelength X-ray flux
```
"""
function goesr_xrs(id, date; update = false)
    file = _download_xrs_file(id, date; update)
    ds = NCDataset(file)
    times = nomissing(Array(ds["time"]))
    return GoesrXrs(ds, times, id)
end

"""
    goesr_xrs(id, t0::Date, t1::Date; update=false) :: GoesrXrs

Load GOES-R XRS data for a date range, combining multiple daily files.

# Example
```julia
data = goesr_xrs(16, Date(2020, 6, 1), Date(2020, 6, 2))
data.xrsa_flux  # Combined X-ray flux data
```
"""
function goesr_xrs(id, t0, t1; update = false)
    dt = Day(1)
    dates = Date(floor(t0, Day)):dt:Date(ceil(t1, Day))
    files = _download_xrs_file.(id, dates; update)
    ds = NCDataset(files, aggdim = "time")
    times = nomissing(ds["time"][:])
    return GoesrXrs(ds, times, id)
end

function _download_xrs_file(id, time; kw...)
    url_info = goesr_xrs_url(id, time)
    return _download_xrs_file(url_info.base, url_info.filename, id; kw...)
end

function _download_xrs_file(base_url, filename, satellite; update = false)
    cache_dir = joinpath(datadir(), "goes$(satellite)")
    mkpath(cache_dir)

    dest = joinpath(cache_dir, filename)

    if isfile(dest) && !update
        return dest
    end

    url = base_url * filename
    download_file(url, dest; update, min_age = Day(1))
    return dest
end
