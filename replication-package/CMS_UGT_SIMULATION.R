#!/usr/local/bin/R
################################################################################
#
# MODEL SIMULATIONS 
#
# THE EMPIRICS OF ECONOMIC GROWTH OVER TIME AND ACROSS NATIONS 		 	
# A UNIFIED GROWTH PERSPECTIVE        										
#
# by Matteo Cervellati, Gerrit Meyerheim, and Uwe Sunde
#
# Journal of Economic Growth
#
# September 2022
#
# see README file!
#
################################################################################
# Set dummy values for different fixed specifications.
#
# To enable a specification set the indicator to "1".
#
# This generates the simulated data for all figures and tables.
#base	= 0				# baseline simulation
#under	= 0				# undershooting (Figure 4)
#ext	= 0				# extension to technology diffusion
trailargs <- commandArgs(trailingOnly=TRUE);
base = as.numeric(trailargs[1])				# baseline simulation
under = as.numeric(trailargs[2])				# undershooting (Figure 4)
ext	 = as.numeric(trailargs[3])				# extension to technology diffusion
################################################################################

# Set generic parameter values.
count	= 114				# number of countries
T	= 36				# number of time periods
gen	= 20				# length of a generation in years
init	= 1680				# initial period == "init + gen"

# Set transition timing.
at	= 9
late	= 16

# Set the normalised parameter value.
X	= 1

# Set data moments.
k_share	= 1 / 3				# capital share of income
l_share	= 0.5				# labor share of income (unskilled)
n_share	= 0.677				# fertility share of income
N_1_d	= 8565				# population of England in the year 1700
N_at_d	= 28888				# population of England in the year 1860
y_1_d	= 2365				# GDP p.c. of England in the year 1700
y_at_d	= 4988				# GDP p.c. of England in the year 1860
malthus	= 0.4				# Malthusian growth rate (Crafts, 2021)
bgp	= 1				# BGP growth rate

# Set production parameter values.
beta	= 1 - k_share			# labor share in the skilled sector
alpha	= l_share			# labor share in the unskilled sector

# Derive initial and target values.
N_1	= N_1_d / N_1_d			# population in 1700 (normalised)
N_at	= N_at_d / N_1_d		# population in 1860 (normalised)
y_1	= y_1_d / y_1_d			# GDP p.c. in 1700 (normalised)
y_at	= y_at_d / y_1_d		# GDP p.c. in 1860 (normalised)

# Compute the average fertility rate in the data bewtween 1700 and 1860.
eq <- function(x) {
	(1 + x) * x**(at - 2) * (N_1 - N_1 / (1 + x)) - N_at
}
solution <- uniroot(eq, interval = c(0, 2), extendInt = c("yes"), tol =
		    0.00000000001)
n_m	= mean(c(solution$root, round(solution$root)))

# Compute the cohort sizes (given constant population growth).
L_0	= N_1 / (1 + n_m)		# initial cohort size (skilled sector)
L_1	= N_1 - L_0			# initial stock of unskilled labor
e_1	= 0				# zero initial education
h_1	= 1 + e_1			# initial individual human capital
H_1	= h_1 * L_0			# initial aggregate human capital

# Compute the average growth rate of GDP p.c. in the data between 1700 and
# 1860.
eq <- function(x) {
	(1 + x)**(at * gen - gen) * y_1 - y_at
}
solution <- uniroot(eq, interval = c(0, 2), extendInt = c("yes"), tol =
		    0.00000000001)
g_m	= mean(c((solution$root) * 100, malthus))

# Target the average growth rate of GDP p.c. in the data between 1700 and 1860.
phi_S	= (1 + (g_m / 100))**(gen * beta / (1 - beta))

# Target the population level in the data in 1860 for "n_1 = n_m".
phi_U	= n_m * phi_S**((1 - beta) / (beta * (1 - alpha)))

# Compute the initial levels of unskilled productivity and unskilled wage. 
A_U_1	= (L_1 / X) * (n_m / n_share)**(1 / (1 - alpha))
w_L_1	= (A_U_1 * X / L_1)**(1 - alpha)

# Compute the initial levels of saving and capital stock.
s_0	= (1 - n_share) * w_L_1 / (phi_S**((1 - beta) / beta))
s_1	= (1 - n_share) * w_L_1
K_1	= s_0 * L_0

