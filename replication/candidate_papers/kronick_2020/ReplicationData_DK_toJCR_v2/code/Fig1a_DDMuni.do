	

	******************************************************************
	**
	**
	**		NAME:		DOROTHY KRONICK
	**		DATE: 		September 24, 2017
	**		PROJECT: 	Venezuela's homicide wave
	**
	**		DETAILS: 	This file creates difference-in-differences 				 
	**				 	graphs comparing homicide-rate trends
	**                  in munis along the Panamericana
	**                  to munis not along the Panamericana.
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



* directories
*------------

cd "/Users/kronick/Dropbox/vz-violence" /* Location of vz-violence directory */

local destination "figures/" /* Location for output */

	
	


		

			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	


*-------------------------------------------------------------------------------
* main difference-in-differences graph
*-------------------------------------------------------------------------------



* use master analysis data
*-------------------------

use "analysis_data/MuniMstr_R.dta", clear



* capture number of municipalities in each group
*-----------------------------------------------

qui su panam_sucre if year == 1997

local n_treat = `r(sum)'

local n_control = 331 - `r(sum)'



* capture homicide rate in munis in each group
*---------------------------------------------

gen hrate1 = hrate_combo if panam_sucre == 1

gen hrate0 = hrate_combo if panam_sucre == 0



* collapse to year level
*-----------------------

collapse (mean) hrate1 hrate0, by(year)



* graph, Panamericana de Sucre hasta Caracas
*-------------------------------------------

#delimit; 

twoway (connected hrate1 year if year >= 1958, 
        lcolor(black) mcolor(black) msize(small)) 

       (connected hrate0 year if year >= 1958, 
        lcolor(gs7) mcolor(gs7) lpattern(dash) msize(small)),

xline(1988.5, lcolor(gs13) lwidth(thick))

graphregion(fcolor(white) lcolor(white) margin(zero))

plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))

xsize(7) ysize(5)

title("Difference-in-differences: Two Groups of Municipalities",
	  color(black) placement(west) justification(left) size(medlarge)) 

ytitle("Violent Deaths per 100,000", size(med))

yscale(lcolor(none))

ylabel(10(10)60, labsize(med) glcolor(white) angle(horizontal))

xtitle("", size(small)) 

xscale(lcolor(none))

xlabel(, labsize(med)) 

legend(order(1 "Panamericana (N = `n_treat')" 2 "Other municipalites (N = `n_control')") 
       pos(11) size(med) symxsize(*.5) region(lcolor(white)) ring(0)
       cols(1) rowgap(*.5));

#delimit cr


* export
*------

graph export "`destination'Fig1a_DD_Muni.pdf", replace


	
	
	





			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	
						** end of do file **		
