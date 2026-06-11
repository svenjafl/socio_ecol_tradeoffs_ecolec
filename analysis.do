

use "$datapath/dataset_cross-sectional.dta", clear

set scheme stcolor

drop if year < 1992
drop if year > 2015

label variable pretaxp0p10 "Bottom 10% pre-tax income share"
label variable pretaxp0p50 "Bottom 50% pre-tax income share"
label variable pretaxp50p90 "Midle 40% pre-tax income share"
label variable pretaxp91p100 "Top 10% pre-tax income share"
label variable pretaxp99p100 "Top 1% pre-tax income share"
label variable gini_pretax_wid1 "Gini coefficient, pre-tax income"
label variable posttaxp0p10 "Bottom 10% post-tax income share"
label variable posttaxp0p50 "Bottom 50% post-tax income share"
label variable posttaxp50p90 "Midle 40% post-tax income share"
label variable posttaxp91p100 "Top 10% post-tax income share"
label variable posttaxp99p100 "Top 1% post-tax income share"
label variable gini_posttax_wid1 "Gini coefficient, post-tax income"

* Panel setup
xtset cnid year

* Define inequality variables
global ineqvars_pre pretaxp0p10 pretaxp0p50 pretaxp50p90 pretaxp91p100 pretaxp99p100 gini_pretax_wid1 
global ineqvars_post posttaxp0p10 posttaxp0p50 posttaxp50p90 posttaxp91p100 posttaxp99p100 gini_posttax_wid1
gen ineq=. /* needed in loops to build universal results tables */

* =========================================================
* MAIN SPECIFICATION: xtscc Mundlak pretax
* =========================================================

foreach m of global ineqvars_pre {

di "-----------------------------------------------------"
di " Estimating models for inequality variable: `m'"
di "-----------------------------------------------------"
	
replace ineq = `m'	
cap drop mean_ineq dev_ineq

bys cnid: egen mean_ineq = mean(ineq)
gen dev_ineq = ineq - mean_ineq
	
    eststo pretaxint2_`m': ///
    xtscc physical_mean_ratio c.mean_ineq#i.WB_classification c.dev_ineq#i.WB_classification c.social_mean_ratio#i.WB_classification i.WB_classification i.year
	
	/* Predictive margins */
	summ mean_ineq
	margins, at(mean_ineq = (`r(min)' (`r(sd)') `r(max)')) by(WB_classification)
	local var `m'
	local vlabel : variable label `var'
	marginsplot, xdimension(c.mean_ineq) ///
    title("") ///
    ytitle("Transgression of planetary boundaries") ///
    recast(line) recastci(rarea) ///
    ciopts(color(%20)) ///
    plotopts(lwidth(medium)) ///
    aspect(1) xtitle("Gini coefficient of pre-tax income")  title("`vlabel'", size(medsmall)) xlabel(, labsize(small) format(%3.2f)) ///
    legend(order(1 "Low income" 2 "Lower-middle income" 3 "Upper-middle income" 4 "High income") ///
    pos(6) ring(1) col(2))  
	graph save "$outputpath/margins_`m'_bw_int2.gph", replace
	graph export "$outputpath/margins_`m'_bw_int2.png", replace
	
}
	
* -----------------------------------------------------
* Export models (main results table in paper)
* -----------------------------------------------------
    esttab pretaxint2_pretaxp0p10 pretaxint2_pretaxp0p50 pretaxint2_pretaxp50p90 ///
			pretaxint2_pretaxp91p100 pretaxint2_pretaxp99p100 pretaxint2_gini_pretax_wid1  ///
           using "$outputpath/main_results_int2.tex", replace ///
           se b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
           title("Inequality specification: `m'") ///
           alignment(D{.}{.}{-1}) ///
           stats(N, labels("Obs."))

* -----------------------------------------------------
* Combined graph (main results graph in paper)
* -----------------------------------------------------

grc1leg "$outputpath/margins_pretaxp0p10_bw_int2.gph" "$outputpath/margins_pretaxp0p50_bw_int2.gph" "$outputpath/margins_pretaxp50p90_bw_int2.gph" ///
"$outputpath/margins_pretaxp91p100_bw_int2.gph" "$outputpath/margins_pretaxp99p100_bw_int2.gph" "$outputpath/margins_gini_pretax_wid1_bw_int2.gph"
graph save "$outputpath/main results_int2.gph", replace
graph export "$outputpath/main results_int2.png", replace

tab country if e(sample) & WB_classification==1 /* 921 */
tab country if e(sample) & WB_classification==2 /* 856 */
tab country if e(sample) & WB_classification==3 /* 617 */
tab country if e(sample) & WB_classification==4 /* 555 */

* ============================================================================================================================
* =========================================================
* ROBUSTNESS CHECKS
* =========================================================

preserve
drop if WB_classification==1
* =========================================================
* (1) Post-tax data
* =========================================================

