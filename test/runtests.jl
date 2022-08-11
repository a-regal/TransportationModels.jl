using Test

@testset "TransportationModels" begin
    include("vrp.jl")
    include("flp.jl")
    include("parser.jl")
end