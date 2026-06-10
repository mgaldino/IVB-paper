// Wild cluster bootstrap t with the null hypothesis imposed //
* Authors: Bansi Malde and Molly Scott (for v2.2)
* First version: Aug 2010
* This version 16.12.14. This is version 2.2
* Iteration 1.6 added assert statements to check the new version of each file with older ones and hence ensure that by expanding one part of
* the file, we've not broken another part 

* Iteration 1.7: adds an option called numvars which will specify the number of variables for which the bootstrap needs to be computed.
* Iteration 1.8: Corrects a bug with the set seed command.
* Iteration 1.9: More corrections to set seed
* Iteration 2.1: Storing results in e(class)
* Iteration 2.2: Store the p values in a matrix in e class so that they can be accessed by commands like estout.

/* 15 Sep 2010 This is a post-estimation command. Run it after the regression has been run. The syntax is:
bootwildct <varlist>, [hypothesis()] [bootreps()] [numvars()]
where `varlist' for the moment should include ALL regressors in the regression for which you are trying to obtain the corrected 
p-values. The command implements a wild cluster bootstrap - t with the null hypothesis imposed. This method is explained in 
Cameron, Gelbach, Miller (2007), ReStat. 
There are currently 3 major limitations with this programme:
1) You need to include all regressors in varlist
2) It doesn't display the bootstrapped standard errors
3) This works for the reg command with simple hypotheses only 

*/


set trace on				/* This helps in debugging the code */
set tracedepth 1

version 10.1
*set seed 10101
cap program drop bootwildct
program bootwildct, sortpreserve eclass			// The sortpreserve preserves the sort order of the data once the programme is run //

syntax varlist(min=1) [if] [in] [=exp] [, HYPothesis(real 0) bootreps(integer 1000) numvars(integer 1000) seed(integer 10101)]
tokenize `varlist' 	// sets `1' to first word of varlist, 2 to the second and so on //

local wordc : word count `varlist'
* Bottom 2 lines added v1.9 (and commented out previous set seed)
local orig_seed=c(seed)
set seed `seed'
	
// Saving some of the post estimation saved results that will be used by the programme //
local command=e(cmd)
local degfree =e(df_m)
local degclust = e(df_r)
local clustvar= e(clustvar)
local depvar = e(depvar)


tempvar hyps
		
cap clear mata
mata: beta = (st_matrix("e(b)"))
mata: sd = sqrt(diag(st_matrix("e(V)")))
mata: namev = st_matrixcolstripe("e(b)")
local numrhsvars = `wordc' + 1
mata: hyp = J(`numrhsvars', 1, `hypothesis') 
mata: st_matrix("`hyps'", hyp)
mata: beta = beta'						/* Now an n*1 vector, where n = number of explanatory vars */
mata: st_matrix("betas", beta)
local numcols = rowsof(betas)
local numcols = `numcols'-1			
mata: st_matrix("sds", sd)
mata: t_stat = (beta-hyp):*diagonal(invsym(sd))		/* n by 1 vector */
mata: st_matrix("tstat", t_stat)


* Generating an error message if the number of variables in varlist < number of variables in the main regression 
if `wordc' < `numcols' {

error 102

}


global mainb betas
global maint tstat

/*.........................................................................
Create a vector to store the bootstrapped p-values in, so they can be accessed after running the bootstrap.
..................................................................................

This vector needs to be the length of the number of variables that are being
bootstrapped: which is either all independent variables or the number specified by 'numvars' command.
In other words, the minimum of wordc and numvars */

