//SUMMARY:  This do file generates all reported results in Ballard-Rosa, Mosley & Wellhausen (2021) "Coming to Terms"

clear all
set more off 

//Set working directory here for local machine:
cd "C:\Users\cambr\Dropbox\Debt terms\IO replication" //CBR

//Import country-year-month level dataset:
use Coming_to_Terms_data.dta, clear

//Set output scheme
set scheme plotplainblind


***********************************
******* DESCRIPTIVE FIGURES **********
***********************************

// Figure 1: Proportion domestic issuance by year (Figure 1):  
local dv "propDom_all"
bysort year: egen pd_OECD = mean(`dv') if oecd == 1 & oecd != .
label var pd_OECD "OECD countries"
bysort year: egen pd_noOECD = mean(`dv') if oecd == 0 & oecd != .
label var pd_noOECD "non-OECD countries"
twoway (line pd_OECD year, sort) (line pd_noOECD year, sort), xlabel(1990(5)2016) ytitle("Proportion domestic currency issuance (by value)") ylabel(0(.2)1) xtitle("") title("Trends in denomination of sovereign bond issues (1990-2016)")
graph export "Figures\Domestic_currency_(over_time).png", as(png) replace

// Table I: Other terms
sort ccode time
replace yield_avg_mo = . if bondsIssued == 0
replace maturity_avg_mo = . if bondsIssued == 0
replace coupon_avg_mo = . if bondsIssued == 0
xtreg $outcome maturity_avg_mo $controls_largeSample $add_controls $temporal if oecd == 0, fe vce(cluster ccode)
outreg2 using  "Figures/OtherTerms", replace ctitle(\% Domestic) drop(i.ccode ccode*) tex(frag) bdec(3) label	//adds(Log likelihood, e(ll), Pseudo-R2, e(r2_p), Countries, e(N_clust))
xtreg $outcome coupon_avg_mo $controls_largeSample $add_controls $temporal if oecd == 0, fe vce(cluster ccode)
outreg2 using  "Figures/OtherTerms", append ctitle(\% Domestic) drop(i.ccode ccode*) tex(frag) bdec(3) label	//adds(Log likelihood, e(ll), Pseudo-R2, e(r2_p), Countries, e(N_clust))
xtreg $outcome maturity_avg_mo coupon_avg_mo $controls_largeSample $add_controls $temporal if oecd == 0, fe vce(cluster ccode)
outreg2 using  "Figures/OtherTerms", append ctitle(\% Domestic) drop(i.ccode ccode*) tex(frag) bdec(3) label	//adds(Log likelihood, e(ll), Pseudo-R2, e(r2_p), Countries, e(N_clust))

* Figure 2: Amount issued by partisanship (Figure 2):
graph bar (mean) totalAmt_gdp_gt1yr if oecd == 0 & anyIssue_gt1yr == 1, over(execrlc_mo) ytitle("Proportion issues per GDP (Avg. 1990-2016)") title("Trends in issuance amounts by partisanship, non-OECD countries")
graph export "Figures\Amount_issued_over_1yr_(non-OECD,_by_exec_partisan).png", as(png) replace

* Figure 3: Partisanship over time (Figure 3):
gen havePartisanData = (execrlc_mo != .)
bysort year: egen totalLW = total(leftwing_exec_mo) if oecd==0
bysort year: egen totalRW = total(rightwing_exec_mo) if oecd==0
gen center_exec_mo = (execrlc_mo == 2) if execrlc_mo != . & oecd==0
bysort year: egen totalCenter = total(center_exec_mo) if oecd==0
bysort year: egen totalParty = total(havePartisanData) if oecd==0
gen propLW_annual = totalLW / totalParty
gen propRW_annual = totalRW / totalParty
gen propCenter_annual = totalCenter / totalParty
label var propLW_annual "Left"
label var propRW_annual "Right"
label var propCenter_annual "Center/Other"
twoway (line propLW year, sort) (line propRW year, sort) (line propCenter year, sort), ytitle("Proportion of governments") xtitle("")  ylabel(0(.25)1) xlabel(1990(5)2016) title("Trends in partisanship, non-OECD countries (1990-2016)")
graph export "Figures\PartisanshipOverTime.png", as(png) replace


****************************
******* ANALYSIS *******
****************************

global controls_largeSample "l12.lngdppc l12.gdp_growth l12.avgDebt_gdp l12.curr_act_gdp l12.tradeGDP l12.oil_rents l12.fdi_net_inflow l12.treasury10yr " 
global add_controls "l12.peg l12.highCBI l12.kaopen l12.imfAnyInPlace crisis_currency crisis_inflation crisis_sovdebt l12.v2x_polyarchy "
global temporal  "time time2 time3" 
sort ccode time
global outcome "propDom_gt1yr" 


// Table II - Effect of partisanship on proportion domestic currency debt
xtreg $outcome l.ib2.execrlc_mo $temporal if oecd == 0, fe vce(cluster ccode)
outreg2 using  "Figures/Partisanship", replace ctitle(No controls) drop(i.ccode ccode*) tex(frag) bdec(3)  label
xtreg $outcome l.ib2.execrlc_mo $controls_largeSample $temporal if oecd == 0, fe vce(cluster ccode)
outreg2 using  "Figures/Partisanship", append ctitle(Baseline) drop(i.ccode ccode*) tex(frag) bdec(3)  label
xtreg $outcome l.ib2.execrlc_mo $controls_largeSample $add_controls $temporal if oecd == 0, fe vce(cluster ccode)
outreg2 using  "Figures/Partisanship", append ctitle(Full controls) drop(i.ccode ccode*) tex(frag) bdec(3) label

// Figure 4A & Table A2 - CBI results
xtreg $outcome l.ib2.execrlc_mo##l12.highCBI $controls_largeSample l12.peg l12.kaopen l12.imfAnyInPlace l.crisis_inflation l.crisis_currency l.crisis_sovdebt l12.v2x_polyarchy if oecd == 0, fe vce(cluster ccode)
outreg2 using  "Figures/Interactions", replace ctitle(CBI) drop(i.ccode ccode*) tex(frag) bdec(3)  label
xtreg $outcome l.ib2.execrlc_mo##l12.highCBI $controls_largeSample l12.peg l12.kaopen l12.imfAnyInPlace l.crisis_inflation l.crisis_currency l.crisis_sovdebt l12.v2x_polyarchy if oecd == 0, fe vce(cluster ccode)
margins l12.highCBI, at(l.execrlc_mo = 1) post
est sto cbiXright
xtreg $outcome l.ib2.execrlc_mo##l12.highCBI $controls_largeSample l12.peg l12.kaopen l12.imfAnyInPlace l.crisis_inflation l.crisis_currency l.crisis_sovdebt l12.v2x_polyarchy if oecd == 0, fe vce(cluster ccode)
margins l12.highCBI, at(l.execrlc_mo = 2) post
est sto cbiXcenter
xtreg $outcome l.ib2.execrlc_mo##l12.highCBI $controls_largeSample l12.peg l12.kaopen l12.imfAnyInPlace l.crisis_inflation l.crisis_currency l.crisis_sovdebt l12.v2x_polyarchy if oecd == 0, fe vce(cluster ccode)
margins l12.highCBI, at(l.execrlc_mo = 3) post
est sto cbiXleft
coefplot (cbiXright, label(Right) color(gs1)) (cbiXcenter, label(Center/Other) color(gs7)) (cbiXleft, label(Left) color(gs13)), recast(bar) barwidth(.25) vertical fcolor(*.5) ciopts(recast(rcap)) citop format(%9.2f) ytitle(Proportion domestic currency) ylabel(0.40(.10)1) title("Partisan issuance, conditional on central bank independence (CBI)") xlabel(1 "Low CBI" 2 "High CBI")
graph export "Figures\PartisanXCBI.png", as(png) replace

// Figure 4B & Table A2 - Pegged XR results
xtreg $outcome l.ib2.execrlc_mo##l12.peg $controls_largeSample l12.highCBI l12.kaopen l12.imfAnyInPlace l.crisis_inflation l.crisis_currency l.crisis_sovdebt l12.v2x_polyarchy if oecd == 0, fe vce(cluster ccode)
outreg2 using  "Figures/Interactions", append ctitle(Peg XR) drop(i.ccode ccode*) tex(frag) bdec(3)  label
xtreg $outcome l.ib2.execrlc_mo##l12.peg $controls_largeSample l12.highCBI l12.kaopen l12.imfAnyInPlace l.crisis_inflation l.crisis_currency l.crisis_sovdebt l12.v2x_polyarchy if oecd == 0, fe vce(cluster ccode)
margins l12.peg, at(l.execrlc_mo = 1) post
est sto pegXright
xtreg $outcome l.ib2.execrlc_mo##l12.peg $controls_largeSample l12.highCBI l12.kaopen l12.imfAnyInPlace l.crisis_inflation l.crisis_currency l.crisis_sovdebt l12.v2x_polyarchy if oecd == 0, fe vce(cluster ccode)
margins l12.peg, at(l.execrlc_mo = 2) post
est sto pegXcenter
xtreg $outcome l.ib2.execrlc_mo##l12.peg $controls_largeSample l12.highCBI l12.kaopen l12.imfAnyInPlace l.crisis_inflation l.crisis_currency l.crisis_sovdebt l12.v2x_polyarchy if oecd == 0, fe vce(cluster ccode)
margins l12.peg, at(l.execrlc_mo = 3) post
est sto pegXleft
coefplot (pegXright, label(Right) color(gs1)) (pegXcenter, label(Center/Other) color(gs7)) (pegXleft, label(Left)  color(gs13)), recast(bar) barwidth(.25) vertical fcolor(*.5) ciopts(recast(rcap)) citop format(%9.2f) ytitle(Proportion domestic currency) ylabel(0.40(0.10)1) title("Partisan issuance, conditional on fixed exchange rate (XR)") xlabel(1 "Not fixed" 2 "Fixed XR")
graph export "Figures\PartisanXpeg.png", as(png) replace

* Figure 5A & Table A2 - Inflation crisis results
xtreg $outcome l.ib2.execrlc_mo##l.crisis_inflation $controls_largeSample l12.highCBI l12.peg l12.kaopen l12.imfAnyInPlace l.crisis_currency l.crisis_sovdebt l12.v2x_polyarchy if oecd == 0, fe vce(cluster ccode)
outreg2 using  "Figures/Interactions", append ctitle(Inflation crisis) drop(i.ccode ccode*) tex(frag) bdec(3)  label
xtreg $outcome l.ib2.execrlc_mo##l.crisis_inflation $controls_largeSample l12.highCBI l12.peg l12.kaopen l12.imfAnyInPlace l.crisis_currency l.crisis_sovdebt l12.v2x_polyarchy if oecd == 0, fe vce(cluster ccode)
margins l.crisis_inflation, at(l.execrlc_mo = 1) post
est sto inflCrisisXright
xtreg $outcome l.ib2.execrlc_mo##l.crisis_inflation $controls_largeSample l12.highCBI l12.peg l12.kaopen l12.imfAnyInPlace l.crisis_currency l.crisis_sovdebt l12.v2x_polyarchy if oecd == 0, fe vce(cluster ccode)
margins l.crisis_inflation, at(l.execrlc_mo = 2) post
est sto inflCrisisXcenter
xtreg $outcome l.ib2.execrlc_mo##l.crisis_inflation $controls_largeSample l12.highCBI l12.peg l12.kaopen l12.imfAnyInPlace l.crisis_currency l.crisis_sovdebt l12.v2x_polyarchy if oecd == 0, fe vce(cluster ccode)
margins l.crisis_inflation, at(l.execrlc_mo = 3) post
est sto inflCrisisXleft
coefplot (inflCrisisXright, label(Right) color(gs1)) (inflCrisisXcenter, label(Center/Other) color(gs7)) (inflCrisisXleft, label(Left) color(gs13)), recast(bar) barwidth(.25) vertical fcolor(*.5) ciopts(recast(rcap)) citop format(%9.2f) ytitle(Proportion domestic currency) ylabel(0.20(0.1)1) title("Partisan issuance, conditional on inflation crisis") xlabel(1 "No crisis" 2 "Inflation crisis")
graph export "Figures\PartisanXinflationCrisis.png", as(png) replace

* Figure 5B & Table A2 - Currency crisis results
xtreg $outcome l.ib2.execrlc_mo##l.crisis_currency $controls_largeSample l12.highCBI l12.peg l12.kaopen l12.imfAnyInPlace l.crisis_inflation l.crisis_sovdebt l12.v2x_polyarchy if oecd == 0, fe vce(cluster ccode)
outreg2 using  "Figures/Interactions", append ctitle(Currency crisis) drop(i.ccode ccode*) tex(frag) bdec(3)  label
xtreg $outcome l.ib2.execrlc_mo##l.crisis_currency $controls_largeSample l12.highCBI l12.peg l12.kaopen l12.imfAnyInPlace l.crisis_inflation l.crisis_sovdebt l12.v2x_polyarchy if oecd == 0, fe vce(cluster ccode)
margins l.crisis_currency, at(l.execrlc_mo = 1) post
est sto currCrisisXright
xtreg $outcome l.ib2.execrlc_mo##l.crisis_currency $controls_largeSample l12.highCBI l12.peg l12.kaopen l12.imfAnyInPlace l.crisis_inflation l.crisis_sovdebt l12.v2x_polyarchy if oecd == 0, fe vce(cluster ccode)
margins l.crisis_currency, at(l.execrlc_mo = 2) post
est sto currCrisisXcenter
xtreg $outcome l.ib2.execrlc_mo##l.crisis_currency $controls_largeSample l12.highCBI l12.peg l12.kaopen l12.imfAnyInPlace l.crisis_inflation l.crisis_sovdebt l12.v2x_polyarchy if oecd == 0, fe vce(cluster ccode)
margins l.crisis_currency, at(l.execrlc_mo = 3) post
est sto currCrisisXleft
coefplot (currCrisisXright, label(Right) color(gs1)) (currCrisisXcenter, label(Center/Other) color(gs7)) (currCrisisXleft, label(Left) color(gs13)), recast(bar) barwidth(.25) vertical fcolor(*.5) ciopts(recast(rcap)) citop format(%9.2f) ytitle(Proportion domestic currency) ylabel(0.20(0.1)1) title("Partisan issuance, conditional on currency crisis") xlabel(1 "No crisis" 2 "Currency crisis")
graph export "Figures\PartisanXcurrencyCrisis.png", as(png) replace

// Figure 6 & Table A4 - Effect of partisanship by decade
xtreg $outcome l.ib2.execrlc_mo##ib3.decade if oecd == 0, fe vce(cluster ccode)
margins decade, at(l.execrlc_mo = 1) post
est sto decadeXright
xtreg $outcome l.ib2.execrlc_mo##ib3.decade if oecd == 0, fe vce(cluster ccode)
margins decade, at(l.execrlc_mo = 2) post
est sto decadeXcenter
xtreg $outcome l.ib2.execrlc_mo##ib3.decade if oecd == 0, fe vce(cluster ccode)
margins decade, at(l.execrlc_mo = 3) post
est sto decadeXleft
coefplot (decadeXright, label(Right) color(gs1)) (decadeXcenter, label(Center/Other) color(gs7)) (decadeXleft, label(Left) color(gs13)), recast(bar) barwidth(.25) vertical fcolor(*.5) ciopts(recast(rcap)) citop format(%9.2f) ytitle(Proportion domestic currency) ylabel(0.4(.1)1) title("Partisan debt issuance, by decade") level(90)
graph export "Figures\PartisanXdecade.png", as(png) replace
xtreg $outcome l.ib2.execrlc_mo##ib3.decade $controls_largeSample $add_controls $temporal if oecd == 0 , fe vce(cluster ccode)
outreg2 using  "Figures/Decades", replace ctitle(Decade dummies) drop(i.ccode ccode*) tex(frag) bdec(3)  label
