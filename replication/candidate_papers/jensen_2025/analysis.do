/******************************************************************************************************
*	analysis.do	
* 	
*	This script reproduces the analyses in the manuscript and appendices for the article
* 	"Educating For Democracy? Going to College Increases Political Participation"
*	Author: Andreas Videbæk Jensen
*
********************************************************************************************************/

***************************************************************
* Contents:                                                   *
* - Section 1: Forest plots and meta-analyses                 *
* - Section 2: Analyses of ELS:2002 data                      *
* - Section 3: Analyses of NELS:88 data                       *
***************************************************************

*   Note: When esttab command is used to produce tables below, parts of the command are commented out in this script in order to make the results viewable in the output window of Stata. To produce the tables in LaTeX format, uncomment the relevant parts of the esttab command, cf. the code comments for each esttab invocation below. 

/* OBS. Make sure to change Stata's working directory to the main folder of this replication package called "replication_files" */
cd "(...)INSERT PATH TO FOLDER HERE (...)/replication_files"

****************************************************************************
**** Section 1: Forest plots and meta-analyses 							****	
****************************************************************************	
    clear
    use "forest_data.dta"
    meta set beta se, studylabel(study) eslabel(mean diff.)

    set scheme plotplain

    *** 1.1 Forest plott in Figure 1, main manuscript
        *** Figure 1, Main manuscript
        meta forestplot _id _plot design if mean_turnout_dif_study == 1 , nullrefline noohetstats noohomtest noosigtest nonotes sort(var4) nowmarkers title("Figure 1. Effects of College on Voter Turnout")  markeropts(msize(large)) xtitle("Effect on Voter Turnout (0/1)") name(turnout_studies, replace)  itemopts(size(small))  customover(0.046 0.013 0.080,label("only previous studies"))   xscale(r(-.2 .4)) xlab(-.2 (.1) .4) omarkeropts(mlwidth(none))

    *** 1.2 Appendix C: 
        *** Appendix C4: Meta-analyses
            *Figure C2 - meta-analysis in figure 1, with details.
            meta forestplot _id _plot _esci  if mean_turnout_dif_study == 1 , nullrefline nowmarkers sort(var4) markeropts(msize(large)) xtitle("Effect on Voter Turnout (0/1)")	name(C2,replace) columnopts(_esci, format(%7.3f))


            *Figure C3 - Fixed effects
            meta forestplot _id _plot _esci  if mean_turnout_dif_study == 1 , nullrefline nowmarkers sort(var4) markeropts(msize(large)) xtitle("Effect on Voter Turnout (0/1)")	fixed name(C3,replace) columnopts(_esci, format(%7.3f))


            *Figure C4 - Only Prior Studies (Also used in figure 1)
            meta forestplot _id _plot _esci  if mean_turnout_dif_study == 1 & !inlist(design,"{it:Individual Level DiD}") , nullrefline nowmarkers sort(var4) markeropts(msize(large)) xtitle("Effect on Voter Turnout (0/1)")	name(C4,replace) columnopts(_esci, format(%7.3f))


            *Figure C5 - Only Studies From US Context
            meta forestplot _id _plot _esci  if mean_turnout_dif_study == 1 & strpos(study, "USA") & !(strpos(study, "Repl")) , nullrefline  nowmarkers sort(var4) markeropts(msize(large)) xtitle("Effect on Voter Turnout (0/1)")	name(C5,replace) columnopts(_esci, format(%7.3f))


            *Figure C6 - Subgrouping studies by short vs. long-term effects of college.
            meta forestplot _id _plot _esci  if mean_turnout_dif_study == 1 & !(strpos(study, "Repl")), nullrefline nowmarkers sort(var4) subgroup(short_term) markeropts(msize(large)) xtitle("Effect on Voter Turnout (0/1)")	name(C6,replace) columnopts(_esci, format(%7.3f))

        *** Appendix C1
            *Figure C1 - Effects of College on Outcome = Scale of Participatory Acts.
            meta forestplot _id _plot if mean_turnout_dif_study == 0 , nullrefline nometashow noover noohetstats noohomtest noosigtest nonotes sort(var4) nowmarkers title("Figure C1. Effects of College on Scale of Participatory Acts.") subtitle("Forest Plot summarizing existing evidence.")   markeropts(msize(large)) xtitle("Effect on Scale of Political Acts (1-10)") name(scale_studies, replace)

