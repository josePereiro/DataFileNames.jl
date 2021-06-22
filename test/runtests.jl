using DataFileNames
const DFN = DataFileNames
using Random
using Test

@testset "DataFileNames.jl" begin

    # ------------------------------------------
    @info("Testing _hex_escape")
    for i in 1:Int(1e4)
        str = randstring(rand(5:10))
        r = Regex(join(DFN._hex_escape(str)))
        @test occursin(r, str)
    end

    # ------------------------------------------
    @info("Testing validity")
    fnames = [
        dfname("dat"), 
        dfname("dat", "test"), 
        dfname("dat", ".png"), 
        dfname((;A = rand())), 
        dfname((;A = rand()), "png"), 
        dfname("dat", "dyn", (;ϵ = rand(), B = "main")), 
        dfname("dat", (;A = :v1), "png"), 
    ]

    for fn in fnames
        isvalid = DFN.isvalidname(fn)
        @info("Testing", fn, isvalid)
        @test isvalid
    end
end
