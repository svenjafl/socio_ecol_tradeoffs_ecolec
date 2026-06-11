

/* Input data need to be downloaded from the World Inequality Database and stored in the folder "$datapath/wid_all_data". */

global countries AE AG AI AM AN AO AR AS AT AU AW AZ BA BB BD BE BF BG BH BI BJ BL BM BN BO BR BS BT BW BY BZ CA CD CF CG CH CI CK CL CM CN CO CR CS CU CV CW CY CZ DD DE DJ DK DM DO DZ EC EE EG EH ER ES ET ///
FI FJ FK FM FO FR GA GB GD GE GG GH GI GL GM GN GQ GR GT GU GW GY HK HN HR HT HU ID IE IL IM IN IQ IR IS IT JE JM JO JP KE KG KH KI KM KN KP KR KS KW KY KZ LA LB LC LI LK LR LS LT LU LY MA MC MD ME MF MG MH MK ML ///
MM MN MO MP MR MS MT MU MV MW MX MY MZ NA NC NE NG NI NL NO NP NR NU NZ OM PA PE PF PG PH PK PL PM PR PS PT PW PY QA RO RS RU RW SA SB SC SD SE SG SH SI SK SL SM SN SO SR SS ST SU SV SW SX SY SZ TC TD TG TH TJ TK TL TM TN ///
TO TR TT TV TW TZ UA UG US UY UZ VA VC VE VG VI VU WF WS YE ZA ZM ZW ZZ

foreach i of global countries {
  
 import delimited "$datapath/wid_all_data/WID_data_`i'.csv", delimiter(";") varnames(1) clear 
 save "/$datapath/`i'_widdata.dta", replace 

}

global countries AE AG AI AM AN AO AR AS AT AU AW AZ BA BB BD BE BF BG BH BI BJ BL BM BN BO BR BS BT BW BY BZ CA CD CF CG CH CI CK CL CM CN CO CR CS CU CV CWd CY CZ DD DE DJ DK DM DO DZ EC EE EG EH ER ES ET ///
FI FJ FK FM FO FR GA GB GD GE GG GH GI GL GM GN GQ GR GT GU GW GY HK HN HR HT HU ID IE IL IM IN IQ IR IS IT JE JM JO JP KE KG KH KI KM KN KP KR KS KW KY KZ LA LB LC LI LK LR LS LT LU LY MA MC MD ME MF MG MH MK ML ///
MM MN MO MP MR MS MT MU MV MW MX MY MZ NA NC NE NG NI NL NO NP NR NU NZ OM PA PE PF PG PH PK PL PM PR PS PT PW PY QA RO RS RU RW SA SB SC SD SE SG SH SI SK SL SM SN SO SR SS ST SU SV SW SX SY SZ TC TD TG TH TJ TK TL TM TN ///
TO TR TT TV TW TZ UA UG US UY UZ VA VC VE VG VI VU WF WS YE ZA ZM ZW 

foreach i of global countries {
  
 append using "/$datapath/`i'_widdata.dta", force

}

save "/$datapath/widdata_complete.dta", replace 

use "/$datapath/widdata_complete.dta", clear

keep if  variable=="sptincj992" | variable=="sdiincj992" | variable=="scaincj992" | variable=="shwealj992" | variable=="lpfcari999" | variable=="lpfghgi999" | variable=="aptincj992" | variable=="inyixxi999" | variable=="xlcuspi999" | variable=="xlcusxi999" | variable=="adiincj992" | variable=="acaincj992" | variable=="ahwealj992"

drop age pop

reshape wide value, i(country year percentile) j(variable) string

rename valuesptincj992 pretax  
label variable pretax "Pre-tax national income share" /* equal split adults, aggregate on population aged over 20, Pre-tax national income  is the sum of all pre-tax personal income flows accruing to the owners of the production factors, labor and capital, before taking into account the operation of the tax/transfer system, but after taking into account the operation of pension system. The central difference between personal factor income and pre-tax income is the treatment of pensions, which are counted on a contribution basis by factor income and on a distribution basis by pre-tax income. Pre-tax national income =Pre-tax labor income [total pre-tax income ranking]+Pre-tax capital income [total pre-tax income ranking]*/ 	

rename valuesdiincj992 posttax
label variable posttax "Post-tax national income share" /* equal split adults, aggregate on population aged over 20, Post-tax national income is the sum of primary incomes over all sectors (private and public), minus taxes. [Post-tax national income]=[Post-tax disposable income]+[Public spending]*/

