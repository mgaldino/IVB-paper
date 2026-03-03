
 ****************************************************************************************************************************
 ******************Step 7a 	CONFLICT
 *************************************************************************************************************************

 
 
 *UCDP PRIO in conflict-year format, with multiple entries and parties per year // we are adding up ordinal units here -  converted to dummy later
 
 use "Data/Conflict/UCDP PRIO updated v16.dta", clear
 
 gen col_war_all_PRIO = 1 if type_of_conflict == 1 
 gen col_war_maj_PRIO = 1 if type_of_conflict == 1 & intensity_level == 2
collapse(sum) col_war_all_PRIO col_war_maj_PRIO, by(iso year)
replace col_war_maj_PRIO =1 if col_war_maj_PRIO >1
replace col_war_all_PRIO =1 if col_war_all_PRIO >1

save "TEMP/col_war.dta", replace

 use "Data/Conflict/UCDP PRIO updated v16.dta", clear

gen col_war_all_PRIO = 1 if type_of_conflict == 1 
 gen col_war_maj_PRIO = 1 if type_of_conflict == 1 & intensity_level == 2
collapse(sum) col_war_all_PRIO col_war_maj_PRIO if iso_b != "", by(iso_b year)
replace col_war_maj_PRIO =1 if col_war_maj_PRIO >1
replace col_war_all_PRIO =1 if col_war_all_PRIO >1
rename iso_b iso

save "TEMP/col_war_b.dta", replace

 use "Data/Conflict/UCDP PRIO updated v16.dta", clear
 
 gen int_war_all_PRIO = 1 if type_of_conflict == 2 
 gen int_war_maj_PRIO = 1 if type_of_conflict == 2 & intensity_level == 2
collapse(sum) int_war_maj_PRIO int_war_all_PRIO, by(iso year)
replace int_war_maj_PRIO =1 if int_war_maj_PRIO >1
replace int_war_all_PRIO =1 if int_war_all_PRIO >1

save "TEMP/int_war.dta", replace

 use "Data/Conflict/UCDP PRIO updated v16.dta", clear
 
 gen int_war_all_PRIO = 1 if type_of_conflict == 2 
 gen int_war_maj_PRIO = 1 if type_of_conflict == 2 & intensity_level == 2
collapse(sum) int_war_maj_PRIO int_war_all_PRIO if iso_b != "", by(iso_b year)
replace int_war_maj_PRIO =1 if int_war_maj_PRIO >1
replace int_war_all_PRIO =1 if int_war_all_PRIO >1
rename iso_b iso

save "TEMP/int_war_b.dta", replace

 use "Data/Conflict/UCDP PRIO updated v16.dta", clear
 
 gen civ_war_all_PRIO = 1 if (type_of_conflict == 3 | type_of_conflict == 4) 
 gen civ_war_maj_PRIO = 2 if (type_of_conflict == 3 | type_of_conflict == 4)  & intensity_level == 2
collapse(sum) civ_war_all_PRIO civ_war_maj_PRIO, by(iso year)
replace civ_war_all_PRIO =1 if civ_war_all_PRIO >1
replace civ_war_maj_PRIO =1 if civ_war_maj_PRIO >1

save "TEMP/civ_war.dta", replace

  
use "TEMP/Master", clear

merge 1:1 iso year using "TEMP/col_war.dta"
drop if _merge == 2
drop _merge

merge 1:1 iso year using "TEMP/col_war_b.dta", update replace
drop if _merge == 2
drop _merge

merge 1:1 iso year using "TEMP/int_war.dta"
drop if _merge == 2
drop _merge

merge 1:1 iso year using "TEMP/int_war_b.dta", update replace
drop if _merge == 2
drop _merge

merge 1:1 iso year using "TEMP/civ_war.dta"
drop if _merge == 2
drop _merge

 

foreach var of varlist *_PRIO {
replace `var' = 0 if `var' == .
}

gen int_war_all_sum_PRIO = col_war_all_PRIO + int_war_all_PRIO 
gen int_war_maj_sum_PRIO = col_war_maj_PRIO + int_war_maj_PRIO 
replace int_war_all_sum_PRIO =1 if int_war_all_sum_PRIO >1
replace int_war_maj_sum_PRIO =1 if int_war_maj_sum_PRIO >1

sort iso_n year

gen l5col_war_all_PRIO = l1.col_war_all_PRIO+ l2.col_war_all_PRIO + l3.col_war_all_PRIO + l4.col_war_all_PRIO + l5.col_war_all_PRIO
gen l5col_war_maj_PRIO = l1.col_war_maj_PRIO+ l2.col_war_maj_PRIO + l3.col_war_maj_PRIO + l4.col_war_maj_PRIO + l5.col_war_maj_PRIO
gen l5int_war_all_PRIO = l1.int_war_all_PRIO + l2.int_war_all_PRIO + l3.int_war_all_PRIO + l4.int_war_all_PRIO + l5.int_war_all_PRIO
gen l5int_war_maj_PRIO = l1.int_war_maj_PRIO + l2.int_war_maj_PRIO + l3.int_war_maj_PRIO + l4.int_war_maj_PRIO + l5.int_war_maj_PRIO
gen l5civ_war_all_PRIO = l1.civ_war_all_PRIO + l2.civ_war_all_PRIO + l3.civ_war_all_PRIO + l4.civ_war_all_PRIO + l5.civ_war_all_PRIO
gen l5civ_war_maj_PRIO = l1.civ_war_maj_PRIO + l2.civ_war_maj_PRIO + l3.civ_war_maj_PRIO + l4.civ_war_maj_PRIO + l5.civ_war_maj_PRIO
gen l5int_war_all_sum_PRIO = l1.int_war_all_sum_PRIO + l2.int_war_all_sum_PRIO + l3.int_war_all_sum_PRIO + l4.int_war_all_sum_PRIO + l5.int_war_all_sum_PRIO
gen l5int_war_maj_sum_PRIO = l1.int_war_maj_sum_PRIO + l2.int_war_maj_sum_PRIO + l3.int_war_maj_sum_PRIO + l4.int_war_maj_sum_PRIO + l5.int_war_maj_sum_PRIO

gen all_war_all_PRIO = 1 if ( col_war_all_PRIO != . & col_war_all_PRIO > 0) | ( int_war_all_PRIO != . & int_war_all_PRIO > 0) | ( civ_war_all_PRIO != . & civ_war_all_PRIO > 0)
replace all_war_all_PRIO = 0 if all_war_all_PRIO != 1
gen all_war_maj_PRIO = 1 if ( col_war_maj_PRIO != . & col_war_maj_PRIO > 0) | ( int_war_maj_PRIO != . & int_war_maj_PRIO > 0) | ( civ_war_maj_PRIO != . & civ_war_maj_PRIO > 0)
replace all_war_maj_PRIO = 0 if all_war_maj_PRIO != 1


* save 
save "TEMP/Master", replace
 
