using Test
using EmpEconGrowthReplication

@testset "EmpEconGrowthReplication" begin
    @test isdefined(EmpEconGrowthReplication, :run_all)

    @test isdefined(EmpEconGrowthReplication, :simulate_baseline)
    @test isdefined(EmpEconGrowthReplication, :simulate_undershooting)
    @test isdefined(EmpEconGrowthReplication, :make_figures_1_to_5)

    @test EmpEconGrowthReplication.bisect_root(x -> x^2 - 4, 0, 5) ≈ 2 atol=1e-6
end