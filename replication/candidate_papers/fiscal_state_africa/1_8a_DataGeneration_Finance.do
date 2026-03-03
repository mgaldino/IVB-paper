

 ****************************************************************************************************************************
 ******************Step 8 a) 	FINANCIAL VARIABLES: INFLATION
 *************************************************************************************************************************


 *use metropolitan values for German, Belgian, Italian colonies 
 use "Data/Debt/cpi_inflation", clear
 
replace iso = "NAM" if iso == "DEU"
replace iso = "COD" if iso == "BEL"
replace iso = "SOM" if iso == "ITA"
replace iso = "DJI" if iso == "FRA"
 
 save "TEMP/cpi_inflation_1", replace
 
 use "Temp/Master", clear
 
 merge 1:1 iso year using "TEMP/cpi_inflation_1"
 drop if _merge == 2
 drop _merge
 
 replace inflation_reinhard_rogoff = . if iso == "NAM" & Germany_col == 0
 replace inflation_reinhard_rogoff = . if iso == "COD" & indep == 1
 replace inflation_reinhard_rogoff = . if iso == "SOM" & indep == 1
  replace inflation_reinhard_rogoff = . if iso == "DJI" & indep == 1
 
 sort iso_n year
 bys iso_n : gen inflation_deflator = ((GDP_Deflator - l1.GDP_Deflator )/ GDP_Deflator )*100
 
gen inflation_ep = 1 if (inflation_deflator > 20 & inflation_deflator != .) | (inflation_reinhard_rogoff > 20 & inflation_reinhard_rogoff != .) | (inflation_frankema_waijenburg > 20 & inflation_frankema_waijenburg != .) 
 
bys year:  egen mean_infl_german = total(inflation_ep) if  Germany_col ==1 
bys year:  egen mean_infl_belgian = total(inflation_ep) if  Belgium_col ==1 
bys year:  egen mean_infl_italian = total(inflation_ep) if  Italy_col ==1 
bys year:  egen mean_infl_port = total(inflation_ep) if  Portugal_col ==1 
bys year:  egen mean_infl_france = total(inflation_ep) if  France_col ==1 
bys year:  egen mean_infl_brit = total(inflation_ep) if  Britain_col ==1 

replace inflation_ep = 1 if  inflation_deflator == . & inflation_reinhard_rogoff == . & inflation_frankema_waijenburg == . & Germany_col ==1  & mean_infl_german > 0
replace inflation_ep = 1 if  inflation_deflator == . & inflation_reinhard_rogoff == . & inflation_frankema_waijenburg == . & Belgium_col ==1  & mean_infl_belgian > 0
replace inflation_ep = 1 if inflation_deflator == . & inflation_reinhard_rogoff == . & inflation_frankema_waijenburg == . & Italy_col ==1  & mean_infl_italian > 0
replace inflation_ep = 1 if inflation_deflator == . & inflation_reinhard_rogoff == . & inflation_frankema_waijenburg == . & Portugal_col ==1  & mean_infl_port > 0
replace inflation_ep = 1 if inflation_deflator == . & inflation_reinhard_rogoff == . & inflation_frankema_waijenburg == . & France_col ==1  & mean_infl_france > 0 & year <= 1939
replace inflation_ep = 1 if inflation_deflator == . & inflation_reinhard_rogoff == . & inflation_frankema_waijenburg == . & France_col ==1  & mean_infl_france > 1 & year > 1939
replace inflation_ep = 1 if inflation_deflator == . & inflation_reinhard_rogoff == . & inflation_frankema_waijenburg == . & Britain_col ==1  & mean_infl_brit > 1
replace inflation_ep = 0 if inflation_ep != 1

drop mean_infl_*

sleep 1000
save "Temp/Master", replace


 ****************************************************************************************************************************
 ****************** 	FINANCIAL VARIABLES: DEFAULTS
 *************************************************************************************************************************

