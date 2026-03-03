***
Readme

Date: 20-April-2023

Title: "Does Democracy Reduce Ethnic Inequality?"

Contact: Lasse Egendal Leipziger - lel@ps.au.dk

This file contains an overview of the replication material for the article and the online appendix. 


The empirical analysis primarily relies on the dataset "Country-level dataset.dta". This dataset has been merged based on a number of datasets listed below.
These datasets are all provided in the folder "Merging of country-level dataset", which includes a Stata do-file "Do-file for merging datasets" that 
replicates the merging of "Country-level dataset.dta". This step is also documented with the log file "log_merge".

- 	"Lexical Index v6.2.dta" (Lexical Index of Electoral Democracy by Skaaning et al. – main democracy measure used)
-	"V-Dem-CY-Full+Others-v11.1.dta" (V-Dem full dataset version 11.1 - ethnic inequality measure, alternative democracy measures, various controls, and variables for mechanism test)
-	"Fariss et al - Estimates_all_long_210911.dta" (GDP pc. data for longer time series)
-	"Omoeva et al. EICC_dataset.dta" (ethnic inequality measure)
-	"Alesina et al. 2016. EI_final_JPE.dta” (ethnic inequality measure)
-	"EPR_country.dta" (Ethnic Power Relations 2019 data for supplementary analysis)
-	"HIEF.dta" (Historical Ethnic Fractionalization Index by Drazanova 2020).
-	"Trade PWT 9.1.dta" (Trade openness data by Penn World Tables v. 9.1)
-	"SWIID 9.1.dta" (Non-ethnic income inequality data for supplementary analysis)
-	"spmap_30_09_2021.dta" (map file needed to operate spmap command)


Two additional sets of analyses also rely on the separate datasets "Group-level dataset - Bormann et al. 2021.dta" and "Group-level dataset - AMAR.dta". 
Following the completion of the country-level analysis, the "Do-file for analysis" opens the group-level datasets and merges them with a number of variables from the country-level dataset.


The Stata do-file "Do-file for analysis" recodes the data and produces all the results presented in the article and the appendix. 

The file "Codebook.pdf" has more information on each dataset and all the variables included in the analysis.

The file "log_dem_ethnic_ineq.pdf" is a log file showing the running of the replication files.

The file "worldcoor.dta"must be in the same folder as the do-file for a sucessful creation of Figure 2.

All analyses were done using: StataSE 16.0

Platform: Windows 10 Education 64-bit

Estimated runtime is 1.5 hours (the "csdid" package is time-consuming)


References:

Country-level:
Skaaning, Svend-Erik, John Gerring & Henrikas Bartusevičius (2015). "A Lexical Index of Electoral Democracy." Comparative Political Studies, Vol. 48, No. 12, pp. 1491-1525. https://doi.org/10.1177/0010414015581050

Skaaning, Svend-Erik, 2021, "Lexical Index of Electoral Democracy (LIED) dataset", https://doi.org/10.7910/DVN/WPKNIT, Harvard Dataverse, V2

Coppedge, Michael, John Gerring, Carl Henrik Knutsen, Staffan Lindberg, and Jan Teorell. 2021. "V-Dem Codebook V11.1. Varieties of Democracy (V-Dem) Project. (Data and codebook retrieved from https://www.v-dem.net/data/the-v-dem-dataset/)

Fariss, Christopher J., Therese Anders, Jonathan N. Markowitz, and Miriam Barnum (2022). New Estimates of Over 500 Years of Historic GDP and Population Data. Journal of Conflict Resolution, 66(3), 553–591. https://doi.org/10.1177/00220027211054432

Fariss, Christopher J., Therese Anders, Jonathan N. Markowitz, Miriam Barnum (2021). "Replication Data for: New Estimates of Over 500 Years of Historic GDP and Population Data", https://doi.org/10.7910/DVN/DC0ING, Harvard Dataverse, V4

Omoeva, Carina, Wael Moussa, and Rachel Hatch. 2018. "The Effects of Armed Conflict on Educational Attainment and Inequality." EPDC Research Paper No. 18-03. (Data was retrieved by contacting authors directly: Wael Moussa <WMoussa@fhi360.org> or Rachel Hatch <rhatch@fhi360.org>)

Alesina, Alberto, Stelios Michalopoulos, and Elias Papaioannou. 2016. "Ethnic Inequality." Journal of Political Economy 124 (2): 428-88. https://doi.org/10.1086/685300 (Data retrieved from "Supplemental Material" - https://www.journals.uchicago.edu/doi/suppl/10.1086/685300)

Vogt, Manuel, et al. 2015. "Integrating Data on Ethnicity, Geography, and Conflict: The Ethnic Power Relations Data Set Family." Journal of Conflict Resolution 59 (7): 1327-42. https://doi.org/10.1177/0022002715591215 (Data retrieved from https://growup.ethz.ch/rfe)

Drazanova, Lenka. 2020. "Introducing the Historical Index of Ethnic Fractionalization (Hief) Dataset: Accounting for Longitudinal Changes in Ethnic Diversity." Journal of Open Humanities Data 6 (1). https://doi.org/10.5334/johd.16

Drazanova, Lenka. 2019. "Historical Index of Ethnic Fractionalization Dataset (HIEF)", https://doi.org/10.7910/DVN/4JQRCL, Harvard Dataverse, V2, UNF:6:z4J/b/PKbUpNdIoeEFPvaw== [fileUNF]

Feenstra, Robert C., Robert Inklaar, and Marcel P. Timmer. 2015. "The Next Generation of the Penn World Table." The American Economic Review 105 (10): 3150-82. (Data retrieved from https://www.rug.nl/ggdc/productivity/pwt/pwt-releases/pwt9.1)

Solt, Frederick. 2020. "Measuring Income Inequality across Countries And over Time: The Standardized World Income Inequality Database." Social Science Quarterly 101 (3): 1183-99. SWIID Version 9.1, May 2021. https://doi.org/10.1111/ssqu.12795

Solt, Frederick, 2019, "The Standardized World Income Inequality Database, Versions 8-9", https://doi.org/10.7910/DVN/LM4OWF, Harvard Dataverse, V9

Group-level:
Birnir, Jóhanna K., et al. 2017. "Introducing the Amar (All Minorities at Risk) Data." Journal of Conflict Resolution 62 (1): 203-26. https://doi.org/10.1177/0022002717719974 (Data and codebook retrieved from "Supplementary Material")

Bormann, Nils-Christian, Yannick I. Pengl, Lars-Erik Cederman, and Nils B. Weidmann. 2021. "Globalization, Institutions, and Ethnic Inequality." International Organization 75 (3): 665-97. https://doi.org/10.1017/S0020818321000096

Bormann, Nils-Christian, Pengl, Yannick I., Cederman, Lars-Erik, Weidmann, Nils B., 2020, "Replication Data for: Globalization, Institutions and Ethnic Inequality", https://doi.org/10.7910/DVN/QLG842, Harvard Dataverse, V1