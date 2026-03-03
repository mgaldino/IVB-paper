

 ****************************************************************************************************************************
 ******************Step 6 a) 		REGIME TURNOVER: DECOLONISATION
 *************************************************************************************************************************


				 
				gen colony = 1- indep
				bys year: egen indep_sum = total(indep)
				gen decolon = 1 if year >= 1957 & indep == 0 
				replace decolon = 0 if decolon != 1
				sleep 1000
				save "Temp/Master", replace


 ****************************************************************************************************************************
 ******************Step 6 b) 		REGIME TURNOVER: REGIME CHANGE (VDEM DATA)
 *************************************************************************************************************************
  
				  
				 use "Data/Turnover/V-Dem_regime_change", clear

				gen regime_end = substr(v2reginfo, -5,  4) 
				replace regime_end = "" if regime_end ==  " - E" | regime_end == "egim"
				destring regime_end, gen(regime_year)
				drop regime_end

				preserve
				collapse (mean) regime_year, by(iso year)
				gen regime_end =1
				drop year
				rename regime_year year
				sort iso year
				gen year_r =  floor(year)
				drop year
				rename year_r year
				bys iso year:  gen dup = cond(_N==1,0,_n)
				drop if dup>1
				drop dup
				drop if year == .
				save "TEMP/regime_end.dta", replace
				restore

				preserve
				collapse(sum) v2eltvrexo, by(iso year)
				replace v2eltvrexo = 2 if v2eltvrexo > 2 
				gen elec_change = 1 if v2eltvrexo == 2 
				drop if elec_change != 1 
				drop v2eltvrexo
				save "TEMP/elec_change.dta", replace
				restore
				clear

				use "Temp/Master", clear

				merge 1:1 iso year using "TEMP/regime_end.dta"
				drop if _merge==2
				drop _merge

				merge 1:1 iso year using "TEMP/elec_change.dta"
				drop if _merge==2 
				drop _merge

				xtset iso_n year
				sort iso_n year

				replace regime_end = 0 if regime_end != 1
				replace elec_change = 0 if elec_change != 1
				gen gov_change = regime_end + elec_change
				replace gov_change = 1 if gov_change == 2
				 

				  save "Temp/Master", replace





 ****************************************************************************************************************************
 ******************Step 6 c) 		REGIME TURNOVER: LEADER TURNOVER (Archigos)
 *************************************************************************************************************************

				use "Data/Turnover/Archigos/Leader_turnover_ARCHIGOS.dta", clear

				encode leader, gen(leader_n)
				bys iso: gen leader_change = 1 if leader_n[_n] != leader_n[_n+1]
				replace leader_change  = 0 if year == 2015 // no leader change in last year possible
				replace leader_change  = 0 if leader_n == .
				replace leader_change  = 0 if leader_change == .

				replace leaderomitted = 0 if leaderomitted == .
				 gen leader_change_ARCHIGOS = leader_change + leaderomitted
				 replace leader_change_ARCHIGOS = 0 if leader_change_ARCHIGOS == .
				 
				 replace iso = "BDI" if iso == "BRD"
				 
				 save "Temp/Leader_turnover_ARCHIGOS_1.dta", replace
				 
				 use "Temp/Master", clear
				 
				 merge 1:1 iso year using "Temp/Leader_turnover_ARCHIGOS_1.dta", keepusing(leader_change_ARCHIGOS)
				 drop if _merge == 2
				 drop _merge
				 
				 
				  save "Temp/Master", replace
  
