import Base

function Base.haskey(m::RegexMatch, name::Symbol)
    idx = Base.PCRE.substring_number_from_name(m.regex.regex, name)
    return idx > 0
end
Base.haskey(m::RegexMatch, name::AbstractString) = haskey(m, Symbol(name))    