foreach m of global ineqvars_post {

di "-----------------------------------------------------"
di " Estimating models for inequality variable: `m'"
di "-----------------------------------------------------"
	
replace ineq = `m'	
cap drop mean_ineq dev_ineq

bys cnid: egen mean_ineq = mean(ineq)
gen dev_ineq = ineq - mean_ineq
	
    eststo posttaxbl_`m': ///
    xtscc physical_mean_ratio c.mean_ineq#i.WB_classification c.dev_ineq#i.WB_classification c.social_mean_ratio#i.WB_classification i.WB_classification i.year 


	/* Predictive margins */
	summ mean_ineq
	margins, at(mean_ineq = (`r(min)' (`r(sd)') `r(max)')) by(WB_classification)
	local var `m'
	local vlabel : variable label `var'
	marginsplot, xdimension(c.mean_ineq) ///
    title("") ///
    ytitle("Transgression of planetary boundaries") ///
    recast(line) recastci(rarea) ///
    ///
    plot1opts(lcolor(stc2) lwidth(medium)) ///
    plot2opts(lcolor(stc3) lwidth(medium)) ///
    plot3opts(lcolor(stc4) lwidth(medium)) ///
    ///
    ci1opts(color(stc2%20)) ///
    ci2opts(color(stc3%20)) ///
    ci3opts(color(stc4%20)) ///
    ///
    aspect(1) xtitle("") ///
    title("`vlabel'", size(medsmall)) ///
    xlabel(, labsize(small) format(%5.4f)) ///
    legend(order(1 "Lower-middle income" 2 "Upper-middle income" 3 "High income") ///
    pos(6) ring(1) col(2))
	graph save "$outputpath/margins_`m'_bw.gph", replace
	graph export "$outputpath/margins_`m'_bw.png", replace
	
}

* tab country if e(sample) & WB_classification==1 /* 26 */

