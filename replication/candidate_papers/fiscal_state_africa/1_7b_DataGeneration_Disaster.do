

 ****************************************************************************************************************************
 ******************Step 7 b)  DISASTERS
 *************************************************************************************************************************
 
 
*Spioni et al data (Global Drouhgt Observatory)
	use "Data/Disasters/Droughts_GDO.dta", clear
	 
	gen disastertype = "Drought"
	rename drght_occ drght_occ_GDO
	rename avgarea_percen mean_area_GDO
	 
	save "TEMP/Droughts_GDO_1.dta", replace
	 
 
* EMDAT DATA
	use "Data/Disasters/Emdat_original.dta", clear
	replace year = startyear
	drop riverbasin country startmonth startday endmonth endday declaration appeal eventname disno location origin seq disastergroup disastersubgroup disastersubtype disastersubsubtype entrycriteria continent region associateddis associateddis2 ofdaresponse dismagvalue dismagscale latitude longitude localtime
	gen disaster_occurrence_emdat = 1 

	* estimate affected from deaths if former is missing
	encode disastertype, gen (disastertype_n)
	bys disastertype_n : reg totalaffected totaldeaths, nocons // p<0.1 for storms, landslides, floods, epi, earthquakes, drought

	tabulate disastertype, generate(d) 
	reg totalaffected totaldeaths if d2==1 , nocons
	predict affected_death_d2 if d2==1 
	replace affected_death_d2 = 0 if affected_death_d2  < 0
	reg totalaffected totaldeaths if d3==1 , nocons
	predict affected_death_d3 if d3==1 
	replace affected_death_d3 = 0 if affected_death_d3  < 0
	reg totalaffected totaldeaths if d4==1 , nocons
	predict affected_death_d4 if d4==1 
	replace affected_death_d4 = 0 if affected_death_d4  < 0
	reg totalaffected totaldeaths if d6==1 , nocons
	predict affected_death_d6 if d6==1 
	replace affected_death_d6 = 0 if affected_death_d6  < 0
	reg totalaffected totaldeaths if d8==1 , nocons
	predict affected_death_d8 if d8==1 
	replace affected_death_d8 = 0 if affected_death_d8  < 0
	reg totalaffected totaldeaths if d10==1 , nocons
	predict affected_death_d10 if d10==1 
	replace affected_death_d10 = 0 if affected_death_d10  < 0

	gen total_affected_death = totalaffected
	replace total_affected_death = affected_death_d2 if affected_death_d2 != . &  total_affected_death == .
	replace total_affected_death = affected_death_d3 if affected_death_d3 != . &  total_affected_death == .
	replace total_affected_death = affected_death_d4 if affected_death_d4 != . &  total_affected_death == .
	replace total_affected_death = affected_death_d6 if affected_death_d6 != . &  total_affected_death == .
	replace total_affected_death = affected_death_d8 if affected_death_d8 != . &  total_affected_death == .
	replace total_affected_death = affected_death_d10 if affected_death_d10 != . &  total_affected_death == .

	drop d1-d12 affected_death_d2-affected_death_d10

	save "TEMP/Emdat_1.dta", replace

	keep if disastertype != "Drought"

	collapse (sum)  disaster_occurrence_emdat total_affected_death aidcontribution cpi, by( iso year)
	merge 1:1 iso year  using "TEMP/Droughts_GDO_1.dta", keepusing(name)
	drop if _merge ==1
	drop _merge 
	sort iso year
	replace total_affected_death = . if total_affected_death == 0

	merge 1:1 iso year using "Data/Disasters/NOAAandDesinventar.dta", keepusing(disaster_occ totalaffected) nogen
	egen disaster_affected = rowtotal(total_affected_death totalaffected) 

	*merge 1:1 iso year using "Temp/Master", keepusing(POPULATION)
	*drop _merge 

	replace disaster_affected = disaster_affected / 1000000
	egen disaster_count = rowtotal(disaster_occ disaster_occurrence_emdat)
	replace aidcontribution = . if aidcontribution == 0
	gen disaster_aid_dum =(aidcontribution != .)
	gen disaster_dum = (disaster_count>0)
	gen disaster_aid_cont = aidcontribution / cpi
	replace disaster_aid_cont = 0 if disaster_aid_cont ==.

	save "TEMP/Emdat_2.dta", replace

	use "TEMP/Emdat_1.dta", clear

	keep if disastertype == "Drought"
	gen drought_occ_emdat = 1
	duplicates drop iso year , force // 1 duplicate observation for MOZ
	merge 1:1 iso year disastertype using "TEMP/Droughts_GDO_1.dta", keepusing(mean_area_GDO drght_occ_GDO)
	drop if _merge ==1
	drop _merge 
	sort iso year

	gen duration = endyear - startyear +1 // droughts soften take place over several years
	replace total_affected_death = total_affected_death/ duration
	replace aidcontribution = aidcontribution / duration

	bys iso: replace endyear = endyear[_n-1] if endyear == .
	replace endyear = . if endyear < year

	bys iso: replace total_affected_death = total_affected_death[_n-1] if endyear >= year & total_affected_death == . & endyear != .
	bys iso: replace drought_occ_emdat = drought_occ_emdat[_n-1] if endyear >= year & drought_occ_emdat == . & endyear != .
	bys iso: replace aidcontribution = aidcontribution[_n-1] if endyear >= year & aidcontribution == . & endyear != .

	gen Emdat_overlap = 1 if endyear != . & drght_occ_GDO ==1 
	replace Emdat_overlap = 0 if (endyear != . & drght_occ_GDO ==0 ) | (endyear == . & drght_occ_GDO ==1 )

	merge 1:1 iso year using "Temp/Master", keepusing(POPULATION)
	drop _merge 
	gen pop_affected_share = total_affected_death  / POPULATION

	reg pop_affected_share mean_area_GDO, nocons
	predict predict_affect_share
	gen predict_affect = predict_affect_share *POPULATION

	replace drought_occ_emdat = drght_occ_GDO if drought_occ_emdat == . 
	rename drought_occ_emdat drought_occ_merged
	gen drought_affected_emdat = total_affected_death / 1000000
	replace drought_affected_emdat =  0 if drought_affected_emdat == .
	replace total_affected_death = predict_affect if total_affected_death == .
	replace total_affected_death = 0 if total_affected_death == .
	rename total_affected_death  drought_affected_merged
	replace drought_affected_merged = drought_affected_merged /1000000
	gen drought_aid_dum =(aidcontribution != .)
	gen drought_aid_cont = aidcontribution / cpi
	replace drought_aid_cont = 0 if drought_aid_cont ==.

	save "TEMP/Emdat_3.dta", replace

	use "Temp/Master", clear

	merge 1:1 iso year using "TEMP/Emdat_2.dta", keepusing(disaster_affected disaster_count disaster_dum disaster_aid_dum disaster_aid_cont) nogen

	merge 1:1 iso year using "TEMP/Emdat_3.dta", keepusing(drought_aid_dum drought_aid_cont drought_occ_merged drought_affected_merged  drought_affected_emdat ) nogen

	sort iso_n year
	gen disaster_affect_aid = disaster_affected  if disaster_aid_dum ==1
	replace disaster_affect_aid  = 0 if disaster_affect_aid ==.
	gen l5disaster_affect_aid   = l1.disaster_affect_aid   + l2.disaster_affect_aid  + l3.disaster_affect_aid   + l4.disaster_affect_aid   + l5.disaster_affect_aid 
	gen l5disaster_affected  = l1.disaster_affected  + l2.disaster_affected  + l3.disaster_affected  + l4.disaster_affected  + l5.disaster_affected 
	gen l5disaster_dum  = l1.disaster_dum  + l2.disaster_dum  + l3.disaster_dum + l4.disaster_dum  + l5.disaster_dum 
	gen l5drought_affected =  l1.drought_affected_merged  + l2.drought_affected_merged  + l3.drought_affected_merged + l4.drought_affected_merged + l5.drought_affected_merged
	gen l5drought_dum  = l1.drought_occ_merged + l2.drought_occ_merged  + l3.drought_occ_merged + l4.drought_occ_merged  + l5.drought_occ_merged




	save "Temp/Master", replace
 
 
