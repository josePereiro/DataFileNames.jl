# -------------------------------------------------------------------------------------
_tryparse(T, v) = tryparse(T, v)
_tryparse(::Type{String}, v) = string(v)

_parse_key(k) = string(k)
function _parse_val(v::AbstractString)
    for T in _OUTPUT_VAL_TYPES
        r = _tryparse(T, v)
        !isnothing(r) && return r
    end
    return string(v)
end

function _parse_pair(p::AbstractString)
    k, v = split(p, _SEPS[:PAIR_SEP])
    return (_parse_key(k) => _parse_val(v))
end

# -------------------------------------------------------------------------------------
function isvalid_dfname(dfn::String)
    dfn = basename(dfn)
    m = _parse_regex(dfn)
    isempty(m.digest)
end

# -------------------------------------------------------------------------------------
function parse_dfname(dfn::String)
    dfn = basename(dfn)
    head_str, params_str, ext_str, digest = _parse_regex(dfn)
    !isempty(digest) && error("Invalid name '", dfn, "'. Digest: '", digest, "'")
    
    keepempty = false
    head_split = split(head_str, _SEPS[:ELEMT_SEP]; keepempty) .|> string
    params_split = split(params_str, _SEPS[:ELEMT_SEP]; keepempty) .|> string
    
    return (;
        head = _parse_val.(head_split),
        params = Dict{String, Any}(_parse_pair.(params_split)...),
        ext = string(ext_str)
    )
end

tryparse_dfname(dfn::String) = try; parse_dfname(dfn); catch nothing end

