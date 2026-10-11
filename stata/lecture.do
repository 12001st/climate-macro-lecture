cls
clear
// Working directory: the folder containing this file (cd to it if needed)

********************************************************************************
***************** TABLE 1 (Time Series)   250417 *******************************
********************************************************************************

import excel  "data/countrylevel_allyearsdeseason.xlsx", sheet("Sheet1") firstrow clear
browse

destring temp_mean_win temp_mean_spr temp_mean, replace
destring temp_mean_fall, replace

tsset YEAR

* Descriptive stat.
sum temp_mean temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall
sum growthGDP

// Replace a variable / generate new variable
replace growthGDP = growthGDP*100
gen laggrowthGDP = L.growthGDP

// Table 1, Eq.(1) 연중
regress growthGDP temp_mean laggrowthGDP

// T1, Eq(2) 계절별
reg growthGDP temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall laggrowthGDP


********************************************************************************
***************** TABLE 1 (Panel)    250424 ************************************
********************************************************************************

import excel  "data/statelevel_allyearsdeseason.xlsx", sheet("Sheet1") firstrow clear
browse

order FIPS YEAR

xtset FIPS YEAR

xtsum growthGSP temp_mean 

replace growthGSP = growthGSP*100
gen laggrowthGSP = L.growthGSP

// 주별 가중치 구하기
egen totalGSP = sum(GSP)
bysort FIPS: egen stateGSP = sum(GSP)
gen GSP_weight = stateGSP/totalGSP

// Eq. (3) 주별, 연중
reg growthGSP temp_mean laggrowthGSP i.FIPS i.YEAR [weight = GSP_weight], vce(cluster YEAR)
reg growthGSP temp_mean laggrowthGSP i.FIPS i.YEAR [weight = GSP_weight], vce(cluster FIPS)

// Eq. (4) 주별, 계절별
reg growthGSP temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall laggrowthGSP i.FIPS i.YEAR [weight = GSP_weight], vce(cluster YEAR)
reg growthGSP temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall laggrowthGSP i.FIPS i.YEAR [weight = GSP_weight], vce(cluster FIPS)

reg growthGSP temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall laggrowthGSP i.FIPS i.YEAR, vce(cluster YEAR)
reg growthGSP temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall laggrowthGSP i.FIPS i.YEAR, vce(cluster FIPS)

***********************************


********************************************************************************
***************** TABLE 2 (Cumulative effects) *********************************
********************************************************************************
xtset FIPS YEAR

// Eq.(8)

reg growthGSP temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall ///
				L.temp_mean_win L.temp_mean_spr L.temp_mean_sum L.temp_mean_fall  ///
				laggrowthGSP i.FIPS i.YEAR [weight = GSP_weight], vce(cluster YEAR)

reg growthGSP temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall ///
				L.temp_mean_win L.temp_mean_spr L.temp_mean_sum L.temp_mean_fall  ///
				laggrowthGSP i.FIPS i.YEAR [weight = GSP_weight], vce(cluster FIPS)

// 방법1: sum of coefficients & Wald tests

gen temp_win = temp_mean_win - L.temp_mean_win
gen temp_spr = temp_mean_spr - L.temp_mean_spr
gen temp_sum = temp_mean_sum - L.temp_mean_sum
gen temp_fall = temp_mean_fall - L.temp_mean_fall


reg growthGSP temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall ///
				temp_win temp_spr temp_sum temp_fall ///
				laggrowthGSP i.FIPS i.YEAR [weight = GSP_weight], vce(cluster YEAR)				
				
				
reg growthGSP temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall ///
				temp_win temp_spr temp_sum temp_fall ///
				laggrowthGSP i.FIPS i.YEAR [weight = GSP_weight], vce(cluster FIPS)					
				
				
// 방법2: sum of coefficients & Wald tests				
				
reg growthGSP temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall ///
				L.temp_mean_win L.temp_mean_spr L.temp_mean_sum L.temp_mean_fall  ///
				laggrowthGSP i.FIPS i.YEAR [weight = GSP_weight], vce(cluster YEAR)
				
lincom temp_mean_win + L.temp_mean_win
lincom temp_mean_sum + L.temp_mean_sum

save "data/statelevel_allyearsdeseason.dta", replace


********************************************************************************
************* FIGURE 3 (Rolling regressions; 관계변화 and/or 강건성) **************
********************************************************************************
////// 프로그램 껐다가 다시 켰다면,

cls
clear
// Working directory: the folder containing this file (cd to it if needed)
use "data/statelevel_allyearsdeseason.dta", clear
browse

forvalues x=1958/1990 {

egen totalGSP`x' = sum(GSP) if YEAR>=`x'
bysort FIPS: egen stateGSP`x' = sum(GSP) if YEAR>=`x'
gen GSP_weight`x'= stateGSP`x'/totalGSP`x'
}

