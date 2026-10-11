cls
clear
// Working directory: the folder containing this file (cd to it if needed)

********************************************************************************
***************** TABLE 1 (Time Series) ****************************************
********************************************************************************

import excel "data/countrylevel_allyearsdeseason.xlsx", sheet("Sheet1") firstrow clear
browse

destring temp_mean_spr temp_mean_fall temp_mean, replace

tsset YEAR
replace growthGDP = growthGDP*100
gen laggrowthGDP = L.growthGDP

* Descriptive stat.
sum growthGDP temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall temp_mean

* eq.(1) US, 연중
reg growthGDP temp_mean laggrowthGDP

* eq.(2) US, 계절별
reg growthGDP temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall laggrowthGDP

********************************************************************************
***************** TABLE 1 (Panel) **********************************************
********************************************************************************

import excel "data/statelevel_allyearsdeseason.xlsx", sheet("Sheet1") firstrow clear
browse

order FIPS YEAR StateName

xtset FIPS YEAR
replace growthGSP = growthGSP*100
generate laggrowthGSP = L.growthGSP

egen totalGSP = sum(GSP)
bysort FIPS: egen stateGSP = sum(GSP)
gen GSP_weight= stateGSP/totalGSP

* Descriptive stats.
xtsum growthGSP temp_mean temp_mean_spr temp_mean_sum temp_mean_fall temp_mean

* eq.(3) 주별, 연중
reg growthGSP temp_mean laggrowthGSP i.FIPS i.YEAR [pweight = GSP_weight], vce(cluster YEAR)
reg growthGSP temp_mean laggrowthGSP i.FIPS i.YEAR [pweight = GSP_weight], vce(cluster FIPS)
reg growthGSP temp_mean laggrowthGSP i.FIPS i.YEAR [pweight = GSP_weight], vce(cluster FIPS YEAR) 
// 그러나, 위의 경우 covariance matrix is NOT positive semidefinite. 위의 대안으로,
tabulate YEAR, gen(year)
tabulate FIPS, gen(fips)
xtivreg2 growthGSP temp_mean laggrowthGSP year* [pw=GSP_weight], fe partial(year*) cluster(FIPS YEAR)

* eq.(4), 주별, 계절
reg growthGSP temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall laggrowthGSP i.FIPS i.YEAR [pw=GSP_weight], vce(cluster YEAR)
reg growthGSP temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall laggrowthGSP i.FIPS i.YEAR [pw=GSP_weight], vce(cluster FIPS)
xtivreg2 growthGSP temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall laggrowthGSP fips* year* [pw=GSP_weight], fe partial(year*) cluster(FIPS YEAR)

********************************************************************************
***************** TABLE 2 (Cumulative effects) *********************************
********************************************************************************

* eq.(8), lagged effects of temperature on GDP growth rates

reg growthGSP temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall ///
				L.temp_mean_win L.temp_mean_spr L.temp_mean_sum L.temp_mean_fall  ///
				laggrowthGSP i.FIPS i.YEAR [weight = GSP_weight], vce(cluster YEAR)

reg growthGSP temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall ///
				L.temp_mean_win L.temp_mean_spr L.temp_mean_sum L.temp_mean_fall  ///
				laggrowthGSP i.FIPS i.YEAR [weight = GSP_weight], vce(cluster FIPS)

// 방법 1: sum of coefficients & Wald test
gen temp_win = temp_mean_win - L.temp_mean_win
gen temp_spr = temp_mean_spr - L.temp_mean_spr
gen temp_sum = temp_mean_sum - L.temp_mean_sum
gen temp_fall = temp_mean_fall - L.temp_mean_fall

reg growthGSP temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall temp_win temp_spr temp_sum temp_fall laggrowthGSP i.FIPS i.YEAR [pw=GSP_weight], vce(cluster YEAR)

reg growthGSP temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall temp_win temp_spr temp_sum temp_fall laggrowthGSP i.FIPS i.YEAR [pw=GSP_weight], vce(cluster FIPS)