forval i= 1/7 {
di "`i'"
tab country if e(sample) & WB_classification==2 & region==`i' /* 206 */
tab country if e(sample) & WB_classification==3 & region==`i' /* 283 */
tab country if e(sample) & WB_classification==4 & region==`i' /* 477 */
}

gen esample_post = 1 if e(sample)

* -----------------------------------------------------
* Export models (post-tax results table in paper)
* -----------------------------------------------------
    esttab posttaxbl_posttaxp0p10 posttaxbl_posttaxp0p50 posttaxbl_posttaxp50p90 ///
			posttaxbl_posttaxp91p100 posttaxbl_posttaxp99p100 posttaxbl_gini_posttax_wid1  ///
           using "$outputpath/posttax_results_int2.tex", replace ///
           se b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
           title("Inequality specification: `m'") ///
           alignment(D{.}{.}{-1}) ///
           stats(N, labels("Obs."))

* -----------------------------------------------------
* Combined graph (post-tax results graph in paper)
* -----------------------------------------------------

grc1leg "$outputpath/margins_posttaxp0p10_bw.gph" "$outputpath/margins_posttaxp0p50_bw.gph" "$outputpath/margins_posttaxp50p90_bw.gph" ///
"$outputpath/margins_posttaxp91p100_bw.gph" "$outputpath/margins_posttaxp99p100_bw.gph" "$outputpath/margins_gini_posttax_wid1_bw.gph" 
graph save "$outputpath/posttax results_ohneLIC_int2.gph", replace
graph export "$outputpath/posttax results_ohneLIC_int2.png", replace


* =========================================================
* (1b) Pre-tax with post-tax sample
* =========================================================

foreach m of global ineqvars_pre {

di "-----------------------------------------------------"
di " Estimating models for inequality variable: `m'"
di "-----------------------------------------------------"
	
replace ineq = `m'	
cap drop mean_ineq dev_ineq

bys cnid: egen mean_ineq = mean(ineq)
gen dev_ineq = ineq - mean_ineq
	
    eststo pretaxbl_`m': ///
    xtscc physical_mean_ratio c.mean_ineq#i.WB_classification c.dev_ineq#i.WB_classification c.social_mean_ratio#i.WB_classification i.WB_classification i.year if esample_post==1
	
	/* Predictive margins */
	summ mean_ineq
	margins, at(mean_ineq = (`r(min)' (`r(sd)') `r(max)')) by(WB_classification)
	local var `m'
	local vlabel : variable label `var'
	marginsplot, xdimension(c.mean_ineq) ///
    title("") ///
    ytitle("Transgression of planetary boundaries") ///
    recast(line) recastci(rarea) ///
    ///
    plot1opts(lcolor(stc2) lwidth(medium)) ///
    plot2opts(lcolor(stc3) lwidth(medium)) ///
    plot3opts(lcolor(stc4) lwidth(medium)) ///
    ///
    ci1opts(color(stc2%20)) ///
    ci2opts(color(stc3%20)) ///
    ci3opts(color(stc4%20)) ///
    ///
    aspect(1) xtitle("") ///
    title("`vlabel'", size(medsmall)) ///
    xlabel(, labsize(small) format(%5.4f)) ///
    legend(order(1 "Lower-middle income" 2 "Upper-middle income" 3 "High income") ///
    pos(6) ring(1) col(2))
	graph save "$outputpath/margins_`m'_prepost_int2.gph", replace
	graph export "$outputpath/margins_`m'_prepost_int2.png", replace
}
	
* -----------------------------------------------------
* Export models (main results table in paper)
* -----------------------------------------------------
    esttab pretaxbl_pretaxp0p10 pretaxbl_pretaxp0p50 pretaxbl_pretaxp50p90 ///
			pretaxbl_pretaxp91p100 pretaxbl_pretaxp99p100 pretaxbl_gini_pretax_wid1  ///
           using "$outputpath/main_results_prepost_int2.tex", replace ///
           se b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
           title("Inequality specification: `m'") ///
           alignment(D{.}{.}{-1}) ///
           stats(N, labels("Obs."))

* -----------------------------------------------------
* Combined graph (main results graph in paper)
* -----------------------------------------------------

grc1leg "$outputpath/margins_pretaxp0p10_prepost_int2.gph" "$outputpath/margins_pretaxp0p50_prepost_int2.gph" "$outputpath/margins_pretaxp50p90_prepost_int2.gph" ///
"$outputpath/margins_pretaxp91p100_prepost_int2.gph" "$outputpath/margins_pretaxp99p100_prepost_int2.gph" "$outputpath/margins_gini_pretax_wid1_prepost_int2.gph" 
graph save "$outputpath/main results_prepostint2.gph", replace
graph export "$outputpath/main results_prepostint2.png", replace

tab country if e(sample) & WB_classification==2 /* 206 */
tab country if e(sample) & WB_classification==3 /* 283 */
tab country if e(sample) & WB_classification==4 /* 477 */

restore

* -----------------------------------------------------
* (2) Pre-tax with control variables
* -----------------------------------------------------

*global ineqvars_pres pretaxp0p10
 foreach m of global ineqvars_pre {

di "-----------------------------------------------------"
di " Estimating models for inequality variable: `m'"
di "-----------------------------------------------------"
	
replace ineq = `m'	
cap drop mean_ineq dev_ineq

bys cnid: egen mean_ineq = mean(ineq)
gen dev_ineq = ineq - mean_ineq
	
    eststo pretaxbl_`m'c: ///
    xtscc physical_mean_ratio c.mean_ineq#i.WB_classification c.dev_ineq#i.WB_classification c.social_mean_ratio#i.WB_classification urbanpop vaind vaserv  vaagri i.WB_classification i.year
	
	/* Predictive margins */
	summ mean_ineq
	margins, at(mean_ineq = (`r(min)' (`r(sd)') `r(max)')) by(WB_classification)
	local var `m'
	local vlabel : variable label `var'
	marginsplot, xdimension(c.mean_ineq) ///
    title("") ///
    ytitle("Transgression of planetary boundaries") ///
    recast(line) recastci(rarea) ///
    ciopts(color(%20)) ///
    plotopts(lwidth(medium)) ///
    aspect(1) xtitle("") title("`vlabel'", size(medsmall)) xlabel(, labsize(small) format(%5.4f)) ///
    legend(order(1 "Low income" 2 "Lower-middle income" 3 "Upper-middle income" 4 "High income") ///
    pos(6) ring(1) col(2))  
	graph save "$outputpath/margins_`m'_bw_controls_int2.gph", replace
	graph export "$outputpath/margins_`m'_bw_controls_int2.png", replace
	
}
	
* -----------------------------------------------------
* Export models (main results table in paper)
* -----------------------------------------------------
    esttab pretaxbl_pretaxp0p10c pretaxbl_pretaxp0p50c pretaxbl_pretaxp50p90c ///
			pretaxbl_pretaxp91p100c pretaxbl_pretaxp99p100c pretaxbl_gini_pretax_wid1c  ///
           using "$outputpath/main_results_controls_int2.tex", replace ///
           se b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
           title("Inequality specification: `m'") ///
           alignment(D{.}{.}{-1}) ///
           stats(N, labels("Obs."))

* -----------------------------------------------------
* Combined graph (main results graph in paper)
* -----------------------------------------------------

grc1leg "$outputpath/margins_pretaxp0p10_bw_controls_int2.gph" "$outputpath/margins_pretaxp0p50_bw_controls_int2.gph" "$outputpath/margins_pretaxp50p90_bw_controls_int2.gph" ///
"$outputpath/margins_pretaxp91p100_bw_controls_int2.gph" "$outputpath/margins_pretaxp99p100_bw_controls_int2.gph" "$outputpath/margins_gini_pretax_wid1_bw_controls_int2.gph" 
graph save "$outputpath/main results_controls_int2.gph", replace
graph export "$outputpath/main results_controls_int2.png", replace

tab country if e(sample) & WB_classification==1 /* 845 */
tab country if e(sample) & WB_classification==2 /* 806 */
tab country if e(sample) & WB_classification==3 /* 581 */
tab country if e(sample) & WB_classification==4 /* 535 */

	  
* -----------------------------------------------------
* Robustness 3: Lagged 1 pretax
* -----------------------------------------------------

foreach m of global ineqvars_pre {

di "-----------------------------------------------------"
di " Estimating models for inequality variable: `m'"
di "-----------------------------------------------------"

replace ineq = `m'	
cap drop mean_ineq dev_ineq

bys cnid: egen mean_ineq = mean(ineq)
gen dev_ineq = ineq - mean_ineq

eststo pretaxl1_`m': ///
        xtscc physical_mean_ratio c.mean_ineq#i.WB_classification c.l.dev_ineq#i.WB_classification i.WB_classification c.l.social_mean_ratio#i.WB_classification i.year	
		
		/* Predictive margins */
	summ mean_ineq
	margins, at(mean_ineq = (`r(min)' (`r(sd)') `r(max)')) by(WB_classification)
	local var `m'
	local vlabel : variable label `var'
	marginsplot, xdimension(c.mean_ineq) ///
    title("") ///
    ytitle("Transgression of planetary boundaries") ///
    recast(line) recastci(rarea) ///
    ciopts(color(%20)) ///
    plotopts(lwidth(medium)) ///
    aspect(1) xtitle("") title("`vlabel'", size(medsmall)) xlabel(, labsize(small) format(%5.4f)) ///
    legend(order(1 "Low income" 2 "Lower-middle income" 3 "Upper-middle income" 4 "High income") ///
    pos(6) ring(1) col(2))  
	graph save "$outputpath/margins_`m'_lag1_int2.gph", replace
	graph export "$outputpath/margins_`m'_lag1_int2.png", replace

tab country if e(sample) & WB_classification==1 /* 881 */
tab country if e(sample) & WB_classification==2 /* 810 */
tab country if e(sample) & WB_classification==3 /* 597 */
tab country if e(sample) & WB_classification==4 /* 538 */	
	
eststo pretaxl2_`m': ///
        xtscc physical_mean_ratio c.mean_ineq#i.WB_classification c.l2.dev_ineq#i.WB_classification i.WB_classification c.l2.social_mean_ratio#i.WB_classification i.year	
		
	/* Predictive margins */
	summ mean_ineq
	margins, at(mean_ineq = (`r(min)' (`r(sd)') `r(max)')) by(WB_classification)
	local var `m'
	local vlabel : variable label `var'
	marginsplot, xdimension(c.mean_ineq) ///
    title("") ///
    ytitle("Transgression of planetary boundaries") ///
    recast(line) recastci(rarea) ///
    ciopts(color(%20)) ///
    plotopts(lwidth(medium)) ///
    aspect(1) xtitle("") title("`vlabel'", size(medsmall)) xlabel(, labsize(small) format(%5.4f)) ///
    legend(order(1 "Low income" 2 "Lower-middle income" 3 "Upper-middle income" 4 "High income") ///
    pos(6) ring(1) col(2))  
	graph save "$outputpath/margins_`m'_lag2_int2.gph", replace
	graph export "$outputpath/margins_`m'_lag2_int2.png", replace	

tab country if e(sample) & WB_classification==1 /* 838 */
tab country if e(sample) & WB_classification==2 /* 767 */
tab country if e(sample) & WB_classification==3 /* 577 */
tab country if e(sample) & WB_classification==4 /* 521 */
}
	
