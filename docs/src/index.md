```@meta
CurrentModule = SpaceWeather
```

# SpaceWeather

Documentation for [SpaceWeather](https://github.com/JuliaSpacePhysics/SpaceWeather.jl).

SpaceWeather.jl provides easy access to space weather indices and data, with automatic downloading and caching from various sources.

## Installation

```julia
using Pkg
Pkg.add("SpaceWeather")
```

## Quickstart

### Basic Usage

```@example quickstart
using SpaceWeather
using Dates

# Fetch all available space weather data from Celestrak
data = celestrak()

# Access Kp index (3-hourly planetary K-index)
kp_values = data.Kp                              # All Kp values as KeyedArray
kp_at_time = data.Kp(DateTime(2023, 1, 1, 1, 30))  # Query specific time

# Access Ap index (3-hourly planetary A-index)
ap_values = data.Ap

# Get data for a specific time range
data_2023 = celestrak(Date(2023, 1, 1), Date(2023, 12, 31))
kp_2023 = data_2023.Kp
ap_2023 = data_2023.Ap

# High-level accessor functions
kp = Kp(Date(2023, 1, 1), Date(2023, 12, 31))
ap = Ap(Date(2023, 1, 1), Date(2023, 12, 31))
```

Data is automatically cached and can be refreshed with `celestrak(update=true)`. Cache is automatically refreshed if older than 30 days.

## API Reference

```@index
```

```@autodocs
Modules = [SpaceWeather]
```
