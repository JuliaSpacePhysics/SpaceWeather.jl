module SpaceWeather

using Dates
using CSV
using SpaceDataModel: getdata, available, localize
using DataFrames: DataFrame, dropmissing!
using AxisKeys: KeyedArray, NamedDimsArray
using NCDatasets: NCDatasets
using NCDatasets: nomissing

# Core utilities
include("utils.jl")

# Data sources
include("celestrak.jl")
include("goesr.jl"); using .GOES
include("accessors.jl")

export celestrak
export getdata, available

# High-level accessors
export Kp, Ap
export xrsa, xrsb

export nomissing

end
