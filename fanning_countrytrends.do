
global countries Afghanistan Albania Algeria Angola Argentina Armenia Australia Austria Azerbaijan Bangladesh Belgium Benin Bolivia "Bosnia and Herzegovina" Botswana Brazil ///
Bulgaria "Burkina Faso" Burundi Cambodia Cameroon Canada "Central African Republic" Chad Chile China Colombia "Congo, Dem. Rep." "Congo, Rep." "Costa Rica" "Cote d'Ivoire" Croatia Cuba "Czech Republic" ///
Denmark "Dominican Republic" Ecuador "Egypt, Arab Rep." "El Salvador" Estonia Eswatini Ethiopia Finland France Gabon "Gambia, The" Georgia Germany Ghana Greece Guatemala Guinea Haiti Honduras Hungary India ///
Indonesia "Iran, Islamic Rep." Iraq Ireland Israel Italy Jamaica Japan Jordan Kazakhstan Kenya "Korea, DPR." "Korea, Rep." "Kyrgyz Republic" "Lao PDR" Latvia Lebanon Lesotho Liberia Libya Lithuania ///
Madagascar Malawi Malaysia Mali Mauritania Mauritius Mexico Moldova Mongolia Morocco Mozambique Myanmar Namibia Nepal Netherlands "New Zealand" Nicaragua Niger Nigeria "North Macedonia" Norway Oman ///
Pakistan Panama "Papua New Guinea" Paraguay Peru Philippines Poland Portugal Qatar Romania "Russian Federation" Rwanda "Saudi Arabia" Senegal Serbia "Sierra Leone" Singapore "Slovak Republic" Slovenia ///
Somalia "South Africa" Spain "Sri Lanka" Sweden Switzerland "Syrian Arab Republic" Tajikistan Tanzania Thailand Togo "Trinidad and Tobago" Tunisia Turkey Turkmenistan Uganda Ukraine "United Arab Emirates" ///
"United States" Uruguay Uzbekistan "Venezuela, RB" Vietnam "West Bank and Gaza" "Yemen, Rep." Zambia Zimbabwe

foreach i of global countries {
  
  import delimited "$datapath/`i' data-1992-2015.csv", clear 

  drop iso3c indicatorname unit
  reshape wide value thresholdboundary ratio, i(country date) j(indicator) string
  save "/$datapath/`i'_data.dta", replace
}

global countries2 Afghanistan Albania Algeria Angola Argentina Armenia Australia Austria Azerbaijan Bangladesh Belgium Benin Bolivia "Bosnia and Herzegovina" Botswana Brazil ///
Bulgaria "Burkina Faso" Burundi Cambodia Cameroon Canada "Central African Republic" Chad Chile China Colombia "Congo, Dem. Rep." "Congo, Rep." "Costa Rica" "Cote d'Ivoire" Croatia Cuba "Czech Republic" ///
Denmark "Dominican Republic" Ecuador "Egypt, Arab Rep." "El Salvador" Estonia Eswatini Ethiopia Finland France Gabon "Gambia, The" Georgia Germany Ghana Greece Guatemala Guinea Haiti Honduras Hungary India ///
Indonesia "Iran, Islamic Rep." Iraq Ireland Israel Italy Jamaica Japan Jordan Kazakhstan Kenya "Korea, DPR." "Korea, Rep." "Kyrgyz Republic" "Lao PDR" Latvia Lebanon Lesotho Liberia Libya Lithuania ///
Madagascar Malawi Malaysia Mali Mauritania Mauritius Mexico Moldova Mongolia Morocco Mozambique Myanmar Namibia Nepal Netherlands "New Zealand" Nicaragua Niger Nigeria "North Macedonia" Norway Oman ///
Pakistan Panama "Papua New Guinea" Paraguay Peru Philippines Poland Portugal Qatar Romania "Russian Federation" Rwanda "Saudi Arabia" Senegal Serbia "Sierra Leone" Singapore "Slovak Republic" Slovenia ///
Somalia "South Africa" Spain "Sri Lanka" Sweden Switzerland "Syrian Arab Republic" Tajikistan Tanzania Thailand Togo "Trinidad and Tobago" Tunisia Turkey Turkmenistan Uganda Ukraine "United Arab Emirates" ///
"United States" Uruguay Uzbekistan "Venezuela, RB" Vietnam "West Bank and Gaza" "Yemen, Rep." Zambia 

foreach i of global countries2 {
  
  append using "/$datapath/`i'_data.dta"
}

