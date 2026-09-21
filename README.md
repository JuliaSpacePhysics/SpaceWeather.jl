# SpaceWeather

[![Coverage](https://codecov.io/gh/JuliaSpacePhysics/SpaceWeather.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaSpacePhysics/SpaceWeather.jl)

## Quickstart

```julia
using Pkg; Pkg.add("SpaceWeather")
using SpaceWeather
using Dates

# Fetch all available space weather data from Celestrak
data = celestrak()

# Access Kp index (3-hourly planetary K-index)
kp_values = data.Kp                              # All Kp values as KeyedArray
kp_at_time = data.Kp(DateTime(2023, 1, 1, 1, 30))  # Query specific time
```

## Features and Roadmap

- [ ] Space Weather Observations
  - [ ] Space Weather Indices
    - [x] Planetary K-index
    - [ ] [Hpo indices of Global Geomagnetic Activity](https://www.gfz.de/en/hpo-index)
  - [ ] Geostationary Operational Environmental Satellite (GOES)
    - [x] Extreme Ultraviolet and X-ray Irradiance Sensors (EXIS)
    - [x] Space Environment In Situ Suite (SEISS)
    - [x] Magnetometer
    - [ ] Solar Ultraviolet Imager (SUVI)
- [ ] Space Weather Models
- [ ] Space Weather Forecasts

## Elsewhere

- [NOAA / NWS Space Weather Prediction Center](https://www.swpc.noaa.gov/)
- [SWx TREC Space Weather Data Portal](https://lasp.colorado.edu/space-weather-portal/): simultaneously displays diverse space weather data from the Sun to the Earth
- [pyspaceweather](https://github.com/st-bender/pyspaceweather): Space weather indices for python
- [pysatSpaceWeather](https://github.com/pysat/pysatSpaceWeather): pysat support for Space Weather Indices
- [SpaceIndices.jl](https://github.com/JuliaSpace/SpaceIndices.jl): automatically fetch and parse space indices (Celestrak, JB2008 and Hpo)
- [GOES-R SPWX Examples](https://cires-stp.github.io/goesr-spwx-examples/index.html)
