


 *********************************************************************************************************
 ******************Step 3 	CODE FORCED LABOUR DAYS
 ********************************************************************************************************

***forced labour- lower bound

sort iso year

					*French
					*epolate to 1900-1946
					*keep North Africa at 0. Djibouti to French average
					bys iso: ipolate Forced_Labourdays_pc year, gen(forced_pc_lower) epolate
					bys iso: ipolate  Forced_Labourdays_pc year, gen(forced_pc_higher) epolate

					replace forced_pc_lower = 0 if year >= 1946
					replace forced_pc_higher = 0 if year >= 1946

					replace forced_pc_lower = 0 if forced_pc_lower <= 0
					replace forced_pc_higher = 0 if forced_pc_higher <= 0

					replace forced_pc_lower = 0 if year <= 1918 & iso == "TGO" 
					replace forced_pc_lower = 0 if year <= 1918 & iso == "CMR"

					replace forced_pc_higher = 0 if year <= 1918 & iso == "TGO" 
					replace forced_pc_higher = 0 if year <= 1918 & iso == "CMR"

					bys year: egen forced_pc_lower_mean = mean(forced_pc_lower)

					replace forced_pc_lower = forced_pc_lower_mean if iso == "DJI"

					replace forced_pc_lower = . if year >= 1938 & year <= 1945 & France_col == 1 
					bys iso: ipolate forced_pc_lower year if year >= 1937 & year <= 1946 & France_col == 1 , gen(forced_pc_lower_temp)
					replace forced_pc_lower = forced_pc_lower_temp if year >= 1937 & year <= 1946 & France_col == 1 
					drop forced_pc_lower_temp

					replace forced_pc_lower = 0 if iso == "DZA"
					replace forced_pc_lower = 0 if iso == "MAR"
					replace forced_pc_lower = 0 if iso == "TUN"

					*British 
					*Use French values as baseline (given migration British forced labour <= French)
					*Okia (2012) details decline at colony level after 1921 Churchill dispatch, disappeared at colony level by 1930
					*keep North Africa at 0
					replace forced_pc_lower = forced_pc_lower_mean if Britain_col ==1
					replace forced_pc_lower = . if year >= 1922 & year <= 1930 & Britain_col ==1
					replace forced_pc_lower = 0 if year == 1930 & Britain_col ==1
					bys iso: ipolate forced_pc_lower year if year >= 1921 &  year <= 1930 & Britain_col ==1, gen(forced_pc_lower_temp)
					replace forced_pc_lower =  forced_pc_lower_temp if year >= 1921 & year <= 1930 & Britain_col ==1
					replace forced_pc_lower = 0 if year >= 1930 & Britain_col ==1
					replace forced_pc_lower = 0 if iso == "EGY"
					drop forced_pc_lower_temp


					*Italian
					*Betizzolo & Pietrantonio (2004) * Libya = 0, pre-fascist = 0, thereafter average

					replace forced_pc_lower = forced_pc_lower_mean if year >= 1923 & Italy_col == 1
					replace forced_pc_lower = 0 if year >= 1946 & Italy_col == 1
					replace forced_pc_lower = 0 if year <= 1922 & Italy_col == 1
					replace forced_pc_lower = 0 if iso== "LBY"


					*Portuguese
					*Marlous van Waijenburg: 60 days
					*abolishment of indigenato in 1961 *assume decrease after labour reforms 1928 and ILO 1930 
					replace forced_pc_lower = 60*0.2 if Portugal_col == 1 & year <=1930
					replace forced_pc_lower = 0 if Portugal_col==1 & year >=1961
					replace forced_pc_lower = . if Portugal_col==1 & year >=1931 & year <= 1960
					bys iso: ipolate forced_pc_lower year if year >= 1930 & year <= 1961 & Portugal_col ==1, gen(forced_pc_lower_temp)
					replace forced_pc_lower = forced_pc_lower_temp if year >= 1930 & year <= 1961 & Portugal_col ==1 
					drop forced_pc_lower_temp


					*Belgian
					*Marlous van Waijenburg: 60 days
					*1910 new labour laws after transfer *male population David Northrup (1988)
					*RWA and BDI get DRC values after 1918
					replace forced_pc_lower = 60*0.2 if iso == "COD" & year <=1910
					replace forced_pc_lower = 0 if iso == "COD" & year >= 1946
					bys iso: ipolate forced_pc_lower year if year >= 1910 & year <= 1946 & iso == "COD", gen(forced_pc_lower_temp)
					replace forced_pc_lower = forced_pc_lower_temp if year >= 1910 & year <= 1946 &  iso == "COD"
					drop forced_pc_lower_temp

					gen forced_pc_lower_DRC = forced_pc_lower if iso == "COD"
					bys year: egen forced_pc_lower_DRCmean = mean(forced_pc_lower_DRC)  
					replace forced_pc_lower = forced_pc_lower_DRCmean if year >= 1919 & iso == "RWA"
					replace forced_pc_lower = forced_pc_lower_DRCmean if year >= 1919 & iso == "BDI"
					drop forced_pc_lower_DRC forced_pc_lower_DRCmean



					*German
							*use mean French values per year
								replace forced_pc_lower = forced_pc_lower_mean if year <= 1918 & iso == "RWA" 
								replace forced_pc_lower = forced_pc_lower_mean if year <= 1918 & iso == "BDI" 
								replace forced_pc_lower = forced_pc_lower_mean if year <= 1918 & iso == "TGO" 
								replace forced_pc_lower = forced_pc_lower_mean if year <= 1918 & iso == "CMR" 
								replace forced_pc_lower = forced_pc_lower_mean if year <= 1918 & iso == "TZA" 
								replace forced_pc_lower = forced_pc_lower_mean if year <= 1918 & iso == "NAM"