grc1leg "$outputpath/margins_pretaxp0p10_lag1_int2.gph" "$outputpath/margins_pretaxp0p50_lag1_int2.gph" "$outputpath/margins_pretaxp50p90_lag1_int2.gph" ///
"$outputpath/margins_pretaxp91p100_lag1_int2.gph" "$outputpath/margins_pretaxp99p100_lag1_int2.gph" "$outputpath/margins_gini_pretax_wid1_lag1_int2.gph" 
graph save "$outputpath/main results_lag1_int2.gph", replace
graph export "$outputpath/main results_lag1_int2.png", replace

grc1leg "$outputpath/margins_pretaxp0p10_lag2_int2.gph" "$outputpath/margins_pretaxp0p50_lag2_int2.gph" "$outputpath/margins_pretaxp50p90_lag2_int2.gph" ///
"$outputpath/margins_pretaxp91p100_lag2_int2.gph" "$outputpath/margins_pretaxp99p100_lag2_int2.gph" "$outputpath/margins_gini_pretax_wid1_lag2_int2.gph" 
graph save "$outputpath/main results_lag2_int2.gph", replace
graph export "$outputpath/main results_lag2_int2.png", replace

* -----------------------------------------------------
* Export models (main results table in paper)
* -----------------------------------------------------
    esttab pretaxl1_pretaxp0p10 pretaxl1_pretaxp0p50 pretaxl1_pretaxp50p90 ///
			pretaxl1_pretaxp91p100 pretaxl1_pretaxp99p100 pretaxl1_gini_pretax_wid1  ///
           using "$outputpath/main_results_lag1_int2.tex", replace ///
           se b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
           alignment(D{.}{.}{-1}) ///
           stats(N, labels("Obs."))		
		   
	 esttab pretaxl2_pretaxp0p10 pretaxl2_pretaxp0p50 pretaxl2_pretaxp50p90 ///
			pretaxl2_pretaxp91p100 pretaxl2_pretaxp99p100 pretaxl2_gini_pretax_wid1  ///
           using "$outputpath/main_results_lag2_int2.tex", replace ///
           se b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
           alignment(D{.}{.}{-1}) ///
           stats(N, labels("Obs."))		
		   

