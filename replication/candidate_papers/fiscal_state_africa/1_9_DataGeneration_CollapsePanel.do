
clear

use "Temp/Master"
  
 
 
 ****************************************************************************************************************************
 ******************Collapse to 5-year panel
 *************************************************************************************************************************
 
 gen demidecade = .
 replace demidecade = 1 if year >= 1890 & year <=  1894
 replace demidecade = 2 if year >= 1895 & year <=  1899
 replace demidecade = 3 if year >= 1900 & year <=  1904
 replace demidecade = 4 if year >= 1905 & year <=  1909
 replace demidecade = 5 if year >= 1910 & year <=  1914
 replace demidecade = 6 if year >= 1915 & year <=  1919
 replace demidecade = 7 if year >= 1920 & year <=  1924
 replace demidecade = 8 if year >= 1925 & year <=  1929
 replace demidecade = 9 if year >= 1930 & year <=  1934
 replace demidecade = 10 if year >= 1935 & year <=  1939
 replace demidecade = 11 if year >= 1940 & year <=  1944
 replace demidecade = 12 if year >= 1945 & year <=  1949
 replace demidecade = 13 if year >= 1950 & year <=  1954
 replace demidecade = 14 if year >= 1955 & year <=  1959
 replace demidecade = 15 if year >= 1960 & year <=  1964
 replace demidecade = 16 if year >= 1965 & year <=  1969
 replace demidecade = 17 if year >= 1970 & year <=  1974
 replace demidecade = 18 if year >= 1975 & year <=  1979
 replace demidecade = 19 if year >= 1980 & year <=  1984
 replace demidecade = 20 if year >= 1985 & year <=  1989
 replace demidecade = 21 if year >= 1990 & year <=  1994
 replace demidecade = 22 if year >= 1995 & year <=  1999
 replace demidecade = 23 if year >= 2000 & year <=  2004
 replace demidecade = 24 if year >= 2005 & year <=  2009
 replace demidecade = 25 if year >= 2010 & year <=  2015

 gen socialist_mean = socialist
 gen inflation_ep_mean = inflation_ep
 
 preserve
 collapse (firstnm)  year name  ///
 (max)  indep Britain_col France_col Portugal_col Belgium_col Italy_col AOF_col AEF_col Germany_col decolon mandate_col socialist secession ///
 		all_war_maj_PRIO all_war_all_PRIO   col_war_all_PRIO col_war_maj_PRIO int_war_maj_PRIO int_war_all_PRIO civ_war_all_PRIO civ_war_maj_PRIO     int_war_all_sum_PRIO int_war_maj_sum_PRIO ///
		drought_occ_merged disaster_dum drought_aid_dum inflation_ep cap_lib   ///
		large_exporter expansion drought_affected_merged ///
 (mean) RESOURCES_NOMINAL direct_real tax_non_trade_real ordinary_non_resource_real ordinary_real total_real extraordinary_real total_forced_low total_forced_high taxnotrade_forced_low taxnotrade_forced_high  ///
		      eth_frac_Querol         PrecolonialCentralisation tradecost ///
		euro_set_1900_AJR cons_exec_indep_AJR demo_1900_AJR settler_mortality_AJR area_1961 pop_dens g_gdp_yoy tax_non_trade_pcGDP ordinary_pcGDP extraordinary_pcGDP ///
 		polyarchy_extra_vdem libdem_extra_vdem partipdem_extra_vdem delibdem_extra_vdem egaldem_extra_vdem suffr_extra_vdem stfisccap_extra_vdem jucon_extra_vdem legcon_extra_vdem   ///
		CB_indep_Romelli_exp CB_lending_Romelli_exp IR_BoE IR_Libor disaster_affected disaster_affect_aid  ///
		S_col_unw_alliance_abs S_col_w_alliance_abs K_col_w_alliance_sq P_col_w_alliance_sq S_col_w_vote_sq S_col_w_vote_abs K_col_w_vote_sq P_col_w_vote_sq S_g5_unw_alliance_abs S_g5_w_alliance_abs K_g5_w_alliance_sq P_g5_w_alliance_sq S_g5_w_vote_sq S_g5_w_vote_abs K_g5_w_vote_sq P_g5_w_vote_sq ///
		ODA_tot_s  ODA_g5_s ODA_col_all   point_resource_s oil_resource_s socialist_mean inflation_ep_mean ///
		P_ind_BB_i P_point_BB_i P_ind_BB_i_real P_point_BB_i_real P_ind_BB_f P_ind_BB_f_real P_ind_total_i_real P_point_total_i_real P_ind_total_i P_ind_total_f_real P_ind_total_i_nomcost P_ind_total_i_realcost P_point_total_i_realcost P_ind_total_f_realcost P_ind_total_i_nomshare P_ind_total_i_realshare P_point_total_i_realshare P_ind_total_f_realshare ///
		credit_market_access credit_market_access_default credit_market_access_CB credit_market_access_capcontrol ///
		ODA_tot_abs ODA_g5_abs ODA_tot_cpi ODA_g5_cpi ODA_tot_lcu ODA_g5_lcu ODA_tot_real ODA_g5_real ODA_col_all_real eshare_easterly ///
		debt_colfed debt_col debt_indep debt_colfed_dum     ///
		resource_real_USD resource_real_LCU resource_trade_real_USD resource_trade_real_LCU ///
 (sum) leader_change_ARCHIGOS   regime_end elec_change gov_change   ///
		 external_default_RR external_default_CRAG  , by(iso demidecade)
 
 gen periodization = 1 if demidecade <= 5 
