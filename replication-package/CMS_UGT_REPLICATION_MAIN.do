********************************************************************************
*  REPLICATION OF DATA ANALYSIS FOR 										
*																			
*  THE EMPIRICS OF ECONOMIC GROWTH OVER TIME AND ACROSS NATIONS 		 	
*  A UNIFIED GROWTH PERSPECTIVE        										
*                                   										
*  MATTEO CERVELLATI, GERRIT MEYERHEIM, AND UWE SUNDE                       
*  				                       										
*  Journal of Economic Growth												
*																			
*  September 2022															
*																			
*  See README file!															
*                                   										
********************************************************************************                                        

********************************************************************************
*  Note:   	this file contains the code for replicating the figures and tables
* 			in the paper and appendix
********************************************************************************
*  
*           - I.  Data Creation:  Model Simulations
* 					executed directly from Stata using the rsource command below
* 								--> ysft_panel.R
*			  		OR execute simulation in RStudio using $pathdo/ysft_panel.R
*
*           - II. conversion of data into Stata format using 
*			 					--> CMS_UGT_REPLICATION_dataprep.do
*
* 			- III: replication of figures and tables
*
********************************************************************************

********************************************************************************
* Setting Paths 
* make sure you execute the do file from within the folder "code" of 
* the Replication Package 
 
* Set global path to execute R:
	global Rterm_path `"c:\r\R-2.5.0\bin\Rterm.exe"'

* Set working directory paths
	global pathdata  	= "..\data"
	global pathdo   	= "..\code"
	global pathout  	= "..\output"
	global pathresults  = "..\replication_results"
	
set more off
clear




********************************************************************************
* I. Model Simulations

*ssc install rsource, replace

* Setting the specification of the model to be simulated: 0/1 (only one allowed)
* Baseline Model
local base_model 	1				/* set to 1 for baseline simulation, else 0 */
local under_model 	0				/* set to 1 for undershooting (Figure 4), else 0 */
local ext_model	 	0				/* set to 1 for extension to technology diffusion, else 0 */
rsource using "$pathdo\CMS_UGT_SIMULATION.R", roptions(`"--vanilla  --args "`base_model'" "`under_model'" "`ext_model'" "') rpath()

