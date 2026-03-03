
 ****************************************************************************************************************************
 ******************Step 5 a)	COHESIVE INSTITUTIONS: DEMOCRACY
 *************************************************************************************************************************

 
 
** Load VDEM dataset 
 

		merge 1:1 iso year using "Data/Democracy/VDEM_small", keepusing(v2x_polyarchy v2x_libdem v2x_partipdem v2x_delibdem v2x_egaldem v2x_suffr v2stfisccap v2x_jucon v2xlg_legcon)
		drop if _merge ==2
		drop _merge

//replace CMR values with Togo (both former German colonies under French mandates)

			foreach var of varlist v2x_polyarchy v2x_libdem v2x_partipdem v2x_delibdem v2x_egaldem v2x_suffr v2stfisccap v2x_jucon v2xlg_legcon {
			bys year: egen `var'_temp = mean(`var') if iso == "TGO"
			}

			foreach var of varlist *_temp {
			bysort year (`var'): replace `var' = `var'[1]
			}

			replace v2x_polyarchy = v2x_polyarchy_temp if iso == "CMR" & year < 1960
			replace v2x_libdem = v2x_libdem_temp if iso == "CMR" & year < 1960
			replace  v2x_partipdem =  v2x_partipdem_temp if iso == "CMR" & year < 1960
			replace  v2x_delibdem =  v2x_delibdem_temp if iso == "CMR" & year < 1960
			replace  v2x_egaldem=  v2x_egaldem_temp if iso == "CMR" & year < 1960
			replace   v2x_suffr=   v2x_suffr_temp if iso == "CMR" & year < 1960
			replace   v2stfisccap=   v2stfisccap if iso == "CMR" & year < 1960
			replace   v2x_jucon=   v2x_jucon if iso == "CMR" & year < 1960
			replace    v2xlg_legcon=    v2xlg_legcon if iso == "CMR" & year < 1960
				
			drop *_temp
				
//extend VDEM coding backward for remaining missing years - including for those that change coloniser (German territories)

			foreach var of varlist v2x_polyarchy v2x_libdem v2x_partipdem v2x_delibdem v2x_egaldem v2x_suffr v2stfisccap v2x_jucon v2xlg_legcon {
			bys iso: ipolate `var' year if year >= 1900, gen (`var'_extra) 
			}

			sort iso year

			forvalues i = 1/35 {
			foreach var of varlist *_extra {
			bysort iso : replace `var' = `var'[_n+1] if `var' == . & year <1925
			}
			}

			rename v2stfisccap v2x_stfisccap
			rename v2xlg_legcon v2x_legcon
			rename v2stfisccap_extra v2x_stfisccap_extra
			rename v2xlg_legcon_extra v2x_legcon_extra
			rename v2x_* *_vdem

 

save  "Temp/Master", replace
