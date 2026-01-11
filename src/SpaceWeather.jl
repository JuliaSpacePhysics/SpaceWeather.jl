module SpaceWeather

using Dates
using Downloads
using DelimitedFiles, CSV
using URIs
using DataFrames
using AxisKeys
using NCDatasets
using NCDatasets: nomissing

# Core utilities
include("utils.jl")

# Data sources
include("celestrak.jl")
include("goesr/goesr.jl"); using .GEOS
include("accessors.jl")

export celestrak

# High-level accessors
export Kp, Ap
export xrsa, xrsb

export nomissing

end
