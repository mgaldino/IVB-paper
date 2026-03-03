log using log_dem_ethnic_ineq.log, replace
clear all

**Set working directory to location of files**
*cd "location"

**Install packages required for analyses and plotting**
ssc install estout, replace
ssc install coefplot, replace
ssc install interflex, replace
ssc install spmap, replace
ssc install ivreg2, replace
ssc install xtivreg2, replace
ssc install ranktest, replace
ssc install spmap, replace
ssc install xtabond2, replace
ssc install csdid, replace
ssc install drdid, replace
ssc install weakiv, replace
ssc install blindschemes, replace
ssc install reghdfe, replace
ssc install ftools, replace
ssc install avar, replace


*****************************************************************************************
*																						*
*																						*
*								Country-level Dataset 									*
*																						*
*																						*
*****************************************************************************************

use "Country-level dataset.dta"

xtset country_id year


********************************************************************
********************************************************************
********************* Dataset preparation **************************
********************************************************************
********************************************************************

*** Generate Dichotomous Lexical Index variable with cutoff at universal male suffrage
gen lexical_index_5 = 1 if lexical_index >= 5
replace lexical_index_5 = 0 if lexical_index <=4
replace lexical_index_5 = . if lexical_index ==.

*** Generate Dichotomous Lexical Index variable with cutoff at universal suffrage
gen lexical_index_6 = 1 if lexical_index >= 6
replace lexical_index_6 = 0 if lexical_index <=5
replace lexical_index_6 = . if lexical_index ==.

*** Generate Dichotomous Lexical Index variable with cutoff at competetive elections (no suffrage requirements)
gen lexical_index_4 = 1 if lexical_index >= 4
replace lexical_index_4 = 0 if lexical_index <=3
replace lexical_index_4 = . if lexical_index ==.


*** rescale V-Dem public service measure to go from 0-1 with lower values being normatively better
generate SEI = ((v2peapssoc-3.37)/(-3.135-3.37)*(1-0)+0)

*** linear interpolation of Alesina et al (2016) for predemocratic ethnic inequality measure
by country_id: ipolate grg year, gen(grg_ip)


*** 5 and 1O years panel *** 
gen fiveyears=1 if year==1900| year==1905| year==1910| year==1915| year==1920| year==1925| year==1930| year==1935| year==1940| year==1945| year==1950| year==1955| year==1960| year==1965| year==1970| year==1975| year==1980| year==1985| year==1990| year==1995| year==2000| year==2005| year==2010| year==2015| year==2020
gen tenyears=1 if year==1900| year==1910| year==1920| year==1930| year==1940| year==1950| year==1960| year==1970| year==1980| year==1990| year==2000| year==2010| year==2020

*** Generate regional control variables  ***
bys e_regionpol_6C year : egen region_SEI = mean(SEI)
bys e_regionpol_6C year : egen region_grg = mean(grg_ip)
bys e_regionpol_6C year : egen region_ggini = mean(ggini)
bys e_regionpol_6C year : egen region_civilwar = mean(e_civil_war) 
sort country_id year

*** Rename economic openness proxy (PWT)
g eco_open = ratioofexportsandimportstogdppwt


*** Rescale variables to range from 0-1 for mechanism study ****

* Power across social groups: v2pepwrsoc
gen power_groups = ((v2pepwrsoc--2.768)/(3.251--2.768))*(1-0)+0 

* Exclusion (EPR): exclpop
gen exclpop_2 = ((exclpop-.98)/(0-.98))*(1-0)+0 

* Political Discrimination (EPR): discrimpop
gen discrimpop_2 = ((discrimpop-.98)/(0-.98))*(1-0)+0 

* Civil liberties by social group: v2clsocgrp
gen civil_lib_groups = ((v2clsocgrp--3.142)/(3.368--3.142))*(1-0)+0 

* Range of consultation: v2dlconslt
gen consult = ((v2dlconslt--3.103)/(4.282--3.103))*(1-0)+0 

* Access to state business opportunities: v2peasbsoc
gen state_business_groups = ((v2peasbsoc--3.275)/(3.564--3.275))*(1-0)+0 

*  Access to state jobs by social group: v2peasjsoc
gen state_jobs_groups = ((v2peasjsoc--3.326)/(3.407--3.326))*(1-0)+0 

* Public vs. particularistic goods: v2dlencmps
gen public_goods = ((v2dlencmps--3.652)/(3.531--3.652))*(1-0)+0 

* Universal vs. means-tested: v2dlunivl
gen uni_v_means = ((v2dlunivl--3.355)/(3.461--3.355))*(1-0)+0 

* Access to basic education: v2peedueq
gen basic_edu = ((v2peedueq--3.308)/(3.675--3.308 ))*(1-0)+0 

* Access to basic health: v2pehealth
gen basic_health = ((v2pehealth--3.431)/(3.606--3.431))*(1-0)+0 



*****************************************************
********** Predemocracy ethnic inequality ***********
*****************************************************


******** GREG: generating the level before democratization taking inequality 5 years before or, if not available, 4, 3, 2, 1 or 0 years before. (Based on interpolated grg values to ensure sufficient observations)
gen pre_demo_ineq_best_grg_ip = L5.grg_ip  if lexical_index_5==0 & F.lexical_index_5==1
replace pre_demo_ineq_best_grg_ip = L4.grg_ip  if lexical_index_5==0 & F.lexical_index_5==1 & L5.grg_ip ==.
replace pre_demo_ineq_best_grg_ip = L3.grg_ip  if lexical_index_5==0 & F.lexical_index_5==1 & L5.grg_ip ==. & L4.grg_ip ==.
replace pre_demo_ineq_best_grg_ip = L2.grg_ip  if lexical_index_5==0 & F.lexical_index_5==1 & L5.grg_ip ==. & L4.grg_ip ==. & L3.grg_ip ==.
replace pre_demo_ineq_best_grg_ip = L.grg_ip  if lexical_index_5==0 & F.lexical_index_5==1 & L5.grg_ip ==. & L4.grg_ip ==. & L3.grg_ip ==. & L2.grg_ip ==.
replace pre_demo_ineq_best_grg_ip = grg_ip  if lexical_index_5==0 & F.lexical_index_5==1 & L5.grg_ip ==. & L4.grg_ip ==. & L3.grg_ip ==. & L2.grg_ip ==. & L.grg_ip ==.
replace pre_demo_ineq_best_grg_ip = F.grg_ip  if lexical_index_5==0 & F.lexical_index_5==1 & L5.grg_ip ==. & L4.grg_ip ==. & L3.grg_ip ==. & L2.grg_ip ==. & L.grg_ip ==. & grg_ip ==.
replace pre_demo_ineq_best_grg_ip = L.pre_demo_ineq_best_grg_ip if lexical_index_5!=0
replace pre_demo_ineq_best_grg_ip = grg_ip  if pre_demo_ineq_best_grg_ip == .



******** Access to public services by social group: generating the level before democratization taking inequality 5 years before or, if not available, 4, 3, 2, 1 or 0 years before
gen pre_demo_ineq_best_SEI = L5.SEI  if lexical_index_5==0 & F.lexical_index_5==1
replace pre_demo_ineq_best_SEI = L4.SEI  if lexical_index_5==0 & F.lexical_index_5==1 & L5.SEI ==.
replace pre_demo_ineq_best_SEI = L3.SEI  if lexical_index_5==0 & F.lexical_index_5==1 & L5.SEI ==. & L4.SEI ==.
replace pre_demo_ineq_best_SEI = L2.SEI  if lexical_index_5==0 & F.lexical_index_5==1 & L5.SEI ==. & L4.SEI ==. & L3.SEI ==.
replace pre_demo_ineq_best_SEI = L.SEI  if lexical_index_5==0 & F.lexical_index_5==1 & L5.SEI ==. & L4.SEI ==. & L3.SEI ==. & L2.SEI ==.
replace pre_demo_ineq_best_SEI = SEI  if lexical_index_5==0 & F.lexical_index_5==1 & L5.SEI ==. & L4.SEI ==. & L3.SEI ==. & L2.SEI ==. & L.SEI ==.
replace pre_demo_ineq_best_SEI = F.SEI  if lexical_index_5==0 & F.lexical_index_5==1 & L5.SEI ==. & L4.SEI ==. & L3.SEI ==. & L2.SEI ==. & L.SEI ==. & SEI ==.
replace pre_demo_ineq_best_SEI = L.pre_demo_ineq_best_SEI if lexical_index_5!=0
replace pre_demo_ineq_best_SEI = SEI  if pre_demo_ineq_best_SEI == .


******* Inequality (Omoeva et al): generating the level before democratization taking inequality 5 years before or, if not available, 4, 3, 2, 1 or 0 years before
gen pre_demo_ineq_best_ggini = L5.ggini  if lexical_index_5==0 & F.lexical_index_5==1
replace pre_demo_ineq_best_ggini = L4.ggini  if lexical_index_5==0 & F.lexical_index_5==1 & L5.ggini ==.
replace pre_demo_ineq_best_ggini = L3.ggini  if lexical_index_5==0 & F.lexical_index_5==1 & L5.ggini ==. & L4.ggini ==.
replace pre_demo_ineq_best_ggini = L2.ggini  if lexical_index_5==0 & F.lexical_index_5==1 & L5.ggini ==. & L4.ggini ==. & L3.ggini ==.
replace pre_demo_ineq_best_ggini = L.ggini  if lexical_index_5==0 & F.lexical_index_5==1 & L5.ggini ==. & L4.ggini ==. & L3.ggini ==. & L2.ggini ==.
replace pre_demo_ineq_best_ggini = ggini  if lexical_index_5==0 & F.lexical_index_5==1 & L5.ggini ==. & L4.ggini ==. & L3.ggini ==. & L2.ggini ==. & L.ggini ==.
replace pre_demo_ineq_best_ggini = F.ggini  if lexical_index_5==0 & F.lexical_index_5==1 & L5.ggini ==. & L4.ggini ==. & L3.ggini ==. & L2.ggini ==. & L.ggini ==. & ggini ==.
replace pre_demo_ineq_best_ggini = L.pre_demo_ineq_best_ggini if lexical_index_5!=0
replace pre_demo_ineq_best_ggini = ggini  if pre_demo_ineq_best_ggini == .







********************************************************************
********************************************************************
**************************** Analysis ******************************
********************************************************************
********************************************************************



*****************************************************
****** Figure 2: Mapping of index  ******************
*****************************************************

sum SEI if year ==2000, detail

* "V-Dem: expert-coded (public services)"
spmap SEI using "worldcoor" if year==2000, id(map_id) fcolor(Blues2) osize(vvthin vvthin vvthin vvthin) ndsize(vvthin) clmethod(quantile) title(, size(small)) leg(off) name(fg2A)
graph export "fg2A.emf", replace 
graph export "fg2A.pdf", replace

*"Alesina et al.: nightlights (income)"
spmap grg using "worldcoor" if year==2000, id(map_id) fcolor(Blues2) osize(vvthin vvthin vvthin vvthin) ndsize(vvthin) clmethod(quantile) title(, size(small)) leg(off) name(fg2B)
graph export "fg2B.emf", replace 
graph export "fg2B.pdf", replace

*""Omoeva et al.: survey-based (education)"
spmap ggini using "worldcoor" if year==2000, id(map_id) fcolor(Blues2) osize(vvthin vvthin vvthin vvthin) ndsize(vvthin) clmethod(quantile) title(, size(small)) leg(off) name(fg2C)
graph export "fg2C.emf", replace 
graph export "fg2C.pdf", replace
 

 
 
********************************************
******* Table 1: Regression results ********
********************************************

*** Unconditional
eststo: xtreg SEI L.lexical_index_5 L.latent_gdppc_mean_log i.year, fe cluster(country_id)

eststo: xtreg grg L.lexical_index_5 L.latent_gdppc_mean_log i.year, fe cluster(country_id)

eststo: xtreg ggini L.lexical_index_5 L.latent_gdppc_mean_log i.year, fe cluster(country_id)


*** Conditional on predemocratic inequality
eststo: xtreg SEI c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log i.year, fe cluster(country_id)
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI

eststo: xtreg grg c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log i.year, fe cluster(country_id)
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip 

eststo: xtreg ggini c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log i.year, fe cluster(country_id)
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini

