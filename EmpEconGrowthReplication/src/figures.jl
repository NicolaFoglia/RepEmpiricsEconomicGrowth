using CSV
using DataFrames
using Plots
using Statistics
using ReadStatTables

function make_figures_1_to_5()
    println("Creating Figures 1–5")

    make_figure_1()
    make_figure_2()
    make_figure_3()
    make_figure_4()
    make_figure_5()

    println("Figures created")
end

function read_dta(path)
    return DataFrame(readstat(path))
end


function add_growth_vars!(df)
    sort!(df, [:id_c, :year])

    df.Y = df.Y_U .+ df.Y_S
    df.y_pc = df.Y ./ df.N
    df.lny_pc = log.(df.y_pc)
    df.lnN = log.(df.N)

    df.growth_pc_pa = Vector{Union{Missing, Float64}}(missing, nrow(df))
    df.popgrowth = Vector{Union{Missing, Float64}}(missing, nrow(df))
    df.k = Vector{Union{Missing, Float64}}(missing, nrow(df))
    df.dk = Vector{Union{Missing, Float64}}(missing, nrow(df))
    df.das = Vector{Union{Missing, Float64}}(missing, nrow(df))

    for sub in groupby(df, :id_c)
        idx = parentindices(sub)[1]

        df.growth_pc_pa[idx] =
            [missing; exp.(diff(log.(sub.y_pc)) ./ 20) .- 1]

        df.popgrowth[idx] =
            [missing; exp.(diff(log.(sub.N)) ./ 20) .- 1]

        ktemp = Vector{Union{Missing, Float64}}(missing, nrow(sub))
        ktemp[2:end] = log.(sub.K[2:end]) .- log.(sub.L[1:end-1])
        df.k[idx] = ktemp

        dktemp = Vector{Union{Missing, Float64}}(missing, nrow(sub))
        for i in 3:nrow(sub)
            dktemp[i] = exp((ktemp[i] - ktemp[i-1]) / 20) - 1
        end
        df.dk[idx] = dktemp

        df.das[idx] =
            [missing;
             (((sub.A_S[2:end] .^ 0.33 .- sub.A_S[1:end-1] .^ 0.33) ./
               (sub.A_S[1:end-1] .^ 0.33) .+ 1) .^ 0.05) .- 1]
    end

    return df
end

# Figure 1

function make_figure_1()
    println("Creating Figure 1")

    df = CSV.read("output/ysft_data_full_20_years.csv", DataFrame)
    add_growth_vars!(df)

    d = filter(row -> row.id_c == 13 && row.year >= 1820 && row.year <= 2020, df)

    p1 = plot(d.year, d.growth_pc_pa,
        label = "Output p.c. Growth",
        xlabel = "Year",
        ylabel = "Growth Rate (p.a.)",
        legend = :topleft
    )

    plot!(p1, d.year, d.popgrowth,
        label = "Population Growth"
    )

    savefig(p1, "images/Figure_1a.png")
    savefig(p1, "images/Figure_1a.pdf")


    p2 = plot(d.year, d.growth_pc_pa,
        label = "Output p.c. Growth",
        xlabel = "Year",
        ylabel = "",
        legend = :topleft
    )

    plot!(p2, d.year, d.dk,
        label = "Growth in log Capital p.c."
    )

    plot!(p2, d.year, d.popgrowth,
        label = "Population Growth"
    )

    plot!(p2, d.year, d.das,
        label = "Productivity Growth (skilled)"
    )

    p2_right = twinx()

    plot!(p2_right, d.year, d.e,
        label = "Education",
        ylabel = "Education (e)",
        legend = :topright,
        color = :black,
        linewidth = 2
    )

    savefig(p2, "images/Figure_1b.png")
    savefig(p2, "images/Figure_1b.pdf")
end

# Figure 2

