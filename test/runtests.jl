using SpaceWeather
using SpaceDataModel: localize
using SpaceWeather.GFZ: IndexFile, _stale_archive
using SpaceDataModel.Testing: test_dataset
using Test
using Aqua
using Dates

@testset "Aqua" begin
    Aqua.test_all(SpaceWeather)
end

@testset "GFZ indices" begin
    # May 2024 "Gannon" storm: Kp reached 9 on May 10–11
    k = Kp("2024-05-10", "2024-05-12")
    @test times(k) == DateTime(2024, 5, 10):Hour(3):DateTime(2024, 5, 11, 21) && maximum(k) == 9
    test_dataset(GFZ.KP, "Kp", DateTime(2024, 5, 10), DateTime(2024, 5, 12); empty = (DateTime(1900), DateTime(1901)))
    @test startswith(getmeta(GFZ.KP)["header"], "PURPOSE:")
    # Availability is per variable: F10.7 starts in 1947, Ap in 1932
    @test isempty(available(F107, "1932-01-01", "1932-01-02")) && !isempty(available(Ap, "1932-01-01", "1932-01-02"))

    # The nowcast file continues the archive on its grid
    t = times(Kp(now(UTC) - Day(40), now(UTC)))
    @test all(==(Hour(3)), diff(t)) && t[end] > now(UTC) - Day(1)
    @test all(==(Minute(30)), diff(times(Hp30(now(UTC) - Day(2), now(UTC)))))
end

@testset "IndexFile splicing and refresh" begin
    mktempdir() do dir
        withenv("SPACE_DATA_DIR" => joinpath(dir, "cache")) do
            row(t, kp; d = 0) = "$(year(t)) $(month(t)) $(day(t)) $(hour(t)) 0 0 0 $kp $(kp == -1 ? -1 : 2) $d"
            archive, recent = joinpath(dir, "archive.txt"), joinpath(dir, "recent.txt")
            start = floor(now(UTC), Day) - Day(1)
            old = DateTime(2020)  # far outside the revision window
            write(recent, join([row(start, 2), row(start + Hour(3), -1)], "\n"))  # -1: unpublished padding
            ds = IndexFile("fixture", "file://$archive", GFZ.KP.parse; recent = "file://$recent", variables = GFZ.KP.variables)
            kp(t0, t1; kw...) = parent(ds["Kp"](t0, t1; kw...))
            @test kp(start, start + Day(1)) == [2]  # archive never fetched
            write(archive, join([row(old, 1), row(start - Hour(3), 1), row(start, 1)], "\n"))
            @test kp(start - Hour(3), start + Day(1)) == [1, 2]  # recent wins the overlap

            # Old rows refresh only while preliminary, and at most weekly
            stale(age) = _stale_archive(ds, localize(ds.url), old, old + Hour(3), now(UTC) - age)
            @test stale(Day(8)) && !stale(Day(1))
            write(archive, row(old, 5; d = 1))
            @test kp(old, old + Hour(3); update = true) == [5]
            @test !stale(Day(8))
        end
    end
end

@testset "GOES-R data" begin
    using SpaceWeather.GOES
    @test_throws ArgumentError MAG[id = 15]

    # A midnight endpoint is exclusive
    @test length(getdata(MAG[]["b_total"], Date(2020, 6, 1), Date(2020, 6, 2))) == 1440
    @test length(getdata(MAG[id = 16]["b_total"], Date(2020, 6, 1), Date(2020, 6, 3))) == 2880
end
