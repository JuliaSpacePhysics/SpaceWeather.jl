const DATA_DIR = Ref{String}("")

"""
    datadir()

Return the default data directory for cached space weather files.
"""
function datadir()
    if isempty(DATA_DIR[])
        DATA_DIR[] = joinpath(first(DEPOT_PATH), "spaceweather")
    end
    mkpath(DATA_DIR[])
    return DATA_DIR[]
end

# Download a file from `url` to `dest` if it doesn't exist or is older than `min_age`.
function download_file(url, dest; update = false, min_age = Hour(3))
    needs_download = !isfile(dest)
    if !needs_download && update
        file_age = now() - unix2datetime(mtime(dest))
        needs_download = file_age > min_age
    end
    if needs_download
        mkpath(dirname(dest))
        Downloads.download(url, dest)
    end
    return dest
end


function _cfvar2keyedarray(var)
    ds = NCDatasets.dataset(var)
    dnames = NCDatasets.dimnames(var)
    nda = NamedDimsArray{Symbol.(dnames)}(Array(var))
    varnames = NCDatasets.varnames(ds)
    keys = ntuple(ndims(var)) do i
        name = dnames[i]
        name in varnames ? nomissing(Array(ds[name])) : axes(nda, i)
    end
    return KeyedArray(nda, keys)
end