* -----------------------------------------------------
* Robustness 7: Worldregions pretax
* -----------------------------------------------------

foreach m of global ineqvars_pre {

di "-----------------------------------------------------"
di " World regions"
di "-----------------------------------------------------"

recode region (5=2)

replace ineq = `m'	
cap drop mean_ineq dev_ineq

bys cnid: egen mean_ineq = mean(ineq)
gen dev_ineq = ineq - mean_ineq
	
    eststo pretaxbl_`m'c: ///
    xtscc physical_mean_ratio c.mean_ineq#i.region c.dev_ineq#i.region c.social_mean_ratio#i.region  i.region i.year

		/* Predictive margins */
	summ mean_ineq
	margins, at(mean_ineq = (`r(min)' (`r(sd)') `r(max)')) by(region)
	local var `m'
	local vlabel : variable label `var'
	marginsplot, xdimension(c.mean_ineq) ///
    title("") ///
    ytitle("Transgression of planetary boundaries") ///
    recast(line) recastci(rarea) ///
    ciopts(color(%20)) ///
    plotopts(lwidth(medium)) ///
    aspect(1) xtitle("") title("`vlabel'", size(medsmall)) xlabel(, labsize(small) format(%5.4f)) ///
    legend(order(1 "East Asia and Pacific" 2 "Europe, US and Central Asia" 3 "Latin America & Caribbean" 4 "Middle East and North Africa" 5 "South Asia" 6 "Sub-Saharan Africa") pos(6) ring(1) col(2))  
	graph save "$outputpath/margins_region_`m'_int2.gph", replace
	graph export "$outputpath/margins_region_`m'_int2.png", replace
}

* -----------------------------------------------------
* Export models (main results table in paper)
* -----------------------------------------------------
    esttab pretaxbl_pretaxp0p10c pretaxbl_pretaxp0p50c pretaxbl_pretaxp50p90c ///
			pretaxbl_pretaxp91p100c pretaxbl_pretaxp99p100c pretaxbl_gini_pretax_wid1c  ///
           using "$outputpath/main_region_int2.tex", replace ///
           se b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
           title("Inequality specification: `m'") ///
           alignment(D{.}{.}{-1}) ///
           stats(N, labels("Obs."))

* -----------------------------------------------------
* Combined graph (main results graph in paper)
* -----------------------------------------------------

grc1leg "$outputpath/margins_region_pretaxp0p10_int2.gph" "$outputpath/margins_region_pretaxp0p50_int2.gph" "$outputpath/margins_region_pretaxp50p90_int2.gph" ///
"$outputpath/margins_region_pretaxp91p100_int2.gph" "$outputpath/margins_region_pretaxp99p100_int2.gph" "$outputpath/margins_region_gini_pretax_wid1_int2.gph" 
graph save "$outputpath/main results_region_int2.gph", replace
graph export "$outputpath/main results_region_int2.png", replace

tab country if e(sample) & region==1 /* 288 */
tab country if e(sample) & region==2 /* 912 */
tab country if e(sample) & region==3 /* 528 */
tab country if e(sample) & region==4 /* 299 */
tab country if e(sample) & region==6 /* 120 */
tab country if e(sample) & region==7 /* 816 */














*use "$datapath/dataset_comm_earth.dta", clear
use "$datapath/dataset_cross-sectional.dta", clear

* =========================================================
* xtscc Mundlak posttax
* =========================================================

* Panel setup
xtset cnid year

set scheme stcolor

drop if year < 1992
drop if year > 2015

* Define inequality variables
global ineqvars posttaxp0p10 posttaxp0p50 posttaxp50p90 posttaxp91p100 posttaxp99p100 gini_posttax_wid1 gini_posttax_wid2