replace periodization = 2 if demidecade <= 11 & demidecade > 5
replace periodization = 3 if demidecade <= 14 & demidecade > 11
replace periodization = 4 if demidecade <= 17 & demidecade > 14
replace periodization = 5 if demidecade <= 21 & demidecade > 17
replace periodization = 6 if demidecade <= 25 & demidecade > 21
 
encode iso, gen(iso_n)
xtset iso_n demidecade
sort iso_n demidecade
gen dtax_non_trade_real = d.tax_non_trade_real
gen dtaxnotrade_forced_high = d.taxnotrade_forced_high

gen cr_market_accessXBOEinv = credit_market_access * (1/IR_BoE)
replace cr_market_accessXBOEinv = cr_market_accessXBOEinv /2
gen cr_market_access_defaultXBOEinv = credit_market_access_default * (1/IR_BoE)
gen cr_market_access_CBXBOEinv = credit_market_access_CB * (1/IR_BoE)
gen cr_market_access_ccXBOEinv = credit_market_access_capcontrol * (1/IR_BoE)



foreach var of varlist ODA_* {
bysort iso : replace `var' = . if `var' == 0 & year <1990 
}

 
rename g_gdp_yoy  X_g_gdp_yoy
rename  inflation_ep X_inflation_ep  
rename external_default_RR X_external_default_RR
rename socialist X_socialist
rename secession X_secession
gen X_indep = indep
 
sort iso_n demi
bys iso_n: gen l10gov_change = l1.gov_change +l2.gov_change
bys iso_n: gen l10leader_change_ARCHIGOS = l1.leader_change_ARCHIGOS + l2.leader_change_ARCHIGOS
 

