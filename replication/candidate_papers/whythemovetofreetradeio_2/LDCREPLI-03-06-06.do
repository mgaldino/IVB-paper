sum newtar dopen_wacz2 date polityiv_update2 aclpn dictator1 milit2 pers2 sp2 yrsoffic  lnpop  gdp_pc_95d bpc1 ecris2 signed gatt_wto_new fdignp avsw  usheg avnewtar l1fiveop

*TABLE2 TARIFF RATES 

xi: xtpcse   newtar  l1polity   l1lnpop  l1gdp_pc  date  i.country, corr(ar1) pairwise
estimates store m21

xi: xtpcse   newtar  l1polity   l1lnpop  l1gdp_pc  l1ecris2  date  i.country, corr(ar1) pairwise
estimates store m22

xi: xtpcse   newtar  l1polity   l1lnpop  l1gdp_pc  l1bpc1  date  i.country, corr(ar1) pairwise
estimates store m23

xi: xtpcse   newtar  l1polity   l1lnpop  l1gdp_pc  l1signed  date  i.country, corr(ar1) pairwise
estimates store m24

xi: xtpcse   newtar  l1polity   l1lnpop  l1gdp_pc  l1usheg date  i.country, corr(ar1) pairwise
estimates store m25

xi: xtpcse   newtar  l1polity   l1lnpop  l1gdp_pc  l1fiveop date  i.country, corr(ar1) pairwise
estimates store m26
estout m2* using t2.txt, cells(b(star) se(par)) stats(N N_g r2 chi2 p, labels("Observations" "Countries" "R-squared" "Wald chi2" "Prob>chi2")) title("Table 2. Dependent Variable: Statutory Tariff Rates") varlabels(_cons Constant l1polity "POLITY" l1ecris2 "EC CRISIS" l1bpc1 "BP CRISIS" l1signed "IMF" l1office "OFFICE" l1avnewtar "AV TARIFF" l1gatt_wto_new "GATT" l1fdi "FDI" l1lnpop "LN POP" l1gdp_pc "GDP PC" l1usheg "US HEG" l1fiveop "FIVE OPEN") legend style(tab)




*TABLE3 TARIFF RATES 

xi: xtpcse   newtar  l1polity   l1lnpop  l1gdp_pc   l1ecris2   l1bpc1 l1signed l1avnewtar  l1office date  i.country, corr(ar1) pairwise
estimates store m31

xi: xtpcse   newtar  l1polity   l1lnpop  l1gdp_pc   l1ecris2   l1bpc1 l1signed  l1office l1gatt_wto_new l1fiveop l1usheg date  i.country, corr(ar1) pairwise
estimates store m32

xi: xtpcse   newtar  l1polity   l1lnpop  l1gdp_pc   l1ecris2   l1bpc1 l1signed  l1office l1avnewtar l1gatt_wto_new l1fdi date  i.country, corr(ar1) pairwise
estimates store m33

xi: xtpcse   newtar  l1aclpn  l1lnpop  l1gdp_pc   l1ecris2   l1bpc1 l1signed  l1office l1avnewtar l1gatt_wto_new l1fdi date  i.country, corr(ar1) pairwise
estimates store m34

xi: xtpcse   newtar  l1dictator1  l1lnpop  l1gdp_pc   l1ecris2   l1bpc1 l1signed  l1office l1avnewtar l1gatt_wto_new l1fdi date  i.country, corr(ar1) pairwise
estimates store m35

xi: xtpcse newtar  l1polity  l1sp2 l1milit2 l1lnpop  l1gdp_pc   l1ecris2   l1bpc1 l1signed  l1office l1avnewtar l1gatt_wto_new l1fdi date  i.country, corr(ar1) pairwise
estimates store m36

estout m3* using t3.txt, cells(b(star) se(par)) stats(N N_g r2 chi2 p, labels("Observations" "Countries" "R-squared" "Wald chi2" "Prob>chi2")) title("Table 3. Dependent Variable: Statutory Tariff Rates") varlabels(_cons Constant l1polity "REGIME" l1ecris2 "EC CRISIS" l1bpc1 "BP CRISIS" l1signed "IMF" l1office "OFFICE" l1avnewtar "AV TARIFF" l1gatt_wto_new "GATT" l1fdi "FDI" l1lnpop "LN POP" l1gdp_pc "GDP PC" l1usheg "US HEG" l1fiveop "FIVE OPEN" l1aclpn "DEM" l1dictator1 "DICTATOR" l1sp2 "SGL PARTY" l1milit2 "MILITARY") legend style(tab) replace


*TABLE4 TARIFF RATES 
*lags of polity:

xi: xtpcse   newtar  l1polity  l1lnpop  l1gdp_pc   l1ecris2   l1bpc1 l1signed  l1office l1avnewtar l1gatt_wto_new l1fdi date  i.country, corr(ar1) pairwise
estimates store m41

xi: xtpcse   newtar  l2polity  l1lnpop  l1gdp_pc   l1ecris2   l1bpc1 l1signed  l1office l1avnewtar l1gatt_wto_new l1fdi date  i.country, corr(ar1) pairwise
estimates store m42

xi: xtpcse   newtar  l3polity  l1lnpop  l1gdp_pc   l1ecris2   l1bpc1 l1signed  l1office l1avnewtar l1gatt_wto_new l1fdi date  i.country, corr(ar1) pairwise
estimates store m43

xi: xtpcse   newtar  l1polity  l2polity  l3polity l1lnpop  l1gdp_pc   l1ecris2   l1bpc1 l1signed  l1office l1avnewtar l1gatt_wto_new l1fdi date  i.country, corr(ar1) pairwise
estimates store m44

