********************************************************************************
/* This do-file prepares and merges the following datasets:

(A) Data from the Standardized World Income Inequality Database (SWIID) 
- GINI coefficient, pre-tax income
- GINI coefficient, post-tax income
Raw data need to be downloaded from https://fsolt.org/swiid/ and in placed in the folder "Data". This code uses data version 9.5, June 2023.

(B) Data from the World Bank
- GDP per capita, current USD
- GDP per capita, constant 2015 USD
- Value added of agriculture, % of GDP
- Value added of services, % of GDP
- Value added of industry, % of GDP
- Urban population, % of population
Raw data need to be downloaded from the World Bank data site and in placed in the folder "Data".

(C) World Bank Historical Country classification
Raw data need to be downloaded from https://ddh-openapi.worldbank.org/resources/DR0095334/download

*/

********************************************************************************
******************* (A) GINI coefficients, SWIID ***********************************

import delimited "$datapath/swiid9_5/swiid9_5_summary.csv", clear 
keep country year gini_disp gini_mkt

do "$codepath/country_codes_swiid.do"
drop if cnid==.
save "$datapath/dataset_swiid_ginis.dta", replace

********************************************************************************
************************ (B) World Bank data ****************************

* GDP per capita, PPP (current US $) 

import delimited "$datapath/WorldBank/API_NY.GDP.PCAP.CD_DS2_en_csv_v2_5994720.csv", clear 
drop in 1/3
rename v1 country
drop v2 v3 v4 v68
do "$codepath/country_codes_wb.do"
drop if cnid==.
order country cnid
reshape long v, i(cnid) j(year)
order country cnid year v
rename v GDPpc 
label variable GDPpc "GDP per capita, current USD, WB"
replace year=year+1955
save "$datapath/dataset_GDPpc.dta", replace

* GDP per capita, constant 2015 USD

import delimited "$datapath/WorldBank/API_NY.GDP.PCAP.KD_DS2_en_csv_v2_5994684.csv", clear 
drop in 1/3
rename v1 country
drop v2 v3 v4 v68
do "$codepath/country_codes_wb.do"
drop if cnid==.
order country cnid
reshape long v, i(cnid) j(year)
order country cnid year v
rename v GDPpc_cons 
label variable GDPpc_cons "GDP per capita, constant USD 2015, WB"
replace year=year+1955
save "$datapath/dataset_GDPpccons.dta", replace

* GDP per capita, constant 2021 USD

import delimited "$datapath/WorldBank/API_NY.GDP.PCAP.PP.KD_DS2_en_csv_v2_13521.csv", clear 
drop in 1/3
rename v1 country
drop v2 v3 v4 v69
do "$codepath/country_codes_wb.do"
drop if cnid==.
order country cnid
reshape long v, i(cnid) j(year)
order country cnid year v
rename v GDPpc_cons21 
label variable GDPpc_cons21 "GDP per capita, constant USD 2021, WB"
replace year=year+1955
save "$datapath/dataset_GDPpccons2021.dta", replace

* Urban Population (% of population)

import delimited "$datapath/WorldBank/API_SP.URB.TOTL.IN.ZS_DS2_en_csv_v2_5996759.csv", clear 
drop in 1/3
rename v1 country
drop v2 v3 v4 v68
do "$codepath/country_codes_wb.do"
drop if cnid==.
order country cnid
reshape long v, i(cnid) j(year)
order country cnid year v
rename v urbanpop
label variable urbanpop "Urban population, % of GDP, WB"
replace year=year+1955
save "$datapath/dataset_urbanpop.dta", replace

* Share of agriculture in value added (% of GDP)

import delimited "$datapath/WorldBank/API_NV.AGR.TOTL.ZS_DS2_en_csv_v2_5995988.csv", clear 
drop in 1/3
rename v1 country
drop v2 v3 v4 v68
do "$codepath/country_codes_wb.do"
drop if cnid==.
order country cnid
reshape long v, i(cnid) j(year)
order country cnid year v
rename v vaagri
label variable vaagri "Value added of agriculture, % of GDP, WB"
replace year=year+1955
save "$datapath/dataset_vaagri.dta", replace

* Share of services in value added (% of GDP)

import delimited "$datapath/WorldBank/API_NV.SRV.TOTL.ZS_DS2_en_csv_v2_5996013.csv", clear 
drop in 1/3
rename v1 country
drop v2 v3 v4 v68
do "$codepath/country_codes_wb.do"
drop if cnid==.
order country cnid
reshape long v, i(cnid) j(year)
order country cnid year v
rename v vaserv
label variable vaserv "Value added of services, % of GDP, WB"
replace year=year+1955
save "$datapath/dataset_vaserv.dta", replace

* Share of industry in value added (% of GDP)

import delimited "$datapath/WorldBank/API_NV.IND.TOTL.ZS_DS2_en_csv_v2_5996008.csv", clear 
drop in 1/3
rename v1 country
drop v2 v3 v4 v68
do "$codepath/country_codes_wb.do"
drop if cnid==.
order country cnid
reshape long v, i(cnid) j(year)
order country cnid year v
rename v vaind
label variable vaind "Value added of industry, % of GDP, WB"
replace year=year+1955
save "$datapath/dataset_vaind.dta", replace

