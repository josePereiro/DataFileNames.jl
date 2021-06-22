# -------------------------------------------------------------------------------------
# _SEPS
const _SEPS = Dict{Symbol, Char}()

function _set_default__SEPS!()
    empty!(_SEPS)
    _SEPS[:EXT_SEP] = '.'
    _SEPS[:PAIR_SEP] = '='
    _SEPS[:ELEMT_SEP] = ' '
    _SEPS[:PARAMS_LSEP] = '['
    _SEPS[:PARAMS_RSEP] = ']'
    _SEPS[:SEP_SUBST] = '_'
    _check__SEPS()
    return _SEPS
end

function _check__SEPS()
    isempty(_SEPS) && error("_SEPS is empty")
    !allunique(values(_SEPS)) && error("_SEPS are not unique. Current _SEPS ", _SEPS)
    return _SEPS
end

function _hex_scaped_seps()
    ks = keys(_SEPS)
    escs = _hex_escape(join([_SEPS[k] for k in ks]))
    Dict{Symbol, String}(k => esc for (k, esc) in zip(ks, escs))
end

# -------------------------------------------------------------------------------------
# INPUT TYPES
const INPUT_KEY_TYPES = [Symbol, String]
const INPUT_VAL_TYPES = [Symbol, Bool, String, Int, Float64]
const INPUT_PAIRS_TYPES = [Pair, Dict, NamedTuple]

_iskeyT(k) = any(isa.([k], INPUT_KEY_TYPES))
_isvalT(v) = any(isa.([v], INPUT_VAL_TYPES))
_ispairT(p) = any(isa.([p], INPUT_PAIRS_TYPES))

function _checker(v, isfun, name, types)
    !isfun(v) && 
        error("Invalid input ", name, " type, got ", v , "::",  typeof(v), 
            ", expected a type from [", join(types, ", "), "]"
        )
    return v
end

_check_keyT(k) = _checker(k, _iskeyT, "key", INPUT_KEY_TYPES)
_check_valT(v) = _checker(v, _isvalT, "value", INPUT_VAL_TYPES)
_check_pairT(p) = _checker(p, _ispairT, "key:value structure", INPUT_PAIRS_TYPES)

# -------------------------------------------------------------------------------------
# String validity
const _VALUE_INVALIDATORS = Char[]

function _set_default_desallowed_chars!()
    empty!(_VALUE_INVALIDATORS)
    push!(_VALUE_INVALIDATORS, 
        (_SEPS[S] for S in [:ELEMT_SEP, :PAIR_SEP, :PARAMS_LSEP, :PARAMS_RSEP])...
    )
    _VALUE_INVALIDATORS
end

function _check_str(str::String)
    any(contains.(str, _VALUE_INVALIDATORS)) && 
    error("Separator detected at '$str'. Reserved _SEPS $_VALUE_INVALIDATORS")
    return str
end

# -------------------------------------------------------------------------------------
const OUTPUT_VAL_TYPES = [Int, Float64, Bool, String] # String must be the last, it is the fallback


