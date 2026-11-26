module SpaceWeather

using Dates
using CSV
using SpaceDataModel: getdata, available, localize
using DataFrames: DataFrame, dropmissing!
using AxisKeys: KeyedArray
using NCDatasets: nomissing

# Data sources
include("celestrak.jl")
include("goesr.jl"); using .GOES
include("accessors.jl")

export celestrak
export getdata, available

# High-level accessors
export Kp, Ap

export nomissing

end
