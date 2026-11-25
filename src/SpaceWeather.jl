module SpaceWeather

using Dates
using NCDatasets: nomissing
export nomissing
using SpaceDataModel: getdata, getmeta, available, times, coords, units

include("utils.jl")
include("gfz.jl"); using .GFZ: GFZ
include("goesr.jl"); using .GOES

export getdata, getmeta, available, times, coords, units
export GFZ, GOES
export Kp, ap, Ap, SN, F107, F107adj, Hp30, ap30, Hp60, ap60

const Kp = GFZ.KP["Kp"]
const ap = GFZ.KP["ap"]
const Ap = GFZ.DAILY["Ap"]
const SN = GFZ.DAILY["SN"]
const F107 = GFZ.DAILY["F10.7obs"]
const F107adj = GFZ.DAILY["F10.7adj"]
const Hp30 = GFZ.HP30["Hp30"]
const ap30 = GFZ.HP30["ap30"]
const Hp60 = GFZ.HP60["Hp60"]
const ap60 = GFZ.HP60["ap60"]

end
