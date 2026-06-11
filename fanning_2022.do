

import excel "$datapath/SocialShortfallAndEcologicalOvershoot_SupplementaryData.xlsx", sheet("Biophysical_Historical") firstrow clear
save "$datapath/biophysical_middle.dta", replace

import excel "$datapath/SocialShortfallAndEcologicalOvershoot_SupplementaryData.xlsx", sheet("Social_Historical") firstrow clear

merge m:m iso3c date using "$datapath/biophysical_middle.dta"
drop _merge
save "$datapath/fanning2021.dta", replace

********************************************************************************
** (1) Rough approximation (Hickel Fig. 1)

bysort iso3c date: gen social_mean = (LifeSatisfaction + LifeExpectancy + Nutrition + Sanitation + IncomePoverty + AccesstoEnergy + Education + SocialSupport + DemocraticQuality + Equality + Employment) / 11
bysort iso3c date: gen physical_mean = (CO2Emissions + Phosphorus + Nitrogen + LandSystemChange + EcologicalFootprint + MaterialFootprint) / 6

global all LifeSatisfaction LifeExpectancy Nutrition Sanitation IncomePoverty AccesstoEnergy Education SocialSupport DemocraticQuality Equality Employment CO2Emissions Phosphorus Nitrogen LandSystemChange EcologicalFootprint MaterialFootprint

foreach z of global all {
gen `z'_missing = 0 
replace `z'_missing = 1 if `z'==.
}

gen social_missing_count = LifeSatisfaction_missing + LifeExpectancy_missing + Nutrition_missing + Sanitation_missing + IncomePoverty_missing + AccesstoEnergy_missing + Education_missing + SocialSupport_missing + DemocraticQuality_missing + Equality_missing + Employment_missing
gen physical_missing_count= CO2Emissions_missing + Phosphorus_missing + Nitrogen_missing + LandSystemChange_missing + EcologicalFootprint_missing + MaterialFootprint_missing

gen sum_social=0
global social LifeSatisfaction LifeExpectancy Nutrition Sanitation IncomePoverty AccesstoEnergy Education SocialSupport DemocraticQuality Equality Employment
foreach z of global social {
replace sum_social= sum_social + `z' if `z'!=.
}

gen sum_physical=0
global physical CO2Emissions Phosphorus Nitrogen LandSystemChange EcologicalFootprint MaterialFootprint
foreach z of global physical {
replace sum_physical= sum_physical + `z' 
}

gen social_present = 11 - social_missing_count
gen physical_present = 6 - physical_missing_count 
gen social_mean2 = sum_social/ social_present
gen physical_mean2 = sum_physical/ physical_present
replace social_mean2=. if social_present<6
replace physical_mean2=. if physical_present<3

scatter  social_mean physical_mean
scatter  social_mean physical_mean if date==2015, mlabel(country)

scatter social_mean social_mean2
scatter social_mean social_mean2
scatter physical_mean physical_mean2

scatter social_mean2 physical_mean2, yline(1) xline(1)
scatter social_mean2 physical_mean2 if date==2015, mlabel(country)

********************************************************************************
** (2) Without including equality

global all LifeSatisfaction LifeExpectancy Nutrition Sanitation IncomePoverty AccesstoEnergy Education SocialSupport DemocraticQuality Employment CO2Emissions Phosphorus Nitrogen LandSystemChange EcologicalFootprint MaterialFootprint

foreach z of global all {
gen `z'_missingfm = 0 
replace `z'_missingfm = 1 if `z'==.
}

gen social_missing_countfm = LifeSatisfaction_missing + LifeExpectancy_missing + Nutrition_missing + Sanitation_missing + IncomePoverty_missing + AccesstoEnergy_missing + Education_missing + SocialSupport_missing + DemocraticQuality_missing + Employment_missing
gen physical_missing_countfm= CO2Emissions_missing + Phosphorus_missing + Nitrogen_missing + LandSystemChange_missing + EcologicalFootprint_missing + MaterialFootprint_missing

gen sum_socialfm=0
global social LifeSatisfaction LifeExpectancy Nutrition Sanitation IncomePoverty AccesstoEnergy Education SocialSupport DemocraticQuality Employment
foreach z of global social {
replace sum_socialfm= sum_socialfm + `z' if `z'!=.
}

gen social_presentfm = 10 - social_missing_countfm
gen social_mean3 = sum_socialfm/ social_presentfm
replace social_mean3=. if social_presentfm<5

scatter social_mean3 social_mean2

scatter social_mean3 physical_mean2
scatter social_mean3 physical_mean2 if date==2015, mlabel(country)

scatter social_mean3 physical_mean2, yline(1) xline(1)



rename date year

do "$codepath/country_codes_wb.do"
replace cnid=52 if country=="Czech Republic"
replace cnid=101 if country=="Korea, Dem. People's Rep." /*North Korea*/
replace cnid=197 if country=="Turkey"
replace cnid=210 if country=="Vietnam"
drop iso3c

save "$datapath/fanning2021.dta", replace