function make_figure_2()
    println("Creating Figure 2")

    sim = CSV.read("output/ysft_data_full_20_years.csv", DataFrame)
    add_growth_vars!(sim)

    sim = filter(row -> row.id_c == 13 && row.year >= 1700 && row.year <= 2020, sim)

    mpd = read_dta("data/mpd2020.dta")
    mpd = filter(row -> row.countrycode == "GBR" && row.year >= 1700, mpd)
    mpd.year = ifelse.(mpd.year .== 2018, 2020, Int.(mpd.year))
    years = collect(1700:20:2020)
    mpd = filter(row -> row.year in years, mpd)

    sort!(mpd, :year)

    mpd.gdppc_growth =
        [missing; ((mpd.gdppc[2:end] ./ mpd.gdppc[1:end-1]) .^ (1 / 20) .- 1) .* 100]

    mpd.pop_growth =
        [missing; ((mpd.pop[2:end] ./ mpd.pop[1:end-1]) .^ (1 / 20) .- 1) .* 100]

    d = leftjoin(sim, mpd[:, [:year, :gdppc_growth, :pop_growth]], on = :year)
    sort!(d, :year)

    p1 = plot(d.year, d.g_y,
        label = "Model",
        xlabel = "Year",
        ylabel = "Growth Rate (p.a.)",
        legend = :topright
    )

    plot!(p1, d.year, d.gdppc_growth,
        label = "Data",
        linestyle = :dash
    )

    hline!(p1, [0], label = "", color = :black, linestyle = :dash)

    savefig(p1, "images/Figure_2a.png")
    savefig(p1, "images/Figure_2a.pdf")


    p2 = plot(d.year, d.g_N,
        label = "Model",
        xlabel = "Year",
        ylabel = "Growth Rate (p.a.)",
        legend = :topright
    )

    plot!(p2, d.year, d.pop_growth,
        label = "Data",
        linestyle = :dash
    )

    hline!(p2, [0], label = "", color = :black, linestyle = :dash)

    savefig(p2, "images/Figure_2b.png")
    savefig(p2, "images/Figure_2b.pdf")
end

# Figure 3

function make_figure_3()
    println("Creating Figure 3")

    sim = CSV.read("output/ysft_data_full_20_years.csv", DataFrame)
    add_growth_vars!(sim)

    sim = filter(row -> row.id_c == 13 && row.year >= 1700 && row.year <= 2020, sim)

    y1700 = sim.y_pc[sim.year .== 1700][1]
    sim.y_pc_norm = sim.y_pc ./ y1700
    sim.N_norm = sim.N ./ sim.N[sim.year .== 1700][1]

    mpd = read_dta("data/mpd2020.dta")
    mpd = filter(row -> row.countrycode == "GBR" && row.year >= 1500 && row.year <= 2020, mpd)
    mpd.year = ifelse.(mpd.year .== 2018, 2020, Int.(mpd.year))
    gdppc1700 = mpd.gdppc[mpd.year .== 1700][1]
    pop1700 = mpd.pop[mpd.year .== 1700][1]

    mpd.gdppc_norm = mpd.gdppc ./ gdppc1700
    mpd.pop_norm = mpd.pop ./ pop1700

    p1 = plot(sim.year, sim.y_pc_norm,
        label = "GDP p.c. (1700=1, model)",
        xlabel = "Year",
        legend = :topleft
    )

    plot!(p1, mpd.year, mpd.gdppc_norm,
        label = "GDP p.c. (1700=1, data)",
        linestyle = :dash
    )

    savefig(p1, "images/Figure_3a.png")
    savefig(p1, "images/Figure_3a.pdf")


    p2 = plot(sim.year, sim.N_norm,
        label = "Population (1700=1, model)",
        xlabel = "Year",
        legend = :topleft
    )

    plot!(p2, mpd.year, mpd.pop_norm,
        label = "Population (1700=1, data)",
        linestyle = :dash
    )

    savefig(p2, "images/Figure_3b.png")
    savefig(p2, "images/Figure_3b.pdf")
end

# Figure 4

