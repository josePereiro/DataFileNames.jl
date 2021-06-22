# DataFileNames

[![Build Status](https://github.com/josePereiro/DataFileNames.jl/workflows/CI/badge.svg)](https://github.com/josePereiro/DataFileNames.jl/actions)

# Description

Just a package for pretty naming data files.
It was inspired on [DrWatson](https://github.com/JuliaDynamics/DrWatson.jl) savename funtionality.

```julia
using DatafileNames

fname = dfname("file_desc", (;ϵ = rand(), B = "main"), "jls")
# "file_desc [B=main ϵ=1.96e-01].jls"
```

WIP...
