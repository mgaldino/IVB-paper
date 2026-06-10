

	******************************************************************
	**
	**
	**		NAME:		DOROTHY KRONICK
	**		DATE: 		October 14, 2017
	**		PROJECT: 	Venezuela's homicide wave
	**
	**		DETAILS: 	This file graphs the dif-in-dif
	**                  main results at the state level. 
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



* set directory
*--------------

cd "/Users/kronick/Dropbox/vz-violence" /* Location of vz-violence directory */

local destination "figures/" /* Location for output */


	
	
	


		

			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	


*-------------------------------------------------------------------------------
* difference-in-differences graph, state level
*-------------------------------------------------------------------------------

 

* state master data
*------------------

use "analysis_data/EdoMstr_R.dta", clear



* capture number of states in each group
*---------------------------------------

gen control = (pct_treat == 0)

qui su control if year == 2000

local n_control = `r(sum)'

local n_treat = 24 - `n_control'



* treated and untreated groups
*-----------------------------

gen mv_rate_treat = mv_rate if pct_treat > 0

gen mv_rate_control = mv_rate if pct_treat == 0



* collapse
*---------

collapse (mean) mv_rate_treat mv_rate_control [aw = weight], by(year)




* graph
*------

#delimit;

twoway (connected mv_rate_treat year if year >= 1958, 
        lcolor(black) mcolor(black) msize(small)) 

       (connected mv_rate_control year if year >= 1958,
        lcolor(gs7) mcolor(gs7) lpattern(dash) msize(small)), 

xline(1988.5, lcolor(gs13) lwidth(thick))

graphregion(fcolor(white) lcolor(white) margin(zero))

plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))

xsize(7) ysize(5)

title("Difference-in-differences: Two groups of states",
	  color(black) placement(west) justification(left) size(medlarge)) 

ytitle("Violent deaths per 100,000", size(med))

yscale(lcolor(none))

ylabel(, labsize(med) glcolor(white) angle(horizontal))

xtitle("", size(small)) 

xscale(lcolor(none))

xlabel(, labsize(med)) 

legend(order(1 "States along Panamericana (N = `n_treat')" 2 "Other states (N = `n_control')") pos(11)
       size(med) symxsize(*.5) region(lcolor(white)) ring(0)
       cols(1) rowgap(*.5));

#delimit cr



* export
*-------

graph export "`destination'Fig1b_DD_States.pdf", replace


	
	
	





			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	
						** end of do file **		

