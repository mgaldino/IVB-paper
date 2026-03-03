**********************************
* Data generation - Nomenclature *
**********************************



**** Define core & non-core sample 


			use "Data/Nomenclature/Nomenclature", clear
			 
			gen core_sample = 1
			 
			append using "Data/Nomenclature/Nomenclature_expand"

			sort iso year

			replace core_sample = 0 if core_sample == .

			
* add COW coding			
			merge m:1 iso using "Data/Nomenclature/iso_cow", nogen

			merge m:1 cow_num using "Data/Nomenclature/cow_states_2016"
			drop if _merge==2
			drop _merge

			
			
* Independence 	& coloniser coding 		
					sort iso year
					replace styear = 1890 if iso == "LBR"
					replace styear = 1931 if iso == "ZAF"

					gen indep = 1 if styear <= year
					replace indep = 1 if iso == "ETH" & year < 1936
					replace indep = 0 if indep == . 

					gen Britain_col = 1 if coloniser  == "UK  - FRN" | coloniser == "UK" | coloniser == "SA" |  iso == "EGY"
					replace Britain_col = 0 if Britain_col != 1

					gen France_col = 1 if coloniser  ==  "France - AEF" | coloniser  ==  "France - AOF" | coloniser  == "France"
					replace France_col = 0 if France_col != 1

					gen Portugal_col = 1 if coloniser == "Portugal"
					replace Portugal_col= 0 if Portugal_col != 1

					gen Belgium_col = 1 if coloniser == "Belgium"
					replace Belgium_col= 0 if Belgium_col != 1

					gen Italy_col = 1 if coloniser == "Italy"
					replace Italy_col= 0 if Italy_col != 1

					gen AOF_col = 1 if coloniser == "France - AOF"
					replace AOF_col = 0 if AOF_col != 1

					gen AEF_col = 1 if coloniser == "France - AEF"
					replace AEF_col = 0 if AEF_col != 1

					gen Germany_col = 1 if (iso == "TZA" | iso == "NAM" | iso == "TGO" | iso == "CMR" | iso == "RWA" | iso == "BDI" |iso == "TZA" | iso == "RWA" | iso == "BDI")   & year < 1916 
					replace Germany_col = 0 if Germany_col != 1

					gen mandate_col = 1 if (iso == "TZA"  & year >= 1922 & year < 1961 ) | (iso == "NAM" & year >= 1920 & year < 1966 ) | (iso == "TGO" & year >= 1920 & year < 1960 ) | (iso == "CMR"& year >= 1920 & year < 1960 ) | (iso == "RWA" & year >= 1922 & year < 1962) | (iso == "BDI" & year >= 1922 & year < 1962 )  | (iso == "SOM" & year >= 1950 & year < 1960 )
					replace mandate_col = 0 if mandate_col != 1

					
* Code socialists 					
					gen socialist = 0
					replace socialist = 1 if iso == "EGY" & year > 1954 & year < 1974 // Nasser's presidency to Sadat's infitāḥ
					replace socialist = 1 if iso == "GIN" & year > 1960 & year < 1978 // Sekou Toure's socialism
					replace socialist = 1 if iso == "MLI" & year > 1960 & year < 1968 // Modibo Keïta's rule
					replace socialist = 1 if iso == "TZA" & year > 1967 & year < 1985 // Nyerere's Ujaama 
					replace socialist = 1 if iso == "SOM" & year > 1969 & year < 1978 // Siad Barre's alignment with USSR
					replace socialist = 1 if iso == "DZA" & year > 1963 & year < 1987 // March Decrees to Bendjedid's liberalisation
					replace socialist = 1 if iso == "GHA" & year > 1964 & year < 1966 // Nkrumah's high tide
					replace socialist = 1 if iso == "SDN" & year > 1969 & year < 1971 // Revolutionary Command Council
					replace socialist = 1 if iso == "LBY" & year > 1978 & year < 1999 // Qadaffi's Jamahiriya
					replace socialist = 1 if iso == "COG" & year > 1969 & year < 1991 // People's Republic of the Congo
					replace socialist = 1 if iso == "MDG" & year > 1975 & year < 1992 // Democratic Republic of Madagascar
					replace socialist = 1 if iso == "GNB" & year > 1973 & year < 1991 // PAIGC
					replace socialist = 1 if iso == "ETH" & year > 1974 & year < 1991 //  DERG and People's Democratic Republic of Ethiopia 
					replace socialist = 1 if iso == "BEN" & year > 1975 & year < 1989 // People's Republic of Benin
					replace socialist = 1 if iso == "MOZ" & year > 1975 & year < 1989 //  People's Republic of Mozambique
					replace socialist = 1 if iso == "AGO" & year > 1975 & year < 1991 // People's Republic of Angola
					replace socialist = 1 if iso == "BFA" & year > 1983 & year < 1987 // Thomas Sankara's Burkinabe Revolution

					
* Code secessions 					

					gen secession = 0
					replace secession = 1 if iso == "ETH" & (year == 1991 | year ==1992 | year ==1993)
					replace secession = 1 if iso == "SDN" & (year == 2011)

* Code UN regions 					
					gen UN_North = 1 if iso == "DZA" | iso == "MOR" | iso == "TUN" | iso == "LBY" | iso == "EGY" | iso == "SDN"
					gen UN_East = 1 if iso == "BDI" | iso == "KEN" | iso == "MOZ" | iso == "MDG" | iso == "TZA" | iso == "DJI" | iso == "MWI" | iso == "RWA" | iso == "UGA" | iso == "ERI" | iso == "ZMB" | iso == "ETH" | iso == "SOM" | iso == "ZWE"
					gen UN_South = 1 if iso == "ZAF" | iso == "SWZ" | iso == "LSO" | iso == "BWA" | iso == "NAM"
					gen UN_Central = 1 if iso == "ANG" | iso == "CMR" | iso == "CAF" | iso == "TCD" | iso == "COD" | iso == "GNQ" | iso == "GAB" | iso == "COG" 
					gen UN_West = 1 if iso == "BEN" | iso == "GIN" | iso == "NGA" | iso == "BFA" | iso == "GNB" | iso == "LBR" | iso == "SEN" | iso == "CIV" | iso == "MLI" | iso == "SLE" | iso == "GMB" | iso == "MRT" | iso == "TGO" | iso == "GHA" | iso == "NER"

					replace UN_North = 0 if UN_North == .
					replace UN_East = 0 if UN_East == .
					replace UN_South = 0 if UN_South == .
					replace UN_Central = 0 if UN_Central == .
					replace UN_West = 0 if UN_West == .

* save data		
 save "Temp/Master", replace					
