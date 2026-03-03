
 *********************************************************************************************************
 ******************Step 2 	INTEGRATE FISCAL DATA
 ********************************************************************************************************


 
* Load fiscal dataset
		*These data are created in another self-authored database program (via Matlab); please consult our websites if interested in the raw data
 
		 
		merge 1:1 iso year using "Data/Fiscal/FISCAL_PANEL_V4", keepusing(Currency INDIRECT_NOMINAL DIRECT_NOMINAL NONTAX_ORDINARY_NOMINAL RESOURCES_NOMINAL EXTRAORDINARY_NOMINAL INDIRECT_EXCL_TR_NOMINAL TRADE_TAXES_NOMINAL WAGES POPULATION Forced_Labourdays_pc GDP_Deflator)

		 
				drop _merge
 
 
		merge 1:1 iso year using "Data/Fiscal/FISCAL_PANEL_V4_SOMDJI.dta", keepusing(Currency INDIRECT_NOMINAL DIRECT_NOMINAL NONTAX_ORDINARY_NOMINAL RESOURCES_NOMINAL EXTRAORDINARY_NOMINAL INDIRECT_EXCL_TR_NOMINAL TRADE_TAXES_NOMINAL WAGES POPULATION Forced_Labourdays_pc GDP_Deflator) update replace

				drop _merge

				
				
* Define expanded sample 
		gen expansion=0


		* Extended sample
		foreach x in "DJI" "SOM" "LBR" "LBY" "ETH" {
		replace expansion=1 if iso=="`x'"
		}

		 

* Define fiscal variables 
encode iso, gen (iso_n)
xtset iso_n year

sort  iso_n year

gen WAGES_SMOOTHED = (WAGES + l.WAGES + f.WAGES)/3
replace WAGES_SMOOTHED = WAGES if WAGES_SMOOTHED == . & WAGES != .

gen direct_real = DIRECT_NOMINAL / WAGES / POPULATION

gen tax_non_trade_real = (DIRECT_NOMINAL + INDIRECT_EXCL_TR_NOMINAL)  / WAGES / POPULATION

gen tax_real = (DIRECT_NOMINAL + INDIRECT_NOMINAL)  / WAGES / POPULATION

gen ordinary_non_resource_real = (DIRECT_NOMINAL + INDIRECT_NOMINAL + NONTAX_ORDINARY_NOMINAL)  / WAGES / POPULATION

gen ordinary_real = (INDIRECT_NOMINAL + DIRECT_NOMINAL + NONTAX_ORDINARY_NOMINAL + RESOURCES_NOMINAL) / WAGES / POPULATION

gen total_real = (INDIRECT_NOMINAL + DIRECT_NOMINAL + NONTAX_ORDINARY_NOMINAL + RESOURCES_NOMINAL + EXTRAORDINARY_NOMINAL)  / WAGES / POPULATION

gen extraordinary_real = (EXTRAORDINARY_NOMINAL)  / WAGES / POPULATION

 * save data		
 save "Temp/Master", replace
