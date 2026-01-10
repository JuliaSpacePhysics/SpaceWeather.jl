# Reading and Plotting GOES-R XRS Data

Example for reading and plotting GOES-R EXIS X-ray sensr data

## Basic Usage

```@example goesr
using SpaceWeather
using Dates

# Download and load XRS data for a single day
xrs = XRS(16, Date(2020, 6, 1))

# Access X-ray flux data
xrsa = xrs["xrsa_flux"]  # Short wavelength (0.05-0.4 nm)
xrsb = xrs["xrsb_flux"]  # Long wavelength (0.1-0.8 nm)
```

```@example goesr
# load Magnetospheric Particle Sensor High (MPS-HI)
mpsh_ds = SpaceWeather.MPSH(16, Date(2020, 6, 1))
var = mpsh_ds["AvgDiffProtonFlux"]
```

```@example goesr
# load MAG Data
mag_ds = SpaceWeather.MAG(16, Date(2020, 6, 1))
```

## Plotting Example

```@example goesr
using CairoMakie

f = Figure()
ax1 = Axis(f[1, 1]; yscale = log10, xlabel = "Time (UTC)", ylabel = "X-Ray Flux\n($(xrsa.attrib["units"]))")
times = nomissing(xrs["time"][:])
lines!(ax1, times, nomissing(xrsa[:]); label = "GOES-16 XRS-A (0.05-0.4 nm)", color = :mediumorchid)
lines!(ax1, times, nomissing(xrsb[:]); label = "GOES-16 XRS-B (0.1-0.8 nm)", color = :green)

# Plot 1 day of MPSH 1-minute AvgDiffProtonFlux in Telescope 0, Band 0
var = mpsh_ds["AvgDiffProtonFlux"]
ax2 = Axis(f[2, 1]; yscale = log10, xlabel = "Time (UTC)", ylabel = "AvgDiffProtonFlux\n($(var.attrib["units"]))")
times = nomissing(mpsh_ds["time"][:])
lines!(ax2, times, var[1, 1, :])

var = mag_ds["b_total"]
ax3 = Axis(f[3, 1]; ylabel = "b_total\n($(var.attrib["units"]))")
times = nomissing(mag_ds["time"][:])
lines!(ax3, times, var[:])

hidexdecorations!.((ax1, ax2); grid = false)
f
```