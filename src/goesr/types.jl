struct GoesInstrument{F}
    name::String
    _url_pattern::F
end

function (ins::GoesInstrument)(id, date; kw...)
    url = ins._url_pattern(id, date; kw...)
    file = _download_geos_file(url)
    return NCDataset(file)
end

function (ins::GoesInstrument)(id, t0, t1; kw...)
    dt = Day(1)
    dates = Date(floor(t0, dt)):dt:Date(ceil(t1, dt))
    files = _download_geos_file.(ins._url_pattern.(id, dates; kw...))
    return NCDataset(files, aggdim = "time")
end

struct GoesUrlPattern{F}
    base::F
end

function (p::GoesUrlPattern)(id, date; kw...)
    s = joinpath(GOESR_BASE_URL, "goes$(id)", p.base(id; kw...))
    year = string(Dates.year(date))
    month = lpad(Dates.month(date), 2, '0')
    day = lpad(Dates.day(date), 2, '0')
    datestr = "$(year)$(month)$(day)"
    return replace(
        s,
        "{Y}" => year,
        "{M}" => month,
        "{D}" => day,
        "{YMD}" => datestr,
    )
end
