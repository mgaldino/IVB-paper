
 
 
 ****************************************************************************************************************************
 ******************Step 4b TIME VARYING DETERMINANTS: 	GDP DYNAMICS  
 ****************************************************************************************************************************

 *Real GDP (G-K $)
					use "Data/GDP/rGDP_Mad_PdlE.dta", clear

					 label variable year "year"

					renvarlab * , label 

					rename * gdp*
					rename gdpyear year

					reshape  long gdp, i(year) j(iso) string

					replace gdp = . if year != 1890 & year != 1900 & year != 1913 & year != 1925 & year != 1929 & year != 1933 & year != 1938 & year != 1950 & year != 1960 & year != 1973 & year != 1979 & year != 1990 & year != 2001 & year != 2008
					sort iso year
					bys iso: ipolate gdp year, gen(rgdp_PdlE_pc)

					save "TEMP/rGDP_Mad_PdlE_1.dta", replace


					use "Data/GDP/rGDP_Mad_Jerven.dta", clear

					 label variable year "year"

					renvarlab * , label 

					rename * gdp*
					rename gdpyear year

					reshape  long gdp, i(year) j(iso) string

					sort iso year
					bys iso: ipolate gdp year, gen(rgdp_Jerven_pc)

					save "TEMP/rGDP_Mad_Jerven_1.dta", replace

					use "Temp/Master", clear

					merge 1:1 iso year using "TEMP/rGDP_Mad_PdlE_1.dta", keepusing(rgdp_PdlE_pc)
					drop if _merge == 2
					drop _merge

					merge 1:1 iso year using "TEMP/rGDP_Mad_Jerven_1.dta", keepusing(rgdp_Jerven_pc)
					drop if _merge == 2
					drop _merge

					merge 1:1 iso year using "Data/GDP/rGDP_Mad_2018.dta", keepusing(rgdpnapc) // pre-1950 not matched
					drop if _merge == 2
					drop _merge

					rename rgdpnapc rgdp_mad_pc
					gen rgdp_PdlE = rgdp_PdlE_pc* POPULATION
					gen rgdp_Jerven = rgdp_Jerven_pc * POPULATION
					gen rgdp_mad = rgdp_mad_pc * POPULATION
					gen rgdp_temp = rgdp_mad 
					replace rgdp_temp = . if year != 2007 & year != 2015
					bys iso: ipolate rgdp_temp year, gen (rgdp_temp2)

					sort  iso_n year
					bys iso_n: gen g_gdp_dec = (rgdp_PdlE - l1.rgdp_PdlE ) / l1.rgdp_PdlE 
					bys iso_n: gen g_gdp_yoy = (rgdp_Jerven- l1.rgdp_Jerven ) / l1.rgdp_Jerven
					bys iso_n: gen g_gdp_mad_dec = (rgdp_temp2 - l1.rgdp_temp2  ) / l1.rgdp_temp2
					bys iso_n : gen g_gdp_mad_yoy = (rgdp_mad  - l1.rgdp_mad  ) / l1.rgdp_mad 

					replace g_gdp_dec = g_gdp_mad_dec if year > 2007
					replace g_gdp_yoy = g_gdp_mad_yoy if year > 2007

					drop rgdp_temp g_gdp_mad_yoy g_gdp_mad_dec rgdp_temp2 rgdp_PdlE_pc rgdp_Jerven_pc rgdp_mad_pc

*Nominal GDP: $, LCU, historical, fiscal

					merge 1:1 iso year using "Data/GDP/nGDP_current_historical.dta"
					drop if _merge ==2
					drop _merge

					merge 1:1 iso year using "Data/GDP/nGDP_fiscal.dta"
					drop if _merge ==2
					drop _merge

					replace gdp_fiscal_lcu = . if gdp_fiscal_lcu == 0
					replace gdp_fiscal_lcu = . if iso == "ZWE" & year <2005
					replace gdp_historical_lcu = . if gdp_historical_lcu == 0
					replace gdp_historical_lcu = . if iso == "ZWE" & year <2005

					gen tax_non_trade_pcGDP = (DIRECT_NOMINAL + INDIRECT_EXCL_TR_NOMINAL)/ gdp_fiscal_lcu
					gen ordinary_pcGDP =  (INDIRECT_NOMINAL + DIRECT_NOMINAL + NONTAX_ORDINARY_NOMINAL + RESOURCES_NOMINAL) / gdp_fiscal_lcu
					gen extraordinary_pcGDP = (EXTRAORDINARY_NOMINAL)  /  gdp_fiscal_lcu


* save data		
 save "Temp/Master", replace					