* Model for Undershooting Population (Figure 4)
local base_model 	0				/* set to 1 for baseline simulation, else 0 */
local under_model 	1				/* set to 1 for undershooting (Figure 4), else 0 */
local ext_model	 	0				/* set to 1 for extension to technology diffusion, else 0 */
rsource using "$pathdo\CMS_UGT_SIMULATION.R", roptions(`"--vanilla  --args "`base_model'" "`under_model'" "`ext_model'" "') rpath()

* Model Extension to Technology Diffusion
local base_model 	0				/* set to 1 for baseline simulation, else 0 */
local under_model 	0				/* set to 1 for undershooting (Figure 4), else 0 */
local ext_model	 	1				/* set to 1 for extension to technology diffusion, else 0 */
rsource using "$pathdo\CMS_UGT_SIMULATION.R", roptions(`"--vanilla  --args "`base_model'" "`under_model'" "`ext_model'" "') rpath()


********************************************************************************
* II. Conversion of simulated data into Stata format	

do "$pathdo\CMS_UGT_REPLICATION_DATAPREP.do"

	
	
********************************************************************************
* III.	REPLICATION											  	 

	
********************************************************************************
* Figure 1
********************************************************************************

use  "$pathout\ysft_data_full_20_years.dta", clear

* Plot for England: id==13 
keep if id==13
	g placeholder = 0.026
	g dk = exp(D.k/20)-1
	g das = (((((A_S^0.33)-L.A_S^0.33)/(L.A_S^0.33))+1)^0.05)-1

	label variable year "Year"
	label variable growth_pc_pa "Output p.c. Growth
	label variable dk "Growth in log Capital p.c."
	label variable das "Productivity Growth (skilled)"
	label variable e "Education (e)"


twoway line growth_pc_pa year,  lcolor(black) || line popgrowth year, lcolor(black) lpattern(_)||  line placeholder  year, lwidth(vthin) lcolor(white)||  if year>=1820& year<=2020 , xlabel(1800(100)2020) legend(row(3) label(1 "Output p.c. Growth") label(3 "")) xline(1880) ytitle("Growth Rate (p.a.)") yline(0, lpattern(-) lcolor(black))
graph export "$pathresults/Figure_1a.pdf", replace
	

twoway line growth_pc_pa year , lcolor(black)|| line dk year, lcolor(black) lpattern(-)|| line popgrowth year, lcolor(black) lpattern(_)|| line das year, lcolor(black) lpattern(_.)||  line e year, lwidth(thick) lcolor(black) yaxis(2) || if year>=1820& year<=2020 , xlabel(1800(100)2020) legend(col(2)) xline(1880) yscale(range (0 0.02) axis(1))yscale(range (-0.05 0.2) axis(2)) yline(0, lpattern(-) lcolor(black))
graph export "$pathresults/Figure_1b.pdf", replace


	
********************************************************************************
* Figure 2
********************************************************************************
	
use  "$pathout\ysft_data_full_20_years.dta", clear
* Plot for England: id==13 
keep if id==13
keep if year>=1700 & year<=2020
save "$pathdata\tmp.dta", replace

use "$pathdata\mpd2020.dta", clear
keep if year>=1800
keep if countrycode=="GBR"
replace year = 2020 if year==2018
sort year

merge 1:1 year using "$pathdata\tmp.dta"
*keep if _m==3
keep if year == 1700 | year == 1720 | year == 1740 | year == 1760 | year == 1780 | year == 1800 | year == 1820 | year == 1840 | year == 1860 | year == 1880 | year == 1900 | year == 1920 | year == 1940 | year == 1960 | year == 1980 | year == 2000 | year == 2020
	label variable year "Year"
	tsset year, delta(20)
	g ln_gdppc = ln(gdppc)
	g ln_pop = ln(pop)
	g madd_popgrowth = (((pop[_n])/pop[_n-1])^0.05 -1) * 100	
	g madd_y_growth = (((gdppc[_n])/gdppc[_n-1])^0.05 -1) * 100	
twoway line g_y year , lcolor(cranberry)|| line madd_y_growth year, lpattern(_) lcolor(navy) || if year>1800, legend(cols(2) label(1 "Model") label(2 "Data")) ytitle("Growth Rate (p.a.)") yline(0, lpattern(-) lcolor(black)) ylabel(-0.5(0.5)2)
graph export "$pathresults/Figure_2a.pdf", replace

twoway line g_N year , lcolor(cranberry)|| line madd_popgrowth year, lpattern(_) lcolor(navy)|| if year>1800, legend(cols(2) label(1 "Model") label(2 "Data")) ytitle("Growth Rate (p.a.)") ylabel(0(0.5)1.2)  yline(0, lpattern(-) lcolor(black))
graph export "$pathresults/Figure_2b.pdf", replace

erase "$pathout\tmp.dta"	
	
********************************************************************************
* Figure 3
********************************************************************************

use  "$pathout\ysft_data_full_20_years.dta", clear
keep if year>=1700 & year<=2020
tsset id year, delta(20)
* Plot for England: id==13 
keep if id==13
save "$pathout\tmp.dta", replace

use "$pathdata\mpd2020.dta", clear
keep if year>=1500
keep if countrycode=="GBR"

merge 1:1 year using "$pathout\tmp.dta"

	su gdppc if year==1700
	g gdppc_norm = gdppc/2412
	g y_pc = Y/N
	su y_pc if year==1700
	g y_pc_norm = y_pc/1.982236
	label variable year "Year"
	
twoway line y_pc_norm year , lcolor(cranberry)|| line gdppc_norm year, lpattern(_) lcolor(navy)|| if year>=1500 & year<=2000, legend(cols(1) label(1 "GDP p.c. (1700=1, model)") label(2 "GDP p.c. (1700=1, data)"))
graph export "$pathresults/Figure_3a.pdf", replace

	g ln_N = ln(N)
	g ln_pop = ln(pop)
	su pop if year==1700
	g pop_n = pop/8565
	g ln_pop_n = ln(pop_n)

twoway line N year , lcolor(cranberry)|| line pop_n year, lpattern(_) lcolor(navy)|| , ylabel(0(5)15) legend(cols(1) label(1 "Population (1700=1, model)") label(2 "Population (1700=1, data)"))
graph export "$pathresults/Figure_3b.pdf", replace

erase "$pathout\tmp.dta"

********************************************************************************
* Figure 4
********************************************************************************

use  "$pathout\ysft_data_full_20_years_undershooting.dta", clear
keep if year>=1700 & year<=2020
tsset id year, delta(20)
* Plot for England: id==1013 
keep if id==1013
	label variable year "Year"

twoway line growth_pc_pa year, lcolor(cranberry) || line popgrowth year, lcolor(cranberry)lpattern(_)||  if year>=1820& year<=2020 , xlabel(1800(50)2020) legend(cols(1) label(1 "Output p.c. Growth") label(2 "Population Growth"))  yline(0, lpattern(-) lcolor(black))
graph export "$pathresults/Figure_4b.pdf", replace

save "$pathout\tmp.dta", replace

use "$pathdata\mpd2020.dta", clear
	keep if year>=1500
	keep if countrycode=="GBR"
	merge 1:1 year using "$pathout\tmp.dta"
	su pop if year==1700
	g pop_n = pop/8565
	label variable year "Year"

twoway line N year , lcolor(cranberry)|| line pop_n year, lpattern(_) lcolor(black)||, legend(col(1) label(1 "Population (1700=1, model)") label(2 "Population (1700=1, data)"))
graph export "$pathresults/Figure_4a.pdf", replace

erase "$pathout\tmp.dta"



********************************************************************************
* Figure 5
********************************************************************************

use  "$pathout\ysft_data_full_20_years.dta", clear
	keep if year>=1800 & year<=2020
	tsset id year, delta(20)
	g lag_year = L.year
	g base=0
	egen edu_min = min(e) if id==13
	egen edu_max = max(e) if id==13
	g edu_norm = ((e-edu_min)/(edu_max-edu_min))*(12-base) + base if id==13
	label variable lag_year "Year of birth"
	label variable edu_norm "Years of Schooling"
	keep if id==13
save "$pathout\tmp.dta", replace

use "$pathdata\LeeLee_LRdata.dta", clear
	tab WBcode
	keep if WBcode == "GBR"
	keep if sex=="M"
merge 1:1 year using  "$pathout\tmp.dta"
	keep if year>=1800 & year<=2020
	bysort year: keep if _n==1
	g prima = pri/100*4
	label variable year "Year"

line edu_norm year,  lcolor(cranberry)|| line prima year if year<1875, lpattern(-) lcolor(navy)|| line tyr year ,lpattern(_) lcolor(navy)|| line hca year, yaxis(2) lcolor(navy) lpattern(._)||  if year>=1820 & year<2001, legend(cols(1)  label(1 "Years of Schooling (model)") label(2 "Years of Primary Schooling (ages 15-64)") label(3 "Total Years of Schooling (ages 15-64)") label(4 "Human Capital Index (ages 15-65)")) ytitle("Years")  ytitle("Human Capital Index (ages 15-64)", axis(2) )
graph export "$pathresults/Figure_5a.pdf", replace


line e year, yaxis(2) lcolor(cranberry)|| line pri  year, lpattern(_) lcolor(navy) || line sec year, lcolor(navy) lpattern(.-) || line ter year ,lpattern(-) lcolor(navy)||, legend(cols(1) label(1 "Education investment (model)") label(2 "Enrolment rate: Primary (males, adj.,%)") label(3 "Enrolment rate: Secondary (males, adj.,%)") label(4 "Enrolment rate: Tertiary (males, adj.,%)") order (1 2 3 4))
graph export "$pathresults/Figure_5b.pdf", replace

erase "$pathout\tmp.dta"
	
	
********************************************************************************
* Figure 6
********************************************************************************

use  "$pathout\ysft_data_full_20_years.dta", clear
keep if year>=1700 & year<=2020
keep if id==13

	g kx_worker = ((K+1)/N)*1000
	su kx_worker if year == 1700
	g kx_worker_n = kx_worker/ 1227.394

preserve

	
merge 1:1 year using "$pathdata\BroadberryPleijt_CEPR2021_Figure4B_KL" 
	sort year
	label variable year "Year"

line kx_worker_n year , lcolor(cranberry) || line k_l_repro year, lcolor(navy) lpattern(_) || if year>=1700 & year<=1860, legend(cols(1) label(1 "Fixed Capital p.c. (1700=1, model)") label(2 "Fixed Capital p.c. (1700=1, data)")) ylabel(0.5(0.25)1.5)
graph export "$pathresults/Figure_6a.pdf", replace


use "$pathdata\pwt91_merged.dta", clear
keep if wbcode == "GBR"
count
* generating capital stock in GBP (exchange rate USD/GBP = 1.6 in 2011, see https://www.macrotrends.net/2549/pound-dollar-exchange-rate-historical-chart)
	g capital_pwt = (rnna*1.6)/pop
	g ky_ratio =  rnna/ rgdpna 
	su capital ky_ratio
	keep capital ky_ratio year
save "$pathout\tmp.dta", replace

restore

merge 1:1 year using "$pathout\tmp.dta"
	su capital_pwt if year==2000
	g k_pwt_norm = capital_pwt/ 219314.8
	su kx_worker if year==2000
	g k_model_norm = kx_worker/ 3973.899
	label variable year "Year"
sort year

line k_model_norm year , lcolor(cranberry) || line k_pwt_norm year, lcolor(navy) lpattern(_) || if year>=1940 & year<=2020, legend(cols(1) label(1 "Fixed Capital p.c. (2000=1, model)") label(2 "Capital p.c. (2000=1, data)"))
graph export "$pathresults/Figure_6b.pdf", replace

erase "$pathout\tmp.dta"
	

		
********************************************************************************
* Figure 7
********************************************************************************

use  "$pathout\ysft_data_full_20_years.dta", clear

keep if id==21 & year>=1900 & year<=2020
	g wage_ratio = w_H/w_L
	label variable wage_ratio "Wage Ratio"
	g earnings_ratio = (w_H*h)/w_L
	label variable earnings_ratio "Earnings Ratio"

merge 1:1 year using "$pathdata\GoldinKatz.dta"
	replace college = 1 + college
	replace highschool = 1 + highschool

	sort year
	label variable year "Year"

twoway line college year , lcolor(navy)|| line highschool year , lcolor(navy) lpattern(_)|| , ylabel(1(0.25)2) legend(label(1 "College Wage Premium") label(2 "High School Wage Premium")) xlabel(1900(20)2020)
graph export "$pathresults/Figure_7a.pdf", replace

twoway line earnings_ratio year , lcolor(cranberry)|| line wage_ratio year , lcolor(cranberry) lpattern(_) || if id==21 & year>=1900 & year<=2020 , ylabel(1(0.25)2) xlabel(1900(20)2020)
graph export "$pathresults/Figure_7b.pdf", replace

	
		
********************************************************************************
* Figure 8
********************************************************************************
	
use  "$pathout\ysft_data_full_20_years.dta", clear
* Plot for England: 13
keep if id==13

	g labin = (w_L*L + w_H*H)/(Y_S+Y_U)
	label variable labin "Labor Income Share"
	g capin = (R*K)/(Y_S+Y_U)
	label variable capin "Capital Income Share"

preserve
	
merge 1:1 year using "$pathdata\Crafts2021_GDPshares.dta"
	replace capshare=capshare/100
	sort year
	label variable year "Year"
	
twoway line  capin year,  lcolor(cranberry) || line capshare year ,lcolor(navy) lpattern(_) || if year>=1760& year<=1880 , xlabel(1760(20)1880) legend(col(1) label(1 "Capital Share of GDP (Model)") label(2 "Capital Share of GDP (Data)")) ylabel(0.15(0.05)0.35)
graph export "$pathresults/Figure_8a.pdf", replace	
	
restore

g r_model = (R^(1/20)-1) *100
label variable r_model "Capital Return (p.a., pct.)"

merge 1:1 year using "$pathdata\Schmelzing_FigIV_original_5.dta"
	sort year
	label variable year "Year"

twoway line r_model year ,  lcolor(cranberry) ||  line real_rate year ,  lcolor(navy)lpattern(_)||if year>=1700& year<=2020 , xlabel(1700(100)2000) legend(col(1) label(1 "Real Return (annualized %, model)")  label(2 "Real Return (annualized %, data)"))
graph export "$pathresults/Figure_8b.pdf", replace
	

			
********************************************************************************
* Figure 9
********************************************************************************

use "$pathdata\pwt91_merged.dta", clear
bysort country: keep if _n==1

twoway kdensity reher, bw(12) legend() ylabel(0(0.005)0.02) lcolor(navy) xlabel(1860(20)2000) xtitle(Year of Demographic Transition) ytitle(Kernel Density Estimate)
graph export "$pathresults/Figure_9a.pdf", replace


use  "$pathout\ysft_data_full_20_years.dta", clear
	bysort id: keep if _n==1
	label variable yearofonset "Year of Demographic Transition"

twoway kdensity yearofonset, lcolor(cranberry) bw(12) legend() ylabel(0(0.005)0.02) xlabel(1860(20)2000) xtitle("Year of Demographic Transition") ytitle(Kernel Density Estimate)
graph export "$pathresults/Figure_9b.pdf", replace


	
			
********************************************************************************
* Figure 10
********************************************************************************
		
use  "$pathout\ysft_data_full_20_years.dta", clear
append using  "$pathout\ysft_data_full_20_years_extension.dta"

	tsset id year, delta(20)
	label variable year "Year"

twoway function "Observed"=0.026 , range(1950 2010) recast(area) color(gs12) base(0)|| line popgrowth year if id==13 & year<2030, lcolor(black)  lpattern(_)|| line growth_pc_pa year if id==13 & year<2030, lcolor(black)  ||line popgrowth year if id==114 & year<2030 , lcolor(red) lpattern(_)|| line growth_pc_pa year if id==114 & year<2030, lcolor(red) ||line popgrowth year if id==1114 & year<2030, lpattern(_) lcolor(cranberry)|| line growth_pc_pa year if id==1114 & year<2030, lcolor(cranberry) || if year>=1850 & year<=2020, legend(cols(1) label(2 "Population Growth (Forerunner)")label(3 "GDP p.c. Growth (Forerunner)")label(4 "Population Growth (Latecomer, baseline)")label(5 "GDP p.c. Growth (Latecomer, baseline)") label(6 "Population Growth (Latecomer, extension)")label(7 "GDP p.c. Growth (Latecomer, extension)")  )xlabel(1860(40)2020) yscale(range (0 0.02)) xtitle("Year") ytitle("Growth Rate (p.a.)")
graph export "$pathresults/Figure_10.pdf", replace
		
		
********************************************************************************
* Figure 11
********************************************************************************
	
use "$pathdata\pwt91_merged.dta", clear
	keep if year==2000
	g rgdpnacapita = rgdpna/pop
	g y_USA = rgdpnacapita if wbcode=="USA"
	egen y_bench = max(y_USA)
	g y_rel = rgdpnacapita/y_bench
	label variable y_rel "GDP p.c., 2000 (USA=1)"
twoway scatter ctfp y_rel , mcolor(navy) mlabel(wbcode) mlabcolor(navy)|| , xscale(log) yscale(log) ylabel(0.2 0.4 1 2, valuelabel) xlabel(0.02 0.05 0.1 0.2 0.4 1 2, valuelabel) ytitle("TFP level at current PPPs, 2000 (USA=1)")
graph export "$pathresults/Figure_11a.pdf", replace
	
		
use  "$pathout\ysft_data_full_20_years.dta", clear	
	keep if year==2000
	g y_USA = y if id==21
	egen y_bench = max(y_USA)
	g y_rel = y/y_bench
	label variable y_rel "GDP p.c., 2000 (USA=1)"
	g TFP = A_S^((1/3))
	g TFP_USA = TFP if id==21
	egen TFP_bench = max(TFP_USA)
	g TFP_rel = TFP/TFP_bench
	label variable TFP_rel "TFP, 2000 (USA=1)"

twoway scatter TFP_rel y_rel , mcolor(cranberry)|| fpfit TFP_rel y_rel, lcolor(cranberry)||, xscale(log) yscale(log) ylabel(0.5 1 2, valuelabel) xlabel(0.6 1 1.5, valuelabel) legend(off) ytitle("TFP, 2000 (USA=1)")
graph export "$pathresults/Figure_11b.pdf", replace	
		
		
		
********************************************************************************
* Figure 12
********************************************************************************
		
use "$pathdata\pwt91_merged.dta", clear
	keep if year==2010
	g rgdpnacapita = rgdpna/pop
	label variable rgdpnacapita "real GDP per capita"
	g rgdpnapw = rgdpna/emp
	label variable rgdpnapw "real GDP per worker"
	g rnnapw = rnna/emp
	label variable rnnapw "real Capital per worker"

twoway scatter rnnapw rgdpnapw if rgdpnapw<140000, mcolor(navy) mlabcolor(navy) mlabel(wbcode)
graph export "$pathresults/Figure_12a.pdf", replace		
		

use  "$pathout\ysft_data_full_20_years.dta", clear	
	keep if year <=2000
	g y_capita = Y/N
	g k_capita = K/N
	bysort id: g y_0 = y_capita if year==1700
	bysort id: egen y_index = max(y_0)
	replace y_index = y_capita/y_index
	bysort id: g k_0 = k_capita if year==1700
	bysort id: egen k_index = max(k_0)
	replace k_index = k_capita/k_index
	label variable y_index "GDP p.c. (indexed, 1700=1)"
	label variable k_index "Capital p.c. (indexed, 1700=1)"
twoway scatter k_index y_index , mcolor(cranberry) mlabcolor(cranberry) 
graph export "$pathresults/Figure_12b.pdf", replace	
		
		
		
********************************************************************************
* Figure 13
********************************************************************************

use "$pathdata\Caselli_Feyrer_QJE2007_TableII.dta", clear
rename y gdppc
	su pmpkl gdppc if wbcode=="USA"
	g pmpkl_relative = pmpkl/0.09
	g gdp_relative = gdppc/57259

save "$pathout\tmp.dta", replace

use  "$pathout\ysft_data_full_20_years.dta", clear	
	keep if year==2000
	g ypc = exp(y)
	su ypc R if id==21
	g ypc_rel = ypc/47.19098
	g R_rel = R/1.759798
append using "$pathout\tmp.dta"

twoway scatter pmpkl_ gdp_ , mlabcolor(navy) mcolor(navy) mlabel(wbcode)||, legend(off) xtitle("Real GDP per capita (USA=1)") xlabel(0(0.2)1.1) ylabel(0(0.5)2) ytitle("Marginal Product of Capital (USA=1)")
graph export "$pathresults/Figure_13a.pdf", replace

twoway scatter R_rel ypc_rel, mcolor(cranberry) lcolor(cranberry) || line R_rel ypc_rel, mcolor(cranberry) lcolor(cranberry) , legend(off) xlabel(0(0.2)1.1) ylabel(0(0.5)2) ytitle("Marginal Product of Capital (normalized)") xtitle("Real GDP per capita (normalized)")
graph export "$pathresults/Figure_13b.pdf", replace			
				
erase "$pathout\tmp.dta"
		
		
	
********************************************************************************
* Figure 14
********************************************************************************

use "$pathdata\pwt91_merged.dta", clear
	encode country, g(ctry)
	keep if year==1950 | year==1970 | year==1990 | year==2010
	bysort ctry year: keep if _n==1
	tsset ctry year, delta(20)
	g rgdpnacapita = rgdpna/pop
	g ln_rgdpnacapita = ln(rgdpnacapita)
	bysort year: egen y_max = max(ln_rgdpnacapita)
	g y_rel = ln_rgdpnacapita/y_max  
	tsset ctry year, delta(20)
	g growth = D.ln_rgdpnacapita / 20
	g y_rel_lag = L.y_rel
binscatter growth y_rel, ylabel(-0.01(0.01)0.04) xlabel(0.5(0.1)1) legend(off) ytitle(GDP p.c. Growth) xtitle(GDP p.c. Relative to Highest) line(qfit)
graph export "$pathresults/Figure_14a.pdf", replace


use  "$pathout\ysft_data_full_20_years.dta", clear	
	keep if  year==1960 |  year==1980 | year==2000 | year==2020
	su y if id==13 & year==1940
	bysort year: egen y_max = max(y)
	g y_rel = y/y_max
	g y_rel50 = y/2.656099
	tsset id year, delta(20)
	g growth = D.y / 20
	g y_rel_lag = L.y_rel
binscatter growth y_rel , mcolor(cranberry) ylabel(-0.01(0.01)0.04) xlabel(0.5(0.1)1) legend(off) ytitle(GDP p.c. Growth) xtitle(GDP p.c. Relative to Highest) line(qfit)
graph export "$pathresults/Figure_14b.pdf", replace



********************************************************************************
* Table 2
********************************************************************************

use "$pathdata\pwt91_merged.dta", clear

	encode country, g(ctry)
	g pre=0
	replace pre=1 if year<reher_transitionyear
	g post=0
	replace post=1 if year>=reher_transitionyear

	g rgdpnacapita = rgdpna/pop
	g ln_rgdpnacapita = ln(rgdpnacapita)
	g lnhc = ln(hc)
	g k_emp = rnna/emp
	g ln_k_emp=ln(rnna/emp)
	g postkemp = post * ln_k_emp
	g prekemp = pre * ln_k_emp

	keep if year==1950 | year==1970 | year==1990 | year==2010
	bysort ctry year: keep if _n==1
	tsset ctry year, delta(20)

	egen edu_min = min(lnhc) 
	egen edu_max = max(lnhc) 
	g edu_index = ((lnhc-edu_min)/(edu_max-edu_min))
	g pre_edu_index = pre*edu_index
	g post_edu_index = post*edu_index

	label variable edu_index "HC"
	label variable pre_edu_index "HC (pre-transition)"
	label variable post_edu_index "HC (post-transition)"

eststo table2_1: xtreg ln_rgdpnacapita L.ln_rgdpnacapita ln_k_emp edu_index i.year, fe cluster(ctry) robust
eststo table2_2: xtreg ln_rgdpnacapita L.ln_rgdpnacapita prekemp postkemp pre_edu_index post_edu_index i.year, fe cluster(ctry) robust



use  "$pathout\ysft_data_full_20_years.dta", clear	

	g ln_hc = ln(1+e)
	g prek = pre*k
	g postk = post*k

	egen edu_min = min(ln_hc) 
	egen edu_max = max(ln_hc) 
	g edu_index = ((ln_hc-edu_min)/(edu_max-edu_min))

	keep if year==1960 |  year==1980 | year==2000 | year==2020

	tsset id year, delta(20)
	g ly = L.y
	g pre_edu_index = pre*edu_index
	g post_edu_index = post*edu_index

	label variable edu_index "HC"
	label variable pre_edu_index "HC (pre-transition)"
	label variable post_edu_index "HC (post-transition)"

	label variable k "$\ln k_{t}$"
	label variable prek "$\ln k_{t}\cdot PRE$"
	label variable postk "$\ln k_{t}\cdot POST$"
	label variable ly "$\ln y_{t-1}$"

eststo table2_3: xtreg y ly k edu_index i.year, fe cluster(id) robust
eststo table2_4: xtreg y ly prek postk pre_edu_index post_edu_index i.year, fe cluster(id) robust


use  "$pathout\ysft_data_full_20_years_extension.dta", clear	

	g ln_hc = ln(1+e)
	g prek = pre*k
	g postk = post*k

	egen edu_min = min(ln_hc) 
	egen edu_max = max(ln_hc) 
	g edu_index = ((ln_hc-edu_min)/(edu_max-edu_min))

	keep if year==1960 |  year==1980 | year==2000 | year==2020

	tsset id year, delta(20)
	g ly = L.y
	g pre_edu_index = pre*edu_index
	g post_edu_index = post*edu_index

	label variable edu_index "HC"
	label variable pre_edu_index "HC (pre-transition)"
	label variable post_edu_index "HC (post-transition)"

	label variable k "$\ln k_{t}$"
	label variable prek "$\ln k_{t}\cdot PRE$"
	label variable postk "$\ln k_{t}\cdot POST$"
	label variable ly "$\ln y_{t-1}$"

eststo table2_5: xtreg y ly k edu_index i.year, fe cluster(id) robust
eststo table2_6: xtreg y ly prek postk pre_edu_index post_edu_index i.year, fe cluster(id) robust

	
esttab table2_1 table2_2 table2_3 table2_4 table2_5 table2_6 using "$pathresults/Table_2.tex" , booktabs nonotes replace compress label nomtitles  indicate("Year and Country FE=*year*")  se(2) b(a2) r2(2) drop(_cons)  star(* 0.10 ** 0.05 *** 0.01) prehead("{\begin{tabular}{l*{6}{c}}\toprule&\multicolumn{6}{c}{Dependent variable: ln [Income p/c]}\\ \cmidrule(lr){2-7}[.1cm]  &\multicolumn{2}{c}{Data 20-year panel}&\multicolumn{2}{c}{Baseline Model}&\multicolumn{2}{c}{Extension}\\ \cmidrule(lr){2-3}\cmidrule(lr){4-5}\cmidrule(lr){6-7}")
	
eststo clear
		

********************************************************************************
* Table 3
********************************************************************************

use "$pathdata\Comin_Mestrieri_replication.dta", clear

	sort tech_no
	by tech_no: gen count_obs_tech = _n
	by tech_no: egen observations_by_technology2 = max(count_obs_tech)
	gen weight = 1/observations_by_technology2

	*ainv is invention date minus 1800
	gen ainv = inventionyear-1820
	gen loglagsprecise = ln(lagsprecise)

	g forerunner = 0
	replace forerunner = 1 if category=="forerunner"
	g follower = 0
	replace follower = 1 if category=="follower"
	g trailer = 0 
	replace trailer = 1 if category=="trailer"
	g latecomer = 0 
	replace latecomer = 1 if category=="latecomer"
	g postatinvention = 0
	replace postatinvention = 1 if reher_transitionyear>=inventionyear

	g adoptionyear = inventionyear+lagsprecise
	g postatadoption = 0
	replace postatadoption = 1 if reher_transitionyear>=adoptionyear

	g interaction = (ainv*reher_transitionyear)/100
	g intiatinvention = ainv*postatinvention
	g intiatadoption = ainv*postatadoption

	tabstat intensive, by (technology) s(count mean sd p10 p50 p90  cv iqr) f(%5.2f)

	keep if reher_transitionyear!=.

	label variable ainv "Invention Year-1820"
	label variable reher_transitionyear "Year of Demogr. Tr."

eststo table3_1: reg loglagsprecise ainv  [pweight=weight], clus(country_no)
eststo table3_2: reg loglagsprecise ainv reher_transitionyear [pweight=weight], clus(country_no)
eststo table3_3: reg loglagsprecise ainv follower trailer latecomer [pweight=weight], clus(country_no)

eststo table3_4: reg intensive ainv  [pweight=weight], clus(country_no)
eststo table3_5: reg intensive ainv reher_transitionyear [pweight=weight], clus(country_no)
eststo table3_6: reg intensive ainv follower trailer latecomer [pweight=weight], clus(country_no)

esttab table3_1 table3_2 table3_3 table3_4 table3_5 table3_6 using "$pathresults/Table_3.tex" , booktabs nonotes replace compress label nomtitles se(2) b(a2) r2(2) drop(_cons)  star(* 0.10 ** 0.05 *** 0.01) prehead("{\begin{tabular}{l*{6}{c}}\toprule\toprule&\multicolumn{6}{c}{Western Countries:} \\ \multicolumn{1}{l}{Dependent Variable:}&\multicolumn{3}{c}{Log [Adoption Lag]}&\multicolumn{3}{c}{Log [Intensity]}\\[.1cm]  \cmidrule(lr){2-4}\cmidrule(lr){5-7}")

eststo clear




********************************************************************************
*** REPLICATION MATERIAL FOR ONLINE APPENDIX 								 
********************************************************************************


********************************************************************************
* Table A.1
********************************************************************************


use "$pathdata\pwt91_merged.dta", clear

	encode country, g(ctry)
	g pre=0
	replace pre=1 if year<reher_transitionyear
	g post=0
	replace post=1 if year>=reher_transitionyear

	g rgdpnacapita = rgdpna/pop
	g ln_rgdpnacapita = ln(rgdpnacapita)
	g lnhc = ln(hc)
	g k_emp = rnna/emp
	g ln_k_emp=ln(rnna/emp)
	g postkemp = post * ln_k_emp
	g prekemp = pre * ln_k_emp

	keep if year==1950 | year==1970 | year==1990 | year==2010
	bysort ctry year: keep if _n==1
	tsset ctry year, delta(20)

	egen edu_min = min(lnhc) 
	egen edu_max = max(lnhc) 
	g edu_index = ((lnhc-edu_min)/(edu_max-edu_min))
	g pre_edu_index = pre*edu_index
	g post_edu_index = post*edu_index

	label variable edu_index "HC"
	label variable pre_edu_index "HC (pre-transition)"
	label variable post_edu_index "HC (post-transition)"
	
eststo table_a1_1a: reg ln_rgdpnacapita L.ln_rgdpnacapita ln_k_emp edu_index i.year i.ctry, cluster(ctry) robust
g baselinesample = e(sample)
eststo table_a1_1b: reg ln_rgdpnacapita L.ln_rgdpnacapita if baselinesample==1, cluster(ctry) robust
eststo table_a1_1c: reg ln_rgdpnacapita ln_k_emp if baselinesample==1, cluster(ctry) robust
eststo table_a1_1d: reg ln_rgdpnacapita edu_index if baselinesample==1, cluster(ctry) robust
eststo table_a1_1e: reg ln_rgdpnacapita i.year i.ctry if baselinesample==1, cluster(ctry) robust

eststo table_a1_2a: reg ln_rgdpnacapita L.ln_rgdpnacapita prekemp postkemp pre_edu_index post_edu_index i.year i.ctry, cluster(ctry) robust
replace baselinesample = e(sample)
eststo table_a1_2b: reg ln_rgdpnacapita L.ln_rgdpnacapita if baselinesample==1, cluster(ctry) robust
eststo table_a1_2c: reg ln_rgdpnacapita prekemp postkemp if baselinesample==1, cluster(ctry) robust
eststo table_a1_2d: reg ln_rgdpnacapita pre_edu_index post_edu_index if baselinesample==1, cluster(ctry) robust
eststo table_a1_2e: reg ln_rgdpnacapita i.year i.ctry if baselinesample==1, cluster(ctry) robust


use  "$pathout\ysft_data_full_20_years.dta", clear	

	g ln_hc = ln(1+e)
	g prek = pre*k
	g postk = post*k

	egen edu_min = min(ln_hc) 
	egen edu_max = max(ln_hc) 
	g edu_index = ((ln_hc-edu_min)/(edu_max-edu_min))

	keep if year==1960 |  year==1980 | year==2000 | year==2020

	tsset id year, delta(20)
	g ly = L.y
	g pre_edu_index = pre*edu_index
	g post_edu_index = post*edu_index

	label variable edu_index "HC"
	label variable pre_edu_index "HC (pre-transition)"
	label variable post_edu_index "HC (post-transition)"

	label variable k "$\ln k_{t}$"
	label variable prek "$\ln k_{t}\cdot PRE$"
	label variable postk "$\ln k_{t}\cdot POST$"
	label variable ly "$\ln y_{t-1}$"


eststo table_a1_3a: reg y ly k edu_index i.year i.id, cluster(id) robust
g baselinesample = e(sample)
eststo table_a1_3b: reg y ly  if baselinesample ==1 , cluster(id) robust
eststo table_a1_3c: reg y k if baselinesample ==1, cluster(id) robust
eststo table_a1_3d: reg y edu_index if baselinesample ==1, cluster(id) robust
eststo table_a1_3e: reg y i.year i.id if baselinesample ==1, cluster(id) robust

eststo table_a1_4a: reg y ly prek postk pre_edu_index post_edu_index i.year i.id, cluster(id) robust
replace baselinesample = e(sample)
eststo table_a1_4b: reg y ly  if baselinesample ==1 , cluster(id) robust
eststo table_a1_4c: reg y prek postk if baselinesample ==1, cluster(id) robust
eststo table_a1_4d: reg y pre_edu_index post_edu_index if baselinesample ==1, cluster(id) robust
eststo table_a1_4e: reg y i.year i.id if baselinesample ==1, cluster(id) robust


use  "$pathout\ysft_data_full_20_years_extension.dta", clear	

	g ln_hc = ln(1+e)
	g prek = pre*k
	g postk = post*k

	egen edu_min = min(ln_hc) 
	egen edu_max = max(ln_hc) 
	g edu_index = ((ln_hc-edu_min)/(edu_max-edu_min))

	keep if year==1960 |  year==1980 | year==2000 | year==2020

	tsset id year, delta(20)
	g ly = L.y
	g pre_edu_index = pre*edu_index
	g post_edu_index = post*edu_index

	label variable edu_index "HC"
	label variable pre_edu_index "HC (pre-transition)"
	label variable post_edu_index "HC (post-transition)"

	label variable k "$\ln k_{t}$"
	label variable prek "$\ln k_{t}\cdot PRE$"
	label variable postk "$\ln k_{t}\cdot POST$"
	label variable ly "$\ln y_{t-1}$"
	
eststo table_a1_5a: reg y ly k edu_index i.year i.id, cluster(id) robust
g baselinesample = e(sample)
eststo table_a1_5b: reg y ly  if baselinesample ==1 , cluster(id) robust
eststo table_a1_5c: reg y k if baselinesample ==1, cluster(id) robust
eststo table_a1_5d: reg y edu_index if baselinesample ==1, cluster(id) robust
eststo table_a1_5e: reg y i.year i.id if baselinesample ==1, cluster(id) robust


eststo table_a1_6a: reg y ly prek postk pre_edu_index post_edu_index i.year i.id, cluster(id) robust
replace baselinesample = e(sample)
eststo table_a1_6b: reg y ly  if baselinesample ==1 , cluster(id) robust
eststo table_a1_6c: reg y prek postk if baselinesample ==1, cluster(id) robust
eststo table_a1_6d: reg y pre_edu_index post_edu_index if baselinesample ==1, cluster(id) robust
eststo table_a1_6e: reg y i.year i.id if baselinesample ==1, cluster(id) robust


esttab table_a1_1a table_a1_1b table_a1_1c table_a1_1d table_a1_1e using "$pathresults/Table_A1.tex" , booktabs nonotes replace compress drop(_cons *ln_rgdpnacapita *ln_k_emp *edu_index *year *ctry) se(2) b(a2) r2(3) mlabels(,none) collabels(,none) star(* 0.101 ** 0.05 *** 0.01) prehead("{\begin{tabular}{l*{5}{c}}\toprule&\multicolumn{5}{c}{R-squared}\\[.1cm] \cmidrule(lr){2-6} &\multicolumn{5}{c}{data, 20-year panel} \\ Specification & Full & GDP p.c. (t-1) & k & h & 2-way f.e.\\ \cmidrule(lr){2-6}")

esttab table_a1_2a table_a1_2b table_a1_2c table_a1_2d table_a1_2e  using "$pathresults/Table_A1.tex" , booktabs nonotes append compress drop(_cons *ln_rgdpnacapita *pre* *post* *year *ctry) se(2) b(a2) r2(3)  star(* 0.101 ** 0.05 *** 0.01) mlabels(,none) collabels(,none)


esttab table_a1_3a table_a1_3b table_a1_3c table_a1_3d table_a1_3e using "$pathresults/Table_A1.tex" , booktabs nonotes append compress drop(_cons *ly *k *edu_index *year *id) se(2) b(a2) r2(3) mlabels(,none) collabels(,none) star(* 0.101 ** 0.05 *** 0.01) prehead("{\begin{tabular}{l*{5}{c}}\toprule&\multicolumn{5}{c}{R-squared}\\[.1cm] \cmidrule(lr){2-6} &\multicolumn{5}{c}{data, 20-year panel} \\ Specification & Full & GDP p.c. (t-1) & k & h & 2-way f.e.\\ \cmidrule(lr){2-6}")


esttab table_a1_4a table_a1_4b table_a1_4c table_a1_4d table_a1_4e using "$pathresults/Table_A1.tex" , booktabs nonotes append compress drop(_cons *ly *prek *postk *pre_edu_index *post_edu_index *year *id) se(2) b(a2) r2(3)  star(* 0.101 ** 0.05 *** 0.01) mlabels(,none) collabels(,none)


esttab table_a1_5a table_a1_5b table_a1_5c table_a1_5d table_a1_5e  using "$pathresults/Table_A1.tex" , booktabs nonotes append compress drop(_cons *ly *k *edu_index *year *id) se(2) b(a2) r2(3)  star(* 0.101 ** 0.05 *** 0.01) mlabels(,none) collabels(,none)


esttab table_a1_6a table_a1_6b table_a1_6c table_a1_6d table_a1_6e  using "$pathresults/Table_A1.tex" , booktabs nonotes append compress drop(_cons *ly *prek *postk *pre_edu_index *post_edu_index *year *id) se(2) b(a2) r2(3)  star(* 0.101 ** 0.05 *** 0.01) mlabels(,none) collabels(,none)

eststo clear



********************************************************************************
* Table A.2
********************************************************************************


use "$pathdata\Comin_Mestrieri_replication.dta", clear

	sort tech_no
	by tech_no: gen count_obs_tech = _n
	by tech_no: egen observations_by_technology2 = max(count_obs_tech)
	gen weight = 1/observations_by_technology2

	*ainv is invention date minus 1800
	gen ainv = inventionyear-1820
	gen loglagsprecise = ln(lagsprecise)

	g forerunner = 0
	replace forerunner = 1 if category=="forerunner"
	g follower = 0
	replace follower = 1 if category=="follower"
	g trailer = 0 
	replace trailer = 1 if category=="trailer"
	g latecomer = 0 
	replace latecomer = 1 if category=="latecomer"
	g postatinvention = 0
	replace postatinvention = 1 if reher_transitionyear>=inventionyear

	g adoptionyear = inventionyear+lagsprecise
	g postatadoption = 0
	replace postatadoption = 1 if reher_transitionyear>=adoptionyear

	g interaction = (ainv*reher_transitionyear)/100
	g intiatinvention = ainv*postatinvention
	g intiatadoption = ainv*postatadoption

	tabstat intensive, by (technology) s(count mean sd p10 p50 p90  cv iqr) f(%5.2f)

	keep if reher_transitionyear!=.

	label variable ainv "Invention Year-1820"
	label variable reher_transitionyear "Year of Demogr. Tr."

eststo table_A2_A1: reg loglagsprecise ainv if wes==1 [pweight=weight], clus(country_no)
eststo table_A2_A2: reg loglagsprecise ainv reher_transitionyear if wes==1 [pweight=weight], clus(country_no)
eststo table_A2_A3: reg loglagsprecise ainv follower trailer latecomer if wes==1 [pweight=weight], clus(country_no)

eststo table_A2_A4: reg intensive ainv if wes==1 [pweight=weight], clus(country_no)
eststo table_A2_A5: reg intensive ainv reher_transitionyear if wes==1 [pweight=weight], clus(country_no)
eststo table_A2_A6: reg intensive ainv follower trailer latecomer if wes==1 [pweight=weight], clus(country_no)


eststo table_A2_B1: reg loglagsprecise ainv if wes==0 [pweight=weight], clus(country_no)
eststo table_A2_B2: reg loglagsprecise ainv reher_transitionyear if wes==0 [pweight=weight], clus(country_no)
eststo table_A2_B3: reg loglagsprecise ainv follower trailer latecomer if wes==0 [pweight=weight], clus(country_no)

eststo table_A2_B4: reg intensive ainv if wes==0 [pweight=weight], clus(country_no)
eststo table_A2_B5: reg intensive ainv reher_transitionyear if wes==0 [pweight=weight], clus(country_no)
eststo table_A2_B6: reg intensive ainv follower trailer latecomer if wes==0 [pweight=weight], clus(country_no)

esttab table_A2_A1 table_A2_A2 table_A2_A3 table_A2_A4 table_A2_A5 table_A2_A6 using "$pathresults/Table A2.tex" , booktabs nonotes replace compress label nomtitles se(2) b(a2) r2(2) drop(_cons)  star(* 0.10 ** 0.05 *** 0.01) prehead("{\begin{tabular}{l*{6}{c}}\toprule\toprule&\multicolumn{6}{c}{Western Countries:} \\  \multicolumn{1}{l}{Dependent Variable:}&\multicolumn{3}{c}{Log [Adoption Lag]}&\multicolumn{3}{c}{Log [Intensity]}\\[.1cm]  \cmidrule(lr){2-4}\cmidrule(lr){5-7}")

esttab table_A2_B1 table_A2_B2 table_A2_B3 table_A2_B4 table_A2_B5 table_A2_B6  using "$pathresults/Table A2.tex" , booktabs nonotes append compress label nomtitles se(2) b(a2) r2(2) drop(_cons)  star(* 0.10 ** 0.05 *** 0.01) prehead("{\begin{tabular}{l*{6}{c}}\toprule&\multicolumn{6}{c}{Non-Western Countries:} \\  \multicolumn{1}{l}{Dependent Variable:}&\multicolumn{3}{c}{Log [Adoption Lag]}&\multicolumn{3}{c}{Log [Intensity]}\\[.1cm]  \cmidrule(lr){2-4}\cmidrule(lr){5-7}")

eststo clear



********************************************************************************
* Table A.3
********************************************************************************

insheet using "$pathout\ysft_data_comin.txt", clear
rename v1 country
rename v2 technology 
* technology: number (1 == unskilled, 2 == skilled) 
rename v3 invention_year
rename v4 adoption_lag
rename v5 intensity
rename v6 transition_year

g forerunner = (transition_year<1935)
g follower = 0
replace follower =1 if transition_year>=1935 & transition_year<1965
g trailer = 0
replace trailer =1 if transition_year>=1965 & transition_year<1980
g latecomer = 0
replace latecomer=1 if transition_year>=1980


g ln_adoptionlag = ln(adoption_lag)
g ln_intensity = ln(intensity)

eststo table_cm_sim1: reg ln_adoptionlag invention_year, clus(country)
eststo table_cm_sim2: reg ln_adoptionlag invention_year transition_year, clus(country)
eststo table_cm_sim3: reg ln_adoptionlag invention_year follower latecomer, clus(country)

eststo table_cm_sim4: reg ln_intensity invention_year, clus(country)
eststo table_cm_sim5: reg ln_intensity invention_year transition_year, clus(country)
eststo table_cm_sim6: reg ln_intensity invention_year follower latecomer, clus(country)

label variable invention_year "Invention Year-1820"
label variable transition_year "Year of Demogr. Tr."

label variable follower "Follower Country"
label variable trailer "Trailer Country"
label variable latecomer "Latecomer Country"


esttab table_cm_sim1 table_cm_sim2 table_cm_sim3 table_cm_sim4 table_cm_sim5 table_cm_sim6 using "$pathresults/Table_A3.tex" , booktabs nonotes replace compress label nomtitles se(2) b(a2) r2(2) drop(_cons)  star(* 0.10 ** 0.05 *** 0.01) prehead("{\begin{tabular}{l*{6}{c}}\toprule&\multicolumn{6}{c}{Dependent variable:} \\ &\multicolumn{3}{c}{Log [Adoption Lag]}&\multicolumn{3}{c}{Log [Intensity]}\\[.1cm]  \cmidrule(lr){2-4}\cmidrule(lr){5-7}")

eststo clear



********************************************************************************
* Figure A.1
********************************************************************************
	
use  "$pathout\ysft_data_full_20_years.dta", clear
* Plot for England: 13
keep if id==13

	g labin = (w_L*L + w_H*H)/(Y_S+Y_U)
	label variable labin "Labor Income Share"
	g capin = (R*K)/(Y_S+Y_U)
	label variable capin "Capital Income Share"

preserve
	
merge 1:1 year using "$pathdata\Crafts2021_GDPshares.dta"
	replace capshare=capshare/100
	sort year
	label variable year "Year"

twoway line  capin year,  lcolor(cranberry) || line capshare year ,lcolor(navy) lpattern(_) || if year>=1760& year<=1880 , xlabel(1760(20)1880) legend(col(1) label(1 "Capital Share of GDP (Model)") label(2 "Capital Share of GDP (Data)")) ylabel(0.15(0.05)0.35)
graph export "$pathresults/Figure_A1a.pdf", replace

restore

g r_model = (R^(1/20)-1) *100
label variable r_model "Capital Return (p.a., pct.)"
su r_model if year==1700
g r_model_norm= r_model/2.65254

g r_model_detrend  = (R^(1/20)-1)/(Y_S+Y_U)
su r_model_detrend if year==1700
replace r_model_detrend = r_model_detrend/.0133815

merge 1:1 year using "$pathdata\Schmelzing_FigIV_original_5.dta"
	sort year
	label variable year "Year"
	su real_rate if year == 1700
	g RR_norm = real_rate/6.705

twoway line r_model_norm year , lcolor(cranberry) || line r_model_detrend year , lcolor(cranberry) lpattern(_) || line RR_norm year , lcolor(navy)lpattern(_)||if year>=1700& year<=2020 , xlabel(1700(100)2000) legend(col(1) label(1 "Real Return (1700=1, model)")  label(2 "Real Return (detrended, 1700=1, model)") label(3 "Real Return (1700=1, data)")) ylabel(-1(0.5)1.5)
graph export "$pathresults/Figure_A1b.pdf", replace


********************************************************************************
* Figure A.2
********************************************************************************

drop _m

merge 1:1 year using "$pathdata\Clark_REH2010_Table7.dta"
sort year

twoway line r_model year ,  lcolor(cranberry) ||  line return_on_capital year ,  lcolor(navy)lpattern(_)||if year>=1680& year<=1880 , xlabel(1680(20)1880) legend(col(1) label(1 "Real Return (annualized %, model)")  label(2 "Real Return (annualized %, data)"))ylabel(-10(5)10)
graph export "$pathresults/Figure_A2a.pdf", replace

twoway line r_model_norm year , lcolor(cranberry) || line return_on_cap_norm year , lcolor(navy) lpattern(_)||if year>=1680& year<=1880 , xlabel(1680(20)1880) legend(col(1) label(1 "Real Return (1700=1, model)") label(2 "Real Return (1700=1, data)")) ylabel(-1(0.5)1.5)
graph export "$pathresults/Figure_A2c.pdf", replace

drop _m
merge 1:1 year using "$pathdata\Jorda_Schularick_Taylor_QJE2019_world_returns.dta"

sort year
su madec_r_capital_tr_simple r_model if year==1900
g rretw_norm = madec_r_capital_tr_simple/5.406644
g r_model_norm1900 = r_model/2.33499

twoway line r_model year ,  lcolor(cranberry) ||  line madec_r_capital_tr_simple year ,  lcolor(navy)lpattern(_)||if year>=1860& year<=2020 , xlabel(1860(20)2020) legend(col(1) label(1 "Real Return (annualized %, model)")  label(2 "Real Return (annualized %, data)"))ylabel(-10(5)10)
graph export "$pathresults/Figure_A2b.pdf", replace

twoway line r_model_norm1900 year , lcolor(cranberry) || line rretw_norm year , lcolor(navy) lpattern(_)||if year>=1860& year<=2020 , xlabel(1860(20)2020) legend(col(1) label(1 "Real Return (1900=1, model)") label(2 "Real Return (1900=1, data)")) ylabel(-1(0.5)1.5)
graph export "$pathresults/Figure_A2d.pdf", replace


********************************************************************************
* Figure A.3
********************************************************************************

use "$pathdata\pwt91_merged.dta", clear
	encode country, g(ctry)
	keep if year==1950 | year==1970 | year==1990 | year==2010
	bysort ctry year: keep if _n==1
	tsset ctry year, delta(20)
	g rgdpnacapita = rgdpna/pop
	g ln_rgdpnacapita = ln(rgdpnacapita)
	bysort year: egen y_max = max(ln_rgdpnacapita)
	g y_rel = ln_rgdpnacapita/y_max  
	tsset ctry year, delta(20)
	g growth = D.ln_rgdpnacapita / 20
	g y_rel_lag = L.y_rel
binscatter growth y_rel, ylabel(-0.01(0.01)0.04) xlabel(0.5(0.1)1) legend(off) ytitle(GDP p.c. Growth) xtitle(GDP p.c. Relative to Highest) line(qfit)
graph export "$pathresults/Figure_A3a.pdf", replace


use  "$pathout\ysft_data_full_20_years_extension.dta", clear	
	keep if  year==1960 |  year==1980 | year==2000 | year==2020
	su y if id==13 & year==1940
	bysort year: egen y_max = max(y)
	g y_rel = y/y_max
	g y_rel50 = y/2.656099
	tsset id year, delta(20)
	g growth = D.y / 20
	g y_rel_lag = L.y_rel
binscatter growth y_rel , mcolor(cranberry) ylabel(-0.01(0.01)0.04) xlabel(0.5(0.1)1) legend(off) ytitle(GDP p.c. Growth) xtitle(GDP p.c. Relative to Highest) line(qfit)
graph export "$pathresults/Figure_A3b.pdf", replace
