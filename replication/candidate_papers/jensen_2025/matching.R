#This script calculates weights for the matched analyses of the ELS:2002 data. 
    #In dataprep.do, we simply load a dataset of pre-calculated weights. 
    #This script replicates the process of calculating these weights.

#Set user specific directory
setwd("PATH_TO_REPLICATION_FILES/replication_files/")

Sys.setenv(LANGUAGE="en")
Sys.setlocale("LC_TIME", "English") 

#loading packages
require(MatchIt)
require(WeightIt)
require(haven)
require(foreign)
require(cobalt)

#Load data:
dat.matching<-read_dta("analysis_data_ELS.dta")

#We subset the data to only include the relevant observations
dat.matching <- subset(dat.matching, eligible_voter_2004 == 1)
dat.matching <- subset(dat.matching, mis_on_voting_and_cg == 0)
dat.matching <- subset(dat.matching, non_hs_grad_2004 == 0)


covariates<-c("m_voteW1", "m_sex","m_SESW0" , "m_race")
dat.matching<-dat.matching[unique(dat.matching$STU_ID)&dat.matching$PostPeriod==0,] #return to "wide" format

#Be aware that missings on all variables are kicked below
dat.matching_all<-dat.matching[,c(covariates,"treatment_level_at_t2", "STU_ID","PostPeriod", "eligible_voter_2004", "mis_on_voting_and_cg", "non_hs_grad_2004","m_SESW0", "m_sex", "m_race")]
dat.matching_tvc<-dat.matching[,c(covariates,"treatment_level_at_t2", "STU_ID","PostPeriod", "eligible_voter_2004", "mis_on_voting_and_cg", "non_hs_grad_2004","m_SESW0", "m_sex", "m_race","xx_no_move", "xx_gotmarried", "lives_with_par_mod")]
dat.matching_all<-na.omit(dat.matching_all)
dat.matching_tvc<-na.omit(dat.matching_tvc)

### Propensity score matching
W.out_all_pscore <- weightit(treatment_level_at_t2 ~m_sex+factor(m_SESW0)+factor(m_voteW1)+factor(m_race), data = dat.matching_all, estimand = "ATT", method = "ps")

    # Table I4 (Balance with propensity score matching)
    summary(W.out_all_pscore)
    bal.tab(W.out_all_pscore, m.threshold = .05, disp.v.ratio = TRUE)

    dat.matching_all$weights_all_pscore <- W.out_all_pscore$weights

    ## Exporting weights
    write.dta(dat.matching_all, "pscore_weights.dta")

### Genetic matching with replacement
    W.out_all_notvc <- matchit(treatment_level_at_t2 ~m_sex+factor(m_SESW0)+factor(m_voteW1)+factor(m_race),
                                    method = "genetic",estimand = "ATT", data = dat.matching_all, replace = TRUE) 

    W.out_all_tvc <- matchit(treatment_level_at_t2 ~m_sex+factor(m_SESW0)+factor(m_voteW1)+factor(m_race),
                                    method = "genetic",estimand = "ATT", data = dat.matching_tvc, replace = TRUE) 

    # Table I3 Balance for unmatched and matched data based on genetic matching
    summary(W.out_all_notvc)
    bal.tab(W.out_all_notvc, m.threshold = .05, disp.v.ratio = TRUE)

    #### Exporting Weights
    W.Postmatch_ds_all_notvc <- match.data(W.out_all_notvc)
    df_gennotvc = data.frame(W.Postmatch_ds_all_notvc)
    names(df_gennotvc)[names(df_gennotvc) == "weights"] <- "weights_notvc"
    write.dta(df_gennotvc, "genetic_weights_notvc.dta")


    W.Postmatch_ds_all_tvc <- match.data(W.out_all_tvc)
    df_gentvc = data.frame(W.Postmatch_ds_all_tvc)
    names(df_gentvc)[names(df_gentvc) == "weights"] <- "weights_tvc"
    write.dta(df_gentvc, "genetic_weights_tvc.dta")