bys cnid: egen mean_social_mean_ratio = mean(social_mean_ratio)
gen dev_social_mean_ratio = social_mean_ratio - mean_social_mean_ratio

	* -----------------------------------------------------
    *  post-tax estimations - Mundlak
    * -----------------------------------------------------
foreach m of global ineqvars {

di "-----------------------------------------------------"
di " Estimating models for inequality variable: `m'"
di "-----------------------------------------------------"


	* -----------------------------------------------------
    * SPEC 1: Baseline posttax
    * -----------------------------------------------------

bys cnid: egen mean_`m' = mean(`m')
gen dev_`m' = `m' - mean_`m'
	
    eststo posttaxbl_`m': ///
    xtscc physical_mean_ratio c.mean_`m'#i.WB_classification c.dev_`m'#i.WB_classification i.WB_classification c.mean_social_mean_ratio c.dev_social_mean_ratio  i.year if inlist(WB_classification, 3, 4)
}
	* -----------------------------------------------------
    * Robustness 1: Controls posttax
    * -----------------------------------------------------

    eststo posttaxbl_`m': ///
        xtscc physical_mean_ratio c.mean_`m'#i.WB_classification c.dev_`m'#i.WB_classification i.WB_classification c.mean_social_mean_ratio c.dev_social_mean_ratio urbanpop vaind vaagri vaserv i.year if inlist(WB_classification, 3, 4)
	
			  
	* -----------------------------------------------------
    * Robustness 2: Lagged 1 posttax
    * -----------------------------------------------------

    eststo posttaxl1_`m': ///
        xtscc physical_mean_ratio c.mean_`m'#i.WB_classification c.l.dev_`m'#i.WB_classification i.WB_classification c.mean_social_mean_ratio c.l.dev_social_mean_ratio i.year if inlist(WB_classification, 3, 4)
			  
	* -----------------------------------------------------
    * Robustness 3: Lagged 2 posttax
    * -----------------------------------------------------

    eststo posttaxl2_`m': ///
        xtscc physical_mean_ratio c.mean_`m'#i.WB_classification c.l2.dev_`m'#i.WB_classification i.WB_classification c.mean_social_mean_ratio c.l2.dev_social_mean_ratio i.year if inlist(WB_classification, 3, 4)

	* -----------------------------------------------------
    * Robustness 4: Lagged 3 posttax
    * -----------------------------------------------------

    eststo posttaxl3`m': ///
        xtscc physical_mean_ratio c.mean_`m'#i.WB_classification c.l3.dev_`m'#i.WB_classification i.WB_classification c.mean_social_mean_ratio c.l3.dev_social_mean_ratio i.year if inlist(WB_classification, 3, 4)
			  
	* -----------------------------------------------------
    * Robustness 5: Lagged 4 posttax
    * -----------------------------------------------------

    eststo posttaxl4`m': ///
        xtscc physical_mean_ratio c.mean_`m'#i.WB_classification c.l4.dev_`m'#i.WB_classification i.WB_classification c.mean_social_mean_ratio c.l4.dev_social_mean_ratio i.year if inlist(WB_classification, 3, 4)
			  
		  
	* -----------------------------------------------------
    * Robustness 6: Difference HIC to UMIC
    * -----------------------------------------------------

    eststo posttaxdiff`m': ///
        xtscc physical_mean_ratio c.mean_`m'##ib4.WB_classification c.dev_`m'##ib4.WB_classification c.mean_social_mean_ratio c.dev_social_mean_ratio i.year if inlist(WB_classification, 3, 4)
			  

}





* =========================================================
* Estimations without within - between division
* =========================================================

* Panel setup
xtset cnid year

*posttaxp0p10 posttaxp0p50 posttaxp50p90 posttaxp91p100 posttaxp99p100
*pretaxp0p10 pretaxp0p50 pretaxp50p90 pretaxp91p100 pretaxp99p100

* Define inequality variables
global ineqvars pretaxp0p10 pretaxp0p50 pretaxp50p90 pretaxp91p100 pretaxp99p100 gini_pretax
	
	* -----------------------------------------------------
    *  pretax estimations
    * -----------------------------------------------------
