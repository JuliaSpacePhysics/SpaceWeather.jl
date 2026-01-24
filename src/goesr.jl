"""

    Geostationary Operational Environmental Satellites

- R Series | NOAA/NASA: https://www.goes-r.gov/
- Data Source: https://data.ngdc.noaa.gov/platforms/solar-space-observing-satellites/goes/
- Documentation: https://www.ngdc.noaa.gov/stp/satellite/goes-r.html
- Catalog: https://catalog.data.gov/dataset/geostationary-operational-environmental-satellite-r-series-goes-r-space-environment-in-situ-sui2
- SEISS Documentation: https://www.ncei.noaa.gov/products/goes-r-space-environment-in-situ
"""
module GOES
using SpaceDataModel: Registry, Dataset, Archive, FilePattern
using Dates
using NCDatasets: NCDataset
export MPSH, XRS, SGPS, MAG

const GOESR_BASE_URL = "https://data.ngdc.noaa.gov/platforms/solar-space-observing-satellites/goes"
const GOES_IDS = (16, 17, 18, 19)

# Every L2 product shares one layout. The instrument abbreviation repeats in the directory and the
# file name, some directories carry a `_science` suffix, and MAG alone is named `dn_` not `sci_`.
const GOES_URL = FilePattern("$GOESR_BASE_URL/goes{id}/l2/data/{stem}-l2-{datatype}{dirsuffix}/{t:yyyy}/{t:mm}/{prefix}_{stem}-l2-{datatype}_g{id}_d{t:yyyymmdd}_v{version}.nc")

function _read(files, t0, t1)
    ds = NCDataset(files, aggdim = "time")
    t = ds["time"][:]
    return view(ds; time = searchsortedfirst(t, t0):(searchsortedfirst(t, t1) - 1))
end

function _goes(name, stem, datatypes; prefix = "sci", dirsuffix = "")
    url = GOES_URL(; stem, prefix, dirsuffix)
    source = Archive(url, _read)
    ds = Dataset(name, source; selectors = (; id = GOES_IDS, datatype = datatypes))
    return Registry(name, [ds]; defaults = (; id = 16, datatype = first(datatypes)))
end

"""Solar and Galactic Proton Sensor (SGPS)"""
const SGPS = _goes("SGPS", "sgps", ("avg1m", "avg5m"))
"""Magnetospheric Particle Sensor High (MPS-HI)"""
const MPSH = _goes("MPSH", "mpsh", ("avg1m", "avg5m"); dirsuffix = "_science")
"""
X-Ray Sensor (XRS)
- [GOES X-ray plots](https://www.swpc.noaa.gov/products/goes-x-ray-flux)

```julia
getdata(XRS[id = 16], Date(2020, 6, 1), Date(2020, 6, 3))["xrsa_flux"]
```
"""
const XRS = _goes("XRS", "xrsf", ("avg1m", "flx1s"); dirsuffix = "_science")
"""Magnetometer (MAG)"""
const MAG = _goes("MAG", "magn", ("avg1m", "hires"); prefix = "dn")

end
