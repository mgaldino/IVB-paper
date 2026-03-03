
clear


use "Temp/Master_5yr.dta"

 




eststo m1: reghdfe dtax_non_trade_real         l1.gov_change libdem_extra_vdem  , absorb(year iso_n) cluster(  iso_n) // domestic variables only

eststo m2: reghdfe dtax_non_trade_real      libdem_extra_vdem    l1.gov_change  l1.civ_war_all_PRIO  l1.int_war_all_PRIO, absorb(year iso_n) cluster(  iso_n) // international conflict
 
eststo m3: reghdfe dtax_non_trade_real      libdem_extra_vdem  l1.gov_change l1.civ_war_all_PRIO  l1.int_war_all_PRIO   P_ind_total_f_realshare  , absorb(year iso_n) cluster(  iso_n)  // resources


eststo m4: reghdfe dtax_non_trade_real      libdem_extra_vdem    l1.gov_change  l1.civ_war_all_PRIO  l1.int_war_all_PRIO S_g5_unw_alliance_abs  , absorb(year iso_n) cluster(  iso_n) // aid

eststo m5: reghdfe dtax_non_trade_real       libdem_extra_vdem   l1.gov_change  l1.civ_war_all_PRIO  l1.int_war_all_PRIO   cr_market_accessXBOEinv  , absorb(year iso_n) cluster(  iso_n) // capital markets




eststo m6: reghdfe dtax_non_trade_real       libdem_extra_vdem    l1.gov_change l1.civ_war_all_PRIO  l1.int_war_all_PRIO	 P_ind_total_f_realshare  S_g5_unw_alliance_abs   cr_market_accessXBOEinv X_* l1.drought_affected_merged  , absorb(year iso_n) cluster(  iso_n)  // full specification, controls

 
*** show standardized coefficents (Model 7) => does not display correctly in in esttab, please check results here.
esttab m6, beta    starlevels(* 0.1 ** 0.05 *** 0.01) // full specification, controls (standardized coefficients)

 
 
*** outsheet results 
esttab m1 m2   m3 m4 		 m5    m6     using "Output/Tables/Main/Table1.rtf", replace style(tex) cells(b(star fmt(2)) se(par fmt(2))) stats(r2_a N F, fmt(%9.2f %9.0g)) legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)
esttab m1  m2   m3 m4 		 m5    m6    using "Output/Tables/Main/Table1.tex", replace style(tex) cells(b(star fmt(2)) se(par fmt(2))) stats(r2_a N F, fmt(%9.2f %9.0g)) legend label varlabels(_cons constant) starlevels(* 0.1 ** 0.05 *** 0.01)

 



