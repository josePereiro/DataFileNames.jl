using DataFileNames
import DataFileNames: parse_arg
const DFN = DataFileNames
using Random
using Test

@testset "DataFileNames.jl" begin

    # ------------------------------------------
    # Use default SEPS (mainly because ext sepataror)
    DFN._set_default_SEPS!()
    
    # ------------------------------------------
    @info("Testing _hex_escape")
    for i in 1:100
        str = randstring(rand(5:10))
        r = Regex(join(DFN._hex_escape(str)))
        @test occursin(r, str)
    end
    println()

    # ------------------------------------------
    @info("Testing 'dfname' produces 'isvalid_dfname' names")

    for fn in [
        dfname("dat"), 
        dfname("dat", "test"), 
        dfname("dat", ".png"), 
        dfname("dat", ".gz.tar"), 
        dfname((;A = rand())), 
        dfname((;A = rand()), "png"), 
        dfname("dat", "dyn", (;ϵ = rand(), B = "main")), 
        dfname("dat", (;A = :v1), "png"), 
        dfname(["dir1", "dir2"], "dat", (;A = :v1), "png")
    ]
        isvalid = DFN.isvalid_dfname(fn)
        @info("Testing", fn, isvalid)
        @test isvalid
    end
    @test dfname() == ""
    @test dfname("") == ""
    println()

    # ------------------------------------------
    #  Test dfname
    @info("Testing dfname")
    @test dfname("dat") == "dat"
    @test dfname("dat") == dfname(:dat)

    @test dfname("dat", ".ext") != dfname("dat", "ext")
    @test dfname("dat", ".") == "dat."
    
    @test dfname("", "dat") == "dat"
    @test dfname("dat", "") == "dat"
    
    @test dfname("dat", (;A = 1)) == dfname("dat", :A => 1)
    @test dfname("dat", (;A = 1)) == dfname("dat", Dict(:A => 1))
    @test dfname("dat", "", (;A = 1)) == dfname("dat", (;A = 1))
    @test dfname("dat", (;A = 1), "") == dfname("dat", (;A = 1))
    @test dfname("dat", (;A = 1), ".ext") == dfname("dat", (;A = 1), "ext")

    @test basename(dfname(["dir"], "dat")) == "dat"
    @test dirname(dfname(["dir"], "dat")) == 
        dirname(joinpath("dir", "dat"))
    @test dirname(dfname(["dir1", "dir2"], "dat")) == 
        dirname(joinpath("dir1", "dir2", "dat"))
    println()

    # ------------------------------------------
    # Custom Type
    @info("Custom type")
    struct Foo
        f::Float64
        i::Int
        s::String
    end
    foo = Foo(1.0, 1, "hi")
    
    DFN.parse_arg(f::Foo) = (;f.f, f.i, f.s)
    @test dfname(foo) == dfname(parse_arg(foo))
    @test dfname("bla", foo) == dfname("bla", parse_arg(foo))
    println()

    # ------------------------------------------
    # Parsing
    @info("Testing parse_dfname")
    let
        head = "dat"
        ext = ".jls"
        fname = dfname(head, ext)
        par_head, par_params, par_ext = DFN.parse_dfname(fname)
        @test head in par_head
        @test ext == par_ext
    end

    for it in 1:100
        head = [rand(-5:10), "Hello", rand()]
        params = (;S = "string", F = rand(), I = rand(-10:10))
        ext = ".ext"
        fname = dfname(head..., params, ext)
        par_head, par_params, par_ext = DFN.parse_dfname(fname)

        _isapprox(s1::String, s2::String) = (s1 == s2)
        _isapprox(v1, v2; atol = 1e-2) = isapprox(v1, v2; atol)
        
        @test length(head) == length(par_head)
        @test length(params) == length(par_params)

        @test all(_isapprox.(head, par_head))
        for (k, param) in pairs(params)
            kstr = string(k)
            @test haskey(par_params, kstr)
            par_param = par_params[kstr]
            @test all(_isapprox.(param, par_param))
        end
        @test length(par_ext) == length(ext) ?
            par_ext == ext : endswith(par_ext, ext)

        @test dfname(head..., params, ext) == dfname(par_head..., par_params, par_ext)
    end
    println()

    # ------------------------------------------
    # Create file
    @info("Testing creating a file")
    let
        file = dfname([tempdir()], "dat", (;I = rand(Int), F = rand()), "jls")
        @assert !isfile(file)
        @show file
        touch(file)
        @test isfile(file)
    end
    

end
