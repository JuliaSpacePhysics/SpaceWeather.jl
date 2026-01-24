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
