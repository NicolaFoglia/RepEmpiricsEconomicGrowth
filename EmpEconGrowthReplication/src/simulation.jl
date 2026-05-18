# bisection method to find root of function f
function bisect_root(f, a, b; tol=1e-10, maxiter=10_000)
    fa, fb = f(a), f(b)
    fa * fb > 0 && error("a and b same sign")

    for _ in 1:maxiter
        c = (a + b) / 2
        fc = f(c)

        if abs(fc) < tol || abs(b - a) < tol
            return c
        end

        if fa * fc <= 0
            b = c
            fb = fc
        else
            a = c
            fa = fc
        end
    end

    return (a + b) / 2
end

# baseline model
function simulate_baseline()
    println("Simulating baseline model")

    simulate_model(
        base = true,
        under = false,
        ext = false,
        outfile = "output/ysft_data_full_20_years.csv",
    )
end

# alternative model, just for fig.4
function simulate_undershooting()
    println("Simulating undershooting model")

    simulate_model(
        base = false,
        under = true,
        ext = false,
        outfile = "output/ysft_data_full_20_years_undershooting.csv",
    )
end

# simulation
function simulate_model(; base::Bool, under::Bool, ext::Bool, outfile::String)
    count = 114         # countries
    T = 36              # periods
    gen = 20            # jump
    init = 1680         # starting year
    at = 9              # this is used to make year 1860
    
    # calibrated parameters 
    X = 1.0              # land
    k_share = 1 / 3      # capital share
    l_share = 0.5        # labor share in unskilled sector
    n_share = 0.677      # share of income spent on fertility
    N_1_d = 8565.0       # pop in 1700
    N_at_d = 28888.0     # pop in 1860
    y_1_d = 2365.0       # gdp p.c. in 1700
    y_at_d = 4988.0      # gdp p.c. in 1860
    malthus = 0.4        # gdp p.c. Malthusian growth rate
    bgp = 1.0            # balanced growth path gdp p.c. growth rate
    beta = 1 - k_share   # labor share in skilled sector
    alpha = l_share
    
    # normalization of pop and gdp
    N_1 = N_1_d / N_1_d
    N_at = N_at_d / N_1_d
    y_1 = y_1_d / y_1_d
    y_at = y_at_d / y_1_d

    # pop growth rate 1700-1860 in the model = pop growth rate in the data
    n_root = bisect_root(x -> (1 + x) * x^(at - 2) * (N_1 - N_1 / (1 + x)) - N_at, 0.0001, 2.0)
    n_m = mean([n_root, round(n_root)])
    
    # initial conditions
    L_0 = N_1 / (1 + n_m)     # old
    L_1 = N_1 - L_0           # young
    e_1 = 0.0                 # education
    h_1 = 1 + e_1             # human capitaò
    H_1 = h_1 * L_0

    # gpd p.c. growth rate 1700-1860 in the model = gpd p.c. growth rate in the data
    g_root = bisect_root(x -> (1 + x)^(at * gen - gen) * y_1 - y_at, 0.0001, 2.0)
    g_m = mean([g_root * 100, malthus])

    # initial conditions
    phi_S = (1 + (g_m / 100))^(gen * beta / (1 - beta))              # skilled sector productivity growth
    phi_U = n_m * phi_S^((1 - beta) / (beta * (1 - alpha)))          # unskilled sector productivity growth
    A_U_1 = (L_1 / X) * (n_m / n_share)^(1 / (1 - alpha))            # unskilled productivity
    w_L_1 = (A_U_1 * X / L_1)^(1 - alpha)                            # unskilled wage
    s_0 = (1 - n_share) * w_L_1 / (phi_S^((1 - beta) / beta))        # savings
    s_1 = (1 - n_share) * w_L_1
    K_1 = s_0 * L_0                                                  # capital
    A_S_1 = (H_1 / K_1) * (w_L_1 / (beta * h_1))^(1 / (1 - beta))    # skilled productivity

    # parameters of law of motion
    gamma = n_m * (1 - beta) * (phi_S * A_S_1)^(1 - beta) / s_1^beta
    e_max = 2 * beta - 1
    sigma_S = ((1 + (bgp / 100))^(gen * beta / (1 - beta)) / phi_S - 1) / e_max   # human capital effect on skilled productivity growth
    sigma_U =                                                                     # human capital effect on unskilled productivity growth
        ((phi_S * (1 + sigma_S * e_max))^((1 - beta) / (beta * (1 - alpha))) -
         phi_U) / (phi_U * e_max)

    psi = 11.665593
    rho = 0.0

    if base
        ext = false
        under = false
    elseif under
        ext = false
    elseif ext          # not implemented for the scope of this replication 
        rho = 0.265
    else
        error("Choose one specification")
    end

    hc(e) = 1 + e       # human capital function
    educ(A, w) = 2 * beta - 1 - gamma * ((beta / (1 - beta)) / (A * w))^(1 - beta)       # education function
    
    function sav(e, A, w)
        if e <= 0
            f(x) = gamma * x^beta / ((1 - beta) * A^(1 - beta)) + x - w
            return bisect_root(f, 1e-8, 10_000.0, tol=1e-6)
        else
            return ((1 - beta) / beta) * hc(e) * w
        end
    end

    fer(e, A, w) = (1 - e) * w - sav(e, A, w)

    # storing results
    year = zeros(T, count)
    Y_U = zeros(T, count)
    Y_S = zeros(T, count)
    Y = zeros(T, count)
    y = zeros(T, count)
    theta = zeros(T, count)
    w_L = zeros(T, count)
    w_H = zeros(T, count)
    R = zeros(T, count)
    A_S = zeros(T + 1, count)
    e = zeros(T + 1, count)
    h = zeros(T + 1, count)
    A_U = zeros(T + 1, count)
    s = zeros(T, count)
    n = zeros(T, count)
    L = zeros(T + 1, count)
    N = zeros(T + 1, count)
    H = zeros(T + 1, count)
    K = zeros(T + 1, count)
    g_N = zeros(T + 1, count)
    g_y = zeros(T, count)
    id_c = zeros(Int, T, count)
    TSO = zeros(T, count)

    # data on demographic transition
    reher = CSV.read("data/reher.txt", DataFrame; header=false, delim=' ', ignorerepeated=true, select=[1,2], silencewarnings=true)
    demog_years = Float64.(reher[:, 2])

    # initial guess for country-specific skilled productivity
    eta = A_S_1 * 2
    omega = 0.1
    eta_scrap = eta - omega
    should_restart = true
    start = 1

    # loop over eta until until all countries match education take-off and demographic transition
    while should_restart
        should_restart = false

        for j in start:count
            at_j = Int((demog_years[j] - init) / gen) - 1

            first_positive = findfirst(x -> x > 0, e[:, j])

            if first_positive === nothing
                eta = eta_scrap - omega
            else
                first_england = findfirst(x -> x > 0, e[:, 1])
                if first_positive == at_j + 1 && e[first_england - 1, j] == 0
                    eta = eta_scrap
                else
                    eta = eta_scrap - omega
                end
            end

            # set equal across countries
            h[1, j] = h_1
            A_U[1, j] = A_U_1
            L[1, j] = L_1
            N[1, j] = N_1
            H[1, j] = H_1
            A_S[1, j] = eta
            K[1, j] = K_1
 
            # laws of motion
            for i in 1:T
                year[i, j] = i * gen + init

                Y_U[i, j] = L[i, j]^alpha * (A_U[i, j] * X)^(1 - alpha)
                Y_S[i, j] = H[i, j]^beta * (A_S[i, j] * K[i, j])^(1 - beta)
                Y[i, j] = Y_U[i, j] + Y_S[i, j]
                y[i, j] = Y[i, j] / N[i, j]
                theta[i, j] = Y_S[i, j] / Y[i, j]
                w_L[i, j] = (A_U[i, j] * X / L[i, j])^(1 - alpha)
                w_H[i, j] = beta * (A_S[i, j] * K[i, j] / H[i, j])^(1 - beta)
                R[i, j] = (1 - beta) * (H[i, j] / K[i, j])^beta * A_S[i, j]^(1 - beta)

                if ext && i >= 3
                    error("Technology diffusion extension not implemented")
                else
                    A_S[i + 1, j] =
                        phi_S *
                        (1 + sigma_S * (h[i, j] - hc(0)) +
                         psi * (h[i, j] - max(i == 1 ? hc(0) : h[i - 1, j], hc(0)))) *
                        A_S[i, j]
                end

                e[i + 1, j] = max(educ(A_S[i + 1, j], w_L[i, j]), 0)
                h[i + 1, j] = hc(e[i + 1, j])

                if under
                    A_U[i + 1, j] =
                        phi_U *
                        (1 + sigma_U * (h[i, j] - hc(0)) +
                         psi * (h[i, j] - max(i == 1 ? hc(0) : h[i - 1, j], hc(0)))) *
                        A_U[i, j]
                else
                    A_U[i + 1, j] =
                        phi_U *
                        (1 + sigma_U * (h[i + 1, j] - hc(0)) +
                         psi * (h[i + 1, j] - h[i, j])) *
                        A_U[i, j]
                end

                s[i, j] = sav(e[i + 1, j], A_S[i + 1, j], w_L[i, j])
                n[i, j] = fer(e[i + 1, j], A_S[i + 1, j], w_L[i, j])

                L[i + 1, j] = n[i, j] * L[i, j]
                N[i + 1, j] = (1 + n[i, j]) * L[i, j]
                H[i + 1, j] = hc(e[i + 1, j]) * L[i, j]
                K[i + 1, j] = s[i, j] * L[i, j]

                g_N[i + 1, j] = ((1 + (N[i + 1, j] - N[i, j]) / N[i, j])^(1 / gen) - 1) * 100

                if i > 1
                    g_y[i, j] = ((1 + (y[i, j] - y[i - 1, j]) / y[i - 1, j])^(1 / gen) - 1) * 100
                end
            end

            first_positive = findfirst(x -> x > 0, e[:, j])

            if first_positive === nothing
                eta_scrap = eta
                should_restart = true
                break
            else
                first_england = findfirst(x -> x > 0, e[:, 1])

                if first_positive == at_j + 1 && e[first_england - 1, j] == 0
                    start += 1
                else
                    eta_scrap = eta
                    should_restart = true
                    break
                end
            end
        end
    end

    rows = DataFrame()

    # saving results
    for j in 1:count
        index = findfirst(x -> x > 0, e[:, j])

        temp = DataFrame(
            id_c = fill(j, T),
            year = year[:, j],
            y = y[:, j],
            N = N[1:T, j],
            Y_U = Y_U[:, j],
            L = L[1:T, j],
            A_U = A_U[1:T, j],
            Y_S = Y_S[:, j],
            H = H[1:T, j],
            A_S = A_S[1:T, j],
            K = K[1:T, j],
            w_L = w_L[:, j],
            w_H = w_H[:, j],
            R = R[:, j],
            e = e[1:T, j],
            s = s[:, j],
            n = n[:, j],
            TSO = year[:, j] .- year[index, j],
            g_N = g_N[1:T, j],
            g_y = g_y[:, j],
        )

        append!(rows, temp)
    end

    CSV.write(outfile, rows)
    println("Saved simulation output to $outfile")

    return rows
end