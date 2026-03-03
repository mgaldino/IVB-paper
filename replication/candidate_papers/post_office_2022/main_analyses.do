*** Table 1 ***

** Models 1 and 2 (panel) **
use "country_panel.dta", clear
xtset country_id trend

xtreg F.e_migdpgro_5yr upu_totalpo_ipo_ln_stock_1_5yr e_migdppcln_5yr i.year, fe vce (cluster country_id) dfadj
xtreg F.e_migdpgro_5yr upu_totalpo_ipo_ln_stock_1_5yr e_migdppcln_5yr e_mipopula_ipo_ln e_miurbaniz e_polity2 i.year, fe vce (cluster country_id) dfadj

** Models 3 and 4 (cross-sectional) **
use "country_cs.dta", clear
qui mi import flong, m(imp) id(year country_id) imp(e_migdppcln)
qui mi stset, clear
mi estimate, esample(sample) post: reg e_migdppcln L100.upu_totalpo_ipo_ln L100.e_migdppcln if year == 2000 & postal_observed == 1,vce(robust)

use "country_cs.dta", clear
qui mi import flong, m(imp) id(year country_id) imp(e_migdppcln e_mipopula_ipo_ln e_miurbaniz e_polity2)
qui mi stset, clear
mi estimate, esample(sample) post: reg e_migdppcln L100.upu_totalpo_ipo_ln L100.e_migdppcln L100.e_mipopula_ipo_ln L100.e_miurbaniz L100.e_polity2 indyears if year == 2000 & postal_observed == 1,vce(robust)



*** Table 2 ***

use "us_panel.dta",clear

xtset fips year

* Panel A (Unbalanced) *
xtreg ln_realfarm ln_po  i.year if ln_pop!=. & ln_foreign!=.,fe vce(cl fips) dfadj
xtreg ln_realfarm ln_po  ln_pop ln_foreign i.year ,fe vce(cl fips) dfadj
xtreg ln_realmfgout ln_po  i.year if ln_pop!=. & ln_foreign!=.,fe vce(cl fips) dfadj
xtreg ln_realmfgout ln_po  ln_pop ln_foreign i.year ,fe vce(cl fips) dfadj
xtreg ln_realmfgcap ln_po  i.year if ln_pop!=. & ln_foreign!=.,fe vce(cl fips) dfadj
xtreg ln_realmfgcap ln_po   ln_pop ln_foreign i.year ,fe vce(cl fips) dfadj

* Panel B (Balanced) *
by fips, sort: egen count_po = count(ln_po)
drop if ln_pop==. | ln_foreign==.|ln_realfarm==.|ln_realmfgcap==.|ln_realmfgout==.
duplicates tag fips, gen(dups)
keep if dups==5 & count_po==7

xtreg ln_realfarm ln_po  i.year if ln_realmfgout!=. & ln_realmfgcap!=. & ln_realfarm!=. & ln_foreign!=. & ln_pop!=.,fe vce(cl fips) dfadj
xtreg ln_realfarm ln_po ln_pop ln_foreign  i.year if ln_realmfgout!=. & ln_realmfgcap!=. & ln_realfarm!=.,fe vce(cl fips) dfadj
xtreg ln_realmfgout ln_po   i.year if ln_realmfgout!=. & ln_realmfgcap!=. & ln_realfarm!=. & ln_foreign!=. & ln_pop!=.,fe vce(cl fips) dfadj
xtreg ln_realmfgout ln_po  ln_pop ln_foreign i.year if ln_realmfgout!=. & ln_realmfgcap!=. & ln_realfarm!=.,fe vce(cl fips) dfadj
xtreg ln_realmfgcap ln_po  i.year if ln_realmfgout!=. & ln_realmfgcap!=. & ln_realfarm!=. & ln_foreign!=. & ln_pop!=.,fe vce(cl fips) dfadj
xtreg ln_realmfgcap ln_po ln_pop ln_foreign i.year if ln_realmfgout!=. & ln_realmfgcap!=. & ln_realfarm!=.,fe vce(cl fips) dfadj

* marginal effects
* increased post offices from mean (21) to one standard deviation (11) above the mean

display 0.222*(log(1 + 21 + 11) - log(1 + 21)) 
display log(1 + 5019405) + .0900
display exp(15.5188) - 5019406
* = 472577/5019405, or 9% increase

display 0.236*(log(1 + 21 + 11) - log(1 + 21)) 
display log(1 + 3869029) + .0957
display exp(15.2642) - 3869030
* = 388501/3869029, or 10% increase

display 0.239*(log(1 + 21 + 11) - log(1 + 21)) 
display log(1 + 2555824) + .0969
display exp(14.8508) - 2555825
* = 260096/2555824, or 10% increase


*** Table 3 ***

use "cs_us.dta",clear