****************************************************************************
**** Section 2: Analyses of ELS:2002 data								****	
****************************************************************************
    cls
    clear
    use "analysis_data_ELS.dta"

    *** 2.1 Appendix F3: Descriptive statistics and balance tables
        eststo clear
        frame copy default descriptive_analyses, replace
        frame change descriptive_analyses

        xtreg voted treatment_level_at_t2##i.PostPeriod  if eligib == 1  & non_hs_grad_2004 != 1 & mis_on_voting_and_cg != 1 ,  cl(STU_ID) fe
        keep if e(sample) 
        drop if PostPeriod==0
        recode BYTXCSTD  (-8 = .)
        recode F1SES1 (-8 =.) 
        recode xx_no_move (0=1) (1=0), gen(tv_moved)

        label variable moved_away_from_parents06 "Share that stopped living with parents"
        label variable res_mob_at_t2 "Residential mobility (miles)" 
        label variable voted_in_PREPERIOD "Share that voted in Pre-treatment Election"
        label variable bb_par_died "Share that lost parent"
        label variable bb_par_div "Share whose parents divorced"
        label variable bb_accident "Share that suffered an accident"
        label variable m_birth_year "Year of birth"
        label variable m_sex "Sex (1=male)"
        label variable F1SES1 "Family socio-economic status (std. m=0, sd=1)"
        label variable BYTXCSTD "Test score math/reading (std. m=50 sd=10)"
        label variable xx_gotmarried "Share that got married"
        label variable tv_moved "Share that moved (residential mobility)"

        recode F2D13 (-9 -8 -7 -4 = .) (0 = 0 "No") (1 = 1 "Yes") , gen(vote_pre)
        recode F3D38 (-9 -8 -7 -4= . ) (0 = 0 "No") (1 = 1 "Yes") , gen(vote_post)
        label variable vote_pre "Voted in 2004"
        label variable vote_post "Voted in 2008"

        global DISTVARS vote_pre vote_post

        local count: word count $DISTVARS
        mat diststat = J(`count',7,.)

        local i = 1
        foreach var in $DISTVARS {
            quietly: summarize `var' if treatment_level_at_t2==0
            mat diststat[`i',1] = r(N)
            mat diststat[`i',2] = r(mean)
            quietly: summarize `var' if treatment_level_at_t2==1
            mat diststat[`i',3] = r(N)
            mat diststat[`i',4] = r(mean)
            local i = `i' + 1
        }
        frmttable, statmat(diststat) store(diststat) sfmt(g,f,g,f,g,f)

        *Table F3 - sample means on voting in 2004 and 2008 by treatment status
        outreg /* using "tableF3.tex" */ , ///
            replay(diststat) tex nocenter note("") fragment plain /*coljust(l;r;r;r;c) */ replace ///
            rtitles("Voted in 2004            "\ "Voted in 2008            ") ///
            ctitles("", "No College", "", "Attended College", "" \ "", n, mean, n, mean) ///
            multicol(1,2,2;1,4,2) // Uncomment "using"-statement for latex export.

        * All content of Table F3: (Row 2 "Yes" in each tab)
        tab  vote_pre treatment_level_at_t2 , col
        tab  vote_post treatment_level_at_t2, col 

        * Table F2 - Descriptives by treatment status
        global DESCVARS moved_away_from_parents06 res_mob_at_t2 tv_moved xx_gotmarried voted_in_PREPERIOD m_sex BYTXCSTD F1SES1
        mata: mata clear

        * First test of differences
        local i = 1
        foreach var in $DESCVARS {
            reg `var' treatment_level_at_t2, vce(robust)
            outreg, drop(_cons)  rtitle("`: var label `var''") stats(b) ///
                noautosumm store(row`i')  starloc(1)
            outreg, replay(diff) append(row`i') ctitles("",Difference ) ///
                store(diff) note("")
            local ++i
        }
        outreg, replay(diff) 

        *Summary statistics
        local count: word count $DESCVARS
        mat sumstat = J(`count',2,.)

        local i = 1
        foreach var in $DESCVARS {
            quietly: summarize `var' if treatment_level_at_t2==0
            mat sumstat[`i',1] = r(mean)
            quietly: summarize `var' if treatment_level_at_t2==1
            mat sumstat[`i',2] = r(mean)
            //quietly: summarize `var' if treatment_level_at_t2==2
            //mat sumstat[`i',3] = r(mean)
            local i = `i' + 1
        }

        frmttable, statmat(sumstat) store(sumstat) sfmt(f,f,f)

        outreg , ///
            replay(sumstat) merge(diff) store(almost) tex nocenter note("") fragment plain  replace // 

        outreg /*using "tableF2.tex" */, ///
            replay(almost) tex nocenter note("") fragment plain coljust(l;r;r;c) replace ///
            ctitles("", "No College", "Attended College" , "" \ "",  mean,mean,  "Difference")    // Uncomment "using"-statement for latex export.
        
        frame change default
        frame drop descriptive_analyses

    *** 2.2 Appendix A2: Placebo Analysis
        xtreg voted i.placebo_collegeGoing##i.PostPeriod i.PostPeriod##i.voted_in_PREPERIOD  if eligib == 1  & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe 
        eststo p1a
        estadd local FE "\checkmark"
        estadd local TE "\checkmark"
        estadd local VH "\checkmark"
        estadd local TVC ""

        xtreg voted i.placebo_collegeGoing##i.PostPeriod i.PostPeriod##i.voted_in_PREPERIOD xx_* i.lives_with_par_mod F2D15A_ F2D15B_ F2D15C_ F2D15D_ F2D15E_ F2D15F_ F2D15G_ became_parent_ paidwork if eligib == 1  & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe
        eststo p1b 
        estadd local FE "\checkmark"
        estadd local TE "\checkmark"
        estadd local VH "\checkmark"
        estadd local TVC "\checkmark"


        xtreg voted i.placebo_collegeGoing##i.PostPeriod i.PostPeriod##i.voted_in_PREPERIOD xx_* i.lives_with_par_mod F2D15A_ F2D15B_ F2D15C_ F2D15D_ F2D15E_ F2D15F_ F2D15G_ became_parent_ paidwork i.PostPeriod##i.(rr_dyn_cog rr_dyn_ses m_sex m_race)  if eligib == 1  & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe
        eststo p1c
        estadd local FE "\checkmark"
        estadd local TE "\checkmark"
        estadd local VH "\checkmark"
        estadd local TVC "\checkmark"
        estadd local DYN "\checkmark"

        esttab  p1c p1b p1a /* using "table_A2.tex"*/, replace f  /// 
            keep(*placebo_collegeGoing#1.PostPeriod) drop(0.*) b(3) se(3) nomtitle ///
            refcat(1.placebo_collegeGoing#1.PostPeriod "No College") ///
            coeflabel(1.placebo_collegeGoing#1.PostPeriod  "Attended College") ///
            /*booktabs collabels(none) compress noobs alignment(D{.}{.}{-1}) */ ///	
        scalars("TE Time FEs \& Individual FEs" "VH Prior Voting" "TVC Additional Time-varying Controls" "DYN Pre-college Covariates $\times$ Time FEs" "N_g Units" "N Observations"  ) sfmt(%12.0fc) // Uncomment using and booktabs for latex export. 



    *** 2.3 Appendix L: Effect of College on Voting in Non-Presidential Elections
        /*We use the following variables:
        %   -  Measured in 2006: Did you vote in local election in last 2 years (between 2004 and 2006). "Voted in local or state election in past 2 years (F2D12)"
        %   -  Measured in 2012: Did you vote in local in 09, 10 or 11? "Whether voted in any local/state/national election during 2009, 2010, or 2011 (F3D39)"
        % --> Treatment: (1 = Some college in 2007, 2008 or 2009. 0 otherwise.) */
        
        gen  went_to_college_btw_06_and_09 = .
        replace went_to_college_btw_06_and_09 = 1 if treatment_level_at_t2 == 1 & !inlist(F3PS1START,2003,2004,2005,2006) & !inlist(F3TZPS1START,2003,2004,2005,2006)
        replace went_to_college_btw_06_and_09 = 0 if treatment_level_at_t2 == 0 
        replace went_to_college_btw_06_and_09 = 1 if placebo_collegeGoing == 1 

        *** Outcome-variable: voting in 06 vs 9-12 locals:
        gen t2_t3_voting = F2D12 if PostPeriod == 0
        replace t2_t3_voting = F3D39 if PostPeriod == 1
        recode t2_t3_voting (-4 -7 -8 -9 = .)
        gen voted_in_pre06 = F2D12
        recode voted_in_pre06 (-4 -7 -8 -9 = .)

        *** Regressions:
        xtreg t2_t3_voting c.went_to_college_btw_06_and_09##c.PostPeriod c.PostPeriod##c.voted_in_pre06 if eligib == 1  & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe
        eststo nonpres_a
        estadd local FE "\checkmark"
        estadd local TE "\checkmark"
        estadd local VH "\checkmark"
        estadd local TVC ""

        xtreg t2_t3_voting c.went_to_college_btw_06_and_09##c.PostPeriod c.PostPeriod##c.voted_in_pre06 i.PostPeriod##i.(rr_dyn_cog rr_dyn_ses m_sex m_race) if eligib == 1  & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe
        eststo nonpres_b
        estadd local FE "\checkmark"
        estadd local TE "\checkmark"
        estadd local VH "\checkmark"
        estadd local DYN "\checkmark"
            
        *** Table L1
        esttab  nonpres_a nonpres_b /*using "non_pres_table.tex"*/, replace f  ///
            keep(*went_to_college_btw_06_and_09#*) b(3) se(3) nomtitle ///
            refcat(c.went_to_college_btw_06_and_09#c.PostPeriod "No College") ///
            coeflabel(c.went_to_college_btw_06_and_09#c.PostPeriod  "Attended College") ///
            /*booktabs collabels(none) compress noobs alignment(D{.}{.}{-1}) */ ///	
        scalars("TE Time FEs \& Individual FEs" "VH Pre-college Voting $\times$ Time FEs" "TVC Time-varying Controls" "DYN Additional Pre-college Covariates $\times$ Time FEs" "N_g Units" "N Observations"  ) sfmt(%12.0fc) 

    *** 2.4: Main Analyses (Table 1)
        *** Full sample models (models 1 to 3)
            xtreg voted i.treatment_level_at_t2##i.PostPeriod i.PostPeriod##i.voted_in_PREPERIOD if eligib == 1  & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe 
            eststo m1
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"


            xtreg voted i.treatment_level_at_t2##i.PostPeriod i.PostPeriod##i.voted_in_PREPERIOD xx_* i.lives_with_par_mod F2D15A_ F2D15B_ F2D15C_ F2D15D_ F2D15E_ F2D15F_ F2D15G_ became_parent_ paidwork if eligib == 1  & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe 
            eststo m2
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC "\checkmark"

            xtreg voted i.treatment_level_at_t2##i.PostPeriod i.PostPeriod##i.voted_in_PREPERIOD xx_* i.lives_with_par_mod F2D15A_ F2D15B_ F2D15C_ F2D15D_ F2D15E_ F2D15F_ F2D15G_ became_parent_ paidwork i.PostPeriod##i.(rr_dyn_ses rr_dyn_cog) i.PostPeriod##i.m_race i.PostPeriod##i.m_sex  if eligib == 1  & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe 
            eststo m3
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC "\checkmark"
            estadd local DYN "\checkmark"
        
        *** Restricted sample models (models 4-6)
            * Here we overwrite the treatment variable with the restricted treatment variable to allow for homogenous tabulation
            * This has to be undone at the end of the restricted sample models.
            rename treatment_level_at_t2 temp_treatment_level_at_t2
            clonevar treatment_level_at_t2 = restr_treatment_level_at_t2    
            
            *Models 4-6
            xtreg voted i.treatment_level_at_t2##i.PostPeriod i.PostPeriod##i.voted_in_PREPERIOD if eligib == 1  & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe
            eststo m4
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC ""

            xtreg voted i.treatment_level_at_t2##i.PostPeriod i.PostPeriod##i.voted_in_PREPERIOD xx_* i.lives_with_par_mod F2D15A_ F2D15B_ F2D15C_ F2D15D_ F2D15E_ F2D15F_ F2D15G_ became_parent_ paidwork if eligib == 1  & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe 
            eststo m5
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC "\checkmark"

            xtreg voted i.treatment_level_at_t2##i.PostPeriod i.PostPeriod##i.voted_in_PREPERIOD xx_* i.lives_with_par_mod  F2D15A_ F2D15B_ F2D15C_ F2D15D_ F2D15E_ F2D15F_ F2D15G_ became_parent_ paidwork i.PostPeriod##i.(rr_dyn_ses rr_dyn_cog)  i.PostPeriod##i.m_race i.PostPeriod##i.m_sex   if eligib == 1  & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe 
            eststo m6
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC "\checkmark"
            estadd local DYN "\checkmark"

        ***Restores the original treatment variable, which was overwritten in the restricted sample models to allow for homogenous tabulation.
        drop treatment_level_at_t2 
        rename temp_treatment_level_at_t2 treatment_level_at_t2

        ***Matching models (models 7-8)
            gen weights_all = .
            replace weights_all = weights_notvc
            xtreg voted i.treatment_level_at_t2##i.PostPeriod  if eligib == 1 & non_hs_grad_2004 != 1 & treatment_level_at_t2!=. [pw =weights_all], cl(STU_ID) fe 
            eststo m7
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC ""

            replace weights_all = weights_tvc
            xtreg voted i.treatment_level_at_t2##i.PostPeriod i.PostPeriod##i.voted_in_PREPERIOD xx_* i.lives_with_par_mod F2D15A_ F2D15B_ F2D15C_ F2D15D_ F2D15E_ F2D15F_ F2D15G_ became_parent_ paidwork if eligib == 1 & non_hs_grad_2004 != 1 & treatment_level_at_t2!=. [pw =weights_all],  cl(STU_ID) fe 
            eststo m8
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC "\checkmark"

        *** Table 1
        esttab m1 m2 m3 m4 m5 m6 m7 m8 /*using "table1.tex"*/, replace f  ///
            keep(*treatment_level_at_t2#1.PostPeriod) drop(0.*) b(3) se(3) nomtitle ///
            refcat(1.treatment_level_at_t2#1.PostPeriod "No College") ///
            coeflabel(1.treatment_level_at_t2#1.PostPeriod  "Attended College") ///
            /*booktabs collabels(none) compress noobs alignment(D{.}{.}{-1})*/ ///	
            scalars("TE Time FEs \& Individual FEs" "VH Prior Voting" "TVC Additional time-varying controls" ///
                "DYN Dynamic Effects" "N_g Units" "N Observations"  ) sfmt(%12.0fc) ///
            mgroups("Full Sample" "Restricted Untr.Grp." "Matched", pattern(1 0 0 1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) ///
            span erepeat(\cmidrule(lr){@span})) // Uncomment "/* */"-sections with "using" and "booktabs" for latex export.

        
    *** 2.5: Appendix E: Robustness to College Timing and Military Service 
        ***Table E1 - Military service
            *** Restricted sample models (Models 1 to 3)
                
                *These are based on the restricted control group. Therefore we overwrite the original treatment variable with the restricted treatment variable to allow for homogenous tabulation. We then restore this overwritten variable at the end of the restricted models.
                rename treatment_level_at_t2 temp_treatment_level_at_t2
                clonevar treatment_level_at_t2 = restr_treatment_level_at_t2

                *Models 1 to 3
                xtreg voted i.treatment_level_at_t2##i.PostPeriod i.PostPeriod##i.voted_in_PREPERIOD  if eligib == 1  & non_hs_grad_2004 != 1 & !(served_military) ,  cl(STU_ID) fe 
                eststo mE1_1
                estadd local FE "\checkmark"
                estadd local TE "\checkmark"
                estadd local VH "\checkmark"
                estadd local TVC ""

                xtreg voted i.treatment_level_at_t2##i.PostPeriod i.PostPeriod##i.voted_in_PREPERIOD xx_no_move i.lives_with_par_mod if eligib == 1  & non_hs_grad_2004 != 1  & !(served_military),  cl(STU_ID) fe
                eststo mE1_2
                estadd local FE "\checkmark"
                estadd local TE "\checkmark"
                estadd local VH "\checkmark"
                estadd local TVC "\checkmark"

                xtreg voted i.treatment_level_at_t2##i.PostPeriod i.PostPeriod##i.voted_in_PREPERIOD xx_no_move i.lives_with_par_mod i.timevarying_military_service if eligib == 1  & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe
                eststo mE1_3
                estadd local FE "\checkmark"
                estadd local TE "\checkmark"
                estadd local VH "\checkmark"
                estadd local TVC "\checkmark"

                *Restores the original treatment variable, which was overwritten in the restricted sample models to allow for homogenous tabulation.
                drop treatment_level_at_t2 
                rename temp_treatment_level_at_t2 treatment_level_at_t2

            *** Full sample models (Models 4 to 6) 
                xtreg voted i.treatment_level_at_t2##i.PostPeriod i.PostPeriod##i.voted_in_PREPERIOD if eligib == 1  & non_hs_grad_2004 != 1 & !(served_military) ,  cl(STU_ID) fe 
                eststo mE1_4
                estadd local FE "\checkmark"
                estadd local TE "\checkmark"
                estadd local VH "\checkmark"
                estadd local TVC ""

                xtreg voted i.treatment_level_at_t2##i.PostPeriod i.PostPeriod##i.voted_in_PREPERIOD xx_no_move i.lives_with_par_mod if eligib == 1  & non_hs_grad_2004 != 1  & !(served_military),  cl(STU_ID) fe
                eststo mE1_5
                estadd local FE "\checkmark"
                estadd local TE "\checkmark"
                estadd local VH "\checkmark"
                estadd local TVC "\checkmark"

                xtreg voted i.treatment_level_at_t2##i.PostPeriod i.PostPeriod##i.voted_in_PREPERIOD xx_* i.lives_with_par_mod i.timevarying_military_service if eligib == 1  & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe 
                eststo mE1_6
                estadd local FE "\checkmark"
                estadd local TE "\checkmark"
                estadd local VH "\checkmark"
                estadd local TVC "\checkmark"

            *** Table E1        
            esttab  mE1_1 mE1_2 mE1_3 mE1_4 mE1_5 mE1_6 /*using "tableE1.tex"*/, replace f  ///
            keep(*treatment_level_at_t2#1.PostPeriod) drop(0.*) b(3) se(3) nomtitle ///
            refcat(1.treatment_level_at_t2#1.PostPeriod "No College") ///
            coeflabel(1.treatment_level_at_t2#1.PostPeriod  "Attended College") ///
            /*booktabs collabels(none) compress noobs alignment(D{.}{.}{-1})*/ ///	
            scalars("TE Time FEs" "FE Individual FEs" "VH Prior Voting" "TVC Additional time-varying controls" "N_g Units" "N Observations"  ) sfmt(%12.0fc) ///
            mgroups("Restr. Ctrl.grp w. military dropped" "Restr. Ctrl.grp" "Full Sample w. military dropped" "Full Sample", pattern(1 0 1 1 0 1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) // Uncomment "/* */"-sections with "using" and "booktabs" for latex export.

        *** Table E2 - Timing of future attendance
            *** Contains only Restricted sample models (Models 1 to 4):
            
                *These are based on the restricted control group. Therefore we overwrite the original treatment variable with the restricted treatment variable to allow for homogenous tabulation. We then restore this overwritten variable at the end of the restricted models.
                rename treatment_level_at_t2 temp_treatment_level_at_t2
                clonevar treatment_level_at_t2 = restr_treatment_level_at_t2

                xtreg voted i.treatment_level_at_t2##i.PostPeriod i.PostPeriod##i.voted_in_PREPERIOD if eligib == 1  & non_hs_grad_2004 != 1 & (future_was_atmost_2009 | treatment_level_at_t2 != 0),  cl(STU_ID) fe 
                eststo mE2_1
                estadd local FE "\checkmark"
                estadd local TE "\checkmark"
                estadd local VH "\checkmark"
                estadd local TVC ""

                xtreg voted i.treatment_level_at_t2##i.PostPeriod i.PostPeriod##i.voted_in_PREPERIOD if eligib == 1  & non_hs_grad_2004 != 1 & (future_was_atmost_2010 | treatment_level_at_t2 != 0),  cl(STU_ID) fe 
                eststo mE2_2
                estadd local FE "\checkmark"
                estadd local TE "\checkmark"
                estadd local VH "\checkmark"
                estadd local TVC ""

                xtreg voted i.treatment_level_at_t2##i.PostPeriod i.PostPeriod##i.voted_in_PREPERIOD if eligib == 1  & non_hs_grad_2004 != 1 & (future_was_atmost_2011 | treatment_level_at_t2 != 0),  cl(STU_ID) fe 
                eststo mE2_3
                estadd local FE "\checkmark"
                estadd local TE "\checkmark"
                estadd local VH "\checkmark"
                estadd local TVC ""

                xtreg voted i.treatment_level_at_t2##i.PostPeriod i.PostPeriod##i.voted_in_PREPERIOD if eligib == 1  & non_hs_grad_2004 != 1 & (future_was_atmost_2012 | treatment_level_at_t2 != 0),  cl(STU_ID) fe 
                eststo mE2_4
                estadd local FE "\checkmark"
                estadd local TE "\checkmark"
                estadd local VH "\checkmark"
                estadd local TVC ""
                
                *Restores the original treatment variable, which was overwritten in the restricted sample models to allow for homogenous tabulation.
                drop treatment_level_at_t2 
                rename temp_treatment_level_at_t2 treatment_level_at_t2

            *** Table E2
            esttab  mE2_1 mE2_2 mE2_3 mE2_4 /*using "tableE2.tex"*/, replace f  ///
            keep(*treatment_level_at_t2#1.PostPeriod) drop(0.*) b(3) se(3) nomtitle ///
            refcat(1.treatment_level_at_t2#1.PostPeriod "No College") ///
            coeflabel(1.treatment_level_at_t2#1.PostPeriod  "Attended College") ///
            /*booktabs collabels(none) compress noobs alignment(D{.}{.}{-1})*/ ///	
            scalars("TE Time FEs" "FE Individual FEs" "VH Prior Voting" "TVC Additional time-varying controls" "N_g Units" "N Observations"  ) sfmt(%12.0fc) ///
            mgroups("fut. attend. \leq2009" "fut. attend. \leq2010" "fut. attend. \leq2011" "fut. attend. \leq2012", pattern(1 1 1 1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) //uncomment "/* */"-sections with "using" and "booktabs" for latex export.

    *** 2.6 Appendix D3: Different sets of covariates
        *** Table D1: Regressions with different combinations of time-varying covariates
            *** Models 1 and 2 come from table 1 (see above)

            *** Full Sample models 3 and 4 
                xtreg voted i.treatment_level_at_t2##i.PostPeriod   xx_* i.lives_with_par_mod F2D15A_ F2D15B_ F2D15C_ F2D15D_ F2D15E_ F2D15F_ F2D15G_ became_parent_ paidwork if eligib == 1  & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe 
                eststo mD1_3
                estadd local FE "\checkmark"
                estadd local TE "\checkmark"
                estadd local VH ""
                estadd local TVC "\checkmark"

                xtreg voted i.treatment_level_at_t2##i.PostPeriod  if eligib == 1 & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe
                eststo mD1_4
                estadd local FE "\checkmark"
                estadd local TE "\checkmark"
                estadd local TVC ""
            
            *** Models 5 and 6 come from table 1 (see above)

            *** Restricted sample models 7 and 8

                *These are based on the restricted control group. Therefore we overwrite the original treatment variable with the restricted treatment variable to allow for homogenous tabulation. We then restore this overwritten variable at the end of the restricted models.
                rename treatment_level_at_t2 temp_treatment_level_at_t2
                clonevar treatment_level_at_t2 = restr_treatment_level_at_t2

                xtreg voted i.treatment_level_at_t2##i.PostPeriod  xx_* i.lives_with_par_mod F2D15A_ F2D15B_ F2D15C_ F2D15D_ F2D15E_ F2D15F_ F2D15G_ became_parent_ paidwork if eligib == 1  & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe 
                eststo mD1_7
                estadd local FE "\checkmark"
                estadd local TE "\checkmark"
                estadd local VH ""
                estadd local TVC "\checkmark"

                xtreg voted i.treatment_level_at_t2##i.PostPeriod if eligib == 1  & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe
                eststo mD1_8
                estadd local FE "\checkmark"
                estadd local TE "\checkmark"
                estadd local VH ""
                estadd local TVC ""

                *Restores the original treatment variable, which was overwritten in the restricted sample models to allow for homogenous tabulation.
                drop treatment_level_at_t2 
                rename temp_treatment_level_at_t2 treatment_level_at_t2

                *Table D1
                esttab  m2 m1 mD1_3 mD1_4 m5 m4 mD1_7 mD1_8  /*using "tableD1.tex"*/, replace f  ///
                keep(*treatment_level_at_t2#1.PostPeriod) drop(0.*) b(3) se(3) nomtitle ///
                refcat(1.treatment_level_at_t2#1.PostPeriod "No College") ///
                coeflabel(1.treatment_level_at_t2#1.PostPeriod  "Attended College") ///
                /*booktabs collabels(none) compress noobs alignment(D{.}{.}{-1}) */ ///	
                scalars("TE Time FEs" "FE Individual FEs" "VH Prior Voting" "TVC Additional time-varying controls" "N_g Units" "N Observations"  ) sfmt(%12.0fc) ///
                mgroups("Full Sample" "Restricted Ctrl.grp", pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) // Uncomment "/* */"-sections with "using" and "booktabs" for latex export.


    *** 2.7 Appendix A3: Estimates for all Covariates
        *** Table A3: All coefficients from estimations reported in table 1. The row order of table A3 have been manually rearranged in the appendix to ease readability, and therefore differs from what is printed below.
        
            esttab m1 m2 m3 m4 m5 m6 m7 m8 /* using "tableA3.tex" */, replace f   ///
            drop(0.* 1.rr* 2.rr* 3.rr* 4.rr* 1.m* 2.m* 3.m* 4.m*) b(3) se(3) onecell nostar nomtitle ///
            refcat(1.treatment_level_at_t2#1.PostPeriod "No College") ///
            coeflabel(1.treatment_level_at_t2#1.PostPeriod  "Attended College") ///
            /*booktabs collabels(none) compress noobs alignment(D{.}{.}{-1}) */ ///	
            scalars("TE Time FEs \& Individual FEs" "VH Prior Voting" "TVC Add. time-varying covs" ///
                 "DYN Pre-college Covariates $\times$ Time FEs" "N_g Units" "N Observations"  ) sfmt(%12.0fc) ///
            mgroups("Full Sample" "Restricted Ctrl.grp" "Matched", pattern(1 0 0 1 0 0 1 0) ///
            prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) // Uncomment "/* */"-sections with "using" and "booktabs" for latex export.
            

    *** 2.8 Appendix I3: Matching Analyses
        *** Table I5: Genetic Matching vs. Propensity Scores

            *** Models 1 and 2 are from table 1 (see above)

            *** Models 3 and 4 (Inverse probability weights using propensity scores)
            replace weights_all = weights_all_pscore
            xtreg voted i.treatment_level_at_t2##i.PostPeriod  if eligib == 1 & non_hs_grad_2004 != 1 & treatment_level_at_t2!=. [pw =weights_all], cl(STU_ID) fe 
            eststo mI5_3
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC ""
            
            replace weights_all = weights_all_pscore
            xtreg voted i.treatment_level_at_t2##i.PostPeriod i.PostPeriod##i.voted_in_PREPERIOD xx_* i.lives_with_par_mod F2D15A_ F2D15B_ F2D15C_ F2D15D_ F2D15E_ F2D15F_ F2D15G_ became_parent_ paidwork if eligib == 1 & non_hs_grad_2004 != 1 & treatment_level_at_t2!=. [pw =weights_all],  cl(STU_ID) fe 
            eststo mI5_4
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC "\checkmark"


            esttab m7 m8 mI5_3 mI5_4 /*using "tableI5.tex" */, replace f  ///
            keep(*treatment_level_at_t2#1.PostPeriod) drop(0.*) b(3) se(3) nomtitle ///
            refcat(1.treatment_level_at_t2#1.PostPeriod "No College") ///
            coeflabel(1.treatment_level_at_t2#1.PostPeriod  "Attended College") ///
            /*booktabs collabels(none) compress noobs alignment(D{.}{.}{-1}) */ ///	
            scalars("TE Time FEs \& Individual FEs" "VH Prior Voting" "TVC Additional time-varying controls" "N_g Units" "N Observations"  ) sfmt(%12.0fc) ///
            mgroups("Matched (Genetic)" "Matched (Propensity Score)", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) // Uncomment "/* */"-sections with "using" and "booktabs" for latex export.

    *** 2.9 Appendix A1: Interaction Analyses
        *** Table A1: Prior Participation
            *** Models 1 to 3:
            xtreg voted i.treatment_level_at_t2##i.PostPeriod##ib1.voted_in_PREPERIOD  if eligib == 1 & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe 
            eststo mA1_1
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC ""
            
            xtreg voted i.treatment_level_at_t2##i.PostPeriod##ib1.voted_in_PREPERIOD xx_* i.lives_with_par_mod F2D15A_ F2D15B_ F2D15C_ F2D15D_ F2D15E_ F2D15F_ F2D15G_ became_parent_ paidwork if eligib == 1 & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe 
            eststo mA1_2
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC "\checkmark"

            xtreg voted i.treatment_level_at_t2##i.PostPeriod##ib1.voted_in_PREPERIOD xx_* i.lives_with_par_mod F2D15A_ F2D15B_ F2D15C_ F2D15D_ F2D15E_ F2D15F_ F2D15G_ became_parent_ paidwork i.PostPeriod##i.(rr_dyn_ses rr_dyn_cog) i.PostPeriod##i.m_race i.PostPeriod##i.m_sex   if eligib == 1 & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe 
            eststo mA1_3
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC "\checkmark"
            estadd local DYN "\checkmark"

            * Table A1
            esttab  mA1_1 mA1_2 mA1_3 /* using "tableA1.tex"*/, replace f  ///
            keep(*treatment_level_at_t2#1.PostPeriod*) drop(0.* *1.voted*) b(3) se(3) nomtitle ///
            refcat(1.treatment_level_at_t2#1.PostPeriod "No College" 1.treatment_level_at_t2#1.PostPeriod#0.voted_in_PREPERIOD "Attended College $\times$  2004-voter") ///
            coeflabel(1.treatment_level_at_t2#1.PostPeriod  "Attended College" ///
            1.treatment_level_at_t2#1.PostPeriod#0.voted_in_PREPERIOD "Attended College $\times$  2004 non-voter") ///
            /*booktabs collabels(none) noobs alignment(D{.}{.}{-1}) */ ///
            starlevels("\textsuperscript{\cross[.4pt]}" 0.10 * 0.05 ** 0.01 *** 0.001 ) ///	
            scalars("TE Time FEs \& Individual FEs" "VH Prior Voting" "TVC Additional time-varying controls" "DYN Pre-college Covariates $\times$ Time FEs" "N_g Units" "N Observations"  ) sfmt(%12.0fc) ///
            mgroups("Full Sample (interaction)", pattern(1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) // Uncomment "/* */"-sections with "using" and "booktabs" for latex export.

        *** Table A1A Heterogeneity by Self-reported Race
            *** Models
            xtreg voted c.treatment_level_at_t2##c.PostPeriod c.treatment_level_at_t2#c.PostPeriod#c.non_white_asi  if eligib == 1 & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe 
            eststo m_race_1
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC ""

            xtreg voted c.treatment_level_at_t2##c.PostPeriod c.treatment_level_at_t2#c.PostPeriod#c.non_white_asi xx_* i.lives_with_par_mod F2D15A_ F2D15B_ F2D15C_ F2D15D_ F2D15E_ F2D15F_ F2D15G_ became_parent_ paidwork if eligib == 1 & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe 
            eststo m_race_2
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC "\checkmark"

            xtreg voted c.treatment_level_at_t2##c.PostPeriod c.treatment_level_at_t2#c.PostPeriod#c.non_white_asi xx_* i.lives_with_par_mod F2D15A_ F2D15B_ F2D15C_ F2D15D_ F2D15E_ F2D15F_ F2D15G_ became_parent_ paidwork i.PostPeriod##i.(rr_dyn_ses rr_dyn_cog)  c.PostPeriod##c.m_sex   if eligib == 1 & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe 
            eststo m_race_3
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC "\checkmark"
            estadd local DYN "\checkmark"

            *Table A1A
            esttab   m_race_1 m_race_2 m_race_3 /*  using "tableA1A.tex" */, replace f  ///
            keep(*treatment_level_at_t2#c.PostPeriod#*)  b(3) se(3) nomtitle ///
            refcat(c.treatment_level_at_t2#c.PostPeriod "No College" c.treatment_level_at_t2#c.PostPeriod#c.non_white_asi "Attended College $\times$  White/Asian") ///
            coeflabel(c.treatment_level_at_t2#c.PostPeriod  "Attended College" ///
            c.treatment_level_at_t2#c.PostPeriod#c.non_white_asi "Attended College $\times$ Black/Hispanic/Other") ///
            /*booktabs collabels(none) noobs alignment(D{.}{.}{-1}) */ ///
            scalars("TE Time FEs \& Individual FEs" "VH Pre-college Voting $\times$ Time FEs" "TVC Time-varying Controls" "DYN Additional Pre-college Covariates $\times$ Time FEs" "N_g Units" "N Observations"  ) sfmt(%12.0fc) ///
            mgroups("Full Sample (interaction)", pattern(1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) // Uncomment "/* */"-sections with "using" and "booktabs" for latex export.


        *** Table A1B Heterogeneity by Socio-economic Status
            *** Models
            xtreg voted c.treatment_level_at_t2##c.PostPeriod c.treatment_level_at_t2#c.PostPeriod#c.low_ses  if eligib == 1 & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe 
            eststo m_ses_1
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC ""

            xtreg voted c.treatment_level_at_t2##c.PostPeriod c.treatment_level_at_t2#c.PostPeriod#c.low_ses xx_* i.lives_with_par_mod F2D15A_ F2D15B_ F2D15C_ F2D15D_ F2D15E_ F2D15F_ F2D15G_ became_parent_ paidwork if eligib == 1 & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe 
            eststo m_ses_2
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC "\checkmark"

            xtreg voted c.treatment_level_at_t2##c.PostPeriod c.treatment_level_at_t2#c.PostPeriod#c.low_ses xx_* i.lives_with_par_mod F2D15A_ F2D15B_ F2D15C_ F2D15D_ F2D15E_ F2D15F_ F2D15G_ became_parent_ paidwork i.PostPeriod##i.(rr_dyn_cog)  c.PostPeriod##c.m_sex i.PostPeriod##i.m_race    if eligib == 1 & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe
            eststo m_ses_3
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC "\checkmark"
            estadd local DYN "\checkmark"

            *Table A1B
            esttab   m_ses_1 m_ses_2 m_ses_3  /* using "tableA1B.tex" */, replace f  ///
            keep(*treatment_level_at_t2#c.PostPeriod#*)   b(3) se(3) nomtitle ///
            refcat(c.treatment_level_at_t2#c.PostPeriod "No College" c.treatment_level_at_t2#c.PostPeriod#c.low_ses "Attended College $\times$  High Parental SES (Q2 or above)") ///
            coeflabel(c.treatment_level_at_t2#c.PostPeriod  "Attended College" ///
            c.treatment_level_at_t2#c.PostPeriod#c.low_ses "Attended College $\times$ Bottom Quartile Parental SES") ///
            /* booktabs collabels(none) noobs alignment(D{.}{.}{-1}) */ ///
            scalars("TE Time FEs \& Individual FEs" "VH Pre-college Voting $\times$ Time FEs" "TVC Time-varying Controls" "DYN Additional Pre-college Covariates $\times$ Time FEs" "N_g Units" "N Observations"  ) sfmt(%12.0fc) ///
            mgroups("Full Sample (interaction)", pattern(1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) // Uncomment "/* */"-sections with "using" and "booktabs" for latex export.

    *** 2.10 Appendix F2: Attrition and representativeness
        *** Table F2A3: Does the effect vary with propensity to drop out?
            *** Models 1-3: Median split on propensity to drop out
            xtreg voted i.treatment_level_at_t2##i.PostPeriod##ib1.pscore_dropout_halfs i.PostPeriod##i.voted_in_PREPERIOD xx_* i.lives_with_par_mod F2D15A_ F2D15B_ F2D15C_ F2D15D_ F2D15E_ F2D15F_ F2D15G_ became_parent_ paidwork if eligib == 1 & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe 
            eststo F2A3_m1
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC "\checkmark"

            xtreg voted i.treatment_level_at_t2##i.PostPeriod##ib1.pscore_dropout_halfs  i.PostPeriod##i.voted_in_PREPERIOD  if eligib == 1 & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe 
            eststo F2A3_m2
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC ""

            xtreg voted i.treatment_level_at_t2##i.PostPeriod##ib1.pscore_dropout_halfs  i.PostPeriod##i.voted_in_PREPERIOD xx_* i.lives_with_par_mod F2D15A_ F2D15B_ F2D15C_ F2D15D_ F2D15E_ F2D15F_ F2D15G_ became_parent_ paidwork i.PostPeriod##i.(rr_dyn_ses rr_dyn_cog) i.PostPeriod##i.m_race i.PostPeriod##i.m_sex   if eligib == 1 & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe 
            eststo F2A3_m3
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC "\checkmark"
            estadd local DYN "\checkmark"

            *** Models 4-6 continuous propensity score to drop out
            xtreg voted i.treatment_level_at_t2##i.PostPeriod##c.pscore_dropout i.PostPeriod##i.voted_in_PREPERIOD xx_* i.lives_with_par_mod F2D15A_ F2D15B_ F2D15C_ F2D15D_ F2D15E_ F2D15F_ F2D15G_ became_parent_ paidwork if eligib == 1 & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe
            eststo F2A3_m4
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC "\checkmark"

            xtreg voted i.treatment_level_at_t2##i.PostPeriod##c.pscore_dropout i.PostPeriod##i.voted_in_PREPERIOD  if eligib == 1 & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe 
            eststo F2A3_m5
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC ""

            xtreg voted i.treatment_level_at_t2##i.PostPeriod##c.pscore_dropout i.PostPeriod##i.voted_in_PREPERIOD xx_* i.lives_with_par_mod F2D15A_ F2D15B_ F2D15C_ F2D15D_ F2D15E_ F2D15F_ F2D15G_ became_parent_ paidwork i.PostPeriod##i.(rr_dyn_ses rr_dyn_cog) i.PostPeriod##i.m_race i.PostPeriod##i.m_sex   if eligib == 1 & non_hs_grad_2004 != 1 ,  cl(STU_ID) fe 
            eststo F2A3_m6
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC "\checkmark"
            estadd local DYN "\checkmark"

            *Table F2A3
            esttab   F2A3_m2    F2A3_m1    F2A3_m3    F2A3_m5    F2A3_m4    F2A3_m6  /*using "tableF2A3.tex"*/, replace f  ///
            keep(*treatment_level_at_t2#1.PostPeriod* *pscore*)  b(3) se(3) nomtitle ///
            refcat(1.treatment_level_at_t2#1.PostPeriod "No College" ///
            1.treatment_level_at_t2#1.PostPeriod#1.pscore_dropout_halfs "Attended College $\times$  Low propensity to drop out") ///
            coeflabel(1.treatment_level_at_t2#1.PostPeriod  "Attended College" ///
            1.treatment_level_at_t2#1.PostPeriod#2.pscore_dropout_halfs "Attended College $\times$  High propensity to drop out" ///
            1.treatment_level_at_t2#1.PostPeriod#c.pscore_dropout "Attended College $\times$ propensity to drop out (cont.)") ///
            /*booktabs collabels(none) noobs alignment(D{.}{.}{-1}) */  ///	
            scalars("TE Time FEs \& Individual FEs" "VH Prior Voting" "TVC Additional time-varying controls" ///
            "DYN Pre-college Covariates $\times$ Time FEs" "N_g Units" "N Observations"  ) sfmt(%12.0fc) ///
            mgroups("Categorical Propensity Pcore (High/Low)" "Continous Propensity Score", ///
            pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) ///
            span erepeat(\cmidrule(lr){@span})) // Uncomment "/* */"-sections with "using" and "booktabs" for latex export.



****************************************************************************
**** Section 3: Analyses of NELS:88 data (Appendix B)                   ****	
****************************************************************************
    cls
    clear
    use "analysis_data_NELS.dta"
    eststo clear

    *** 3: Appendix B
    *** Table B1: overall effect of college  m1 m1c m1d m1x m1y m1z m2mb m2ma 
        *Full sample models (models 1-3)
            xtreg voted i.treatment_level_at_t2##i.PostPeriod i.PostPeriod##i.voted_in_PRE_PERIOD  if mis_on_voting_and_cg != 1 , cl(STU_ID) fe 
            eststo mb1_1
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC ""

            xtreg voted i.treatment_level_at_t2##i.PostPeriod i.PostPeriod##i.voted_in_PRE_PERIOD i.xx_div_change_q if mis_on_voting_and_cg != 1 , cl(STU_ID) fe 
            eststo mb1_2
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC "\checkmark"

            xtreg voted i.treatment_level_at_t2##i.PostPeriod i.PostPeriod##i.voted_in_PRE_PERIOD i.xx_div_change_q i.PostPeriod##i.(F2SEX	F2SES1Q m_race	rr_dyn_cog) if mis_on_voting_and_cg != 1 , cl(STU_ID) fe 
            eststo mb1_3
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC "\checkmark"
            estadd local DYN "\checkmark"

        *Restricted control group models (models 4-6)
            * These are based on the restricted control group. Therefore we overwrite the original treatment variable with the restricted treatment variable to allow for homogenous tabulation. We then restore this overwritten variable at the end of the restricted models.
            rename treatment_level_at_t2 temp_treatment_level_at_t2
            rename restr_treatment_level_at_t2 treatment_level_at_t2

            xtreg voted i.treatment_level_at_t2##i.PostPeriod i.PostPeriod##i.voted_in_PRE_PERIOD if mis_on_voting_and_cg != 1 , cl(STU_ID) fe 
            eststo mb1_4
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC ""

            xtreg voted i.treatment_level_at_t2##i.PostPeriod i.PostPeriod##i.voted_in_PRE_PERIOD i.xx_div_change_q if mis_on_voting_and_cg != 1 , cl(STU_ID) fe 
            eststo mb1_5
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC "\checkmark"

            xtreg voted i.treatment_level_at_t2##i.PostPeriod i.PostPeriod##i.voted_in_PRE_PERIOD i.xx_div_change_q i.PostPeriod##i.(F2SEX	F2SES1Q m_race	rr_dyn_cog) if mis_on_voting_and_cg != 1 , cl(STU_ID) fe 
            eststo mb1_6
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC "\checkmark"
            estadd local DYN "\checkmark"

        *Restores the original treatment variable, which was overwritten in the restricted sample models to allow for homogenous tabulation.
        drop treatment_level_at_t2 
        rename temp_treatment_level_at_t2 treatment_level_at_t2  

        *Matching models (models 7 and 8)
            gen weights_all = .
            
            replace weights_all = weights_notvc
            xtreg voted i.treatment_level_at_t2##i.PostPeriod  if mis_on_voting_and_cg != 1 & treatment_level_at_t2!=. [pw =weights_all], cl(STU_ID) fe 
            eststo mb1_7
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC ""
            
            replace weights_all = weights_tvc
            xtreg voted i.treatment_level_at_t2##i.PostPeriod i.PostPeriod##i.voted_in_PRE_PERIOD i.xx_div_change_q if mis_on_voting_and_cg != 1 & treatment_level_at_t2!=. [pw =weights_all],  cl(STU_ID) fe 
            eststo mb1_8
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC "\checkmark"

        * Table B1
        esttab mb1_1 mb1_2 mb1_3 mb1_4 mb1_5 mb1_6 mb1_7 mb1_8 /*using "tableB1_NELS.tex"*/, replace f  ///
        keep(*treatment_level_at_t2#1.PostPeriod) drop(0.*) b(3) se(3) nomtitle ///
        refcat(1.treatment_level_at_t2#1.PostPeriod "No College") ///
        coeflabel(1.treatment_level_at_t2#1.PostPeriod  "Attended College") ///
        /*booktabs collabels(none) compress noobs alignment(D{.}{.}{-1}) */ ///	
        scalars("TE Time FEs \& Individual FEs" "VH Pre-college Voting $\times$ Time FEs" "TVC Time-varying Controls" "DYN Additional Pre-college Covariates $\times$ Time FEs" "N_g Units" "N Observations"  ) sfmt(%12.0fc) ///
        mgroups("Full Sample" "Restricted Untr.Grp." "Matched", pattern(1 0 0 1 0 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) // Uncomment "/* */"-sections with "using" and "booktabs" for latex export.
 
    *** Table B2: Interaction analysis previous participation
        * models 1-3
            xtreg voted i.treatment_level_at_t2##i.PostPeriod##ib1.voted_in_PRE_PERIOD if mis_on_voting_and_cg != 1 , cl(STU_ID) fe 
            eststo mB2_1
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC ""

            xtreg voted i.treatment_level_at_t2##i.PostPeriod##ib1.voted_in_PRE_PERIOD i.xx_div_change_q if mis_on_voting_and_cg != 1 , cl(STU_ID) fe 
            eststo mB2_2
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC "\checkmark"

            xtreg voted i.treatment_level_at_t2##i.PostPeriod##ib1.voted_in_PRE_PERIOD i.xx_div_change_q i.PostPeriod##i.(F2SEX	F2SES1Q m_race	rr_dyn_cog) if mis_on_voting_and_cg != 1 , cl(STU_ID) fe 
            eststo mB2_3
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC "\checkmark"
            estadd local DYN "\checkmark"

        * Table B2
        esttab mB2_1 mB2_2 mB2_3 /*using "tableB2_NELS.tex" */, replace f  ///
        keep(*treatment_level_at_t2#1.PostPeriod*) drop(0.* *1.voted*) b(3) se(3) nomtitle ///
        refcat(1.treatment_level_at_t2#1.PostPeriod "No College" 1.treatment_level_at_t2#1.PostPeriod#0.voted_in_PRE_PERIOD "Attended College $\times$  1992-voter") ///
        coeflabel(1.treatment_level_at_t2#1.PostPeriod  "Attended College" ///
        1.treatment_level_at_t2#1.PostPeriod#0.voted_in_PRE_PERIOD "Attended College $\times$  1992 non-voter") ///
        /* booktabs collabels(none) noobs alignment(D{.}{.}{-1}) */ ///
        scalars("TE Time FEs \& Individual FEs" "VH Prior Voting" "VH Prior Voting" "TVC Additional time-varying controls" "DYN Pre-college Covariates $\times$ Time FEs" "N_g Units" "N Observations"  ) sfmt(%12.0fc) ///
        mgroups("Full Sample (interaction)", pattern(1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))

 
    *** Table B2A: Heterogeneity by self-reported race
        * Models 1-3
            xtreg voted c.treatment_level_at_t2##c.PostPeriod  c.treatment_level_at_t2#c.PostPeriod#c.non_white_race if mis_on_voting_and_cg != 1 , cl(STU_ID) fe 
            eststo m_race_1
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC ""

            xtreg voted c.treatment_level_at_t2##c.PostPeriod  c.treatment_level_at_t2#c.PostPeriod#c.non_white_race i.xx_div_change_q if mis_on_voting_and_cg != 1 , cl(STU_ID) fe 
            eststo m_race_2
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC "\checkmark"

            xtreg voted c.treatment_level_at_t2##c.PostPeriod  c.treatment_level_at_t2#c.PostPeriod#c.non_white_race i.xx_div_change_q i.PostPeriod##i.(F2SEX	F2SES1Q rr_dyn_cog) if mis_on_voting_and_cg != 1 , cl(STU_ID) fe  
            eststo m_race_3
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC "\checkmark"
            estadd local DYN "\checkmark"

        * Table B3
        esttab   m_race_1 m_race_2 m_race_3 /*  using "tableB2A_NELS.tex" */ , replace f  ///
        keep(*treatment_level_at_t2#*.PostPeriod#*) drop() b(3) se(3) nomtitle ///
        refcat(c.treatment_level_at_t2#c.PostPeriod "No College" c.treatment_level_at_t2#c.PostPeriod#c.non_white_race "Attended College $\times$  White/Asian") ///
        coeflabel(c.treatment_level_at_t2#c.PostPeriod  "Attended College" ///
        c.treatment_level_at_t2#c.PostPeriod#c.non_white_race "Attended College $\times$  Black/Hispanic/Other") ///	
        /* booktabs collabels(none) noobs alignment(D{.}{.}{-1}) */ ///
        scalars("TE Time FEs \& Individual FEs" "VH Pre-college Voting $\times$ Time FEs" "TVC Time-varying Controls" "DYN Additional Pre-college Covariates $\times$ Time FEs" "N_g Units" "N Observations"  ) sfmt(%12.0fc) ///
        mgroups("Full Sample (interaction)", pattern(1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) // Uncomment "/* */"-sections with "using" and "booktabs" for latex export.

    *** Table B2B: Heterogeneity by socio-economic status
        *** Models 1-3
            xtreg voted c.treatment_level_at_t2##c.PostPeriod  c.treatment_level_at_t2#c.PostPeriod#c.low_ses if mis_on_voting_and_cg != 1 , cl(STU_ID) fe 
            eststo m_ses_1
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC ""

            xtreg voted c.treatment_level_at_t2##c.PostPeriod  c.treatment_level_at_t2#c.PostPeriod#c.low_ses i.xx_div_change_q if mis_on_voting_and_cg != 1 , cl(STU_ID) fe 
            eststo m_ses_2
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC "\checkmark"

            xtreg voted c.treatment_level_at_t2##c.PostPeriod  c.treatment_level_at_t2#c.PostPeriod#c.low_ses i.xx_div_change_q i.PostPeriod##i.(F2SEX m_race rr_dyn_cog) if mis_on_voting_and_cg != 1 , cl(STU_ID) fe 
            eststo m_ses_3
            estadd local FE "\checkmark"
            estadd local TE "\checkmark"
            estadd local VH "\checkmark"
            estadd local TVC "\checkmark"
            estadd local DYN "\checkmark"

        * Table B2B
        esttab   m_ses_1 m_ses_2 m_ses_3  /*using "tableB2B_NELS.tex" */ , replace f  ///
        keep(*treatment_level_at_t2#*.PostPeriod#*)  b(3) se(3) nomtitle ///
        refcat(c.treatment_level_at_t2#c.PostPeriod "No College" c.treatment_level_at_t2#c.PostPeriod#c.low_ses "Attended College $\times$  High Parental SES (Q2-Q4)") ///
        coeflabel(c.treatment_level_at_t2#c.PostPeriod  "Attended College" ///
        c.treatment_level_at_t2#c.PostPeriod#c.low_ses "Attended College $\times$  Bottom Quartile SES") ///	
        /*booktabs collabels(none) noobs alignment(D{.}{.}{-1}) */ ///
        scalars("TE Time FEs \& Individual FEs" "VH Pre-college Voting $\times$ Time FEs" "TVC Time-varying Controls" "DYN Additional Pre-college Covariates $\times$ Time FEs" "N_g Units" "N Observations"  ) sfmt(%12.0fc) ///
        mgroups("Full Sample (interaction)", pattern(1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) // Uncomment "/* */"-sections with "using" and "booktabs" for latex export.

    *** Table B3: Means on voting in 1992 and 1996 by college going status.
        * Sample is model 1 in table B1
            xtreg voted i.treatment_level_at_t2##i.PostPeriod i.PostPeriod##i.voted_in_PRE_PERIOD  if mis_on_voting_and_cg != 1 , cl(STU_ID) fe 
            generate sample = e(sample)

        * Table B3
        preserve 
            // if: (1) only one row per respondent [PostPeriod == 1] (this is long data set), (2) only respondents who replied in both waves [e(sample)].
            drop if PostPeriod == 0
            keep if sample 

            tab treatment_level_at_t2 voted_in_PRE_PERIOD, row //1992
            tab treatment_level_at_t2 voted ,  row // 1996
        restore 
