cap program drop indvar_separate_ctrls

program define indvar_separate_ctrls

syntax varlist, indvar(varlist) title(string)

	foreach depvar in `varlist' {
		foreach indvar of varlist `indvar' {

		local title `title'
		local label: var label `depvar' 

		xtreg `depvar' `indvar' $ictrls_3l_varying, fe
			eststo ucdp_all_ctrls
				estadd local FE "Yes"
				estadd local time "N/A"
				estadd local ctrls "Yes"


				
		foreach n in 0 1 2 3 {
					
			xtreg `depvar' `indvar' $ictrls_3l_varying if ucdp_`n'yrs==1, fe
				eststo ucdp_`n'yrs_ctrls
					estadd local FE "Yes"
					estadd local time "`n'"
					estadd local ctrls "Yes"
				}
				
		esttab ucdp_all_ctrls ucdp_0yrs_ctrls ucdp_1yrs_ctrls ucdp_2yrs_ctrls ucdp_3yrs_ctrls using "output/`title'.tex", replace ///
			label booktabs b(3) se(3) eqlabels(none) br ///
			mgroups("`label'", pattern(1 0 0 0 0 0 0 0 0 0) ///
			prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
			keep(`indvar') nomtitles ///
			star(* 0.10 ** 0.05 *** 0.01) nonotes scalars("ctrls Controls" "FE Country FE" "time Years of peace" ) 
						
		}
	}
						
end
		
		
