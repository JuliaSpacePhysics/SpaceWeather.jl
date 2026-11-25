module GFZ
using Dates
using SpaceDataModel: SpaceDataModel, AbstractDataset, DataVariable, Product, getdata, localize, times
using ..SpaceWeather: _attrs, _parsed, _searchrange

export KP, DAILY, HP30, HP60

const BASE_URL = "https://kp.gfz.de/app/files"

# One GFZ series: the full record in a file rewritten in place, and a nowcast file `recent` of its last `RECENT`,
# which supplies those values so recent requests skip the large download.
# float measurements with NaN for missing, and `Bool` flags, false while the row's values are preliminary.
struct IndexFile{F} <: AbstractDataset
    name::String
    url::String
    recent::String
    parse::F
    metadata::Dict{String, Any}
    variables::Dict{String, Dict{String, Any}}
end

IndexFile(name, url, parse; recent, metadata = Dict(), variables = Dict()) =
    IndexFile(name, url, recent, parse, _attrs(metadata), Dict{String, Dict{String, Any}}(k => _attrs(v) for (k, v) in variables))

# Span of a nowcast file; requests ending earlier read the full series alone.
const RECENT = Day(28)
# Values within `REVISION` of a download may have been preliminary or unpublished then.
const REVISION = Day(60)

Base.keys(f::IndexFile) = sort!(collect(keys(f.variables)))
Base.getindex(f::IndexFile, key::Symbol) = f[String(key)]
function SpaceDataModel.getmeta(f::IndexFile)
    meta = copy(f.metadata)
    # The nowcast repeats the full series' `#` header and is the smaller download.
    lines = String[]
    for line in eachline(localize(f.recent))
        startswith(line, '#') || break
        text = rstrip(chopprefix(chopprefix(line, "#"), " "))
        startswith(text, "LICENSE:") && (meta["license"] = strip(chopprefix(text, "LICENSE:")))
        push!(lines, text)
    end
    while !isempty(lines) && isempty(last(lines))
        pop!(lines)
    end
    meta["header"] = join(lines, "\n")
    return meta
end
SpaceDataModel.name(f::IndexFile) = f.name
Base.show(io::IO, f::IndexFile) = print(io, f.name, " ", keys(f))

_slice(t, cols, idx) = (t[idx], Dict(k => v[idx] for (k, v) in cols))

# Whether the archive cached at `path`, downloaded at `fetched`, may hold stale values in `[t0, t1)`.
function _stale_archive(f, path, t0, t1, fetched)
    now(UTC) - fetched > Day(7) || return false
    t1 > fetched - REVISION && return true
    # Preliminary values far outside `revision`: GFZ's sunspot numbers stay preliminary months after Kp is final.
    t, cols = _parsed(f.parse, path)
    rows = _searchrange(t, t0, t1)
    return any(c -> eltype(c) == Bool && !all(view(c, rows)), values(cols))
end

function _archive_path(f, t0, t1, update)
    update === false || return localize(f.url; update)
    path = localize(f.url)
    return localize(f.url; update = fetched -> _stale_archive(f, path, t0, t1, fetched))
end

function _load(f::IndexFile, t0, t1; update)
    recent = nothing
    if t1 > now(UTC) - RECENT
        # The nowcast gains intervals as GFZ publishes them.
        path = localize(f.recent; update = update === false ? Hour(1) : update)
        rt, rc = _parsed(f.parse, path)
        if !isempty(rt)
            # GFZ pads the current day with flags and missing values for unpublished intervals.
            lastrow = something(findlast(i -> _measured(values(rc), i), eachindex(rt)), 0)
            idx = intersect(_searchrange(rt, t0, t1), 1:lastrow)
            recent = _slice(rt, rc, idx)
            t0 >= first(rt) && return recent
            t1 = min(t1, first(rt))
        end
    end
    path = _archive_path(f, t0, t1, update)
    ft, fc = _parsed(f.parse, path)
    t, cols = _slice(ft, fc, _searchrange(ft, t0, t1))
    isnothing(recent) && return t, cols
    rt, rc = recent
    return vcat(t, rt), Dict(k => vcat(v, rc[k]) for (k, v) in cols)
end

function SpaceDataModel.getdata(f::IndexFile, t0::DateTime, t1::DateTime; update = false)
    t, columns = _load(f, t0, t1; update)
    return Dict{String, DataVariable}(
        name => DataVariable(columns[name]; time = t, name, metadata = merge(f.metadata, attrs))
            for (name, attrs) in f.variables
    )
end

_measured(cols, i) = any(c -> eltype(c) <: AbstractFloat && !isnan(c[i]), cols)

function _available(vars)
    t = times(first(vars))
    return t[filter(i -> _measured(vars, i), eachindex(t))]