** Panel A (Median income, 2000) **
reg ln_income2000  ln_po1896  ln_pop1890 ln_density1890 foreign  , robust
reg ln_income2000  ln_po1896  ln_pop1890 ln_density1890 foreign  i.statefip, robust
reg ln_income2000  ln_po1896  ln_pop1890 ln_density1890 foreign   realfarmval1890 realmfgout1890  i.statefip, robust
reg ln_income2000  ln_po1896  ln_pop1890 ln_density1890 foreign   realfarmval1890 realmfgout1890 realfarmval1880 realmfgout1880 i.statefip, robust
reg ln_income2000  ln_po1896  ln_pop1890 ln_density1890 foreign   realfarmval1890 realmfgout1890 realfarmval1880 realmfgout1880 realfarmval1870 realmfgout1870 i.statefip, robust
reg ln_income2000  ln_po1896  ln_pop1890 ln_density1890 foreign   realfarmval1890 realmfgout1890 realfarmval1880 realmfgout1880 realfarmval1870 realmfgout1870 realfarmval1860 realmfgout1860 i.statefip, robust
reg ln_income2000  ln_po1896  ln_pop1890 ln_density1890 foreign rail water1860  realfarmval1890 realmfgout1890 realfarmval1880 realmfgout1880 realfarmval1870 realmfgout1870 realfarmval1860 realmfgout1860 i.statefip, robust
reg ln_income2000  ln_po1896  ln_pop1890 ln_density1890 foreign rail water1860  realfarmval1890 realmfgout1890 realfarmval1880 realmfgout1880 realfarmval1870 realmfgout1870 realfarmval1860 realmfgout1860 slavepop i.statefip, robust
reg ln_income2000  ln_po1896  ln_pop1890 ln_density1890 foreign rail water1860  realfarmval1890 realmfgout1890 realfarmval1880 realmfgout1880 realfarmval1870 realmfgout1870 realfarmval1860 realmfgout1860  slavepop lat longitu i.statefip, robust

** Panel B (Mfg establishments, 2000) **
reg ln_mfg2000  ln_po1896  ln_pop1890 ln_density1890 foreign  , robust
reg ln_mfg2000  ln_po1896  ln_pop1890 ln_density1890 foreign  i.statefip, robust
reg ln_mfg2000  ln_po1896  ln_pop1890 ln_density1890 foreign   realfarmval1890 realmfgout1890  i.statefip, robust
reg ln_mfg2000  ln_po1896  ln_pop1890 ln_density1890 foreign   realfarmval1890 realmfgout1890 realfarmval1880 realmfgout1880 i.statefip, robust
reg ln_mfg2000  ln_po1896  ln_pop1890 ln_density1890 foreign   realfarmval1890 realmfgout1890 realfarmval1880 realmfgout1880 realfarmval1870 realmfgout1870 i.statefip, robust
reg ln_mfg2000  ln_po1896  ln_pop1890 ln_density1890 foreign   realfarmval1890 realmfgout1890 realfarmval1880 realmfgout1880 realfarmval1870 realmfgout1870 realfarmval1860 realmfgout1860 i.statefip, robust
reg ln_mfg2000  ln_po1896  ln_pop1890 ln_density1890 foreign rail water1860  realfarmval1890 realmfgout1890 realfarmval1880 realmfgout1880 realfarmval1870 realmfgout1870 realfarmval1860 realmfgout1860 i.statefip, robust
reg ln_mfg2000  ln_po1896  ln_pop1890 ln_density1890 foreign rail water1860  realfarmval1890 realmfgout1890 realfarmval1880 realmfgout1880 realfarmval1870 realmfgout1870 realfarmval1860 realmfgout1860 slavepop i.statefip, robust
reg ln_mfg2000  ln_po1896  ln_pop1890 ln_density1890 foreign rail water1860  realfarmval1890 realmfgout1890 realfarmval1880 realmfgout1880 realfarmval1870 realmfgout1870 realfarmval1860 realmfgout1860  slavepop lat longitu i.statefip, robust

* substantive magnitudes
*display 0.0819*(log(1 + 25 + 6) - log(1 + 25)) 
*display log(1 + 32940) + .017
*display exp(10.4195) - 32941
*display (94312/2.62) * 566 

*display 0.2803*(log(1 + 25 + 6) - log(1 + 25)) 
*display log(1 + 171) + .058
*display exp(5.2055) - 172


*** Table 4 ***

** Panel A (Median income) **
reg ln_income1960  ln_po1896  ln_pop1890 ln_density1890 foreign    i.statefip, robust
reg ln_income1970  ln_po1896  ln_pop1890 ln_density1890 foreign    i.statefip, robust
reg ln_income1980  ln_po1896  ln_pop1890 ln_density1890 foreign    i.statefip, robust
reg ln_income1990  ln_po1896  ln_pop1890 ln_density1890 foreign    i.statefip, robust
reg ln_income2000  ln_po1896  ln_pop1890 ln_density1890 foreign    i.statefip, robust

** Panel B (Mfg establishments) **
reg ln_mfg1960  ln_po1896  ln_pop1890 ln_density1890 foreign    i.statefip, robust
reg ln_mfg1970  ln_po1896  ln_pop1890 ln_density1890 foreign    i.statefip, robust
reg ln_mfg1980  ln_po1896  ln_pop1890 ln_density1890 foreign    i.statefip, robust
reg ln_mfg1990  ln_po1896  ln_pop1890 ln_density1890 foreign    i.statefip, robust
reg ln_mfg2000  ln_po1896  ln_pop1890 ln_density1890 foreign    i.statefip, robust


