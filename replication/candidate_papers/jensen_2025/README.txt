### README ###
The replication files in this folder include the code and data needed to replicate the results in the article "Educating For Democracy? Going to College Increases Political Participation" and its appendices.

Script files:

    - dataprep.do // loads and recodes raw data, then saves the analysis data sets to be used in analysis.do. The datasets produced are "analysis_data_ELS.dta" and "analysis_data_NELS.dta". Since these datasets are already in the replication files, the dataprep step can be skipped, and one can move directly to analysis.do.
    - analysis.do // This script reproduces all results in the manuscript and appendices for the article.
    - matching.R // Calculates weights for the matching analyses in the paper. For convenience, these weights are also already loaded into the analysis datasets.

Datasets:
    - analysis_data_ELS.dta //dataset for ELS:2002 analysis. (Section 2 of analysis.do)
    - analysis_data_NELS.dta //dataset for NELS:88 analysis. (Section 3 of analysis.do)
    - forest_data.dta // prior studies for forest plots and meta-analyses (Section 1 of analysis.do)
    - els_02_12_byf3pststu_v1_0.dta //Raw ELS data before recoding (Section 1 of dataprep.do)
    - NELS_88_00_BYF4STU_V1_0.dta //Raw NELS data before recoding (Section 2 of dataprep.do)
    - matching_weights.dta // dataset containing pre-calculated weights ELS:2002 data.
    - NELS_matching_weights.dta // dataset containing pre-calculated weights  NELS:88 data.

In total this replication package contains 10 files (excluding this ReadMe-file).