use "Data/Nomenclature/Nomenclature", clear

 append using "Data/Nomenclature/Nomenclature_expand"
 
 merge 1:1 name year using "Data/Debt/Debtdefault_CRAG" // no data for Libya and Namibia
 drop if _merge==2
 drop _merge
 
 merge 1:1 iso year using "Data/Debt/NY.GDP.MKTP.CDS.dta"  // all matched
 drop if _merge==2
 drop _merge

  merge 1:1 iso year using "Data/Debt/External_default_Trebesch"   // only subset of countries in core Reinhart, Rogoff, Trebesch dataset 
 drop if _merge==2
 drop _merge
 
 merge 1:1 name year using "Data/Debt/External_default_RR" 
 drop if _merge==2
 drop _merge
 
 gen external_default = default_incl_offical_trebesch
 replace external_default = external_default_RR if default_incl_offical_trebesch == .
 
 replace lcdebt = 0 if lcdebt  ==.
 gen debt_in_default = (total- lcdebt) / (nom_gdp_usd_wdi / 1000000)
 
 encode iso, gen (iso_n)
logit external_default debt_in_default i.iso_n if year > 1959
predict prob_default

replace external_default = 1 if prob_default >= 0.5 & external_default == . & prob_default != .
replace external_default = 0 if external_default != 1

gen external_default_CRAG = 1 if debt_in_default > 0.10 & debt_in_default != .
replace external_default_CRAG = 0 if external_default_CRAG != 1

replace external_default = 0 if iso == "NAM" // not in CRAG database
replace external_default_CRAG = 0 if iso == "NAM" // not in CRAG database
replace external_default = 0 if iso == "LBY" // not in CRAG database
replace external_default_CRAG = 0 if iso == "LBY" // not in CRAG database
replace external_default_CRAG = 1 if iso == "LBR" & external_default == 1 & debt_in_default  == . & total  != 0 // not in CRAG database prior to 1960s

save "Data/Debt/Defaults", replace

use "Temp/Master", clear

merge 1:1 iso year using "Data/Debt/Defaults", keepusing(external_default_CRAG external_default nom_gdp_usd_wdi) // all matched
drop _merge

rename external_default external_default_RR

sort iso_n year
gen l5default_RR = l1.external_default_RR + l2.external_default_RR + l3.external_default_RR + l4.external_default_RR + l5.external_default_RR
gen l5default_CRAG = l1.external_default_CRAG + l2.external_default_CRAG + l3.external_default_CRAG + l4.external_default_CRAG + l5.external_default_CRAG

sleep 1000
save "Temp/Master", replace

 ****************************************************************************************************************************
 ****************** 	FINANCIAL VARIABLES: CENTRAL BANKS AND INTEREST RATES
 *************************************************************************************************************************
 
use "Data/Debt/Central_Bank_Romelli.dta", clear

gen CB_indep_Romelli = (ECBI - (0.2*ECBILending))/0.8 // ECBI is index of 5 equally weighted components, one of which is ECBILending
gen CB_lending_Romelli = ECBILending // Define index as extent to which CB is independent, i.e. cannot lend
rename iso_a3 iso

save "TEMP/Central_Bank_Romelli_1.dta", replace
 
 use "Temp/Master", clear
 
 merge 1:1 iso year using "TEMP/Central_Bank_Romelli_1.dta", keepusing( CB_indep_Romelli CB_lending_Romelli)
 drop if _merge == 2
 drop _merge
 
 gsort iso_n -year
 
 gen CB_indep_Romelli_exp = CB_indep_Romelli
bys iso_n: replace CB_indep_Romelli_exp=CB_indep_Romelli_exp[_n-1] if CB_indep_Romelli_exp==. & indep ==1 & year > 1955
  gen CB_lending_Romelli_exp = CB_lending_Romelli
bys iso_n: replace CB_lending_Romelli_exp=CB_lending_Romelli_exp[_n-1] if CB_lending_Romelli_exp==. & indep ==1 & year > 1955
 
 sort iso_n year
 
 sleep 1000
save "Temp/Master", replace

use "Data/Debt/Interest_rates.dta", clear

gen month = date(date, "DMY")
format month %td
gen year = year(month)
collapse(mean) boeinterestrate monthliborfred, by(year)

save  "TEMP/Interest_rates.dta_1", replace

use "Temp/Master", clear

merge m:1 year using "TEMP/Interest_rates.dta_1", nogen // all matched

rename boeinterestrate IR_BoE
rename monthliborfred IR_Libor
gen IR_BoE_inv = 1/ IR_BoE

 ****************************************************************************************************************************
 ******************  	FINANCIAL VARIABLES: PRIVATE CREDIT MARKET ACCESS (COLONIAL)
 *************************************************************************************************************************