// 방법 2: sum of coefficients & Wald test
reg growthGSP temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall temp_win temp_spr temp_sum temp_fall laggrowthGSP i.FIPS i.YEAR [pw=GSP_weight], vce(cluster YEAR)
lincom temp_mean_win + L.temp_mean_win
test temp_mean_win + L.temp_mean_win = 0
// ... (다른 계절들도 마찬가지)

reg growthGSP temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall temp_win temp_spr temp_sum temp_fall laggrowthGSP i.FIPS i.YEAR [pw=GSP_weight], vce(cluster FIPS)
lincom temp_mean_win + L.temp_mean_win
test temp_mean_win + L.temp_mean_win = 0
// ... (다른 계절들도 마찬가지)

save "data/statelevel_allyearsdeseason.dta", replace // 메모리에 있는 데이터셋 저장 for later use.


**** How to store the results? (estout 패키지 활용법)
// ssc install estout, replace

est clear

eststo: reg growthGSP temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall L.temp_mean_win L.temp_mean_spr L.temp_mean_sum L.temp_mean_fall laggrowthGSP i.FIPS i.YEAR [pw=GSP_weight], vce(cluster YEAR)

eststo: reg growthGSP temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall L.temp_mean_win L.temp_mean_spr L.temp_mean_sum L.temp_mean_fall laggrowthGSP i.FIPS i.YEAR [pw=GSP_weight], vce(cluster FIPS)

eststo: reg growthGSP temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall temp_win temp_spr temp_sum temp_fall laggrowthGSP i.FIPS i.YEAR [pw=GSP_weight], vce(cluster YEAR)

eststo: reg growthGSP temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall temp_win temp_spr temp_sum temp_fall laggrowthGSP i.FIPS i.YEAR [pw=GSP_weight], vce(cluster FIPS)

estout, cells(b(star fmt(3)) se(par fmt(3))) stat(N r2) starlevel(* .1 ** .05 *** .01) drop(*.FIPS *.YEAR)

esttab using "results/Table2.rtf", replace title(TABLE2) cells(b(star fmt(3)) se(par fmt(3))) stat(N r2) starlevel(* .1 ** .05 *** .01) drop(*.FIPS *.YEAR)


//-----------------------------------------------------------------------------//
**************** 껐다가 켰다면, ****************************************************
//-----------------------------------------------------------------------------//

cls
clear
// Working directory: the folder containing this file (cd to it if needed)
use "data/statelevel_allyearsdeseason.dta", replace
browse

