using SpaceWeather
using Test
using Aqua
using Dates

@testset "Code quality (Aqua.jl)" begin
    Aqua.test_all(SpaceWeather)
end

@testset "Celestrak data" begin
    data = celestrak()
    @test length(data.DATE) > 20000
    @test first(data.DATE) == Date(1957, 10, 1)

    @test length(data.Kp) == length(data.DATE) * 8
    @test length(data.Ap) == length(data.DATE) * 8

    # Test timestamps
    kp_times = data.Kp.time
    @test length(kp_times) == length(data.DATE) * 8
    @test kp_times[1] == DateTime(first(data.DATE)) + Minute(90)

    # Test individual columns (daily frequency)
    @test length(data.KP1) == length(data.DATE)
end

@testset "High-level API" begin
    t0 = DateTime(2023, 1, 1)
    t1 = DateTime(2023, 12, 31)
    result = Kp(t0, t1)
    @test length(result.time) == length(result)
end

@testset "GOES-R data" begin
    data = xrsa(16, Date(2020, 6, 1))
    @test length(data.time) == length(data)
    mag_ds = MAG(16, Date(2020, 6, 1), Date(2020, 6, 2))
    @test length(mag_ds["b_total"]) == 2880
end
