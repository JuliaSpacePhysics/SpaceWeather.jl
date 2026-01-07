module SpaceWeather

using Dates
using Downloads
using DelimitedFiles, CSV
using DataFrames
using AxisKeys
using NCDatasets

# Core utilities
include("utils.jl")

# Data sources
include("celestrak.jl")
include("goesr.jl")
include("accessors.jl")

export celestrak
export goesr_xrs

# High-level accessors
export Kp, Ap
export xrsa, xrsb

end
