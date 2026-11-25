# SpaceWeather

Geomagnetic and solar indices from GFZ and satellite observations from GOES.

```julia
using SpaceWeather, Dates

k = Kp("2024-05-10", "2024-05-13")
times(k), parent(k)
```

Index timestamps are UTC interval starts. The end date is exclusive.

| Cadence | GFZ indices |
|---|---|
| 3 hours | `Kp`, `ap` (equivalent planetary amplitude) |
| Daily | `Ap` (mean of the eight `ap` values), `SN` (sunspot number), `F107` and `F107adj` (observed and adjusted solar radio flux) |
| 30 or 60 minutes | `Hp30`, `ap30` and `Hp60`, `ap60` |

[GFZ index files and format examples](https://www-app3.gfz-potsdam.de/data.php) ⋅ [GFZ Kp index](https://kp.gfz.de) ⋅ [Hpo index](https://kp.gfz.de/en/hp30-hp60)

- `print(getmeta(GFZ.KP)["header"])` shows GFZ's file description and citations; likewise for `GFZ.DAILY`, `GFZ.HP30` and `GFZ.HP60`.
- In `GFZ.KP` and `GFZ.DAILY`, `definitive` applies to the geomagnetic indices; sunspot number has its own `SN_definitive`. Definitive daily sunspot observations:

```julia
d = getdata(GFZ.DAILY, "2024-01-01", "2025-01-01")
sn = d["SN"]
keep = d["SN_definitive"] .& isfinite.(sn)
times(sn)[keep], parent(sn)[keep]
```

- GFZ revises preliminary values in place. Save the input file or the extracted series with the retrieval date for reproduction. `update = true` forces a fresh copy.

## Geostationary Operational Environmental Satellites (GOES)

```julia
using SpaceWeather.GOES
getdata(XRS[id = 16], Date(2020, 6, 1), Date(2020, 6, 3))["xrsa_flux"]
```

## References

- [NOAA / NWS Space Weather Prediction Center](https://www.swpc.noaa.gov/)
- [SWx TREC Space Weather Data Portal](https://lasp.colorado.edu/space-weather-portal/) for viewing observations from the Sun to Earth
- [pyspaceweather](https://github.com/st-bender/pyspaceweather) and [pysatSpaceWeather](https://github.com/pysat/pysatSpaceWeather) for space weather indices in Python
- [SpaceIndices.jl](https://github.com/JuliaSpace/SpaceIndices.jl) for Celestrak, JB2008 and Hpo indices
- [GOES-R Space Weather Examples](https://cires-stp.github.io/goesr-spwx-examples/index.html)