foreach m of global ineqvars {

di "-----------------------------------------------------"
di " Estimating models for inequality variable: `m'"
di "-----------------------------------------------------"

	* -----------------------------------------------------
    * SPEC 1: Baseline pretax
    * -----------------------------------------------------

    eststo pretaxbl_`m': ///
        xtscc physical_mean_ratio ///
              c.`m'#i.WB_classification i.WB_classification ///
              c.social_mean_ratio i.year

	* -----------------------------------------------------
    * Robustness 1: Controls pretax
    * -----------------------------------------------------

    eststo pretaxbl_`m': ///
        xtscc physical_mean_ratio ///
              c.`m'#i.WB_classification i.WB_classification ///
              c.social_mean_ratio urbanpop vaind vaagri vaserv i.year
	
			  
	* -----------------------------------------------------
    * Robustness 2: Lagged 1 pretax
    * -----------------------------------------------------

    eststo pretaxl1_`m': ///
        xtscc physical_mean_ratio ///
              c.l.`m'#i.WB_classification i.WB_classification ///
              c.l.social_mean_ratio i.year
			  
	* -----------------------------------------------------
    * Robustness 3: Lagged 2 pretax
    * -----------------------------------------------------

    eststo pretaxl2_`m': ///
        xtscc physical_mean_ratio ///
              c.l2.`m'#i.WB_classification i.WB_classification ///
              c.l2.social_mean_ratio i.year

	* -----------------------------------------------------
    * Robustness 4: Lagged 3 pretax
    * -----------------------------------------------------

    eststo pretaxl3`m': ///
        xtscc physical_mean_ratio ///
              c.l3.`m'#i.WB_classification i.WB_classification ///
              c.l3.social_mean_ratio i.year
			  
	* -----------------------------------------------------
    * Robustness 5: Lagged 4 pretax
    * -----------------------------------------------------

    eststo pretaxl4`m': ///
        xtscc physical_mean_ratio ///
              c.l4.`m'#i.WB_classification i.WB_classification ///
              c.l4.social_mean_ratio i.year
			  
	* -----------------------------------------------------
    * Robustness 6: Difference LIC to rest
    * -----------------------------------------------------

    eststo pretaxdiffLIC`m': ///
        xtscc physical_mean_ratio ///
              c.`m'##i.WB_classification ///
              c.social_mean_ratio i.year
			  
	* -----------------------------------------------------
    * Robustness 7: Difference HIC to rest
    * -----------------------------------------------------

    eststo pretaxdiffHIC`m': ///
        xtscc physical_mean_ratio ///
              c.`m'##ib4.WB_classification ///
              c.social_mean_ratio i.year
			  
	* -----------------------------------------------------
    * Robustness 8: Worldregions pretax
    * -----------------------------------------------------

    eststo pretaxbl_`m': ///
        xtscc physical_mean_ratio ///
              c.`m'#i.region i.region ///
              c.social_mean_ratio i.year
			  
}

*pretaxp0p10 pretaxp0p50 pretaxp50p90 pretaxp91p100 pretaxp99p100
*posttaxp0p10 posttaxp0p50 posttaxp50p90 posttaxp91p100 posttaxp99p100

* Define inequality variables
global ineqvars posttaxp0p10 posttaxp0p50 posttaxp50p90 posttaxp91p100 posttaxp99p100 gini_posttax
	

	* -----------------------------------------------------
    *  Posttax estimations
    * -----------------------------------------------------
foreach m of global ineqvars {

di "-----------------------------------------------------"
di " Estimating models for inequality variable: `m'"
di "-----------------------------------------------------"



	* -----------------------------------------------------
    * SPEC 1: Baseline posttax
    * -----------------------------------------------------

    eststo posttaxbl_`m': ///
        xtscc physical_mean_ratio ///
              c.`m'#i.WB_classification i.WB_classification ///
              c.social_mean_ratio i.year if inlist(WB_classification, 3, 4)

	* -----------------------------------------------------
    * Robustness 1: Controls posttax
    * -----------------------------------------------------

    eststo posttaxbl_`m': ///
        xtscc physical_mean_ratio ///
              c.`m'#i.WB_classification i.WB_classification ///
              c.social_mean_ratio urbanpop vaind vaagri vaserv i.year if inlist(WB_classification, 3, 4)
			  
	* -----------------------------------------------------
    * Robustness 2: Lagged 1 posttax
    * -----------------------------------------------------

    eststo posttaxl1_`m': ///
        xtscc physical_mean_ratio ///
              c.l.`m'#i.WB_classification i.WB_classification ///
              c.l.social_mean_ratio i.year if inlist(WB_classification, 3, 4)
			  
	* -----------------------------------------------------
    * Robustness 3: Lagged 2 posttax
    * -----------------------------------------------------

    eststo posttaxl2_`m': ///
        xtscc physical_mean_ratio ///
              c.l2.`m'#i.WB_classification i.WB_classification ///
              c.l2.social_mean_ratio i.year if inlist(WB_classification, 3, 4)

	* -----------------------------------------------------
    * Robustness 4: Lagged 3 postta
    * -----------------------------------------------------

    eststo posttaxl3`m': ///
        xtscc physical_mean_ratio ///
              c.l3.`m'#i.WB_classification i.WB_classification ///
              c.l3.social_mean_ratio i.year if inlist(WB_classification, 3, 4)
			  
	* -----------------------------------------------------
    * Robustness 5: Lagged 4 posttax
    * -----------------------------------------------------

    eststo posttaxl4`m': ///
        xtscc physical_mean_ratio ///
              c.l4.`m'#i.WB_classification i.WB_classification ///
              c.l4.social_mean_ratio i.year if inlist(WB_classification, 3, 4)
			  

	* -----------------------------------------------------
    * Robustness 6: Difference HIC to UMIC
    * -----------------------------------------------------

    eststo posttaxl4`m': ///
        xtscc physical_mean_ratio ///
              c.`m'##ib4.WB_classification ///
              c.social_mean_ratio i.year if inlist(WB_classification, 3, 4)
			  
}


