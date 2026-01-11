module SpaceWeather

using Dates
using Downloads: download
using CSV
using URIs: URI
using DataFrames: DataFrame, dropmissing!
using AxisKeys: KeyedArray, NamedDimsArray
using NCDatasets: NCDatasets
using NCDatasets: nomissing

# Core utilities
include("utils.jl")

# Data sources
include("celestrak.jl")
include("goesr/goesr.jl"); using .GOES
include("accessors.jl")

export celestrak

# High-level accessors
export Kp, Ap
export xrsa, xrsb

export nomissing

end
