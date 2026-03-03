This folder contains replication files for:

Rogowski, Jon C., John Gerring, Matthew Maguire, and Lee Cojocaru. "Public Infrastructure and Economic Development: Evidence from Postal Systems." American Journal of Political Science.

Dataverse DOI: 10.7910/DVN/33K3EF
		

The Dataverse folder contains the following:

(1) Data for analysis:

	(a) country_cs.dta: contains the data necessary to conduct the cross-sectional (long-term) cross-national regressions
	(b) country_panel.dta: contains the data necessary to conduct the panel (short-term) cross-national regressions
	(c) cs_us.dta: contains the data necessary to conduct the cross-sectional (long-term) analysis of U.S. counties
	(d) newspapers_panel.dta: contains data necessary to conduct the panel analysis of newspapers and newspaper circulation in U.S. counties.
	(e) state_mo.dta: contains the data necessary to conduct the panel analysis of money order transactions in U.S. states
	(f) us_panel.dta: contains the data necessary to conduct the panel (short-term) analysis of U.S. counties

(2) Code:

	(a) figures-replication-code.R: contains the code necessary to create all figures in R.
	(b) main analyses.do: contains the code necessary to reproduce (in Stata) all regression tables reported in the main text.
	(c) supplementary analyses.do: contains the code necessary to reproduce (in Stata) all regression tables reported in the supplementary appendix, with the exception of Table A.12.
	(d) trends.R: contains the code necessary to reproduce (in R) the regression results reported in Table A.12.
	(e) create_analysis_datasets.do: contains the code necessary to create the datasets used in "Data for analysis."

(3) Codebook:

	(a) Codebook.pdf: describes the variables used in the analysis and contained in the datasets listed under "Data for analysis." 


(4) Additional Data:

	(a) county_elections_1840.dta: merge in county vote shares for candidate from president's party to conduct instrumental variables analyses. Used in main analyses.do.
	(b) data coverage.csv: contains information on the number of years each country appears in the UPU data. Used in figures-replication-code.R.
	(c) data-facet1.dta: contains raw data on number of post offices by country (A-L) collected from UPU records. Used in figures-replication-code.R.
	(d) data-facet2.dta: contains raw data on number of post offices by country (L-Z) collected from UPU records. Used in figures-replication-code.R.
	(e) money_orders.dta: contains raw data on money orders by state. Used in figures-replication-code.R.
	(f) per_capita_2000.csv: contains information on the per capita distribution of post offices by country for the year 2000. Used in figures-replication-code.R.
	(g) UPU2000.dta: contains information on the number of post offices in each country-year included in the data. Used in figures-replication-code.R.
	(h) county partisanship 1896.dta: contains information on county-level vote shares for the president's copartisans in the 1894 congressional election. Used to create the analysis dataset.
	(i) county_1840_1900.dta: county Census characteristics for decennial years 1840-1900. Used to create the analysis dataset.
	(j) county_1896_2000.dta: county Census characteristics for decennial years 1960-2000. Used to create the analysis dataset.
	(k) money_orders_panel.dta: contains data we collected on money orders by state and year. Used to create the analysis dataset.
	(l) patents cross-sectional.dta: contains data on patents assigned in 19th century. Used to create the analysis dataset on long-term associations between post offices and economic outcomes.
	(m) patents panel.dta: contains data on panels assiged by decade in 19th century. Used to create the analysis dataset on short-term associations between post offices and economic outcomes.
	(n) postal_1875_2000.dta: contains original data on post offices by country between 1875 and 2000. Used to create the analysis dataset on short term associations between post offices and economic outcomes.
	(o) postal_imputation.dta: contains data on post offices by country in the year 1900. Used to create the analysis dataset on long term associations between post offices and economic outcomes.
	(p) rfd1900.dta: contains data on the presence of rural free delivery in U.S. counties. Used to create the analysis dataset for long term associations between post offices and economic outcomes.
	(q) rr1850-1900_long.dta: contains data on the presence of rail lines in U.S. counties between 1850 and 1900. In long format. Used to create the analysis dataset for short term associations between post offices and economic outcomes.
	(r) voting_cnty_clean.dta: contains data on the number of newspapers in counties. Used to create datas for analyses in both the short and long terms.


Computing:

Analyses were conducted with Windows 10. Processor: Intel(R) Core(TM) i5-8250U CPU @ 1.60GHz 1.80GHz. Installed memory (RAM): 8.0 GB. System: 64-bit Operating System, x64-based processor.

Stata commands were executed on Stata/MP 16.1 for Windows (64-bit x86-64), Revision 13 August 2020. Note: the user-created modules ivreg2 and xtivreg are necessary to conduct some of the analyses.

R commands were executed on R version 3.6.0 (2019-04-26),  "Planting of a Tree", on Platform i386-w64-mingw32/i386 (32-bit). Note:  the following packages are required to be installed and loaded to conduct the analyses: ggplot2, foreign, rworldmap, RColorBrewer, classInt, stargazer, devtools, lme, readstata13, and rgdal. 		



Contact: 	Jon Rogowski
			Harvard University
			rogowski@fas.harvard.edu		