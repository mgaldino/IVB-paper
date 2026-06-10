	

	******************************************************************
	**
	**
	**		NAME:		DOROTHY KRONICK
	**		DATE: 		September 27, 2017
	**		PROJECT: 	Venezuela's homicide wave
	**
	**		DETAILS: 	This file estimates difference-in-differences 				 
	**				 	comparing homicide-rate trends
	**                  in munis along trafficking routes 
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

clear all



* set more off
*-------------

set more off



* mat size
*---------

set matsize 10000



* directory
*----------

cd "/Users/djkronick/Dropbox/vz-violence" /* Location of vz-violence directory */

local destination "tables/" /* Location for output */



* package to implement Wild cluster bootstrap
*--------------------------------------------

do "code/bootwildct.ado"
	

	


		

			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	


*-------------------------------------------------------------------------------
* master analysis data
*-------------------------------------------------------------------------------



* use master analysis data
*-------------------------

use "analysis_data/MuniMstr_R.dta", clear



* set seed (for replication)
*---------------------------

set seed 08231948
	
	



		

			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	


*-------------------------------------------------------------------------------
* de-meaning
*-------------------------------------------------------------------------------


	/* Note: This is necessary because, as far as I know,
		     the Wild cluster bootstrap implmentations
			 do not work with the areg command.
			 
			 */

			 
* treatment indicator
*--------------------
	 
local t treat_panam_sucre



* year dummies
*-------------
			 
qui xi: areg hrate_combo `t' i.year, ///
        a(ci_mun) cl(ci_mun) noomit
		


* collect in-sample year dummies in a list
*----------------------------------------- 		

gen _Iyear_1958 = (year == 1958)

local years _Iyear_1958 _Iyear_1963 _Iyear_1968 _Iyear_1973 _Iyear_1978 ///
            _Iyear_1985 _Iyear_1988 _Iyear_1997 _Iyear_1999-_Iyear_2013

			
			
* city-size trends
*-----------------

foreach y of varlist `years' {

		gen pob1990x`y' = `y' * pob_1990
		
		}
		

		
* muni-specific linear trends
*----------------------------

levelsof ci_mun, local(muns)

foreach m of local muns {

	gen Tx`m' = year if ci_mun == "`m'"
	
	replace Tx`m' = 0 if ci_mun ~= "`m'"
	
	}
	


* taking out the municipio averages
*----------------------------------
		
foreach var of varlist ln_hrate_combo hrate_combo ln_pob ///
					   `t' `years' pob1990x* Tx* {

	egen mean = mean(`var'), by(ci_mun)
	
	gen dm_`var' = `var' - mean
	
	drop mean
	
	}


	
* taking out weighted municipio averages (for weighted regressions)
*------------------------------------------------------------------
		
foreach var of varlist ln_hrate_combo hrate_combo ln_pob ///
					   `t' `years' pob1990x* Tx* {

	egen mean = wtmean(`var'), weight(pob_cgr) by(ci_mun)
	
	gen dmw_`var' = `var' - mean
	
	drop mean
	
	}	
	
	
	
* collect year dummies in two lists
*----------------------------------
	
local yeardummies dm__Iyear_1958 dm__Iyear_1963 dm__Iyear_1968 dm__Iyear_1973 ///
                  dm__Iyear_1978 dm__Iyear_1985 dm__Iyear_1988 dm__Iyear_1997 ///
				  dm__Iyear_1999-dm__Iyear_2013
	
local yeardummiesw dmw__Iyear_1958 dmw__Iyear_1963 dmw__Iyear_1968 dmw__Iyear_1973 ///
                   dmw__Iyear_1978 dmw__Iyear_1985 dmw__Iyear_1988 dmw__Iyear_1997 ///
				   dmw__Iyear_1999-dmw__Iyear_2013

	
	
	


		

			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	


*-------------------------------------------------------------------------------
* set up loop over two panels
*-------------------------------------------------------------------------------

	/* Note: The main table has two panels, one 
		     with unweighted estimates and the other
			 weighted by population. This section
			 sets up a loop over these two options.
			 
			 Note that in the first of the two loops,
			 the local w is not defined; in the second,
			 it takes the value "w".
			 
			 */
	