end

SpaceDataModel.available(f::IndexFile, t0, t1; kw...) = _available(collect(values(getdata(f, t0, t1; kw...))))
SpaceDataModel.available(p::Product{<:IndexFile}, t0, t1; kw...) = _available([getdata(p, t0, t1; kw...)])

_missing(x, fill) = x == fill ? NaN : x

# One line per interval: `YYYY MM DD hh.h hh._m days days_m index ap D`; -1 is missing.
function _parse_intervals(path, index, ap; flag = true)
    times = DateTime[]
    x = Float64[]
    a = Float64[]
    d = Bool[]
    for line in eachline(path)
        startswith(line, '#') && continue
        f = split(line)
        t = DateTime(parse(Int, f[1]), parse(Int, f[2]), parse(Int, f[3])) + Minute(round(Int, 60 * parse(Float64, f[4])))
        push!(times, t)
        push!(x, _missing(parse(Float64, f[8]), -1))
        push!(a, _missing(parse(Float64, f[9]), -1))
        push!(d, f[10] == "1")
    end
    cols = Dict{String, Vector}(index => x, ap => a)
    flag && (cols["definitive"] = d)
    return times, cols
end

# One line per UT day: `YYYY MM DD days days_m Bsr dB Kp1..Kp8 ap1..ap8 Ap SN F10.7obs F10.7adj D`.
function _parse_daily(path)
    times = DateTime[]
    cols = Dict{String, Vector}(k => Float64[] for k in ("Ap", "SN", "F10.7obs", "F10.7adj"))
    kpdef = Bool[]
    sndef = Bool[]
    for line in eachline(path)
        startswith(line, '#') && continue
        f = split(line)
        push!(times, DateTime(parse(Int, f[1]), parse(Int, f[2]), parse(Int, f[3])))
        push!(cols["Ap"], _missing(parse(Float64, f[24]), -1))
        push!(cols["SN"], _missing(parse(Float64, f[25]), -1))
        push!(cols["F10.7obs"], _missing(parse(Float64, f[26]), -1))
        push!(cols["F10.7adj"], _missing(parse(Float64, f[27]), -1))
        D = parse(Int, f[28])
        push!(kpdef, D >= 1)
        push!(sndef, D == 2)
    end
    cols["definitive"] = kpdef
    cols["SN_definitive"] = sndef
    return times, cols
end

const KP_DOI = "10.5880/Kp.0001"
const KP_SOURCE = "https://kp.gfz.de"
const F107_SOURCE = "https://www.spaceweather.gc.ca/forecast-prevision/solar-solaire/solarflux/sx-en.php"
const KP_FLAG = (; units = "1", long_name = "Kp and derived indices definitive")

const KP = IndexFile(
    "GFZ Kp", "$BASE_URL/Kp_ap_since_1932.txt", path -> _parse_intervals(path, "Kp", "ap"); recent = "$BASE_URL/Kp_ap_nowcast.txt",
    metadata = (; cadence = "PT3H", doi = KP_DOI, source = KP_SOURCE),
    variables = Dict("Kp" => (; units = "1"), "ap" => (; units = "1"), "definitive" => KP_FLAG),
)

const DAILY = IndexFile(
    "GFZ daily", "$BASE_URL/Kp_ap_Ap_SN_F107_since_1932.txt", _parse_daily; recent = "$BASE_URL/Kp_ap_Ap_SN_F107_nowcast.txt",
    metadata = (; cadence = "P1D", source = KP_SOURCE),
    variables = Dict(
        "Ap" => (; units = "1", doi = KP_DOI),
        "SN" => (; units = "1", long_name = "Daily total sunspot number", source = "https://www.sidc.be/SILSO/"),
        "F10.7obs" => (; units = "sfu", long_name = "Observed F10.7", source = F107_SOURCE),
        "F10.7adj" => (; units = "sfu", long_name = "F10.7 adjusted to 1 AU", source = F107_SOURCE),
        "definitive" => KP_FLAG,
        "SN_definitive" => (; units = "1", long_name = "Sunspot number definitive"),
    ),
)

function _hpo(n)
    index, ap = "Hp$n", "ap$n"
    return IndexFile(
        "GFZ $index", "$BASE_URL/$(index)_$(ap)_complete_series.txt", path -> _parse_intervals(path, index, ap; flag = false); recent = "$BASE_URL/$(index)_$(ap)_nowcast.txt",
        metadata = (; cadence = "PT$(n)M", doi = "10.5880/Hpo.0003", source = "https://kp.gfz.de/en/hp30-hp60"),
        variables = Dict(index => (; units = "1"), ap => (; units = "1")),
    )
end

const HP30 = _hpo(30)
const HP60 = _hpo(60)

end
