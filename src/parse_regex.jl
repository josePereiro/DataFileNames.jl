

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
    val_char_rstr = "[^$(join(inval_chars))]"
    noextsep_char_rstr = "[^$(join([inval_chars; hex_extsep]))]"

    # ------------------------------------------------------------
    # EXT
    ext_rstr = string(
        "(?<extstr>",
            "$(hex_extsep)$(noextsep_char_rstr)*\$",
        ")",
    )
    _REGEXS[:EXT_SPLIT_REGEX] = Regex(ext_rstr)
    
    # ------------------------------------------------------------
    # HEAD # IMPORTANT!!! it assumes the extension is being removed
    head_rstr = string(
        "^",
        "(?<headstr>", 
            "(?:", 
                "$(val_char_rstr)+", 
                "(?:$(hex_elsep)|\$)", 
            ")*", 
        ")", 
    )
    _REGEXS[:HEAD_SPLIT_REGEX] = Regex(head_rstr)
    
    # ------------------------------------------------------------
     # PARAMS # IMPORTANT!!! it assumes the extension is being removed
     params_rstr = string(
        "$(hex_plsep)",
            "(?<paramstr>", 
                "(?:$(val_char_rstr)+$(hex_psep)$(val_char_rstr)+$(hex_elsep)?)+",
            ")",
        "$(hex_prsep)", 
        "\$"
    )
    _REGEXS[:PARAMS_SPLIT_REGEX] = Regex(params_rstr)

end



# -------------------------------------------------------------------------------------
function _parse_regex(fname::String)
    _check__SEPS()
    _set_regexs!()

    _get(m, gk) = haskey(m, gk) ? m[gk] : ""
    _get(m::Nothing, gk) = ""
    
    # remove ext
    ext_r = _REGEXS[:EXT_SPLIT_REGEX]
    m = match(ext_r, fname)
    extstr = _get(m, :extstr)
    fname = replace(fname, ext_r => "")
    
    # remove head
    head_r = _REGEXS[:HEAD_SPLIT_REGEX]
    m = match(head_r, fname)
    headstr = _get(m, :headstr)
    fname = replace(fname, head_r => "")
    
    # remove param body
    param_r = _REGEXS[:PARAMS_SPLIT_REGEX]
    m = match(param_r, fname)
    paramsstr = _get(m, :paramstr)
    fname = replace(fname, param_r => "")
    
    digest = fname
    return (;headstr, paramsstr, extstr, digest)
end

