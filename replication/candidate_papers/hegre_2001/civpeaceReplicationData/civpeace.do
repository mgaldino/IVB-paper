log close
log using civpeace.log, replace

/*
Stata do file replicating tables in

Haavard Hegre, Tanja Ellingsen, Scott Gates, and Nils Petter Gleditsch
'Toward a Democratic Civil Peace? Democracy, Political Change, and Civil War 1816-1992'
American Political Science Review, vol. 95, no. 1 (2000)
*/

version 5
clear
use civpeace.dta
stset stop status, t0(start) id(ss_numbe)

/* Table 2: Risk of Civil War by Level of Democracy and Proximity of Regime Change */
stcox prc demo demosq pcw pi interwar neighbwa ln_energ energsq ethnic_h if year >= 1946, nohr robust
stcox prc demo demosq pcw pi interwar neighbwa, nohr robust

/* Table 3: Risk of Civil War by Level of Democracy and Subdivided Proximity of Regime Change Variable */
stcox psd pld psa pla porc demo demosq pcw pi interwar neighbwa ln_energ energsq ethnic_h if year >= 1946, nohr robust
stcox psd pld psa pla porc demo demosq pcw pi interwar neighbwa, nohr robust