***Higher bound***

					* French
							* Reports from French colonies 30-60 days in 1913, 30-40 days 1935 (Marlous van Waijenburg)
							replace forced_pc_higher = 60*0.25 if France_col == 1 & AOF_col != 1 & AEF_col !=1 & year <= 1930
							replace forced_pc_higher = . if year >= 1931 & year <= 1945 & France_col == 1 & AOF_col != 1 & AEF_col !=1
							replace forced_pc_higher = 0 if year >= 1946 & France_col == 1 & AOF_col != 1 & AEF_col !=1
							bys iso: ipolate forced_pc_higher year if year >= 1930 & year <= 1946 & France_col == 1 & AOF_col != 1 & AEF_col !=1, gen(forced_pc_higher_temp)
							replace forced_pc_higher =  forced_pc_higher_temp if year >= 1930 & year <= 1946 & France_col == 1 & AOF_col != 1 & AEF_col !=1
							replace forced_pc_higher = 0 if iso == "MAR" |iso == "DZA" | iso == "TUN"
							drop forced_pc_higher_temp

							replace forced_pc_higher= . if year >= 1938 & year <= 1945 & (AOF_col == 1 | AEF_col == 1 )
							bys iso: ipolate forced_pc_higher year if year >= 1937 & year <= 1946 & (AOF_col == 1 | AEF_col == 1 ) , gen(forced_pc_higher_temp)
							replace forced_pc_higher= forced_pc_higher_temp if year >= 1937 & year <= 1946 & (AOF_col == 1 | AEF_col == 1 )
							drop forced_pc_higher_temp

							bys year: egen forced_pc_higher_mean = mean(forced_pc_higher)


					*British
							* Imperial maximum in Britain 60 days, some substitution afterwards by communal labour
							* Assume 60 until 1921 dispatch, then gradual change to 0 in 1946

							replace forced_pc_higher = 60*0.25 if Britain_col ==1 & year <= 1921
							replace forced_pc_higher = . if year >= 1922 & year <= 1945 & Britain_col ==1
							replace forced_pc_higher = 0 if year >= 1946 & Britain_col ==1
							bys iso: ipolate forced_pc_higher year if year >= 1921 & year <= 1946 & Britain_col ==1, gen(forced_pc_higher_temp)
							replace forced_pc_higher =  forced_pc_higher_temp if year >= 1921 & year <= 1946 & Britain_col ==1
							replace forced_pc_higher = 0 if iso == "EGY"
							drop forced_pc_higher_temp



					*Italian
							*Betizzolo & Pietrantonio (2004) * Libya = 0 pre-fascist, other pre-fascist = lower average, thereafter all 60 days
							replace forced_pc_higher = forced_pc_lower_mean if year <= 1922 & Italy_col == 1
							replace forced_pc_higher = 0 if year <= 1922 & iso == "LBY"
							replace forced_pc_higher = 60*0.25 if year >= 1923 & year <= 1945 & Italy_col == 1


					*Portuguese
							*Marlous van Waijenburg: 60 days
							*abolishment of indigenato in 1961  *whole population before labour reforms of 1928/1930 *after reforms 60 days maximum
							replace forced_pc_higher = 60*0.5 if Portugal_col & year <=1930
							replace forced_pc_higher = 0 if Portugal_col== 3 & year >=1961
							replace forced_pc_higher = 60*0.25 if Portugal_col == 3 & year ==1931

							replace forced_pc_higher = . if year >= 1931 & year <= 1960 & Portugal_col ==1
							bys iso: ipolate forced_pc_higher year if year >= 1930 & year <= 1961 & Portugal_col ==1, gen(forced_pc_higher_temp)
							replace forced_pc_higher = forced_pc_higher_temp if year >= 1930 & year <= 1961 & Portugal_col ==1 
							drop forced_pc_higher_temp



					*Belgian
							*Use 300 days as physical maximum
							*1910 new labour laws after transfer *male population David Northrup (1988)
							*RWA and BDI get DRC values after 1918, but decline after ILO convention (trust / mandate territories)
							replace forced_pc_higher = 300*0.25 if iso == "COD" & year <=1910
							replace forced_pc_higher = 0 if iso == "COD" & year >= 1946
							replace forced_pc_higher = 60*0.25 if year >= 1910 & year <= 1945 & iso == "COD"

							replace forced_pc_higher = 60*0.25 if year >= 1919 & year <= 1930 & iso == "RWA"
							replace forced_pc_higher = 60*0.25 if year >= 1919 & year <= 1930 & iso == "BDI"

							replace forced_pc_higher = 0 if iso == "RWA" & year >= 1946
							replace forced_pc_higher = 0 if iso == "BDI" & year >= 1946

							replace forced_pc_higher = . if iso == "RWA" & year >= 1931 & year <= 1945
							bys iso: ipolate forced_pc_higher year if year >= 1930 & year <= 1946 & iso == "RWA", gen(forced_pc_higher_temp)
							replace forced_pc_higher = forced_pc_higher_temp if  year >= 1930 & year <= 1946 & iso == "RWA"
							drop forced_pc_higher_temp
							replace forced_pc_higher = . if iso == "BDI" & year >= 1931 & year <= 1945
							bys iso: ipolate forced_pc_higher year if year >= 1930 & year <= 1946 & iso == "BDI", gen(forced_pc_higher_temp)
							replace forced_pc_higher = forced_pc_higher_temp if  year >= 1930 & year <= 1946 & iso == "BDI"
							drop forced_pc_higher_temp


					*German 
							*use French high average

							replace forced_pc_higher = 60*0.25 if year <= 1918 & iso == "RWA" 
							replace forced_pc_higher = 60*0.25 if year <= 1918 & iso == "BDI" 
							replace forced_pc_higher = 60*0.25 if year <= 1918 & iso == "TGO" 
							replace forced_pc_higher = 60*0.25 if year <= 1918 & iso == "CMR" 
							replace forced_pc_higher = 60*0.25 if year <= 1918 & iso == "TZA" 
							replace forced_pc_higher = 60*0.25 if year <= 1918 & iso == "NAM"

							

							
*** generate fiscal variables of interest and save							
							
					replace forced_pc_lower = 0 if forced_pc_lower == .
					replace forced_pc_higher = 0 if forced_pc_higher == .

					gen total_forced_low = ordinary_real + forced_pc_lower
					gen total_forced_high = ordinary_real + forced_pc_higher

					gen taxnotrade_forced_low = tax_non_trade_real + forced_pc_lower
					gen taxnotrade_forced_high = tax_non_trade_real + forced_pc_higher
					 
					 
 
 
					* save data		
					 save "Temp/Master", replace