use "$datapath/dataset_comm_earth.dta", clear


* =========================================================
* MAIN ESTIMATIONS
* =========================================================

* Panel setup
xtset cnid year

*posttaxp0p10 posttaxp0p50 posttaxp50p90 posttaxp91p100 posttaxp99p100
*pretaxp0p10 pretaxp0p50 pretaxp50p90 pretaxp91p100 pretaxp99p100

* Define inequality variables
global ineqvars pretaxp0p10 pretaxp0p50 pretaxp50p90 pretaxp91p100 pretaxp99p100 gini_pretax

bys cnid: egen mean_social_mean_ratio = mean(social_mean_ratio)
gen dev_social_mean_ratio = social_mean_ratio - mean_social_mean_ratio

	* -----------------------------------------------------
    *  pretax estimations - Mundlak
    * -----------------------------------------------------
foreach m of global ineqvars {

di "-----------------------------------------------------"
di " Estimating models for inequality variable: `m'"
di "-----------------------------------------------------"


	* -----------------------------------------------------
    * SPEC 1: Baseline pretax
    * -----------------------------------------------------

bys cnid: egen mean_`m' = mean(`m')
gen dev_`m' = `m' - mean_`m'
	
    eststo pretaxbl_`m': ///
    xtscc physical_mean_ratio c.mean_`m'#i.WB_classification c.dev_`m'#i.WB_classification i.WB_classification c.mean_social_mean_ratio c.dev_social_mean_ratio  i.year
	
	* -----------------------------------------------------
    * Robustness 1: Controls pretax
    * -----------------------------------------------------

    eststo pretaxbl_`m': ///
        xtscc physical_mean_ratio c.mean_`m'#i.WB_classification c.dev_`m'#i.WB_classification i.WB_classification c.mean_social_mean_ratio c.dev_social_mean_ratio urbanpop vaind vaagri vaserv i.year
	
			  
	* -----------------------------------------------------
    * Robustness 2: Lagged 1 pretax
    * -----------------------------------------------------

    eststo pretaxl1_`m': ///
        xtscc physical_mean_ratio c.mean_`m'#i.WB_classification c.l.dev_`m'#i.WB_classification i.WB_classification c.mean_social_mean_ratio c.l.dev_social_mean_ratio i.year
			  
	* -----------------------------------------------------
    * Robustness 3: Lagged 2 pretax
    * -----------------------------------------------------

    eststo pretaxl2_`m': ///
        xtscc physical_mean_ratio c.mean_`m'#i.WB_classification c.l2.dev_`m'#i.WB_classification i.WB_classification c.mean_social_mean_ratio c.l2.dev_social_mean_ratio i.year

	* -----------------------------------------------------
    * Robustness 4: Lagged 3 pretax
    * -----------------------------------------------------

    eststo pretaxl3`m': ///
        xtscc physical_mean_ratio c.mean_`m'#i.WB_classification c.l3.dev_`m'#i.WB_classification i.WB_classification c.mean_social_mean_ratio c.l3.dev_social_mean_ratio i.year
			  
	* -----------------------------------------------------
    * Robustness 5: Lagged 4 pretax
    * -----------------------------------------------------

    eststo pretaxl4`m': ///
        xtscc physical_mean_ratio c.mean_`m'#i.WB_classification c.l4.dev_`m'#i.WB_classification i.WB_classification c.mean_social_mean_ratio c.l4.dev_social_mean_ratio i.year
			  
	* -----------------------------------------------------
    * Robustness 6: Difference LIC to rest
    * -----------------------------------------------------

    eststo pretaxdiffLIC`m': ///
        xtscc physical_mean_ratio c.mean_`m'##i.WB_classification c.dev_`m'##i.WB_classification c.mean_social_mean_ratio c.dev_social_mean_ratio i.year
			  
	* -----------------------------------------------------
    * Robustness 7: Difference HIC to rest
    * -----------------------------------------------------

    eststo pretaxdiffHIC`m': ///
        xtscc physical_mean_ratio c.mean_`m'##ib4.WB_classification c.dev_`m'##ib4.WB_classification c.mean_social_mean_ratio c.dev_social_mean_ratio i.year
			  
	* -----------------------------------------------------
    * Robustness 8: Worldregions pretax
    * -----------------------------------------------------

    eststo pretaxbl_`m': ///
        xtscc physical_mean_ratio c.mean_`m'#i.region c.dev_`m'#i.region i.region c.mean_social_mean_ratio c.dev_social_mean_ratio i.year
			  
}
