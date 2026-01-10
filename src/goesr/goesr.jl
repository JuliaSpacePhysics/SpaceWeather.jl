# Geostationary Operational Environmental Satellites
# [Geostationary Operational Environmental Satellites - R Series | NOAA/NASA](https://www.goes-r.gov/)
# Source: [NOAA GOES-R Data](https://data.ngdc.noaa.gov/platforms/solar-space-observing-satellites/goes/)
# Documentation: https://www.ngdc.noaa.gov/stp/satellite/goes-r.html
# Catalog: https://catalog.data.gov/dataset/geostationary-operational-environmental-satellite-r-series-goes-r-space-environment-in-situ-sui2
# SEISS Documentation: https://www.ncei.noaa.gov/products/goes-r-space-environment-in-situ

include("types.jl")

const GOESR_BASE_URL = "https://data.ngdc.noaa.gov/platforms/solar-space-observing-satellites/goes"

_mpsh_url(id; datatype = "avg1m", version = "v2-0-2") =
    "l2/data/mpsh-l2-$(datatype)_science/{Y}/{M}/sci_mpsh-l2-$(datatype)_g$(id)_d{YMD}_$(version).nc"

_sgps_url(id; datatype = "avg1m", version = "v3-0-2") =
    "l2/data/sgps-l2-$(datatype)/{Y}/{M}/sci_sgps-l2-$(datatype)_g$(id)_d{YMD}_$(version).nc"

_xrs_url(id; datatype = "avg1m", version = "v2-2-0") =
    "l2/data/xrsf-l2-$(datatype)_science/{Y}/{M}/sci_xrsf-l2-$(datatype)_g$(id)_d{YMD}_$(version).nc"

function _mag_url(id; datatype = "avg1m", version = nothing)
    version = @something version (datatype == "avg1m" ? "v2-0-2" : "v1-0-1")
    return "l2/data/magn-l2-$(datatype)/{Y}/{M}/dn_magn-l2-$(datatype)_g$(id)_d{YMD}_$(version).nc"
end

const SGPS = GoesInstrument("SGPS", GoesUrlPattern(_sgps_url))
"""Magnetospheric Particle Sensor High (MPS-HI)"""
const MPSH = GoesInstrument("MPSH", GoesUrlPattern(_mpsh_url))
const XRS = GoesInstrument("XRS", GoesUrlPattern(_xrs_url))
const MAG = GoesInstrument("MAG", GoesUrlPattern(_mag_url))

@doc """
    XRS(id, t0, t1; update=false)

Load GOES-R EXIS X-Ray Sensor (XRS) data for a date range, combining multiple daily files.

# Example
```julia
dataset = XRS(16, Date(2020, 6, 1), Date(2020, 6, 2))
dataset.xrsa_flux  # Combined X-ray flux data
```
""" XRS

function _download_geos_file(url; update = false)
    uri = URI(url)
    relpath = lstrip(uri.path, '/')
    local_path = joinpath(datadir(), relpath)
    mkpath(dirname(local_path))
    if isfile(local_path) && !update
        return local_path
    end
    download_file(url, local_path; update, min_age = Day(1))
    return local_path
end
