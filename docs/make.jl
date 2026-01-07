using SpaceWeather
using Documenter

DocMeta.setdocmeta!(SpaceWeather, :DocTestSetup, :(using SpaceWeather); recursive = true)

makedocs(;
    modules = [SpaceWeather],
    authors = "Beforerr <zzj956959688@gmail.com> and contributors",
    sitename = "SpaceWeather.jl",
    format = Documenter.HTML(;
        canonical = "https://JuliaSpacePhysics.github.io/SpaceWeather.jl",
    ),
    pages = [
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo = "github.com/JuliaSpacePhysics/SpaceWeather.jl",
)