* CO2 emissions, metric tons per capita 

import delimited "$datapath/WorldBank/API_EN.ATM.CO2E.PC_DS2_en_csv_v2_5995557.csv", clear 
drop in 1/3
rename v1 country
drop v2 v3 v4 v68
do "$codepath/country_codes_wb.do"
drop if cnid==.
order country cnid
reshape long v, i(cnid) j(year)
order country cnid year v
rename v co2pc
label variable co2pc "CO2 emissions in metric tons per capita, WB"
replace year=year+1955
save "$datapath/dataset_co2pcwb.dta", replace


********************************************************************************
************************ (C) World Bank, Historical Country Classification ********************

import excel "$datapath/OGHIST.xlsx", sheet("Country Analytical History") firstrow clear

drop A
drop in 1/4
drop in 2/5
drop in 221/231
rename WorldBankAnalyticalClassifica country
rename C t1987
rename D t1988
rename E t1989
rename F t1990
rename G t1991
rename H t1992
rename I t1993
rename J t1994
rename K t1995
rename L t1996
rename M t1997
rename N t1998
rename O t1999
rename P t2000
rename Q t2001
rename R t2002
rename S t2003
rename T t2004
rename U t2005
rename V t2006
rename W t2007
rename X t2008
rename Y t2009
rename Z t2010
rename AA t2011
rename AB t2012
rename AC t2013
rename AD t2014
rename AE t2015
rename AF t2016
rename AG t2017
rename AH t2018
rename AI t2019
rename AJ t2020
rename AK t2021
rename AL t2022

drop in 1/2

reshape long t, i(country) j(year)
keep country year t

do "$codepath/country_codes_wb.do"
replace cnid=47 if country=="Côte d'Ivoire"
replace cnid=52 if country=="Czech Republic"
replace cnid=64 if country=="Faeroe Islands"
replace cnid=101 if country=="Korea, Dem. Rep." /*North Korea*/
replace cnid=162 if country=="São Tomé and Príncipe"
replace cnid=188 if country=="Taiwan, China"
replace cnid=197 if country=="Türkiye"
replace cnid=210 if country=="Vietnam"
drop if cnid==.

replace t="LM" if t=="LM*"
gen WB_classification=.
replace WB_classification=1 if t=="L"
replace WB_classification=2 if t=="LM"
replace WB_classification=3 if t=="UM"
replace WB_classification=4 if t=="H"

label define wbclass 1 "Low-income" 2 "Lower-middle income" 3 "Upper-middle income" 4 "High-income"
label values WB_classification wbclass
drop t

save "$datapath/dataset_WBclassification.dta", replace

********************************************************************************
********************************* Merge ****************************************
********************************************************************************

use "$datapath/dataset_GDPpc.dta", clear
merge m:m cnid year using "$datapath/dataset_GDPpccons2021.dta"
drop _merge
merge m:m cnid year using "$datapath/dataset_urbanpop.dta"
drop _merge
merge m:m cnid year using "$datapath/dataset_vaind.dta"
drop _merge
merge m:m cnid year using "$datapath/dataset_vaserv.dta"
drop _merge
merge m:m cnid year using "$datapath/dataset_vaagri.dta"
drop _merge
merge m:m cnid year using "$datapath/dataset_GDPpccons.dta"
drop _merge
merge m:m cnid year using "$datapath/dataset_co2pcwb.dta"
drop _merge
merge m:m cnid year using "$datapath/dataset_WBclassification.dta"
drop _merge
merge m:m cnid year using "$datapath/dataset_convfacHH.dta"
drop _merge

merge m:m cnid year using "$datapath/dataset_swiid_ginis.dta"
drop _merge
drop if cnid==.

merge m:m cnid year using "$datapath/fanning2021.dta" 
drop _merge
drop if cnid==.

merge m:m cnid year using "$datapath/Fanning2.dta" 
drop _merge
drop if cnid==.

merge m:m cnid year using "/$datapath/widdata_pretax.dta"
drop _merge
drop if cnid==.

merge m:m cnid year using "/$datapath/widdata_posttax.dta"
drop _merge
drop if cnid==.

merge m:m cnid year using "/$datapath/widdata_dispinc.dta"
drop _merge
drop if cnid==.

merge m:m cnid year using "/$datapath/widdata_wealth.dta"
drop _merge
drop if cnid==.

merge m:m cnid year using "/$datapath/widdata_priceindex.dta"
drop _merge
drop if cnid==.

merge m:m cnid year using "/$datapath/widdata_pretaxlevel.dta"
drop _merge
drop if cnid==.

merge m:m cnid year using "/$datapath/widdata_PPPer.dta"
drop _merge
drop if cnid==.

merge m:m cnid year using "/$datapath/wid_ginis.dta"
drop _merge
drop if cnid==.

do "$codepath/country_regioncodes_wb.do"
drop if country==""
order country cnid region year WB_classification 

save "$datapath/dataset_cross-sectional.dta", replace

