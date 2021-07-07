module DataFileNames

    import Printf: @sprintf

    export dfname
    export parse_dfname, tryparse_dfname, isvalid_dfname

    include("utils.jl")
    include("globals.jl")
    include("dfname.jl")
    include("parse_regex.jl")
    include("parse_dfname.jl")

    VERSION < v"1.6" && include("compat.jl")

    function __init__()
        _set_default_SEPS!()
        _set_regexs!()
    end
end