********************************************************************************
************* FIGURE 3 (Rolling regressions; 관계변화 and/or 강건성) **************
********************************************************************************

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
qui reg growthGSP temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall laggrowthGSP i.FIPS i.YEAR [pw=GSP_weight`x'] if YEAR>=`x', vce(cluster YEAR) level(90)

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

gen labor_prod = IndOutputNAICS/private_emp if YEAR >=1998 
replace labor_prod = IndOutputSIC/private_emp if YEAR <1998
gen growthprod = (log(labor_prod) - log(L.labor_prod))*100

* 결과 요약/저장
// ssc install estout, replace

est clear
eststo: reg growthprod temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall l.growthprod i.FIPS i.YEAR [pw=GSP_weight], vce(cluster YEAR) 
eststo: reg growthprod temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall l.growthprod i.FIPS i.YEAR [pw=GSP_weight], vce(cluster FIPS)
estout, cells(b(star fmt(3)) se(par fmt(3))) stat(N r2) starlevel(* .1 ** .05 *** .01) drop(*.FIPS *.YEAR)


gen growthemp = (log(private_emp) - log(L.private_emp))*100

est clear
eststo: reg growthemp temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall l.growthemp i.FIPS i.YEAR [pw=GSP_weight], vce(cl YEAR)
eststo: reg growthemp temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall l.growthemp i.FIPS i.YEAR [pw=GSP_weight], vce(cl FIPS)
eststo: xtivreg2 growthemp temp_mean_win temp_mean_spr temp_mean_sum temp_mean_fall l.growthemp fips* year* [pw=GSP_weight], fe partial(year*) cluster(FIPS YEAR)
estout, cells(b(star fmt(3)) se(par fmt(3))) stat(N r2) starlevel(* .1 ** .05 *** .01) drop(*.FIPS *.YEAR)



//-----------------------------------------------------------------------------//
**************** 껐다가 켰다면, ****************************************************
//-----------------------------------------------------------------------------//

********************************************************************************
*********** Table 4 (Industry Analysis) ****************************************
********************************************************************************

cls
clear
// Working directory: the folder containing this file (cd to it if needed)
use "data/statelevel_allyearsdeseason.dta", replace
browse
save "data/temp1.dta", replace

//import delimited "data/CategoryOutput1963-1997.csv", varnames(1) clear
import delimited "data/CategoryOutput1997-2011.csv", varnames(1) clear
rename fips FIPS
rename year YEAR
replace FIPS=FIPS/1000
drop if FIPS>56
browse

egen USOutput=sum(output) if category==0 & FIPS==0
sort category FIPS
replace USOutput= USOutput[1] if USOutput==.
drop if FIPS==0
save "data/temp2.dta", replace

use "data/temp1.dta", clear
merge 1:m YEAR FIPS using "data/temp2.dta"
drop if _merge==1 | _merge==2 
drop _merge
sort FIPS YEAR
order FIPS category YEAR
sort FIPS category YEAR

bysort FIPS: egen GSoutput=sum(output)  // to check
bysort FIPS category: egen STATEOutput=sum(output)
bysort category: egen USCatOutput=sum(output) // to check

gen GSP_weight2 = GSoutput/USOutput // to check
gen Industryweights= STATEOutput/ USOutput
gen Industryweights2= STATEOutput/ USCatOutput // to check

sort FIPS category YEAR

gen growthOutput=(log(output) -log(output[_n-1]))*100
replace growthOutput=. if YEAR==1997 // added
gen laggrowthOutput = growthOutput[_n-1]
replace laggrowthOutput=. if YEAR==1997 // added

drop if YEAR==1997 // added

/*
0 "Gross State Product" 11 "Services" 12 "Finance, insurance,real estate" 4 "Manufacturing" ///
13 "Government" 10 "Retail" 9 "Wholesale" 7 "Communication/Information" 3 "Construction" ///
6 "Transportation" 8 "Utilities" 2 "Mining" 1 "Agriculture, forestry, fishing"
*/

preserve
keep if category==0
xtset FIPS YEAR
est clear
eststo: qui reg growthGSP temp_mean_sum L.growthGSP fips* year* [pw=GSP_weight], vce(cluster YEAR)
eststo: qui reg growthGSP temp_mean_sum L.growthGSP fips* year* [pw=GSP_weight], vce(cluster FIPS) 
eststo: qui xtivreg2 growthGSP temp_mean_sum L.growthGSP fips* year* [pw=GSP_weight], cluster(FIPS YEAR) fe  partial(year*)
estout, cells(b(star fmt(3)) se(par fmt(3))) stat(N r2) starlevel(* .1 ** .05 *** .01) drop(fips* year*)
restore

local categ 0 11 12 4 13 10 9 7 3 6 8 2 1
foreach x in `categ'{
	preserve 
	keep if category == `x'
	xtset FIPS YEAR
	est clear
	eststo: qui reg growthOutput temp_mean_sum l.growthOutput fips* year* [pw=Industryweights2], vce(cl YEAR) 
	eststo: qui reg growthOutput temp_mean_sum l.growthOutput fips* year* [pw=Industryweights2], vce(cl FIPS) 
	eststo: qui xtivreg2 growthOutput temp_mean_sum l.growthOutput fips* year* [pw=Industryweights2], cluster(FIPS YEAR) fe partial(year*)
	estout, cells(b(star fmt(3)) se(par fmt(3))) stat(N r2) starlevel(* .1 ** .05 *** .01) drop(fips* year*)
	restore
}



