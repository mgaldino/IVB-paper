
 
  ****************************************************************************************************************************
 ******************Step 10 	Resources
 *************************************************************************************************************************
 
 *categorise 1960 goods categories to 1938 categorisation

									use "Data/Resources/Volumes_1960.dta", clear

									foreach var of varlist g_* {
									replace `var' = 0 if `var' == .
									}

									replace g_83 = g_83 + g_192
									replace g_83 = g_83 + g_193
									replace g_180 = g_180 + g_194
									replace g_92 = g_92 + g_195
									replace g_185 = g_185 + g_196
									replace g_83 = g_83 + g_197
									replace g_93 = g_93 + g_200
									replace g_29 = g_29 + g_201
									replace g_27 = g_27 + g_202
									replace g_93 = g_93 + g_205
									replace g_116 = g_116 + g_207
									replace g_19 = g_19 + g_208
									replace g_140 = g_140 + g_209
									replace g_19 = g_19 + g_210
									replace g_19 = g_19 + g_211
									replace g_27 = g_27 + g_212
									replace g_27 = g_27 + g_214
									replace g_27 = g_27 + g_215
									replace g_83 = g_83 + g_216
									replace g_83 = g_83 + g_217
									replace g_83 = g_83 + g_218
									replace g_93 = g_93 + g_219
									replace g_93 = g_93 + g_220
									replace g_73 = g_73 + g_221
									replace g_68 = g_68 + g_222
									replace g_68 = g_68 + g_223
									replace g_9 = g_9 + g_224
									replace g_9 = g_9 + g_225
									replace g_8 = g_8 + g_228
									replace g_9 = g_9 + g_229
									replace g_9 = g_9 + g_230
									replace g_115 = g_115 + g_231
									replace g_40 = g_40 + g_232
									replace g_40 = g_40 + g_233
									replace g_57 = g_57 + g_234
									replace g_8 = g_8 + g_235
									replace g_8 = g_8 + g_236
									replace g_8 = g_8 + g_237
									replace g_56 = g_56 + g_238
									replace g_93 = g_93 + g_239
									replace g_93 = g_93 + g_240
									replace g_29 = g_29 + g_241
									replace g_67 = g_67 + g_243
									replace g_125 = g_125 + g_245
									replace g_11 = g_11 + g_247
									replace g_73 = g_73 + g_248
									replace g_73 = g_73 + g_249
									replace g_93 = g_93 + g_250
									replace g_34 = g_34 + g_252
									replace g_93 = g_93 + g_250
									replace g_93 = g_93 + g_255

									drop g_192-g_197
									drop g_199-g_258

									replace g_3 = g_3 + g_4 + g_85 + g_41+ g_136 + g_13 + g_43 //palm oils = palm kernels, palm almonds
									replace g_2 = g_2 + g_162 // copra
									replace g_8 = g_8 + g_87 + g_121 + g_156 + g_157 + g_110 // woods
									replace g_10 = g_10 + g_103 // Gold
									replace g_11 = g_11 + g_20 + g_46 + g_59 //arachides, peanuts, groundnuts
									replace g_14 = g_14 + g_64 // decorative wood
									replace g_140 = g_140 + g_12 + g_18 + g_25 + g_31 + g_102 + g_163 // hides and skins
									replace g_16 = g_16 + g_28 + g_63 //gums
									replace g_19 = g_19 + g_134 // wool
									replace g_24 = g_24 + g_49 // banana
									replace g_26 = g_26 + g_155 + g_167 // sesame
									replace g_27 = g_27 + g_38 + g_79 + g_164 + g_166 // fish
									replace g_29 = g_29 + g_113 + g_152 // sisal
									replace g_34 = g_34 + g_144 + g_151 // tobocco
									replace g_36 = g_36 + g_150 + g_81 // ivory
									replace g_51 = g_51 + g_147 + g_175 + g_182 // cereals, wheat
									replace g_56 = g_56 + g_158 // tin
									replace g_57 = g_57 + g_15  + g_32 +  g_127 + g_141 + g_142 // cotton
									replace g_66 = g_66 + g_82 + g_154 // maize
									replace g_69 = g_69 + g_191 // feathers
									replace g_70 = g_70 + g_186 // bark
									replace g_71 = g_71 + g_168 // sugar
									replace g_73 = g_73 + g_72 // copper
									replace g_77 = g_77 + g_17 + g_35 + g_65 + g_42 + g_44 + g_45 + g_47 + g_48 + g_145 + g_146 // live cattle
									replace g_83 = g_83 + g_88 + g_174 + g_172 // fruits
									replace g_93 = g_93 + g_74 + g_75 + g_159 // metals
									replace g_115 = g_115 + g_159 + g_78 // meat
									replace g_116 = g_116 + g_129 + g_135 + g_148 + g_153 + g_176 // vegetables
									replace g_125 = g_125 + g_114 + g_160 // butter
									replace g_137 = g_137 + g_5 // cocoa
									replace g_165 = g_165 + g_120 + g_183 // flour
									replace g_187 = g_187 + g_119+ g_184 //wine
									replace g_188 = g_188 + g_61 + g_50 + g_189 //spices


									keep iso g_1 g_2 g_3  g_6 g_7 g_8 g_9 g_10 g_11 g_14 g_16 g_19 g_24 g_26 g_27 g_29  g_34 g_36 g_40 g_51 g_52 g_56 g_57 g_58 g_62 g_66 g_67 g_68 g_69 g_70 g_71 g_73 g_76 g_77 g_83 g_92 g_93 g_115 g_116 g_125 g_126 g_137 g_140 g_165 g_179 g_180 g_185 g_187 g_188 g_198 


									gen year = 1960
									replace iso = "BDI" if iso == "BRD"

									save "TEMP/Volumes_1960_1.dta", replace

 *unified 1938, 1928 and 1913 categorisations

								use "Data/Resources/Volumes_1938.dta", clear

								gen g_191 = 0
								gen g_198 = 0

								*AEF 1938 values
								replace g_57 = 676288.7 if iso == "GAB" | iso == "COG" | iso == "TCD" | iso == "CAF"
								replace g_58 = 13845.79 if iso == "GAB" | iso == "COG" | iso == "TCD" | iso == "CAF"
								replace g_3 = 214089.3 if iso == "GAB" | iso == "COG" | iso == "TCD" | iso == "CAF"
								replace g_40 = 6514 if iso == "GAB" | iso == "COG" | iso == "TCD" | iso == "CAF"
								replace g_137 = 25598.97 if iso == "GAB" | iso == "COG" | iso == "TCD" | iso == "CAF"
								replace g_77 = 112453 if iso == "GAB" | iso == "COG" | iso == "TCD" | iso == "CAF"

								*Ethiopia for 1938 (post-war values)
								replace g_40 = 47.6 if iso == "ETH"
								replace g_140 = 22.4 if iso == "ETH"
								replace g_147 = 10.4 if iso == "ETH"
								replace g_20 = 9.8 if iso == "ETH"

								*Botswana 1938 values (Annual Report on the Social and Economic Progress of the People of BECHUANALAND PROTECTORATE, 1938 )
								replace g_77 = 186000 if iso == "BWA"
								replace g_125 = 27000 if iso == "BWA"
								replace g_10 = 133000 if iso == "BWA"
								replace g_140 = 20000 if iso == "BWA"

								*Stateman's Yearbook 1940 - Liberia 1938 values
								replace g_7 = 1099 if iso == "LBR" 
								replace g_3 = 462 if iso == "LBR"
								replace g_29 = 176 if iso == "LBR"
								replace g_40 = 192 if iso == "LBR"
								replace g_137 = 37 if iso == "LBR"


								foreach var of varlist g_* {
								replace `var' = 0 if `var' == .
								}

								replace g_3 = g_3 + g_4 + g_85 + g_41+ g_136 + g_13 + g_43 //palm oils = palm kernels, palm almonds
								replace g_2 = g_2 + g_162 // copra
								replace g_8 = g_8 + g_87 + g_121 + g_156 + g_157 + g_110 // woods
								replace g_10 = g_10 + g_103 // Gold
								replace g_11 = g_11 + g_20 + g_46 + g_59 //arachides, peanuts, groundnuts
								replace g_14 = g_14 + g_64 // decorative wood
								replace g_140 = g_140 + g_12 + g_18 + g_25 + g_31 + g_102 + g_163 // hides and skins
								replace g_16 = g_16 + g_28 + g_63 //gums
								replace g_19 = g_19 + g_134 // wool
								replace g_24 = g_24 + g_49 // banana
								replace g_26 = g_26 + g_155 + g_167 // sesame
								replace g_27 = g_27 + g_38 + g_79 + g_164 + g_166 // fish
								replace g_29 = g_29 + g_113 + g_152 // sisal
								replace g_34 = g_34 + g_144 + g_151 // tobocco
								replace g_36 = g_36 + g_150 + g_81 // ivory
								replace g_51 = g_51 + g_147 + g_175 + g_182 // cereals, wheat
								replace g_56 = g_56 + g_158 // tin
								replace g_57 = g_57 + g_15  + g_32 +  g_127 + g_141 + g_142 // cotton
								replace g_66 = g_66 + g_82 + g_154 // maize
								replace g_69 = g_69 + g_191 // feathers
								replace g_70 = g_70 + g_186 // bark
								replace g_71 = g_71 + g_168 // sugar
								replace g_73 = g_73 + g_72 // copper
								replace g_77 = g_77 + g_17 + g_35 + g_65 + g_42 + g_44 + g_45 + g_47 + g_48 + g_145 + g_146 // live cattle
								replace g_83 = g_83 + g_88 + g_174 + g_172 // fruits
								replace g_93 = g_93 + g_74 + g_75 + g_159 // metals
								replace g_115 = g_115 + g_159 + g_78 // meat
								replace g_116 = g_116 + g_129 + g_135 + g_148 + g_153 + g_176 // vegetables
								replace g_125 = g_125 + g_114 + g_160 // butter
								replace g_137 = g_137 + g_5 // cocoa
								replace g_165 = g_165 + g_120 + g_183 // flour
								replace g_187 = g_187 + g_119+ g_184 //wine
								replace g_188 = g_188 + g_61 + g_50 + g_189 //spices

								keep iso g_1 g_2 g_3  g_6 g_7 g_8 g_9 g_10 g_11  g_14 g_16 g_19 g_24 g_26 g_27 g_29  g_34 g_36 g_40 g_51 g_52 g_56 g_57 g_58 g_62 g_66 g_67 g_68 g_69 g_70 g_71 g_73 g_76 g_77 g_83 g_92 g_93 g_115 g_116 g_125 g_126 g_137 g_140 g_165 g_179 g_180 g_185 g_187 g_188 g_198

								gen year = 1938
								replace iso = "BDI" if iso == "BRD"

								save "TEMP/Volumes_1938_1.dta", replace 

								use "Data/Resources/Volumes_1928.dta", clear

								gen g_198 = 0

								*Swaziland 1928 values (Stateman's Yearbook 1930)
								replace g_77 = 54594 if iso == "SWZ"
								replace g_56 = 39706 if iso == "SWZ"
								replace g_34 = 37428 if iso == "SWZ"
								replace g_140 = 13047 if iso == "SWZ"
								replace g_57 = 13785 if iso == "SWZ"
								replace g_70 = 4920 if iso == "SWZ"

								*Botswana 1928 values (Technical Bulletin, Issues 451-475)
								replace g_77 = 235430 if iso == "BWA"
								replace g_125 = 36000 if iso == "BWA"
								replace g_10 = 7330 if iso == "BWA"
								replace g_126 = 14 if iso == "BWA"

								*Replace Guinee Bissau volume with values
								replace g_7 = 4762 if iso == "GNB"
								replace g_11 = 438925 if iso == "GNB"
								replace g_3 = 198451 if iso == "GNB"
								replace g_140 = 37485 if iso == "GNB"


								foreach var of varlist g_* {
								replace `var' = 0 if `var' == .
								}

								replace g_3 = g_3 + g_4 + g_85 + g_41+ g_136 + g_13 + g_43 //palm oils = palm kernels, palm almonds
								replace g_2 = g_2 + g_162 // copra
								replace g_8 = g_8 + g_87 + g_121 + g_156 + g_157 + g_110 // woods
								replace g_10 = g_10 + g_103 // Gold
								replace g_11 = g_11 + g_20 + g_46 + g_59 //arachides, peanuts, groundnuts
								replace g_14 = g_14 + g_64 // decorative wood
								replace g_140 = g_140 + g_12 + g_18 + g_25 + g_31 + g_102 + g_163 // hides and skins
								replace g_16 = g_16 + g_28 + g_63 //gums
								replace g_19 = g_19 + g_134 // wool
								replace g_24 = g_24 + g_49 // banana
								replace g_26 = g_26 + g_155 + g_167 // sesame
								replace g_27 = g_27 + g_38 + g_79 + g_164 + g_166 // fish
								replace g_29 = g_29 + g_113 + g_152 // sisal
								replace g_34 = g_34 + g_144 + g_151 // tobocco
								replace g_36 = g_36 + g_150 + g_81 // ivory
								replace g_51 = g_51 + g_147 + g_175 + g_182 // cereals, wheat
								replace g_56 = g_56 + g_158 // tin
								replace g_57 = g_57 + g_15  + g_32 +  g_127 + g_141 + g_142 // cotton
								replace g_66 = g_66 + g_82 + g_154 // maize
								replace g_69 = g_69 + g_191 // feathers
								replace g_70 = g_70 + g_186 // bark
								replace g_71 = g_71 + g_168 // sugar
								replace g_73 = g_73 + g_72 // copper
								replace g_77 = g_77 + g_17 + g_35 + g_65 + g_42 + g_44 + g_45 + g_47 + g_48 + g_145 + g_146 // live cattle
								replace g_83 = g_83 + g_88 + g_174 + g_172 // fruits
								replace g_93 = g_93 + g_74 + g_75 + g_159 // metals
								replace g_115 = g_115 + g_159 + g_78 // meat
								replace g_116 = g_116 + g_129 + g_135 + g_148 + g_153 + g_176 // vegetables
								replace g_125 = g_125 + g_114 + g_160 // butter
								replace g_137 = g_137 + g_5 // cocoa
								replace g_165 = g_165 + g_120 + g_183 // flour
								replace g_187 = g_187 + g_119 + g_184 //wine
								replace g_188 = g_188 + g_61 + g_50 + g_189 //spices

								keep iso g_1 g_2 g_3  g_6 g_7 g_8 g_9 g_10 g_11  g_14 g_16 g_19 g_24 g_26 g_27 g_29  g_34 g_36 g_40 g_51 g_52 g_56 g_57 g_58 g_62 g_66 g_67 g_68 g_69 g_70 g_71 g_73 g_76 g_77 g_83 g_92 g_93 g_115 g_116 g_125 g_126 g_137 g_140 g_165 g_179 g_180 g_185 g_187 g_188 g_198

								replace iso = "BDI" if iso == "BRD"
								gen year = 1928

								save "TEMP/Volumes_1928_1.dta", replace 


								use "Data/Resources/Volumes_1913.dta", clear

								gen g_182 = 0
								gen g_183 = 0
								gen g_184 = 0
								gen g_185 = 0
								gen g_186 = 0
								gen g_187 = 0
								gen g_188 = 0
								gen g_189 = 0
								gen g_190 = 0
								gen g_191 = 0
								gen g_198 = 0

								*Angola for 1906 (Imperial Network and External Dependency: The Case of Angola, Issue 11)
								replace g_7 = 69 if iso == "AGO"
								replace g_40 = 10 if iso == "AGO"
								replace g_23 = 12 if iso == "AGO"
								replace g_27 = 6 if iso == "AGO" 


								foreach var of varlist g_* {
								replace `var' = 0 if `var' == .
								}

								replace g_3 = g_3 + g_4 + g_85 + g_41+ g_136 + g_13 + g_43 //palm oils = palm kernels, palm almonds
								replace g_2 = g_2 + g_162 // copra
								replace g_8 = g_8 + g_87 + g_121 + g_156 + g_157 + g_110 // woods
								replace g_10 = g_10 + g_103 // Gold
								replace g_11 = g_11 + g_20 + g_46 + g_59 //arachides, peanuts, groundnuts
								replace g_14 = g_14 + g_64 // decorative wood
								replace g_140 = g_140 + g_12 + g_18 + g_25 + g_31 + g_102 + g_163 // hides and skins
								replace g_16 = g_16 + g_28 + g_63 //gums
								replace g_19 = g_19 + g_134 // wool
								replace g_24 = g_24 + g_49 // banana
								replace g_26 = g_26 + g_155 + g_167 // sesame
								replace g_27 = g_27 + g_38 + g_79 + g_164 + g_166 // fish
								replace g_29 = g_29 + g_113 + g_152 // sisal
								replace g_34 = g_34 + g_144 + g_151 // tobocco
								replace g_36 = g_36 + g_150 + g_81 // ivory
								replace g_51 = g_51 + g_147 + g_175 + g_182 // cereals, wheat
								replace g_56 = g_56 + g_158 // tin
								replace g_57 = g_57 + g_15  + g_32 +  g_127 + g_141 + g_142 // cotton
								replace g_66 = g_66 + g_82 + g_154 // maize
								replace g_69 = g_69 + g_191 // feathers
								replace g_70 = g_70 + g_186 // bark
								replace g_71 = g_71 + g_168 // sugar
								replace g_73 = g_73 + g_72 // copper
								replace g_77 = g_77 + g_17 + g_35 + g_65 + g_42 + g_44 + g_45 + g_47 + g_48 + g_145 + g_146 // live cattle
								replace g_83 = g_83 + g_88 + g_174 + g_172 // fruits
								replace g_93 = g_93 + g_74 + g_75 + g_159 // metals
								replace g_115 = g_115 + g_159 + g_78 // meat
								replace g_116 = g_116 + g_129 + g_135 + g_148 + g_153 + g_176 // vegetables
								replace g_125 = g_125 + g_114 + g_160 // butter
								replace g_137 = g_137 + g_5 // cocoa
								replace g_165 = g_165 + g_120 + g_183 // flour
								replace g_187 = g_187 + g_119 + g_184 //wine
								replace g_188 = g_188 + g_61 + g_50 + g_189 //spices

								keep iso g_1 g_2 g_3  g_6 g_7 g_8 g_9 g_10 g_11 g_14 g_16 g_19 g_24 g_26 g_27 g_29  g_34 g_36 g_40 g_51 g_52 g_56 g_57 g_58 g_62 g_66 g_67 g_68 g_69 g_70 g_71 g_73 g_76 g_77 g_83 g_92 g_93 g_115 g_116 g_125 g_126 g_137 g_140 g_165 g_179 g_180 g_185 g_187 g_188 g_198 

								replace iso = "BDI" if iso == "BRD"
								gen year = 1913

								save "TEMP/Volumes_1913_1.dta", replace 

								
								
								
								**** insheet all
								use "Temp/Master", clear

								merge 1:1 iso year using "TEMP/Volumes_1913_1.dta"
								drop if _merge ==2
								drop _merge
								 
								merge 1:1 iso year using "TEMP/Volumes_1928_1.dta",  update
								drop if _merge ==2
								drop _merge

								merge 1:1 iso year using "TEMP/Volumes_1938_1.dta",  update
								drop if _merge ==2
								drop _merge

								merge 1:1 iso year using "TEMP/Volumes_1960_1.dta",  update
								drop if _merge ==2
								drop _merge
 
 *create export shares from calculated total

								egen export_totals = rowtotal(g_1-g_198)

								foreach myvar of varlist  g_1-g_198{
								  gen `myvar'_s = `myvar' / export_totals
								}

								drop g_1-g_198


 * inter and extrapolate missings
								 
								 * extrapolate missing 1913 with 1928 values
								 
								 sort iso year
								 
								 foreach myvar of varlist  g_1_s-g_198_s{
								  bys iso: replace `myvar' = `myvar'[_n+15] if year == 1913 & `myvar' == .
								}
								 
								  * extrapolate missing 1960 with 1938 values
								 
								 sort iso year
								 
								 foreach myvar of varlist  g_1_s-g_198_s{
								  bys iso: replace `myvar' = `myvar'[_n-22] if year == 1960 & `myvar' == .
								}
								 
								 * interpolate, extrapolate and lag shares 
								 
								 foreach myvar of varlist  g_1_s-g_198_s{
								  bys iso_n (year): gen `myvar'_temp = l1.`myvar'
								  replace `myvar' = `myvar'_temp
								  drop `myvar'_temp
								}
								 
								  foreach myvar of varlist  g_1_s-g_198_s{
								  bys iso: ipolate `myvar' year, gen(`myvar'_i ) 
								}
								 
								 forvalues i = 1/24 {
								foreach var of varlist g_1_s_i-g_198_s_i {
								bysort iso : replace `var' = `var'[_n+1] if `var' == . & year <1914
								}
								}

								save "Temp/Master", replace

								
								
								
								
