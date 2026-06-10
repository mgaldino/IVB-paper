	

	******************************************************************
	**
	**
	**		NAME:		DOROTHY KRONICK
	**		DATE: 		October 11, 2017
	**		PROJECT: 	Venezuela's homicide wave
	**
	**		DETAILS: 	This file creates difference-in-differences 				 
	**				 	graphs comparing trends in under-five
	**                  mortality in munis along trafficking routes 
	**                  to munis not along trafficking routes.
	**			
	**
	**
	**				
	**		Version: 	Stata MP 14
	**
	******************************************************************
	
	
	


		

			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	


*-------------------------------------------------------------------------------
* preliminaries
*-------------------------------------------------------------------------------



* clear
*------

clear



* set more off
*-------------

set more off



* directory
*----------

cd "/Users/kronick/Dropbox/vz-violence" /* Location of vz-violence directory */

local destination "figures/" /* Location for output */






		

			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	


*-------------------------------------------------------------------------------
* difference-in-differences graphs: suicide
*-------------------------------------------------------------------------------



* use master analysis data
*-------------------------

use "analysis_data/MuniMstr_R.dta", clear



* capture suicide rate in munis in each group
*--------------------------------------------

gen rate1 = srate_combo if panam_sucre == 1

gen rate0 = srate_combo if panam_sucre == 0



* number of munis in each group
*------------------------------

qui su panam_sucre if year == 1997

local n_treat = `r(sum)'

local n_control = 331 - `n_treat'



* collapse to year level
*-----------------------

collapse (mean) rate*, by(year)



* graph, Panamericana de San Cristobal hasta Sucre
*-------------------------------------------------

#delimit; 

twoway (connected rate1 year if year >= 1958, 
        lcolor(black) mcolor(black) msize(small)) 

       (connected rate0 year if year >= 1958, 
        lcolor(gs7) mcolor(gs7) lpattern(dash) msize(small)),

xline(1988.5, lcolor(gs13) lwidth(thick))

graphregion(fcolor(white) lcolor(white) margin(zero))

plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))

xsize(7) ysize(5)

title("Infant deaths",
	  color(black) placement(west) justification(left) size(medlarge)) 

ytitle("Suicides per 100,000 population", size(med))

yscale(lcolor(none))

ylabel(0(2)8, labsize(med) glcolor(white) angle(horizontal))

xtitle("", size(small)) 

xscale(lcolor(none))

xlabel(, labsize(med)) 

legend(order(1 "Panamericana (N = `n_treat')" 2 "Other municipalites (N = `n_control')") 
       pos(11) size(med) symxsize(*.5) region(lcolor(white)) ring(0)
       cols(1) rowgap(*.5));

#delimit cr



* export
*------

graph export "`destination'Fig4a_DD_Placebo_Suicides.pdf", replace



		

			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	


*-------------------------------------------------------------------------------
* difference-in-differences graphs: infant deaths
*-------------------------------------------------------------------------------



* use master analysis data
*-------------------------

use "analysis_data/MuniMstr_R.dta", clear



* capture suicide rate in munis in each group
*--------------------------------------------

gen rate1 = m1year_rate_combo if panam_sucre == 1

gen rate0 = m1year_rate_combo if panam_sucre == 0



* number of munis in each group
*------------------------------

qui su panam_sucre if year == 1997

local n_treat = `r(sum)'

local n_control = 331 - `n_treat'



* collapse to year level
*-----------------------

collapse (mean) rate*, by(year)



* graph, Panamericana de San Cristobal hasta Caracas
*---------------------------------------------------

#delimit; 

twoway (connected rate1 year if year >= 1958, 
        lcolor(black) mcolor(black) msize(small)) 

       (connected rate0 year if year >= 1958, 
        lcolor(gs7) mcolor(gs7) lpattern(dash) msize(small)),

xline(1988.5, lcolor(gs13) lwidth(thick))

graphregion(fcolor(white) lcolor(white) margin(zero))

plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))

xsize(7) ysize(5)

title("Suicide",
	  color(black) placement(west) justification(left) size(medlarge)) 

ytitle("Infant deaths per 1,000 population", size(med))

yscale(lcolor(none))

ylabel(, labsize(med) glcolor(white) angle(horizontal))

xtitle("", size(small)) 

xscale(lcolor(none))

xlabel(, labsize(med)) 

legend(order(1 "Panamericana (N = `n_treat')" 2 "Other municipalites (N = `n_control')") 
       pos(2) size(med) symxsize(*.5) region(lcolor(white)) ring(0)
       cols(1) rowgap(*.5));

#delimit cr



* export
*------

graph export "`destination'Fig4b_DD_Placebo_m1.pdf", replace
	








			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	
						** end of do file **		

