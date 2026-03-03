


***** This bins the data required for the interactions (for time-variant data, these are binned 1) pre- 1965 and 2) post-1965)

clear

use  "Temp/Master_5yr"




* bin Querol ehtnic frac

			egen  eth_frac_Querol_binned= cut(eth_frac_Querol), group(3)  


* bin Easterly
			 gen eshare_easterly_d=1 if eshare_easterly!=0
			 replace eshare_easterly_d=0 if eshare_easterly_d==.
			  
			  * this creates 3(!) bins  
				egen eshare_easterly_binned=cut(eshare_easterly) , group(4)
			 
				tab eshare_easterly_binned
			  

 * Bin democracy  ( by period )
 
			 gen libdem_extra_vdem_binned=.
				egen  libdem_extra_vdem_b_pre1965= cut(libdem_extra_vdem) if dtax_non_trade_real!=. & year<=1960, group(3)

				tab libdem_extra_vdem_b_pre1965

				egen  libdem_extra_vdem_b_post1965= cut(libdem_extra_vdem) if dtax_non_trade_real!=.  & year>=1965, group(3)  

				tab libdem_extra_vdem_b_post1965
				
				
				replace libdem_extra_vdem_binned=libdem_extra_vdem_b_pre1965 if year<=1960  
				replace libdem_extra_vdem_binned=libdem_extra_vdem_b_post1965 if year>=1965  
				
					
	

* Bin resources (by period)
				gen P_ind_total_f_realshare_binned=.

					egen  P_resources_b_pre1965= cut(P_ind_total_f_realshare) if dtax_non_trade_real!=. & year<=1960, group(3)
					
					 tab P_resources_b_pre1965

					 
					
					  
					egen  P_resources_b_post1965= cut(P_ind_total_f_realshare) if dtax_non_trade_real!=.  & year>=1965, group(3)  

				   tab P_resources_b_post1965

					
					replace P_ind_total_f_realshare_binned=P_resources_b_pre1965 if year<=1960  
					replace P_ind_total_f_realshare_binned=P_resources_b_post1965 if year>=1965  
					
					
					
					 

 * Bin aid (by period)
				 
				  gen S_g5_unw_alliance_abs_binned=.
				  
					egen S_alliance_b_pre1965= cut(S_g5_unw_alliance_abs)  if dtax_non_trade_real!=. 	& 	year<=1960, group(3)
					
					tab S_alliance_b_pre1965
					
					egen S_alliance_b_post1965= cut(S_g5_unw_alliance_abs)  if dtax_non_trade_real!=. 	&  	year>=1965, group(3)

					tab S_alliance_b_post1965
					
					
					replace S_g5_unw_alliance_abs_binned=S_alliance_b_pre1965 	if year<=1960  
					replace S_g5_unw_alliance_abs_binned=S_alliance_b_post1965  if year>=1965  
				  
				  
				  
				  
  
  
 * Bin credit access by period  
					gen cr_market_accessXBOEinv_binned=.
		
		
					* group(4) will create three groups.
					egen cr_access_pre1965= cut(cr_market_accessXBOEinv) if dtax_non_trade_real!=. & year<=1960, group(4)
					
					 
	
					tab cr_access_pre1965 if dtax_non_trade_real!=. & year<=1960
	
					* recode
					replace cr_access_pre1965=cr_access_pre1965-1
				
					egen cr_access_post1965= cut(cr_market_accessXBOEinv) if dtax_non_trade_real!=. & year>=1965, group(3)  
			 
					tab cr_access_post1965
			 
 
					replace  cr_market_accessXBOEinv_binned=cr_access_pre1965 if year<=1960 
					replace  cr_market_accessXBOEinv_binned=cr_access_post1965 if year>=1965

	
  
  
  save "Temp/Master_5yr", replace