# Set the minimum skilled productivity that sets "w_H(1) h(1) >= w_L(1)".
A_S_1	= (H_1 / K_1) * (w_L_1 / (beta * h_1))**(1 / (1 - beta))

# Set the preference parameter that implements "n_1 = n_m".
gamma	= n_m * (1 - beta) * (phi_S * A_S_1)**(1 - beta) / s_1**(beta)

# Set parameter values for the endogenous growth process (BPG of one percent,
# peak growth of 2.25 percent, and "n_BGP = 1").
e_max	= 2 * beta - 1
sigma_S	= ((1 + (bgp / 100))**(gen * beta / (1 - beta)) / phi_S - 1) / e_max
sigma_U	= (
	((phi_S * (1 + sigma_S * e_max))**((1 - beta) / (beta * (1 - alpha))) -
	 phi_U) / (phi_U * e_max)
)
psi	= 11.665593

# Set the extension parameter.
rho	= 0

if (base == 1) {

	ext	= 0
	under	= 0

} else if (under == 1) {

	ext	= 0

} else if (ext == 1) {

	rho	= 0.265			# 82.5 per cent convergence in the G7

} else {

	stop("please set a specification.")

}

# Define empty vectors.
year	= matrix(0, T, count)
Y_U	= matrix(0, T, count)
Y_S	= matrix(0, T, count)
Y	= matrix(0, T, count)
y	= matrix(0, T, count)
theta	= matrix(0, T, count)
w_L	= matrix(0, T, count)
w_H	= matrix(0, T, count)
R	= matrix(0, T, count)
A_S	= matrix(0, T+1, count)
e	= matrix(0, T+1, count)
h	= matrix(0, T+1, count)
A_U	= matrix(0, T+1, count)
s	= matrix(0, T, count)
n	= matrix(0, T, count)
L	= matrix(0, T+1, count)
N	= matrix(0, T+1, count)
H	= matrix(0, T+1, count)
K	= matrix(0, T+1, count)
g_N	= matrix(0, T+1, count)
g_U	= matrix(0, T+1, count)
g_S	= matrix(0, T+1, count)
g_y	= matrix(0, T, count)
id_c	= matrix(0, T, count)
TSO	= matrix(0, T, count)

# Define helper functions.
hc <- function(e) {
	1 + e
}

hc_prime <- function() {
	1
}

educ <- function(A, w) {
	2 * beta - 1 - gamma * ((beta / (1 - beta)) / (A * w))**(1 - beta)
}

sav <- function(e, A, w) {
	if (e <= 0) {

		eq <- function(x) {
			gamma * x**(beta) / ((1 - beta) * A**(1 - beta)) + x -
			w
		}
		solution <- uniroot(eq, interval = c(0, 10000),
				    extendInt = c("yes"),
				    tol = 0.000001)
		solution$root

	} else {

		((1 - beta) / beta) * (hc(e) / hc_prime()) * w

	}
}

fer <- function(e, A, w) {
	(1 - e) * w - sav(e, A, w)
}

spillover <- function(A, B, B1, B2) {
	(B - A) * min(B1 - A, 0) / (B1 - A) + max(B1 - A, 0) * min(B2 - A, 0) /
	(B2 - A) + max(B2 - A, 0)
}

# Set up the restart condition.
should_restart	= TRUE
start		= 1

# Load the data points and normalise them.
demog_years	= read.table("../data/reher.txt", header = FALSE, sep = ' ')[, 2]

# Initialise the baseline productivity and set the increment of subtraction.
eta		= A_S_1 * 2
omega		= 0.1

eta_scrap	= eta - omega

