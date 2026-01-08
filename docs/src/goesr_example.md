# Reading and Plotting GOES-R XRS Data

Example for reading and plotting GOES-R EXIS X-ray sensor data

## Basic Usage

```@example goesr
using SpaceWeather
using Dates

# Download and load XRS data for a single day
data = goesr_xrs(16, Date(2020, 6, 1))

# Access X-ray flux data
xrsa = data.xrsa_flux  # Short wavelength (0.05-0.4 nm)
xrsb = data.xrsb_flux  # Long wavelength (0.1-0.8 nm)

# Access timestamps
times = data.time
```

## Plotting Example

```@example goesr
using CairoMakie

axis = (;
    yscale = log10,
    xlabel = "Time (UTC)",
    ylabel = "X-Ray Flux (W/m²)",
)
fap = plot(
    data.time, data.xrsa_flux;
    label = "GOES-16 XRS-A (0.05-0.4 nm)",
    color = :mediumorchid,
    axis = axis
)

plot!(
    data.time, identity.(data.xrsb_flux),
    label = "GOES-16 XRS-B (0.1-0.8 nm)",
    color = :green,
)
fap
```