	

	******************************************************************
	**
	**
	**		NAME:		DOROTHY KRONICK
	**		DATE: 		September 27, 2017
	**		PROJECT: 	Venezuela's homicide wave
	**
	**		DETAILS: 	This file estimates additional 
	**					specifications of the main
	**					difference-in-differences equation,
	**					in particular, controlling for
	**					local police presence and 
	**					mayoral party.
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

do "2019/bootwildct.ado"
	
	
	


		

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
					   `t' `years' pob1990x* Tx* pol_local alc_ofic {

	egen mean = mean(`var'), by(ci_mun)
	
	gen dm_`var' = `var' - mean
	
	drop mean
	
	}


	
* need additional set of de-meaned values for pre-1999 specification
*-------------------------------------------------------------------
		
foreach var of varlist hrate_combo ln_pob `t' `years' {

	egen mean = mean(`var') if year < 1999, by(ci_mun)
	
	gen dm99_`var' = `var' - mean
	
	drop mean
	
	}
	
	
	
* collect year dummies in a list
*-------------------------------
	
local yeardummies dm__Iyear_1958 dm__Iyear_1963 dm__Iyear_1968 dm__Iyear_1973 ///
                  dm__Iyear_1978 dm__Iyear_1985 dm__Iyear_1988 dm__Iyear_1997 ///
				  dm__Iyear_1999-dm__Iyear_2013

local yeardummies99 dm99__Iyear_1958 dm99__Iyear_1963 dm99__Iyear_1968 dm99__Iyear_1973 ///
                    dm99__Iyear_1978 dm99__Iyear_1985 dm99__Iyear_1988 dm99__Iyear_1997 ///
				    dm99__Iyear_1999-dm99__Iyear_2013


	
		


		

			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	


*-------------------------------------------------------------------------------
* table: alternative explanations
*-------------------------------------------------------------------------------



* pre-1999 only
*--------------

xi: areg hrate_combo `t' i.year if year < 1999, ///
         a(ci_mun) cl(ci_mun) noomit

local b1 = _b[`t'] 
	


	* wild cluster bootstrap p-value for this
	*----------------------------------------
			
	reg dm99_hrate_combo dm99_`t' `yeardummies99' if year < 1999, cl(estado)

	local b2 = _b[dm99_`t']

	assert round(`b1',.01) == round(`b2',.01) /* Check that point estimates are the same */
	
	bootwildct dm99_`t' `yeardummies99', numvars(1)

	

* + population and police
*------------------------

xi: areg hrate_combo `t' ///
         ln_pob pol_local i.year*pob_1990, ///
         a(ci_mun) cl(ci_mun) noomit

local b1 = _b[`t'] 



	* wild cluster bootstrap p-value for this
	*----------------------------------------
			
	reg dm_hrate_combo dm_`t' `yeardummies' ///
		dm_ln_pob dm_pol_local dm_pob1990x*, cl(estado)

	local b2 = _b[dm_`t']

	assert round(`b1',.01) == round(`b2',.01) /* Check that point estimates are the same */
	
	bootwildct dm_`t' `yeardummies' dm_ln_pob dm_pol_local dm_pob1990x*, numvars(1)

	
	
* + population, police, mayor
*----------------------------

xi: areg hrate_combo `t' ///
         ln_pob pol_local alc_ofic i.year*pob_1990, ///
         a(ci_mun) cl(ci_mun) noomit

local b1 = _b[`t'] 



	* wild cluster bootstrap p-value for this
	*----------------------------------------
			
	reg dm_hrate_combo dm_`t' `yeardummies' ///
		dm_ln_pob dm_pol_local dm_alc_ofic dm_pob1990x*, cl(estado)

	local b2 = _b[dm_`t']

	assert round(`b1',.01) == round(`b2',.01) /* Check that point estimates are the same */
	
	bootwildct dm_`t' `yeardummies' ///
			   dm_ln_pob dm_pol_local dm_alc_ofic dm_pob1990x*, numvars(1)
	
	

* + population, police, mayor, muni-specific linear trends
*---------------------------------------------------------

eststo: xi: areg hrate_combo `t' ///
        ln_pob pol_local alc_ofic i.year i.ci_mun*year, ///
        a(ci_mun) cl(ci_mun) noomit

local b1 = _b[`t'] 



	* wild cluster bootstrap p-value for this
	*----------------------------------------
			
	reg dm_hrate_combo dm_`t' `yeardummies' ///
		dm_ln_pob dm_pol_local dm_alc_ofic dm_Tx*, cl(estado)

	local b2 = _b[dm_`t']

	assert round(`b1',.01) == round(`b2',.01) /* Check that point estimates are the same */
	
	bootwildct dm_`t' `yeardummies' ///
			   dm_ln_pob dm_pol_local dm_alc_ofic dm_Tx*, numvars(1)

	

* placebo
*--------

	/* Don't need Wild cluster bootstrap p-value for this. */

xi: areg m1year_rate_combo `t' ///
         ln_pob i.year*pob_1990, ///
         a(ci_mun) cl(ci_mun) noomit





	



			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
			**	**	**	**	**	**	**	**	**	**	**	**	**
	
						** end of do file **		