**** label data

			 
			label var  libdem_extra_vdem "lib. democracy score (VDEM)"
			label var Britain_col "(former) British colony"
			label var euro_set_1900_AJR "European settlers, share of pop."
			label var suffr_extra_vdem "Population granted suffrage, share"
 			label var eth_frac_Q "Ethnic fractionalisation (Montalvo & Reynal-Querol)"
 			label var  delibdem_extra_vdem "deliberative democracy score (VDEM)"
			label var  egaldem_extra_vdem "egalitarian democracy score (VDEM)"
			label var  partipdem_extra_vdem "participatory democracy score (VDEM)"
			label var  polyarchy_extra_vdem "polyarchy score (VDEM)"

			label var  all_war_all_PRIO "conflict incidence (PRIO)" 
			label var  int_war_all_sum_PRIO "international war incidence (PRIO)" 
 			label var  civ_war_all_PRIO "civil war incidence (PRIO)" 
   

			label var drought_affected_merged "drought-affected population"
			label var disaster_affected "disaster-affected population"

			label var gov_change "change in government"
			label var leader "change in chief executive, 5yr period" 
			label var l10leader "change in chief executive, 10yr period" 
			label var decol "decolonisation"  
 

			label var S_g5_unw_alliance_abs   "Exposure to foreign aid"
			label var S_g5_w_alliance_abs   "Exposure to foreign aid, weighted alliances"
			label var S_col_w_alliance_abs   "Exposure to metropolitan aid, weighted alliances"
			label var S_col_unw_alliance_abs "Exposure to metropolitan aid"
			label var S_g5_w_vote_sq   "Exposure to foreign aid, UN voting, sq. distances"
			label var S_g5_w_vote_abs   "Exposure to foreign aid, UN voting, abs. distances"
			label var K_g5_w_vote_sq  "K-index, UN voting, sq. distances"
			label var P_g5_w_vote_sq "P-index, UN voting, sq. distances"
			label var ODA_g5_abs "Aid received, UNSC veto powers, US Dollar"
			label var ODA_col_all "Aid received , former metropolis, share of GDP" 
			label var ODA_col_all_real "Real aid received, (former) metropolis, local currency"


			label var P_ind_total_f_realshare  "Real resource prices"
			label var P_ind_total_i_realshare  "Real resource prices, variable export shares, trade weighted index"
			label var P_ind_total_f_real  "Real resource prices, fixed export shares, no trade weighting"
			label var P_ind_total_i_real  "Real resource prices, fixed export shares, no trade weighting"
			label var P_ind_total_i_nomshare "Nominal resource prices, variable export shares, trade weighted index"
			label var resource_real_LCU "Real resource revenues, local currency"
			label var resource_real_USD "Real resource revenues, US Dollars"
			label var oil_resource_s "Share of oil in exports"
			label var P_point_total_i_realshare "Real mineral prices, variable export shares, trade weighted index"

			label var cr_market_accessXBOEinv "Credit market access"
			label var debt_colfed "Debt issuance, amount, incl. French colonies"
			label var  debt_colfed_dum "Debt issuance, dummy, incl. French colonies"
			label var cap_lib "Liberalised capital flows"
			label var CB_indep_Romelli_exp "Central Bank independence"
			label var  CB_lending_Romelli_exp "Central bank lending"
 		 
			label var X_g_gdp_yoy "real GDP, y-o-y change"
			label var X_inflation_ep  "hyperinflation episode"
			label var X_external_default_RR "sovereign debt default"
			label var X_secession "territorial change"
			label var X_socialist "socialist economic system"
			label var X_indep "independent state"

			label var tax_non_trade_real "Real pc tax revenues, excl. trade and resources"
			label var dtax_non_trade_real "Change of real pc tax revenues, excl. trade and resources"
			label var taxnotrade_forced_low "Real pc tax revenues, incl. forced labour, lower bound"
			label var taxnotrade_forced_high "Real pc tax revenues, incl. forced labour, upper bound"
			label var ordinary_non_resource_real "Real pc ordinary revenues"
			label var tax_non_trade_pcGDP  "Tax revenues, share of GDP"
			label var Precolonial "Precolonial centralisation"
			label var pop_dens "Population density"
			label var eshare_easterly  "Settler share (Easterly & Levine)"


			
			

						*** add lagged variables  
						xtset iso_n demidecade

						by iso_n :	gen l1_drought_affected_merged		=l1.drought_affected_merged 
						by iso_n: 	gen l1_gov_change					=l1.gov_change
 						by iso_n:   gen l1_int_war_all_PRIO 			=l1.int_war_all_PRIO
						by iso_n:   gen l1_civ_war_all_PRIO 			=l1.civ_war_all_PRIO
 						by iso_n:   gen l1_leader_change_archigos		=l1.leader_change_ARCHIGOS

						
						  
						
						* rescale vdem measures
						local democracymeasures `"  "libdem_extra_vdem"   "polyarchy_extra_vdem" "partipdem_extra_vdem"  "delibdem_extra_vdem" "egaldem_extra_vdem"    "' 

						foreach x of local  democracymeasures {
							replace `x'=`x'*100
						}


  save "Temp/Master_5yr", replace
 
 restore