estout m4* using t4.txt, cells(b(star) se(par)) stats(N N_g r2 chi2 p, labels("Observations" "Countries" "R-squared" "Wald chi2" "Prob>chi2")) title("Table 4. Dependent Variable: Statutory Tariff Rates") varlabels(_cons Constant l1polity "Regime L1" l2polity "Regime L2" l3polity "Regime L3" l1ecris2 "EC Crisis" l1bpc1 "BP Crisis" l1signed "IMF" l1office "OFFICE" l1avnewtar "AV TARIFF" l1gatt_wto_new "GATT" l1fdi "FDI" l1lnpop "LN POP" l1gdp_pc "GDP PC" ) legend style(tab) replace

*lincom l1polity + l2polity
*xi: xtpcse   newtar  l1polity  l2polity l3polity l1lnpop  l1gdp_pc   l1ecris2   l1bpc1 l1signed  l1office l1avnewtar l1gatt_wto_new l1fdi date  i.country, corr(ar1) pairwise
*lincom l1polity +l2polity + l3polity

*TABLE5 

xi: xtlogit dopen_wacz2 l1polity l1lnpop l1gdp_pc l1ecris2 l1bpc1  yr70 yr80 closedyr _spline1 _spline2 _spline3, fe 
estimates store m51

xi: xtlogit dopen_wacz2 l1polity l1lnpop l1gdp_pc l1ecris2 l1bpc1 l1signed l1office l1gatt_wto_new yr70 yr80 closedyr _spline1 _spline2 _spline3, fe 
estimates store m52

xi: xtlogit dopen_wacz2 l1polity l1lnpop l1gdp_pc l1ecris2 l1bpc1 l1signed l1office l1gatt_wto_new l1usheg l1fiveop yr70 yr80 closedyr _spline1 _spline2 _spline3, fe 
estimates store m53

xi: xtlogit dopen_wacz2 l1polity l1lnpop l1gdp_pc l1ecris2 l1bpc1 l1signed l1office l1gatt_wto_new l1usheg  l1avsw  l1fdi yr70 yr80 closedyr _spline1 _spline2 _spline3, fe 
estimates store m54

estout m5* using t5.txt, cells(b(star) se(par)) stats(N chi2 p ll, labels("Observations" "LR chi2" "Prob>chi2" "Log likelihood")) title("Table 5. Dependent Variable: Sachs-Warner Openness") varlabels(_cons Constant l1polity "POLITY" l1ecris2 "EC CRISIS" l1bpc1 "BP CRISIS" l1signed "IMF" l1office "OFFICE" l1avnewtar "AV TARIFF" l1gatt_wto_new "GATT" l1fdi "FDI" l1lnpop "LN POP" l1gdp_pc "GDP PC" l1usheg "US HEG" l1fiveop "FIVE OPEN" l1avsw "AV OPEN") legend style(tab) 


*TABLE6

xi: xtlogit   dopen_wacz2 l1polity l1lnpop l1gdp_pc  l1ecris2 l1bpc1 l1signed   l1office l1gatt_wto_new l1avsw  yr70 yr80 closedyr _spline1 _spline2 _spline3, fe 
estimates store m61

xi: xtlogit  dopen_wacz2 l1aclpn l1bpc1  l1ecris2  l1signed  l1office  l1gatt_wto_new  l1gdp_pc  l1lnpop   l1avsw  yr70 yr80 closedyr _spline1 _spline2 _spline3, fe 
estimates store m62

xi: xtlogit dopen_wacz2 l1dictator l1signed   l1office l1bpc1  l1ecris2 l1gdp_pc   l1lnpop  l1gatt_wto_new l1avsw yr70 yr80 closedyr _spline1 _spline2 _spline3, fe 
estimates store m63

xi: xtlogit dopen_wacz2 l1polity l1milit2 l1sp2 l1signed   l1office l1bpc1  l1ecris2 l1gdp_pc   l1lnpop  l1gatt_wto_new l1avsw yr70 yr80 closedyr _spline1 _spline2 _spline3, fe 
estimates store m64

estout m6* using t6.txt, cells(b(star) se(par)) stats(N chi2 p ll, labels("Observations" "LR chi2" "Prob>chi2" "Log likelihood")) title("Table 6. Dependent Variable: Sachs-Warner Openness") varlabels(_cons Constant l1polity "REGIME" l1ecris2 "EC CRISIS" l1bpc1 "BP CRISIS" l1signed "IMF" l1office "OFFICE" l1avnewtar "AV TARIFF" l1gatt_wto_new "GATT" l1fdi "FDI" l1lnpop "LN POP" l1gdp_pc "GDP PC" l1usheg "US HEG" l1fiveop "FIVE OPEN" l1avsw "AV OPEN" l1aclpn "DEM" l1dictator1 "DICTATOR" l1sp2 "SGL PARTY" l1milit2 "MILITARY") legend style(tab) 


*TABLE7
xtivreg newtar l1bpc1 l1ecris2 l1gdp_pc  l1office l1signed l1lnpop  l1gatt_wto_new l1avnewtar date (l1polity= l1partyage2000 l1ssch) , fe first
estimates store m7
estout m7 using t7.txt, cells(b(star) se(par)) stats(N r2 chi2 p, labels("Observations" "R-squared" "Wald chi2" "Prob>chi2")) title("Table 7. Instrumental variable regression. Dependent Variable: Tariff rates") varlabels(_cons Constant l1polity "REGIME" l1ecris2 "EC CRISIS" l1bpc1 "BP CRISIS" l1signed "IMF" l1office "OFFICE" l1avnewtar "AV TARIFF" l1gatt_wto_new "GATT" l1lnpop "LN POP" l1gdp_pc "GDP PC") legend style(tab) 
