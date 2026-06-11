
/* This is the master do file for the article "Income inequality and the trade-off between socio-economic and ecological goals" by S. Flechtner and M. Middelanis, published in Ecological Economics (2026). doi: 10.1016/j.ecolecon.2026.109100

*/

********************************************************************************

clear all

*** Version 
version 18 /*insert version*/

*** output on screen
set more off
set logtype text
set linesize 255 

*** Ado path
*sysdir set PERSONAL " " /* insert path */
*mata mata mlib index

*** Folder paths

global datapath "~/Replication_package/Data"
global outputpath "~/Replication_package/Results"
global codepath "~/Replication_package/Code"

*** Macros for data file and output file
global dateiname "ineq_co2.dta" 
global outputname "Protocole"   

set matsize 10000
cap log close

**************************************************************************************************
*** Data Preparation ***

do "$codepath/fanning_2022.do" /* prepares threshold-adjusted data from Fanning et al. (2022) */
* Original data need to be downloaded from https://goodlife.leeds.ac.uk/download-data/ and stored in folder $datapath.
* The code file produces the data file: "$datapath/fanning2021.dta"

do "$codepath/fanning_countrytrends.do" /* prepares country-wise data for planetary and social boundaries in original values from Fanning et al. (2022) */
* produces: save "/$datapath/Fanning2.dta", replace

do "$codepath/wid_dataprep.do" /* prepares data from the World Income Database */ 
* generates dataset "widdata_complete.dta" - a merge of all country data files with all variables from the WID
* generates dataset "widdata_full.dta" where relevant variables in their raw versions are included (not ALL WID variables) 
* generates datasets "widdata_pretax.dta", "widdata_posttax.dta", "widdata_dispinc.dta", "widdata_wealth.dta", "widdata_priceindex.dta", "widdata_PPPer.dta", "widdata_pretaxlevel.dta".
* uses the "widdtata_full.dta" to generate graphs with Lorenz curves (using dataset "widdata_stepshares.dta")
* uses the "widdata_full.dta" to calculate Gini coefficients and generates datase "wid_ginis.dta"

do "$codepath/data_preparation.do" /* combines with data from other data sources, e.g. on income , and integrates WID variables */
* produces "$datapath/dataset_cross-sectional.dta"

**************************************************************************************************
*** Fig. 1 in paper ***

sepscatter social_mean_ratio physical_mean_ratio if year==2015, sep(WB_classification) color(gs4 medium_blue red green) mlabsize(tiny) yline(1) xline(1) ytitle("Social living standards", size(medsmall)) xtitle("Transgression of planetary boundaries", size(medsmall)) legend(pos(6) col(4) size(small))
graph save "$outputpath/descr_2015.gph", replace
graph export "$outputpath/descr_2015.png", replace

**************************************************************************************************
*** Analysis ***

do "$codepath/analysis.do"

