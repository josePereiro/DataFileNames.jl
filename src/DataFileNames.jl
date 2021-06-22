module DataFileNames

    import Printf: @sprintf

    export dfname
    export parse_dfname

    include("utils.jl")
    include("globals.jl")
    include("dfname.jl")
    include("parse_dfname.jl")

    VERSION < v"1.6" && include("compat.jl")

    function __init__()
        _set_default__SEPS!()
        _set_default_desallowed_chars!()
    end
end
