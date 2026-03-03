 


 ****************************************************************************************************************************
 ******************Step 4 a	MERGE IN TIME INVARIANT VARIABLES: ETHNO-LINGUISTIC FRACTIONALISATION, PRE-COLONIAL HISTORIES, POP DENSITY, URBANISATION
 *************************************************************************************************************************

 *Ethnicity
 
 * load  Montalvo and Reynal-Querol Data 

		merge m:m name using "Data/Ethnicity/Querol.dta", keepusing(    ETHFRAC)  // Note no data for Burkina Faso, Namibia, Djibouti, Libya
		drop if _merge==2
		drop _merge

 		rename ETHFRAC eth_frac_Querol
		
		* replace missings with Fearon data 

		merge m:m cow_num  using "Data/Ethnicity/Fearon.dta", keepusing(  ef   )  // 
		drop if _merge==2
		drop _merge
		
 		rename ef eth_frac_Fearon
 
		replace eth_frac_Querol = eth_frac_Fearon if eth_frac_Querol == .
		
		


* Pre-colonial centralization

merge m:1 iso  using "Data/Precolonial Centralization/Gennaioli.dta", nogen 
		
 
 
* Trade potential (own calculation)

		merge m:1 iso  using "Data/Trade potential/tradecosts.dta"
		drop if _merge ==2
		drop _merge

		 gen tradecost = exp(ln_tradecost)

* AJR (to replace Congo value) 

		merge m:1 iso  using "Data/Settler Mortality/AJR.dta" ,keepusing(euro1900 cons1 democ00a extmort4)
		drop if _merge ==2
		drop _merge

		rename euro1900 euro_set_1900_AJR
		rename cons1 cons_exec_indep_AJR
		rename democ00a demo_1900_AJR
		rename extmort4 settler_mortality_AJR

		replace euro_set_1900_AJR = euro_set_1900_AJR/100


* Easterly settler data 

		merge m:1 iso  using "Data/Democracy/Eshare_Easterly.dta" ,keepusing(eshare)
		drop if _merge ==2
		drop _merge

		replace eshare=euro_set_1900_AJR if eshare==.

		rename eshare eshare_easterly
		label var eshare_easterly  "Share according to Easterly/Levine 2018; Congos take AJR value"

* Population density

		merge m:1 iso using "Data/Area/Area_WDI.dta" 
		drop if _merge ==2
		drop _merge

		gen pop_dens = POPULATION/ area_1961

		
* save data		
 save "Temp/Master", replace
