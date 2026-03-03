/***********************************************************************************************
*
*   Replication files for "UN Peacekeeping and Democratization in Conflict-Affected Countries"
*   American Political Science Review
*   Robert A. Blair, Jessica Di Salvatore, and Hannah M. Smidt
*
***********************************************************************************************/



		clear
		set more off
		clear matrix
		clear mata
		set maxvar 15000
		set seed 12345
		
		graph set window fontface "Times"

		
	
	* Change directory
		
		capture cd "[YOUR DIRECTORY]"
		
		
		
		
	* Load dataset
				
		use "data_replication.dta", clear

	

	* Drop observations for Eritrea before 1993 and South Sudan before 2011
	
		drop if gwnoloc==531 & year<1993
		drop if gwnoloc==626 & year<2011

		

	* Generate lagged dependent variables
		
		sort gwnoloc year
		
		foreach x of varlist v2x_polyarchy polity2 fh_pr_rec democracy ///
			{
			gen `x'_1l=`x'[_n-1]
			gen `x'_2l=`x'[_n-2]
			gen `x'_3l=`x'[_n-3]
			gen `x'_4l=`x'[_n-4]
			gen `x'_5l=`x'[_n-5]
			
			local lab: variable label `x'
			
			la var `x'_1l "`lab' (1 yr lag)"
			la var `x'_2l "`lab' (2 yr lag)"
			la var `x'_3l "`lab' (3 yr lag)"
			la var `x'_4l "`lab' (4 yr lag)"
			la var `x'_5l "`lab' (5 yr lag)"
			}

			
			
	* Divide personnel numbers by 1,000

		gen itotal_compound_K = itotal_compound / 1000
			la var itotal_compound_K "\# of uniformed personnel (1K units)"
		
		gen iactual_civilian_total_K = iactual_civilian_total / 1000
			la var iactual_civilian_total_K "\# of civilian personnel (1K units)"
	
	
	
	* Generate lagged independent variables
		
		sort gwnoloc year
		
		foreach x of varlist ///
			itotal_compound_K iactual_civilian_total_K idemo_all_max_dum ivoters_all_max_dum iparties_all_max_dum iany_demo_all_max_dum iany_demo_rel_all_max_dum ielections_all_max_dum iall_demo_max ///
			iany_demo_engage_max_dum iany_demo_bypass_max_dum ipema_any_demo_assist_dum ipema_any_demo_rel_assist_dum ipema_any_demo_agg  iall_demo_engage_max iall_demo_bypass_max ///
				{
					gen `x'_1l=`x'[_n-1]
					gen `x'_2l=`x'[_n-2]
					gen `x'_3l=`x'[_n-3]
					gen `x'_4l=`x'[_n-4]
					
				local lab: variable label `x'
				
				la var `x'_1l "`lab' (1 yr lag)"
				la var `x'_2l "`lab' (2 yr lag)"
				la var `x'_3l "`lab' (3 yr lag)"
				la var `x'_4l "`lab' (3 yr lag)"
				
				}

				
		
	* Set missing values on control variables to within-country means 
				
		foreach x of varlist wdi_pop wdi_oda wdi_gdppc unhcr_ref_idp wdi_literacy wdi_fuel  {
			bys gwnoloc: egen `x'_mean=mean(`x')
			gen i`x'=`x'
			replace i`x'=`x'_mean if `x'==.
				local lab: variable label `x'
				lab var i`x' "`lab' (missing = within-country mean)"
					drop `x'_mean
			}

		
					
	* Generate lagged control variables
		
		sort gwnoloc year
							
		foreach x of varlist ///
			iwdi_pop iwdi_oda iwdi_gdppc iunhcr_ref_idp iwdi_literacy iwdi_fuel ///
			{
			gen `x'_2l=`x'[_n-2]
			gen `x'_3l=`x'[_n-3]
			gen `x'_4l=`x'[_n-4]
			gen `x'_5l=`x'[_n-5]
			gen `x'_6l=`x'[_n-6]

				local lab: variable label `x'
				
				la var `x'_2l "`lab' (2 yr lag)"
				la var `x'_3l "`lab' (3 yr lag)"
				la var `x'_4l "`lab' (4 yr lag)"
				la var `x'_5l "`lab' (5 yr lag)"
				la var `x'_6l "`lab' (5 yr lag)"

			}



	* Generate instruments
								
		sort gwnoloc year
								
		tab gwnoloc, gen(country_temp)
		
		gen ianydemoallmaxdum = iany_demo_all_max_dum 
		gen ipemaanydemoassistdum = ipema_any_demo_assist_dum
				
		foreach x of varlist ianydemoallmaxdum ipemaanydemoassistdum ///
			{ 
			gen `x'_iv = .
			}
		
		foreach x of varlist ianydemoallmaxdum ipemaanydemoassistdum ///
			{ 
			foreach n of numlist 1/42 {
				bys year: egen `x'_`n'=mean(`x') if country_temp`n'!=1
				bys year: replace `x'_`n'=-1 if country_temp`n'==1
				bys year: egen `x'_`n'_max=max(`x'_`n') if `x'_`n'!=.
				}

			foreach n of numlist 1/42 {
				bys year: replace `x'_iv=`x'_`n'_max if country_temp`n'==1
				}						
			}	
					
		foreach x of varlist ianydemoallmaxdum ipemaanydemoassistdum ///
			{ 
				drop `x'_1 - `x'_42_max		
			}			
					
		foreach x of varlist ianydemoallmaxdum ipemaanydemoassistdum ///
			{ 
			foreach n of numlist 1/42 {
				bys year: egen `x'_`n'=mean(`x') if country_temp`n'!=1 & pko_p4p==1
				bys year: replace `x'_`n'=-1 if country_temp`n'==1
				bys year: egen `x'_`n'_max=max(`x'_`n') if `x'_`n'!=.
				}
			}
			
		foreach x of varlist ianydemoallmaxdum ipemaanydemoassistdum ///
			{ 
				drop `x'_1 - `x'_42_max		
				replace `x'_iv = . if `x'_iv == -1
			}	
			
			drop ianydemoallmaxdum ipemaanydemoassistdum
			
			ren ianydemoallmaxdum_iv iany_demo_all_maxdiv
			ren ipemaanydemoassistdum_iv ipema_any_demo_assdiv

			drop country_temp*
				
			la var iany_demo_all_maxdiv "\% democracy activities in other missions" 
			la var ipema_any_demo_assdiv "\% democracy mandate components in other missions" 
							
							
				
	* Generate lagged instruments

		sort gwnoloc year

		foreach x of varlist ///
			iany_demo_all_maxdiv ipema_any_demo_assdiv ///		
				{
					gen `x'_1l=`x'[_n-1]
					gen `x'_2l=`x'[_n-2]
					gen `x'_3l=`x'[_n-2]
					
					local lab: variable label `x'
				
					la var `x'_1l "`lab' (1 yr lag)"
					la var `x'_2l "`lab' (2 yr lag)"
					la var `x'_3l "`lab' (3 yr lag)"
				}

			
									
	* Generate dummies for conflict and post-conflict samples

		gen ucdp_0yrs=ucdp
	
		gen ucdp_1yrs=0
			bys gwnoloc: replace ucdp_1yrs=. if ucdp_ever==0
			bys gwnoloc: replace ucdp_1yrs=1 if year>=ucdp_end_alt+1
			bys gwnoloc: replace ucdp_1yrs=0 if ucdp==1
	
		gen ucdp_2yrs=0
			bys gwnoloc: replace ucdp_2yrs=. if ucdp_ever==0
			bys gwnoloc: replace ucdp_2yrs=1 if year>=ucdp_end_alt+2
			bys gwnoloc: replace ucdp_2yrs=0 if ucdp==1

		gen ucdp_3yrs=0
			bys gwnoloc: replace ucdp_3yrs=. if ucdp_ever==0
			bys gwnoloc: replace ucdp_3yrs=1 if year>=ucdp_end_alt+3
			bys gwnoloc: replace ucdp_3yrs=0 if ucdp==1

		bys gwnoloc: egen ucdp_first_start_alt = min(ucdp_start_alt) if ucdp_start_alt!=.
		
		foreach n of numlist 1 2 3 {
			replace ucdp_`n'yrs = . if year<ucdp_first_start_alt
		}

		drop ucdp_first_start_alt
		
		la var ucdp_0yrs "In armed conflict (UCDP)"
		la var ucdp_1yrs "One year after end of armed conflict (UCDP)"
		la var ucdp_2yrs "Two years after end of armed conflict (UCDP)"
		la var ucdp_3yrs "Three years after end of armed conflict (UCDP)"
			
			
	
	* Generate interaction terms
	
		foreach x in itotal_compound_K iactual_civilian_total_K iany_demo_all_max_dum {
			gen ipema_`x'=ipema_any_demo_assist_dum_2l * `x'_2l
		}
	
		foreach x in iactual_civilian_total_K iany_demo_all_max_dum {
			gen itotal_`x'=itotal_compound_K_2l * `x'_2l
		}
	
		gen iany_iactual_civilian_total_K = iany_demo_all_max_dum_2l * iactual_civilian_total_K_2l
	
		la var ipema_itotal_compound_K "Democracy mandate $\times$ \# of uniformed personnel"
		la var ipema_iactual_civilian_total_K "Democracy mandate $\times$ \# of civilian personnel"
		la var ipema_iany_demo_all_max_dum "Dmocracy mandate $\times$ any democracy activities"
		
		la var itotal_iactual_civilian_total_K "\# of uniformed personnel $\times$ \# of civilian personnel"
		la var itotal_iany_demo_all_max_dum "\# of uniformed personnel $\times$ any democracy activities"
		
		la var iany_iactual_civilian_total_K "Any democracy activities $\times$ \# of civilian personnel"
		
	
	
	
	* Generate version of uniformed personnel for country-years with data on civilian personnel
		
		gen itotal_compound_K_2l_civ = itotal_compound_K_2l
			replace itotal_compound_K_2l_civ=. if iactual_civilian_total_K_2l==.
			la var itotal_compound_K_2l_civ "\# of uniformed personnel (restricted sample)"

	
	
	
	* Code changes in number of democracy mandate components over time
		
		gen ipema_any_demo_more_2l = 0
			replace ipema_any_demo_more_2l = 1 if ipema_any_demo_agg_2l>ipema_any_demo_agg_3l & ipema_any_demo_agg_2l!=. & ipema_any_demo_agg_3l!=.

			la var ipema_any_demo_more_2l "More democracy mandate components than previous year (2 yr lag)"
			
		gen ipema_any_demo_less_2l = 0
			replace ipema_any_demo_less_2l = 1 if ipema_any_demo_agg_2l<ipema_any_demo_agg_3l & ipema_any_demo_agg_2l!=. & ipema_any_demo_agg_3l!=.

			la var ipema_any_demo_less_2l "Fewer democracy mandate components than previous year (2 yr lag)"

		gen ipema_any_demo_diff_2l = ipema_any_demo_agg_2l-ipema_any_demo_agg_3l
			gen ipema_any_demo_diff=ipema_any_demo_diff_2l[_n+2]
			
			la var ipema_any_demo_diff "Change in \# of mandated democracy tasks from previous year"
			la var ipema_any_demo_diff_2l "Change in \# of mandated democracy tasks from previous year (2 yr lag)"
				

	
	
	* Relabel variables for parsimony in tables and figures
	
		la var v2x_polyarchy_2l "Electoral democracy (V-Dem)"
		la var v2x_polyarchy_3l "Electoral democracy (V-Dem, lagged)"
		la var v2x_polyarchy_4l "Electoral democracy (V-Dem, +2 lags)"
		
		la var iany_demo_all_max_dum_2l "Any democracy activities"
		la var iany_demo_all_max_dum_3l "Any democracy activities (+1 lag)"
		la var iany_demo_all_max_dum_4l "Any democracy activities (+2 lags)"
		
		la var iany_demo_rel_all_max_dum_2l "Any democracy-related activities"
		la var iall_demo_max_2l  "\# of distinct democracy activities"
		la var idemo_all_max_dum_2l "Any democratic institution activities"
		la var ielections_all_max_dum_2l "Any election activities"
		la var iparties_all_max_dum_2l "Any political party activities"
		la var ivoters_all_max_dum_2l "Any voter activities"
		
		la var iany_demo_engage_max_dum_2l "Any democracy engagement with host state"
		la var iany_demo_bypass_max_dum_2l "Any democracy bypassing of host state"
		
		la var iall_demo_engage_max_2l "# of distinct democracy activities engaging host state"
		la var iall_demo_bypass_max_2l "# of distinct democracy activities bypassing host state"
				
		la var ipema_any_demo_assist_dum_2l "Democracy mandate"
		la var ipema_any_demo_assist_dum_3l "Democracy mandate (+1 lag)"
		la var ipema_any_demo_assist_dum_4l "Democracy mandate (+2 lags)"
		
		la var ipema_any_demo_rel_assist_dum_2l "Democracy-related mandate"
		
		la var ipema_any_demo_assdiv_2l "\% democracy mandates in other missions" 
				
		la var ipema_any_demo_diff_2l "Change in \# of mandated democracy tasks from previous year"
		la var ipema_any_demo_agg_2l "\# of distinct democracy tasks in mandate"
		
		la var iactual_civilian_total_K_2l "\# of civilian personnel"
		la var iactual_civilian_total_K_3l "\# of civilian personnel (+1 lag)"
		la var iactual_civilian_total_K_4l "\# of civilian personnel (+2 lags)"
				
		la var itotal_compound_K_2l "\# of uniformed personnel"
		la var itotal_compound_K_3l "\# of uniformed personnel (+1 lag)"
		la var itotal_compound_K_4l "\# of uniformed personnel (+2 lags)"
		
		la var itotal_compound_K_2l_civ "\# of uniformed personnel (restricted sample)"
				
		la var iwdi_pop_3l "Population"
		la var iwdi_oda_3l "Foreign aid"
		la var iwdi_gdppc_3l "GDP per capita"
		la var iunhcr_ref_idp_3l "Refugees"
		la var iwdi_literacy_3l "Literacy"
		la var iwdi_fuel_3l "Fuel exports"
		
		la var iwdi_pop_4l "Population (+1 lag)"
		la var iwdi_oda_4l "Foreign aid (+1 lag)"
		la var iwdi_gdppc_4l "GDP per capita (+1 lag)"
		la var iunhcr_ref_idp_4l "Refugees (+1 lag)"
		la var iwdi_literacy_4l "Literacy (+1 lag)"
		la var iwdi_fuel_4l "Fuel exports (+1 lag)"

		la var iwdi_pop_5l "Population (+2 lags)"
		la var iwdi_oda_5l "Foreign aid (+2 lags)"
		la var iwdi_gdppc_5l "GDP per capita (+2 lags)"
		la var iunhcr_ref_idp_5l "Refugees (+2 lags)"
		la var iwdi_literacy_5l "Literacy (+2 lags)"
		la var iwdi_fuel_5l "Fuel exports (+2 lags)"

	
	
	
	* Drop observations before 1991 (accounting for lags)
	
		drop if year<1991
	
	
	
	
	* Set globals
			
		gl ictrls_2l_varying iwdi_pop_2l iwdi_oda_2l iwdi_gdppc_2l iunhcr_ref_idp_2l iwdi_literacy_2l iwdi_fuel_2l 

		gl ictrls_3l_varying iwdi_pop_3l iwdi_oda_3l iwdi_gdppc_3l iunhcr_ref_idp_3l iwdi_literacy_3l iwdi_fuel_3l

		gl ictrls_4l_varying iwdi_pop_4l iwdi_oda_4l iwdi_gdppc_4l iunhcr_ref_idp_4l iwdi_literacy_4l iwdi_fuel_4l

		gl ictrls_5l_varying iwdi_pop_5l iwdi_oda_5l iwdi_gdppc_5l iunhcr_ref_idp_5l iwdi_literacy_5l iwdi_fuel_5l

		
				
		
		
	* Load programs
	
	
		do "programs/indvar_separate_ctrls.ado"
		do "programs/indvar_separate_re_ctrls.ado"
		do "programs/indvar_separate_laggedDV_ctrls.ado"
		do "programs/indvar_separate_laggedDV_ctrls_nofe.ado"
		do "programs/indvar_separate_ctrls_4l.ado"
		do "programs/indvar_separate_ctrls_5l.ado"		
		do "programs/indvar_together_ctrls.ado"
		do "programs/indvar_together_laggedDV_ctrls.ado"
		do "programs/indvar_together_laggedDV_ctrls_nofe.ado"
		do "programs/iv_ctrls_simple.ado"
		do "programs/iv_ctrls.ado"

		
		


			
				
STOP




*************
*** PAPER ***
*************



	* Replicate Figure 1

		set scheme plotplainblind
		
		preserve
			drop if year>2016
			collapse (sum) ipema_any_demo_assist_dum, by(year)
			twoway line ipema_any_demo_assist_dum year, ytitle("# of countries with democracy mandate") xtitle("Year") xlab(1991(5)2016)
			graph export "output/figure1_top.pdf", replace
		restore
		
		preserve
			drop if year>2016
			collapse (sum) iany_demo_all_max_dum, by(year)
			twoway line iany_demo_all_max_dum year, ytitle("# of countries with any democracy activities") xtitle("Year") xlab(1991(5)2016)
			graph export "output/figure1_bottom.pdf", replace
		restore


	* Replicate Table 2

		indvar_separate_ctrls v2x_polyarchy, indvar(ipema_any_demo_assist_dum_2l) title(table2)
				
	* Replicate Table 3
	
		iv_ctrls_simple v2x_polyarchy, indvar(ipema_any_demo_assist_dum_2l) iv(ipema_any_demo_assdiv_2l) title(table3)
		
	* Replicate Table 4

		indvar_separate_ctrls v2x_polyarchy, indvar(itotal_compound_K_2l) title(table4)
		
	* Replicate Table 5

		indvar_separate_ctrls v2x_polyarchy, indvar(iactual_civilian_total_K_2l) title(table5)	
		
	* Replicate Table 6

		indvar_separate_ctrls v2x_polyarchy, indvar(iany_demo_all_max_dum_2l) title(table6)	

	* Replicate Table 7
	
		iv_ctrls_simple v2x_polyarchy, indvar(iany_demo_all_max_dum_2l) iv(iany_demo_all_maxdiv_2l) title(table7)
				
	* Replicate Table 8

		indvar_together_ctrls v2x_polyarchy, indvar(iany_demo_engage_max_dum_2l iany_demo_bypass_max_dum_2l) title(table8)

	* Replicate Table 9
		
		indvar_together_ctrls v2x_polyarchy, indvar(idemo_all_max_dum_2l ielections_all_max_dum_2l iparties_all_max_dum_2l ivoters_all_max_dum_2l) title(table9) 

		
	
		
		
****************
*** APPENDIX ***
****************



	* Replicate Figure A1

		preserve

		drop if year>2016
		
		set scheme plotplainblind
		
		twoway line itotal_compound year if country=="Angola", ///
			ytitle("# of uniformed personnel", margin(small)) xtitle("Year", margin(small)) title("Angola", margin(small)) xlab(1991(5)2016) name(AGO, replace)
				graph export "output/figureA1_AGO.pdf", replace

		twoway line itotal_compound year if country=="Burundi", ///
			ytitle("# of uniformed personnel", margin(small)) xtitle("Year", margin(small)) title("Burundi", margin(small)) xlab(1991(5)2016) name(BDI, replace)
				graph export "output/figureA1_BDI.pdf", replace
		
		twoway line itotal_compound year if country=="Central African Republic", ///
			ytitle("# of uniformed personnel", margin(small)) xtitle("Year", margin(small)) title("Central African Republic", margin(small)) xlab(1991(5)2016) name(CAF, replace)
				graph export "output/figureA1_CAF.pdf", replace
		
		twoway line itotal_compound year if country=="Chad", ///
			ytitle("# of uniformed personnel", margin(small)) xtitle("Year", margin(small)) title("Chad", margin(small)) xlab(1991(5)2016) name(TCD, replace)
				graph export "output/figureA1_TCD.pdf", replace
		
		twoway line itotal_compound year if country=="Cote d'Ivoire", ///
			ytitle("# of uniformed personnel", margin(small)) xtitle("Year", margin(small)) title("Cote d'Ivoire", margin(small)) xlab(1991(5)2016) name(CIV, replace)
				graph export "output/figureA1_CIV.pdf", replace
		
		twoway line itotal_compound year if country=="Democratic Republic of the Congo", ///
			ytitle("# of uniformed personnel", margin(small)) xtitle("Year", margin(small)) title("Democratic Republic of the Congo", margin(small)) xlab(1991(5)2016) name(COD, replace)
				graph export "output/figureA1_COD.pdf", replace
		
		twoway line itotal_compound year if country=="Eritrea", ///
			ytitle("# of uniformed personnel", margin(small)) xtitle("Year", margin(small)) title("Eritrea", margin(small)) xlab(1991(5)2016) name(ERI, replace)
				graph export "output/figureA1_ERI.pdf", replace
		
		twoway line itotal_compound year if country=="Liberia", ///
			ytitle("# of uniformed personnel", margin(small)) xtitle("Year", margin(small)) title("Liberia", margin(small)) xlab(1991(5)2016) name(LBR, replace)
				graph export "output/figureA1_LBR.pdf", replace
		
		twoway line itotal_compound year if country=="Mali", ///
			ytitle("# of uniformed personnel", margin(small)) xtitle("Year", margin(small)) title("Mali", margin(small)) xlab(1991(5)2016) name(MLI, replace)
				graph export "output/figureA1_MLI.pdf", replace
		
		twoway line itotal_compound year if country=="Mozambique", ///
			ytitle("# of uniformed personnel", margin(small)) xtitle("Year", margin(small)) title("Mozambique", margin(small)) xlab(1991(5)2016) name(MOZ, replace)
				graph export "output/figureA1_MOZ.pdf", replace
		
		twoway line itotal_compound year if country=="Rwanda", ///
			ytitle("# of uniformed personnel", margin(small)) xtitle("Year", margin(small)) title("Rwanda", margin(small)) xlab(1991(5)2016) name(RWA, replace)
				graph export "output/figureA1_RWA.pdf", replace
		
		twoway line itotal_compound year if country=="Sierra Leone", ///
			ytitle("# of uniformed personnel", margin(small)) xtitle("Year", margin(small)) title("Sierra Leone", margin(small)) xlab(1991(5)2016) name(SLE, replace)
				graph export "output/figureA1_SLE.pdf", replace
		
		twoway line itotal_compound year if country=="Somalia", ///
			ytitle("# of uniformed personnel", margin(small)) xtitle("Year", margin(small)) title("Somalia", margin(small)) xlab(1991(5)2016) name(SOM, replace)
				graph export "output/figureA1_SOM.pdf", replace
		
		twoway line itotal_compound year if country=="South Sudan", ///
			ytitle("# of uniformed personnel", margin(small)) xtitle("Year", margin(small)) title("South Sudan", margin(small)) xlab(1991(5)2016) name(SSD, replace)
				graph export "output/figureA1_SSD.pdf", replace
		
		twoway line itotal_compound year if country=="Sudan", ///
			ytitle("# of uniformed personnel", margin(small)) xtitle("Year", margin(small)) title("Sudan", margin(small)) xlab(1991(5)2016) name(SDN, replace)
				graph export "output/figureA1_SDN.pdf", replace
	
		restore
		
		
		
		
	* Replicate Figure A2
		
		preserve
		
		drop if year<1993
		drop if year>2016
		
		set scheme plotplainblind

		twoway line iactual_civilian_total year if country=="Burundi", ///
			ytitle("# of civilian personnel", margin(small)) xtitle("Year", margin(small)) title("Burundi", margin(small)) xlab(1993(5)2016) name(BDI, replace)
				graph export "output/figureA2_BDI.pdf", replace
		
		twoway line iactual_civilian_total year if country=="Central African Republic", ///
			ytitle("# of civilian personnel", margin(small)) xtitle("Year", margin(small)) title("Central African Republic", margin(small)) xlab(1993(5)2016) name(CAF, replace)
				graph export "output/figureA2_CAF.pdf", replace
		
		twoway line iactual_civilian_total year if country=="Cote d'Ivoire", ///
			ytitle("# of civilian personnel", margin(small)) xtitle("Year", margin(small)) title("Cote d'Ivoire", margin(small)) xlab(1993(5)2016) name(CIV, replace)
				graph export "output/figureA2_CIV.pdf", replace
		
		twoway line iactual_civilian_total year if country=="Democratic Republic of the Congo", ///
			ytitle("# of civilian personnel", margin(small)) xtitle("Year", margin(small)) title("Democratic Republic of the Congo", margin(small)) xlab(1993(5)2016) name(COD, replace)
				graph export "output/figureA2_COD.pdf", replace
		
		twoway line iactual_civilian_total year if country=="Liberia", ///
			ytitle("# of civilian personnel", margin(small)) xtitle("Year", margin(small)) title("Liberia", margin(small)) xlab(1993(5)2016) name(LBR, replace)
				graph export "output/figureA2_LBR.pdf", replace
		
		twoway line iactual_civilian_total year if country=="Mali", ///
			ytitle("# of civilian personnel", margin(small)) xtitle("Year", margin(small)) title("Mali", margin(small)) xlab(1993(5)2016) name(MLI, replace)
				graph export "output/figureA2_MLI.pdf", replace

		twoway line iactual_civilian_total year if country=="Sierra Leone", ///
			ytitle("# of civilian personnel", margin(small)) xtitle("Year", margin(small)) title("Sierra Leone", margin(small)) xlab(1993(5)2016) name(SLE, replace)
				graph export "output/figureA2_SLE.pdf", replace
		
		twoway line iactual_civilian_total year if country=="South Sudan", ///
			ytitle("# of civilian personnel", margin(small)) xtitle("Year", margin(small)) title("South Sudan", margin(small)) xlab(1993(5)2016) name(SSD, replace)
				graph export "output/figureA2_SSD.pdf", replace
		
		twoway line iactual_civilian_total year if country=="Sudan", ///
			ytitle("# of civilian personnel", margin(small)) xtitle("Year", margin(small)) title("Sudan", margin(small)) xlab(1993(5)2016) name(SDN, replace)
				graph export "output/figureA2_SDN.pdf", replace
	
		restore		
		

		

	
	* Replicate Figure A3

		set scheme plotplainblind
		
		preserve
		drop if year>2016
		collapse (sum) iany_demo_engage_max_dum iany_demo_bypass_max_dum, by(year)
		twoway line iany_demo_engage_max_dum year, lpattern("solid") ///
				|| line iany_demo_bypass_max_dum year, lpattern("solid") ytitle("# of countries with any democracy activities") xtitle("Year") ///
				legend(title("Democracy activities that...") label(1 "engage the host government") label(2 "bypass the host government")) ///
				xlab(1991(5)2016)
		graph export "output/figureA3_top.pdf", replace
		restore
		
		set scheme plotplainblind

		preserve
		drop if year>2016
		replace year = 1 if year<1995
		replace year = 2 if year>=1995 & year<2000
		replace year = 3 if year>=2000 & year<2005
		replace year = 4 if year>=2005 & year<2010
		replace year = 5 if year>=2010
		tab year
		collapse (sum) idemo_all_max_dum ielections_all_max_dum iparties_all_max_dum ivoters_all_max_dum, by(year)
		gen year1 = year-0.2
		gen year2 = year
		gen year3 = year+0.2
		gen year4 = year+0.4
		twoway bar ivoters_all_max_dum year1, barw(0.18) ///
				|| bar iparties_all_max_dum year2, barw(0.18) ///
				|| bar idemo_all_max_dum year3, barw(0.18) ///
				|| bar ielections_all_max_dum year4, barw(0.18) ytitle("# of countries with democracy activities") xtitle("Years") ///
													xlabel(1 "1991-94" 2 "1995-99" 3 "2000-05" 4 "2006-10" 5 "2011-16") ///
													legend(label(1 "Voter education") label(2 "Political party assistance") label(3 "Democratic institution assistance") label(4 "Election assistance"))
		graph export "output/figureA3_bottom.pdf", replace
		restore
			
		
		
		
	* Replicate Figure A4
		
		preserve
		
		keep if year<=2016

		local country_name "Angola"
		
		tab year if ipema_any_demo_assist_dum==1 & country=="`country_name'"
		
		gr tw ///
			(scatteri 0 `=1992' 0 `=1994' .7 `=1994' .7 `=1992', bcolor(gs14) recast(area)) ///
			(tsline v2x_polyarchy if country=="`country_name'", lc(black) lpattern(solid)), ///
				yscale(range(0(.1).7)) ylab(0(.1).7, nogrid) ytitle("Electoral democracy (V-Dem)", margin(small)) ///
				xlab(1991(4)2016) xtitle("`country_name'", margin(small)) ///
				legend(off) graphr(color(white))
					graph export "output/figureA4_`country_name'.pdf", as(pdf) replace


					
		local country_name "Burundi"
		
		tab year if ipema_any_demo_assist_dum==1 & country=="`country_name'"
		
		gr tw ///
			(scatteri 0 `=2004' 0 `=2006' .7 `=2006' .7 `=2004', bcolor(gs14) recast(area)) ///
			(tsline v2x_polyarchy if country=="`country_name'", lc(black) lpattern(solid)), ///
				yscale(range(0(.1).7)) ylab(0(.1).7, nogrid) ytitle("Electoral democracy (V-Dem)", margin(small)) ///
				xlab(1991(4)2016) xtitle("`country_name'", margin(small)) ///
				legend(off) graphr(color(white))
					graph export "output/figureA4_`country_name'.pdf", as(pdf) replace

					
				
		local country_name "Central African Republic"
		
		tab year if ipema_any_demo_assist_dum==1 & country=="`country_name'"
		
		gr tw ///
			(scatteri 0 `=1998' 0 `=1999' .7 `=1999' .7 `=1998', bcolor(gs14) recast(area)) ///
			(scatteri 0 `=2014' 0 `=2016' .7 `=2016' .7 `=2014', bcolor(gs14) recast(area)) ///
			(tsline v2x_polyarchy if country=="`country_name'", lc(black) lpattern(solid)), ///
				yscale(range(0(.1).7)) ylab(0(.1).7, nogrid) ytitle("Electoral democracy (V-Dem)", margin(small)) ///
				xlab(1991(4)2016) xtitle("`country_name'", margin(small)) ///
				legend(off) graphr(color(white))
					graph export "output/figureA4_CAR.pdf", as(pdf) replace

					
		local country_name "Cote d'Ivoire"
		
		tab year if ipema_any_demo_assist_dum==1 & country=="`country_name'"
		
		gr tw ///
			(scatteri 0 `=2004' 0 `=2015' .7 `=2015' .7 `=2004', bcolor(gs14) recast(area)) ///
			(tsline v2x_polyarchy if country=="`country_name'", lc(black) lpattern(solid)), ///
				yscale(range(0(.1).7)) ylab(0(.1).7, nogrid) ytitle("Electoral democracy (V-Dem)", margin(small)) ///
				xlab(1991(4)2016) xtitle("`country_name'", margin(small)) ///
				legend(off) graphr(color(white))
					graph export "output/figureA4_CDI.pdf", as(pdf) replace

	
	
		local country_name "Democratic Republic of the Congo"
		
		tab year if ipema_any_demo_assist_dum==1 & country=="`country_name'"
		
		gr tw ///
			(scatteri 0 `=2004' 0 `=2016' .7 `=2016' .7 `=2004', bcolor(gs14) recast(area)) ///
			(tsline v2x_polyarchy if country=="`country_name'", lc(black) lpattern(solid)), ///
				yscale(range(0(.1).7)) ylab(0(.1).7, nogrid) ytitle("Electoral democracy (V-Dem)", margin(small)) ///
				xlab(1991(4)2016) xtitle("`country_name'", margin(small)) ///
				legend(off) graphr(color(white))
					graph export "output/figureA4_DRC.pdf", as(pdf) replace

	
					
		local country_name "Liberia"
		
		tab year if ipema_any_demo_assist_dum==1 & country=="`country_name'"
		
		gr tw ///
			(scatteri 0 `=2003' 0 `=2016' .7 `=2016' .7 `=2003', bcolor(gs14) recast(area)) ///
			(tsline v2x_polyarchy if country=="`country_name'", lc(black) lpattern(solid)), ///
				yscale(range(0(.1).7)) ylab(0(.1).7, nogrid) ytitle("Electoral democracy (V-Dem)", margin(small)) ///
				xlab(1991(4)2016) xtitle("`country_name'", margin(small)) ///
				legend(off) graphr(color(white))
					graph export "output/figureA4_`country_name'.pdf", as(pdf) replace

					
					
		local country_name "Mali"
		
		tab year if ipema_any_demo_assist_dum==1 & country=="`country_name'"
		
		gr tw ///
			(scatteri 0 `=2013' 0 `=2016' .7 `=2016' .7 `=2013', bcolor(gs14) recast(area)) ///
			(tsline v2x_polyarchy if country=="`country_name'", lc(black) lpattern(solid)), ///
				yscale(range(0(.1).7)) ylab(0(.1).7, nogrid) ytitle("Electoral democracy (V-Dem)", margin(small)) ///
				xlab(1991(4)2016) xtitle("`country_name'", margin(small)) ///
				legend(off) graphr(color(white))
					graph export "output/figureA4_`country_name'.pdf", as(pdf) replace

					
					
		local country_name "Mozambique"
		
		tab year if ipema_any_demo_assist_dum==1 & country=="`country_name'"
		
		gr tw ///
			(scatteri 0 `=1992' 0 `=1994' .7 `=1994' .7 `=1992', bcolor(gs14) recast(area)) ///
			(tsline v2x_polyarchy if country=="`country_name'", lc(black) lpattern(solid)), ///
				yscale(range(0(.1).7)) ylab(0(.1).7, nogrid) ytitle("Electoral democracy (V-Dem)", margin(small)) ///
				xlab(1991(4)2016) xtitle("`country_name'", margin(small)) ///
				legend(off) graphr(color(white))
					graph export "output/figureA4_`country_name'.pdf", as(pdf) replace

	
			
		
		local country_name "Rwanda"
				
		gr tw ///
			(tsline v2x_polyarchy if country=="`country_name'", lc(black) lpattern(solid)), ///
				yscale(range(0(.1).7)) ylab(0(.1).7, nogrid) ytitle("Electoral democracy (V-Dem)", margin(small)) ///
				xlab(1991(4)2016) xtitle("`country_name'", margin(small)) ///
				legend(off) graphr(color(white))
					graph export "output/figureA4_`country_name'.pdf", as(pdf) replace
		
		
		
		
		local country_name "Sierra Leone"
		
		tab year if ipema_any_demo_assist_dum==1 & country=="`country_name'"
		
		gr tw ///
			(scatteri 0 `=1999' 0 `=2005' .7 `=2005' .7 `=1999', bcolor(gs14) recast(area)) ///
			(tsline v2x_polyarchy if country=="`country_name'", lc(black) lpattern(solid)), ///
				yscale(range(0(.1).7)) ylab(0(.1).7, nogrid) ytitle("Electoral democracy (V-Dem)", margin(small)) ///
				xlab(1991(4)2016) xtitle("`country_name'", margin(small)) ///
				legend(off) graphr(color(white))
					graph export "output/figureA4_Sierra_Leone.pdf", as(pdf) replace
			

			
	
		local country_name "Somalia"
				
		gr tw ///
			(tsline v2x_polyarchy if country=="`country_name'", lc(black) lpattern(solid)), ///
				yscale(range(0(.1).7)) ylab(0(.1).7, nogrid) ytitle("Electoral democracy (V-Dem)", margin(small)) ///
				xlab(1991(4)2016) xtitle("`country_name'", margin(small)) ///
				legend(off) graphr(color(white))
					graph export "output/figureA4_`country_name'.pdf", as(pdf) replace
		
		
	
		local country_name "South Sudan"
		
		tab year if ipema_any_demo_assist_dum==1 & country=="`country_name'"
		
		gr tw ///
			(scatteri 0 `=2011' 0 `=2013' .7 `=2013' .7 `=2011', bcolor(gs14) recast(area)) ///
			(tsline v2x_polyarchy if country=="`country_name'", lc(black) lpattern(solid)), ///
				yscale(range(0(.1).7)) ylab(0(.1).7, nogrid) ytitle("Electoral democracy (V-Dem)", margin(small)) ///
				xlab(1991(4)2016) xtitle("`country_name'", margin(small)) ///
				legend(off) graphr(color(white))
					graph export "output/figureA4_South_Sudan.pdf", as(pdf) replace
	

	
		local country_name "Sudan"
		
		tab year if ipema_any_demo_assist_dum==1 & country=="`country_name'"
		
		gr tw ///
			(scatteri 0 `=2005' 0 `=2011' .7 `=2011' .7 `=2005', bcolor(gs14) recast(area)) ///
			(tsline v2x_polyarchy if country=="`country_name'", lc(black) lpattern(solid)), ///
				yscale(range(0(.1).7)) ylab(0(.1).7, nogrid) ytitle("Electoral democracy (V-Dem)", margin(small)) ///
				xlab(1991(4)2016) xtitle("`country_name'", margin(small)) ///
				legend(off) graphr(color(white))
					graph export "output/figureA4_`country_name'.pdf", as(pdf) replace
		
		restore
		
			
		
		

					
	* Replicate Figure A5
		
		preserve
		
		keep if year<=2016

		local country_name "Angola"
		
		tab year if iany_demo_all_max_dum==1 & country=="`country_name'"
		
		gr tw ///
			(scatteri 0 `=1992' 0 `=1992.5' .7 `=1992.5' .7 `=1992', bcolor(gs14) recast(area)) ///
			(scatteri 0 `=1997' 0 `=1998' .7 `=1998' .7 `=1997', bcolor(gs14) recast(area)) ///
			(tsline v2x_polyarchy if country=="`country_name'", lc(black) lpattern(solid)), ///
				yscale(range(0(.1).7)) ylab(0(.1).7, nogrid) ytitle("Electoral democracy (V-Dem)", margin(small)) ///
				xlab(1991(4)2016) xtitle("`country_name'", margin(small)) ///
				legend(off) graphr(color(white))
					graph export "output/figureA5_`country_name'.pdf", as(pdf) replace


					
		local country_name "Burundi"
		
		tab year if iany_demo_all_max_dum==1 & country=="`country_name'"
		
		gr tw ///
			(scatteri 0 `=2004' 0 `=2005' .7 `=2005' .7 `=2004', bcolor(gs14) recast(area)) ///
			(tsline v2x_polyarchy if country=="`country_name'", lc(black) lpattern(solid)), ///
				yscale(range(0(.1).7)) ylab(0(.1).7, nogrid) ytitle("Electoral democracy (V-Dem)", margin(small)) ///
				xlab(1991(4)2016) xtitle("`country_name'", margin(small)) ///
				legend(off) graphr(color(white))
					graph export "output/figureA5_`country_name'.pdf", as(pdf) replace

					
				
		local country_name "Central African Republic"
		
		tab year if iany_demo_all_max_dum==1 & country=="`country_name'"
		
		gr tw ///
			(scatteri 0 `=1998' 0 `=2000' .7 `=2000' .7 `=1998', bcolor(gs14) recast(area)) ///
			(scatteri 0 `=2014' 0 `=2016' .7 `=2016' .7 `=2014', bcolor(gs14) recast(area)) ///
			(tsline v2x_polyarchy if country=="`country_name'", lc(black) lpattern(solid)), ///
				yscale(range(0(.1).7)) ylab(0(.1).7, nogrid) ytitle("Electoral democracy (V-Dem)", margin(small)) ///
				xlab(1991(4)2016) xtitle("`country_name'", margin(small)) ///
				legend(off) graphr(color(white))
					graph export "output/figureA5_CAR.pdf", as(pdf) replace

					
		local country_name "Cote d'Ivoire"
		
		tab year if iany_demo_all_max_dum==1 & country=="`country_name'"
		
		gr tw ///
			(scatteri 0 `=2004' 0 `=2013' .7 `=2013' .7 `=2004', bcolor(gs14) recast(area)) ///
			(scatteri 0 `=2015' 0 `=2016' .7 `=2016' .7 `=2015', bcolor(gs14) recast(area)) ///
			(tsline v2x_polyarchy if country=="`country_name'", lc(black) lpattern(solid)), ///
				yscale(range(0(.1).7)) ylab(0(.1).7, nogrid) ytitle("Electoral democracy (V-Dem)", margin(small)) ///
				xlab(1991(4)2016) xtitle("`country_name'", margin(small)) ///
				legend(off) graphr(color(white))
					graph export "output/figureA5_CDI.pdf", as(pdf) replace

	
	
		local country_name "Democratic Republic of the Congo"
		
		tab year if iany_demo_all_max_dum==1 & country=="`country_name'"
		
		gr tw ///
			(scatteri 0 `=2002' 0 `=2016' .7 `=2016' .7 `=2002', bcolor(gs14) recast(area)) ///
			(tsline v2x_polyarchy if country=="`country_name'", lc(black) lpattern(solid)), ///
				yscale(range(0(.1).7)) ylab(0(.1).7, nogrid) ytitle("Electoral democracy (V-Dem)", margin(small)) ///
				xlab(1991(4)2016) xtitle("`country_name'", margin(small)) ///
				legend(off) graphr(color(white))
					graph export "output/figureA5_DRC.pdf", as(pdf) replace

	
					
		local country_name "Liberia"
		
		tab year if iany_demo_all_max_dum==1 & country=="`country_name'"
		
		gr tw ///
			(scatteri 0 `=2003' 0 `=2012' .7 `=2012' .7 `=2003', bcolor(gs14) recast(area)) ///
			(scatteri 0 `=2014' 0 `=2016' .7 `=2016' .7 `=2014', bcolor(gs14) recast(area)) ///
			(tsline v2x_polyarchy if country=="`country_name'", lc(black) lpattern(solid)), ///
				yscale(range(0(.1).7)) ylab(0(.1).7, nogrid) ytitle("Electoral democracy (V-Dem)", margin(small)) ///
				xlab(1991(4)2016) xtitle("`country_name'", margin(small)) ///
				legend(off) graphr(color(white))
					graph export "output/figureA5_`country_name'.pdf", as(pdf) replace

					
					
		local country_name "Mali"
		
		tab year if iany_demo_all_max_dum==1 & country=="`country_name'"
		
		gr tw ///
			(scatteri 0 `=2013' 0 `=2016' .7 `=2016' .7 `=2013', bcolor(gs14) recast(area)) ///
			(tsline v2x_polyarchy if country=="`country_name'", lc(black) lpattern(solid)), ///
				yscale(range(0(.1).7)) ylab(0(.1).7, nogrid) ytitle("Electoral democracy (V-Dem)", margin(small)) ///
				xlab(1991(4)2016) xtitle("`country_name'", margin(small)) ///
				legend(off) graphr(color(white))
					graph export "output/figureA5_`country_name'.pdf", as(pdf) replace

					
					
		local country_name "Mozambique"
		
		tab year if iany_demo_all_max_dum==1 & country=="`country_name'"
		
		gr tw ///
			(scatteri 0 `=1993' 0 `=1994' .7 `=1994' .7 `=1993', bcolor(gs14) recast(area)) ///
			(tsline v2x_polyarchy if country=="`country_name'", lc(black) lpattern(solid)), ///
				yscale(range(0(.1).7)) ylab(0(.1).7, nogrid) ytitle("Electoral democracy (V-Dem)", margin(small)) ///
				xlab(1991(4)2016) xtitle("`country_name'", margin(small)) ///
				legend(off) graphr(color(white))
					graph export "output/figureA5_`country_name'.pdf", as(pdf) replace

	

		local country_name "Rwanda"
		
		tab year if iany_demo_all_max_dum==1 & country=="`country_name'"
		
		gr tw ///
			(scatteri 0 `=1994' 0 `=1994.5' .7 `=1994.5' .7 `=1994', bcolor(gs14) recast(area)) ///
			(tsline v2x_polyarchy if country=="`country_name'", lc(black) lpattern(solid)), ///
				yscale(range(0(.1).7)) ylab(0(.1).7, nogrid) ytitle("Electoral democracy (V-Dem)", margin(small)) ///
				xlab(1991(4)2016) xtitle("`country_name'", margin(small)) ///
				legend(off) graphr(color(white))
					graph export "output/figureA5_`country_name'.pdf", as(pdf) replace

	
	
	
		local country_name "Sierra Leone"
		
		tab year if iany_demo_all_max_dum==1 & country=="`country_name'"
		
		gr tw ///
			(scatteri 0 `=2001' 0 `=2002' .7 `=2002' .7 `=2001', bcolor(gs14) recast(area)) ///
			(scatteri 0 `=2004' 0 `=2005' .7 `=2005' .7 `=2004', bcolor(gs14) recast(area)) ///
			(tsline v2x_polyarchy if country=="`country_name'", lc(black) lpattern(solid)), ///
				yscale(range(0(.1).7)) ylab(0(.1).7, nogrid) ytitle("Electoral democracy (V-Dem)", margin(small)) ///
				xlab(1991(4)2016) xtitle("`country_name'", margin(small)) ///
				legend(off) graphr(color(white))
					graph export "output/figureA5_Sierra_Leone.pdf", as(pdf) replace
			

			
	
		local country_name "Somalia"
		
		tab year if iany_demo_all_max_dum==1 & country=="`country_name'"
		
		gr tw ///
			(scatteri 0 `=1993' 0 `=1993.5' .7 `=1993.5' .7 `=1993', bcolor(gs14) recast(area)) ///
			(tsline v2x_polyarchy if country=="`country_name'", lc(black) lpattern(solid)), ///
				yscale(range(0(.1).7)) ylab(0(.1).7, nogrid) ytitle("Electoral democracy (V-Dem)", margin(small)) ///
				xlab(1991(4)2016) xtitle("`country_name'", margin(small)) ///
				legend(off) graphr(color(white))
					graph export "output/figureA5_`country_name'.pdf", as(pdf) replace
	
			
			
	
		local country_name "South Sudan"
		
		tab year if iany_demo_all_max_dum==1 & country=="`country_name'"
		
		gr tw ///
			(scatteri 0 `=2011' 0 `=2014' .7 `=2014' .7 `=2011', bcolor(gs14) recast(area)) ///
			(scatteri 0 `=2015.5' 0 `=2016' .7 `=2016' .7 `=2015.5', bcolor(gs14) recast(area)) ///
			(tsline v2x_polyarchy if country=="`country_name'", lc(black) lpattern(solid)), ///
				yscale(range(0(.1).7)) ylab(0(.1).7, nogrid) ytitle("Electoral democracy (V-Dem)", margin(small)) ///
				xlab(1991(4)2016) xtitle("`country_name'", margin(small)) ///
				legend(off) graphr(color(white))
					graph export "output/figureA5_South_Sudan.pdf", as(pdf) replace
	

	
		local country_name "Sudan"
		
		tab year if iany_demo_all_max_dum==1 & country=="`country_name'"
		
		gr tw ///
			(scatteri 0 `=2006' 0 `=2011' .7 `=2011' .7 `=2006', bcolor(gs14) recast(area)) ///
			(tsline v2x_polyarchy if country=="`country_name'", lc(black) lpattern(solid)), ///
				yscale(range(0(.1).7)) ylab(0(.1).7, nogrid) ytitle("Electoral democracy (V-Dem)", margin(small)) ///
				xlab(1991(4)2016) xtitle("`country_name'", margin(small)) ///
				legend(off) graphr(color(white))
					graph export "output/figureA5_`country_name'.pdf", as(pdf) replace
		
		restore
		
		
		

	* Replicate Table A4

		indvar_separate_ctrls v2x_polyarchy, indvar(ipema_any_demo_rel_assist_dum_2l) title(tableA4)
		
		
		
		
	* Replicate Table A5

		indvar_separate_ctrls v2x_polyarchy, indvar(iany_demo_rel_all_max_dum_2l) title(tableA5)
		
		
		
		
	* Replicate Table A6

		indvar_separate_ctrls v2x_polyarchy, indvar(ipema_any_demo_agg_2l) title(tableA6)
		

		
		
	* Replicate Table A7		
		
		indvar_separate_ctrls v2x_polyarchy, indvar(ipema_any_demo_diff_2l) title(tableA7)
	
		
		
		
	* Replicate Table A8
		
		
		indvar_separate_ctrls v2x_polyarchy, indvar(iall_demo_max_2l) title(tableA8)
		
	
	
	* Replicate Table A9
		
		indvar_together_ctrls v2x_polyarchy, indvar(iall_demo_engage_max_2l iall_demo_bypass_max_2l) title(tableA9)
		
		
		
			
	* Replicate Table A10
	
		indvar_separate_ctrls v2x_polyarchy, indvar(itotal_compound_K_2l_civ) title(tableA10)		
		
		
		
	* Replicate Table A11
		
		indvar_separate_ctrls polity2, indvar(ipema_any_demo_assist_dum_2l) title(tableA11)
		
		
		
	* Replicate Table A12

		indvar_separate_ctrls polity2, indvar(itotal_compound_K_2l) title(tableA12)
		
		
		
	* Replicate Table A13

		indvar_separate_ctrls polity2, indvar(iactual_civilian_total_K_2l) title(tableA13)
				
				
		
	* Replicate Table A14

		indvar_separate_ctrls polity2, indvar(iany_demo_all_max_dum_2l) title(tableA14)
			
		
		
	* Replicate Table A15
		
		indvar_separate_ctrls democracy, indvar(ipema_any_demo_assist_dum_2l) title(tableA15)
		
		
		
	* Replicate Table A16

		indvar_separate_ctrls democracy, indvar(itotal_compound_K_2l) title(tableA16)
		
		
		
	* Replicate Table A17

		indvar_separate_ctrls democracy, indvar(iactual_civilian_total_K_2l) title(tableA17)
				
				
		
	* Replicate Table A18

		indvar_separate_ctrls democracy, indvar(iany_demo_all_max_dum_2l) title(tableA18)
			
		

	* Replicate Table A19
		
		indvar_separate_ctrls fh_pr_rec, indvar(ipema_any_demo_assist_dum_2l) title(tableA19)
		
		
		
		
	* Replicate Table A20

		indvar_separate_ctrls fh_pr_rec, indvar(itotal_compound_K_2l) title(tableA20)
		
		
		
		
	* Replicate Table A21

		indvar_separate_ctrls fh_pr_rec, indvar(iactual_civilian_total_K_2l) title(tableA21)
				
				
				
		
	* Replicate Table A22

		indvar_separate_ctrls fh_pr_rec, indvar(iany_demo_all_max_dum_2l) title(tableA22)
			

		
	* Replicate Table A23
		
		indvar_separate_re_ctrls v2x_polyarchy, indvar(ipema_any_demo_assist_dum_2l) title(tableA23)
	
	
	
	* Replicate Table A24
		
		indvar_separate_re_ctrls v2x_polyarchy, indvar(itotal_compound_K_2l) title(tableA24)

		
		
		
	* Replicate Table A25
		
		indvar_separate_re_ctrls v2x_polyarchy, indvar(iactual_civilian_total_K_2l) title(tableA25)
		
		
		
	* Replicate Table A26
		
		indvar_separate_re_ctrls v2x_polyarchy, indvar(iany_demo_all_max_dum_2l) title(tableA26)
		

		
	* Replicate Table A27
		
		indvar_separate_laggedDV_ctrls v2x_polyarchy, indvar(ipema_any_demo_assist_dum_2l) title(tableA27)

		
		
		
	* Replicate Table A28

		indvar_separate_laggedDV_ctrls v2x_polyarchy, indvar(itotal_compound_K_2l) title(tableA28)
		
		
		
	* Replicate Table A29

		indvar_separate_laggedDV_ctrls v2x_polyarchy, indvar(iactual_civilian_total_K_2l) title(tableA29)
		
		
		
	* Replicate Table A30

		indvar_separate_laggedDV_ctrls v2x_polyarchy, indvar(iany_demo_all_max_dum_2l) title(tableA30)

			
	* Replicate Table A31
		
		indvar_together_laggedDV_ctrls v2x_polyarchy, indvar(iany_demo_engage_max_dum_2l iany_demo_bypass_max_dum_2l) title(tableA31)		
		
		
		
	* Replicate Table A32		
		
		indvar_together_laggedDV_ctrls v2x_polyarchy, indvar(idemo_all_max_dum_2l ielections_all_max_dum_2l iparties_all_max_dum_2l ivoters_all_max_dum_2l) title(tableA32) 
		
		
		
		
	* Replicate Table A33
	
		indvar_separate_laggedDV_nofe v2x_polyarchy, indvar(ipema_any_demo_assist_dum_2l) title(tableA33)
		
		
		
	* Replicate Table A34
	
		indvar_separate_laggedDV_nofe v2x_polyarchy, indvar(itotal_compound_K_2l) title(tableA34)
		
		
		
	* Replicate Table A35
		
		indvar_separate_laggedDV_nofe v2x_polyarchy, indvar(iactual_civilian_total_K_2l) title(tableA35)
		
		
		
	* Replicate Table A36

		indvar_separate_laggedDV_nofe v2x_polyarchy, indvar(iany_demo_all_max_dum_2l) title(tableA36)	
		
		
		
	* Replicate Table A37
		
		indvar_separate_laggedDV_nofe v2x_polyarchy, indvar(iany_demo_engage_max_dum_2l iany_demo_bypass_max_dum_2l) title(tableA37)
		
		
		
	* Replicate Table A38
		
		indvar_separate_laggedDV_nofe v2x_polyarchy, indvar(idemo_all_max_dum_2l ielections_all_max_dum_2l iparties_all_max_dum_2l ivoters_all_max_dum_2l) title(tableA38) 
	
	
	
	* Replicate Table A39

		iv_ctrls v2x_polyarchy, indvar(ipema_any_demo_assist_dum_2l) iv(ipema_any_demo_assdiv_2l) title(tableA39)
	
		

	* Replicate Table A40

		iv_ctrls v2x_polyarchy, indvar(iany_demo_all_max_dum_2l) iv(iany_demo_all_maxdiv_2l) title(tableA40)

		
		
	* Replicate Table A41
		
		indvar_together_ctrls v2x_polyarchy, indvar(ipema_any_demo_assist_dum_2l iany_demo_all_max_dum_2l itotal_compound_K_2l iactual_civilian_total_K_2l) title(tableA41)			
		
		
	* Replicate Table A42
		
		indvar_together_ctrls v2x_polyarchy, indvar(ipema_any_demo_assist_dum_2l itotal_compound_K_2l) title(tableA42)			
		
										

	* Replicate Table A43
	
		indvar_together_ctrls v2x_polyarchy, indvar(ipema_any_demo_assist_dum_2l iactual_civilian_total_K_2l) title(tableA43)
		
		
		
	* Replicate Table A44

		indvar_together_ctrls v2x_polyarchy, indvar(ipema_any_demo_assist_dum_2l iany_demo_all_max_dum_2l) title(tableA44)
		

		
	* Replicate Table A45
		
		indvar_together_ctrls v2x_polyarchy, indvar(itotal_compound_K_2l iactual_civilian_total_K_2l) title(tableA45)

		
		
	* Replicate Table A46
		
		indvar_together_ctrls v2x_polyarchy, indvar(itotal_compound_K_2l iany_demo_all_max_dum_2l) title(tableA46)
		
		
		
	* Replicate Table A47
		
		indvar_together_ctrls v2x_polyarchy, indvar(iany_demo_all_max_dum_2l iactual_civilian_total_K_2l) title(tableA47)
		
		
	

	* Replicate Table A48
		
		indvar_together_ctrls v2x_polyarchy, indvar(ipema_any_demo_assist_dum_2l itotal_compound_K_2l ipema_itotal_compound_K) title(tableA48)
		
		
		
		
	* Replicate Table A49
		
		indvar_together_ctrls v2x_polyarchy, indvar(ipema_any_demo_assist_dum_2l iactual_civilian_total_K_2l ipema_iactual_civilian_total_K) title(tableA49)	

		
			
		
	* Replicate Table A50
		
		indvar_together_ctrls v2x_polyarchy, indvar(ipema_any_demo_assist_dum_2l iany_demo_all_max_dum_2l ipema_iany_demo_all_max_dum) title(tableA50)

		
		
	* Replicate Table A51

		indvar_together_ctrls v2x_polyarchy, indvar(itotal_compound_K_2l iactual_civilian_total_K_2l itotal_iactual_civilian_total_K) title(tableA51)
		
		
		
	* Replicate Table A52

		indvar_together_ctrls v2x_polyarchy, indvar(itotal_compound_K_2l iany_demo_all_max_dum_2l itotal_iany_demo_all_max_dum) title(tableA52)
		
		
		
	* Replicate Table A53

		indvar_together_ctrls v2x_polyarchy, indvar(iany_demo_all_max_dum_2l iactual_civilian_total_K_2l iany_iactual_civilian_total_K) title(tableA53)
			
		
		
		
	* Replicate Figure A6

		set scheme plotplainblind
		
		xtreg v2x_polyarchy i.ipema_any_demo_assist_dum_2l##c.iactual_civilian_total_K_2l $ictrls_3l_varying, fe
			margins, dydx(ipema_any_demo_assist_dum_2l) at( iactual_civilian_total_K_2l = (0 (1) 8) )
				marginsplot, recast(line) recastci(rline) ciopts(lpattern("dash")) ///
				ytitle("Marginal effect of democracy mandates", margin(small)) ///
				xtitle("# of civilian personnel", margin(small)) ///
				title("")
				graph export "output/figureA6_top.pdf", replace

		xtreg v2x_polyarchy i.ipema_any_demo_assist_dum_2l##c.iactual_civilian_total_K_2l $ictrls_3l_varying, fe
			margins, dydx(iactual_civilian_total_K_2l) at(ipema_any_demo_assist_dum_2l = ( 0 1))
				marginsplot, recast(line) recastci(rline) ciopts(lpattern("dash")) ///
				ytitle("Marginal effect of civilian personnel", margin(small)) ///
				xtitle("Democracy mandates", margin(small)) ///
				title("")
				graph export "output/figureA6_bottom.pdf", replace

		
		
	* Replicate Figure A7

		set scheme plotplainblind
		
		xtreg v2x_polyarchy i.ipema_any_demo_assist_dum_2l##c.iactual_civilian_total_K_2l $ictrls_3l_varying if ucdp_0yrs==1, fe
			margins, dydx(ipema_any_demo_assist_dum_2l) at( iactual_civilian_total_K_2l = (0 (1) 8) )
				marginsplot, recast(line) recastci(rline) ciopts(lpattern("dash")) ///
				ytitle("Marginal effect of democracy mandates" "(during conflict)", margin(small)) ///
				xtitle("# of civilian personnel (during conflict)", margin(small)) ///
				title("")
				graph export "output/figureA7_top.pdf", replace

		xtreg v2x_polyarchy i.ipema_any_demo_assist_dum_2l##c.iactual_civilian_total_K_2l $ictrls_3l_varying if ucdp_0yrs==1, fe
			margins, dydx(iactual_civilian_total_K_2l) at(ipema_any_demo_assist_dum_2l = ( 0 1))
				marginsplot, recast(line) recastci(rline) ciopts(lpattern("dash")) ///
				ytitle("Marginal effect of civilian personnel" "(during conflict)", margin(small)) ///
				xtitle("Democracy mandates (during conflict)", margin(small)) ///
				title("")
				graph export "output/figureA7_bottom.pdf", replace



	* Replicate Figure A8

		set scheme plotplainblind
		
		xtreg v2x_polyarchy c.itotal_compound_K_2l##c.iactual_civilian_total_K_2l $ictrls_3l_varying , fe
			margins, dydx(itotal_compound_K_2l) at( iactual_civilian_total_K_2l = (0 (1) 8) )
				marginsplot, recast(line) recastci(rline) plotopts(lpattern("solid") lcolor(black)) ciopts(lpattern("dash") lcolor(black)) graphr(color(white)) ///
					ytitle("Marginal effect of uniformed personnel", margin(small)) ///
					xtitle("# of civilian personnel", margin(small)) ///
					title("")
					graph export "output/figureA8_top.pdf", replace
		
		xtreg v2x_polyarchy c.itotal_compound_K_2l##c.iactual_civilian_total_K_2l $ictrls_3l_varying, fe
			margins, dydx(iactual_civilian_total_K_2l) at(itotal_compound_K_2l = (0 (1) 32) )
				marginsplot, recast(line) recastci(rline) plotopts(lpattern("solid") lcolor(black)) ciopts(lpattern("dash") lcolor(black)) graphr(color(white)) ///
					ytitle("Marginal effect of civilian personnel", margin(small)) ///
					xtitle("# of uniformed personnel", margin(small)) ///
					title("")
					graph export "output/figureA8_bottom.pdf", replace
		
		
		
	* Replicate Figure A9
			
		set scheme plotplainblind
		
		xtreg v2x_polyarchy c.itotal_compound_K_2l##c.iactual_civilian_total_K_2l $ictrls_3l_varying if ucdp_0yrs==1, fe
			margins, dydx(itotal_compound_K_2l) at( iactual_civilian_total_K_2l = (0 (1) 8) )
				marginsplot, recast(line) recastci(rline) plotopts(lpattern("solid") lcolor(black)) ciopts(lpattern("dash") lcolor(black)) graphr(color(white)) ///
					ytitle("Marginal effect of uniformed personnel" "(during conflict)", margin(small)) ///
					xtitle("# of civilian personnel (during conflict)", margin(small)) ///
					title("")
					graph export "output/figureA9_top.pdf", replace
		
		xtreg v2x_polyarchy c.itotal_compound_K_2l##c.iactual_civilian_total_K_2l $ictrls_3l_varying if ucdp_0yrs==1, fe
			margins, dydx(iactual_civilian_total_K_2l) at(itotal_compound_K_2l = (0 (1) 32) )
				marginsplot, recast(line) recastci(rline) plotopts(lpattern("solid") lcolor(black)) ciopts(lpattern("dash") lcolor(black)) graphr(color(white)) ///
					ytitle("Marginal effect of civilian personnel" "(during conflict)", margin(small)) ///
					xtitle("# of uniformed personnel (during conflict)", margin(small)) ///
					title("")
					graph export "output/figureA9_bottom.pdf", replace
		
		
		
	* Replicate Figure A10

		set scheme plotplainblind

		xtreg v2x_polyarchy c.itotal_compound_K_2l##c.iactual_civilian_total_K_2l $ictrls_3l_varying if ucdp_2yrs==1, fe
			margins, dydx(itotal_compound_K_2l) at( iactual_civilian_total_K_2l = (0 (1) 8) )
				marginsplot, recast(line) recastci(rline) plotopts(lpattern("solid") lcolor(black)) ciopts(lpattern("dash") lcolor(black)) graphr(color(white)) ///
					ytitle("Marginal effect of uniformed personnel" "(after 2+ years of peace)", margin(small)) ///
					xtitle("# of civilian personnel (after 2+ years of peace)", margin(small)) ///
					title("")
				graph export "output/figureA10_top.pdf", replace
		
		xtreg v2x_polyarchy c.itotal_compound_K_2l##c.iactual_civilian_total_K_2l $ictrls_3l_varying if ucdp_2yrs==1, fe
			margins, dydx(iactual_civilian_total_K_2l) at(itotal_compound_K_2l = (0 (1) 32) )
				marginsplot, recast(line) recastci(rline) plotopts(lpattern("solid") lcolor(black)) ciopts(lpattern("dash") lcolor(black)) graphr(color(white)) ///
					ytitle("Marginal effect of civilian personnel" "(after 2+ years of peace)", margin(small)) ///
					xtitle("# of uniformed personnel (during conflict)", margin(small)) ///
					title("")
				graph export "output/figureA10_bottom.pdf", replace


		
		
	
	* Replicate Figure A11
		
		set scheme plotplainblind
		
		xtreg v2x_polyarchy i.iany_demo_all_max_dum_2l##c.iactual_civilian_total_K_2l  $ictrls_3l_varying, fe
			margins, dydx(iany_demo_all_max_dum_2l) at( iactual_civilian_total_K_2l = (0 (1) 8) )
				marginsplot, recast(line) recastci(rline) ciopts(lpattern("dash")) ///
				ytitle("Marginal effect of democracy activities", margin(small)) ///
				xtitle("# of civilian personnel", margin(small)) ///
				title("")
				graph export "output/figureA11_top.pdf", replace

		xtreg v2x_polyarchy i.iany_demo_all_max_dum_2l##c.iactual_civilian_total_K_2l  $ictrls_3l_varying, fe
			margins, dydx(iactual_civilian_total_K_2l) at( iany_demo_all_max_dum_2l = (0 1) )
				marginsplot, recast(line) recastci(rline) ciopts(lpattern("dash")) ///
				ytitle("Marginal effect of civilian personnel", margin(small)) ///
				xtitle("Democracy activities", margin(small)) ///
				title("")
				graph export "output/figureA11_bottom.pdf", replace

	
	
	
	* Replicate Figure A12
		
		set scheme plotplainblind
		
		xtreg v2x_polyarchy i.iany_demo_all_max_dum_2l##c.iactual_civilian_total_K_2l  $ictrls_3l_varying if ucdp_0yrs==1, fe
			margins, dydx(iany_demo_all_max_dum_2l) at( iactual_civilian_total_K_2l = (0 (1) 8) )
				marginsplot, recast(line) recastci(rline) ciopts(lpattern("dash")) ///
				ytitle("Marginal effect of democracy activities" "(during conflict)", margin(small)) ///
				xtitle("# of civilian personnel (during conflict)", margin(small)) ///
				title("")
				graph export "output/figureA12_top.pdf", replace

		xtreg v2x_polyarchy i.iany_demo_all_max_dum_2l##c.iactual_civilian_total_K_2l  $ictrls_3l_varying if ucdp_0yrs==1, fe
			margins, dydx(iactual_civilian_total_K_2l) at( iany_demo_all_max_dum_2l = (0 1) )
				marginsplot, recast(line) recastci(rline) ciopts(lpattern("dash")) ///
				ytitle("Marginal effect of civilian personnel" "(during conflict)", margin(small)) ///
				xtitle("Democracy activities (during conflict)", margin(small)) ///
				title("")
				graph export "output/figureA12_bottom.pdf", replace

				
		
			
	* Replicate Table A54

		indvar_separate_ctrls_4l v2x_polyarchy, indvar(ipema_any_demo_assist_dum_3l) title(tableA54)

		
		
	* Replicate Table A55

		indvar_separate_ctrls_5l v2x_polyarchy, indvar(ipema_any_demo_assist_dum_4l) title(tableA55)


		
	* Replicate Table A56
	
		indvar_separate_ctrls_4l v2x_polyarchy, indvar(itotal_compound_K_3l) title(tableA56)
		
		
	* Replicate Table A57
		
		indvar_separate_ctrls_5l v2x_polyarchy, indvar(itotal_compound_K_4l) title(tableA57)	
		
		
	* Replicate Table A58

		indvar_separate_ctrls_4l v2x_polyarchy, indvar(iactual_civilian_total_K_3l) title(tableA58)
		

		
	* Replicate Table A59
			
		indvar_separate_ctrls_5l v2x_polyarchy, indvar(iactual_civilian_total_K_4l) title(tableA59)
		
		
		
	* Replicate Table A60

		indvar_separate_ctrls_4l v2x_polyarchy, indvar(iany_demo_all_max_dum_3l) title(tableA60)
	
	
	
	* Replicate Table A61

		indvar_separate_ctrls_5l v2x_polyarchy, indvar(iany_demo_all_max_dum_4l) title(tableA61)
				
			
		
		
		
		

		
		
		
		
		

		
