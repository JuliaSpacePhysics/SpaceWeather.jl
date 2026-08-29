# SpaceWeather

[![Coverage](https://codecov.io/gh/JuliaSpacePhysics/SpaceWeather.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaSpacePhysics/SpaceWeather.jl)

**Installation**: at the Julia REPL, run `using Pkg; Pkg.add("SpaceWeather")`

**Documentation**: [![Dev](https://img.shields.io/badge/docs-dev-blue.svg?logo=julia)](https://JuliaSpacePhysics.github.io/SpaceWeather.jl/dev/)

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