local minvars=min(`wordc', `numvars')

capture matrix drop A


matrix A = J(1, `minvars', .) // The vector is the length of the number of variables that we are bootstrapping.


// Then, we impose the null hypothesis. Note that the below is relevant for linear specifications only //
// To do this, we need to impose it one by one to each coefficient. We will do this using a loop, //
// with the tokenized varlist //

local i=1 
while "``i''"~="" { 

		// Next, creating the file and declaring the variable names and filename where the results will be stored //
		tempfile bootsave
		cap erase `bootsave'
		cap postclose bskeep
		qui postfile bskeep t_wild /*wild_b*/ using `bootsave', replace


		// This bit imposes the null hypothesis in the following way: 											    //
		// First, we removed the part of the dependent variable that is described by the variable on which the null hypothesis is imposed //
		// Then, we run a restricted regression of the restricted dependent variable on the varlist excluding the one on which the null is//
		// imposed. Then, we obtain the uhat and yhat for this regression. To the yhat, we add on the restricted variable * value it is //
		// hypothesized to take. //
		// So as not to change the data, we create variables temp_``i'' to save the restricted variables, before setting them to 0 for the //
		// restricted regression and then replacing them back after the regression is conducted. //

		qui cap drop temp_``i'' 
		qui cap drop tempy
		qui gen temp_``i'' = ``i''
		qui gen tempy = `depvar' - ``i''*`hypothesis'
		qui replace ``i''=0
		qui cap drop u_imposed
		qui cap drop yhat_imposed
		qui `command' tempy `varlist'
		qui predict u_imposed, resid
		qui predict yhat_imposed, xb
		qui replace ``i'' = temp_``i''
		qui replace yhat_imposed = yhat_imposed + ``i''*`hypothesis'
		qui drop temp_``i'' tempy

		// Next, computing the number of clusters - this will be needed later in the programme //
		qui ta `clustvar'
		global num = r(N)


		// Next, the loop for the wild bootstrap //
		*set seed 10101 /*(comm out v 1.9)*/
			forvalues b = 1/`bootreps'	{
				* Wild bootstrap first
				qui so `clustvar'
				
				qui cap drop temp
				qui cap drop pos
				// The next 2 lines randomly allocate clusters to either have a positive u or a negative one //
				qui bys `clustvar': gen temp = uniform()
				qui bys `clustvar': gen pos = (temp[1]<0.5)			
				
				tempvar wildresid wildy
				/* Then, computing the residual for the wild bootstrap with the null hypothesis imposed */
				qui gen `wildresid' = u_imposed*(2*pos-1)
				qui gen `wildy' = yhat_imposed + `wildresid'
				qui `command' `wildy' `varlist', cluster(`clustvar')
					
				local bst_wild = (_b[``i''] - `hypothesis')/_se[``i'']		
						
				post bskeep (`bst_wild') 				
				qui cap drop `wildresid' `wildy' temp pos
				}						/* End of bootstrap reps */

		qui postclose bskeep
		qui cap drop u_imposed yhat_imposed 

		preserve		
		qui drop _all
		qui set obs 1
		scalar t_stat = tstat[`i',1]
		scalar beta`i' = betas[`i',1]
		qui cap drop t_wild 
		qui cap drop beta
		qui gen t_wild = t_stat
		qui gen beta = beta`i'

		qui append using `bootsave'

		//p-value computation// 
		qui cap drop n
		qui gen n=.
		qui sum t_wild
		scalar bign = r(N)
		qui so t_wild
		qui replace n = _n
		qui sum n if abs(t_wild - t_stat) < .000001
		scalar myp = r(mean)/bign
		scalar pctile_twild = 2*min(myp, (1-myp))
		ereturn scalar twild_pval = pctile_twild
		
		* Now store the p values in vector A.
		mat A[1,`i']=pctile_twild // put the bootstrapped p value in the ith element of the vector
		
		
		// p-value for the main t statistic//
		scalar mainp = ttail(`degclust',t_stat)
		scalar pctile_main = 2*min(mainp, (1-mainp))

			
		//Displaying the results//
		local myfmt = "%7.5f"

		di
		if `i'==1 {0
		di "Number BS reps = `bootreps', Null hypothesis = `hypothesis'"
		display "Variable" _column(15) "Main Beta" _column(26) "Main t" _column(35) "Main p-value" _column(49) "T_wild p-value" _column(64) 
		
		di "``i''" _column(15) %6.3f beta`i' _column(26) %6.3f t_stat _column(35) `myfmt' pctile_main _column(49) `myfmt' pctile_twild _column(64) 
		}
		else {
		di "``i''" _column(15) %6.3f beta`i' _column(26) %6.3f t_stat _column(35) `myfmt' pctile_main _column(49) `myfmt' pctile_twild _column(64) 
		}
		
		qui cap drop t_wild 
		restore

		if `i'< `minvars' { 
		local ++i	// Next variable of varlist to be placed in the local. This takes us back to the top //
		}
		else { // finish loop if we have looped over all variables in varlist
		set seed `orig_seed'     /*added v1.9*/
		
		ereturn clear
		ereturn matrix t_wild_pval A
		
		exit
		}
}		/* End of i loop */


ereturn matrix t_wild_pval A

end