gen credit_market_access = 0
replace credit_market_access = 1 if indep ==1 
replace credit_market_access = 1 if iso == "LBR" | iso == "EGY" | iso == "ZAF" | iso == "SLE" // Anglophone countries with continuous access
replace credit_market_access = 1 if iso == "GMB" & year >= 1888 // Crown colony status granted
replace credit_market_access = 1 if iso == "GHA" & year >= 1895 // Crown colony status granted
replace credit_market_access = 1 if iso == "NGA" & year >= 1906 // Crown colony status granted
replace credit_market_access = 1 if iso == "KEN" & year >= 1920 // Crown colony status granted
replace credit_market_access = 1 if iso == "ZWE" & year >= 1923 // Crown colony status granted
replace credit_market_access = 1 if iso == "BWA" & year >= 1930 // Colonial Development Act 1929
replace credit_market_access = 1 if iso == "ZMB" & year >= 1930 // Colonial Development Act 1929
replace credit_market_access = 1 if iso == "MWI" & year >= 1930 // Colonial Development Act 1929
replace credit_market_access = 1 if iso == "ZMB" & year >= 1930 // Colonial Development Act 1929
replace credit_market_access = 1 if iso == "UGA" & year >= 1930 // Colonial Development Act 1929
replace credit_market_access = 1 if iso == "SWZ" & year >= 1930 // Colonial Development Act 1929
replace credit_market_access = 1 if iso == "LSO" & year >= 1930 // Assume as above
replace credit_market_access = 1 if iso == "TZA" & year >= 1930 // Assume as above
replace credit_market_access = 0 if Britain_col == 1 & year >= 1915 & year <= 1918 // No access to London money market during war
replace credit_market_access = 0 if Britain_col == 1 & year >= 1940 & year <= 1945 // No access to London money market during war

replace credit_market_access = 1 if iso == "ETH" & year >= 1950 // First IBRD loan

replace credit_market_access = 1 if iso == "COD" // First loan issues under Congo Free State regime, continuing for Belgian Congo
replace credit_market_access = 1 if iso == "RWA" & year >= 1930 // Public debt exists from 1930 onwards (although some of it conversions of advances from Congo/Belgium)
replace credit_market_access = 1 if iso == "BDI" & year >= 1930 // Public debt exists from 1930 onwards (although some of it conversions of advances from Congo/Belgium)

replace credit_market_access = 1 if iso == "AGO" & year >= 1914 & year < 1930
replace credit_market_access = 1 if iso == "AGO" & year >= 1958 // Local debt and debt from public metropolitan banks before Colonial Act of 1930, subsequent financial autonomy curtailed, Law Number 2094 of 25th November 1958 allows coloneis to draw on private sources of finance, b
replace credit_market_access = 1 if iso == "MOZ" & year >= 1916 & year < 1930  // Local debt and debt from public metropolitan banks before Colonial Act of 1930, subsequent financial autonomy curtailed, Law Number 2094 of 25th November 1958 allows coloneis to draw on private sources of finance, b
replace credit_market_access = 1 if iso == "MOZ" & year >= 1958 
replace credit_market_access = 1 if iso == "GNB" & year >= 1916 & year < 1930
replace credit_market_access = 1 if iso == "GNB" & year >= 1958 // assume same as Angola

replace credit_market_access = 1 if iso == "DZA" & year >= 1902 // First loan project recorded in law
replace credit_market_access = 1 if iso == "TUN"  // Continuous access (although possibly little use made of borrowing in 30s and 40s)
replace credit_market_access = 1 if iso == "MAR"  // Continuous access (first loans predate establishment of protectorate)
replace credit_market_access = 1 if iso == "MDG"  // Continuous access (incl. French guarantee)
replace credit_market_access = 1 if iso == "CMR" & year >= 1931 // First loan project recorded in law
replace credit_market_access = 1 if iso == "TGO" & year >= 1931 // First loan project recorded in law
//constituent colonies of AEF and AOF do not have access to loans independently until independence

gen cr_market_accessXIRinv = credit_market_access*IR_BoE_inv

gen credit_market_access_default = credit_market_access
replace credit_market_access_default = 0 if external_default_RR == 1
gen cr_market_access_defXIRinv = credit_market_access_default*IR_BoE_inv

