


 ****************************************************************************************************************************
 ******************Step 8b 	AID / ODA
 *************************************************************************************************************************
			
			
			*** Political Similartiy data
			
						use "Data/ODA/Political_similarity.dta", clear

						sort cabb1 cabb2 year

						*there is no alliance data for 2013, 14, 15 

						foreach var of varlist srsvaa srswvaa kappava piva  {
						bys cabb1 cabb2: replace `var' = `var'[_n-1] if `var' == . 
						}



						  save "TEMP/Political_similarity_1.dta", replace
						 
						 use "TEMP/Political_similarity_1.dta", clear
						 
						 keep if cabb1 == "UKG"
						 keep year ccode1 cabb1 ccode2 cabb2 srsvaa srswvaa kappava piva srsvvs srsvva kappavv pivv
						 
						foreach var of varlist srsvaa srswvaa kappava piva srsvvs srsvva kappavv pivv {
						rename `var' uk_`var' 
						}
						 
						 rename cabb2 cow_alf
						 
						 save "TEMP/Political_similarity_UK.dta", replace
						 
						 use "TEMP/Political_similarity_1.dta", clear
						 
						 keep if cabb1 == "FRN"
						 keep year ccode1 cabb1 ccode2 cabb2 srsvaa srswvaa kappava piva srsvvs srsvva kappavv pivv
						 
						foreach var of varlist srsvaa srswvaa kappava piva srsvvs srsvva kappavv pivv {
						rename `var' fr_`var' 
						}
						 
						 rename cabb2 cow_alf
						 
						 save "TEMP/Political_similarity_FR.dta", replace
						 
						 use "TEMP/Political_similarity_1.dta", clear
						 
						 keep if cabb1 == "POR"
						 keep year ccode1 cabb1 ccode2 cabb2 srsvaa srswvaa kappava piva srsvvs srsvva kappavv pivv
						 
						foreach var of varlist srsvaa srswvaa kappava piva srsvvs srsvva kappavv pivv {
						rename `var' pt_`var' 
						}
						 
						 rename cabb2 cow_alf
						 
						 save "TEMP/Political_similarity_PT.dta", replace
						 
						 
						  use "TEMP/Political_similarity_1.dta", clear
						 
						 keep if cabb1 == "ITA"
						 keep year ccode1 cabb1 ccode2 cabb2 srsvaa srswvaa kappava piva srsvvs srsvva kappavv pivv
						 
						foreach var of varlist srsvaa srswvaa kappava piva srsvvs srsvva kappavv pivv {
						rename `var' it_`var' 
						}
						 
						 rename cabb2 cow_alf
						 
						 save "TEMP/Political_similarity_IT.dta", replace
						 
						  use "TEMP/Political_similarity_1.dta", clear
						 
						 keep if cabb1 == "BEL"
						 keep year ccode1 cabb1 ccode2 cabb2 srsvaa srswvaa kappava piva srsvvs srsvva kappavv pivv
						 
						foreach var of varlist srsvaa srswvaa kappava piva srsvvs srsvva kappavv pivv {
						rename `var' be_`var' 
						}
						 
						 rename cabb2 cow_alf
						 
						 save "TEMP/Political_similarity_BE.dta", replace
						 
						 use "TEMP/Political_similarity_1.dta", clear
						 
						 replace cabb1 = "GMY" if cabb1 == "GFR" & year <1990
						 keep if cabb1 == "GMY" 
						 keep year ccode1 cabb1 ccode2 cabb2 srsvaa srswvaa kappava piva srsvvs srsvva kappavv pivv
						 
						foreach var of varlist srsvaa srswvaa kappava piva srsvvs srsvva kappavv pivv {
						rename `var' de_`var' 
						}
						 
						 rename cabb2 cow_alf
						 
						 save "TEMP/Political_similarity_DE.dta", replace
						 
						  use "TEMP/Political_similarity_1.dta", clear
						 
						 keep if cabb1 == "USA"
						 keep year ccode1 cabb1 ccode2 cabb2 srsvaa srswvaa kappava piva srsvvs srsvva kappavv pivv
						 
						foreach var of varlist srsvaa srswvaa kappava piva srsvvs srsvva kappavv pivv {
						rename `var' us_`var' 
						}
						 
						 rename cabb2 cow_alf
						 
						 save "TEMP/Political_similarity_US.dta", replace
						 
						  use "TEMP/Political_similarity_1.dta", clear
						 
						 keep if cabb1 == "RUS"
						 keep year ccode1 cabb1 ccode2 cabb2 srsvaa srswvaa kappava piva srsvvs srsvva kappavv pivv
						 
						foreach var of varlist srsvaa srswvaa kappava piva srsvvs srsvva kappavv pivv {
						rename `var' ru_`var' 
						}
						 
						 rename cabb2 cow_alf
						 
						 save "TEMP/Political_similarity_RU.dta", replace
						 
						 use "TEMP/Political_similarity_1.dta", clear
						 
						 keep if cabb1 == "CHN"
						 keep year ccode1 cabb1 ccode2 cabb2 srsvaa srswvaa kappava piva srsvvs srsvva kappavv pivv
						 
						foreach var of varlist srsvaa srswvaa kappava piva srsvvs srsvva kappavv pivv {
						rename `var' cn_`var' 
						}
						 
						 rename cabb2 cow_alf
						 
						 save "TEMP/Political_similarity_CN.dta", replace
						 
						 use "Temp/Master", clear
						 merge 1:1 year cow_alf using "TEMP/Political_similarity_UK.dta"
						 drop if _merge ==2 
						 drop _merge
						 
						  merge 1:1 year cow_alf using "TEMP/Political_similarity_FR.dta"
						 drop if _merge ==2 
						 drop _merge
						 
						 merge 1:1 year cow_alf using "TEMP/Political_similarity_PT.dta"
						 drop if _merge ==2 
						 drop _merge
						 
						  merge 1:1 year cow_alf using "TEMP/Political_similarity_IT.dta"
						 drop if _merge ==2 
						 drop _merge
						 
						 merge 1:1 year cow_alf using "TEMP/Political_similarity_BE.dta"
						 drop if _merge ==2 
						 drop _merge
						 
						 merge 1:1 year cow_alf using "TEMP/Political_similarity_DE.dta"
						 drop if _merge ==2 
						 drop _merge
						 
						  merge 1:1 year cow_alf using "TEMP/Political_similarity_US.dta"
						 drop if _merge ==2 
						 drop _merge
						 
						 merge 1:1 year cow_alf using "TEMP/Political_similarity_RU.dta"
						 drop if _merge ==2 
						 drop _merge
						 
						 merge 1:1 year cow_alf using "TEMP/Political_similarity_CN.dta"
						 drop if _merge ==2 
						 drop _merge
						 
						 drop ccode1 cabb1 ccode2
						 
						  merge m:1 year using "Data/ODA/Metropolitan_budgets.dta"
						 drop _merge
						 
						 foreach var of varlist uk_* {
						gen `var'_w =  `var'*xuk_def if indep ==1
						replace `var'_w = xuk_def if indep ==0
						}
						 
						  foreach var of varlist fr_* {
						gen `var'_w =  `var'*xfr_def if indep ==1
						replace `var'_w = xfr_def if indep ==0
						}

						foreach var of varlist pt_* {
						gen `var'_w =  `var'*xpt_def if indep ==1 
						replace `var'_w = xpt_def if indep ==0
						}

						foreach var of varlist it_* {
						gen `var'_w =  `var'*xit_def if indep == 1
						replace `var'_w = xit_def if indep ==0
						}

						foreach var of varlist be_* {
						gen `var'_w =  `var'*xbe_def if indep == 1
						replace `var'_w = xbe_def if indep ==0
						}

						foreach var of varlist de_* {
						gen `var'_w =  `var'*xde_def if indep ==1
						replace `var'_w = xde_def if indep ==0
						}

						foreach var of varlist us_* {
						gen `var'_w =  `var'*xus_def if indep ==1 
						replace `var'_w = xus_def if indep ==0
						}

						foreach var of varlist ru_* {
						gen `var'_w =  `var'*xru_def if indep ==1 
						replace `var'_w = xru_def if indep ==0
						}

						foreach var of varlist cn_* {
						gen `var'_w =  `var'*xcn_def if indep ==1
						replace `var'_w = xcn_def if indep ==0
						}

						sort iso_n year
						gen col_srsvaa = uk_srsvaa_w if Britain_col ==1 | iso == "ETH"
						replace col_srsvaa = fr_srsvaa_w if France_col ==1
						replace col_srsvaa = pt_srsvaa_w if Portugal_col ==1
						replace col_srsvaa = it_srsvaa_w if Italy_col ==1
						replace col_srsvaa = be_srsvaa_w if Belgium_col ==1
						replace col_srsvaa = de_srsvaa_w if Germany_col ==1 |  (iso == "NAM" & year> 1945)
						replace col_srsvaa = us_srsvaa_w if iso == "LBR"

						rename col_srsvaa S_col_unw_alliance_abs
						gen l1S_col_unw_alliance_abs = l1.S_col_unw_alliance_abs + S_col_unw_alliance_abs

						 gen col_srswvaa = uk_srswvaa_w if Britain_col ==1 | iso == "ETH"
						replace col_srswvaa = fr_srswvaa_w if France_col ==1
						replace col_srswvaa = pt_srswvaa_w if Portugal_col ==1
						replace col_srswvaa = it_srswvaa_w if Italy_col ==1
						replace col_srswvaa = be_srswvaa_w if Belgium_col ==1
						replace col_srswvaa = de_srswvaa_w if Germany_col ==1 |  (iso == "NAM" & year> 1945)
						replace col_srswvaa = us_srswvaa_w if iso == "LBR"

						rename col_srswvaa S_col_w_alliance_abs
						gen l1S_col_w_alliance_abs = l1.S_col_w_alliance_abs + S_col_w_alliance_abs

						gen col_kappava = uk_kappava_w if Britain_col ==1 | iso == "ETH"
						replace col_kappava = fr_kappava_w if France_col ==1
						replace col_kappava = pt_kappava_w if Portugal_col ==1
						replace col_kappava = it_kappava_w if Italy_col ==1
						replace col_kappava = be_kappava_w if Belgium_col ==1
						replace col_kappava = de_kappava_w if Germany_col ==1 |  (iso == "NAM" & year> 1945)
						replace col_kappava = us_kappava_w if iso == "LBR"

						rename col_kappava K_col_w_alliance_sq
						gen l1K_col_w_alliance_sq = l1.K_col_w_alliance_sq + K_col_w_alliance_sq

						 gen col_piva = uk_piva_w if Britain_col ==1 | iso == "ETH"
						replace col_piva = fr_piva_w if France_col ==1
						replace col_piva = pt_piva_w if Portugal_col ==1
						replace col_piva = it_piva_w if Italy_col ==1
						replace col_piva = be_piva_w if Belgium_col ==1
						replace col_piva = de_piva_w if Germany_col ==1 |  (iso == "NAM" & year> 1945)
						replace col_piva = us_piva_w if iso == "LBR"

						rename col_piva P_col_w_alliance_sq
						gen l1P_col_w_alliance_sq = l1.P_col_w_alliance_sq + P_col_w_alliance_sq

						 gen col_srsvvs = uk_srsvvs_w if Britain_col ==1 | iso == "ETH"
						replace col_srsvvs = fr_srsvvs_w if France_col ==1
						replace col_srsvvs = pt_srsvvs_w if Portugal_col ==1
						replace col_srsvvs = it_srsvvs_w if Italy_col ==1
						replace col_srsvvs = be_srsvvs_w if Belgium_col ==1
						replace col_srsvvs = de_srsvvs_w if Germany_col ==1 |  (iso == "NAM" & year> 1945)
						replace col_srsvvs = us_srsvvs_w if iso == "LBR"

						rename col_srsvvs S_col_w_vote_sq
						gen l1S_col_w_vote_sq = l1.S_col_w_vote_sq + S_col_w_vote_sq

						 gen col_srsvva = uk_srsvva_w if Britain_col ==1 | iso == "ETH"
						replace col_srsvva = fr_srsvva_w if France_col ==1
						replace col_srsvva = pt_srsvva_w if Portugal_col ==1
						replace col_srsvva = it_srsvva_w if Italy_col ==1
						replace col_srsvva = be_srsvva_w if Belgium_col ==1
						replace col_srsvva = de_srsvva_w if Germany_col ==1 |  (iso == "NAM" & year> 1945)
						replace col_srsvva = us_srsvva_w if iso == "LBR"

						rename col_srsvva S_col_w_vote_abs
						gen l1S_col_w_vote_abs = l1.S_col_w_vote_abs + S_col_w_vote_abs

						gen col_kappavv = uk_kappavv_w if Britain_col ==1 | iso == "ETH"
						replace col_kappavv = fr_kappavv_w if France_col ==1
						replace col_kappavv = pt_kappavv_w if Portugal_col ==1
						replace col_kappavv = it_kappavv_w if Italy_col ==1
						replace col_kappavv = be_kappavv_w if Belgium_col ==1
						replace col_kappavv = de_kappavv_w if Germany_col ==1 |  (iso == "NAM" & year> 1945)
						replace col_kappavv = us_kappavv_w if iso == "LBR"

						rename col_kappavv K_col_w_vote_sq
						gen l1K_col_w_vote_sq = l1.K_col_w_vote_sq + K_col_w_vote_sq

						 gen col_pivv = uk_pivv_w if Britain_col ==1 | iso == "ETH"
						replace col_pivv = fr_pivv_w if France_col ==1
						replace col_pivv = pt_pivv_w if Portugal_col ==1
						replace col_pivv = it_pivv_w if Italy_col ==1
						replace col_pivv = be_pivv_w if Belgium_col ==1
						replace col_pivv = de_pivv_w if Germany_col ==1 |  (iso == "NAM" & year> 1945)
						replace col_pivv = us_pivv_w if iso == "LBR"

						rename col_pivv P_col_w_vote_sq
						gen l1P_col_w_vote_sq = l1.P_col_w_vote_sq + P_col_w_vote_sq

						sort iso_n year

						gen S_g5_unw_alliance_abs = S_col_unw_alliance_abs
						replace S_g5_unw_alliance_abs = uk_srsvaa_w + fr_srsvaa_w + us_srsvaa_w + ru_srsvaa_w + cn_srsvaa_w if indep == 1 & year > 1945
						gen l1S_g5_unw_alliance_abs = l1.S_g5_unw_alliance_abs+ S_g5_unw_alliance_abs

						gen S_g5_w_alliance_abs =  S_col_w_alliance_abs
						replace S_g5_w_alliance_abs  = uk_srswvaa_w + fr_srswvaa_w + us_srswvaa_w + ru_srswvaa_w + cn_srswvaa_w if indep == 1 & year > 1945
						gen l1S_g5_w_alliance_abs = l1.S_g5_w_alliance_abs+ S_g5_w_alliance_abs

						gen K_g5_w_alliance_sq = K_col_w_alliance_sq
						replace K_g5_w_alliance_sq   = uk_kappava_w + fr_kappava_w + us_kappava_w + ru_kappava_w + cn_kappava_w if indep == 1 & year > 1945
						gen l1K_g5_w_alliance_sq = l1.K_g5_w_alliance_sq + K_g5_w_alliance_sq

						gen P_g5_w_alliance_sq = P_col_w_alliance_sq
						replace P_g5_w_alliance_sq   = uk_piva_w + fr_piva_w + us_piva_w + ru_piva_w + cn_piva_w if indep == 1 & year > 1945
						gen l1P_g5_w_alliance_sq= l1.P_g5_w_alliance_sq + P_g5_w_alliance_sq

						egen S_g5_w_vote_sq = rowtotal(uk_srsvvs_w  fr_srsvvs_w  us_srsvvs_w  ru_srsvvs_w  cn_srsvvs_w) if indep == 1 & year > 1945 
						replace S_g5_w_vote_sq = S_col_w_vote_sq  if S_g5_w_vote_sq == .
						gen l1S_g5_w_vote_sq= l1.S_g5_w_vote_sq + S_g5_w_vote_sq

						egen S_g5_w_vote_abs = rowtotal(uk_srsvva_w  fr_srsvva_w  us_srsvva_w  ru_srsvva_w  cn_srsvva_w) if indep == 1 & year > 1945 
						replace S_g5_w_vote_abs  = S_col_w_vote_abs if S_g5_w_vote_abs == .
						gen l1S_g5_w_vote_abs = l1.S_g5_w_vote_abs + S_g5_w_vote_abs

						egen K_g5_w_vote_sq = rowtotal(uk_kappavv_w  fr_kappavv_w  us_kappavv_w  ru_kappavv_w  cn_kappavv_w) if indep == 1 & year > 1945
						replace K_g5_w_vote_sq  = S_col_w_vote_abs if K_g5_w_vote_sq == .
						gen l1K_g5_w_vote_sq = l1.K_g5_w_vote_sq + K_g5_w_vote_sq

						egen P_g5_w_vote_sq = rowtotal(uk_pivv_w  fr_pivv_w  us_pivv_w  ru_pivv_w  cn_pivv_w ) if indep == 1 & year > 1945
						replace P_g5_w_vote_sq = P_col_w_vote_sq if P_g5_w_vote_sq == .
						gen l1P_g5_w_vote_sq = l1.P_g5_w_vote_sq  + P_g5_w_vote_sq 

						drop *_srsvaa *_srswvaa *_kappava *_piva *_srsvvs *_srsvva *_kappavv *_pivv *_def *_w

						save "Temp/Master", replace

						
			*** *ODA flows
 
						use "Data/ODA/ODA_flows.dta", clear

						rename dac_countries ODA_dac 
						rename nondac_countries ODA_nondac
						rename belgium ODA_BE 
						rename france ODA_FR
						rename portugal ODA_PT
						rename spain ODA_SP
						rename usa ODA_US
						rename soviet ODA_RU
						rename germany ODA_DE
						rename unitedkingdom2 ODA_UK
						rename china ODA_CN
						rename italy ODA_IT

						save "TEMP/ODA_flows_1.dta", replace

						sleep 1000
						use "Temp/Master", clear
						merge 1:1 iso year using "TEMP/ODA_flows_1.dta"
						drop if _merge ==2
						drop _merge

								*ODA as % of GDP

								egen ODA_tot_abs = rowtotal(ODA_dac  ODA_nondac ODA_CN ODA_RU)
								gen ODA_tot_s = ODA_tot_abs / (gdp_current_us / 1000000)
								egen ODA_g5_abs = rowtotal(ODA_UK  ODA_FR  ODA_US  ODA_CN  ODA_RU)
								gen ODA_g5_s = ODA_g5_abs / (gdp_current_us / 1000000)
								gen ODA_col_UK = ODA_UK / (gdp_current_us / 1000000)
								gen ODA_col_FR = ODA_FR / (gdp_current_us / 1000000)
								gen ODA_col_PT = ODA_PT / (gdp_current_us / 1000000)
								gen ODA_col_BE = ODA_BE / (gdp_current_us / 1000000)
								gen ODA_col_IT = ODA_IT / (gdp_current_us / 1000000)
								gen ODA_col_DE = ODA_DE / (gdp_current_us / 1000000)
								gen ODA_col_US = ODA_US / (gdp_current_us / 1000000)
								gen ODA_col_RU = ODA_RU / (gdp_current_us / 1000000)
								gen ODA_col_CN = ODA_CN / (gdp_current_us / 1000000)

								gen ODA_col_all = ODA_col_UK if Britain_col ==1
								replace ODA_col_all = ODA_col_FR if France_col ==1
								replace ODA_col_all = ODA_col_PT if Portugal_col ==1
								replace ODA_col_all = ODA_col_IT if Italy_col ==1
								replace ODA_col_all = ODA_col_BE if Belgium_col ==1
								replace ODA_col_all = ODA_col_DE if Germany_col ==1 |  iso == "NAM"
								replace ODA_col_all = ODA_col_US if iso == "LBR"
								replace ODA_col_all = ODA_col_RU if iso == "ETH"

								*ODA as deflated by CPI
								merge m:1 year using "Data/Resources/CPI.dta", nogen
								sort iso year
								gen ODA_tot_cpi = ODA_tot_abs / (us_cpi)
								gen ODA_g5_cpi = ODA_g5_abs / (us_cpi)

								*convert $ ODA to LCU using implicit exchange rate
								gen x_rate_lcu_dollar = gdp_current_us / gdp_fiscal_lcu

								gen ODA_tot_lcu = ODA_tot_abs * 1000000 / x_rate_lcu_dollar
								replace ODA_tot_lcu  = . if indep == 0
								gen ODA_g5_lcu = ODA_g5_abs * 1000000 / x_rate_lcu_dollar
								replace ODA_g5_lcu = . if indep == 0
								gen ODA_col_UK_lcu = ODA_UK * 1000000 / x_rate_lcu_dollar
								gen ODA_col_FR_lcu = ODA_FR * 1000000 / x_rate_lcu_dollar
								gen ODA_col_PT_lcu = ODA_PT * 1000000 / x_rate_lcu_dollar
								gen ODA_col_BE_lcu = ODA_BE * 1000000 / x_rate_lcu_dollar
								gen ODA_col_IT_lcu = ODA_IT * 1000000 / x_rate_lcu_dollar
								gen ODA_col_DE_lcu = ODA_DE * 1000000 / x_rate_lcu_dollar
								gen ODA_col_US_lcu = ODA_US * 1000000 / x_rate_lcu_dollar
								gen ODA_col_RU_lcu = ODA_RU * 1000000 / x_rate_lcu_dollar
								gen ODA_col_CN_lcu = ODA_CN * 1000000 / x_rate_lcu_dollar

								gen ODA_tot_real = ODA_tot_lcu / WAGES 
								replace ODA_tot_lcu = ODA_tot_lcu/1000000000
								gen ODA_g5_real = ODA_g5_lcu / WAGES 
								gen ODA_col_UK_real = ODA_col_UK_lcu / WAGES 
								gen ODA_col_FR_real = ODA_col_FR_lcu / WAGES 
								gen ODA_col_PT_real = ODA_col_PT_lcu  / WAGES 
								gen ODA_col_BE_real = ODA_col_BE_lcu  / WAGES 
								gen ODA_col_IT_real = ODA_col_IT_lcu  / WAGES 
								gen ODA_col_DE_real = ODA_col_DE_lcu  / WAGES 
								gen ODA_col_US_real = ODA_col_US_lcu / WAGES 
								gen ODA_col_RU_real = ODA_col_RU_lcu / WAGES 
								gen ODA_col_CN_real = ODA_col_CN_lcu  / WAGES 

								 gen ODA_col_all_real = ODA_col_UK_real if Britain_col ==1
								replace ODA_col_all_real = ODA_col_FR_real if France_col ==1
								replace ODA_col_all_real = ODA_col_PT_real if Portugal_col ==1
								replace ODA_col_all_real = ODA_col_IT_real if Italy_col ==1
								replace ODA_col_all_real = ODA_col_BE_real if Belgium_col ==1
								replace ODA_col_all_real = ODA_col_DE_real if Germany_col ==1 |  iso == "NAM"
								replace ODA_col_all_real = ODA_col_US_real if iso == "LBR"
								replace ODA_col_all_real = ODA_col_RU_real if iso == "ETH"
								replace ODA_col_all_real = . if indep == 0

								gen ODA_col_extra = EXTRAORDINARY / WAGES
								replace ODA_col_extra= . if indep == 1
								replace ODA_col_extra= . if indep == 0 & Britain_col ==1 // British colonies excluded as no usable extraordianry revenue series exist
								replace ODA_tot_real = ODA_col_extra if indep == 0
								replace ODA_tot_real = . if ODA_tot_real == 0
								replace ODA_g5_real = ODA_col_extra if indep == 0
								replace ODA_g5_real = . if ODA_g5_real == 0
								replace ODA_col_all_real = ODA_col_extra if indep == 0
								replace ODA_col_all_real = . if ODA_col_all_real == 0
								replace ODA_col_all_real =  ODA_col_all_real/1000000

			*** save ODA flows
								
			save "Temp/Master", replace
