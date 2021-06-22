# -------------------------------------------------------------------------------------
_isext_str(s::String) = startswith(s, _SEPS[:EXT_SEP])
_ispair_str(s::String) = count(_SEPS[:PAIR_SEP], s) == 1
_istext_str(s::String) = !_isext_str(s) && !_ispair_str(s)

# -------------------------------------------------------------------------------------
function _hasparams(dfn::String)
    lsep = findall(dfn, _SEPS[:PARAMS_LSEP])
    rsep = findall(dfn, _SEPS[:PARAMS_LSEP])
    
    isempty(lsep) && return false
    isempty(rsep) && return false
end

# -------------------------------------------------------------------------------------
_tryparse(T, v) = tryparse(T, v)
_tryparse(::Type{String}, v) = string(v)

_parse_key(k) = string(k)
function _parse_val(v)
    for T in OUTPUT_VAL_TYPES
        r = _tryparse(T, v)
        !isnothing(r) && return r
    end
    return string(v)
end

function _parse_pair(p)
    k, v = split(p, _SEP[:PAIR_SEP])
    return (_parse_key(k) => _parse_val(v))
end


function _parse_elem(el)
    el = string(el)
    if _ispair_str(el)
        return _parse_pair(el)
    elseif _isext_str(el)
        return el
    else
        return _parse_val(el)
    end
end

# -------------------------------------------------------------------------------------
function _regex_parse(fname::String)

    # escape 
    ESC_SEPS = _hex_scaped_seps()
    hex_plsep = ESC_SEPS[:PARAMS_LSEP]
    hex_prsep = ESC_SEPS[:PARAMS_RSEP]
    hex_elsep = ESC_SEPS[:ELEMT_SEP]
    hex_psep = ESC_SEPS[:PAIR_SEP]
    hex_extsep = ESC_SEPS[:EXT_SEP]

    # inval_chars
    inval_chars = [hex_plsep, hex_prsep, hex_elsep, hex_psep]
    inval_char_rstr = "[^$(join(inval_chars))]"

    # head
    head_rstr = 
        string(
            "^(?<head>",
                "(?:",
                    "$(inval_char_rstr)+(?:$(hex_elsep)|\$|$(hex_extsep))", 
                ")*",
            ")?"
        )
    
    # params
    params_rstr = 
        string(
            "(?<params>", 
                "$(hex_plsep)",
                    "(?:", 
                        "(?:$(inval_char_rstr)+$(hex_psep)$(inval_char_rstr)+$(hex_elsep))?",
                        "(?:$(inval_char_rstr)+$(hex_psep)$(inval_char_rstr)+)", 
                    ")?",
                "$(hex_prsep)",
            ")?"
        )

    # ext
    ext_rstr = "(?<ext>$(hex_extsep)$(inval_char_rstr)*)?\$"

    # dfname regex
    dfname_rstr = string("(?<dfname>", head_rstr, params_rstr, ext_rstr, ")")
    # dfname_rstr = string("(?<dfname>", head_rstr, ")")
    dfname_r = Regex(dfname_rstr)

    # matchs
    m = match(dfname_r, fname)

    _get(m, gk) = haskey(m, gk) ? m[gk] : ""
    _get(m::Nothing, gk) = ""
    return (;
        head = _get(m, :head), 
        params = _get(m, :params),
        ext = _get(m, :ext), 
        dfname = _get(m, :dfname),    
    )
end

# -------------------------------------------------------------------------------------
function isvalidname(dfn::String)
    m = _regex_parse(dfn)
    m.dfname == dfn
end