rename valuescaincj992 dispinc
label variable dispinc "Post-tax disposable income" /* equal split adults, aggregate on population aged over 20, Post-tax private income corresponds to all sources of incomes, net of taxes, received by individuals and which can be individualized (this excludes social transfers in kind, collective consumption expenditure and government deficit). Post-tax disposable income=Pre-tax income-Taxes on production (net)-Current taxes on income and wealth+Social assistance benefits in cash*/
	
rename 	valueshwealj992 wealth
label variable wealth "Net personal wealth share" /* equal split adults, aggregation population aged over 20, Net personal wealth is  the total value of non-financial and financial assets (housing, land, deposits, bonds, equities, etc.) held by households, minus their debts. The personal or household sector - in the national accounts sense - includes all households and private individuals (including those living in institutions), as well as unincorporated enterprises whose accounts are not separated from those of the households who own them. [Net personal wealth]=[Personal non-financial assets]+[Personal financial assets]-[Personal debt]*/

rename 	valuelpfcari999 persco2fp
label variable persco2fp "Personal CO2 footprint" /* individuals, aggregation population of all ages. Personal CO2 footprint, average per capita group emissions in Tons of CO2 equivalent per capita emissions*/

rename 	valuelpfghgi999 persghgfp
label variable persghgfp "Personal carbon footprint" /* individuals, aggregation population of all ages. Personal carbon footprint, includes CO2 emissions and other greenhouse gases, average per capita group emissions in Tons of CO2 equivalent per capita emissions*/

rename 	valueaptincj992 pretax_level
label variable pretax_level "Pre-tax national income average level, local currency unit, last year's prices" /* equal split adults, aggregate on population aged over 20, Pre-tax national income  is the sum of all pre-tax personal income flows accruing to the owners of the production factors, labor and capital, before taking into account the operation of the tax/transfer system, but after taking into account the operation of pension system. The central difference between personal factor income and pre-tax income is the treatment of pensions, which are counted on a contribution basis by factor income and on a distribution basis by pre-tax income. Pre-tax national income =Pre-tax labor income [total pre-tax income ranking]+Pre-tax capital income [total pre-tax income ranking]*/ 	

rename 	valueadiincj992 posttax_level
label variable posttax_level "Pre-tax national income average level, local currency unit, last year's prices" 

rename 	valueacaincj992 dispinc_level
label variable dispinc_level "Pre-tax national income average level, local currency unit, last year's prices" 

rename 	valueahwealj992 wealth_level
label variable wealth_level "Pre-tax national income average level, local currency unit, last year's prices" 

rename valuexlcuspi999 PPPer
label variable PPPer "PPP exchange rate" /* PPP exchange rate to convert into USD. */ 

rename valuexlcusxi999 mer
label variable mer "Market exchange rate" /* Market exchange rate to convert into USD. */ 	

rename 	valueinyixxi999 priceindex
label variable priceindex "Price index" /* Series are at last year's prices (the database is usually updated yearly at the end of June). To check the year of reference, consider when the price index equals 1. You can access the price index using the variable inyixx999i. */ 	

order country year pretax_level dispinc posttax wealth pretax persco2fp persghgfp 
sort country year

do "$codepath/country_codes_wid.do"

drop country
order cnid year
sort cnid year

bysort cnid year: gen indexyear=1 if priceindex==1
bysort cnid: gen indexPPP=PPPer if indexyear==1
bysort cnid: gen indexmer=mer if indexyear==1
bysort cnid: egen PPPergl = max(indexPPP)
bysort cnid: egen mergl = max(indexmer)
drop indexyear indexPPP indexmer

save "/$datapath/widdata_full.dta", replace 

********************************************************************************

use "/$datapath/widdata_full.dta", clear
keep if percentile == "p0p10" | percentile == "p0p20" | percentile == "p0p50" | percentile == "p81p100" | percentile == "p91p100" | percentile == "p99p100" | percentile == "p0p10" | percentile == "p50p90" 
drop pretax_level persco2fp persghgfp  posttax wealth pretax dispinc_level posttax_level wealth_level priceindex PPPer 
drop if dispinc==.
reshape wide dispinc , i(cnid year) j(percentile) string
save "/$datapath/widdata_dispinc.dta", replace 

use "/$datapath/widdata_full.dta", clear
keep if percentile == "p0p10" | percentile == "p0p20" | percentile == "p0p50" | percentile == "p81p100" | percentile == "p91p100" | percentile == "p99p100" | percentile == "p0p10" | percentile == "p50p90" 
drop pretax_level persco2fp persghgfp dispinc  wealth pretax dispinc_level posttax_level wealth_level priceindex PPPer
drop if posttax==.
reshape wide posttax , i(cnid year) j(percentile) string
save "/$datapath/widdata_posttax.dta", replace 

