********************************************************************************
*  DATA ANALYSIS FOR PROJECT        										
*																			
*  THE EMPIRICS OF ECONOMIC GROWTH OVER TIME AND ACROSS NATIONS 		 	
*  A UNIFIED GROWTH PERSPECTIVE        										
*                                   										
*  MATTEO CERVELLATI, GERRIT MEYERHEIM, AND UWE SUNDE                       
*  19.9.2022                        											
*                                   										
********************************************************************************                                     

********************************************************************************
*  Note:   this file generates data sets for analysis
*           - I. 	baseline simulation (see simulations for code!)
*           - II. 	simulation extension: technology diffusion
*			- III. 	simulation extension: population undershooting
********************************************************************************

*  Plain: no background color *
set scheme s1color


********************************************************************************                                     
* SIMULATION DATA: INSHEETING AND CONSTRUCTING DATA SETS                 
********************************************************************************                                     

set more off
clear


                                                                    
********************************************************************************                                     
* I. SIMULATION DATA: MANY COUNTRIES -- 20 YEARS  			             
********************************************************************************                                     


insheet using "$pathout/ysft_data_full_20_years.txt", clear
rename v1 id      
rename v2 year    
rename v3 N
rename v4 Y_U
rename v5 L
rename v6 A_U                                                           
rename v7 Y_S                                                             
rename v8 H                                                           
rename v9 A_S                                                            
rename v10 K                                                          
rename v11 w_L                                                          
rename v12 w_H                                                            
rename v13 R                                                            
rename v14 e                                                            
rename v15 s                                                            
rename v16 n                                                          
rename v17 tso                                                          
rename v18 g_N                                                          
rename v19 g_y                                                          

tsset id year, delta(20)
g hc = (1+e)
g Y = Y_U+Y_S
g lnY = ln(Y)
g lnK = ln(K)
g lnL = ln(L)
g lnN = ln(N)
g dlnY = lnY-L.lnY
g y = ln(Y/N)
g dlny = y-L.y
g growth_pa = exp(dlnY/20)-1
g growth_pc_pa = exp(dlny/20)-1
g popgrowth = exp(D.lnN/20)-1
g k = ln(K/L.L)
g x = Y/Y_S
*replace hc = exp(hc)
label variable growth_pa "Output Growth"
label variable growth_pc_pa "Output per capita Growth"
label variable popgrowth "Population Growth"
label variable y "ln GDP p.c."
label variable k "ln capital p.c."
label variable H "human capital index"
label variable tso "TSO (time since onset)"
label variable x "Y/Y_M"
label variable Y "ln GDP"
label variable N "Population"

g yearonset=year if tso==0
bysort id: egen yearofonset = max(yearonset)
g forerunner = (yearofonset<=1964)
g latecomer = (yearofonset>1964)
g timesinceonset = tso
replace tso = tso/100
replace tso = 0 if tso<0
g tsosq = tso^2
g pre = (timesinceonset<0)
g post = (timesinceonset>=0)
g baseline =0
save "$pathout/ysft_data_full_20_years.dta", replace
                                                       

                                                                    
********************************************************************************                                     
* II. SIMULATION DATA: MANY COUNTRIES -- 20 YEARS --- EXTENSION ---      
********************************************************************************                                     

insheet using "$pathout/ysft_data_full_20_years_extension.txt", clear
rename v1 id      
rename v2 year    
rename v3 N
rename v4 Y_U
rename v5 L
rename v6 A_U                                                           
rename v7 Y_S                                                             
rename v8 H                                                           
rename v9 A_S                                                            
rename v10 K                                                          
rename v11 w_L                                                          
rename v12 w_H                                                            
rename v13 R                                                            
rename v14 e                                                            
rename v15 s                                                            
rename v16 n                                                          
rename v17 tso                                                          
rename v18 g_N                                                          
rename v19 g_y                                                        

replace id = id+1000
tsset id year, delta(20)
g hc = (1+e)
g Y = Y_U+Y_S
g lnY = ln(Y)
g lnK = ln(K)
g lnL = ln(L)
g lnN = ln(N)
g dlnY = lnY-L.lnY
g y = ln(Y/N)
g dlny = y-L.y
g growth_pa = exp(dlnY/20)-1
g growth_pc_pa = exp(dlny/20)-1
g popgrowth = exp(D.lnN/20)-1
g k = ln(K/L.L)
g x = Y/Y_S
*replace hc = exp(hc)
label variable growth_pa "Output Growth"
label variable growth_pc_pa "Output per capita Growth"
label variable popgrowth "Population Growth"
label variable y "ln GDP p.c."
label variable k "ln capital p.c."
label variable H "human capital index"
label variable tso "TSO (time since onset)"
label variable x "Y/Y_M"
label variable Y "ln GDP"
label variable N "Population"

g yearonset=year if tso==0
bysort id: egen yearofonset = max(yearonset)
g forerunner = (yearofonset<=1964)
g latecomer = (yearofonset>1964)
g timesinceonset = tso
replace tso = tso/100
replace tso = 0 if tso<0
g tsosq = tso^2
g pre = (timesinceonset<0)
g post = (timesinceonset>=0)

g extension=1
g baseline=0
save "$pathout/ysft_data_full_20_years_extension.dta", replace


********************************************************************************                                     
* III. SIMULATION DATA: MANY COUNTRIES / POPULATION UNDERSHOOTING        
********************************************************************************                                     

insheet using "$pathout/ysft_data_full_20_years_undershooting.txt", clear
rename v1 id      
rename v2 year    
rename v3 N
rename v4 Y_U
rename v5 L
rename v6 A_U                                                           
rename v7 Y_S                                                             
rename v8 H                                                           
rename v9 A_S                                                            
rename v10 K                                                          
rename v11 w_L                                                          
rename v12 w_H                                                            
rename v13 R                                                            
rename v14 e                                                            
rename v15 s                                                            
rename v16 n                                                          
rename v17 tso                                                          
rename v18 g_N                                                          
rename v19 g_y                                                             

replace id = id+1000
tsset id year, delta(20)
g hc = (1+e)
g Y = Y_U+Y_S
g lnY = ln(Y)
g lnK = ln(K)
g lnL = ln(L)
g lnN = ln(N)
g dlnY = lnY-L.lnY
g y = ln(Y/N)
g dlny = y-L.y
g growth_pa = exp(dlnY/20)-1
g growth_pc_pa = exp(dlny/20)-1
g popgrowth = exp(D.lnN/20)-1
g k = ln(K/L.L)
g x = Y/Y_S
*replace hc = exp(hc)
label variable growth_pa "Output Growth"
label variable growth_pc_pa "Output per capita Growth"
label variable popgrowth "Population Growth"
label variable y "ln GDP p.c."
label variable k "ln capital p.c."
label variable H "human capital index"
label variable tso "TSO (time since onset)"
label variable x "Y/Y_M"
label variable Y "ln GDP"
label variable N "Population"

g yearonset=year if tso==0
bysort id: egen yearofonset = max(yearonset)
g forerunner = (yearofonset<=1964)
g latecomer = (yearofonset>1964)
g timesinceonset = tso
replace tso = tso/100
replace tso = 0 if tso<0
g tsosq = tso^2
g pre = (timesinceonset<0)
g post = (timesinceonset>=0)

g extension=2
g baseline=0
save "$pathout/ysft_data_full_20_years_undershooting.dta", replace

********************************************************************************