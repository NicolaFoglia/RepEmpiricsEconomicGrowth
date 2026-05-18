module EmpEconGrowthReplication

using CSV
using DataFrames
using ReadStatTables
using Plots
using Statistics

include("simulation.jl")
include("figures.jl")

export run_all

function run_all()
    println("Running replication up to Figure 5")

    mkpath("output")
    mkpath("images")

    simulate_baseline()
    simulate_undershooting()

    make_figures_1_to_5()

    println("Done. Figures saved in images/")
end

end