use "/$datapath/widdata_full.dta", clear
keep if percentile == "p0p10" | percentile == "p0p20" | percentile == "p0p50" | percentile == "p81p100" | percentile == "p91p100" | percentile == "p99p100" | percentile == "p0p10" | percentile == "p50p90" 
drop pretax_level persco2fp persghgfp dispinc posttax  pretax dispinc_level posttax_level wealth_level priceindex PPPer
drop if wealth==.
reshape wide wealth , i(cnid year) j(percentile) string
save "/$datapath/widdata_wealth.dta", replace 

use "/$datapath/widdata_full.dta", clear
keep if percentile == "p0p10" | percentile == "p0p20" | percentile == "p0p50" | percentile == "p81p100" | percentile == "p91p100" | percentile == "p99p100" | percentile == "p0p10" | percentile == "p50p90" 
drop pretax_level persco2fp persghgfp dispinc posttax wealth dispinc_level posttax_level wealth_level priceindex PPPer 
drop if pretax==.
drop if cnid==.
reshape wide pretax , i(cnid year) j(percentile) string
save "/$datapath/widdata_pretax.dta", replace 

use "/$datapath/widdata_full.dta", clear
keep if percentile == "p0p10" | percentile == "p0p20" | percentile == "p0p50" | percentile == "p81p100" | percentile == "p91p100" | percentile == "p99p100" | percentile == "p0p10" | percentile == "p50p90" 
drop pretax persco2fp persghgfp dispinc posttax wealth priceindex dispinc_level posttax_level wealth_level PPPer 
drop if pretax_level==.
drop if cnid==.
reshape wide pretax_level , i(cnid year) j(percentile) string
save "/$datapath/widdata_pretaxlevel.dta", replace 

use "/$datapath/widdata_full.dta", clear
keep if percentile == "p0p10" | percentile == "p0p20" | percentile == "p0p50" | percentile == "p81p100" | percentile == "p91p100" | percentile == "p99p100" | percentile == "p0p10" | percentile == "p50p90" 
drop pretax_level persco2fp persghgfp  posttax wealth pretax dispinc posttax_level wealth_level priceindex PPPer 
drop if dispinc_level==.
reshape wide dispinc_level , i(cnid year) j(percentile) string
save "/$datapath/widdata_dispinc_level.dta", replace 

use "/$datapath/widdata_full.dta", clear
keep if percentile == "p0p10" | percentile == "p0p20" | percentile == "p0p50" | percentile == "p81p100" | percentile == "p91p100" | percentile == "p99p100" | percentile == "p0p10" | percentile == "p50p90" 
drop pretax_level persco2fp persghgfp  posttax wealth pretax dispinc dispinc_level wealth_level priceindex PPPer 
drop if posttax_level==.
reshape wide posttax_level , i(cnid year) j(percentile) string
save "/$datapath/widdata_posttax_level.dta", replace 

use "/$datapath/widdata_full.dta", clear
keep if percentile == "p0p10" | percentile == "p0p20" | percentile == "p0p50" | percentile == "p81p100" | percentile == "p91p100" | percentile == "p99p100" | percentile == "p0p10" | percentile == "p50p90" 
drop pretax_level persco2fp persghgfp  posttax wealth pretax dispinc dispinc_level posttax_level priceindex PPPer 
drop if wealth_level==.
reshape wide wealth_level , i(cnid year) j(percentile) string
save "/$datapath/widdata_wealth_level.dta", replace 


use "/$datapath/widdata_full.dta", clear
keep if percentile == "p0p10" | percentile == "p0p20" | percentile == "p0p50" | percentile == "p81p100" | percentile == "p91p100" | percentile == "p99p100" | percentile == "p0p10" | percentile == "p50p90" 
drop pretax persco2fp persghgfp dispinc posttax wealth pretax_level posttax_level wealth_level dispinc_level priceindex
drop if PPPergl==.
drop if cnid==.
sort cnid year percentile
reshape wide PPPergl , i(cnid year) j(percentile) string
save "/$datapath/widdata_PPPergl.dta", replace 

**************
 
use "/$datapath/widdata_full.dta", clear

gen keep=.

// Start with an empty string for the condition
local condition ""

// Loop over the numbers from 0 to 8 to create the condition
forvalues i = 0/99 {
    // Append each condition to the local macro 'condition'
    local condition "percentile == "p`i'p`=`i'+1'""
// Apply the condition to keep only the desired percentiles
replace keep=1 if `condition'
	}

keep if keep==1

gen perc=.

