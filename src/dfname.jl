# -------------------------------------------------------------------------------------
# parse_arg
"""
This is part of the public interface.
Implement a new method for parsing a new type.
`parse_arg` must return one of the following types 
[`Symbol`, `Int`, `Float64`, `String`, `Bool`, `NamedTuple`, `Dict`]
or other type that already has an implemented `parse_arg` method.
For the case in `NamedTuple` and `Dict`, the keys and values must be 
one of the first other types.
    
# Example:
```julia
struct Foo
    x::Int
    y::String
end
parse_arg(f::Foo) = (;f.x, f.y)

foo = Foo(1, "A")
fname = dfname("my_foo", foo, ".ext")
# "my_foo [x=1 y=A].ext"
```
"""
parse_arg
parse_arg(s::Symbol) = s
parse_arg(n::Int) = n
parse_arg(f::Float64) = f
parse_arg(s::AbstractString) = string(s)
parse_arg(b::Bool) = b
parse_arg(p::Pair) = p
parse_arg(pt::NamedTuple) = pt
parse_arg(pt::Dict) = pt
parse_arg(v::Any) = error("parse_arg(v::", typeof(v), ") not implemented. Type `?parse_arg` for help.")

# -------------------------------------------------------------------------------------
# _argstr
_argstr(s::Symbol) = _check_str(string(s))
_argstr(n::Int) = _check_str(string(n))
_argstr(f::Float64) = _check_str(@sprintf("%0.2e", f))
_argstr(s::String) = _check_str(s)
_argstr(b::Bool) = _check_str(string(b))

# -------------------------------------------------------------------------------------
# dfname
function dfname(args...)
    _check__SEPS()

    head_args = []
    params_args = []

    # --------------------------------------------------------
    # collect args except last
    largi = lastindex(args)
    for argi in eachindex(args)
        argi == largi && break

        arg = args[argi]
        parg = parse_arg(arg)

        if _isvalT(parg)
            length(params_args) > 0 && 
                error(
                    "After the first key:value argument no single value is allowed (except the extension at the end). ", 
                    "Type protocole_desc() for info!"
                )
            push!(head_args, parg)
        elseif _ispairT(parg)
            push!(params_args, parg)
        else
            error("parse_arg(a::$(typeof(arg))) returns an invalid type. Use `?parse_arg` for help.")
        end
    end

    # --------------------------------------------------------
    # deal with ext
    ext = _check_str("")
    larg = last(args)
    plarg = parse_arg(larg)
    if _isvalT(plarg)
        slarg = _argstr(plarg)
        if startswith(slarg, _SEPS[:EXT_SEP])
            ext = slarg 
        elseif length(params_args) > 0
            ext = isempty(slarg) ? slarg : string(_SEPS[:EXT_SEP], slarg)
        else
            push!(head_args, slarg)
        end
    elseif _ispairT(plarg)
        push!(params_args, plarg)
    else
        error("parse_arg(a::$(typeof(larg))) returns an invalid type. Use `?parse_arg` for help.")
    end

    # --------------------------------------------------------
    # join params to check for collisions
    params_dict = Dict()
    for param_arg in params_args
        param_arg = (param_arg isa Pair) ? [param_arg] : pairs(param_arg)
        for (k, v) in param_arg
            ck = _check_keyT(k)
            cv = _check_valT(v)
            strk = _argstr(ck)
            strv = _argstr(cv)

            haskey(params_dict, strk) && 
                error("You have passed two keys that lead to the same string '", strk, "'. Collisions are not allowed")
            params_dict[strk] = strv
        end
    end

    # --------------------------------------------------------
    # build name
    body_strs = [_argstr(arg) for arg in head_args]
    params_scol = sort!(collect(params_dict); by = first)
    params_strs = [string(k, _SEPS[:PAIR_SEP], v) for (k, v) in params_scol]
    if !isempty(params_strs)
        param_str = string(
            _SEPS[:PARAMS_LSEP], 
            join(params_strs, _SEPS[:ELEMT_SEP]), 
            _SEPS[:PARAMS_RSEP]
        )
        push!(body_strs, param_str)
    end
    filter!(!isempty, body_strs)
    fname = string(join(body_strs, _SEPS[:ELEMT_SEP]), ext)
    
    # --------------------------------------------------------
    # happyness
    return fname 
end

dfname(joinp::Vector{<:AbstractString}, args...) = 
joinpath(joinp..., dfname(args...))