	

	******************************************************************
	**
	**
	**		NAME:		DOROTHY KRONICK
	**		DATE: 		September 24, 2017
	**		PROJECT: 	Venezuela's homicide wave
	**
	**		DETAILS: 	This file graphs the distribution				 
	**				 	of pre-post changes across municipalities
	**                  on and off the Panamericana.				
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
* collapse to municipio-pre-post panel
*-------------------------------------------------------------------------------



* use master analysis data
*-------------------------

use "analysis_data/MuniMstr_R.dta", clear



* post
*-----

gen post = (year >= 1989)



* collapse
*---------

collapse (mean) hrate_combo pob_1990 ///
         (first) panam_sucre, by(estado municipio post)
	


* reshape
*--------

reshape wide hrate_combo, i(estado municipio) j(post)



* change
*-------

gen jump = hrate_combo1 - hrate_combo0

	

* log values
*-----------

gen ln_hrate_0 = ln(1 + hrate_combo0)

gen ln_hrate_1 = ln(1 + hrate_combo1)




		

			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	


*-------------------------------------------------------------------------------
* distribution of changes graph
*-------------------------------------------------------------------------------

					 					 

* number of municipalities in each group
*---------------------------------------

qui su panam_sucre

local n_treat = `r(sum)'

local n_control = 331 - `n_treat'



* graph
*------

#delimit;

twoway (kdensity jump if panam_sucre == 1, lcolor(black) lpattern(dash)) 

	   (kdensity jump if panam_sucre == 0, lcolor(gs12)),

graphregion(fcolor(white) lcolor(white) margin(zero))

plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))

xsize(7) ysize(5)

title("Distribution of Change in Violence",
	  color(black) placement(west) justification(left) size(medlarge)) 

ytitle("Density", size(medlarge))

yscale(lcolor(none))

ylabel(, labsize(med) glcolor(white) angle(horizontal))

xtitle("Change in violent death rate, post- vs. pre-1989", size(med)) 

xscale(lcolor(none))

xlabel(, labsize(med)) 

legend(order(1 "Panamericana (N = `n_treat')" 2 "Other municipalities (N = `n_control')") 
       pos(1) size(med) symxsize(*.5) region(lcolor(white)) ring(0)
       cols(1) rowgap(*.5));

#delimit cr



* export
*------

graph export "`destination'Fig2a_JumpDistribution_panam_sucre.pdf", replace

	
	



		

			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	


*-------------------------------------------------------------------------------
* scatter plot, post- vs pre-period mean violent death rates
*-------------------------------------------------------------------------------



* graph
*------

#delimit;

twoway (scatter hrate_combo1 hrate_combo0 if panam_sucre == 1, 
        msymbol(square) mcolor(gs7)) 

       (lfit hrate_combo1 hrate_combo0 if panam_sucre == 1,
        lcolor(black)) 

       (scatter hrate_combo1 hrate_combo0 if panam_sucre == 0,
        msymbol(Oh) mcolor(gs10))

       (lfit hrate_combo1 hrate_combo0 if panam_sucre == 0,
        lcolor(gs10) lwidth(thick) lpattern(longdash)),

graphregion(fcolor(white) lcolor(white) margin(zero))

plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))

xsize(7) ysize(5)

title("Post vs. pre violent death rate", 
	  color(black) placement(west) justification(left) size(medlarge)) 

ytitle("Mean homicide rate, 1989–2012", size(med))

yscale(lcolor(none))

ylabel(, labsize(med) glcolor(white) angle(horizontal))

xtitle("Mean homicide rate, 1958–1988", size(med))

xscale(lcolor(none))

xlabel(, labsize(med)) 

legend(order(1 "Panamericana municipalities" 
             2 "Fitted values, Panamericana"
			 3 "Other municipalities"
			 4 "Fitted values, other")
	   size(med) cols(1) pos(1) ring(0) region(lcolor(white))
	   symxsize(*.5) rowgap(*.1));
	   
graph export "`destination'Fig2b_JumpScatter.pdf", replace;

#delimit cr	

	

	


		

			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	


*-------------------------------------------------------------------------------
* scatter plot: change against 1990 population
*-------------------------------------------------------------------------------



* labels
*-------

foreach x of numlist 1000 10000 100000 500000 1000000 {

di ln(`x') `" "`x'""'

}



* graph
*------

#delimit;

twoway (scatter jump pob_1990 if panam_sucre == 0, 
        msymbol(Oh) mcolor(gs10)) 

       (scatter jump pob_1990 if panam_sucre == 1, 
        msymbol(square) mcolor(gs7))

       (lpoly jump pob_1990 if panam_sucre == 0, 
        lcolor(gs10) lwidth(thick) lpattern(longdash)) 
       
       (lpoly jump pob_1990 if panam_sucre == 1, 
        lcolor(black)),

graphregion(fcolor(white) lcolor(white) margin(zero))

plotregion(fcolor(white) lstyle(none) lcolor(white) ilstyle(none))

xsize(7) ysize(5)

title("City size and growth in violence", 
	  color(black) placement(west) justification(left) size(medlarge)) 

ytitle("Change in violent death rate, post- vs. pre-1989", size(med))

yscale(lcolor(none))

ylabel(, labsize(med) glcolor(white) angle(horizontal))

xtitle("Population 1990 (log scale, labels exponentiated)", size(med))

xscale(lcolor(none))

xlabel(6.9077553 "1000"
9.2103404 "10K"
11.512925 "100K"
13.122363 "500K"
13.815511 "1M"
, labsize(med)) 

legend(order(2 "Panamericana municipalities" 
             4 "Fitted values, Panamericana"
			 1 "Other municipalities"
			 3 "Fitted values, other")
	   size(med) cols(1) pos(11) ring(0) region(lcolor(white))
	   symxsize(*.5) rowgap(*.1));
	   
graph export "`destination'Fig3_PobScatter.pdf", replace;

#delimit cr
	
	
	





			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	
						** end of do file **		