forval i = 0/99 {
    local j = `i' + 1
    replace perc = 1+`i' if percentile == "p`i'p`j'"
}

save "/$datapath/widdata_stepshares.dta", replace

*************

use "/$datapath/widdata_full.dta", clear

gen keep=.

// Start with an empty string for the condition
local condition ""

// Loop over the numbers from 0 to 8 to create the condition
forvalues i = 0/100 {
    // Append each condition to the local macro 'condition'
    local condition "percentile == "p`i'p`=`i'+1'""
// Apply the condition to keep only the desired percentiles
replace keep=1 if `condition'
	}

replace keep=1 if percentile=="p0p100"
keep if keep==1

gen perc=.

forval i = 0/99 {
    local j = `i' + 1
    replace perc = 1+`i' if percentile == "p`i'p`j'"
}

save "/$datapath/widdata_stepshares2.dta", replace

**************

use "/$datapath/widdata_stepshares.dta", clear

drop dispinc posttax wealth keep
drop percentile

drop if year<1992
duplicates tag cnid year perc , gen(dup)
drop dup

*Generate cumulative income share and cumulative population percentile
sort cnid year perc
bysort cnid year: gen cum_income_share = sum(pretax)
bysort cnid year: gen cum_population = perc / 100

**********************************************************************************
**********************************************************************************	   
* Calculate Gini coefficients in loops
**********************************************************************************
**********************************************************************************

******* Variant 1 

global cnid 3 5 8 9 11 12 13 14 15 16 18 19 20 21 23 24 25 26 27 28 29 30 31 32 33 34 35 37 38 40 41 42 43 44 45 46 47 48 49 51 52 53 54 56 ///
57 58 59 60 61 62 63 66 67 69 70 72 73 74 76 78 79 80 81 82 83 84 85 86 87 88 89 90 91 93 94 95 96 97 98 99 101 102 104 105 106 108 109 110 ///
111 113 114 115 116 117 118 119 120 121 122 124 125 126 128 130 131 132 133 134 135 136 137 139 140 141 142 144 145 146 148 149 150 151 152 /// 
153 154 156 157 158 159 162 163 164 165 166 167 168 170 171 173 174 175 176 177 182 183 184 185 186 187 188 189 190 191 192 193 195 196 197 /// 
198 201 202 203 204 205 206 207 209 212 213 214 215