matrix F3=J(33,12,0)
matrix list F3

scalar i=1
local ryear ""

forvalues x=1958/1990 {
preserve
quietly reg growthGSP temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall laggrowthGSP i.FIPS i.YEAR [pw=GSP_weight`x'] if YEAR>=`x', vce(cluster YEAR) level(90)

parmest, norestore label level(90)

mat F3[i,1]=_b[temp_mean_win]
mat F3[i,2]=_b[temp_mean_spr]
mat F3[i,3]=_b[temp_mean_sum]
mat F3[i,4]=_b[temp_mean_fall]
mat F3[i,5]=max90[1]
mat F3[i,6]=max90[2]
mat F3[i,7]=max90[3]
mat F3[i,8]=max90[4]
mat F3[i,9]=min90[1]
mat F3[i,10]=min90[2]
mat F3[i,11]=min90[3]
mat F3[i,12]=min90[4]

local ryear `"`ryear'"`x'" "'
scalar i=i+1
restore
}

matrix rownames F3 = `ryear'
matrix colnames F3 = "Winter" "Spring" "Summer" "Fall" "CI Winter" "CI Spring" "CI Summer" "CI Fall" "CI Winter" "CI Spring" "CI Summer" "CI Fall"
matrix list F3

putexcel set "results/Figure3.xlsx", sheet("Sheet1") replace
putexcel A1 = matrix(F3), names


coefplot (matrix(F3[,1])), vertical ci((F3[,5] F3[,9])) recast(scatter) ///
ciopts(recast(rline)) ylabel(-0.5(0.1)0.3) saving ("results/F3Winter.gph", replace)

coefplot (matrix(F3[,2])), vertical ci((F3[,6] F3[,10])) recast(scatter) ///
ciopts(recast(rline)) ylabel(-0.5(0.1)0.3) saving ("results/F3Spring.gph", replace)

coefplot (matrix(F3[,3])), vertical ci((F3[,7] F3[,11])) recast(scatter) ///
ciopts(recast(rline)) ylabel(-0.5(0.1)0.3) saving ("results/F3Summer.gph", replace)

coefplot (matrix(F3[,4])), vertical ci((F3[,8] F3[,12])) recast(scatter) ///
ciopts(recast(rline)) ylabel(-0.5(0.1)0.3) saving ("results/F3Fall.gph", replace)

graph combine "results/F3Winter.gph" "results/F3Spring.gph" "results/F3Summer.gph" "results/F3Fall.gph"
graph export "results/Fig3.png", width(1200) height(900) replace



// 5.15
********************************************************************************
*********** TABLE 3 (Mechanism: Labor Quality vs Quantity) *********************
********************************************************************************

clear
import excel "data/All_employees_Total_Private.xlsx", sheet("Sheet1") firstrow clear
browse

merge 1:1 YEAR State using "data/statelevel_allyearsdeseason.dta"
drop if _merge==1 | _merge==2 
drop _merge
sort FIPS YEAR
order FIPS YEAR StateName
save "data/temp1.dta", replace

import excel "data/PrivateIndustry.xlsx", sheet("Sheet1") firstrow clear
browse
merge 1:1 YEAR FIPS using "data/temp1.dta"
drop if _merge==1 | _merge==2 
drop _merge
sort FIPS YEAR
order FIPS YEAR StateName


* eq.(9) <-- basically corresponding to eq.(4)
xtset FIPS YEAR

gen labor_prod = IndOutputNAICS / private_emp if YEAR >=1998 
replace labor_prod = IndOutputSIC / private_emp if YEAR <1998
gen growthprod = (log(labor_prod) - log(L.labor_prod))*100
gen growthemp = (log(private_emp) - log(L.private_emp))*100

// ssc install estout, replace

est clear
eststo: qui reg growthprod temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall L.growthprod i.FIPS i.YEAR [weight = GSP_weight], vce(cluster YEAR)
eststo: qui reg growthprod temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall L.growthprod i.FIPS i.YEAR [weight = GSP_weight], vce(cluster FIPS)
eststo: qui reg growthemp temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall L.growthemp i.FIPS i.YEAR [pw=GSP_weight], vce(cluster YEAR)
eststo: qui reg growthemp temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall L.growthemp i.FIPS i.YEAR [pw=GSP_weight], vce(cluster FIPS)

estout, cells(b(star fmt(3)) se(par fmt(3))) stat(N r2) starlevel(* .1 ** .05 *** .01) drop(*.FIPS *.YEAR)

esttab using "results/Table3.rtf", replace title(TABLE3) cells(b(star fmt(3)) se(par fmt(3))) stat(N r2) starlevel(* .1 ** .05 *** .01) drop(*.FIPS *.YEAR)