esttab using T1.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3))  order(L.lexical_index_5 cL.lexical_index_5#cL.pre_demo_ineq_best_* L.latent_gdppc_mean_log) drop(*.year) replace
eststo clear

* Note for all regression tables: Results from F-test of joint signifance derived from "testparm" command are added to each column in the regression tables.
** Number of transitions is not provided by regression output and has been subsequently added by summarizing the number of transitions for the sample in question.


********************************************
******* Figure 3: Marginal effects *********
********************************************

* Prepare dependent variables for interflex *
g f_SEI = f.SEI
g f_grg = f.grg
g f_ggini = f.ggini

*** Interflex 
set scheme plotplain
interflex f_SEI lexical_index_5 pre_demo_ineq_best_SEI latent_gdppc_mean_log, fe(country_id year) cluster(country_id) ylabel("Ethnic Inequality") dlabel("Democracy") title("") xlabel("Predemocratic Ethnic Inequality")
graph display Graph, ysize(3) xsize(6)
gr_edit yaxis1.title.text = {}
gr_edit yaxis1.title.text.Arrpush `"Marginal Effect of Democracy"'
gr_edit yaxis1.title.text.Arrpush `"on Ethnic Inequality"'
gr_edit yaxis1.title.style.editstyle size(medlarge) editcopy
gr_edit yaxis1.style.editstyle majorstyle(tickstyle(textstyle(size(medlarge)))) editcopy
gr_edit xaxis1.style.editstyle majorstyle(tickstyle(textstyle(size(medlarge)))) editcopy
gr_edit xaxis1.title.style.editstyle size(medlarge) editcopy
gr_edit plotregion1.textbox1.style.editstyle color(black) editcopy
gr_edit plotregion1.textbox2.style.editstyle color(black) editcopy
gr_edit plotregion1.textbox3.style.editstyle color(black) editcopy
gr_edit .yaxis1.title.DragBy -.5 5.5
graph save "fg3A.gph",replace
graph export "fg3A.emf", replace 
graph export "fg3A.pdf", replace

interflex f_grg lexical_index_5 pre_demo_ineq_best_grg_ip latent_gdppc_mean_log, fe(country_id year) cluster(country_id) ylabel("Ethnic Inequality") dlabel("Democracy") title("") xlabel("Predemocratic Ethnic Inequality")
graph display Graph, ysize(3) xsize(6)
gr_edit yaxis1.title.text = {}
gr_edit yaxis1.title.text.Arrpush `"Marginal Effect of Democracy"'
gr_edit yaxis1.title.text.Arrpush `"on Ethnic Inequality"'
gr_edit yaxis1.title.style.editstyle size(medlarge) editcopy
gr_edit yaxis1.style.editstyle majorstyle(tickstyle(textstyle(size(medlarge)))) editcopy
gr_edit xaxis1.style.editstyle majorstyle(tickstyle(textstyle(size(medlarge)))) editcopy
gr_edit xaxis1.title.style.editstyle size(medlarge) editcopy
gr_edit plotregion1.textbox1.style.editstyle color(black) editcopy
gr_edit plotregion1.textbox2.style.editstyle color(black) editcopy
gr_edit plotregion1.textbox3.style.editstyle color(black) editcopy
gr_edit .yaxis1.title.DragBy -.5 5.5
graph save "fg3B.gph",replace
graph export "fg3B.emf", replace 
graph export "fg3B.pdf", replace

interflex f_ggini lexical_index_5 pre_demo_ineq_best_ggini latent_gdppc_mean_log, fe(country_id year) cluster(country_id) ylabel("Ethnic Inequality") dlabel("Democracy") title("") xlabel("Predemocratic Ethnic Inequality") 
graph display Graph, ysize(3) xsize(6)
gr_edit yaxis1.title.text = {}
gr_edit yaxis1.title.text.Arrpush `"Marginal Effect of Democracy"'
gr_edit yaxis1.title.text.Arrpush `"on Ethnic Inequality"'
gr_edit yaxis1.title.style.editstyle size(medlarge) editcopy
gr_edit yaxis1.style.editstyle majorstyle(tickstyle(textstyle(size(medlarge)))) editcopy
gr_edit xaxis1.style.editstyle majorstyle(tickstyle(textstyle(size(medlarge)))) editcopy
gr_edit xaxis1.title.style.editstyle size(medlarge) editcopy
gr_edit plotregion1.textbox1.style.editstyle color(black) editcopy
gr_edit plotregion1.textbox2.style.editstyle color(black) editcopy
gr_edit plotregion1.textbox3.style.editstyle color(black) editcopy
gr_edit .yaxis1.title.DragBy -.5 5.5
graph save "fg3C.gph",replace
graph export "fg3C.emf", replace 
graph export "fg3C.pdf", replace



***************************************************************************
****** Table 2: IV analysis *********************************************
***************************************************************************


*************************************
*********** Instruments *************
*************************************


******************************** Lexical Index of Electoral Democracy: Generate instruments
gen demo_lied=1 if lexical_index_5>=1 & lexical_index_5!=.
replace demo_lied=0 if lexical_index_5<=0 & lexical_index_5!=.


gen demo_lied_initial = demo_lied if demo_lied!=. & L.demo_lied==.

replace demo_lied_initial = L.demo_lied_initial if L.demo_lied_initial!=.
 
forvalues i = 1/100 {
    replace demo_lied_initial = F.demo_lied_initial if demo_lied_initial==.
local i=`i'+1
} 
*}

bys e_regionpol_6C year : egen n_non_demo_lied = sum(demo_lied_initial==0) 

bys e_regionpol_6C year : egen n_demo_lied = sum(demo_lied_initial==1)

bys e_regionpol_6C year demo_lied_initial : egen sum_demo_lied = sum(demo_lied==1)


gen neighbour_demo_lied = (1/(n_non_demo_lied - 1))*(sum_demo_lied  - demo_lied) if demo_lied_initial==0
replace neighbour_demo_lied = (1/(n_demo_lied - 1))*(sum_demo_lied  - demo_lied) if demo_lied_initial==1

sort country_id year


*** generate interaction and their instruments
gen dem_predemo_ineq_SEI = lexical_index_5*pre_demo_ineq_best_SEI
gen neighbour_predemo_ineq_SEI = neighbour_demo_lied*pre_demo_ineq_best_SEI

gen dem_predemo_ineq_grg_ip = lexical_index_5*pre_demo_ineq_best_grg_ip
gen neighbour_predemo_ineq_grg_ip = neighbour_demo_lied*pre_demo_ineq_best_grg_ip

gen dem_predemo_ineq_ggini = lexical_index_5*pre_demo_ineq_best_ggini
gen neighbour_predemo_ineq_ggini = neighbour_demo_lied*pre_demo_ineq_best_ggini


*** Analysis ***
eststo: xi: xtivreg2 SEI (L.lexical_index_5= L.neighbour_demo_lied) L.latent_gdppc_mean_log i.year, cluster(country_id) fe
eststo: xi: xtivreg2 grg (L.lexical_index_5= L.neighbour_demo_lied) L.latent_gdppc_mean_log i.year, cluster(country_id) fe
eststo: xi: xtivreg2 ggini (L.lexical_index_5= L.neighbour_demo_lied) L.latent_gdppc_mean_log i.year, cluster(country_id) fe

eststo: xi: xtivreg2 SEI (L.lexical_index_5 L.dem_predemo_ineq_SEI = L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI) L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log i.year, cluster(country_id) fe
testparm L.lexical_index_5 L.dem_predemo_ineq_SEI L.pre_demo_ineq_best_SEI

eststo: xi: xtivreg2 grg (L.lexical_index_5 L.dem_predemo_ineq_grg_ip = L.neighbour_demo_lied L.neighbour_predemo_ineq_grg_ip) L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log i.year, cluster(country_id) fe
testparm L.lexical_index_5 L.dem_predemo_ineq_grg_ip L.pre_demo_ineq_best_grg_ip

eststo: xi: xtivreg2 ggini (L.lexical_index_5 L.dem_predemo_ineq_ggini = L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini) L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log i.year, cluster(country_id) fe
testparm L.lexical_index_5 L.dem_predemo_ineq_ggini L.pre_demo_ineq_best_ggini

esttab using T2.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3)) order(L.lexical_index_5 L.dem_predemo_ineq_* L.latent_gdppc_mean_log) drop(*_Iyear_17* *_Iyear_18* *_Iyear_19* *_Iyear_20*) replace
eststo clear



********************************************************
************* Figure 4: Event study plot ***************
********************************************************


***** Event study: All democratizations *****
graph drop _all

** Transition variable
gen transition = 0
recode transition (0=1) if lexical_index_5==1 & L.lexical_index_5==0
recode transition (0=.) if lexical_index_5==.

** Dummies pre/post democratization **
g pre_20_15=0
g pre_15_10=0
g pre_10_5=0
g pre_5_0=0
g event=0
g post_0_5=0
g post_5_10=0
g post_10_15=0
g post_15_20=0

label variable pre_20_15 "-20 to -15"
label variable pre_15_10 "-15 to -10"
label variable pre_10_5 "-10 to -5"
label variable pre_5_0 "-5 to 0"

label variable post_0_5 "0 to 5"
label variable post_5_10 "5 to 10"
label variable post_10_15 "10 to 15"
label variable post_15_20 "15 to 20"

recode pre_20_15 (0=1) if F20.transition ==1 & lexical_index_5==0 | F19.transition ==1 & lexical_index_5==0 | F18.transition ==1 & lexical_index_5==0 | F17.transition ==1 & lexical_index_5==0 | F16.transition ==1 & lexical_index_5==0 
recode pre_15_10 (0=1) if F15.transition ==1 & lexical_index_5==0 | F14.transition ==1 & lexical_index_5==0 | F13.transition ==1 & lexical_index_5==0 | F12.transition ==1 & lexical_index_5==0 | F11.transition ==1 & lexical_index_5==0 
recode pre_10_5 (0=1) if F10.transition ==1 & lexical_index_5==0 | F9.transition ==1 & lexical_index_5==0 | F8.transition ==1 & lexical_index_5==0 | F7.transition ==1 & lexical_index_5==0 | F6.transition ==1 & lexical_index_5==0 
recode pre_5_0 (0=1) if F5.transition ==1 & lexical_index_5==0 | F4.transition ==1 & lexical_index_5==0 | F3.transition ==1 & lexical_index_5==0 | F2.transition ==1 & lexical_index_5==0 | F1.transition ==1 & lexical_index_5==0 
recode event (0=1) if transition==1
recode post_0_5 (0=1) if L1.transition==1 & lexical_index_5==1 | L2.transition==1 & lexical_index_5==1 | L3.transition==1 & lexical_index_5==1| L4.transition==1 & lexical_index_5==1| L5.transition==1 & lexical_index_5==1
recode post_5_10 (0=1) if L6.transition==1 & lexical_index_5==1 | L7.transition==1 & lexical_index_5==1 | L8.transition==1 & lexical_index_5==1| L9.transition==1 & lexical_index_5==1| L10.transition==1 & lexical_index_5==1
recode post_10_15 (0=1) if L11.transition==1 & lexical_index_5==1 | L12.transition==1 & lexical_index_5==1 | L13.transition==1 & lexical_index_5==1| L14.transition==1 & lexical_index_5==1| L15.transition==1 & lexical_index_5==1
recode post_15_20 (0=1) if L16.transition==1 & lexical_index_5==1 | L17.transition==1 & lexical_index_5==1 | L18.transition==1 & lexical_index_5==1| L19.transition==1 & lexical_index_5==1| L20.transition==1 & lexical_index_5==1

** Variable for following democractic years
g post_post=0
recode post_post (0=1) if lexical_index_5 == 1 & post_0_5==0 & post_5_10==0  & post_10_15==0 & post_15_20==0

* Median of the upper tercile
centile pre_demo_ineq_best_SEI, centile(83)
centile pre_demo_ineq_best_grg_ip, centile(83)
centile pre_demo_ineq_best_ggini, centile(83)

** Estimates and event graph: SEI **
xtreg SEI pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demo_ineq_best_SEI >=.7867794, fe cluster(country_id)

eststo m1: qui margins, dydx(pre* event post*) post
coefplot m1, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(medlarge)) ylabel(, labsize(medlarge))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(medlarge) xtitle(" " "Years from democratization", size(medlarge)) title(, color(black)) name(fg4A)
graph display fg4A, ysize(3) xsize(6)
graph export "fg4A.emf", replace 
graph export "fg4A.pdf", replace

** Estimates and event graph: GRG **
xtreg grg pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demo_ineq_best_grg_ip >=.6962401 , fe cluster(country_id)

eststo m2: qui margins, dydx(pre* event post*) post
coefplot m2, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(medlarge)) ylabel(, labsize(medlarge))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(medlarge) xtitle(" " "Years from democratization", size(medlarge)) title(, color(black)) name(fg4B)
graph display fg4B, ysize(3) xsize(6)
graph export "fg4B.emf", replace 
graph export "fg4B.pdf", replace

** Estimates and event graph: GGINI **
xtreg ggini pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demo_ineq_best_ggini >=.1999601, fe cluster(country_id) 

eststo m3: qui margins, dydx(pre* event post*) post
coefplot m3, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(medlarge)) ylabel(, labsize(medlarge))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(medlarge) xtitle(" " "Years from democratization", size(medlarge)) title(, color(black)) name(fg4C)
graph display fg4C, ysize(3) xsize(6)
graph export "fg4C.emf", replace 
graph export "fg4C.pdf", replace

eststo clear

********************************************************************
********************************************************************
**************************** Appendix *****************************
********************************************************************
********************************************************************


******************************************************
************* Table A1: Temporal variation ***********
******************************************************
xtsum grg ggini SEI



**************************************************************
************** Table A2: First-stage estimations *************
**************************************************************

*** Samples for first-stage
xtreg SEI L.lexical_index_5 L.latent_gdppc_mean_log i.year, fe cluster(country_id)
gen baseline_1 = e(sample)
xtreg grg L.lexical_index_5 L.latent_gdppc_mean_log i.year, fe cluster(country_id)
gen baseline_2 = e(sample)
xtreg ggini L.lexical_index_5 L.latent_gdppc_mean_log i.year, fe cluster(country_id)
gen baseline_3 = e(sample)
xtreg SEI c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log i.year, fe cluster(country_id)
gen baseline_4 = e(sample)
xtreg grg_ip c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log i.year, fe cluster(country_id)
gen baseline_5 = e(sample)
xtreg ggini c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log i.year, fe cluster(country_id)
gen baseline_6 = e(sample)


*** Table A2: First-stage ***
eststo: xtreg L.lexical_index_5 L.neighbour_demo_lied L.latent_gdppc_mean_log i.year if baseline_1==1, cluster(country_id) fe
testparm L.neighbour_demo_lied

eststo: xtreg L.lexical_index_5 L.neighbour_demo_lied L.latent_gdppc_mean_log i.year if baseline_2==1, cluster(country_id) fe
testparm L.neighbour_demo_lied

eststo: xtreg L.lexical_index_5 L.neighbour_demo_lied L.latent_gdppc_mean_log i.year if baseline_3==1, cluster(country_id) fe
testparm L.neighbour_demo_lied

eststo: xtreg L.lexical_index_5 L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log i.year if baseline_4==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI L.pre_demo_ineq_best_SEI

eststo: xtreg L.dem_predemo_ineq_SEI L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log i.year if baseline_4==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI L.pre_demo_ineq_best_SEI

eststo: xtreg L.lexical_index_5 L.neighbour_demo_lied L.neighbour_predemo_ineq_grg_ip L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log i.year if baseline_5==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_grg_ip L.pre_demo_ineq_best_grg_ip

eststo: xtreg L.dem_predemo_ineq_grg_ip L.neighbour_demo_lied L.neighbour_predemo_ineq_grg_ip L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log i.year if baseline_5==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_grg_ip L.pre_demo_ineq_best_grg_ip

eststo: xtreg L.lexical_index_5 L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log i.year if baseline_6==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini L.pre_demo_ineq_best_ggini

eststo: xtreg L.dem_predemo_ineq_ggini L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log i.year if baseline_6==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini L.pre_demo_ineq_best_ggini 

esttab using TA2.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3)) drop(*.year) replace
eststo clear


**************************************************************
************** Table A3: Weak instrument inference ***********
**************************************************************

*** Note: Table A3 is a copy of Table 2 + the diagnostics from the "weakiv" package. Because results from "weakiv" cannot be exported to a text file, they have been copied manually. ***

eststo: xi: xtivreg2 SEI (L.lexical_index_5= L.neighbour_demo_lied) L.latent_gdppc_mean_log i.year, cluster(country_id) fe
eststo: xi: xtivreg2 grg (L.lexical_index_5= L.neighbour_demo_lied) L.latent_gdppc_mean_log i.year, cluster(country_id) fe
eststo: xi: xtivreg2 ggini (L.lexical_index_5= L.neighbour_demo_lied) L.latent_gdppc_mean_log i.year, cluster(country_id) fe

eststo: xi: xtivreg2 SEI (L.lexical_index_5 L.dem_predemo_ineq_SEI = L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI) L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log i.year, cluster(country_id) fe
testparm L.lexical_index_5 L.dem_predemo_ineq_SEI L.pre_demo_ineq_best_SEI

eststo: xi: xtivreg2 grg (L.lexical_index_5 L.dem_predemo_ineq_grg_ip = L.neighbour_demo_lied L.neighbour_predemo_ineq_grg_ip) L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log i.year, cluster(country_id) fe
testparm L.lexical_index_5 L.dem_predemo_ineq_grg_ip L.pre_demo_ineq_best_grg_ip

eststo: xi: xtivreg2 ggini (L.lexical_index_5 L.dem_predemo_ineq_ggini = L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini) L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log i.year, cluster(country_id) fe
testparm L.lexical_index_5 L.dem_predemo_ineq_ggini L.pre_demo_ineq_best_ggini

esttab using TA3.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3)) drop(*_Iyear_17* *_Iyear_18* *_Iyear_19* *_Iyear_20*) replace
eststo clear

xi: weakiv xtivreg2 SEI (L.lexical_index_5= L.neighbour_demo_lied) L.latent_gdppc_mean_log i.year, cluster(country_id) fe 
xi: weakiv xtivreg2 grg (L.lexical_index_5= L.neighbour_demo_lied) L.latent_gdppc_mean_log i.year, cluster(country_id) fe
xi: weakiv xtivreg2 ggini (L.lexical_index_5= L.neighbour_demo_lied) L.latent_gdppc_mean_log i.year, cluster(country_id) fe

xi: weakiv xtivreg2 SEI (L.lexical_index_5 L.dem_predemo_ineq_SEI = L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI) L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log i.year, cluster(country_id) fe project(_all)
xi: weakiv xtivreg2 grg (L.lexical_index_5 L.dem_predemo_ineq_grg_ip = L.neighbour_demo_lied L.neighbour_predemo_ineq_grg_ip) L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log i.year, cluster(country_id) fe project(_all)
xi: weakiv xtivreg2 ggini (L.lexical_index_5 L.dem_predemo_ineq_ggini = L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini) L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log i.year, cluster(country_id) fe project(_all)


***********************************************************
************ Examining the exclusion criterion ************
***********************************************************


***********************
*** Table A4: V-Dem ***
***********************
eststo: xi: xtivreg2 SEI (L.lexical_index_5 L.dem_predemo_ineq_SEI = L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI) L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log L.region_SEI i.year, cluster(country_id) fe
testparm L.lexical_index_5 L.dem_predemo_ineq_SEI L.pre_demo_ineq_best_SEI

eststo: xi: xtivreg2 SEI (L.lexical_index_5 L.dem_predemo_ineq_SEI = L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI) L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log L.region_civilwar i.year, cluster(country_id) fe
testparm L.lexical_index_5 L.dem_predemo_ineq_SEI L.pre_demo_ineq_best_SEI

eststo: xi: xtivreg2 SEI (L.lexical_index_5 L.dem_predemo_ineq_SEI = L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI) L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log L.eco_open i.year, cluster(country_id) fe
testparm L.lexical_index_5 L.dem_predemo_ineq_SEI L.pre_demo_ineq_best_SEI

eststo: xi: xtivreg2 SEI (L.lexical_index_5 L.dem_predemo_ineq_SEI = L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI) L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log L.e_wb_pop i.year, cluster(country_id) fe
testparm L.lexical_index_5 L.dem_predemo_ineq_SEI L.pre_demo_ineq_best_SEI

eststo: xi: xtivreg2 SEI (L.lexical_index_5 L.dem_predemo_ineq_SEI = L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI) L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log L.region_SEI L.region_civilwar L.eco_open L.e_wb_pop  i.year, cluster(country_id) fe
testparm L.lexical_index_5 L.dem_predemo_ineq_SEI L.pre_demo_ineq_best_SEI

esttab using TA4.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3)) drop(*_Iyear_17* *_Iyear_18* *_Iyear_19* *_Iyear_20*) replace
eststo clear


*********************************
*** Table A5: Alesina et al.  *** 
*********************************
eststo: xi: xtivreg2 grg (L.lexical_index_5 L.dem_predemo_ineq_grg_ip = L.neighbour_demo_lied L.neighbour_predemo_ineq_grg_ip) L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log region_grg i.year, cluster(country_id) fe
testparm L.lexical_index_5 L.dem_predemo_ineq_grg_ip L.pre_demo_ineq_best_grg_ip

eststo: xi: xtivreg2 grg (L.lexical_index_5 L.dem_predemo_ineq_grg_ip = L.neighbour_demo_lied L.neighbour_predemo_ineq_grg_ip) L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log L.eco_open i.year, cluster(country_id) fe
testparm L.lexical_index_5 L.dem_predemo_ineq_grg_ip L.pre_demo_ineq_best_grg_ip

eststo: xi: xtivreg2 grg (L.lexical_index_5 L.dem_predemo_ineq_grg_ip = L.neighbour_demo_lied L.neighbour_predemo_ineq_grg_ip) L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log L.e_wb_pop i.year, cluster(country_id) fe
testparm L.lexical_index_5 L.dem_predemo_ineq_grg_ip L.pre_demo_ineq_best_grg_ip

eststo: xi: xtivreg2 grg (L.lexical_index_5 L.dem_predemo_ineq_grg_ip = L.neighbour_demo_lied L.neighbour_predemo_ineq_grg_ip) L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log region_grg L.eco_open L.e_wb_pop i.year, cluster(country_id) fe
testparm L.lexical_index_5 L.dem_predemo_ineq_grg_ip L.pre_demo_ineq_best_grg_ip

esttab using TA5.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3)) drop(*_Iyear_17* *_Iyear_18* *_Iyear_19* *_Iyear_20*) replace
eststo clear


*******************************
*** Table A6: Omoeva et al. ***
*******************************
eststo: xi: xtivreg2 ggini (L.lexical_index_5 L.dem_predemo_ineq_ggini = L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini) L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log L.region_ggini i.year, cluster(country_id) fe
testparm L.lexical_index_5 L.dem_predemo_ineq_ggini L.pre_demo_ineq_best_ggini

eststo: xi: xtivreg2 ggini (L.lexical_index_5 L.dem_predemo_ineq_ggini = L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini) L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log L.region_civilwar i.year, cluster(country_id) fe
testparm L.lexical_index_5 L.dem_predemo_ineq_ggini L.pre_demo_ineq_best_ggini

eststo: xi: xtivreg2 ggini (L.lexical_index_5 L.dem_predemo_ineq_ggini = L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini) L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log L.eco_open i.year, cluster(country_id) fe
testparm L.lexical_index_5 L.dem_predemo_ineq_ggini L.pre_demo_ineq_best_ggini

eststo: xi: xtivreg2 ggini (L.lexical_index_5 L.dem_predemo_ineq_ggini = L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini) L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log L.e_wb_pop i.year, cluster(country_id) fe
testparm L.lexical_index_5 L.dem_predemo_ineq_ggini L.pre_demo_ineq_best_ggini

eststo: xi: xtivreg2 ggini (L.lexical_index_5 L.dem_predemo_ineq_ggini = L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini) L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log L.region_ggini L.region_civilwar L.eco_open L.e_wb_pop i.year, cluster(country_id) fe
testparm L.lexical_index_5 L.dem_predemo_ineq_ggini L.pre_demo_ineq_best_ggini

esttab using TA6.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3)) drop(*_Iyear_17* *_Iyear_18* *_Iyear_19* *_Iyear_20*) replace
eststo clear


***********************************************************************
*** First-stage regressions for examinations of exclusion criterion ***
***********************************************************************

*** Samples for first-stage ***

* V-Dem sample
xtreg SEI c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log L.region_SEI i.year, fe cluster(country_id)
gen sample_SEI1 = e(sample)

xtreg SEI c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log L.region_civilwar i.year, fe cluster(country_id)
gen sample_SEI2 = e(sample)

xtreg SEI c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log L.eco_open i.year, fe cluster(country_id)
gen sample_SEI3 = e(sample)

xtreg SEI c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log L.e_wb_pop i.year, fe cluster(country_id)
gen sample_SEI4 = e(sample)

xtreg SEI c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log L.region_SEI L.region_civilwar L.eco_open L.e_wb_pop i.year, fe cluster(country_id)
gen sample_SEI5 = e(sample)


* Alesina et al. sample
xtreg grg_ip c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log region_grg i.year, fe cluster(country_id)
gen sample_grg1 = e(sample)

xtreg grg_ip c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log L.eco_open i.year, fe cluster(country_id)
gen sample_grg2 = e(sample)

xtreg grg_ip c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log L.e_wb_pop i.year, fe cluster(country_id)
gen sample_grg3 = e(sample)

xtreg grg_ip c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log region_grg L.eco_open L.e_wb_pop i.year, fe cluster(country_id)
gen sample_grg4 = e(sample)


* Omoeva et al. sample
xtreg ggini c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log L.region_ggini i.year, fe cluster(country_id)
gen sample_ggini1 = e(sample)

xtreg ggini c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log L.region_civilwar i.year, fe cluster(country_id)
gen sample_ggini2 = e(sample)

xtreg ggini c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log L.eco_open i.year, fe cluster(country_id)
gen sample_ggini3 = e(sample)

xtreg ggini c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log L.e_wb_pop i.year, fe cluster(country_id)
gen sample_ggini4 = e(sample)

xtreg ggini c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log L.region_ggini L.region_civilwar L.eco_open L.e_wb_pop i.year, fe cluster(country_id)
gen sample_ggini5 = e(sample)


***************************************
*** Table A7: First-stage for V-Dem ***
***************************************

* (1)
eststo: xtreg L.lexical_index_5 L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log L.region_SEI i.year if sample_SEI1==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI L.pre_demo_ineq_best_SEI
	
eststo: xtreg L.dem_predemo_ineq_SEI L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log L.region_SEI i.year if sample_SEI1==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI L.pre_demo_ineq_best_SEI

* (2)
eststo: xtreg L.lexical_index_5 L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log L.region_civilwar i.year if sample_SEI2==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI L.pre_demo_ineq_best_SEI

eststo: xtreg L.dem_predemo_ineq_SEI L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log L.region_civilwar i.year if sample_SEI2==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI L.pre_demo_ineq_best_SEI

* (3)
eststo: xtreg L.lexical_index_5 L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log L.eco_open i.year if sample_SEI3==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI L.pre_demo_ineq_best_SEI

eststo: xtreg L.dem_predemo_ineq_SEI L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log L.eco_open i.year if sample_SEI3==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI L.pre_demo_ineq_best_SEI

* (4)
eststo: xtreg L.lexical_index_5 L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log L.e_wb_pop i.year if sample_SEI4==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI L.pre_demo_ineq_best_SEI

eststo: xtreg L.dem_predemo_ineq_SEI L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log L.e_wb_pop i.year if sample_SEI4==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI L.pre_demo_ineq_best_SEI

* (5)
eststo: xtreg L.lexical_index_5 L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log L.region_SEI L.region_civilwar L.eco_open L.e_wb_pop i.year if sample_SEI5==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI L.pre_demo_ineq_best_SEI

eststo: xtreg L.dem_predemo_ineq_SEI L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log L.region_SEI L.region_civilwar L.eco_open L.e_wb_pop i.year if sample_SEI5==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_SEI L.pre_demo_ineq_best_SEI

esttab using TA7.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3)) drop(*.year) replace
eststo clear


************************************************
*** Table A8: First-stage for Alesina et al. ***
************************************************

*(1)
eststo: xtreg L.lexical_index_5 L.neighbour_demo_lied L.neighbour_predemo_ineq_grg_ip L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log region_grg i.year if sample_grg1==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_grg_ip L.pre_demo_ineq_best_grg_ip

eststo: xtreg L.dem_predemo_ineq_grg_ip L.neighbour_demo_lied L.neighbour_predemo_ineq_grg_ip L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log region_grg i.year if sample_grg1==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_grg_ip L.pre_demo_ineq_best_grg_ip

*(2)
eststo: xtreg L.lexical_index_5 L.neighbour_demo_lied L.neighbour_predemo_ineq_grg_ip L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log L.eco_open i.year if sample_grg2==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_grg_ip L.pre_demo_ineq_best_grg_ip

eststo: xtreg L.dem_predemo_ineq_grg_ip L.neighbour_demo_lied L.neighbour_predemo_ineq_grg_ip L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log L.eco_open i.year if sample_grg2==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_grg_ip L.pre_demo_ineq_best_grg_ip

*(3)
eststo: xtreg L.lexical_index_5 L.neighbour_demo_lied L.neighbour_predemo_ineq_grg_ip L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log L.e_wb_pop i.year if sample_grg3==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_grg_ip L.pre_demo_ineq_best_grg_ip

eststo: xtreg L.dem_predemo_ineq_grg_ip L.neighbour_demo_lied L.neighbour_predemo_ineq_grg_ip L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log L.e_wb_pop i.year if sample_grg3==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_grg_ip L.pre_demo_ineq_best_grg_ip

*(4)
eststo: xtreg L.lexical_index_5 L.neighbour_demo_lied L.neighbour_predemo_ineq_grg_ip L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log region_grg L.eco_open L.e_wb_pop i.year if sample_grg4==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_grg_ip L.pre_demo_ineq_best_grg_ip

eststo: xtreg L.dem_predemo_ineq_grg_ip L.neighbour_demo_lied L.neighbour_predemo_ineq_grg_ip L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log region_grg L.eco_open L.e_wb_pop i.year if sample_grg4==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_grg_ip L.pre_demo_ineq_best_grg_ip

esttab using TA8.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3)) drop(*.year) replace
eststo clear


***********************************************
*** Table A9: First-stage for Omoeva et al. ***
***********************************************

* (1)
eststo: xtreg L.lexical_index_5 L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log L.region_ggini i.year if sample_ggini1==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini L.pre_demo_ineq_best_ggini

eststo: xtreg L.dem_predemo_ineq_ggini L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log L.region_ggini i.year if sample_ggini1==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini L.pre_demo_ineq_best_ggini 

* (2)
eststo: xtreg L.lexical_index_5 L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log L.region_civilwar i.year if sample_ggini2==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini L.pre_demo_ineq_best_ggini

eststo: xtreg L.dem_predemo_ineq_ggini L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log L.region_civilwar i.year if sample_ggini2==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini L.pre_demo_ineq_best_ggini 

* (3)
eststo: xtreg L.lexical_index_5 L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log L.eco_open i.year if sample_ggini3==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini L.pre_demo_ineq_best_ggini

eststo: xtreg L.dem_predemo_ineq_ggini L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log L.eco_open i.year if sample_ggini3==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini L.pre_demo_ineq_best_ggini 

* (4)
eststo: xtreg L.lexical_index_5 L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log L.e_wb_pop i.year if sample_ggini4==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini L.pre_demo_ineq_best_ggini

eststo: xtreg L.dem_predemo_ineq_ggini L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log L.e_wb_pop i.year if sample_ggini4==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini L.pre_demo_ineq_best_ggini 


* (5)
eststo: xtreg L.lexical_index_5 L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log L.region_ggini L.region_civilwar L.eco_open L.e_wb_pop i.year if sample_ggini5==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini L.pre_demo_ineq_best_ggini

eststo: xtreg L.dem_predemo_ineq_ggini L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log L.region_ggini L.region_civilwar L.eco_open L.e_wb_pop i.year if sample_ggini5==1, cluster(country_id) fe
testparm L.neighbour_demo_lied L.neighbour_predemo_ineq_ggini L.pre_demo_ineq_best_ggini 


esttab using TA9.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3)) drop(*.year) replace
eststo clear




********************************************************
************* Table A10: Event study Table **************
********************************************************
eststo clear

eststo: xtreg SEI pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demo_ineq_best_SEI >=0.73, fe cluster(country_id)
eststo: xtreg grg pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demo_ineq_best_grg_ip >=0.67, fe cluster(country_id)
eststo: xtreg ggini pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demo_ineq_best_ggini >=0.16, fe cluster(country_id) 

esttab using TA10.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3))  order() drop(*.year) replace
eststo clear


************************************************************************************************
************* Figure A1: Event study plot for non-high predomacy inequality sample *************
************************************************************************************************

* Drop variables from previous event analysis
eststo clear
drop transition pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post
graph drop _all

** Transition variable
gen transition = 0
recode transition (0=1) if lexical_index_5==1 & L.lexical_index_5==0
recode transition (0=.) if lexical_index_5==.

** Dummies pre/post democratization **
g pre_20_15=0
g pre_15_10=0
g pre_10_5=0
g pre_5_0=0
g event=0
g post_0_5=0
g post_5_10=0
g post_10_15=0
g post_15_20=0

label variable pre_20_15 "-20 to -15"
label variable pre_15_10 "-15 to -10"
label variable pre_10_5 "-10 to -5"
label variable pre_5_0 "-5 to 0"

label variable post_0_5 "0 to 5"
label variable post_5_10 "5 to 10"
label variable post_10_15 "10 to 15"
label variable post_15_20 "15 to 20"

recode pre_20_15 (0=1) if F20.transition ==1 & lexical_index_5==0 | F19.transition ==1 & lexical_index_5==0 | F18.transition ==1 & lexical_index_5==0 | F17.transition ==1 & lexical_index_5==0 | F16.transition ==1 & lexical_index_5==0 
recode pre_15_10 (0=1) if F15.transition ==1 & lexical_index_5==0 | F14.transition ==1 & lexical_index_5==0 | F13.transition ==1 & lexical_index_5==0 | F12.transition ==1 & lexical_index_5==0 | F11.transition ==1 & lexical_index_5==0 
recode pre_10_5 (0=1) if F10.transition ==1 & lexical_index_5==0 | F9.transition ==1 & lexical_index_5==0 | F8.transition ==1 & lexical_index_5==0 | F7.transition ==1 & lexical_index_5==0 | F6.transition ==1 & lexical_index_5==0 
recode pre_5_0 (0=1) if F5.transition ==1 & lexical_index_5==0 | F4.transition ==1 & lexical_index_5==0 | F3.transition ==1 & lexical_index_5==0 | F2.transition ==1 & lexical_index_5==0 | F1.transition ==1 & lexical_index_5==0 
recode event (0=1) if transition==1
recode post_0_5 (0=1) if L1.transition==1 & lexical_index_5==1 | L2.transition==1 & lexical_index_5==1 | L3.transition==1 & lexical_index_5==1| L4.transition==1 & lexical_index_5==1| L5.transition==1 & lexical_index_5==1
recode post_5_10 (0=1) if L6.transition==1 & lexical_index_5==1 | L7.transition==1 & lexical_index_5==1 | L8.transition==1 & lexical_index_5==1| L9.transition==1 & lexical_index_5==1| L10.transition==1 & lexical_index_5==1
recode post_10_15 (0=1) if L11.transition==1 & lexical_index_5==1 | L12.transition==1 & lexical_index_5==1 | L13.transition==1 & lexical_index_5==1| L14.transition==1 & lexical_index_5==1| L15.transition==1 & lexical_index_5==1
recode post_15_20 (0=1) if L16.transition==1 & lexical_index_5==1 | L17.transition==1 & lexical_index_5==1 | L18.transition==1 & lexical_index_5==1| L19.transition==1 & lexical_index_5==1| L20.transition==1 & lexical_index_5==1

** Variable for following democractic years
g post_post=0
recode post_post (0=1) if lexical_index_5 == 1 & post_0_5==0 & post_5_10==0  & post_10_15==0 & post_15_20==0

** Estimates and event graph: SEI **
xtreg SEI pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demo_ineq_best_SEI <.7867794, fe cluster(country_id)

eststo m1: qui margins, dydx(pre* event post*) post
coefplot m1, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel(, labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from democratization") title(" " "V-Dem", color(black)) name(graph1)

** Estimates and event graph: GRG **
xtreg grg pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demo_ineq_best_grg_ip <.6962401 , fe cluster(country_id)

eststo m2: qui margins, dydx(pre* event post*) post
coefplot m2, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel(#4, labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from democratization") title(" " "Alesina et al.", color(black)) name(graph2)

** Estimates and event graph: GGINI **
xtreg ggini pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demo_ineq_best_ggini <.1999601, fe cluster(country_id) 

eststo m3: qui margins, dydx(pre* event post*) post
coefplot m3, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel(, labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from democratization") title(" " "Omoeva et al.", color(black)) name(graph3)

graph combine graph1 graph2 graph3, rows(3) name(fga1)
graph display fga1, ysize(5) xsize(3)
graph export "fgA1.emf", replace 
graph export "fgA1.pdf", replace
eststo clear



*************************************************************************
**************** DiD for Multiple Time Periods **************************
*************************************************************************

**** NOTE: "csdid" package calculations are time-demanding ***** 

*prep var*
g y=year if lexical_index_5==1
bys country_id: egen miny=min(y)
g treat=0
replace treat=miny if miny!=.
bys country_id: egen always=mean(lexical_index_5)
replace treat=. if always==1

************************
*** Figure A2: V-DEM ***
************************
g treat_SEI_1=treat
g treat_SEI_2=treat
replace treat_SEI_1=. if pre_demo_ineq_best_SEI <.7867794
replace treat_SEI_2=. if pre_demo_ineq_best_SEI >=.7867794

csdid SEI,ivar(country_id) time(year) gvar(treat_SEI_1)
estat all
estat event,window(-10 10)
csdid_plot, title("V-Dem: Public Services", color(black))
graph export "fgA2.emf", replace 
graph export "fgA2.pdf", replace

********************************
*** Figure A3: Omoeva et al. ***
********************************
g treat_ggini_1=treat
g treat_ggini_2=treat
replace treat_ggini_1=. if pre_demo_ineq_best_ggini <.1999601
replace treat_ggini_2=. if pre_demo_ineq_best_ggini >=.1999601

csdid ggini,ivar(country_id) time(year) gvar(treat_ggini_1)
estat all
estat event,window(-10 10)
csdid_plot, title("Omoeva et al.: Education", color(black))
graph export "fgA3.emf", replace 
graph export "fgA3.pdf", replace


*****************************************************
*************** Table A11: Additional controls ******
*****************************************************

*** Unconditional models: Oil, pop, ethnic fractionalization
eststo: xtreg SEI L.lexical_index_5 L.latent_gdppc_mean_log L.e_total_oil_income_pc L.e_civil_war L.efindex L.e_migdpgro i.year, fe cluster(country_id)

eststo: xtreg grg L.lexical_index_5 L.latent_gdppc_mean_log L.e_total_oil_income_pc L.e_civil_war L.efindex L.e_migdpgro i.year, fe cluster(country_id)

eststo: xtreg ggini L.lexical_index_5 L.latent_gdppc_mean_log L.e_total_oil_income_pc L.e_civil_war L.efindex L.e_migdpgro i.year, fe cluster(country_id)

*** Conditional models: Oil, pop, ethnic fractionalization
eststo: xtreg SEI c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log L.e_total_oil_income_pc L.e_civil_war L.efindex L.e_migdpgro i.year, cluster(country_id) fe
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI

*addditonal controls, minus civil war and oil*
eststo: xtreg grg c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log L.efindex L.e_migdpgro i.year, cluster(country_id) fe
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip 

eststo: xtreg ggini c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log L.e_total_oil_income_pc L.e_civil_war L.efindex L.e_migdpgro i.year, cluster(country_id) fe
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini

esttab using TA11.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3)) order(L.lexical_index_5 cL.lexical_index_5#cL.pre_demo_ineq_best_* L.pre_demo_ineq_best* L.latent_gdppc_mean_log) drop(*.year) replace
eststo clear


****************************************************************
********** Alternative democracy measures: Binary  *************
****************************************************************

***********************
*** Table A12: BMR ****
***********************

******** GREG: generating the level before democratization taking inequality 5 years before or, if not available, 4, 3, 2, 1 or 0 years before. (Based on interpolated grg values to ensure sufficient observations)
gen pre_demobmr_ineq_best_grg_ip = L5.grg_ip  if e_boix_regime==0 & F.e_boix_regime==1
replace pre_demobmr_ineq_best_grg_ip = L4.grg_ip  if e_boix_regime==0 & F.e_boix_regime==1 & L5.grg_ip ==.
replace pre_demobmr_ineq_best_grg_ip = L3.grg_ip  if e_boix_regime==0 & F.e_boix_regime==1 & L5.grg_ip ==. & L4.grg_ip ==.
replace pre_demobmr_ineq_best_grg_ip = L2.grg_ip  if e_boix_regime==0 & F.e_boix_regime==1 & L5.grg_ip ==. & L4.grg_ip ==. & L3.grg_ip ==.
replace pre_demobmr_ineq_best_grg_ip = L.grg_ip  if e_boix_regime==0 & F.e_boix_regime==1 & L5.grg_ip ==. & L4.grg_ip ==. & L3.grg_ip ==. & L2.grg_ip ==.
replace pre_demobmr_ineq_best_grg_ip = grg_ip  if e_boix_regime==0 & F.e_boix_regime==1 & L5.grg_ip ==. & L4.grg_ip ==. & L3.grg_ip ==. & L2.grg_ip ==. & L.grg_ip ==.
replace pre_demobmr_ineq_best_grg_ip = F.grg_ip  if e_boix_regime==0 & F.e_boix_regime==1 & L5.grg_ip ==. & L4.grg_ip ==. & L3.grg_ip ==. & L2.grg_ip ==. & L.grg_ip ==. & grg_ip ==.
replace pre_demobmr_ineq_best_grg_ip = L.pre_demobmr_ineq_best_grg_ip if e_boix_regime!=0
replace pre_demobmr_ineq_best_grg_ip = grg_ip  if pre_demobmr_ineq_best_grg_ip == .


******** Access to public services by social group: generating the level before democratization taking inequality 5 years before or, if not available, 4, 3, 2, 1 or 0 years before
gen pre_demobmr_ineq_best_SEI = L5.SEI  if e_boix_regime==0 & F.e_boix_regime==1
replace pre_demobmr_ineq_best_SEI = L4.SEI  if e_boix_regime==0 & F.e_boix_regime==1 & L5.SEI ==.
replace pre_demobmr_ineq_best_SEI = L3.SEI  if e_boix_regime==0 & F.e_boix_regime==1 & L5.SEI ==. & L4.SEI ==.
replace pre_demobmr_ineq_best_SEI = L2.SEI  if e_boix_regime==0 & F.e_boix_regime==1 & L5.SEI ==. & L4.SEI ==. & L3.SEI ==.
replace pre_demobmr_ineq_best_SEI = L.SEI  if e_boix_regime==0 & F.e_boix_regime==1 & L5.SEI ==. & L4.SEI ==. & L3.SEI ==. & L2.SEI ==.
replace pre_demobmr_ineq_best_SEI = SEI  if e_boix_regime==0 & F.e_boix_regime==1 & L5.SEI ==. & L4.SEI ==. & L3.SEI ==. & L2.SEI ==. & L.SEI ==.
replace pre_demobmr_ineq_best_SEI = F.SEI  if e_boix_regime==0 & F.e_boix_regime==1 & L5.SEI ==. & L4.SEI ==. & L3.SEI ==. & L2.SEI ==. & L.SEI ==. & SEI ==.
replace pre_demobmr_ineq_best_SEI = L.pre_demobmr_ineq_best_SEI if e_boix_regime!=0
replace pre_demobmr_ineq_best_SEI = SEI  if pre_demobmr_ineq_best_SEI == .


******* Inequality (Omoeva et al): generating the level before democratization taking inequality 5 years before or, if not available, 4, 3, 2, 1 or 0 years before
gen pre_demobmr_ineq_best_ggini = L5.ggini  if e_boix_regime==0 & F.e_boix_regime==1
replace pre_demobmr_ineq_best_ggini = L4.ggini  if e_boix_regime==0 & F.e_boix_regime==1 & L5.ggini ==.
replace pre_demobmr_ineq_best_ggini = L3.ggini  if e_boix_regime==0 & F.e_boix_regime==1 & L5.ggini ==. & L4.ggini ==.
replace pre_demobmr_ineq_best_ggini = L2.ggini  if e_boix_regime==0 & F.e_boix_regime==1 & L5.ggini ==. & L4.ggini ==. & L3.ggini ==.
replace pre_demobmr_ineq_best_ggini = L.ggini  if e_boix_regime==0 & F.e_boix_regime==1 & L5.ggini ==. & L4.ggini ==. & L3.ggini ==. & L2.ggini ==.
replace pre_demobmr_ineq_best_ggini = ggini  if e_boix_regime==0 & F.e_boix_regime==1 & L5.ggini ==. & L4.ggini ==. & L3.ggini ==. & L2.ggini ==. & L.ggini ==.
replace pre_demobmr_ineq_best_ggini = F.ggini  if e_boix_regime==0 & F.e_boix_regime==1 & L5.ggini ==. & L4.ggini ==. & L3.ggini ==. & L2.ggini ==. & L.ggini ==. & ggini ==.
replace pre_demobmr_ineq_best_ggini = L.pre_demobmr_ineq_best_ggini if e_boix_regime!=0
replace pre_demobmr_ineq_best_ggini = ggini  if pre_demobmr_ineq_best_ggini == .


*** BMR analysis
eststo: xtreg SEI L.e_boix_regime L.latent_gdppc_mean_log i.year, fe cluster(country_id)
eststo: xtreg grg L.e_boix_regime L.latent_gdppc_mean_log i.year, fe cluster(country_id)
eststo: xtreg ggini L.e_boix_regime L.latent_gdppc_mean_log i.year, fe cluster(country_id)

eststo: xtreg SEI L.c.e_boix_regime##c.L.pre_demobmr_ineq_best_SEI L.latent_gdppc_mean_log i.year, cluster(country_id) fe
testparm L.c.e_boix_regime##c.L.pre_demobmr_ineq_best_SEI

eststo: xtreg grg L.c.e_boix_regime##c.L.pre_demobmr_ineq_best_grg_ip L.latent_gdppc_mean_log i.year, cluster(country_id) fe
testparm L.c.e_boix_regime##c.L.pre_demobmr_ineq_best_grg_ip

eststo: xtreg ggini L.c.e_boix_regime##c.L.pre_demobmr_ineq_best_ggini L.latent_gdppc_mean_log i.year, cluster(country_id) fe
testparm L.c.e_boix_regime##c.L.pre_demobmr_ineq_best_ggini

esttab using TA12.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3)) drop(*.year) order(L.e_boix_regime cL.e_boix_regime#cL.pre_demobmr_ineq_best_*  L.latent_gdppc_mean_log) replace
eststo clear 


**********************************
*** Table A13: Lexical level 6 ***
**********************************

******** GREG: generating the level before democratization taking inequality 5 years before or, if not available, 4, 3, 2, 1 or 0 years before. (Based on interpolated grg values to ensure sufficient observations)
gen pre_demoL6_ineq_best_grg_ip = L5.grg_ip  if lexical_index_6==0 & F.lexical_index_6==1
replace pre_demoL6_ineq_best_grg_ip = L4.grg_ip  if lexical_index_6==0 & F.lexical_index_6==1 & L5.grg_ip ==.
replace pre_demoL6_ineq_best_grg_ip = L3.grg_ip  if lexical_index_6==0 & F.lexical_index_6==1 & L5.grg_ip ==. & L4.grg_ip ==.
replace pre_demoL6_ineq_best_grg_ip = L2.grg_ip  if lexical_index_6==0 & F.lexical_index_6==1 & L5.grg_ip ==. & L4.grg_ip ==. & L3.grg_ip ==.
replace pre_demoL6_ineq_best_grg_ip = L.grg_ip  if lexical_index_6==0 & F.lexical_index_6==1 & L5.grg_ip ==. & L4.grg_ip ==. & L3.grg_ip ==. & L2.grg_ip ==.
replace pre_demoL6_ineq_best_grg_ip = grg_ip  if lexical_index_6==0 & F.lexical_index_6==1 & L5.grg_ip ==. & L4.grg_ip ==. & L3.grg_ip ==. & L2.grg_ip ==. & L.grg_ip ==.
replace pre_demoL6_ineq_best_grg_ip = F.grg_ip  if lexical_index_6==0 & F.lexical_index_6==1 & L5.grg_ip ==. & L4.grg_ip ==. & L3.grg_ip ==. & L2.grg_ip ==. & L.grg_ip ==. & grg_ip ==.
replace pre_demoL6_ineq_best_grg_ip = L.pre_demoL6_ineq_best_grg_ip if lexical_index_6!=0
replace pre_demoL6_ineq_best_grg_ip = grg_ip  if pre_demoL6_ineq_best_grg_ip == .


******** Access to public services by social group: generating the level before democratization taking inequality 5 years before or, if not available, 4, 3, 2, 1 or 0 years before
gen pre_demoL6_ineq_best_SEI = L5.SEI  if lexical_index_6==0 & F.lexical_index_6==1
replace pre_demoL6_ineq_best_SEI = L4.SEI  if lexical_index_6==0 & F.lexical_index_6==1 & L5.SEI ==.
replace pre_demoL6_ineq_best_SEI = L3.SEI  if lexical_index_6==0 & F.lexical_index_6==1 & L5.SEI ==. & L4.SEI ==.
replace pre_demoL6_ineq_best_SEI = L2.SEI  if lexical_index_6==0 & F.lexical_index_6==1 & L5.SEI ==. & L4.SEI ==. & L3.SEI ==.
replace pre_demoL6_ineq_best_SEI = L.SEI  if lexical_index_6==0 & F.lexical_index_6==1 & L5.SEI ==. & L4.SEI ==. & L3.SEI ==. & L2.SEI ==.
replace pre_demoL6_ineq_best_SEI = SEI  if lexical_index_6==0 & F.lexical_index_6==1 & L5.SEI ==. & L4.SEI ==. & L3.SEI ==. & L2.SEI ==. & L.SEI ==.
replace pre_demoL6_ineq_best_SEI = F.SEI  if lexical_index_6==0 & F.lexical_index_6==1 & L5.SEI ==. & L4.SEI ==. & L3.SEI ==. & L2.SEI ==. & L.SEI ==. & SEI ==.
replace pre_demoL6_ineq_best_SEI = L.pre_demoL6_ineq_best_SEI if lexical_index_6!=0
replace pre_demoL6_ineq_best_SEI = SEI  if pre_demoL6_ineq_best_SEI == .


******* Inequality (Omoeva et al): generating the level before democratization taking inequality 5 years before or, if not available, 4, 3, 2, 1 or 0 years before
gen pre_demoL6_ineq_best_ggini = L5.ggini  if lexical_index_6==0 & F.lexical_index_6==1
replace pre_demoL6_ineq_best_ggini = L4.ggini  if lexical_index_6==0 & F.lexical_index_6==1 & L5.ggini ==.
replace pre_demoL6_ineq_best_ggini = L3.ggini  if lexical_index_6==0 & F.lexical_index_6==1 & L5.ggini ==. & L4.ggini ==.
replace pre_demoL6_ineq_best_ggini = L2.ggini  if lexical_index_6==0 & F.lexical_index_6==1 & L5.ggini ==. & L4.ggini ==. & L3.ggini ==.
replace pre_demoL6_ineq_best_ggini = L.ggini  if lexical_index_6==0 & F.lexical_index_6==1 & L5.ggini ==. & L4.ggini ==. & L3.ggini ==. & L2.ggini ==.
replace pre_demoL6_ineq_best_ggini = ggini  if lexical_index_6==0 & F.lexical_index_6==1 & L5.ggini ==. & L4.ggini ==. & L3.ggini ==. & L2.ggini ==. & L.ggini ==.
replace pre_demoL6_ineq_best_ggini = F.ggini  if lexical_index_6==0 & F.lexical_index_6==1 & L5.ggini ==. & L4.ggini ==. & L3.ggini ==. & L2.ggini ==. & L.ggini ==. & ggini ==.
replace pre_demoL6_ineq_best_ggini = L.pre_demoL6_ineq_best_ggini if lexical_index_6!=0
replace pre_demoL6_ineq_best_ggini = ggini  if pre_demoL6_ineq_best_ggini == .

*** lexical level 6 analysis
eststo: xtreg SEI L.lexical_index_6 L.latent_gdppc_mean_log i.year, fe cluster(country_id)
eststo: xtreg grg L.lexical_index_6 L.latent_gdppc_mean_log i.year, fe cluster(country_id)
eststo: xtreg ggini L.lexical_index_6 L.latent_gdppc_mean_log i.year, fe cluster(country_id)

eststo: xtreg SEI L.c.lexical_index_6##c.L.pre_demoL6_ineq_best_SEI L.latent_gdppc_mean_log i.year, cluster(country_id) fe
testparm L.c.lexical_index_6##c.L.pre_demoL6_ineq_best_SEI

eststo: xtreg grg L.c.lexical_index_6##c.L.pre_demoL6_ineq_best_grg_ip L.latent_gdppc_mean_log i.year, cluster(country_id) fe
testparm L.c.lexical_index_6##c.L.pre_demoL6_ineq_best_grg_ip

eststo: xtreg ggini L.c.lexical_index_6##c.L.pre_demoL6_ineq_best_ggini L.latent_gdppc_mean_log i.year, cluster(country_id) fe
testparm L.c.lexical_index_6##c.L.pre_demoL6_ineq_best_ggini

esttab using TA13.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3)) drop(*.year) order(L.lexical_index_6 cL.lexical_index_6#cL.pre_demoL6_ineq_best_*  L.latent_gdppc_mean_log) replace
eststo clear 


**********************************
*** Table A14: Lexical level 4 ***
**********************************

******** GREG: generating the level before democratization taking inequality 5 years before or, if not available, 4, 3, 2, 1 or 0 years before. (Based on interpolated grg values to ensure sufficient observations)
gen pre_demoL4_ineq_best_grg_ip = L5.grg_ip  if lexical_index_4==0 & F.lexical_index_4==1
replace pre_demoL4_ineq_best_grg_ip = L4.grg_ip  if lexical_index_4==0 & F.lexical_index_4==1 & L5.grg_ip ==.
replace pre_demoL4_ineq_best_grg_ip = L3.grg_ip  if lexical_index_4==0 & F.lexical_index_4==1 & L5.grg_ip ==. & L4.grg_ip ==.
replace pre_demoL4_ineq_best_grg_ip = L2.grg_ip  if lexical_index_4==0 & F.lexical_index_4==1 & L5.grg_ip ==. & L4.grg_ip ==. & L3.grg_ip ==.
replace pre_demoL4_ineq_best_grg_ip = L.grg_ip  if lexical_index_4==0 & F.lexical_index_4==1 & L5.grg_ip ==. & L4.grg_ip ==. & L3.grg_ip ==. & L2.grg_ip ==.
replace pre_demoL4_ineq_best_grg_ip = grg_ip  if lexical_index_4==0 & F.lexical_index_4==1 & L5.grg_ip ==. & L4.grg_ip ==. & L3.grg_ip ==. & L2.grg_ip ==. & L.grg_ip ==.
replace pre_demoL4_ineq_best_grg_ip = F.grg_ip  if lexical_index_4==0 & F.lexical_index_4==1 & L5.grg_ip ==. & L4.grg_ip ==. & L3.grg_ip ==. & L2.grg_ip ==. & L.grg_ip ==. & grg_ip ==.
replace pre_demoL4_ineq_best_grg_ip = L.pre_demoL4_ineq_best_grg_ip if lexical_index_4!=0
replace pre_demoL4_ineq_best_grg_ip = grg_ip  if pre_demoL4_ineq_best_grg_ip == .


******** Access to public services by social group: generating the level before democratization taking inequality 5 years before or, if not available, 4, 3, 2, 1 or 0 years before
gen pre_demoL4_ineq_best_SEI = L5.SEI  if lexical_index_4==0 & F.lexical_index_4==1
replace pre_demoL4_ineq_best_SEI = L4.SEI  if lexical_index_4==0 & F.lexical_index_4==1 & L5.SEI ==.
replace pre_demoL4_ineq_best_SEI = L3.SEI  if lexical_index_4==0 & F.lexical_index_4==1 & L5.SEI ==. & L4.SEI ==.
replace pre_demoL4_ineq_best_SEI = L2.SEI  if lexical_index_4==0 & F.lexical_index_4==1 & L5.SEI ==. & L4.SEI ==. & L3.SEI ==.
replace pre_demoL4_ineq_best_SEI = L.SEI  if lexical_index_4==0 & F.lexical_index_4==1 & L5.SEI ==. & L4.SEI ==. & L3.SEI ==. & L2.SEI ==.
replace pre_demoL4_ineq_best_SEI = SEI  if lexical_index_4==0 & F.lexical_index_4==1 & L5.SEI ==. & L4.SEI ==. & L3.SEI ==. & L2.SEI ==. & L.SEI ==.
replace pre_demoL4_ineq_best_SEI = F.SEI  if lexical_index_4==0 & F.lexical_index_4==1 & L5.SEI ==. & L4.SEI ==. & L3.SEI ==. & L2.SEI ==. & L.SEI ==. & SEI ==.
replace pre_demoL4_ineq_best_SEI = L.pre_demoL4_ineq_best_SEI if lexical_index_4!=0
replace pre_demoL4_ineq_best_SEI = SEI  if pre_demoL4_ineq_best_SEI == .


******* Inequality (Omoeva et al): generating the level before democratization taking inequality 5 years before or, if not available, 4, 3, 2, 1 or 0 years before
gen pre_demoL4_ineq_best_ggini = L5.ggini  if lexical_index_4==0 & F.lexical_index_4==1
replace pre_demoL4_ineq_best_ggini = L4.ggini  if lexical_index_4==0 & F.lexical_index_4==1 & L5.ggini ==.
replace pre_demoL4_ineq_best_ggini = L3.ggini  if lexical_index_4==0 & F.lexical_index_4==1 & L5.ggini ==. & L4.ggini ==.
replace pre_demoL4_ineq_best_ggini = L2.ggini  if lexical_index_4==0 & F.lexical_index_4==1 & L5.ggini ==. & L4.ggini ==. & L3.ggini ==.
replace pre_demoL4_ineq_best_ggini = L.ggini  if lexical_index_4==0 & F.lexical_index_4==1 & L5.ggini ==. & L4.ggini ==. & L3.ggini ==. & L2.ggini ==.
replace pre_demoL4_ineq_best_ggini = ggini  if lexical_index_4==0 & F.lexical_index_4==1 & L5.ggini ==. & L4.ggini ==. & L3.ggini ==. & L2.ggini ==. & L.ggini ==.
replace pre_demoL4_ineq_best_ggini = F.ggini  if lexical_index_4==0 & F.lexical_index_4==1 & L5.ggini ==. & L4.ggini ==. & L3.ggini ==. & L2.ggini ==. & L.ggini ==. & ggini ==.
replace pre_demoL4_ineq_best_ggini = L.pre_demoL4_ineq_best_ggini if lexical_index_4!=0
replace pre_demoL4_ineq_best_ggini = ggini  if pre_demoL4_ineq_best_ggini == .

*** lexical level 4 analysis
eststo: xtreg SEI L.lexical_index_4 L.latent_gdppc_mean_log i.year, fe cluster(country_id)
eststo: xtreg grg L.lexical_index_4 L.latent_gdppc_mean_log i.year, fe cluster(country_id)
eststo: xtreg ggini L.lexical_index_4 L.latent_gdppc_mean_log i.year, fe cluster(country_id)

eststo: xtreg SEI L.c.lexical_index_4##c.L.pre_demoL4_ineq_best_SEI L.latent_gdppc_mean_log i.year, cluster(country_id) fe
testparm L.c.lexical_index_4##c.L.pre_demoL4_ineq_best_SEI

eststo: xtreg grg L.c.lexical_index_4##c.L.pre_demoL4_ineq_best_grg_ip L.latent_gdppc_mean_log i.year, cluster(country_id) fe
testparm L.c.lexical_index_4##c.L.pre_demoL4_ineq_best_grg_ip

eststo: xtreg ggini L.c.lexical_index_4##c.L.pre_demoL4_ineq_best_ggini L.latent_gdppc_mean_log i.year, cluster(country_id) fe
testparm L.c.lexical_index_4##c.L.pre_demoL4_ineq_best_ggini

esttab using TA14.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3)) drop(*.year) order(L.lexical_index_4 cL.lexical_index_4#cL.pre_demoL4_ineq_best_*  L.latent_gdppc_mean_log) replace
eststo clear 




**********************************************
**** Table A15: Acemoglu & al (2019) index ***
**********************************************

*Generate index following coding rules by Acemoglu et al. (2019)
gen acemoglu_demo=1 if e_polity2>0 & e_polity2!=. & (e_fh_status==2 | e_fh_status==1)
replace acemoglu_demo=0 if (e_polity2<=0 & e_polity2!=.) | e_fh_status==3
replace acemoglu_demo=1 if e_polity2>0 & e_polity2!=. & e_fh_status==. & (e_chga_demo==1 | e_boix_regime==1)
replace acemoglu_demo=1 if (e_fh_status==2 | e_fh_status==1) & e_polity2==. & (e_chga_demo==1 | e_boix_regime==1)
replace acemoglu_demo=0 if e_polity2>0  & e_fh_status==. & e_chga_demo==0 & e_boix_regime==0
replace acemoglu_demo=0 if (e_fh_status==2 | e_fh_status==1 | e_fh_status==.) & e_polity2==. & e_chga_demo==0 &  e_boix_regime==0


******** GREG: generating the level before democratization taking inequality 5 years before or, if not available, 4, 3, 2, 1 or 0 years before. (Based on interpolated grg values to ensure sufficient observations)
gen pre_acemoglu_ineq_best_grg_ip = L5.grg_ip  if acemoglu_demo==0 & F.acemoglu_demo==1
replace pre_acemoglu_ineq_best_grg_ip = L4.grg_ip  if acemoglu_demo==0 & F.acemoglu_demo==1 & L5.grg_ip ==.
replace pre_acemoglu_ineq_best_grg_ip = L3.grg_ip  if acemoglu_demo==0 & F.acemoglu_demo==1 & L5.grg_ip ==. & L4.grg_ip ==.
replace pre_acemoglu_ineq_best_grg_ip = L2.grg_ip  if acemoglu_demo==0 & F.acemoglu_demo==1 & L5.grg_ip ==. & L4.grg_ip ==. & L3.grg_ip ==.
replace pre_acemoglu_ineq_best_grg_ip = L.grg_ip  if acemoglu_demo==0 & F.acemoglu_demo==1 & L5.grg_ip ==. & L4.grg_ip ==. & L3.grg_ip ==. & L2.grg_ip ==.
replace pre_acemoglu_ineq_best_grg_ip = grg_ip  if acemoglu_demo==0 & F.acemoglu_demo==1 & L5.grg_ip ==. & L4.grg_ip ==. & L3.grg_ip ==. & L2.grg_ip ==. & L.grg_ip ==.
replace pre_acemoglu_ineq_best_grg_ip = F.grg_ip  if acemoglu_demo==0 & F.acemoglu_demo==1 & L5.grg_ip ==. & L4.grg_ip ==. & L3.grg_ip ==. & L2.grg_ip ==. & L.grg_ip ==. & grg_ip ==.
replace pre_acemoglu_ineq_best_grg_ip = L.pre_acemoglu_ineq_best_grg_ip if acemoglu_demo!=0
replace pre_acemoglu_ineq_best_grg_ip = grg_ip  if pre_acemoglu_ineq_best_grg_ip == .


******** Access to public services by social group: generating the level before democratization taking inequality 5 years before or, if not available, 4, 3, 2, 1 or 0 years before
gen pre_acemoglu_ineq_best_SEI = L5.SEI  if acemoglu_demo==0 & F.acemoglu_demo==1
replace pre_acemoglu_ineq_best_SEI = L4.SEI  if acemoglu_demo==0 & F.acemoglu_demo==1 & L5.SEI ==.
replace pre_acemoglu_ineq_best_SEI = L3.SEI  if acemoglu_demo==0 & F.acemoglu_demo==1 & L5.SEI ==. & L4.SEI ==.
replace pre_acemoglu_ineq_best_SEI = L2.SEI  if acemoglu_demo==0 & F.acemoglu_demo==1 & L5.SEI ==. & L4.SEI ==. & L3.SEI ==.
replace pre_acemoglu_ineq_best_SEI = L.SEI  if acemoglu_demo==0 & F.acemoglu_demo==1 & L5.SEI ==. & L4.SEI ==. & L3.SEI ==. & L2.SEI ==.
replace pre_acemoglu_ineq_best_SEI = SEI  if acemoglu_demo==0 & F.acemoglu_demo==1 & L5.SEI ==. & L4.SEI ==. & L3.SEI ==. & L2.SEI ==. & L.SEI ==.
replace pre_acemoglu_ineq_best_SEI = F.SEI  if acemoglu_demo==0 & F.acemoglu_demo==1 & L5.SEI ==. & L4.SEI ==. & L3.SEI ==. & L2.SEI ==. & L.SEI ==. & SEI ==.
replace pre_acemoglu_ineq_best_SEI = L.pre_acemoglu_ineq_best_SEI if acemoglu_demo!=0
replace pre_acemoglu_ineq_best_SEI = SEI  if pre_acemoglu_ineq_best_SEI == .


******* Inequality (Omoeva et al): generating the level before democratization taking inequality 5 years before or, if not available, 4, 3, 2, 1 or 0 years before
gen pre_acemoglu_ineq_best_ggini = L5.ggini  if acemoglu_demo==0 & F.acemoglu_demo==1
replace pre_acemoglu_ineq_best_ggini = L4.ggini  if acemoglu_demo==0 & F.acemoglu_demo==1 & L5.ggini ==.
replace pre_acemoglu_ineq_best_ggini = L3.ggini  if acemoglu_demo==0 & F.acemoglu_demo==1 & L5.ggini ==. & L4.ggini ==.
replace pre_acemoglu_ineq_best_ggini = L2.ggini  if acemoglu_demo==0 & F.acemoglu_demo==1 & L5.ggini ==. & L4.ggini ==. & L3.ggini ==.
replace pre_acemoglu_ineq_best_ggini = L.ggini  if acemoglu_demo==0 & F.acemoglu_demo==1 & L5.ggini ==. & L4.ggini ==. & L3.ggini ==. & L2.ggini ==.
replace pre_acemoglu_ineq_best_ggini = ggini  if acemoglu_demo==0 & F.acemoglu_demo==1 & L5.ggini ==. & L4.ggini ==. & L3.ggini ==. & L2.ggini ==. & L.ggini ==.
replace pre_acemoglu_ineq_best_ggini = F.ggini  if acemoglu_demo==0 & F.acemoglu_demo==1 & L5.ggini ==. & L4.ggini ==. & L3.ggini ==. & L2.ggini ==. & L.ggini ==. & ggini ==.
replace pre_acemoglu_ineq_best_ggini = L.pre_acemoglu_ineq_best_ggini if acemoglu_demo!=0
replace pre_acemoglu_ineq_best_ggini = ggini  if pre_acemoglu_ineq_best_ggini == .

*** Acemoglu et al. analysis
eststo: xtreg SEI L.acemoglu_demo L.latent_gdppc_mean_log i.year, fe cluster(country_id)
eststo: xtreg grg L.acemoglu_demo L.latent_gdppc_mean_log i.year, fe cluster(country_id)
eststo: xtreg ggini L.acemoglu_demo L.latent_gdppc_mean_log i.year, fe cluster(country_id)

eststo: xtreg SEI L.c.acemoglu_demo##c.L.pre_acemoglu_ineq_best_SEI L.latent_gdppc_mean_log i.year, cluster(country_id) fe
testparm L.c.acemoglu_demo##c.L.pre_acemoglu_ineq_best_SEI

eststo: xtreg grg L.c.acemoglu_demo##c.L.pre_acemoglu_ineq_best_grg_ip L.latent_gdppc_mean_log i.year, cluster(country_id) fe
testparm L.c.acemoglu_demo##c.L.pre_acemoglu_ineq_best_grg_ip

eststo: xtreg ggini L.c.acemoglu_demo##c.L.pre_acemoglu_ineq_best_ggini L.latent_gdppc_mean_log i.year, cluster(country_id) fe
testparm L.c.acemoglu_demo##c.L.pre_acemoglu_ineq_best_ggini

esttab using TA15.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3)) drop(*.year) order(L.acemoglu_demo cL.acemoglu_demo#cL.pre_acemoglu_ineq_best_*  L.latent_gdppc_mean_log) replace
eststo clear 




****************************************************************
********** Alternative democracy measures: Continuous  *********
****************************************************************

************************
*** Table A16: V-Dem ***
************************
eststo: xtreg SEI L.v2x_polyarchy L.latent_gdppc_mean_log i.year, fe cluster(country_id)
eststo: xtreg grg L.v2x_polyarchy L.latent_gdppc_mean_log i.year, fe cluster(country_id)
eststo: xtreg ggini L.v2x_polyarchy L.latent_gdppc_mean_log i.year, fe cluster(country_id)

eststo: xtreg SEI L.c.v2x_polyarchy##c.L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log i.year, cluster(country_id) fe
testparm L.c.v2x_polyarchy##c.L.pre_demo_ineq_best_SEI

eststo: xtreg grg L.c.v2x_polyarchy##c.L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log i.year, cluster(country_id) fe
testparm L.c.v2x_polyarchy##c.L.pre_demo_ineq_best_grg_ip

eststo: xtreg ggini L.c.v2x_polyarchy##c.L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log i.year, cluster(country_id) fe
testparm L.c.v2x_polyarchy##c.L.pre_demo_ineq_best_ggini


esttab using TA16.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N r2, fmt(0 3)) drop(*.year) order(L.v2x_polyarchy cL.v2x_polyarchy#cL.pre_demo_ineq_best_*  L.latent_gdppc_mean_log) replace
eststo clear 

**********************
*** Table A17: UDS ***
**********************
eststo: xtreg SEI L.e_uds_mean L.latent_gdppc_mean_log i.year, fe cluster(country_id)
eststo: xtreg grg L.e_uds_mean L.latent_gdppc_mean_log i.year, fe cluster(country_id)
eststo: xtreg ggini L.e_uds_mean L.latent_gdppc_mean_log i.year, fe cluster(country_id)

eststo: xtreg SEI c.L.e_uds_mean##c.L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log i.year, fe cluster(country_id)
testparm c.L.e_uds_mean##c.L.pre_demo_ineq_best_SEI

eststo: xtreg grg c.L.e_uds_mean##c.L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log i.year, fe cluster(country_id)
testparm c.L.e_uds_mean##c.L.pre_demo_ineq_best_grg_ip

eststo: xtreg ggini c.L.e_uds_mean##c.L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log i.year, fe cluster(country_id)
testparm c.L.e_uds_mean##c.L.pre_demo_ineq_best_ggini

esttab using TA17.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N r2, fmt(0 3)) drop(*.year) order(L.e_uds_mean cL.e_uds_mean#cL.pre_demo_ineq_best_*  L.latent_gdppc_mean_log) replace
eststo clear 




****************************************************************
********** Alternative democracy measures: Event studies *******
****************************************************************

********************************************
*** Figure A4 (Left-hand panel): LIED 6  ***
********************************************

* Drop variables from previous event analysis
eststo clear
drop transition pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post
graph drop _all


** Transition variable
gen transition = 0
recode transition (0=1) if lexical_index_6==1 & L.lexical_index_6==0
recode transition (0=.) if lexical_index_6==.

** Dummies pre/post democratization **
g pre_20_15=0
g pre_15_10=0
g pre_10_5=0
g pre_5_0=0
g event=0
g post_0_5=0
g post_5_10=0
g post_10_15=0
g post_15_20=0

label variable pre_20_15 "-20 to -15"
label variable pre_15_10 "-15 to -10"
label variable pre_10_5 "-10 to -5"
label variable pre_5_0 "-5 to 0"

label variable post_0_5 "0 to 5"
label variable post_5_10 "5 to 10"
label variable post_10_15 "10 to 15"
label variable post_15_20 "15 to 20"

recode pre_20_15 (0=1) if F20.transition ==1 & lexical_index_6==0 | F19.transition ==1 & lexical_index_6==0 | F18.transition ==1 & lexical_index_6==0 | F17.transition ==1 & lexical_index_6==0 | F16.transition ==1 & lexical_index_6==0 
recode pre_15_10 (0=1) if F15.transition ==1 & lexical_index_6==0 | F14.transition ==1 & lexical_index_6==0 | F13.transition ==1 & lexical_index_6==0 | F12.transition ==1 & lexical_index_6==0 | F11.transition ==1 & lexical_index_6==0 
recode pre_10_5 (0=1) if F10.transition ==1 & lexical_index_6==0 | F9.transition ==1 & lexical_index_6==0 | F8.transition ==1 & lexical_index_6==0 | F7.transition ==1 & lexical_index_6==0 | F6.transition ==1 & lexical_index_6==0 
recode pre_5_0 (0=1) if F5.transition ==1 & lexical_index_6==0 | F4.transition ==1 & lexical_index_6==0 | F3.transition ==1 & lexical_index_6==0 | F2.transition ==1 & lexical_index_6==0 | F1.transition ==1 & lexical_index_6==0 
recode event (0=1) if transition==1
recode post_0_5 (0=1) if L1.transition==1 & lexical_index_6==1 | L2.transition==1 & lexical_index_6==1 | L3.transition==1 & lexical_index_6==1| L4.transition==1 & lexical_index_6==1| L5.transition==1 & lexical_index_6==1
recode post_5_10 (0=1) if L6.transition==1 & lexical_index_6==1 | L7.transition==1 & lexical_index_6==1 | L8.transition==1 & lexical_index_6==1| L9.transition==1 & lexical_index_6==1| L10.transition==1 & lexical_index_6==1
recode post_10_15 (0=1) if L11.transition==1 & lexical_index_6==1 | L12.transition==1 & lexical_index_6==1 | L13.transition==1 & lexical_index_6==1| L14.transition==1 & lexical_index_6==1| L15.transition==1 & lexical_index_6==1
recode post_15_20 (0=1) if L16.transition==1 & lexical_index_6==1 | L17.transition==1 & lexical_index_6==1 | L18.transition==1 & lexical_index_6==1| L19.transition==1 & lexical_index_6==1| L20.transition==1 & lexical_index_6==1

** Variable for following democractic years
g post_post=0
recode post_post (0=1) if lexical_index_6 == 1 & post_0_5==0 & post_5_10==0  & post_10_15==0 & post_15_20==0

* Median of upper tercile
centile pre_demoL6_ineq_best_SEI, centile(83)
centile pre_demoL6_ineq_best_grg_ip, centile(83)
centile pre_demoL6_ineq_best_ggini, centile(83)

** Estimates and event graph: SEI **
xtreg SEI pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demoL6_ineq_best_SEI >=.7867794, fe cluster(country_id)

eststo m1: qui margins, dydx(pre* event post*) post
coefplot m1, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from democratization") title(" " "V-Dem", color(black)) name(graph1)

** Estimates and event graph: GRG **
xtreg grg pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demoL6_ineq_best_grg_ip >=.6962401, fe cluster(country_id)

eststo m2: qui margins, dydx(pre* event post*) post
coefplot m2, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from democratization") title(" " "Alesina et al.", color(black)) name(graph2)

** Estimates and event graph: GGINI **
xtreg ggini pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demoL6_ineq_best_ggini >=.1999601, fe cluster(country_id) 

eststo m3: qui margins, dydx(pre* event post*) post
coefplot m3, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from democratization") title(" " "Omoeva et al.", color(black)) name(graph3)

graph combine graph1 graph2 graph3, rows(3) name(fgA4L)
graph display fgA4L, ysize(5) xsize(3)
graph export "fgA4L.emf", replace 
graph export "fgA4L.pdf", replace


********************************************
*** Figure A4 (Right-hand panel): LIED 6 ***
********************************************

graph drop _all

** Estimates and event graph: SEI **
xtreg SEI pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demoL6_ineq_best_SEI <.7867794, fe cluster(country_id)

eststo m1: qui margins, dydx(pre* event post*) post
coefplot m1, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from democratization") title(" " "V-Dem", color(black)) name(graph1)

** Estimates and event graph: GRG **
xtreg grg pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demoL6_ineq_best_grg_ip <.6962401, fe cluster(country_id)

eststo m2: qui margins, dydx(pre* event post*) post
coefplot m2, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from democratization") title(" " "Alesina et al.", color(black)) name(graph2)

** Estimates and event graph: GGINI **
xtreg ggini pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demoL6_ineq_best_ggini <.1999601, fe cluster(country_id) 

eststo m3: qui margins, dydx(pre* event post*) post
coefplot m3, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from democratization") title(" " "Omoeva et al.", color(black)) name(graph3)

graph combine graph1 graph2 graph3, rows(3) name(fgA4R)
graph display fgA4R, ysize(5) xsize(3)
graph export "fgA4R.emf", replace 
graph export "fgA4R.pdf", replace



*******************************************
*** Figure A5 (left-hand panel): LIED 4 ***
*******************************************

* Drop variables from previous event analysis
eststo clear
drop transition pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post
graph drop _all


** Transition variable
gen transition = 0
recode transition (0=1) if lexical_index_4==1 & L.lexical_index_4==0
recode transition (0=.) if lexical_index_4==.

** Dummies pre/post democratization **
g pre_20_15=0
g pre_15_10=0
g pre_10_5=0
g pre_5_0=0
g event=0
g post_0_5=0
g post_5_10=0
g post_10_15=0
g post_15_20=0

label variable pre_20_15 "-20 to -15"
label variable pre_15_10 "-15 to -10"
label variable pre_10_5 "-10 to -5"
label variable pre_5_0 "-5 to 0"

label variable post_0_5 "0 to 5"
label variable post_5_10 "5 to 10"
label variable post_10_15 "10 to 15"
label variable post_15_20 "15 to 20"

recode pre_20_15 (0=1) if F20.transition ==1 & lexical_index_4==0 | F19.transition ==1 & lexical_index_4==0 | F18.transition ==1 & lexical_index_4==0 | F17.transition ==1 & lexical_index_4==0 | F16.transition ==1 & lexical_index_4==0 
recode pre_15_10 (0=1) if F15.transition ==1 & lexical_index_4==0 | F14.transition ==1 & lexical_index_4==0 | F13.transition ==1 & lexical_index_4==0 | F12.transition ==1 & lexical_index_4==0 | F11.transition ==1 & lexical_index_4==0 
recode pre_10_5 (0=1) if F10.transition ==1 & lexical_index_4==0 | F9.transition ==1 & lexical_index_4==0 | F8.transition ==1 & lexical_index_4==0 | F7.transition ==1 & lexical_index_4==0 | F6.transition ==1 & lexical_index_4==0 
recode pre_5_0 (0=1) if F5.transition ==1 & lexical_index_4==0 | F4.transition ==1 & lexical_index_4==0 | F3.transition ==1 & lexical_index_4==0 | F2.transition ==1 & lexical_index_4==0 | F1.transition ==1 & lexical_index_4==0 
recode event (0=1) if transition==1
recode post_0_5 (0=1) if L1.transition==1 & lexical_index_4==1 | L2.transition==1 & lexical_index_4==1 | L3.transition==1 & lexical_index_4==1| L4.transition==1 & lexical_index_4==1| L5.transition==1 & lexical_index_4==1
recode post_5_10 (0=1) if L6.transition==1 & lexical_index_4==1 | L7.transition==1 & lexical_index_4==1 | L8.transition==1 & lexical_index_4==1| L9.transition==1 & lexical_index_4==1| L10.transition==1 & lexical_index_4==1
recode post_10_15 (0=1) if L11.transition==1 & lexical_index_4==1 | L12.transition==1 & lexical_index_4==1 | L13.transition==1 & lexical_index_4==1| L14.transition==1 & lexical_index_4==1| L15.transition==1 & lexical_index_4==1
recode post_15_20 (0=1) if L16.transition==1 & lexical_index_4==1 | L17.transition==1 & lexical_index_4==1 | L18.transition==1 & lexical_index_4==1| L19.transition==1 & lexical_index_4==1| L20.transition==1 & lexical_index_4==1

** Variable for following democractic years
g post_post=0
recode post_post (0=1) if lexical_index_4 == 1 & post_0_5==0 & post_5_10==0  & post_10_15==0 & post_15_20==0

* Median of upper tercile
centile pre_demoL4_ineq_best_SEI, centile(83)
centile pre_demoL4_ineq_best_grg_ip, centile(83)
centile pre_demoL4_ineq_best_ggini, centile(83)

** Estimates and event graph: SEI **
xtreg SEI pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demoL4_ineq_best_SEI >=.7883167 , fe cluster(country_id)

eststo m1: qui margins, dydx(pre* event post*) post
coefplot m1, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from democratization") title(" " "V-Dem", color(black)) name(graph1)

** Estimates and event graph: GRG **
xtreg grg pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demoL4_ineq_best_grg_ip >=.6962401, fe cluster(country_id)

eststo m2: qui margins, dydx(pre* event post*) post
coefplot m2, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from democratization") title(" " "Alesina et al.", color(black)) name(graph2)

** Estimates and event graph: GGINI **
xtreg ggini pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demoL4_ineq_best_ggini >=.2017673, fe cluster(country_id) 

eststo m3: qui margins, dydx(pre* event post*) post
coefplot m3, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from democratization") title(" " "Omoeva et al.", color(black)) name(graph3)

graph combine graph1 graph2 graph3, rows(3) name(fgA5L)
graph display fgA5L, ysize(5) xsize(3)
graph export "fgA5L.emf", replace 
graph export "fgA5L.pdf", replace


********************************************
*** Figure A5 (Right-hand panel): LIED 4 ***
********************************************

graph drop _all

** Estimates and event graph: SEI **
xtreg SEI pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demoL4_ineq_best_SEI <.7883167, fe cluster(country_id)

eststo m1: qui margins, dydx(pre* event post*) post
coefplot m1, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from democratization") title(" " "V-Dem", color(black)) name(graph1)

** Estimates and event graph: GRG **
xtreg grg pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demoL4_ineq_best_grg_ip <.6962401, fe cluster(country_id)

eststo m2: qui margins, dydx(pre* event post*) post
coefplot m2, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from democratization") title(" " "Alesina et al.", color(black)) name(graph2)

** Estimates and event graph: GGINI **
xtreg ggini pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demoL4_ineq_best_ggini <.2017673, fe cluster(country_id) 

eststo m3: qui margins, dydx(pre* event post*) post
coefplot m3, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from democratization") title(" " "Omoeva et al.", color(black)) name(graph3)

graph combine graph1 graph2 graph3, rows(3) name(fgA5R)
graph display fgA5R, ysize(5) xsize(3)
graph export "fgA5R.emf", replace 
graph export "fgA5R.pdf", replace



****************************************
*** Figure A6 (Left-hand panel): BMR ***
****************************************

* Drop variables from previous event analysis
eststo clear
drop transition pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post
graph drop _all


** Transition variable
gen transition = 0
recode transition (0=1) if e_boix_regime==1 & L.e_boix_regime==0
recode transition (0=.) if e_boix_regime==.

** Dummies pre/post democratization **
g pre_20_15=0
g pre_15_10=0
g pre_10_5=0
g pre_5_0=0
g event=0
g post_0_5=0
g post_5_10=0
g post_10_15=0
g post_15_20=0

label variable pre_20_15 "-20 to -15"
label variable pre_15_10 "-15 to -10"
label variable pre_10_5 "-10 to -5"
label variable pre_5_0 "-5 to 0"

label variable post_0_5 "0 to 5"
label variable post_5_10 "5 to 10"
label variable post_10_15 "10 to 15"
label variable post_15_20 "15 to 20"

recode pre_20_15 (0=1) if F20.transition ==1 & e_boix_regime==0 | F19.transition ==1 & e_boix_regime==0 | F18.transition ==1 & e_boix_regime==0 | F17.transition ==1 & e_boix_regime==0 | F16.transition ==1 & e_boix_regime==0 
recode pre_15_10 (0=1) if F15.transition ==1 & e_boix_regime==0 | F14.transition ==1 & e_boix_regime==0 | F13.transition ==1 & e_boix_regime==0 | F12.transition ==1 & e_boix_regime==0 | F11.transition ==1 & e_boix_regime==0 
recode pre_10_5 (0=1) if F10.transition ==1 & e_boix_regime==0 | F9.transition ==1 & e_boix_regime==0 | F8.transition ==1 & e_boix_regime==0 | F7.transition ==1 & e_boix_regime==0 | F6.transition ==1 & e_boix_regime==0 
recode pre_5_0 (0=1) if F5.transition ==1 & e_boix_regime==0 | F4.transition ==1 & e_boix_regime==0 | F3.transition ==1 & e_boix_regime==0 | F2.transition ==1 & e_boix_regime==0 | F1.transition ==1 & e_boix_regime==0 
recode event (0=1) if transition==1
recode post_0_5 (0=1) if L1.transition==1 & e_boix_regime==1 | L2.transition==1 & e_boix_regime==1 | L3.transition==1 & e_boix_regime==1| L4.transition==1 & e_boix_regime==1| L5.transition==1 & e_boix_regime==1
recode post_5_10 (0=1) if L6.transition==1 & e_boix_regime==1 | L7.transition==1 & e_boix_regime==1 | L8.transition==1 & e_boix_regime==1| L9.transition==1 & e_boix_regime==1| L10.transition==1 & e_boix_regime==1
recode post_10_15 (0=1) if L11.transition==1 & e_boix_regime==1 | L12.transition==1 & e_boix_regime==1 | L13.transition==1 & e_boix_regime==1| L14.transition==1 & e_boix_regime==1| L15.transition==1 & e_boix_regime==1
recode post_15_20 (0=1) if L16.transition==1 & e_boix_regime==1 | L17.transition==1 & e_boix_regime==1 | L18.transition==1 & e_boix_regime==1| L19.transition==1 & e_boix_regime==1| L20.transition==1 & e_boix_regime==1

** Variable for following democractic years
g post_post=0
recode post_post (0=1) if e_boix_regime == 1 & post_0_5==0 & post_5_10==0  & post_10_15==0 & post_15_20==0

* Median of upper tercile
centile pre_demobmr_ineq_best_SEI, centile(83)
centile pre_demobmr_ineq_best_grg_ip, centile(83)
centile pre_demobmr_ineq_best_ggini, centile(83)

** Estimates and event graph: SEI **
xtreg SEI pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demobmr_ineq_best_SEI >=.7818601, fe cluster(country_id)

eststo m1: qui margins, dydx(pre* event post*) post
coefplot m1, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from democratization") title(" " "V-Dem", color(black)) name(graph1)

** Estimates and event graph: GRG **
xtreg grg pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demobmr_ineq_best_grg_ip >=.6968509, fe cluster(country_id)

eststo m2: qui margins, dydx(pre* event post*) post
coefplot m2, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(3.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from democratization") title(" " "Alesina et al.", color(black)) name(graph2)

** Estimates and event graph: GGINI **
xtreg ggini pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demobmr_ineq_best_ggini >=.2002232, fe cluster(country_id) 

eststo m3: qui margins, dydx(pre* event post*) post
coefplot m3, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from democratization") title(" " "Omoeva et al.", color(black)) name(graph3)

graph combine graph1 graph2 graph3, rows(3) name(fgA6L)
graph display fgA6L, ysize(5) xsize(3)
graph export "fgA6L.emf", replace 
graph export "fgA6L.pdf", replace


*****************************************
*** Figure A6 (Right-hand panel): BMR ***
*****************************************
graph drop _all

** Estimates and event graph: SEI **
xtreg SEI pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demobmr_ineq_best_SEI <.7818601, fe cluster(country_id)

eststo m1: qui margins, dydx(pre* event post*) post
coefplot m1, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from democratization") title(" " "V-Dem", color(black)) name(graph1)

** Estimates and event graph: GRG **
xtreg grg pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demobmr_ineq_best_grg_ip <.6968509, fe cluster(country_id)

eststo m2: qui margins, dydx(pre* event post*) post
coefplot m2, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(3.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from democratization") title(" " "Alesina et al.", color(black)) name(graph2)

** Estimates and event graph: GGINI **
xtreg ggini pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demobmr_ineq_best_ggini <.2002232, fe cluster(country_id) 

eststo m3: qui margins, dydx(pre* event post*) post
coefplot m3, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from democratization") title(" " "Omoeva et al.", color(black)) name(graph3)

graph combine graph1 graph2 graph3, rows(3) name(fgA6R)
graph display fgA6R, ysize(5) xsize(3)
graph export "fgA6R.emf", replace 
graph export "fgA6R.pdf", replace



****************************************************
*** Figure A7 (Left-hand panel): Acemoglu et al. ***
****************************************************

* Drop variables from previous event analysis
eststo clear
drop transition pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post
graph drop _all


** Transition variable
gen transition = 0
recode transition (0=1) if acemoglu_demo==1 & L.acemoglu_demo==0
recode transition (0=.) if acemoglu_demo==.

** Dummies pre/post democratization **
g pre_20_15=0
g pre_15_10=0
g pre_10_5=0
g pre_5_0=0
g event=0
g post_0_5=0
g post_5_10=0
g post_10_15=0
g post_15_20=0

label variable pre_20_15 "-20 to -15"
label variable pre_15_10 "-15 to -10"
label variable pre_10_5 "-10 to -5"
label variable pre_5_0 "-5 to 0"

label variable post_0_5 "0 to 5"
label variable post_5_10 "5 to 10"
label variable post_10_15 "10 to 15"
label variable post_15_20 "15 to 20"

recode pre_20_15 (0=1) if F20.transition ==1 & acemoglu_demo==0 | F19.transition ==1 & acemoglu_demo==0 | F18.transition ==1 & acemoglu_demo==0 | F17.transition ==1 & acemoglu_demo==0 | F16.transition ==1 & acemoglu_demo==0 
recode pre_15_10 (0=1) if F15.transition ==1 & acemoglu_demo==0 | F14.transition ==1 & acemoglu_demo==0 | F13.transition ==1 & acemoglu_demo==0 | F12.transition ==1 & acemoglu_demo==0 | F11.transition ==1 & acemoglu_demo==0 
recode pre_10_5 (0=1) if F10.transition ==1 & acemoglu_demo==0 | F9.transition ==1 & acemoglu_demo==0 | F8.transition ==1 & acemoglu_demo==0 | F7.transition ==1 & acemoglu_demo==0 | F6.transition ==1 & acemoglu_demo==0 
recode pre_5_0 (0=1) if F5.transition ==1 & acemoglu_demo==0 | F4.transition ==1 & acemoglu_demo==0 | F3.transition ==1 & acemoglu_demo==0 | F2.transition ==1 & acemoglu_demo==0 | F1.transition ==1 & acemoglu_demo==0 
recode event (0=1) if transition==1
recode post_0_5 (0=1) if L1.transition==1 & acemoglu_demo==1 | L2.transition==1 & acemoglu_demo==1 | L3.transition==1 & acemoglu_demo==1| L4.transition==1 & acemoglu_demo==1| L5.transition==1 & acemoglu_demo==1
recode post_5_10 (0=1) if L6.transition==1 & acemoglu_demo==1 | L7.transition==1 & acemoglu_demo==1 | L8.transition==1 & acemoglu_demo==1| L9.transition==1 & acemoglu_demo==1| L10.transition==1 & acemoglu_demo==1
recode post_10_15 (0=1) if L11.transition==1 & acemoglu_demo==1 | L12.transition==1 & acemoglu_demo==1 | L13.transition==1 & acemoglu_demo==1| L14.transition==1 & acemoglu_demo==1| L15.transition==1 & acemoglu_demo==1
recode post_15_20 (0=1) if L16.transition==1 & acemoglu_demo==1 | L17.transition==1 & acemoglu_demo==1 | L18.transition==1 & acemoglu_demo==1| L19.transition==1 & acemoglu_demo==1| L20.transition==1 & acemoglu_demo==1

** Variable for following democractic years
g post_post=0
recode post_post (0=1) if acemoglu_demo == 1 & post_0_5==0 & post_5_10==0  & post_10_15==0 & post_15_20==0

* Median of upper tercile
centile pre_acemoglu_ineq_best_SEI, centile(83)
centile pre_acemoglu_ineq_best_grg_ip, centile(83)
centile pre_acemoglu_ineq_best_ggini, centile(83)

** Estimates and event graph: SEI **
xtreg SEI pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_acemoglu_ineq_best_SEI >=.7815527 , fe cluster(country_id)

eststo m1: qui margins, dydx(pre* event post*) post
coefplot m1, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from democratization") title(" " "V-Dem", color(black)) name(graph1)

** Estimates and event graph: GRG **
xtreg grg pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_acemoglu_ineq_best_grg_ip >=.6974547, fe cluster(country_id)

eststo m2: qui margins, dydx(pre* event post*) post
coefplot m2, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(3.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from democratization") title(" " "Alesina et al.", color(black)) name(graph2)

** Estimates and event graph: GGINI **
xtreg ggini pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_acemoglu_ineq_best_ggini >=.1991847, fe cluster(country_id) 

eststo m3: qui margins, dydx(pre* event post*) post
coefplot m3, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from democratization") title(" " "Omoeva et al.", color(black)) name(graph3)

graph combine graph1 graph2 graph3, rows(3) name(fgA7L)
graph display fgA7L, ysize(5) xsize(3)
graph export "fgA7L.emf", replace 
graph export "fgA7L.pdf", replace



*****************************************************
*** Figure A7 (Right-hand panel): Acemoglu et al. ***
*****************************************************
graph drop _all

** Estimates and event graph: SEI **
xtreg SEI pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_acemoglu_ineq_best_SEI <.7815527 , fe cluster(country_id)

eststo m1: qui margins, dydx(pre* event post*) post
coefplot m1, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from democratization") title(" " "V-Dem", color(black)) name(graph1)

** Estimates and event graph: GRG **
xtreg grg pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_acemoglu_ineq_best_grg_ip <.6974547, fe cluster(country_id)

eststo m2: qui margins, dydx(pre* event post*) post
coefplot m2, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(3.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from democratization") title(" " "Alesina et al.", color(black)) name(graph2)

** Estimates and event graph: GGINI **
xtreg ggini pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_acemoglu_ineq_best_ggini <.1991847, fe cluster(country_id) 

eststo m3: qui margins, dydx(pre* event post*) post
coefplot m3, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from democratization") title(" " "Omoeva et al.", color(black)) name(graph3)

graph combine graph1 graph2 graph3, rows(3) name(fgA7R)
graph display fgA7R, ysize(5) xsize(3)
graph export "fgA7R.emf", replace 
graph export "fgA7R.pdf", replace
eststo clear


******************************************************
****************** Longer lags ***********************
******************************************************

************************
*** Table A18: V-DEM ***
************************

* 5 years
eststo: xtreg SEI L5.lexical_index_5 L5.latent_gdppc_mean_log i.year, fe cluster(country_id)

eststo: xtreg SEI c.L5.lexical_index_5##c.L5.pre_demo_ineq_best_SEI L5.latent_gdppc_mean_log i.year, cluster(country_id) fe
testparm L5.lexical_index_5##c.L5.pre_demo_ineq_best_SEI


* 10 years
eststo: xtreg SEI L10.lexical_index_5 L10.latent_gdppc_mean_log i.year, fe cluster(country_id)

eststo: xtreg SEI c.L10.lexical_index_5##c.L10.pre_demo_ineq_best_SEI L10.latent_gdppc_mean_log i.year, cluster(country_id) fe
testparm c.L10.lexical_index_5##c.L10.pre_demo_ineq_best_SEI

esttab using TA18.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3)) order(L5.lexical_index_5 L10.lexical_index_5 cL5.lexical_index_5#cL5.pre_demo_ineq_best_* cL10.lexical_index_5#cL10.pre_demo_ineq_best_* L5.latent_gdppc_mean_log L10.latent_gdppc_mean_log) drop(*.year) replace
eststo clear 



*********************************
*** Table A19: Alesina et al. ***
*********************************

* 5 years
eststo: xtreg grg L5.lexical_index_5 L5.latent_gdppc_mean_log i.year, fe cluster(country_id)

eststo: xtreg grg c.L5.lexical_index_5##c.L5.pre_demo_ineq_best_grg_ip L5.latent_gdppc_mean_log i.year, cluster(country_id) fe
testparm c.L5.lexical_index_5##c.L5.pre_demo_ineq_best_grg_ip

esttab using TA19.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3)) drop(*.year) order(L5.lexical_index_5 cL5.lexical_index_5#cL5.pre_demo_ineq_best_* L5.latent_gdppc_mean_log) replace
eststo clear 


********************************
*** Table A20: Omoeva et al. ***
********************************

* 5 years
eststo: xtreg ggini L5.lexical_index_5 L5.latent_gdppc_mean_log i.year, fe cluster(country_id)

eststo: xtreg ggini c.L5.lexical_index_5##c.L5.pre_demo_ineq_best_ggini L5.latent_gdppc_mean_log i.year, cluster(country_id) fe
testparm c.L5.lexical_index_5##c.L5.pre_demo_ineq_best_ggini

* 10 years
eststo: xtreg ggini L10.lexical_index_5 L10.latent_gdppc_mean_log i.year, fe cluster(country_id)

eststo: xtreg ggini c.L10.lexical_index_5##c.L10.pre_demo_ineq_best_ggini L10.latent_gdppc_mean_log i.year, cluster(country_id) fe
testparm c.L10.lexical_index_5##c.L10.pre_demo_ineq_best_ggini

esttab using TA20.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3)) drop(*.year) order(L5.lexical_index_5 L10.lexical_index_5 cL5.lexical_index_5#cL5.pre_demo_ineq_best_* cL10.lexical_index_5#cL10.pre_demo_ineq_best_* L5.latent_gdppc_mean_log L10.latent_gdppc_mean_log) replace
eststo clear



*******************************************************
*******************  Longer panels ********************
*******************************************************

*************************
*** Table A21: 5-year ***
*************************
eststo: xtreg SEI L.lexical_index_5 L.latent_gdppc_mean_log i.year if fiveyears==1, fe cluster(country_id)
eststo: xtreg ggini L.lexical_index_5 L.latent_gdppc_mean_log i.year if fiveyears==1, fe cluster(country_id)

eststo: xtreg SEI c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log i.year if fiveyears==1, cluster(country_id) fe
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI

eststo: xtreg ggini c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log i.year if fiveyears==1, cluster(country_id) fe
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini

esttab using TA21.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3)) drop(*.year) order(L.lexical_index_5 cL.lexical_index_5#cL.pre_demo_ineq_best_* L.latent_gdppc_mean_log) replace
eststo clear

**************************
*** Table A22: 10-year ***
***************************
eststo: xtreg SEI L.lexical_index_5 L.latent_gdppc_mean_log i.year if tenyears==1, fe cluster(country_id)
eststo: xtreg ggini L.lexical_index_5 L.latent_gdppc_mean_log i.year if tenyears==1, fe cluster(country_id)

eststo: xtreg SEI c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log i.year if tenyears==1, cluster(country_id) fe
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI

eststo: xtreg ggini c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log i.year if tenyears==1, cluster(country_id) fe
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini

esttab using TA22.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3)) drop(*.year) order(L.lexical_index_5 cL.lexical_index_5#cL.pre_demo_ineq_best_* L.latent_gdppc_mean_log) replace
eststo clear 



**********************************************
*********** Lagged dependent variables *******
**********************************************

****************************************
*** Table A23: Different lagged DV's ***
****************************************

* 1 Year
eststo: xtreg SEI L.SEI L.lexical_index_5 L.latent_gdppc_mean_log i.year, fe cluster(country_id)

eststo: xtreg ggini L.ggini L.lexical_index_5 L.latent_gdppc_mean_log i.year, fe cluster(country_id)

eststo: xtreg SEI L.SEI c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log i.year, fe cluster(country_id)
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI

eststo: xtreg ggini L.ggini c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log i.year, fe cluster(country_id)
testparm L.ggini c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini

* 2 Years
eststo: xtreg SEI L2.SEI L.lexical_index_5 L.latent_gdppc_mean_log i.year, fe cluster(country_id)

eststo: xtreg ggini L2.ggini L.lexical_index_5 L.latent_gdppc_mean_log i.year, fe cluster(country_id)

eststo: xtreg SEI L2.SEI c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log i.year, fe cluster(country_id)
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI

eststo: xtreg ggini L2.ggini c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log i.year, fe cluster(country_id)
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini

* 3 Years
eststo: xtreg SEI L3.SEI L.lexical_index_5 L.latent_gdppc_mean_log i.year, fe cluster(country_id)

eststo: xtreg ggini L3.ggini L.lexical_index_5 L.latent_gdppc_mean_log i.year, fe cluster(country_id)

eststo: xtreg SEI L3.SEI c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log i.year, fe cluster(country_id)
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI

eststo: xtreg ggini L3.ggini c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log i.year, fe cluster(country_id)
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini

esttab using TA23.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3))  order(L.lexical_index_5 cL.lexical_index_5#cL.pre_demo_ineq_best_* L.latent_gdppc_mean_log L.SEI L.ggini L2.SEI L2.ggini L3.SEI L3.ggini) drop(*.year) replace
eststo clear


*********************************************************
*** Table A24: Mutliple lagged DV's in same estimates ***
*********************************************************
eststo: xtreg SEI L.SEI L2.SEI L3.SEI L.lexical_index_5 L.latent_gdppc_mean_log i.year, fe cluster(country_id)

eststo: xtreg ggini L.ggini L2.ggini L3.ggini L.lexical_index_5 L.latent_gdppc_mean_log i.year, fe cluster(country_id)

eststo: xtreg SEI L.SEI L2.SEI L3.SEI c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log i.year, fe cluster(country_id)
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI

eststo: xtreg ggini L.ggini L2.ggini L3.ggini c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log i.year, fe cluster(country_id)
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini

esttab using TA24.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3))  order(L.lexical_index_5 cL.lexical_index_5#cL.pre_demo_ineq_best_* L.latent_gdppc_mean_log) drop(*.year) replace
eststo clear


***************************************************
*** Table A25: Alesina et al. (Not yearly data) ***
***************************************************
egen time=group(year) if grg!=.
xtset country_id time

eststo: xtreg grg L.grg L.lexical_index_5 L.latent_gdppc_mean_log i.time, fe cluster(country_id)

eststo: xtreg grg L.grg c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log i.time, fe cluster(country_id)
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip

esttab using TA25.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3))  order(L.lexical_index_5 cL.lexical_index_5#cL.pre_demo_ineq_best_* L.latent_gdppc_mean_log) drop(*.time) replace
eststo clear

xtset country_id year




********************************************************
************* Table A26: System GMM *********************
********************************************************

*** Unconditional
eststo: xtabond2 SEI L.lexical_index_5 L.latent_gdppc_mean_log i.year, gmm(L.lexical_index_5 L.latent_gdppc_mean_log, collapse equation(both)) iv(i.year) robust small two orthog artests(2)

eststo: xtabond2 grg L.lexical_index_5 L.latent_gdppc_mean_log i.year, gmm(L.lexical_index_5 L.latent_gdppc_mean_log, collapse equation(both)) iv(i.year) robust small two orthog artests(2)

eststo: xtabond2 ggini L.lexical_index_5 L.latent_gdppc_mean_log i.year, gmm(L.lexical_index_5 L.latent_gdppc_mean_log, collapse equation(both)) iv(i.year) robust small two orthog artests(2)

*** Conditional on predemocratic inequality
eststo: xtabond2 SEI c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log i.year, gmm(c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log, collapse equation(both)) iv(i.year) robust small two orthog artests(2)
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI

eststo: xtabond2 grg c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log i.year, gmm(c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log, collapse equation(both)) iv(i.year) robust small two orthog artests(2)
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip

eststo: xtabond2 ggini c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log i.year,gmm(c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log, collapse equation(both)) iv(i.year) robust small two orthog artests(2)
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini

esttab using TA26.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3))  order(L.lexical_index_5 cL.lexical_index_5#cL.pre_demo_ineq_best_* L.latent_gdppc_mean_log) drop(*.year) replace
eststo clear






********************************************************
******************* Excluding regions ******************
********************************************************

****************************************
*** Table A27: E. Europe and C. Asia ***
****************************************
eststo: xtreg SEI L.lexical_index_5 L.latent_gdppc_mean_log i.year if e_regionpol_6C!=1, fe cluster(country_id)

eststo: xtreg grg L.lexical_index_5 L.latent_gdppc_mean_log i.year if e_regionpol_6C!=1, fe cluster(country_id)

eststo: xtreg ggini L.lexical_index_5 L.latent_gdppc_mean_log i.year if e_regionpol_6C!=1, fe cluster(country_id)

eststo: xtreg SEI c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log i.year if e_regionpol_6C!=1, cluster(country_id) fe
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI

eststo: xtreg grg c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log i.year if e_regionpol_6C!=1, cluster(country_id) fe
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip

eststo: xtreg ggini c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log i.year if e_regionpol_6C!=1, cluster(country_id) fe
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini

esttab using TA27.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3)) order(L.lexical_index_5 cL.lexical_index_5#cL.pre_demo_ineq_best_* L.pre_demo_ineq_best_*) drop(*.year) replace
eststo clear 


***********************************************
*** Table A28: L. America and the Carribean ***
************************************************
eststo: xtreg SEI L.lexical_index_5 L.latent_gdppc_mean_log i.year if e_regionpol_6C!=2, fe cluster(country_id)

eststo: xtreg grg L.lexical_index_5 L.latent_gdppc_mean_log i.year if e_regionpol_6C!=2, fe cluster(country_id)

eststo: xtreg ggini L.lexical_index_5 L.latent_gdppc_mean_log i.year if e_regionpol_6C!=2, fe cluster(country_id)

eststo: xtreg SEI c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log i.year if e_regionpol_6C!=2, cluster(country_id) fe
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI

eststo: xtreg grg c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log i.year if e_regionpol_6C!=2, cluster(country_id) fe
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip

eststo: xtreg ggini c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log i.year if e_regionpol_6C!=2, cluster(country_id) fe
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini

esttab using TA28.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3)) order(L.lexical_index_5 cL.lexical_index_5#cL.pre_demo_ineq_best_* L.pre_demo_ineq_best_*) drop(*.year) replace
eststo clear 


***********************
*** Table A29: MENA ***
***********************
eststo: xtreg SEI L.lexical_index_5 L.latent_gdppc_mean_log i.year if e_regionpol_6C!=3, fe cluster(country_id)

eststo: xtreg grg L.lexical_index_5 L.latent_gdppc_mean_log i.year if e_regionpol_6C!=3, fe cluster(country_id)

eststo: xtreg ggini L.lexical_index_5 L.latent_gdppc_mean_log i.year if e_regionpol_6C!=3, fe cluster(country_id)

eststo: xtreg SEI c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log i.year if e_regionpol_6C!=3, cluster(country_id) fe
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI

eststo: xtreg grg c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log i.year if e_regionpol_6C!=3, cluster(country_id) fe
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip

eststo: xtreg ggini c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log i.year if e_regionpol_6C!=3, cluster(country_id) fe
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini

esttab using TA29.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3)) order(L.lexical_index_5 cL.lexical_index_5#cL.pre_demo_ineq_best_* L.pre_demo_ineq_best_*) drop(*.year) replace
eststo clear 


**********************
*** Table A30: SSA ***
**********************
eststo: xtreg SEI L.lexical_index_5 L.latent_gdppc_mean_log i.year if e_regionpol_6C!=4, fe cluster(country_id)

eststo: xtreg grg L.lexical_index_5 L.latent_gdppc_mean_log i.year if e_regionpol_6C!=4, fe cluster(country_id)

eststo: xtreg ggini L.lexical_index_5 L.latent_gdppc_mean_log i.year if e_regionpol_6C!=4, fe cluster(country_id)

eststo: xtreg SEI c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log i.year if e_regionpol_6C!=4, cluster(country_id) fe
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI

eststo: xtreg grg c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log i.year if e_regionpol_6C!=4, cluster(country_id) fe
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip

eststo: xtreg ggini c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log i.year if e_regionpol_6C!=4, cluster(country_id) fe
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini

esttab using TA30.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3)) order(L.lexical_index_5 cL.lexical_index_5#cL.pre_demo_ineq_best_* L.pre_demo_ineq_best_*) drop(*.year) replace
eststo clear 


*******************************************
*** Table A31: W. Europe and N. America ***
*******************************************
eststo: xtreg SEI L.lexical_index_5 L.latent_gdppc_mean_log i.year if e_regionpol_6C!=5, fe cluster(country_id)

eststo: xtreg grg L.lexical_index_5 L.latent_gdppc_mean_log i.year if e_regionpol_6C!=5, fe cluster(country_id)

eststo: xtreg ggini L.lexical_index_5 L.latent_gdppc_mean_log i.year if e_regionpol_6C!=5, fe cluster(country_id)

eststo: xtreg SEI c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log i.year if e_regionpol_6C!=5, cluster(country_id) fe
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI

eststo: xtreg grg c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log i.year if e_regionpol_6C!=5, cluster(country_id) fe
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip

eststo: xtreg ggini c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log i.year if e_regionpol_6C!=5, cluster(country_id) fe
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini

esttab using TA31.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3)) order(L.lexical_index_5 cL.lexical_index_5#cL.pre_demo_ineq_best_* L.pre_demo_ineq_best_*) drop(*.year) replace
eststo clear 

***********************************
*** Table A32: Asia and Pacific ***
***********************************
eststo: xtreg SEI L.lexical_index_5 L.latent_gdppc_mean_log i.year if e_regionpol_6C!=6, fe cluster(country_id)

eststo: xtreg grg L.lexical_index_5 L.latent_gdppc_mean_log i.year if e_regionpol_6C!=6, fe cluster(country_id)

eststo: xtreg ggini L.lexical_index_5 L.latent_gdppc_mean_log i.year if e_regionpol_6C!=6, fe cluster(country_id)

eststo: xtreg SEI c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log i.year if e_regionpol_6C!=6, cluster(country_id) fe
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI

eststo: xtreg grg c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log i.year if e_regionpol_6C!=6, cluster(country_id) fe
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip

eststo: xtreg ggini c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log i.year if e_regionpol_6C!=6, cluster(country_id) fe
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini

esttab using TA32.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3)) order(L.lexical_index_5 cL.lexical_index_5#cL.pre_demo_ineq_best_* L.pre_demo_ineq_best_*) drop(*.year) replace
eststo clear 




***********************************************
*** Table A33: Temporally restricted sample ***
***********************************************

* 1945
eststo: xtreg SEI L.lexical_index_5 L.latent_gdppc_mean_log i.year if year >1945, fe cluster(country_id)

eststo: xtreg SEI c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log i.year if year >1945, fe cluster(country_id)
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI

* 1989
eststo: xtreg SEI L.lexical_index_5 L.latent_gdppc_mean_log i.year if year >=1990, fe cluster(country_id)

eststo: xtreg SEI c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log i.year if year >=1990, fe cluster(country_id)
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI

esttab using TA33.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3)) order(L.lexical_index_5 cL.lexical_index_5#cL.pre_demo_ineq_best_* L.pre_demo_ineq_best_*) drop(*.year) replace
eststo clear 




************************************************************************
********************** Placebo tests ***********************************
************************************************************************

*******************************************************************
*** Figure A8 (left-hand panel): 10 year lead placebo treatment ***
*******************************************************************

**** generating placebo with leads  *****
generate plac_lead10 = F10.lexical_index_5

* Drop variables from previous event analysis
eststo clear
drop transition pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post
graph drop _all

** Transition variable
gen transition = 0
recode transition (0=1) if plac_lead10==1 & L.plac_lead10==0
recode transition (0=.) if plac_lead10==.

* V-Dem (10)
gen pre_lead10_ineq_best_SEI = L5.SEI if plac_lead10==0 & F.plac_lead10==1
replace pre_lead10_ineq_best_SEI = L4.SEI if plac_lead10==0 & F.plac_lead10==1 & L5.SEI==.
replace pre_lead10_ineq_best_SEI = L3.SEI if plac_lead10==0 & F.plac_lead10==1 & L5.SEI==. & L4.SEI==.
replace pre_lead10_ineq_best_SEI = L2.SEI if plac_lead10==0 & F.plac_lead10==1 & L5.SEI==. & L4.SEI==. & L3.SEI==.
replace pre_lead10_ineq_best_SEI = L.SEI if plac_lead10==0 & F.plac_lead10==1 & L5.SEI==. & L4.SEI==. & L3.SEI==. & L2.SEI==.
replace pre_lead10_ineq_best_SEI = SEI if plac_lead10==0 & F.plac_lead10==1 & L5.SEI==. & L4.SEI==. & L3.SEI==. & L2.SEI==. & L.SEI==.
replace pre_lead10_ineq_best_SEI = F.SEI if plac_lead10==0 & F.plac_lead10==1 & L5.SEI==. & L4.SEI==. & L3.SEI==. & L2.SEI==. & L.SEI==. & SEI==.

replace pre_lead10_ineq_best_SEI = L.pre_lead10_ineq_best_SEI if plac_lead10!=0
replace pre_lead10_ineq_best_SEI = SEI if pre_lead10_ineq_best_SEI == .


* Alesina et al (10)
gen pre_lead10_ineq_best_grg_ip = L5.grg_ip if plac_lead10==0 & F.plac_lead10==1
replace pre_lead10_ineq_best_grg_ip = L4.grg_ip if plac_lead10==0 & F.plac_lead10==1 & L5.grg_ip==.
replace pre_lead10_ineq_best_grg_ip = L3.grg_ip if plac_lead10==0 & F.plac_lead10==1 & L5.grg_ip==. & L4.grg_ip==.
replace pre_lead10_ineq_best_grg_ip = L2.grg_ip if plac_lead10==0 & F.plac_lead10==1 & L5.grg_ip==. & L4.grg_ip==. & L3.grg_ip==.
replace pre_lead10_ineq_best_grg_ip = L.grg_ip if plac_lead10==0 & F.plac_lead10==1 & L5.grg_ip==. & L4.grg_ip==. & L3.grg_ip==. & L2.grg_ip==.
replace pre_lead10_ineq_best_grg_ip = grg_ip if plac_lead10==0 & F.plac_lead10==1 & L5.grg_ip==. & L4.grg_ip==. & L3.grg_ip==. & L2.grg_ip==. & L.grg_ip==.
replace pre_lead10_ineq_best_grg_ip = F.grg_ip if plac_lead10==0 & F.plac_lead10==1 & L5.grg_ip==. & L4.grg_ip==. & L3.grg_ip==. & L2.grg_ip==. & L.grg_ip==. & grg_ip==.

replace pre_lead10_ineq_best_grg_ip = L.pre_lead10_ineq_best_grg_ip if plac_lead10!=0
replace pre_lead10_ineq_best_grg_ip = grg_ip if pre_lead10_ineq_best_grg_ip == .


* Omoeva et al. (10)
gen pre_lead10_ineq_best_ggini = L5.ggini if plac_lead10==0 & F.plac_lead10==1
replace pre_lead10_ineq_best_ggini = L4.ggini if plac_lead10==0 & F.plac_lead10==1 & L5.ggini==.
replace pre_lead10_ineq_best_ggini = L3.ggini if plac_lead10==0 & F.plac_lead10==1 & L5.ggini==. & L4.ggini==.
replace pre_lead10_ineq_best_ggini = L2.ggini if plac_lead10==0 & F.plac_lead10==1 & L5.ggini==. & L4.ggini==. & L3.ggini==.
replace pre_lead10_ineq_best_ggini = L.ggini if plac_lead10==0 & F.plac_lead10==1 & L5.ggini==. & L4.ggini==. & L3.ggini==. & L2.ggini==.
replace pre_lead10_ineq_best_ggini = ggini if plac_lead10==0 & F.plac_lead10==1 & L5.ggini==. & L4.ggini==. & L3.ggini==. & L2.ggini==. & L.ggini==.
replace pre_lead10_ineq_best_ggini = F.ggini if plac_lead10==0 & F.plac_lead10==1 & L5.ggini==. & L4.ggini==. & L3.ggini==. & L2.ggini==. & L.ggini==. & ggini==.

replace pre_lead10_ineq_best_ggini = L.pre_lead10_ineq_best_ggini if plac_lead10!=0
replace pre_lead10_ineq_best_ggini = ggini if pre_lead10_ineq_best_ggini == .
 

** Dummies pre/post democratization **
g pre_20_15=0
g pre_15_10=0
g pre_10_5=0
g pre_5_0=0
g event=0
g post_0_5=0
g post_5_10=0
g post_10_15=0
g post_15_20=0

label variable pre_20_15 "-20 to -15"
label variable pre_15_10 "-15 to -10"
label variable pre_10_5 "-10 to -5"
label variable pre_5_0 "-5 to 0"

label variable post_0_5 "0 to 5"
label variable post_5_10 "5 to 10"
label variable post_10_15 "10 to 15"
label variable post_15_20 "15 to 20"

recode pre_20_15 (0=1) if F20.transition ==1 & plac_lead10==0 | F19.transition ==1 & plac_lead10==0 | F18.transition ==1 & plac_lead10==0 | F17.transition ==1 & plac_lead10==0 | F16.transition ==1 & plac_lead10==0 
recode pre_15_10 (0=1) if F15.transition ==1 & plac_lead10==0 | F14.transition ==1 & plac_lead10==0 | F13.transition ==1 & plac_lead10==0 | F12.transition ==1 & plac_lead10==0 | F11.transition ==1 & plac_lead10==0 
recode pre_10_5 (0=1) if F10.transition ==1 & plac_lead10==0 | F9.transition ==1 & plac_lead10==0 | F8.transition ==1 & plac_lead10==0 | F7.transition ==1 & plac_lead10==0 | F6.transition ==1 & plac_lead10==0 
recode pre_5_0 (0=1) if F5.transition ==1 & plac_lead10==0 | F4.transition ==1 & plac_lead10==0 | F3.transition ==1 & plac_lead10==0 | F2.transition ==1 & plac_lead10==0 | F1.transition ==1 & plac_lead10==0 
recode event (0=1) if transition==1
recode post_0_5 (0=1) if L1.transition==1 & plac_lead10==1 | L2.transition==1 & plac_lead10==1 | L3.transition==1 & plac_lead10==1| L4.transition==1 & plac_lead10==1| L5.transition==1 & plac_lead10==1
recode post_5_10 (0=1) if L6.transition==1 & plac_lead10==1 | L7.transition==1 & plac_lead10==1 | L8.transition==1 & plac_lead10==1| L9.transition==1 & plac_lead10==1| L10.transition==1 & plac_lead10==1
recode post_10_15 (0=1) if L11.transition==1 & plac_lead10==1 | L12.transition==1 & plac_lead10==1 | L13.transition==1 & plac_lead10==1| L14.transition==1 & plac_lead10==1| L15.transition==1 & plac_lead10==1
recode post_15_20 (0=1) if L16.transition==1 & plac_lead10==1 | L17.transition==1 & plac_lead10==1 | L18.transition==1 & plac_lead10==1| L19.transition==1 & plac_lead10==1| L20.transition==1 & plac_lead10==1

** Variable for following democractic years
g post_post=0
recode post_post (0=1) if plac_lead10 == 1 & post_0_5==0 & post_5_10==0  & post_10_15==0 & post_15_20==0

* Median of the upper tercile
centile pre_lead10_ineq_best_SEI, centile(83)
centile pre_lead10_ineq_best_grg_ip, centile(83)
centile pre_lead10_ineq_best_ggini, centile(83)

** Estimates and event graph: SEI **
xtreg SEI pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demo_ineq_best_SEI >=.7898539, fe cluster(country_id)

eststo m1: qui margins, dydx(pre* event post*) post
coefplot m1, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from placebo democratization") title(" " "V-Dem", color(black)) name(graph1)

** Estimates and event graph: GRG **
xtreg grg pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demo_ineq_best_grg_ip >=.6949809, fe cluster(country_id)

*xline 3.5 (omitts pre 20_15)
eststo m2: qui margins, dydx(pre* event post*) post
coefplot m2, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(3.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from placebo democratization") title(" " "Alesina et al.", color(black)) name(graph2)

** Estimates and event graph: GGINI **
xtreg ggini pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demo_ineq_best_ggini >=.1990162, fe cluster(country_id) 

eststo m3: qui margins, dydx(pre* event post*) post
coefplot m3, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from placebo democratization") title(" " "Omoeva et al.", color(black)) name(graph3)

graph combine graph1 graph2 graph3, rows(3) name(fgA8L)
graph display fgA8L, ysize(5) xsize(3)
graph export "fgA8L.emf", replace 
graph export "fgA8L.pdf", replace
eststo clear 

********************************************************************
*** Figure A8 (right-hand panel): 10 year lead placebo treatment ***
********************************************************************
graph drop _all

** Estimates and event graph: SEI **
xtreg SEI pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demo_ineq_best_SEI <.7898539, fe cluster(country_id)

eststo m1: qui margins, dydx(pre* event post*) post
coefplot m1, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from placebo democratization") title(" " "V-Dem", color(black)) name(graph1)

** Estimates and event graph: GRG **
xtreg grg pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demo_ineq_best_grg_ip <.6949809, fe cluster(country_id)

*xline 3.5 (omitts pre 20_15)
eststo m2: qui margins, dydx(pre* event post*) post
coefplot m2, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(3.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from placebo democratization") title(" " "Alesina et al.", color(black)) name(graph2)

** Estimates and event graph: GGINI **
xtreg ggini pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_demo_ineq_best_ggini <.1990162, fe cluster(country_id) 

eststo m3: qui margins, dydx(pre* event post*) post
coefplot m3, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from placebo democratization") title(" " "Omoeva et al.", color(black)) name(graph3)

graph combine graph1 graph2 graph3, rows(3) name(fgA8R)
graph display fgA8R, ysize(5) xsize(3)
graph export "fgA8R.emf", replace 
graph export "fgA8R.pdf", replace
eststo clear 

***********************************************************************************************
*** Figure A9 (left-hand panel): Randomized country-year placebo treatments, entire sample  ***
***********************************************************************************************

* Drop variables from previous event analysis
eststo clear
drop transition pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post
graph drop _all

*
set seed 12345
generate random_placebo = runiformint(0, 1)

** Transition variable
gen transition = 0
recode transition (0=1) if random_placebo==1 & L.random_placebo==0
recode transition (0=.) if random_placebo==.

* V-Dem (10)
gen pre_random_plac_ineq_best_SEI = L5.SEI if random_placebo==0 & F.random_placebo==1
replace pre_random_plac_ineq_best_SEI = L4.SEI if random_placebo==0 & F.random_placebo==1 & L5.SEI==.
replace pre_random_plac_ineq_best_SEI = L3.SEI if random_placebo==0 & F.random_placebo==1 & L5.SEI==. & L4.SEI==.
replace pre_random_plac_ineq_best_SEI = L2.SEI if random_placebo==0 & F.random_placebo==1 & L5.SEI==. & L4.SEI==. & L3.SEI==.
replace pre_random_plac_ineq_best_SEI = L.SEI if random_placebo==0 & F.random_placebo==1 & L5.SEI==. & L4.SEI==. & L3.SEI==. & L2.SEI==.
replace pre_random_plac_ineq_best_SEI = SEI if random_placebo==0 & F.random_placebo==1 & L5.SEI==. & L4.SEI==. & L3.SEI==. & L2.SEI==. & L.SEI==.
replace pre_random_plac_ineq_best_SEI = F.SEI if random_placebo==0 & F.random_placebo==1 & L5.SEI==. & L4.SEI==. & L3.SEI==. & L2.SEI==. & L.SEI==. & SEI==.

replace pre_random_plac_ineq_best_SEI = L.pre_random_plac_ineq_best_SEI if random_placebo!=0
replace pre_random_plac_ineq_best_SEI = SEI if pre_random_plac_ineq_best_SEI == .


* Alesina et al (10)
gen pre_random_plac_ineq_best_grg_ip = L5.grg_ip if random_placebo==0 & F.random_placebo==1
replace pre_random_plac_ineq_best_grg_ip = L4.grg_ip if random_placebo==0 & F.random_placebo==1 & L5.grg_ip==.
replace pre_random_plac_ineq_best_grg_ip = L3.grg_ip if random_placebo==0 & F.random_placebo==1 & L5.grg_ip==. & L4.grg_ip==.
replace pre_random_plac_ineq_best_grg_ip = L2.grg_ip if random_placebo==0 & F.random_placebo==1 & L5.grg_ip==. & L4.grg_ip==. & L3.grg_ip==.
replace pre_random_plac_ineq_best_grg_ip = L.grg_ip if random_placebo==0 & F.random_placebo==1 & L5.grg_ip==. & L4.grg_ip==. & L3.grg_ip==. & L2.grg_ip==.
replace pre_random_plac_ineq_best_grg_ip = grg_ip if random_placebo==0 & F.random_placebo==1 & L5.grg_ip==. & L4.grg_ip==. & L3.grg_ip==. & L2.grg_ip==. & L.grg_ip==.
replace pre_random_plac_ineq_best_grg_ip = F.grg_ip if random_placebo==0 & F.random_placebo==1 & L5.grg_ip==. & L4.grg_ip==. & L3.grg_ip==. & L2.grg_ip==. & L.grg_ip==. & grg_ip==.

replace pre_random_plac_ineq_best_grg_ip = L.pre_random_plac_ineq_best_grg_ip if random_placebo!=0
replace pre_random_plac_ineq_best_grg_ip = grg_ip if pre_random_plac_ineq_best_grg_ip == .


* Omoeva et al. (10)
gen pre_random_plac_ineq_best_ggini = L5.ggini if random_placebo==0 & F.random_placebo==1
replace pre_random_plac_ineq_best_ggini = L4.ggini if random_placebo==0 & F.random_placebo==1 & L5.ggini==.
replace pre_random_plac_ineq_best_ggini = L3.ggini if random_placebo==0 & F.random_placebo==1 & L5.ggini==. & L4.ggini==.
replace pre_random_plac_ineq_best_ggini = L2.ggini if random_placebo==0 & F.random_placebo==1 & L5.ggini==. & L4.ggini==. & L3.ggini==.
replace pre_random_plac_ineq_best_ggini = L.ggini if random_placebo==0 & F.random_placebo==1 & L5.ggini==. & L4.ggini==. & L3.ggini==. & L2.ggini==.
replace pre_random_plac_ineq_best_ggini = ggini if random_placebo==0 & F.random_placebo==1 & L5.ggini==. & L4.ggini==. & L3.ggini==. & L2.ggini==. & L.ggini==.
replace pre_random_plac_ineq_best_ggini = F.ggini if random_placebo==0 & F.random_placebo==1 & L5.ggini==. & L4.ggini==. & L3.ggini==. & L2.ggini==. & L.ggini==. & ggini==.

replace pre_random_plac_ineq_best_ggini = L.pre_random_plac_ineq_best_ggini if random_placebo!=0
replace pre_random_plac_ineq_best_ggini = ggini if pre_random_plac_ineq_best_ggini == .
 

** Dummies pre/post democratization **
g pre_20_15=0
g pre_15_10=0
g pre_10_5=0
g pre_5_0=0
g event=0
g post_0_5=0
g post_5_10=0
g post_10_15=0
g post_15_20=0

label variable pre_20_15 "-20 to -15"
label variable pre_15_10 "-15 to -10"
label variable pre_10_5 "-10 to -5"
label variable pre_5_0 "-5 to 0"

label variable post_0_5 "0 to 5"
label variable post_5_10 "5 to 10"
label variable post_10_15 "10 to 15"
label variable post_15_20 "15 to 20"

recode pre_20_15 (0=1) if F20.transition ==1 & random_placebo==0 | F19.transition ==1 & random_placebo==0 | F18.transition ==1 & random_placebo==0 | F17.transition ==1 & random_placebo==0 | F16.transition ==1 & random_placebo==0 
recode pre_15_10 (0=1) if F15.transition ==1 & random_placebo==0 | F14.transition ==1 & random_placebo==0 | F13.transition ==1 & random_placebo==0 | F12.transition ==1 & random_placebo==0 | F11.transition ==1 & random_placebo==0 
recode pre_10_5 (0=1) if F10.transition ==1 & random_placebo==0 | F9.transition ==1 & random_placebo==0 | F8.transition ==1 & random_placebo==0 | F7.transition ==1 & random_placebo==0 | F6.transition ==1 & random_placebo==0 
recode pre_5_0 (0=1) if F5.transition ==1 & random_placebo==0 | F4.transition ==1 & random_placebo==0 | F3.transition ==1 & random_placebo==0 | F2.transition ==1 & random_placebo==0 | F1.transition ==1 & random_placebo==0 
recode event (0=1) if transition==1
recode post_0_5 (0=1) if L1.transition==1 & random_placebo==1 | L2.transition==1 & random_placebo==1 | L3.transition==1 & random_placebo==1| L4.transition==1 & random_placebo==1| L5.transition==1 & random_placebo==1
recode post_5_10 (0=1) if L6.transition==1 & random_placebo==1 | L7.transition==1 & random_placebo==1 | L8.transition==1 & random_placebo==1| L9.transition==1 & random_placebo==1| L10.transition==1 & random_placebo==1
recode post_10_15 (0=1) if L11.transition==1 & random_placebo==1 | L12.transition==1 & random_placebo==1 | L13.transition==1 & random_placebo==1| L14.transition==1 & random_placebo==1| L15.transition==1 & random_placebo==1
recode post_15_20 (0=1) if L16.transition==1 & random_placebo==1 | L17.transition==1 & random_placebo==1 | L18.transition==1 & random_placebo==1| L19.transition==1 & random_placebo==1| L20.transition==1 & random_placebo==1

** Variable for following democractic years
g post_post=0
recode post_post (0=1) if random_placebo == 1 & post_0_5==0 & post_5_10==0  & post_10_15==0 & post_15_20==0

* Median of the upper tercile
centile pre_random_plac_ineq_best_SEI, centile(83)
centile pre_random_plac_ineq_best_grg_ip, centile(83)
centile pre_random_plac_ineq_best_ggini, centile(83)

** Estimates and event graph: SEI **
xtreg SEI pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_random_plac_ineq_best_SEI >=.7818601, fe cluster(country_id)

eststo m1: qui margins, dydx(pre* event post*) post
coefplot m1, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from placebo democratization") title(" " "V-Dem", color(black)) name(graph1)

** Estimates and event graph: GRG **
xtreg grg pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_random_plac_ineq_best_grg_ip >=.6923227, fe cluster(country_id)

eststo m2: qui margins, dydx(pre* event post*) post
coefplot m2, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from placebo democratization") title(" " "Alesina et al.", color(black)) name(graph2)

** Estimates and event graph: GGINI **
xtreg ggini pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_random_plac_ineq_best_ggini >=.1987069, fe cluster(country_id) 

eststo m3: qui margins, dydx(pre* event post*) post
coefplot m3, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from placebo democratization") title(" " "Omoeva et al.", color(black)) name(graph3)

graph combine graph1 graph2 graph3, rows(3) name(fgA9L)
graph display fgA9L, ysize(5) xsize(3)
graph export "fgA9L.emf", replace 
graph export "fgA9L.pdf", replace
eststo clear 

***********************************************************************************************
*** Figure A9 (Right-hand panel): Randomized country-year placebo treatments, entire sample ***
***********************************************************************************************
graph drop _all

** Estimates and event graph: SEI **
xtreg SEI pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_random_plac_ineq_best_SEI <.7818601, fe cluster(country_id)

eststo m1: qui margins, dydx(pre* event post*) post
coefplot m1, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from placebo democratization") title(" " "V-Dem", color(black)) name(graph1)

** Estimates and event graph: GRG **
xtreg grg pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_random_plac_ineq_best_grg_ip <.6923227, fe cluster(country_id)

eststo m2: qui margins, dydx(pre* event post*) post
coefplot m2, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from placebo democratization") title(" " "Alesina et al.", color(black)) name(graph2)

** Estimates and event graph: GGINI **
xtreg ggini pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_random_plac_ineq_best_ggini <.1987069, fe cluster(country_id) 

eststo m3: qui margins, dydx(pre* event post*) post
coefplot m3, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from placebo democratization") title(" " "Omoeva et al.", color(black)) name(graph3)

graph combine graph1 graph2 graph3, rows(3) name(fgA9R)
graph display fgA9R, ysize(5) xsize(3)
graph export "fgA9R.emf", replace 
graph export "fgA9R.pdf", replace
eststo clear 


******************************************************************************************************************
*** Figure A10 (left-hand panel): Randomized country-year placebo treatment, sample of democratized countries  ***
******************************************************************************************************************
bys country_id: egen democratized = max(lexical_index_5)

set seed 12345
generate random_placebo_2 = runiformint(0, 1) if democratized==1
recode random_placebo_2 (.=0) if democratized==0

* Drop variables from previous event analysis
eststo clear
drop transition pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post
graph drop _all

** Transition variable
gen transition = 0
recode transition (0=1) if random_placebo_2==1 & L.random_placebo_2==0
recode transition (0=.) if random_placebo_2==.

* V-Dem (10)
gen pre_randomplac2_ineq_best_SEI = L5.SEI if random_placebo_2==0 & F.random_placebo_2==1
replace pre_randomplac2_ineq_best_SEI = L4.SEI if random_placebo_2==0 & F.random_placebo_2==1 & L5.SEI==.
replace pre_randomplac2_ineq_best_SEI = L3.SEI if random_placebo_2==0 & F.random_placebo_2==1 & L5.SEI==. & L4.SEI==.
replace pre_randomplac2_ineq_best_SEI = L2.SEI if random_placebo_2==0 & F.random_placebo_2==1 & L5.SEI==. & L4.SEI==. & L3.SEI==.
replace pre_randomplac2_ineq_best_SEI = L.SEI if random_placebo_2==0 & F.random_placebo_2==1 & L5.SEI==. & L4.SEI==. & L3.SEI==. & L2.SEI==.
replace pre_randomplac2_ineq_best_SEI = SEI if random_placebo_2==0 & F.random_placebo_2==1 & L5.SEI==. & L4.SEI==. & L3.SEI==. & L2.SEI==. & L.SEI==.
replace pre_randomplac2_ineq_best_SEI = F.SEI if random_placebo_2==0 & F.random_placebo_2==1 & L5.SEI==. & L4.SEI==. & L3.SEI==. & L2.SEI==. & L.SEI==. & SEI==.

replace pre_randomplac2_ineq_best_SEI = L.pre_randomplac2_ineq_best_SEI if random_placebo_2!=0
replace pre_randomplac2_ineq_best_SEI = SEI if pre_randomplac2_ineq_best_SEI == .


* Alesina et al (10)
gen pre_randomplac2_ineq_best_grg_ip = L5.grg_ip if random_placebo_2==0 & F.random_placebo_2==1
replace pre_randomplac2_ineq_best_grg_ip = L4.grg_ip if random_placebo_2==0 & F.random_placebo_2==1 & L5.grg_ip==.
replace pre_randomplac2_ineq_best_grg_ip = L3.grg_ip if random_placebo_2==0 & F.random_placebo_2==1 & L5.grg_ip==. & L4.grg_ip==.
replace pre_randomplac2_ineq_best_grg_ip = L2.grg_ip if random_placebo_2==0 & F.random_placebo_2==1 & L5.grg_ip==. & L4.grg_ip==. & L3.grg_ip==.
replace pre_randomplac2_ineq_best_grg_ip = L.grg_ip if random_placebo_2==0 & F.random_placebo_2==1 & L5.grg_ip==. & L4.grg_ip==. & L3.grg_ip==. & L2.grg_ip==.
replace pre_randomplac2_ineq_best_grg_ip = grg_ip if random_placebo_2==0 & F.random_placebo_2==1 & L5.grg_ip==. & L4.grg_ip==. & L3.grg_ip==. & L2.grg_ip==. & L.grg_ip==.
replace pre_randomplac2_ineq_best_grg_ip = F.grg_ip if random_placebo_2==0 & F.random_placebo_2==1 & L5.grg_ip==. & L4.grg_ip==. & L3.grg_ip==. & L2.grg_ip==. & L.grg_ip==. & grg_ip==.

replace pre_randomplac2_ineq_best_grg_ip = L.pre_randomplac2_ineq_best_grg_ip if random_placebo_2!=0
replace pre_randomplac2_ineq_best_grg_ip = grg_ip if pre_randomplac2_ineq_best_grg_ip == .


* Omoeva et al. (10)
gen pre_randomplac2_ineq_best_ggini = L5.ggini if random_placebo_2==0 & F.random_placebo_2==1
replace pre_randomplac2_ineq_best_ggini = L4.ggini if random_placebo_2==0 & F.random_placebo_2==1 & L5.ggini==.
replace pre_randomplac2_ineq_best_ggini = L3.ggini if random_placebo_2==0 & F.random_placebo_2==1 & L5.ggini==. & L4.ggini==.
replace pre_randomplac2_ineq_best_ggini = L2.ggini if random_placebo_2==0 & F.random_placebo_2==1 & L5.ggini==. & L4.ggini==. & L3.ggini==.
replace pre_randomplac2_ineq_best_ggini = L.ggini if random_placebo_2==0 & F.random_placebo_2==1 & L5.ggini==. & L4.ggini==. & L3.ggini==. & L2.ggini==.
replace pre_randomplac2_ineq_best_ggini = ggini if random_placebo_2==0 & F.random_placebo_2==1 & L5.ggini==. & L4.ggini==. & L3.ggini==. & L2.ggini==. & L.ggini==.
replace pre_randomplac2_ineq_best_ggini = F.ggini if random_placebo_2==0 & F.random_placebo_2==1 & L5.ggini==. & L4.ggini==. & L3.ggini==. & L2.ggini==. & L.ggini==. & ggini==.

replace pre_randomplac2_ineq_best_ggini = L.pre_randomplac2_ineq_best_ggini if random_placebo_2!=0
replace pre_randomplac2_ineq_best_ggini = ggini if pre_randomplac2_ineq_best_ggini == .
 

** Dummies pre/post democratization **
g pre_20_15=0
g pre_15_10=0
g pre_10_5=0
g pre_5_0=0
g event=0
g post_0_5=0
g post_5_10=0
g post_10_15=0
g post_15_20=0

label variable pre_20_15 "-20 to -15"
label variable pre_15_10 "-15 to -10"
label variable pre_10_5 "-10 to -5"
label variable pre_5_0 "-5 to 0"

label variable post_0_5 "0 to 5"
label variable post_5_10 "5 to 10"
label variable post_10_15 "10 to 15"
label variable post_15_20 "15 to 20"

recode pre_20_15 (0=1) if F20.transition ==1 & random_placebo_2==0 | F19.transition ==1 & random_placebo_2==0 | F18.transition ==1 & random_placebo_2==0 | F17.transition ==1 & random_placebo_2==0 | F16.transition ==1 & random_placebo_2==0 
recode pre_15_10 (0=1) if F15.transition ==1 & random_placebo_2==0 | F14.transition ==1 & random_placebo_2==0 | F13.transition ==1 & random_placebo_2==0 | F12.transition ==1 & random_placebo_2==0 | F11.transition ==1 & random_placebo_2==0 
recode pre_10_5 (0=1) if F10.transition ==1 & random_placebo_2==0 | F9.transition ==1 & random_placebo_2==0 | F8.transition ==1 & random_placebo_2==0 | F7.transition ==1 & random_placebo_2==0 | F6.transition ==1 & random_placebo_2==0 
recode pre_5_0 (0=1) if F5.transition ==1 & random_placebo_2==0 | F4.transition ==1 & random_placebo_2==0 | F3.transition ==1 & random_placebo_2==0 | F2.transition ==1 & random_placebo_2==0 | F1.transition ==1 & random_placebo_2==0 
recode event (0=1) if transition==1
recode post_0_5 (0=1) if L1.transition==1 & random_placebo_2==1 | L2.transition==1 & random_placebo_2==1 | L3.transition==1 & random_placebo_2==1| L4.transition==1 & random_placebo_2==1| L5.transition==1 & random_placebo_2==1
recode post_5_10 (0=1) if L6.transition==1 & random_placebo_2==1 | L7.transition==1 & random_placebo_2==1 | L8.transition==1 & random_placebo_2==1| L9.transition==1 & random_placebo_2==1| L10.transition==1 & random_placebo_2==1
recode post_10_15 (0=1) if L11.transition==1 & random_placebo_2==1 | L12.transition==1 & random_placebo_2==1 | L13.transition==1 & random_placebo_2==1| L14.transition==1 & random_placebo_2==1| L15.transition==1 & random_placebo_2==1
recode post_15_20 (0=1) if L16.transition==1 & random_placebo_2==1 | L17.transition==1 & random_placebo_2==1 | L18.transition==1 & random_placebo_2==1| L19.transition==1 & random_placebo_2==1| L20.transition==1 & random_placebo_2==1

** Variable for following democractic years
g post_post=0
recode post_post (0=1) if random_placebo_2 == 1 & post_0_5==0 & post_5_10==0  & post_10_15==0 & post_15_20==0

* Median of the upper tercile
centile pre_randomplac2_ineq_best_SEI, centile(83)
centile pre_randomplac2_ineq_best_grg_ip, centile(83)
centile pre_randomplac2_ineq_best_ggini, centile(83)

** Estimates and event graph: SEI **
xtreg SEI pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_randomplac2_ineq_best_SEI >=.7812452, fe cluster(country_id)

eststo m1: qui margins, dydx(pre* event post*) post
coefplot m1, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from placebo democratization") title(" " "V-Dem", color(black)) name(graph1)

** Estimates and event graph: GRG **
xtreg grg pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_randomplac2_ineq_best_grg_ip >=.6840936, fe cluster(country_id)

eststo m2: qui margins, dydx(pre* event post*) post
coefplot m2, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from placebo democratization") title(" " "Alesina et al.", color(black)) name(graph2)

** Estimates and event graph: GGINI **
xtreg ggini pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_randomplac2_ineq_best_ggini >=.1990279, fe cluster(country_id) 

eststo m3: qui margins, dydx(pre* event post*) post
coefplot m3, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from placebo democratization") title(" " "Omoeva et al.", color(black)) name(graph3)

graph combine graph1 graph2 graph3, rows(3) name(fgA10L)
graph display fgA10L, ysize(5) xsize(3)
graph export "fgA10L.emf", replace 
graph export "fgA10L.pdf", replace
eststo clear 


*******************************************************************************************************************
*** Figure A10 (right-hand panel): Randomized country-year placebo treatment, sample of democratized countries  ***
*******************************************************************************************************************
graph drop _all

** Estimates and event graph: SEI **
xtreg SEI pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_randomplac2_ineq_best_SEI <.7812452, fe cluster(country_id)

eststo m1: qui margins, dydx(pre* event post*) post
coefplot m1, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from placebo democratization") title(" " "V-Dem", color(black)) name(graph1)

** Estimates and event graph: GRG **
xtreg grg pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_randomplac2_ineq_best_grg_ip <.6840936, fe cluster(country_id)

eststo m2: qui margins, dydx(pre* event post*) post
coefplot m2, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from placebo democratization") title(" " "Alesina et al.", color(black)) name(graph2)

** Estimates and event graph: GGINI **
xtreg ggini pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log if pre_randomplac2_ineq_best_ggini <.1990279, fe cluster(country_id) 

eststo m3: qui margins, dydx(pre* event post*) post
coefplot m3, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from placebo democratization") title(" " "Omoeva et al.", color(black)) name(graph3)

graph combine graph1 graph2 graph3, rows(3) name(fgA10R)
graph display fgA10R, ysize(5) xsize(3)
graph export "fgA10R.emf", replace
graph export "fgA10R.pdf", replace
eststo clear 


****************************************
*** Figure A11: Democratic breakdown ***
****************************************

* Drop variables from previous event analysis
eststo clear
drop transition pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post
graph drop _all


*** Transition to autocracy variable
gen transition = 0
recode transition (0=1) if lexical_index_5==0 & L.lexical_index_5==1
recode transition (0=.) if lexical_index_5==.

*** Dummies pre/post autocratization ***
g pre_20_15=0
g pre_15_10=0
g pre_10_5=0
g pre_5_0=0
g event=0
g post_0_5=0
g post_5_10=0
g post_10_15=0
g post_15_20=0

recode pre_20_15 (0=1) if F20.transition ==1 & lexical_index_5==1 | F19.transition ==1 & lexical_index_5==1 | F18.transition ==1 & lexical_index_5==1 | F17.transition ==1 & lexical_index_5==1 | F16.transition ==1 & lexical_index_5==1 
recode pre_15_10 (0=1) if F15.transition ==1 & lexical_index_5==1 | F14.transition ==1 & lexical_index_5==1 | F13.transition ==1 & lexical_index_5==1 | F12.transition ==1 & lexical_index_5==1 | F11.transition ==1 & lexical_index_5==1 
recode pre_10_5 (0=1) if F10.transition ==1 & lexical_index_5==1 | F9.transition ==1 & lexical_index_5==1 | F8.transition ==1 & lexical_index_5==1 | F7.transition ==1 & lexical_index_5==1 | F6.transition ==1 & lexical_index_5==1 
recode pre_5_0 (0=1) if F5.transition ==1 & lexical_index_5==1 | F4.transition ==1 & lexical_index_5==1 | F3.transition ==1 & lexical_index_5==1 | F2.transition ==1 & lexical_index_5==1 | F1.transition ==1 & lexical_index_5==1 
recode event (0=1) if transition==1
recode post_0_5 (0=1) if L1.transition==1 & lexical_index_5==0 | L2.transition==1 & lexical_index_5==0 | L3.transition==1 & lexical_index_5==0| L4.transition==1 & lexical_index_5==0| L5.transition==1 & lexical_index_5==0
recode post_5_10 (0=1) if L6.transition==1 & lexical_index_5==0 | L7.transition==1 & lexical_index_5==0 | L8.transition==1 & lexical_index_5==0| L9.transition==1 & lexical_index_5==0| L10.transition==1 & lexical_index_5==0
recode post_10_15 (0=1) if L11.transition==1 & lexical_index_5==0 | L12.transition==1 & lexical_index_5==0 | L13.transition==1 & lexical_index_5==0| L14.transition==1 & lexical_index_5==0| L15.transition==1 & lexical_index_5==0
recode post_15_20 (0=1) if L16.transition==1 & lexical_index_5==0 | L17.transition==1 & lexical_index_5==0 | L18.transition==1 & lexical_index_5==0| L19.transition==1 & lexical_index_5==0| L20.transition==1 & lexical_index_5==0

* Variable for subsequent autocratic years
g post_post=0
recode post_post (0=1) if lexical_index_5 == 0 & post_0_5==0 & post_5_10==0  & post_10_15==0 & post_15_20==0

*Labels
label variable pre_20_15 "-20 to -15"
label variable pre_15_10 "-15 to -10"
label variable pre_10_5 "-10 to -5"
label variable pre_5_0 "-5 to 0"
label variable post_0_5 "0 to 5"
label variable post_5_10 "5 to 10"
label variable post_10_15 "10 to 15"
label variable post_15_20 "15 to 20"

* SEI
xtreg SEI pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log, fe cluster(country_id)
eststo m1: qui margins, dydx(pre* event post*) post
coefplot m1, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from autocratization") title("V-Dem", color(black)) name(graph_1)

* GREG
xtreg grg pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log, fe cluster(country_id)
eststo m1: qui margins, dydx(pre* event post*) post
coefplot m1, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from autocratization") title("Alesina et al.", color(black)) name(graph_2)


* GGINI
xtreg ggini pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log, fe cluster(country_id)
eststo m1: qui margins, dydx(pre* event post*) post
coefplot m1, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(small)) ylabel("", labsize(small))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(small) xtitle(" " "Years from autocratization") title("Omoeva et al.", color(black)) name(graph_3)

graph combine graph_1 graph_2 graph_3, rows(3) name(fgA11)
graph display fgA11, ysize(5) xsize(3)
graph export "fgA11.emf", replace
graph export "fgA11.pdf", replace
eststo clear 



**********************************
****** Figure A12: Mechanisms ****
**********************************

* Copies of lexical_index_5 for visual output using "coefplot"
g lexical_index_5_1 = lexical_index_5
g lexical_index_5_2 = lexical_index_5
g lexical_index_5_3 = lexical_index_5
g lexical_index_5_4 = lexical_index_5
g lexical_index_5_5 = lexical_index_5
g lexical_index_5_6 = lexical_index_5
g lexical_index_5_7 = lexical_index_5
g lexical_index_5_8 = lexical_index_5
g lexical_index_5_9 = lexical_index_5
g lexical_index_5_10 = lexical_index_5
g lexical_index_5_11 = lexical_index_5


*** Upper panel: high pre-democratic inequality subsample ***

* Share of excluded groups
eststo M1: xtreg exclpop_2 L.lexical_index_5_1 L.latent_gdppc_mean_log i.year if pre_demo_ineq_best_SEI >=.7867794, fe cluster(country_id)

* Share of discriminated groups
eststo M2: xtreg discrimpop_2 L.lexical_index_5_2 L.latent_gdppc_mean_log i.year if pre_demo_ineq_best_SEI >=.7867794, fe cluster(country_id)

* Power distributed by group
eststo M3: xtreg power_groups L.lexical_index_5_3 L.latent_gdppc_mean_log i.year if pre_demo_ineq_best_SEI >=.7867794, fe cluster(country_id)

* Range of consultation
eststo M4: xtreg consult L.lexical_index_5_4 L.latent_gdppc_mean_log i.year if pre_demo_ineq_best_SEI >=.7867794, fe cluster(country_id) 

* Civil liberties by social group
eststo M5: xtreg civil_lib_groups L.lexical_index_5_5 L.latent_gdppc_mean_log i.year if pre_demo_ineq_best_SEI >=.7867794, fe cluster(country_id) 

* Access to state business opportunities
eststo M6: xtreg state_business_groups L.lexical_index_5_6 L.latent_gdppc_mean_log i.year if pre_demo_ineq_best_SEI >=.7867794, fe cluster(country_id)

* Access to state jobs by social group
eststo M7: xtreg state_jobs_groups L.lexical_index_5_7 L.latent_gdppc_mean_log i.year if pre_demo_ineq_best_SEI >=.7867794, fe cluster(country_id)

* Public goods vs. particularistic goods
eststo M8: xtreg public_goods L.lexical_index_5_8 L.latent_gdppc_mean_log i.year if pre_demo_ineq_best_SEI >=.7867794, fe cluster(country_id)

* Universal vs. means-tested
eststo M9: xtreg uni_v_means L.lexical_index_5_9 L.latent_gdppc_mean_log i.year if pre_demo_ineq_best_SEI >=.7867794, fe cluster(country_id)

* Access to basic education
eststo M10: xtreg basic_edu L.lexical_index_5_10 L.latent_gdppc_mean_log i.year if pre_demo_ineq_best_SEI >=.7867794, fe cluster(country_id)

* Access to basis healthcare
eststo M11: xtreg basic_health L.lexical_index_5_11 L.latent_gdppc_mean_log i.year if pre_demo_ineq_best_SEI >=.7867794, fe cluster(country_id)

*
coefplot (M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11, label(Low Inequality)), drop(_cons L.latent_gdppc_mean_log i.year *year) level(95) xline(0) ciopts(recast(rcap)) scheme(s2mono) graphregion(fcolor(white) lcolor(white) lwidth(tiny)) coeflabel(L.lexical_index_5_1 = "Ethnic Inclusion" L.lexical_index_5_2 = "Absence of Ethnopol. discrim." L.lexical_index_5_3 = "Power distributed by group" L.lexical_index_5_4 = "Range of consultation" L.lexical_index_5_5 = "Civil liberties by group"  L.lexical_index_5_6  = "Access to state business by group" L.lexical_index_5_7 = "Access to state jobs by group" L.lexical_index_5_8 = "Public vs. particularistic goods" L.lexical_index_5_9 = "Universalistic welfare policy" L.lexical_index_5_10 = "Access to education" L.lexical_index_5_11 = "Access to healthcare") headings(L.lexical_index_5_1 = "{bf:Political inclusion}" L.lexical_index_5_5 = "{bf:Anti-discrimination policies}" L.lexical_index_5_8 = "{bf:Social policies}") title("High predem. ineq. subsample") name(mech1) 


**** Lower panel: Non-high pre-democratic inequality sample ****
eststo clear

* Share of excluded groups
eststo M1: xtreg exclpop_2 L.lexical_index_5_1 L.latent_gdppc_mean_log i.year if pre_demo_ineq_best_SEI <.7867794, fe cluster(country_id)

* Share of discriminated groups
eststo M2: xtreg discrimpop_2 L.lexical_index_5_2 L.latent_gdppc_mean_log i.year if pre_demo_ineq_best_SEI <.7867794, fe cluster(country_id)

* Power distributed by group
eststo M3: xtreg power_groups L.lexical_index_5_3 L.latent_gdppc_mean_log i.year if pre_demo_ineq_best_SEI <.7867794, fe cluster(country_id)

* Range of consultation
eststo M4: xtreg consult L.lexical_index_5_4 L.latent_gdppc_mean_log i.year if pre_demo_ineq_best_SEI <.7867794, fe cluster(country_id) 

* Civil liberties by social group
eststo M5: xtreg civil_lib_groups L.lexical_index_5_5 L.latent_gdppc_mean_log i.year if pre_demo_ineq_best_SEI <.7867794, fe cluster(country_id) 

* Access to state business opportunities
eststo M6: xtreg state_business_groups L.lexical_index_5_6 L.latent_gdppc_mean_log i.year if pre_demo_ineq_best_SEI <.7867794, fe cluster(country_id)

* Access to state jobs by social group
eststo M7: xtreg state_jobs_groups L.lexical_index_5_7 L.latent_gdppc_mean_log i.year if pre_demo_ineq_best_SEI <.7867794, fe cluster(country_id)

* Public goods vs. particularistic goods
eststo M8: xtreg public_goods L.lexical_index_5_8 L.latent_gdppc_mean_log i.year if pre_demo_ineq_best_SEI <.7867794, fe cluster(country_id)

* Universal vs. means-tested
eststo M9: xtreg uni_v_means L.lexical_index_5_9 L.latent_gdppc_mean_log i.year if pre_demo_ineq_best_SEI <.7867794, fe cluster(country_id)

* Access to basic education
eststo M10: xtreg basic_edu L.lexical_index_5_10 L.latent_gdppc_mean_log i.year if pre_demo_ineq_best_SEI <.7867794, fe cluster(country_id)

* Access to basis healthcare
eststo M11: xtreg basic_health L.lexical_index_5_11 L.latent_gdppc_mean_log i.year if pre_demo_ineq_best_SEI <.7867794, fe cluster(country_id)

*
coefplot (M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11, label(Low Inequality)), drop(_cons L.latent_gdppc_mean_log i.year *year) level(95) xline(0) ciopts(recast(rcap)) scheme(s2mono) graphregion(fcolor(white) lcolor(white) lwidth(tiny)) coeflabel(L.lexical_index_5_1 = "Ethnic Inclusion" L.lexical_index_5_2 = "Absence of Ethnopol. discrim." L.lexical_index_5_3 = "Power distributed by group" L.lexical_index_5_4 = "Range of consultation" L.lexical_index_5_5 = "Civil liberties by group"  L.lexical_index_5_6  = "Access to state business by group" L.lexical_index_5_7 = "Access to state jobs by group" L.lexical_index_5_8 = "Public vs. particularistic goods" L.lexical_index_5_9 = "Universalistic welfare policy" L.lexical_index_5_10 = "Access to education" L.lexical_index_5_11 = "Access to healthcare") headings(L.lexical_index_5_1 = "{bf:Political inclusion}" L.lexical_index_5_5 = "{bf:Anti-discrimination policies}" L.lexical_index_5_8 = "{bf:Social policies}") title("Non-high predem. ineq. subsample") name(mech2)

graph combine mech1 mech2, rows(2) name(fga12) xcommon 
graph export "fgA12.emf", replace
graph export "fgA12.pdf", replace
eststo clear 



***************************************************
*** Table A34: Ethnic and non-ethnic inequality ***
***************************************************

******** Access to public services by social group: generating the level before democratization taking inequality 5 years before or, if not available, 4, 3, 2, 1 or 0 years before
gen pre_demo_ineq_best_gini_disp = L5.gini_disp  if lexical_index_5==0 & F.lexical_index_5==1
replace pre_demo_ineq_best_gini_disp = L4.gini_disp  if lexical_index_5==0 & F.lexical_index_5==1 & L5.gini_disp ==.
replace pre_demo_ineq_best_gini_disp = L3.gini_disp  if lexical_index_5==0 & F.lexical_index_5==1 & L5.gini_disp ==. & L4.gini_disp ==.
replace pre_demo_ineq_best_gini_disp = L2.gini_disp  if lexical_index_5==0 & F.lexical_index_5==1 & L5.gini_disp ==. & L4.gini_disp ==. & L3.gini_disp ==.
replace pre_demo_ineq_best_gini_disp = L.gini_disp  if lexical_index_5==0 & F.lexical_index_5==1 & L5.gini_disp ==. & L4.gini_disp ==. & L3.gini_disp ==. & L2.gini_disp ==.
replace pre_demo_ineq_best_gini_disp = gini_disp  if lexical_index_5==0 & F.lexical_index_5==1 & L5.gini_disp ==. & L4.gini_disp ==. & L3.gini_disp ==. & L2.gini_disp ==. & L.gini_disp ==.
replace pre_demo_ineq_best_gini_disp = F.gini_disp  if lexical_index_5==0 & F.lexical_index_5==1 & L5.gini_disp ==. & L4.gini_disp ==. & L3.gini_disp ==. & L2.gini_disp ==. & L.gini_disp ==. & gini_disp ==.
replace pre_demo_ineq_best_gini_disp = L.pre_demo_ineq_best_gini_disp if lexical_index_5!=0
replace pre_demo_ineq_best_gini_disp = gini_disp  if pre_demo_ineq_best_gini_disp == .

* Define sample
xtreg SEI c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI c.L.lexical_index_5##c.L.pre_demo_ineq_best_gini_disp  L.latent_gdppc_mean_log i.year, fe cluster(country_id)
gen sample_x = e(sample)
xtreg grg c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip c.L.lexical_index_5##c.L.pre_demo_ineq_best_gini_disp  L.latent_gdppc_mean_log i.year, fe cluster(country_id)
gen sample_y = e(sample)
xtreg ggini c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini c.L.lexical_index_5##c.L.pre_demo_ineq_best_gini_disp  L.latent_gdppc_mean_log i.year, fe cluster(country_id)
gen sample_z = e(sample)

* Original (but restricted sample)
eststo: xtreg SEI c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI L.latent_gdppc_mean_log i.year if sample_x ==1, fe cluster(country_id)
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI

eststo: xtreg grg c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip L.latent_gdppc_mean_log i.year if sample_y ==1, fe cluster(country_id)
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip

eststo: xtreg ggini c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini L.latent_gdppc_mean_log i.year if sample_z ==1., fe cluster(country_id)
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini

* Control for gini_disp
eststo: xtreg SEI c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI L.gini_disp L.latent_gdppc_mean_log i.year if sample_x ==1, fe cluster(country_id)
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI

eststo: xtreg grg c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip L.gini_disp L.latent_gdppc_mean_log i.year if sample_y ==1, fe cluster(country_id)
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip

eststo: xtreg ggini c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini L.gini_disp L.latent_gdppc_mean_log i.year if sample_z ==1, fe cluster(country_id)
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini

* Control for interaction
eststo: xtreg SEI c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI c.L.lexical_index_5##c.L.pre_demo_ineq_best_gini_disp  L.latent_gdppc_mean_log i.year if sample_x ==1, fe cluster(country_id)
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_SEI

eststo: xtreg grg c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip c.L.lexical_index_5##c.L.pre_demo_ineq_best_gini_disp  L.latent_gdppc_mean_log i.year if sample_y ==1, fe cluster(country_id)
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_grg_ip

eststo: xtreg ggini c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini c.L.lexical_index_5##c.L.pre_demo_ineq_best_gini_disp  L.latent_gdppc_mean_log i.year if sample_z ==1, fe cluster(country_id)
testparm c.L.lexical_index_5##c.L.pre_demo_ineq_best_ggini

esttab using TA34.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Countries" "R2 (within)") fmt(0 0 3))  order(L.lexical_index_5 cL.lexical_index_5#cL.pre_demo_ineq_best_SEI cL.lexical_index_5#cL.pre_demo_ineq_best_grg_ip cL.lexical_index_5#cL.pre_demo_ineq_best_ggini L.gini_disp cL.lexical_index_5#cL.pre_demo_ineq_best_gini_disp *L.pre_demo_ineq_best_*) drop(*.year oL.lexical_index_5) replace
eststo clear 


*** Save dataset for merge with group-level data ***
save "Country-level dataset.dta", replace




*****************************************************************************************
*																						*
*																						*
*								Group-level Datasets 									*
*																						*
*																						*
*****************************************************************************************



*******************************************************************
*******************************************************************
******************** Bormann et al. *******************************
*******************************************************************
*******************************************************************

use "Group-level dataset - Bormann et al. 2021.dta", replace

**** Prepare to merge based on V-Dem country_id
generate country_id = .
order country_id, after(country)
replace country_id = 36 if countryname=="Afghanistan"
replace country_id = 12 if countryname=="Albania"
replace country_id = 103 if countryname=="Algeria"
replace country_id = 104 if countryname=="Angola"
replace country_id = 37 if countryname=="Argentina"
replace country_id = 105 if countryname=="Armenia"
replace country_id = 67 if countryname=="Australia"
replace country_id = 144 if countryname=="Austria"
replace country_id = 106 if countryname=="Azerbaijan"
replace country_id = 146 if countryname=="Bahrain"
replace country_id = 24 if countryname=="Bangladesh"
replace country_id = 147 if countryname=="Barbados"
replace country_id = 107 if countryname=="Belarus"
replace country_id = 148 if countryname=="Belgium"
replace country_id = 52 if countryname=="Benin"
replace country_id = 53 if countryname=="Bhutan"
replace country_id = 25 if countryname=="Bolivia"
replace country_id = 150 if countryname=="Bosnia and Herzegovina"
replace country_id = 68 if countryname=="Botswana"
replace country_id = 19 if countryname=="Brazil"
replace country_id = 152 if countryname=="Bulgaria"
replace country_id = 54 if countryname=="Burkina Faso"
replace country_id = 10 if countryname=="Myanmar"
replace country_id = 69 if countryname=="Burundi"
replace country_id = 55 if countryname=="Cambodia"
replace country_id = 108 if countryname=="Cameroon"
replace country_id = 66 if countryname=="Canada"
replace country_id = 70 if countryname=="Cape Verde"
replace country_id = 71 if countryname=="Central African Republic"
replace country_id = 71 if countryname=="CAR"
replace country_id = 109 if countryname=="Chad"
replace country_id = 72 if countryname=="Chile"
replace country_id = 110 if countryname=="China"
replace country_id = 15 if countryname=="Colombia"
replace country_id = 153 if countryname=="Comoros"
replace country_id = 112 if countryname=="Congo"
replace country_id = 111 if countryname=="Democratic Republic of the Congo"
replace country_id = 73 if countryname=="Costa Rica"
replace country_id = 154 if countryname=="Croatia"
replace country_id = 155 if countryname=="Cuba"
replace country_id = 156 if countryname=="Cyprus"
replace country_id = 157 if countryname=="Czech Republic"
replace country_id = 157 if countryname=="Czechoslovakia"
replace country_id = 158 if countryname=="Denmark"
replace country_id = 113 if countryname=="Djibouti"
replace country_id = 114 if countryname=="Dominican Republic"
replace country_id = 75 if countryname=="Ecuador"
replace country_id = 13 if countryname=="Egypt"
replace country_id = 22 if countryname=="El Salvador"
replace country_id = 160 if countryname=="Equatorial Guinea"
replace country_id = 115 if countryname=="Eritrea"
replace country_id = 161 if countryname=="Estonia"
replace country_id = 38 if countryname=="Ethiopia"
replace country_id = 162 if countryname=="Fiji"
replace country_id = 163 if countryname=="Finland"
replace country_id = 76 if countryname=="France"
replace country_id = 116 if countryname=="Gabon"
replace country_id = 118 if countryname=="Georgia"
replace country_id = 77 if countryname=="Germany Federal Republic"
replace country_id = 7 if countryname=="Ghana"
replace country_id = 164 if countryname=="Greece"
replace country_id = 78 if countryname=="Guatemala"
replace country_id = 63 if countryname=="Guinea"
replace country_id = 119 if countryname=="Guinea-Bissau"
replace country_id = 166 if countryname=="Guyana"
replace country_id = 26 if countryname=="Haiti"
replace country_id = 27 if countryname=="Honduras"
replace country_id = 167 if countryname=="Hong Kong"
replace country_id = 210 if countryname=="Hungary"
replace country_id = 168 if countryname=="Iceland"
replace country_id = 39 if countryname=="India"
replace country_id = 56 if countryname=="Indonesia"
replace country_id = 79 if countryname=="Iran"
replace country_id = 80 if countryname=="Iraq"
replace country_id = 81 if countryname=="Ireland"
replace country_id = 169 if countryname=="Israel"
replace country_id = 82 if countryname=="Italy"
replace country_id = 64 if countryname=="Ivory Coast"
replace country_id = 120 if countryname=="Jamaica"
replace country_id = 9 if countryname=="Japan"
replace country_id = 83 if countryname=="Jordan"
replace country_id = 121 if countryname=="Kazakhstan"
replace country_id = 40 if countryname=="Kenya"
replace country_id = 43 if countryname=="Kosovo"
replace country_id = 171 if countryname=="Kuwait"
replace country_id = 122 if countryname=="Kyrgyzstan"
replace country_id = 123 if countryname=="Laos"
replace country_id = 84 if countryname=="Latvia"
replace country_id = 44 if countryname=="Lebanon"
replace country_id = 85 if countryname=="Lesotho"
replace country_id = 86 if countryname=="Liberia"
replace country_id = 124 if countryname=="Libya"
replace country_id = 173 if countryname=="Lithuania"
replace country_id = 174 if countryname=="Luxembourg"
replace country_id = 176 if countryname=="Macedonia"
replace country_id = 125 if countryname=="Madagascar"
replace country_id = 87 if countryname=="Malawi"
replace country_id = 177 if countryname=="Malaysia"
replace country_id = 88 if countryname=="Maldives"
replace country_id = 28 if countryname=="Mali"
replace country_id = 65 if countryname=="Mauretania"
replace country_id = 65 if countryname=="Mauritania"
replace country_id = 180 if countryname=="Mauritius"
replace country_id = 3 if countryname=="Mexico"
replace country_id = 126 if countryname=="Moldova"
replace country_id = 89 if countryname=="Mongolia"
replace country_id = 183 if countryname=="Montenegro"
replace country_id = 90 if countryname=="Morocco"
replace country_id = 57 if countryname=="Mozambique"
replace country_id = 127 if countryname=="Nambibia"
replace country_id = 58 if countryname=="Nepal"
replace country_id = 91 if countryname=="Netherlands"
replace country_id = 185 if countryname=="New Zealand"
replace country_id = 59 if countryname=="Nicaragua"
replace country_id = 60 if countryname=="Niger"
replace country_id = 45 if countryname=="Nigeria"
replace country_id = 186 if countryname=="Norway"
replace country_id = 187 if countryname=="Oman"
replace country_id = 29 if countryname=="Pakistan"
replace country_id = 92 if countryname=="Panama"
replace country_id = 93 if countryname=="Papua New Guinea"
replace country_id = 189 if countryname=="Paraguay"
replace country_id = 30 if countryname=="Peru"
replace country_id = 46 if countryname=="Philippines"
replace country_id = 17 if countryname=="Poland"
replace country_id = 21 if countryname=="Portugal"
replace country_id = 94 if countryname=="Qatar"
replace country_id = 190 if countryname=="Romania"
replace country_id = 11 if countryname=="Russia"
replace country_id = 129 if countryname=="Rwanda"
replace country_id = 196 if countryname=="Sao Tome and Principe"
replace country_id = 197 if countryname=="Saudi Arabia"
replace country_id = 31 if countryname=="Senegal"
replace country_id = 198 if countryname=="Serbia and Montenegro"
replace country_id = 198 if countryname=="Serbia"
replace country_id = 199 if countryname=="Seychelles"
replace country_id = 95 if countryname=="Sierra Leone"
replace country_id = 200 if countryname=="Singapore"
replace country_id = 201 if countryname=="Slovakia"
replace country_id = 202 if countryname=="Slovenia"
replace country_id = 130 if countryname=="Somalia"
replace country_id = 8 if countryname=="South Africa"
replace country_id = 96 if countryname=="Spain"
replace country_id = 131 if countryname=="Sri Lanka"
replace country_id = 33 if countryname=="Sudan"
replace country_id = 32 if countryname=="South Sudan"
replace country_id = 4 if countryname=="Suriname"
replace country_id = 132 if countryname=="Swaziland"
replace country_id = 5 if countryname=="Sweden"
replace country_id = 6 if countryname=="Switzerland"
replace country_id = 97 if countryname=="Syria"
replace country_id = 48 if countryname=="Taiwan"
replace country_id = 133 if countryname=="Tajikistan"
replace country_id = 47 if countryname=="Tanzania"
replace country_id = 49 if countryname=="Thailand"
replace country_id = 117 if countryname=="The Gambia"
replace country_id = 74 if countryname=="Timor Leste"
replace country_id = 134 if countryname=="Togo"
replace country_id = 135 if countryname=="Trinidad and Tobago"
replace country_id = 98 if countryname=="Tunisia"
replace country_id = 99 if countryname=="Turkey"
replace country_id = 136 if countryname=="Turkmenistan"
replace country_id = 50 if countryname=="Uganda"
replace country_id = 100 if countryname=="Ukraine"
replace country_id = 207 if countryname=="United Arab Emirates"
replace country_id = 101 if countryname=="United Kingdom"
replace country_id = 20 if countryname=="United States of America"
replace country_id = 102 if countryname=="Uruguay"
replace country_id = 140 if countryname=="Uzbekistan"
replace country_id = 206 if countryname=="Vanuatu"
replace country_id = 51 if countryname=="Venezuela"
replace country_id = 34 if countryname=="Vietnam"
replace country_id = 14 if countryname=="Yemen"
replace country_id = 61 if countryname=="Zambia"
replace country_id = 62 if countryname=="Zimbabwe"
replace country_id = 127 if countryname=="Namibia"
replace country_id = 117 if countryname=="Gambia"
replace country_id = 41 if countryname=="North Korea"
replace country_id = 42 if countryname=="South Korea"
replace country_id = 111 if countryname=="Congo, DRC"
replace country_id = 112 if countryname=="Congo, Rep."
replace country_id = 64 if countryname=="Ivory Coast"
replace country_id = 64 if countryname=="Cote d'Ivoire"
replace country_id = 13 if countryname=="Egypt, Arab Rep."
replace country_id = 117 if countryname=="Gambia, The"
replace country_id = 122 if countryname=="Kyrgyz Republic"
replace country_id = 123 if countryname=="Lao PDR"
replace country_id = 176 if countryname=="Macedonia, FYR"
replace country_id = 74 if countryname=="Timor-Leste"
replace country_id = 20 if countryname=="United States"
replace country_id = 20 if countryname=="USA"

*** Keep only variables needed for analysis
keep countries_gwid year groupname countryname groupsize nlpc_corr country_id gwgroupid incidence_flag resource_rents

*** Merge ***
merge m:1 country_id year using "Country-level dataset.dta", keepusing(lexical_index_5 latent_gdppc_mean_log pre_demo_ineq_best_SEI)



***********************************************
******************* Figure 5 ******************
***********************************************

* Clear graphs
graph drop _all

*** Generate variable measuring group relative distance to country mean
bys countries_gwid year: egen groupsize_aggregated = total(groupsize) if nlpc_corr!=.
sort gwgroupid year

bys gwgroupid year: gen groupsize_adjusted = groupsize/groupsize_aggregated
bys gwgroupid year: gen groupsize_income = groupsize_adjusted*nlpc_corr
bys countries_gwid year: egen cntry_mean_income = total(groupsize_income)
sort gwgroupid year

bys gwgroupid year: gen distance_cntry_mean = nlpc_corr-cntry_mean_income
bys gwgroupid year: gen distance_cntry_mean_pct = distance_cntry_mean/cntry_mean_income*100


*** Remove empty data points ***
drop if gwgroupid==.
xtset gwgroupid year

*** Sort by group-year
sort gwgroupid year 

*** Group income category variable
g disadvantaged = .
recode disadvantaged (.=1) if distance_cntry_mean_pct < 0
recode disadvantaged (.=0) if distance_cntry_mean_pct >= 0
recode disadvantaged (0=.) if distance_cntry_mean_pct==.
label define disadvantaged 0 "Advantaged" 1 "Disadvantaged"
label values disadvantaged disadvantaged



*** Analysis
xtreg distance_cntry_mean_pct L.lexical_index_5##disadvantaged L.latent_gdppc_mean_log i.year, fe cluster(gwgroupid)
set scheme plotplain
margins, dydx(L.lexical_index_5) over(disadvantaged)
marginsplot, recast(scatter) yline(0) xscale(range(-0.5 1.5)) yscale(range(-30 (10) 20)) xtitle("") ytitle("Marginal effect of democracy on relative group income", size(large)) title("") xlabel(, nogrid labsize(medium)) ylabel(-30 (10) 20, nogrid labsize(medlarge))  scheme(plotplain) name(fg5A)
graph display fg5A, ysize(5) xsize(3)
graph export "fg5A.emf", replace
graph export "fg5A.pdf", replace

*** Analysis - above mean
xtreg distance_cntry_mean_pct L.lexical_index_5##disadvantaged L.latent_gdppc_mean_log i.year if L.pre_demo_ineq_best_SEI >=0.5, fe cluster(gwgroupid)
margins, dydx(L.lexical_index_5) over(disadvantaged)
marginsplot, recast(scatter) yline(0) xscale(range(-0.5 1.5)) yscale(range(-30 (10) 20)) xtitle("") ytitle("") title("") xlabel(, nogrid labsize(medium)) ylabel(-30 (10) 20, nogrid labsize(medlarge)) scheme(plotplain) name(fg5B)
graph display fg5B, ysize(5) xsize(3)
graph export "fg5B.emf", replace
graph export "fg5B.pdf", replace

*** Analysis - below mean
xtreg distance_cntry_mean_pct L.lexical_index_5##disadvantaged L.latent_gdppc_mean_log i.year if L.pre_demo_ineq_best_SEI <0.5, fe cluster(gwgroupid)
margins, dydx(L.lexical_index_5) over(disadvantaged)
marginsplot, recast(scatter) yline(0) xscale(range(-0.5 1.5)) yscale(range(-30 (10) 20)) xtitle("") ytitle("") title("") xlabel(, nogrid labsize(medium)) ylabel(-30 (10) 20, nogrid labsize(medlarge)) scheme(plotplain) name(fg5C)
graph display fg5C, ysize(5) xsize(3)
graph export "fg5C.emf", replace
graph export "fg5C.pdf", replace

*graph combine graph_1 graph_2 graph_3, rows(1) common scheme(plotplain) ycommon b2title("Group socioeconomic position", size(small)) name(fg5)



***********************************************
******************* Table A35 ******************
***********************************************

* Regression Tables, including robustness to controls (ressource rents per capita, ethnic group's conflict incidence and ethnic group size)
eststo: xtreg distance_cntry_mean_pct L.lexical_index_5##disadvantaged L.latent_gdppc_mean_log i.year, fe cluster(gwgroupid)
testparm L.lexical_index_5##disadvantaged

eststo: xtreg distance_cntry_mean_pct L.lexical_index_5##disadvantaged L.latent_gdppc_mean_log i.year if L.pre_demo_ineq_best_SEI >=0.5, fe cluster(gwgroupid)
testparm L.lexical_index_5##disadvantaged

eststo: xtreg distance_cntry_mean_pct L.lexical_index_5##disadvantaged L.latent_gdppc_mean_log i.year if L.pre_demo_ineq_best_SEI <0.5, fe cluster(gwgroupid)
testparm L.lexical_index_5##disadvantaged

eststo: xtreg distance_cntry_mean_pct L.lexical_index_5##disadvantaged L.latent_gdppc_mean_log L.incidence_flag L.resource_rents L.groupsize i.year, fe cluster(gwgroupid)
testparm L.lexical_index_5##disadvantaged

eststo: xtreg distance_cntry_mean_pct L.lexical_index_5##disadvantaged L.latent_gdppc_mean_log L.incidence_flag L.resource_rents L.groupsize i.year if L.pre_demo_ineq_best_SEI >=0.5, fe cluster(gwgroupid)
testparm L.lexical_index_5##disadvantaged

eststo: xtreg distance_cntry_mean_pct L.lexical_index_5##disadvantaged L.latent_gdppc_mean_log L.incidence_flag L.resource_rents L.groupsize i.year if L.pre_demo_ineq_best_SEI <0.5, fe cluster(gwgroupid)
testparm L.lexical_index_5##disadvantaged

esttab using TA35.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Groups" "R2 (within)") fmt(0 0 3)) order(1L.lexical_index_5 1L.lexical_index_5#1.disadvantaged 1.disadvantaged) drop(*.year 0bL.lexical_index_5 0.disadvantaged 0bL.lexical_index_5#0.disadvantaged 0bL.lexical_index_5#1.disadvantaged 1L.lexical_index_5#0.disadvantaged) replace
eststo clear





*******************************************************************
*******************************************************************
************************ AMAR *************************************
*******************************************************************
*******************************************************************


use "Group-level dataset - AMAR", replace

*** Add V-dem ID's and merge with country-level variables ***
generate country_id = .
order country_id, after(COUNTRY)
replace country_id = 36 if COUNTRY=="Afghanistan"
replace country_id = 12 if COUNTRY=="Albania"
replace country_id = 103 if COUNTRY=="Algeria"
replace country_id = 104 if COUNTRY=="Angola"
replace country_id = 37 if COUNTRY=="Argentina"
replace country_id = 105 if COUNTRY=="Armenia"
replace country_id = 67 if COUNTRY=="Australia"
replace country_id = 144 if COUNTRY=="Austria"
replace country_id = 106 if COUNTRY=="Azerbaijan"
replace country_id = 146 if COUNTRY=="Bahrain"
replace country_id = 24 if COUNTRY=="Bangladesh"
replace country_id = 147 if COUNTRY=="Barbados"
replace country_id = 107 if COUNTRY=="Belarus"
replace country_id = 148 if COUNTRY=="Belgium"
replace country_id = 52 if COUNTRY=="Benin"
replace country_id = 53 if COUNTRY=="Bhutan"
replace country_id = 25 if COUNTRY=="Bolivia"
replace country_id = 150 if COUNTRY=="Bosnia and Herzegovina"
replace country_id = 150 if COUNTRY=="Bosnia"
replace country_id = 68 if COUNTRY=="Botswana"
replace country_id = 19 if COUNTRY=="Brazil"
replace country_id = 152 if COUNTRY=="Bulgaria"
replace country_id = 54 if COUNTRY=="Burkina Faso"
replace country_id = 10 if COUNTRY=="Myanmar"
replace country_id = 10 if COUNTRY=="Burma"
replace country_id = 69 if COUNTRY=="Burundi"
replace country_id = 55 if COUNTRY=="Cambodia"
replace country_id = 108 if COUNTRY=="Cameroon"
replace country_id = 66 if COUNTRY=="Canada"
replace country_id = 70 if COUNTRY=="Cape Verde"
replace country_id = 71 if COUNTRY=="Central African Republic"
replace country_id = 109 if COUNTRY=="Chad"
replace country_id = 72 if COUNTRY=="Chile"
replace country_id = 110 if COUNTRY=="China"
replace country_id = 15 if COUNTRY=="Colombia"
replace country_id = 153 if COUNTRY=="Comoros"
replace country_id = 112 if COUNTRY=="Republic of Congo"
replace country_id = 111 if COUNTRY=="Dem. Rep. of the Congo"
replace country_id = 111 if COUNTRY=="Democratic Republic of Congo"
replace country_id = 73 if COUNTRY=="Costa Rica"
replace country_id = 154 if COUNTRY=="Croatia"
replace country_id = 155 if COUNTRY=="Cuba"
replace country_id = 156 if COUNTRY=="Cyprus"
replace country_id = 157 if COUNTRY=="Czech Republic"
replace country_id = 158 if COUNTRY=="Denmark"
replace country_id = 113 if COUNTRY=="Djibouti"
replace country_id = 114 if COUNTRY=="Dominican Republic"
replace country_id = 75 if COUNTRY=="Ecuador"
replace country_id = 13 if COUNTRY=="Egypt"
replace country_id = 22 if COUNTRY=="El Salvador"
replace country_id = 160 if COUNTRY=="Equatorial Guinea"
replace country_id = 115 if COUNTRY=="Eritrea"
replace country_id = 161 if COUNTRY=="Estonia"
replace country_id = 38 if COUNTRY=="Ethiopia"
replace country_id = 162 if COUNTRY=="Fiji"
replace country_id = 163 if COUNTRY=="Finland"
replace country_id = 76 if COUNTRY=="France"
replace country_id = 116 if COUNTRY=="Gabon"
replace country_id = 118 if COUNTRY=="Georgia"
replace country_id = 77 if COUNTRY=="Germany"
replace country_id = 77 if COUNTRY=="West Germany"
replace country_id = 7 if COUNTRY=="Ghana"
replace country_id = 164 if COUNTRY=="Greece"
replace country_id = 78 if COUNTRY=="Guatemala"
replace country_id = 63 if COUNTRY=="Guinea"
replace country_id = 119 if COUNTRY=="Guinea Bissau"
replace country_id = 166 if COUNTRY=="Guyana"
replace country_id = 26 if COUNTRY=="Haiti"
replace country_id = 27 if COUNTRY=="Honduras"
replace country_id = 210 if COUNTRY=="Hungary"
replace country_id = 39 if COUNTRY=="India"
replace country_id = 56 if COUNTRY=="Indonesia"
replace country_id = 79 if COUNTRY=="Iran"
replace country_id = 80 if COUNTRY=="Iraq"
replace country_id = 81 if COUNTRY=="Ireland"
replace country_id = 169 if COUNTRY=="Israel"
replace country_id = 82 if COUNTRY=="Italy"
replace country_id = 64 if COUNTRY=="Cote D'Ivoire"
replace country_id = 120 if COUNTRY=="Jamaica"
replace country_id = 9 if COUNTRY=="Japan"
replace country_id = 83 if COUNTRY=="Jordan"
replace country_id = 121 if COUNTRY=="Kazakhstan"
replace country_id = 40 if COUNTRY=="Kenya"
replace country_id = 171 if COUNTRY=="Kuwait"
replace country_id = 122 if COUNTRY=="Kyrgyzstan"
replace country_id = 123 if COUNTRY=="Laos"
replace country_id = 84 if COUNTRY=="Latvia"
replace country_id = 44 if COUNTRY=="Lebanon"
replace country_id = 85 if COUNTRY=="Lesotho"
replace country_id = 86 if COUNTRY=="Liberia"
replace country_id = 124 if COUNTRY=="Libya"
replace country_id = 173 if COUNTRY=="Lithuania"
replace country_id = 174 if COUNTRY=="Luxembourg"
replace country_id = 176 if COUNTRY=="Macedonia"
replace country_id = 125 if COUNTRY=="Madagascar"
replace country_id = 87 if COUNTRY=="Malawi"
replace country_id = 177 if COUNTRY=="Malaysia"
replace country_id = 88 if COUNTRY=="Maldives"
replace country_id = 28 if COUNTRY=="Mali"
replace country_id = 65 if COUNTRY=="Mauretania"
replace country_id = 65 if COUNTRY=="Mauritania"
replace country_id = 180 if COUNTRY=="Mauritius"
replace country_id = 3 if COUNTRY=="Mexico"
replace country_id = 126 if COUNTRY=="Moldova"
replace country_id = 89 if COUNTRY=="Mongolia"
replace country_id = 183 if COUNTRY=="Montenegro"
replace country_id = 90 if COUNTRY=="Morocco"
replace country_id = 57 if COUNTRY=="Mozambique"
replace country_id = 127 if COUNTRY=="Nambibia"
replace country_id = 58 if COUNTRY=="Nepal"
replace country_id = 91 if COUNTRY=="Netherlands"
replace country_id = 185 if COUNTRY=="New Zealand"
replace country_id = 59 if COUNTRY=="Nicaragua"
replace country_id = 60 if COUNTRY=="Niger"
replace country_id = 45 if COUNTRY=="Nigeria"
replace country_id = 186 if COUNTRY=="Norway"
replace country_id = 187 if COUNTRY=="Oman"
replace country_id = 29 if COUNTRY=="Pakistan"
replace country_id = 92 if COUNTRY=="Panama"
replace country_id = 93 if COUNTRY=="Papua New Guinea"
replace country_id = 189 if COUNTRY=="Paraguay"
replace country_id = 30 if COUNTRY=="Peru"
replace country_id = 46 if COUNTRY=="Philippines"
replace country_id = 17 if COUNTRY=="Poland"
replace country_id = 21 if COUNTRY=="Portugal"
replace country_id = 94 if COUNTRY=="Qatar"
replace country_id = 190 if COUNTRY=="Romania"
replace country_id = 11 if COUNTRY=="Russia"
replace country_id = 129 if COUNTRY=="Rwanda"
replace country_id = 196 if COUNTRY=="Sao Tome and Principe"
replace country_id = 197 if COUNTRY=="Saudi Arabia"
replace country_id = 31 if COUNTRY=="Senegal"
replace country_id = 198 if COUNTRY=="Serbia"
replace country_id = 198 if COUNTRY=="Serbia and Montenegro"
replace country_id = 199 if COUNTRY=="Seychelles"
replace country_id = 95 if COUNTRY=="Sierra Leone"
replace country_id = 200 if COUNTRY=="Singapore"
replace country_id = 201 if COUNTRY=="Slovakia"
replace country_id = 202 if COUNTRY=="Slovenia"
replace country_id = 130 if COUNTRY=="Somalia"
replace country_id = 8 if COUNTRY=="South Africa"
replace country_id = 96 if COUNTRY=="Spain"
replace country_id = 131 if COUNTRY=="Sri Lanka"
replace country_id = 33 if COUNTRY=="Sudan"
replace country_id = 4 if COUNTRY=="Suriname"
replace country_id = 132 if COUNTRY=="Swaziland"
replace country_id = 5 if COUNTRY=="Sweden"
replace country_id = 6 if COUNTRY=="Switzerland"
replace country_id = 97 if COUNTRY=="Syria"
replace country_id = 48 if COUNTRY=="Taiwan"
replace country_id = 133 if COUNTRY=="Tajikistan"
replace country_id = 47 if COUNTRY=="Tanzania"
replace country_id = 49 if COUNTRY=="Thailand"
replace country_id = 117 if COUNTRY=="The Gambia"
replace country_id = 74 if COUNTRY=="East Timor"
replace country_id = 74 if COUNTRY=="Timor Leste"
replace country_id = 74 if COUNTRY=="Timor-Leste"
replace country_id = 134 if COUNTRY=="Togo"
replace country_id = 135 if COUNTRY=="Trinidad and Tobago"
replace country_id = 135 if COUNTRY=="Trinidad"
replace country_id = 98 if COUNTRY=="Tunisia"
replace country_id = 99 if COUNTRY=="Turkey"
replace country_id = 136 if COUNTRY=="Turkmenistan"
replace country_id = 50 if COUNTRY=="Uganda"
replace country_id = 100 if COUNTRY=="Ukraine"
replace country_id = 207 if COUNTRY=="United Arab Emirates"
replace country_id = 101 if COUNTRY=="United Kingdom"
replace country_id = 101 if COUNTRY=="UK"
replace country_id = 20 if COUNTRY=="United States of America"
replace country_id = 102 if COUNTRY=="Uruguay"
replace country_id = 140 if COUNTRY=="Uzbekistan"
replace country_id = 206 if COUNTRY=="Vanuatu"
replace country_id = 51 if COUNTRY=="Venezuela"
replace country_id = 34 if COUNTRY=="Vietnam"
replace country_id = 14 if COUNTRY=="Yemen"
replace country_id = 61 if COUNTRY=="Zambia"
replace country_id = 62 if COUNTRY=="Zimbabwe"
replace country_id = 127 if COUNTRY=="Namibia"
replace country_id = 117 if COUNTRY=="Gambia"
replace country_id = 41 if COUNTRY=="North Korea"
replace country_id = 41 if COUNTRY=="N. Korea"
replace country_id = 42 if COUNTRY=="Korea, South"
replace country_id = 42 if COUNTRY=="S. Korea"
replace country_id = 203 if COUNTRY=="Solomon Islands"
replace country_id = 236 if COUNTRY=="Zanzibar"
replace country_id = 32 if COUNTRY=="South Sudan"
replace country_id = 137 if COUNTRY=="East Germany"
replace country_id = 198 if COUNTRY=="Federal Republic of Yugoslavia"
replace country_id = 198 if COUNTRY=="Socialist Federal Republic of Yugoslavia"
replace country_id = 35 if COUNTRY=="South Vietnam"

keep NUMCODE AMAR_Group country_id YEAR ECDIS POLDIS
recode ECDIS (-99=.)
recode POLDIS (-99=.)
rename YEAR year


*** Merge ***
merge m:1 country_id year using "Country-level dataset.dta", keepusing(lexical_index_5 latent_gdppc_mean_log pre_demo_ineq_best_SEI)
drop if AMAR_Group==""
xtset NUMCODE year


***********************************************
******************* Figure 6 ******************
***********************************************

** Transition variable
gen transition = 0
recode transition (0=1) if lexical_index_5==1 & L.lexical_index_5==0
recode transition (0=.) if lexical_index_5==.

** Dummies pre/post democratization **
g pre_20_15=0
g pre_15_10=0
g pre_10_5=0
g pre_5_0=0
g event=0
g post_0_5=0
g post_5_10=0
g post_10_15=0
g post_15_20=0

label variable pre_20_15 "-20 to -15"
label variable pre_15_10 "-15 to -10"
label variable pre_10_5 "-10 to -5"
label variable pre_5_0 "-5 to 0"

label variable post_0_5 "0 to 5"
label variable post_5_10 "5 to 10"
label variable post_10_15 "10 to 15"
label variable post_15_20 "15 to 20"

recode pre_20_15 (0=1) if F20.transition ==1 & lexical_index_5==0 | F19.transition ==1 & lexical_index_5==0 | F18.transition ==1 & lexical_index_5==0 | F17.transition ==1 & lexical_index_5==0 | F16.transition ==1 & lexical_index_5==0 
recode pre_15_10 (0=1) if F15.transition ==1 & lexical_index_5==0 | F14.transition ==1 & lexical_index_5==0 | F13.transition ==1 & lexical_index_5==0 | F12.transition ==1 & lexical_index_5==0 | F11.transition ==1 & lexical_index_5==0 
recode pre_10_5 (0=1) if F10.transition ==1 & lexical_index_5==0 | F9.transition ==1 & lexical_index_5==0 | F8.transition ==1 & lexical_index_5==0 | F7.transition ==1 & lexical_index_5==0 | F6.transition ==1 & lexical_index_5==0 
recode pre_5_0 (0=1) if F5.transition ==1 & lexical_index_5==0 | F4.transition ==1 & lexical_index_5==0 | F3.transition ==1 & lexical_index_5==0 | F2.transition ==1 & lexical_index_5==0 | F1.transition ==1 & lexical_index_5==0 
recode event (0=1) if transition==1
recode post_0_5 (0=1) if L1.transition==1 & lexical_index_5==1 | L2.transition==1 & lexical_index_5==1 | L3.transition==1 & lexical_index_5==1| L4.transition==1 & lexical_index_5==1| L5.transition==1 & lexical_index_5==1
recode post_5_10 (0=1) if L6.transition==1 & lexical_index_5==1 | L7.transition==1 & lexical_index_5==1 | L8.transition==1 & lexical_index_5==1| L9.transition==1 & lexical_index_5==1| L10.transition==1 & lexical_index_5==1
recode post_10_15 (0=1) if L11.transition==1 & lexical_index_5==1 | L12.transition==1 & lexical_index_5==1 | L13.transition==1 & lexical_index_5==1| L14.transition==1 & lexical_index_5==1| L15.transition==1 & lexical_index_5==1
recode post_15_20 (0=1) if L16.transition==1 & lexical_index_5==1 | L17.transition==1 & lexical_index_5==1 | L18.transition==1 & lexical_index_5==1| L19.transition==1 & lexical_index_5==1| L20.transition==1 & lexical_index_5==1

** Variable for following democractic years
g post_post=0
recode post_post (0=1) if lexical_index_5 == 1 & post_0_5==0 & post_5_10==0  & post_10_15==0 & post_15_20==0



** Estimates and event graph
* Economic group discrimination
xtreg ECDIS pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log, fe r

eststo m1: qui margins, dydx(pre* event post*) post
set scheme plotplain
coefplot m1, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(medlarge)) ylabel(, labsize(medlargesmall))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(medlarge) xtitle(" " "Years from democratization", size(medlarge)) title("", color(black)) name(fg6A)
graph display fg6A, ysize(3) xsize(6)
graph export "fg6A.emf", replace
graph export "fg6A.pdf", replace

* Political group discrimination
xtreg POLDIS pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log, fe r

eststo m1: qui margins, dydx(pre* event post*) post
coefplot m1, vertical order(pre_20_15 pre_15_10 pre_10_5 pre_5_0 post_0_5 post_5_10 post_10_15 post_15_20 post_post) drop(event post_post) xline(4.5, lcolor(black) lpattern(dash)) yline(0, lcolor(black) lpattern(dash)) xlabel(, angle(horizontal) labsize(medlarge)) ylabel(, labsize(medlarge))  scheme(s1mono)  mlabel format(%9.3f) mlabposition(12) mlabgap(*2) mlabsize(medlarge) xtitle(" " "Years from democratization", size(medlarge)) title("", color(black)) name(fg6B)
graph display fg6B, ysize(3) xsize(6)
graph export "fg6B.emf", replace
graph export "fg6B.pdf", replace

eststo clear


*****************
*** Table A36 ***
*****************

eststo: xtreg ECDIS pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log, fe r
eststo: xtreg POLDIS pre_20_15 pre_15_10 pre_10_5 pre_5_0 event post_0_5 post_5_10 post_10_15 post_15_20 post_post i.year L.latent_gdppc_mean_log, fe r

esttab using TA36.rtf, b(3) se(3) se star(† 0.1 * 0.05 ** 0.01) stats(N N_g r2, labels("Observations" "Groups" "R2 (within)") fmt(0 0 3)) order() drop(*.year) replace
eststo clear 


***
log close
translate log_dem_ethnic_ineq.log log_dem_ethnic_ineq.pdf