foreach i of global cnid {
forval j = 1992/2015 {
		
use "/$datapath/widdata_stepshares.dta", clear

keep if cnid==`i' & year==`j'
drop percentile 

*Generate cumulative income share and cumulative population percentile
sort cnid year perc

gen cum_pretax_share = sum(pretax)
gen cum_pretax_population = perc / 100

gen cum_posttax_share = sum(posttax)
gen cum_posttax_population = perc / 100

gen cum_dispinc_share = sum(dispinc)
gen cum_dispinc_population = perc / 100

gen cum_wealth_share = sum(wealth)
gen cum_wealth_population = perc / 100

replace cum_pretax_share=. if pretax==.
replace cum_posttax_share=. if posttax==.
replace cum_dispinc_share=. if dispinc==.
replace cum_wealth_share=. if wealth==.
replace cum_pretax_population=. if pretax==.
replace cum_posttax_population=. if posttax==.
replace cum_dispinc_population=. if dispinc==.
replace cum_wealth_population=. if wealth==.

* Ensure data is sorted by cumulative population share
* Generate lagged variables for cumulative income and cumulative population
* Calculate the Gini coefficient using the trapezoidal rule
* Compute the Gini coefficient (1 - sum of areas under the Lorenz curve)

xtset cnid perc
sort cnid perc 
gen L1_cum_pretax_share = L.cum_pretax_share
gen L1_cum_pretax_population = L.cum_pretax_population
gen gini_pretax_parts = (cum_pretax_share + L1_cum_pretax_share) * (cum_pretax_population - L1_cum_pretax_population)
summarize gini_pretax_parts
gen gini_pretax_wid = 1 - sum(gini_pretax_parts)
egen gini_pretax_wid1 = min(gini_pretax_wid)

gen L1_cum_posttax_share = L.cum_posttax_share
gen L1_cum_posttax_population = L.cum_posttax_population
gen gini_posttax_parts = (cum_posttax_share + L1_cum_posttax_share) * (cum_posttax_population - L1_cum_posttax_population)
summarize gini_posttax_parts
gen gini_posttax_wid = 1 - sum(gini_posttax_parts)
egen gini_posttax_wid1 = min(gini_posttax_wid)

gen L1_cum_dispinc_share = L.cum_dispinc_share
gen L1_cum_dispinc_population = L.cum_dispinc_population
gen gini_dispinc_parts = (cum_dispinc_share + L1_cum_dispinc_share) * (cum_dispinc_population - L1_cum_dispinc_population)
summarize gini_dispinc_parts
gen gini_dispinc_wid = 1 - sum(gini_dispinc_parts)
egen gini_dispinc_wid1 = min(gini_dispinc_wid)

gen L1_cum_wealth_share = L.cum_wealth_share
gen L1_cum_wealth_population = L.cum_wealth_population
gen gini_wealth_parts = (cum_wealth_share + L1_cum_wealth_share) * (cum_wealth_population - L1_cum_wealth_population)
summarize gini_wealth_parts
gen gini_wealth_wid = 1 - sum(gini_wealth_parts)
egen gini_wealth_wid1 = min(gini_wealth_wid)


******* Variant 2

* PRETAX Step 1: Calculate the mean income share

summarize pretax
local mean_income_share = r(mean)

* Step 2: Initialize a local macro to accumulate pairwise differences
local sum_diffs = 0

* Step 3: Nested loop to calculate pairwise absolute differences
forvalues m = 1/100 {
    forvalues n = 1/100 {
        * Calculate absolute difference between percentile i and percentile j
        local diff = abs(pretax[`m'] - pretax[`n'])
        
        * Accumulate the difference in the local macro
        local sum_diffs = `sum_diffs' + `diff'
    }
	}

* Step 4: Calculate Gini coefficient
local n = 100
scalar gini = `sum_diffs' / (2 * `n'^2 * `mean_income_share')
gen gini_pretax_wid2 = scalar(gini)

* POSTTAX Step 1: Calculate the mean income share

summarize posttax
local mean_income_share = r(mean)

* Step 2: Initialize a local macro to accumulate pairwise differences
local sum_diffs = 0

* Step 3: Nested loop to calculate pairwise absolute differences
forvalues m = 1/100 {
    forvalues n = 1/100 {
        * Calculate absolute difference between percentile i and percentile j
        local diff = abs(posttax[`m'] - posttax[`n'])
        
        * Accumulate the difference in the local macro
        local sum_diffs = `sum_diffs' + `diff'
    }
	}

* Step 4: Calculate Gini coefficient
local n = 100
scalar gini = `sum_diffs' / (2 * `n'^2 * `mean_income_share')
gen gini_posttax_wid2 = scalar(gini)

* DISPINC Step 1: Calculate the mean income share

summarize dispinc
local mean_income_share = r(mean)

* Step 2: Initialize a local macro to accumulate pairwise differences
local sum_diffs = 0

* Step 3: Nested loop to calculate pairwise absolute differences
forvalues m = 1/100 {
    forvalues n = 1/100 {
        * Calculate absolute difference between percentile i and percentile j
        local diff = abs(dispinc[`m'] - dispinc[`n'])
        
        * Accumulate the difference in the local macro
        local sum_diffs = `sum_diffs' + `diff'
    }
	}

* Step 4: Calculate Gini coefficient
local n = 100
scalar gini = `sum_diffs' / (2 * `n'^2 * `mean_income_share')
gen gini_dispinc_wid2 = scalar(gini)

* WEALTH Step 1: Calculate the mean income share

summarize wealth
local mean_income_share = r(mean)

* Step 2: Initialize a local macro to accumulate pairwise differences
local sum_diffs = 0

* Step 3: Nested loop to calculate pairwise absolute differences
forvalues m = 1/100 {
    forvalues n = 1/100 {
        * Calculate absolute difference between percentile i and percentile j
        local diff = abs(wealth[`m'] - wealth[`n'])
        
        * Accumulate the difference in the local macro
        local sum_diffs = `sum_diffs' + `diff'
    }
	}

* Step 4: Calculate Gini coefficient
local n = 100
scalar gini = `sum_diffs' / (2 * `n'^2 * `mean_income_share')
gen gini_wealth_wid2 = scalar(gini)

keep cnid year gini_pretax_wid1 gini_posttax_wid1 gini_dispinc_wid1 gini_wealth_wid1 gini_pretax_wid2 gini_posttax_wid2 gini_dispinc_wid2 gini_wealth_wid2
duplicates drop

save "/$datapath/wid_gini_`i'`j'.dta", replace
}
}

foreach i of global cnid {
forval j = 1992/2015 {

append using "/$datapath/wid_gini_`i'`j'.dta" 

}
}	

duplicates drop
recode gini_pretax_wid1 gini_posttax_wid1 gini_dispinc_wid1 gini_wealth_wid1 (1=.)

save "/$datapath/wid_ginis.dta", replace 