local panel = "a"
	
foreach ending in "," "[aw = pob_cgr]," {

eststo clear

	


	
		

			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	


*-------------------------------------------------------------------------------
* table: main results
*-------------------------------------------------------------------------------


	
* bivariate
*----------

xi: areg hrate_combo `t' i.year `ending' ///
        a(ci_mun) cl(ci_mun) noomit

local b1 = _b[`t'] 


	
	* wild cluster bootstrap p-value for this
	*----------------------------------------
			
	reg dm`w'_hrate_combo dm`w'_`t' `yeardummies`w'' `ending' cl(estado)

	local b2 = _b[dm`w'_`t']

	assert round(`b1',.01) == round(`b2',.01) /* Check that point estimates are the same */
	
	bootwildct dm_`t' `yeardummies', numvars(1)



* logged DV
*----------

xi: areg ln_hrate_combo `t' i.year `ending' ///
        a(ci_mun) cl(ci_mun) noomit

local b1 = _b[`t'] 



	* wild cluster bootstrap p-value for this
	*----------------------------------------
	
	reg dm`w'_ln_hrate_combo dm`w'_`t' `yeardummies`w'' `ending' cl(estado)
	
	local b2 = _b[dm`w'_`t']

	assert round(`b1',.01) == round(`b2',.01) /* Check that point estimates are the same */

	bootwildct dm_`t' `yeardummies', numvars(1)

			

* + population control
*---------------------

xi: areg hrate_combo `t' ///
         ln_pob i.year*pob_1990 `ending' ///
         a(ci_mun) cl(ci_mun) noomit

local b1 = _b[`t'] 



	* wild cluster bootstrap p-value for this
	*----------------------------------------
	
	reg dm`w'_hrate_combo dm`w'_`t' `yeardummies`w'' ///
		dm`w'_ln_pob dm`w'_pob1990x* `ending' cl(estado)

	local b2 = _b[dm`w'_`t']

	assert round(`b1',.01) == round(`b2',.01) /* Check that point estimates are the same */

	bootwildct dm_`t' `yeardummies' dm_ln_pob dm_pob1990x*, numvars(1)


	
* store estimate: + place-specific linear trends
*-----------------------------------------------

xi: areg hrate_combo `t' ///
         ln_pob i.year i.ci_mun*year `ending' ///
         a(ci_mun) cl(ci_mun) noomit

local b1 = _b[`t'] 
		


	* wild cluster bootstrap p-value for this
	*----------------------------------------
	
	reg dm`w'_hrate_combo dm`w'_`t' `yeardummies`w'' ///
		dm`w'_ln_pob dm`w'_Tx* `ending' cl(estado)

	local b2 = _b[dm`w'_`t']

	assert round(`b1',.01) == round(`b2',.01) /* Check that point estimates are the same */

	bootwildct dm_`t' `yeardummies' dm_ln_pob dm_Tx*, numvars(1)

	

* excluding adjacent municipalities
*----------------------------------

xi: areg hrate_combo `t' ///
         ln_pob i.year*pob_1990 if panam_neighbors == 0 `ending' ///
         a(ci_mun) cl(ci_mun) noomit

local b1 = _b[`t'] 



	* wild cluster bootstrap p-value for this
	*----------------------------------------
	
	reg dm`w'_hrate_combo dm`w'_`t' `yeardummies`w'' ///
		dm`w'_ln_pob dm`w'_pob1990x* if panam_neighbors == 0 `ending' cl(estado)

	local b2 = _b[dm`w'_`t']

	assert round(`b1',.01) == round(`b2',.01) /* Check that point estimates are the same */

	bootwildct dm_`t' `yeardummies' dm_ln_pob dm_pob1990x*, numvars(1)

	

* advance panel counter and close loop over weights
*--------------------------------------------------
		
local panel = "b"

local w = "w"

	}
	
		 
		 





	



			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	
						** end of do file **		