gen credit_market_access_CB = credit_market_access
replace credit_market_access_CB = 0 if CB_indep_Romelli_exp < 0.5 & CB_indep_Romelli_exp != .
gen cr_market_access_CBXIRinv = credit_market_access_CB*IR_BoE_inv

 ****************************************************************************************************************************
 ******************  	FINANCIAL VARIABLES: PRIVATE CREDIT MARKET ACCESS (EXCHANGE CONTROLS) 
 *************************************************************************************************************************

merge 1:1 iso year using "Data/Debt/Exchange_control_Quinn.dta", keepusing(cur100 cap100) // no data available for many countries
drop if _merge == 2
drop _merge 
 
 gen cap_lib = 1 if (cur100 >= 50 | cap100 >= 50) & cur100 != .
 replace cap_lib = 0 if cur100 < 50 & cap100 < 50 & cur100 != .
 
 gen credit_market_access_capcontrol = credit_market_access
replace credit_market_access_capcontrol  = 0 if cap_lib == 0 
gen cr_market_access_ccXIRinv = credit_market_access_capcontrol*IR_BoE_inv
 
 
 
 save "Temp/Master",replace

 ****************************************************************************************************************************
 ****************** 	FINANCIAL VARIABLES: DEBT DATA
 *************************************************************************************************************************

merge 1:1 iso year using "Data/Debt/Global_Debt_Database_IBRD.dta", keepusing(d_centralgovernmentdebtofgdp newdebt alldebt)
drop if _merge ==2
drop _merge

rename d_centralgovernmentdebtofgdp debt_gov_GDD
rename newdebt debt_gen_IBRD
rename alldebt debt_all_indep

sleep 1000
save "Temp/Master",replace

use "Data/Debt/Debt_French_col.dta", clear
collapse(sum) amount (firstnm) coloniser, by(iso year) 
save "TEMP/Debt_French_col_1.dta", replace

use "Temp/Master", clear
merge 1:1 iso year using "TEMP/Debt_French_col_1.dta", keepusing(amount)
drop if _merge ==2
drop _merge

rename amount debt_gov_col_temp
gen debt_gov_col_fed_temp = debt_gov_col_temp
sleep 1000
save "Temp/Master",replace

use "TEMP/Debt_French_col_1.dta", clear
drop if coloniser == ""
save "TEMP/Debt_French_col_2.dta", replace

use "Temp/Master", clear
merge m:1 coloniser year using "TEMP/Debt_French_col_2.dta", keepusing(amount)
drop if _merge ==2
drop _merge

sort iso year

bys year: egen pop_AOF = total(POPULATION) if AOF_col ==1
bys year: egen pop_AEF = total(POPULATION) if AEF_col ==1
replace debt_gov_col_fed_temp = amount* (POPULATION/ pop_AOF ) if AOF_col ==1
replace debt_gov_col_fed_temp = amount* (POPULATION/ pop_AEF ) if AEF_col ==1

gen ord_nom = (INDIRECT_NOMINAL + DIRECT_NOMINAL + NONTAX_ORDINARY_NOMINAL + RESOURCES_NOMINAL )
gen rev_gdp = ord_nom /gdp_historical_lcu 
bys iso: egen rev_gdp_mean = mean(rev_gdp ) if France_col ==1 & year >= 1960 & year <=1970
sort iso year
bys iso: gen rev_gdp_mean2 = rev_gdp_mean[75]
replace rev_gdp_mean2 = 0.188 if iso == "GIN" // CIV values 
gen gdp_nom_temp = (1/rev_gdp_mean2) * ord_nom 

gen debt_gov_col_fed = debt_gov_col_fed_temp / gdp_nom_temp 
gen debt_gov_col = debt_gov_col_temp / gdp_nom_temp 

drop *_temp  rev_gdp ord_nom rev_gdp_mean2 rev_gdp_mean
sort iso_n year

gen debt_colfed =  d.debt_all_indep 
replace debt_colfed  = debt_gov_col_fed if France_col == 1 & indep ==0
replace debt_colfed = 0 if debt_colfed == . & France_col == 1 & indep ==0

gen debt_col =  d.debt_all_indep 
replace debt_col  = debt_gov_col if France_col == 1 & indep ==0
replace debt_col = 0 if debt_col == . & France_col == 1 & indep ==0

gen debt_indep = d.debt_all_indep

gen debt_colfed_dum = 1 if debt_colfed > 0 & debt_colfed != .
replace debt_colfed_dum = 0 if debt_colfed <= 0 & debt_colfed != .

sleep 1000
save "Temp/Master", replace