function make_figure_4()
    println("Creating Figure 4")

    sim = CSV.read("output/ysft_data_full_20_years_undershooting.csv", DataFrame)
    add_growth_vars!(sim)

    sim = filter(row -> row.id_c == 13 && row.year >= 1700 && row.year <= 2020, sim)

    sim.N_norm = sim.N ./ sim.N[sim.year .== 1700][1]

    mpd = read_dta("data/mpd2020.dta")
    mpd = filter(row -> row.countrycode == "GBR" && row.year >= 1500 && row.year <= 2020, mpd)
    mpd.year = ifelse.(mpd.year .== 2018, 2020, Int.(mpd.year))
    pop1700 = mpd.pop[mpd.year .== 1700][1]
    mpd.pop_norm = mpd.pop ./ pop1700

    p1 = plot(sim.year, sim.N_norm,
        label = "Population (1700=1, model)",
        xlabel = "Year",
        legend = :topleft
    )

    plot!(p1, mpd.year, mpd.pop_norm,
        label = "Population (1700=1, data)",
        linestyle = :dash
    )

    savefig(p1, "images/Figure_4a.png")
    savefig(p1, "images/Figure_4a.pdf")


    d = filter(row -> row.year >= 1820 && row.year <= 2020, sim)

    p2 = plot(d.year, d.growth_pc_pa,
        label = "Output p.c. Growth",
        xlabel = "Year",
        ylabel = "Growth Rate (p.a.)",
        legend = :topleft
    )

    plot!(p2, d.year, d.popgrowth,
        label = "Population Growth"
    )

    hline!(p2, [0], label = "", color = :black, linestyle = :dash)

    savefig(p2, "images/Figure_4b.png")
    savefig(p2, "images/Figure_4b.pdf")
end

# Figure 5

function make_figure_5()
    println("Creating Figure 5")

    sim = CSV.read("output/ysft_data_full_20_years.csv", DataFrame)
    add_growth_vars!(sim)

    sim = filter(row -> row.id_c == 13 &&
                       row.year >= 1820 &&
                       row.year < 2001, sim)

    edu_min = minimum(sim.e)
    edu_max = maximum(sim.e)
    sim.edu_norm = ((sim.e .- edu_min) ./ (edu_max - edu_min)) .* 12

    lee = read_dta("data/LeeLee_LRdata.dta")
    lee = filter(row -> row.WBcode == "GBR" &&
                       row.sex == "M" &&
                       row.year >= 1820 &&
                       row.year < 2001, lee)

    lee.year = Int.(lee.year)
    lee.prima = lee.pri ./ 100 .* 4

    sort!(sim, :year)
    sort!(lee, :year)

    # FIGURE 5a 

    p1 = plot(sim.year, sim.edu_norm,
        label = "Years of Schooling (model)",
        xlabel = "Year",
        ylabel = "Years",
        legend = :topleft
    )

    lee_prima = filter(row -> row.year < 1875, lee)

    plot!(p1, lee_prima.year, lee_prima.prima,
        label = "Years of Primary Schooling (ages 15–64)",
        linestyle = :dash
    )

    plot!(p1, lee.year, lee.tyr,
        label = "Total Years of Schooling (ages 15–64)",
        linestyle = :dashdot
    )

    p1_right = twinx()

    plot!(p1_right, lee.year, lee.hca,
        label = "Human Capital Index (ages 15–64)",
        ylabel = "Human Capital Index (ages 15–64)",
        linestyle = :dot,
        color = :black
    )

    savefig(p1, "images/Figure_5a.png")
    savefig(p1, "images/Figure_5a.pdf")

    # FIGURE 5b 

    p2 = plot(lee.year, lee.pri,
        label = "Enrolment rate: Primary (males, adj.,%)",
        xlabel = "Year",
        ylabel = "Enrolment rates (%)",
        legend = (0.12, 0.85),
        linestyle = :dash
    )

    plot!(p2, lee.year, lee.sec,
        label = "Enrolment rate: Secondary (males, adj.,%)",
        linestyle = :dashdot
    )

    plot!(p2, lee.year, lee.ter,
        label = "Enrolment rate: Tertiary (males, adj.,%)",
        linestyle = :dot
    )

    p2_right = twinx()

    plot!(p2_right, sim.year, sim.e,
        label = "Education investment (model)",
        ylabel = "Education investment (model)",
        color = :black,
        linewidth = 2
    )

    savefig(p2, "images/Figure_5b.png")
    savefig(p2, "images/Figure_5b.pdf")
end