# Start the main loop.
while (should_restart == TRUE) {
	
	# Default is to not restart.
	should_restart	= FALSE

	# Set initial conditions.
	for (j in start:count) {

		# Obtain the target period from the data.
		at		= as.integer((demog_years[j] - init) / gen) - 1

		# Target the eta value for the first country; use incremented
		# scrap values after that.
		if (is.na(which(e[, j] > 0)[1])) {

			eta	= eta_scrap - omega

		} else {

			if (which(e[, j] > 0)[1] == at + 1
			    & e[(which(e[, 1] > 0)[1]-1), j] == 0) {

			    	eta	= eta_scrap

			} else {

				eta	= eta_scrap - omega

			}

		}

		h[1, j]		= h_1

		A_U[1, j]	= A_U_1

		L[1, j]		= L_1

		N[1, j]		= N_1

		H[1, j]		= H_1

		A_S[1, j]	= eta

		K[1, j]		= K_1

		# Run the dynamic system.
		for (i in 1:T) {

			year[i, j]	= i * gen + init

			# Production and factor prices.
			Y_U[i, j]	= (
					L[i, j]**(alpha) * (A_U[i, j] * X)**(1
					- alpha)
			)

			Y_S[i, j]	= (
					H[i, j]**(beta) * (A_S[i, j] * K[i,
					j])**(1 - beta)
			)

			Y[i, j]		= Y_U[i, j] + Y_S[i, j]

			y[i, j]		= Y[i, j] / N[i, j]

			theta[i, j]	= Y_S[i, j] / Y[i, j]

			w_L[i, j]	= (A_U[i, j] * X / L[i, j])**(1 - alpha)

			w_H[i, j]	= (
					beta * (A_S[i, j] * K[i, j] / H[i,
					j])**(1 - beta)
			)

			R[i, j]		= (
					(1 - beta) * (H[i, j] / K[i,
					j])**(beta) * A_S[i, j]**(1 - beta)
			)

			# Evolution of skilled productivity.
			if (ext == 1 & i >= 3) {

				A_S[i+1, j]	= (
						phi_S * (1 + sigma_S * (h[i, j]
						- hc(0)) + psi * (h[i, j] -
						max(h[i-1, j], hc(0)))) *
						A_S[i, j] + rho * (h[i, j] -
						hc(0)) * spillover(A_S[i, j],
						A_S[i, 1], A_S[i-1, 1],
						A_S[i-2, 1])
				)

			} else {

				A_S[i+1, j]	= (
						phi_S * (1 + sigma_S * (h[i, j]
						- hc(0)) + psi * (h[i, j] -
						max(h[i-1, j], hc(0)))) *
						A_S[i, j]
				)

			}

			# Solve for the education level.
			e[i+1, j]	= max(educ(A_S[i+1, j], w_L[i, j]), 0)

			h[i+1, j]	= hc(e[i+1, j])

			# Evolution of unskilled productivity.
			if (ext == 1 & i >= 3) {

				if (under == 1) {

					A_U[i+1, j]	= (
							phi_U * (1 + sigma_U *
							(h[i, j] - hc(0)) + psi
							* (h[i, j] - max(h[i-1,
							j], hc(0)))) * A_U[i,
							j] + rho * (h[i, j] -
							hc(0)) *
							spillover(A_U[i, j],
							A_U[i, 1], A_U[i-1, 1],
							A_U[i-2, 1])
					)

				} else {

					A_U[i+1, j]	= (
							phi_U * (1 + sigma_U *
							(h[i+1, j] - hc(0)) +
							psi * (h[i+1, j] - h[i,
							j])) * A_U[i, j] + rho
							* (h[i+1, j] - hc(0)) *
							spillover(A_U[i, j],
							A_U[i, 1], A_U[i-1, 1],
							A_U[i-2, 1])
					)

				}

			} else {

				if (under == 1) {

					A_U[i+1, j]	= (
							phi_U * (1 + sigma_U *
							(h[i, j] - hc(0)) + psi
							* (h[i, j] - max(h[i-1,
							j], hc(0)))) * A_U[i,
							j]
					)

				} else {

					A_U[i+1, j]	= (
							phi_U * (1 + sigma_U *
							(h[i+1, j] - hc(0)) +
							psi * (h[i+1, j] - h[i,
							j])) * A_U[i, j]
					)

				}

			}

			# Individual variables.
			s[i, j]		= sav(e[i+1, j], A_S[i+1, j], w_L[i, j])

			n[i, j]		= fer(e[i+1, j], A_S[i+1, j], w_L[i, j])

			# State variables.
			L[i+1, j]	= n[i, j] * L[i, j]

			N[i+1, j]	= (1 + n[i, j]) * L[i, j]

			H[i+1, j]	= hc(e[i+1, j]) * L[i, j]

			K[i+1, j]	= s[i, j] * L[i, j]

			# Compute yearly growth rates (in percent).
			g_N[i+1, j]	= (
					((1 + (N[i+1, j] - N[i, j]) / N[i,
					j])**(1 / gen) - 1) * 100
			)

			g_U[i+1, j]	= (
					((1 + (A_U[i+1, j]**(1 - alpha) -
					A_U[i, j]**(1 - alpha)) / A_U[i, j]**(1
					- alpha))**(1 / gen) - 1) * 100
			)

			g_S[i+1, j]	= (
					((1 + (A_S[i+1, j]**(1 - beta) - A_S[i,
					j]**(1 - beta)) / A_S[i, j]**(1 -
					beta))**(1 / gen) - 1) * 100
			)

			if (i > 1) {

				g_y[i, j]	= (
						((1 + (y[i, j] - y[i-1, j]) /
						y[i-1, j])**(1 / gen) - 1) *
						100
				)

			}

		}

		# Check if we match the data.
		if (is.na(which(e[, j] > 0)[1])) {

			eta_scrap	= eta

			# Restart the loop if we do not match.
			should_restart	= TRUE
			break

		} else {

			if (which(e[, j] > 0)[1] == at + 1
			    & e[(which(e[, 1] > 0)[1]-1), j] == 0) {

				start		= start + 1

			} else {

				eta_scrap	= eta

				# Restart the loop if we do not match.
				should_restart	= TRUE
				break

			}

		}

	}

}

