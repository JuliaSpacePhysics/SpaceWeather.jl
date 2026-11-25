_attrs(kv) = Dict{String, Any}(String(k) => v for (k, v) in pairs(kv))

# Indices of sorted `t` in `[t0, t1)`, the span a `getdata(x, t0, t1)` request covers.
_searchrange(t, t0, t1) = searchsortedfirst(t, t0):(searchsortedfirst(t, t1) - 1)

# Parsed files of this session: path => (mtime, parsed), replaced when the file changes.
const _PARSED = Dict{String, Tuple{Float64, Any}}()
const _PARSED_LOCK = ReentrantLock()

function _parsed(parse, path)
    m = mtime(path)
    return lock(_PARSED_LOCK) do
        cached = get(_PARSED, path, nothing)
        isnothing(cached) || first(cached) != m || return last(cached)
        parsed = parse(path)
        _PARSED[path] = (m, parsed)
        parsed
    end
end