do "$codepath/country_codes_wb.do"
replace cnid=52 if country=="Czech Republic"
replace cnid=101 if country=="Korea, Dem. PeopleÃ¢ÂÂs Rep." /*North Korea*/
replace cnid=197 if country=="Turkey"
replace cnid=210 if country=="Vietnam"

rename date year	

global type value thresholdboundary ratio
global indicators CO2footCum DQval EDval EFfootPerCap EMval ENval EQval INval LEval LSval MFfootPerCap NUval NfootPerCap PfootPerCap SAval SSval ehanppPerCap
foreach i of global type {
foreach z of global indicators {
	if "`i'"== "value" {
	rename `i'`z' `z'
	}
}
}

foreach i of global type {
foreach z of global indicators {
	if "`i'"== "thresholdboundary" {
	rename `i'`z' `z'_tb
	}
}
}

foreach i of global type {
foreach z of global indicators {
	if "`i'"== "ratio" {
	rename `i'`z' `z'_r
	}
}
}

label variable DQval "Democratic quality, scale 0-10"
label variable EDval "Education, % gross enrolment in secondary school"
label variable EMval "Employment, % of labor force employed"
label variable ENval "Access to energy, % of population"
label variable LSval "Life Satisfaction, 0-10 centril scale"
label variable LEval "Life expectancy in years"
label variable NUval "Nutrition, kilocalories per capita per day"
label variable SAval "Sanitation, % with access to improved san."
label variable INval "Income poverty, % who earn above $5.5 2011 PPP"
label variable SSval "Social support, % with friends or family to depend on"
label variable EQval "Equality, 0-100 scale Gini index of 0.3"

********************************************************************************
** (3) Physical and social means from data in ratios

*bysort country year: gen social_mean_ratio = (LSval_r + LEval_r + NUval_r + SAval_r + INval_r + ENval_r + EDval_r + SSval_r + DQval_r + EMval_r) / 10
*bysort country year: gen physical_mean_ratio = (CO2footCum_r + PfootPerCap_r + NfootPerCap_r + ehanppPerCap_r + EFfootPerCap_r + MFfootPerCap_r) / 6

global all LSval_r LEval_r NUval_r SAval_r INval_r ENval_r EDval_r SSval_r  DQval_r  EMval_r CO2footCum_r  PfootPerCap_r  NfootPerCap_r  ehanppPerCap_r  EFfootPerCap_r  MFfootPerCap_r

foreach z of global all {
gen `z'_missing = 0 
replace `z'_missing = 1 if `z'==.
}

global allmisss LSval_r_missing LEval_r_missing NUval_r_missing SAval_r_missing INval_r_missing ENval_r_missing EDval_r_missing SSval_r_missing DQval_r_missing EMval_r_missing 
global allmissp CO2footCum_r_missing PfootPerCap_r_missing NfootPerCap_r_missing ehanppPerCap_r_missing EFfootPerCap_r_missing MFfootPerCap_r_missing 

gen social_missing_count = 0
foreach z of global allmisss {
replace social_missing_count = social_missing_count+1 if `z'==1
}

gen physical_missing_count= 0
foreach z of global allmissp {
replace physical_missing_count = physical_missing_count+1 if `z'==1
}

gen sum_social=0
global social LSval_r LEval_r NUval_r SAval_r INval_r ENval_r EDval_r SSval_r  DQval_r  EMval_r 
foreach z of global social {
replace sum_social= sum_social + `z' if `z'!=.
}

gen sum_physical=0
global physical CO2footCum_r  PfootPerCap_r  NfootPerCap_r  ehanppPerCap_r  EFfootPerCap_r  MFfootPerCap_r
foreach z of global physical {
replace sum_physical= sum_physical + `z' 
}

gen social_present = 10 - social_missing_count 
gen physical_present = 6 - physical_missing_count 
gen social_mean_ratio = sum_social/ social_present
gen physical_mean_ratio = sum_physical/ physical_present
replace social_mean_ratio=. if social_present<5
replace physical_mean_ratio=. if physical_present<3

label variable social_mean_ratio "Social living standards (mean over all indicators), as ratio (1 = minimum standards achieved)"
label variable physical_mean_ratio "Transgression of planetary boundaries (mean over all indicators), as ratio (1 = boundary)"

/* social_mean_adj : adjusted for missing categories; not missing automatically with the first missing category */
/* physical_mean_adj: adjusted for missing categories; not missing automatically with the first missing category */

save "/$datapath/Fanning2.dta", replace