# Export a full dataset.
for (j in 1:count) {

	for (i in 1:T) {

		id_c[i,j]	= j

		index		= which(e[, j] > 0)[1]

		TSO[i,j]	= year[i,j] - year[index,j]

	}

	data = cbind(id_c[1:T, j], year[1:T, j], N[1:T, j],
		     Y_U[1:T, j], L[1:T, j], A_U[1:T, j], Y_S[1:T, j], H[1:T, j],
		     A_S[1:T, j], K[1:T, j], w_L[1:T, j], w_H[1:T, j], R[1:T, j],
		     e[1:T, j], s[1:T, j], n[1:T, j], TSO[1:T, j], g_N[1:T, j],
		     g_y[1:T, j])

	if (j == 1) {

		data_frame	= data

	} else {

		data_frame	= rbind(data_frame, data)

	}

	if (ext == 0 & under == 0)

		write.table(data_frame,
			    file = "../output/ysft_data_full_20_years.txt",
			    append = FALSE, sep = "\t", row.names = FALSE,
			    col.names = FALSE)

	else if (ext == 1 & under == 0) { 

		write.table(data_frame,
			    file = "../output/ysft_data_full_20_years_extension.txt",
			    append = FALSE, sep = "\t", row.names = FALSE,
			    col.names = FALSE)

	} else if (ext == 0 & under == 1) {

		write.table(data_frame,
			    file = "../output/ysft_data_full_20_years_undershooting.txt",
			    append = FALSE, sep = "\t", row.names = FALSE,
			    col.names = FALSE)

	} else {


	}

}

# Extension only: compute adoption lags and intensity of use.
if (ext == 1 & under == 0) {

	# Set time range from 1780 to 1980 in 20-year intervals.
	yr_init	= 1760
	end	= length(which(year[, 1] == 1780):which(year[, 1] == 1980))

	# Define empty vectors.
	yr		= matrix(0, end)
	inv_yr		= matrix(0, end)

	for (i in 1:end) {

		yr[i]		= which(year[, 1] == yr_init + i * gen)

		inv_yr[i]	= year[yr[i]]

	}

	# Define empty vectors.
	L_A	= matrix(0, end, count)
	I_A	= matrix(0, end, count)

	for (j in 2:count) {

		# Generate adoption lags and intensity of use at the time of
		# adoption.
		for (i in 1:end) {

			ad		= which(A_S[yr[i], 1] - A_S[, j] <= 0)[1]

			ad_yr		= year[ad, j]

			L_A[i, j]	= ad_yr - inv_yr[i]

			I_A[i, j]	= A_S[yr[i], j] / A_S[yr[i], 1]

		}

		# Generate the year of the demographic transition.
		index	= which(e[, j] > 0)[1]

		# Collect the data.
		data	= cbind(id_c[1:end, j], matrix(1:end, end),
				    inv_yr[1:end], L_A[1:end, j],
				    I_A[1:end, j], matrix(year[index,j], end))

		if (j == 2) {

			data_frame	= data

		} else {

			data_frame	= rbind(data_frame, data)

		}

		write.table(data_frame,
			    file = "../output/ysft_data_comin.txt",
			    append = FALSE, sep = "\t", row.names = FALSE,
			    col.names = FALSE)

	}

}
