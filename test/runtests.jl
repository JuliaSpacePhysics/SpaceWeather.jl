using SpaceWeather
using Test
using Aqua

@testset "SpaceWeather.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(SpaceWeather)
    end
    # Write your tests here.
end
