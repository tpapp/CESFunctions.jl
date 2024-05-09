using CESFunctions, Test, StaticArrays

@testset "CESProduction argument checks" begin
    @test_throws ArgumentError CESProduction(0.1, ())
    @test_throws ArgumentError CESProduction(-0.1, (1.0,))
    @test_throws ArgumentError CESProduction(0.1, (0.5,))
    @test_throws ArgumentError CESProduction(0.1, (-0.5,1.5))
end

@testset "CESProduction checks" begin
    σ = 0.3
    a1 = 0.1
    a2 = 0.9
    F = CESProduction(σ, (a1, a2))
    L1 = 0.7
    L2 = 0.8
    ρ = (σ - 1) / σ
    Y = @inferred(output_quantity(F, (L1, L2)))
    @test Y ≈ (a1 * L1^ρ + a2 * L2^ρ)^(1/ρ)
    p1 = 0.3
    p2 = 0.5
    P = @inferred(output_price(F, (p1, p2)))
    @test P ≈ (a1^σ * p1^(1-σ) + a2^σ * p2^(1-σ))^(1/(1-σ))
    @test SVector(input_demands(F, (p1, p2), Y)) ≈ SVector((P * a1 / p1)^σ * Y, (P * a2 / p2)^σ * Y)
    @test SVector(input_demands(F, (p1, p2), Y)) ==  SVector(input_demands(F, (p1, p2), Y, P))
end

using JET
@testset "static analysis with JET.jl" begin
    @test isempty(JET.get_reports(report_package(CESFunctions, target_modules=(CESFunctions,))))
end

@testset "QA with Aqua" begin
    import Aqua
    Aqua.test_all(CESFunctions; ambiguities = false)
    # testing separately, cf https://github.com/JuliaTesting/Aqua.jl/issues/77
    Aqua.test_ambiguities(CESFunctions)
end
