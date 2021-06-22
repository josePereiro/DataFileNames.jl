# -------------------------------------------------------------------------------------
_REGEXS = Dict()
function _set_regexs!()
    empty!(_REGEXS)

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
            "(?<paramgroup>", 
                "$(hex_plsep)",
                    "(?<params>", 
                        "(?:$(inval_char_rstr)+$(hex_psep)$(inval_char_rstr)+$(hex_elsep))*",
                        "(?:$(inval_char_rstr)+$(hex_psep)$(inval_char_rstr)+)+", 
                    ")",
                "$(hex_prsep)",
            ")?"
        )

    # ext
    ext_rstr = "(?<ext>$(hex_extsep)$(inval_char_rstr)*)?\$"

    # dfname regex
    dfname_rstr = string("(?<dfname>", head_rstr, params_rstr, ext_rstr, ")")
    dfname_r = Regex(dfname_rstr)

    _REGEXS[:DFNAME_REGEX] = dfname_r

end
# -------------------------------------------------------------------------------------
function _parse_regex(fname::String)
    _check__SEPS()
    
    # matchs
    _set_regexs!()
    m = match(_REGEXS[:DFNAME_REGEX], fname)

    _get(m, gk) = haskey(m, gk) ? m[gk] : ""
    _get(m::Nothing, gk) = ""
    return (;
        head = _get(m, :head), 
        params = _get(m, :params),
        ext = _get(m, :ext), 
        dfname = _get(m, :dfname)
    )
end