**** load resource prices 
															
							use "Data/Resources/Prices_1900-1957.dta", clear 

							 foreach myvar of varlist  P_1-P_198{
							  ipolate `myvar' year, gen(`myvar'_x) epolate
							  replace `myvar'_x = . if `myvar' == . & year > 1950
							  replace `myvar'_x = . if `myvar' == . & year < 1900
							  replace `myvar'_x = 0 if `myvar'_x <= 0
							}

							drop P_1-P_198
							rename *_x *

							save "TEMP/Prices_1900-1957_1.dta", replace

							
							
							
							
**** calculate price indices

							sleep 1000
							use "Temp/Master", clear

							merge m:1 year using "TEMP/Prices_1900-1957_1.dta", nogen

							sort iso year

							  foreach myvar of varlist  P_1-P_198{
							  bys iso: gen `myvar'_b =  `myvar'[24]
							}

							  foreach myvar of varlist  P_1-P_198{
							  bys iso: replace `myvar' = (`myvar' / `myvar'_b )*100
							  drop `myvar'_b
							}

							rename g_*_s_i P_*_s_i 

							 foreach myvar of varlist  P_1-P_198{
							  bys iso: gen `myvar'_w_i =  `myvar' * `myvar'_s_i 
							}
							 
							egen P_ind_col_i = rowtotal(P_1_w_i-P_198_w_i)
							replace P_ind_col_i = . if P_ind_col_i == 0
							egen P_point_col_i = rowtotal(P_6_w_i P_9_w_i P_10_w_i P_56_w_i P_67_w_i P_68_w_i P_73_w_i P_92_w_i P_93_w_i P_126_w_i P_180_w_i P_198_w_i)

							bys iso (year): gen P_ind_col_b = P_ind_col_i[68] // rebase to 1957
							replace P_ind_col_i = (P_ind_col_i/ P_ind_col_b )*100
							drop P_ind_col_b

							bys iso (year): gen P_point_col_b = P_point_col_i[68] // rebase to 1957
							replace P_point_col_i = (P_point_col_i/ P_point_col_b )*100
							drop P_point_col_b

							drop g_1_s-g_198_s
							drop P_1_w_i-P_198_w_i

							*fixed weights 

							foreach myvar of varlist  P_1_s_i-P_198_s_i{
							  bys iso: egen `myvar'_s_f =  mean(`myvar')
							}

							rename P_*_s_i_s_f P_*_s_f

							foreach myvar of varlist  P_1-P_198{
							  bys iso: gen `myvar'_w_f =  `myvar' * `myvar'_s_f 
							}

							egen P_ind_col_f = rowtotal(P_1_w_f-P_198_w_f)
							replace P_ind_col_f = . if P_ind_col_f == 0

							bys iso (year): gen P_ind_col_b = P_ind_col_f[68] // rebase to 1957
							replace P_ind_col_f = (P_ind_col_f/ P_ind_col_b )*100
							drop P_ind_col_b P_1_s_f-P_198_s_f P_1_w_f-P_198_w_f

							*point-source resources vs distributed resources
							sort iso year
							egen point_resource_s = rowtotal(P_6_s_i P_9_s_i P_10_s_i P_56_s_i P_67_s_i P_68_s_i P_73_s_i P_92_s_i P_93_s_i P_126_s_i P_180_s_i P_198_s_i)
							replace point_resource_s = . if P_ind_col_i == .
							gen oil_resource_col_s = P_198_s_i 

							bys iso (year): gen uk_rpi_b =  uk_rpi[68]
							replace uk_rpi = (uk_rpi  / uk_rpi_b )*100
							drop uk_rpi_b
							gen P_ind_col_i_real = (P_ind_col_i  / uk_rpi)*100
							gen P_point_col_i_real = (P_point_col_i  / uk_rpi)*100
							gen P_ind_col_f_real = (P_ind_col_f  / uk_rpi)*100

							* Post-1957 data from Bazzi & Blattman*
							merge 1:1 iso year using "Data/Resources/Volumes_1957-2007.dta", keepusing(exp ippx iw_* ishr_world_*) // all African countries merged 1957-2007
							drop if _merge ==2
							drop _merge

							rename exp exp_total_BB
							rename ippx exp_com_BB
							rename ishr_world_* ishr_world_*_BB


							 foreach myvar of varlist  iw_*{
							  bys iso_n (year): gen `myvar'_l1  =  l1.`myvar'
							  replace `myvar'_l1 = `myvar' if year == 1957
							}

							rename iw_*_l1 p_*_BB_l_i
							drop iw_*

							 foreach myvar of varlist  p_*_BB_l_i{
							  bys iso: replace `myvar'  =  `myvar'[_n-1] if year > 1957 & `myvar' == .
							}

							save "Temp/Master", replace

							*prepare and merge in post-2007 prices

							use "Data/Resources/Prices_2007-2015_monthly.dta", clear
							collapse(mean) p*, by(year)

							gen p3 = p48
							gen p4 = p55
							gen p8 = p27
							gen p13 = p12
							gen p14 = p15
							gen p26 = p2
							gen p32 = p2
							gen p40 = p54
							gen p41 = p54
							gen p51 = p55
							gen p57 = p33
							gen p59 = p55

							merge 1:1 year using "Data/Resources/Prices_2007-2015_annual.dta", nogen

							 foreach myvar of varlist  p*{
							  gen `myvar'_b  =  `myvar'[1] 
							  replace `myvar' = (`myvar'/ `myvar'_b)*100
							  drop `myvar'_b
							} // rebase to 2007

							save "TEMP/Prices_2007-2015", replace

							use "Data/Resources/Prices_1957-2007.dta", clear
							 foreach myvar of varlist  p*{
							  gen `myvar'_b  =  `myvar'[51] 
							  replace `myvar' = (`myvar'/ `myvar'_b)*100
							  drop `myvar'_b
							} // rebase to 2007

							append using "TEMP/Prices_2007-2015"
							drop in 52

							save "TEMP/Prices_1957-2015.dta", replace

							sleep 1000
							use "Temp/Master", clear

							merge m:1 year using "TEMP/Prices_1957-2015.dta", nogen
							sort iso year

							*price renaming from B&B code
							ren p1 p_alum_BB 
							ren p2 p_banana_BB 
							ren p3 p_barley_BB
							ren p4 p_beef_BB
							ren p5 p_dairy_BB
							ren p6 p_coal_BB
							ren p7 p_cocoa_BB 
							ren p8 p_coc_oil_BB 
							ren p9 p_coffee_BB
							ren p10 p_copper_BB
							ren p11 p_cotton_BB 
							ren p12 p_fish_BB
							ren p13 p_fishml_BB 
							ren p14 p_g_oil_BB 
							ren p15 p_gnut_BB 
							ren p16 p_hide_BB 
							ren p17 p_iron_BB
							ren p18 p_jute_BB
							ren p19 p_lamb_BB
							ren p20 p_lead_BB 
							ren p21 p_linoil_BB
							ren p22 p_mz_BB
							ren p23 p_gas_BB 
							ren p24 p_nickel_BB 
							ren p25 p_olvoil_BB
							ren p26 p_orange_BB 
							ren p27 p_palm_oil_BB
							ren p28 p_pepper_BB
							ren p29 p_oil_BB 
							ren p30 p_phos_BB 
							ren p31 p_cashew_BB 
							ren p32 p_fruit_BB 
							ren p33 p_poultry_BB 
							ren p34 p_pulp_BB
							ren p35 p_rice_BB
							ren p36 p_rubber_BB
							ren p37 p_shrimp_BB 
							ren p38 p_silver_BB 
							ren p39 p_ssal_BB
							ren p40 p_soyoil_BB
							ren p41 p_soy_BB 
							ren p42 p_sugar_BB 
							ren p43 p_tea_BB 
							ren p44 p_lumber_BB
							ren p45 p_tin_BB 
							ren p46 p_tobacco_BB
							ren p47 p_uranium_BB
							ren p48 p_wheat_BB
							ren p49 p_wool_BB 
							ren p50 p_zinc_BB
							ren p51 p_meat_BB
							ren p52 p_swine_BB
							ren p53 p_snoil_BB
							ren p54 p_soymeal_BB 
							ren p55 p_cattle_BB 
							ren p56 p_sheep_BB 
							ren p57 p_lv_poul_BB
							ren p58 p_lv_swine_BB
							ren p59 p_lvestock_BB
							ren p60 p_copra_BB
							ren p61 p_sorghum_BB
							ren p62 p_mangan_BB
							ren p63 p_asbest_BB
							ren p64 p_diamond_BB
							ren p65 p_gold_BB 

							egen export_totals_BB = rowtotal(p_alum_BB_l_i-p_gold_BB_l_i) // normalise sum of export shares to 1
							 foreach myvar of varlist p_alum_BB_l_i-p_gold_BB_l_i{
							  bys iso: replace `myvar' =  `myvar' /  export_totals_BB 
							}

							 foreach myvar of varlist  p_alum_BB-p_gold_BB{
							  bys iso: gen `myvar'_w_i =  `myvar' * `myvar'_l_i 
							}
							 
							gen oil_resource_s =  p_oil_BB_l_i
							replace oil_resource_s = oil_resource_col_s if year < 1957
							 
							egen P_ind_BB_i = rowtotal(p_alum_BB_w_i-p_gold_BB_w_i)
							replace P_ind_BB_i = . if P_ind_BB_i == 0
							egen P_point_BB_i = rowtotal(p_gold_BB_w_i p_diamond_BB_w_i p_asbest_BB_w_i p_mangan_BB_w_i  p_zinc_BB_w_i p_uranium_BB_w_i p_tin_BB_w_i p_silver_BB_w_i p_pulp_BB_w_i p_phos_BB_w_i p_oil_BB_w_i p_nickel_BB_w_i p_gas_BB_w_i p_lead_BB_w_i p_iron_BB_w_i p_copper_BB_w_i p_coal_BB_w_i p_alum_BB_w_i )    

							drop p_alum_BB_w_i-p_gold_BB_w_i

							bys iso (year): gen P_ind_BB_b = P_ind_BB_i[68] // rebase to 1957
							replace P_ind_BB_i = (P_ind_BB_i/ P_ind_BB_b )*100
							drop P_ind_BB_b

							bys iso (year): gen P_point_BB_b = P_point_BB_i[68] // rebase to 1957
							replace P_point_BB_i = (P_point_BB_i/ P_point_BB_b )*100
							drop P_point_BB_b

							bys iso (year): gen us_cpi_b =  us_cpi[68]
							replace us_cpi = (us_cpi  / us_cpi_b )*100
							drop us_cpi_b cpi2000
							gen P_ind_BB_i_real = (P_ind_BB_i  / us_cpi)*100
							gen P_point_BB_i_real = (P_point_BB_i  / us_cpi)*100

							*fixed weights 

							foreach myvar of varlist  p_alum_BB_l_i-p_gold_BB_l_i{
							  bys iso: egen `myvar'_s_f =  mean(`myvar')
							}

							rename p_*_l_i_s_f p_*_s_f

							foreach myvar of varlist  p_alum_BB-p_gold_BB{
							  bys iso: gen `myvar'_w_f =  `myvar' * `myvar'_s_f 
							}

							egen P_ind_BB_f = rowtotal(p_alum_BB_w_f-p_gold_BB_w_f)
							replace P_ind_BB_f = . if P_ind_BB_f == 0

							bys iso (year): gen P_ind_BB_b = P_ind_BB_f[68] // rebase to 1957
							replace P_ind_BB_f = (P_ind_BB_f/ P_ind_BB_b )*100
							gen P_ind_BB_f_real = (P_ind_BB_f / us_cpi)*100
							drop P_ind_BB_b p_alum_BB_s_f-p_gold_BB_s_f p_alum_BB_w_f-p_gold_BB_w_f


							egen point_resource_BB = rowtotal(p_gold_BB_l_i p_diamond_BB_l_i p_asbest_BB_l_i p_mangan_BB_l_i  p_zinc_BB_l_i p_uranium_BB_l_i p_tin_BB_l_i p_silver_BB_l_i p_pulp_BB_l_i p_phos_BB_l_i p_oil_BB_l_i p_nickel_BB_l_i p_gas_BB_l_i p_lead_BB_l_i p_iron_BB_l_i p_copper_BB_l_i p_coal_BB_l_i p_alum_BB_l_i )
							replace point_resource_s = point_resource_BB if year >1957
							drop point_resource_BB

							gen P_ind_total_i_real = P_ind_col_i_real
							replace P_ind_total_i_real = P_ind_BB_i_real if year >1957
							gen P_point_total_i_real = P_point_col_i_real
							replace P_point_total_i_real = P_point_BB_i_real if year >1957
							replace P_point_total_i_real = . if year <1900
							gen P_ind_total_i = P_ind_col_i
							replace P_ind_total_i = P_ind_BB_i if year >1957
							gen P_ind_total_f_real = P_ind_col_f_real
							replace P_ind_total_f_real = P_ind_BB_f_real if year >1957

							*weighting with trade shares
							merge 1:1 iso year using "Data/Resources/Bazzi_Blattmann_Final.dta", keepusing(exportsBOP2gdp)
							drop if _merge==2
							drop _merge

							gen export_share_BB = exportsBOP2gdp / gdp_current_us
							gen export_share_BB2 = exp_total_BB / gdp_current_us
							replace export_share_BB = export_share_BB2 if export_share_BB == .
							bys iso: egen export_share_mean_BB = mean(export_share_BB)
							bys iso: egen primary_share_mean_BB = mean(exp_com_BB)

							merge m:1 year using "Data/Resources/Federico_Tena_openness.dta"
							drop _merge

							sort iso year
							gen export_share_FT = x_share_CMR
							replace export_share_FT = x_share_EGY if iso == "EGY"
							replace export_share_FT = x_share_MAR if iso == "MAR"
							replace export_share_FT = x_share_MAR if iso == "DZA"
							replace export_share_FT = x_share_ZWE if iso == "ZWE"
							replace export_share_FT = x_share_ZWE if iso == "BWA"
							replace export_share_FT = x_share_ZWE if iso == "NAM"
							replace export_share_FT = x_share_ZAF if iso == "ZMB"
							replace export_share_FT = x_share_ZAF if iso == "COD"
							replace export_share_FT = x_share_ZAF if iso == "ZAF"
							replace export_share_FT = x_share_TUN if iso == "TUN"
							bys iso: egen export_share_mean_FT = mean(export_share_FT)
							drop x_share_CMR-x_share_TUN

							replace export_share_mean_BB = export_share_mean_FT  if year <= 1938
							replace export_share_mean_BB = . if year > 1938 & year < 1957 
							bys iso: ipolate export_share_mean_BB year, gen(export_share_mean_i)

							replace primary_share_mean_BB = 1 if year <= 1938 // all primary product shares 100% according to FT
							replace primary_share_mean_BB = . if year > 1938 & year < 1957 
							ipolate primary_share_mean_BB year, gen(primary_share_mean_i)

							sort iso_n year
							gen P_ind_total_i_nomcost = P_ind_total_i* (1/ tradecost ) // weigh index by tradecosts
							gen P_ind_total_i_realcost = P_ind_total_i_real* (1/ tradecost ) // weigh index by tradecosts
							gen P_point_total_i_realcost = P_point_total_i_real* (1/ tradecost ) // weigh index by tradecosts
							gen P_ind_total_f_realcost = P_ind_total_f_real* (1/ tradecost ) // weigh index by tradecosts
							gen P_ind_total_i_nomshare = P_ind_total_i* (export_share_mean_i* primary_share_mean_i ) // weigh index by tradeshare
							gen P_ind_total_i_realshare = P_ind_total_i_real* (export_share_mean_i* primary_share_mean_i)  // weigh index by tradecosts
							gen P_point_total_i_realshare = P_point_total_i_real* (export_share_mean_i* primary_share_mean_i) // weigh index by tradeshare
							gen P_ind_total_f_realshare = P_ind_total_f_real* (export_share_mean_i* primary_share_mean_i ) // weigh index by tradeshare

							gen large_exporter = 0
							foreach myvar of varlist  ishr_world_alum_BB-ishr_world_gold_BB{
							  bys iso: replace large_exporter = 1  if  `myvar' > 0.1 & `myvar' != .
							  drop `myvar' 
							}

							sort iso_n year
							gen l5P_ind_total_i_realcost = l1.P_ind_total_i_realcost + l2.P_ind_total_i_realcost  + l3.P_ind_total_i_realcost + l4.P_ind_total_i_realcost + l5.P_ind_total_i_realcost
							gen l5P_point_total_i_realshare = l1.P_point_total_i_realshare + l2.P_point_total_i_realshare + l3.P_point_total_i_realshare + l4.P_point_total_i_realshare + l5.P_point_total_i_realshare

**** resource revenues

							 

							gen resource_real_USD = ( (RESOURCES_NOMINAL  *x_rate_lcu_dollar) /us_cpi )/1000000
							gen resource_real_LCU = (RESOURCES_NOMINAL  / WAGES / POPULATION)
							gen resource_trade_real_USD = ((TRADE_TAXES_NOMINAL + RESOURCES_NOMINAL )  * x_rate_lcu_dollar /us_cpi )/1000000
							gen resource_trade_real_LCU = (TRADE_TAXES_NOMINAL + RESOURCES_NOMINAL )  / WAGES / POPULATION
							replace resource_real_USD = . if year < 1900
							replace resource_real_LCU = . if year < 1900


**** save 

save "Temp/Master", replace
