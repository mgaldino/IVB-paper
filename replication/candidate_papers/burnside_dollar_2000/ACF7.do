gen bdaid2=bdaid^2
gen elraid2=elraid^2
gen bdlpop2=bdlpop^2
gen elrlpop2=elrlpop^2
gen bdlgdp = ln(bdgdp)
gen elrlgdp = ln(elrgdp)
gen bdlgdp2=bdlgdp^2
gen elrlgdp2=elrlgdp^2
gen bdethnfassas = bdethnf * bdassas
gen elrethnfassas = elrethnf * elrassas
xi i.period /* generate period dummies */

global header "B&D original."
gen bdpolicy = bddatap
gen bdoutlier = bddatao
gen bdaidpolicy = bdaid * bdpolicy
gen bdaid2policy = bdaid^2 * bdpolicy
gen bdarms1policy = bdarms1 * bdpolicy
gen bdlpoppolicy = bdlpop * bdpolicy
gen bdlgdppolicy = bdlgdp * bdpolicy
gen bdlpop2policy = bdlpop2 * bdpolicy
gen bdlgdp2policy = bdlgdp2 * bdpolicy

display _newline "$header Regression 1 (policy index-forming regression)"
regress bdgdpg bdlgdp bdethnf bdassas bdethnfassas bdssa bdeasia bdicrge bdm21 bdbb bdinfl bdsacw _Iperiod* if country!="BHS" & country!="SGP", robust
gen sample = e(sample)
display _newline "Regress policy index provided in data set on policy variables to show the coefficients match those above."
regress bdpolicy bdbb bdinfl bdsacw

display _newline "$header 4/OLS (low- and middle-income, with aid^2*policy)"
regress bdgdpg bdaid bdaidpolicy bdaid2policy bdlgdp bdethnf bdassas bdethnfassas bdssa bdeasia bdicrge bdm21 bdpolicy _Iperiod* if sample, robust
display _newline "$header 5/OLS (low- and middle-income, outliers excluded, no aid^2*policy)"
regress bdgdpg bdaid bdaidpolicy bdlgdp bdethnf bdassas bdethnfassas bdssa bdeasia bdicrge bdm21 bdpolicy _Iperiod* if sample & !bdoutlier, robust
avplot bdaidpolicy
display _newline "$header 5/OLS+ (low- and middle-income, with outliers but no aid^2*policy)"
regress bdgdpg bdaid bdaidpolicy bdlgdp bdethnf bdassas bdethnfassas bdssa bdeasia bdicrge bdm21 bdpolicy _Iperiod* if sample, robust
display _newline "$header 5/2SLS (low- and middle-income, outliers excluded, no aid^2*policy)"
ivreg bdgdpg bdlgdp bdethnf bdassas bdethnfassas bdssa bdeasia bdicrge bdm21 bdpolicy _Iperiod* (bdaid bdaidpolicy = bdfrz bdcentam bdegypt bdarms1 bdarms1policy bdlpop bdlpoppolicy bdlpop2policy bdlgdppolicy bdlgdp2policy) if sample & !bdoutlier, robust
display _newline "$header 5/2SLS+ (low- and middle-income, with outliers but no aid^2*policy)"
ivreg bdgdpg bdlgdp bdethnf bdassas bdethnfassas bdssa bdeasia bdicrge bdm21 bdpolicy _Iperiod* (bdaid bdaidpolicy = bdfrz bdcentam bdegypt bdarms1 bdarms1policy bdlpop bdlpoppolicy bdlpop2policy bdlgdppolicy bdlgdp2policy) if sample, robust
display _newline "$header 7/OLS (low-income, with aid^2*policy)"
regress bdgdpg bdaid bdaidpolicy bdaid2policy bdlgdp bdethnf bdassas bdethnfassas bdssa bdeasia bdicrge bdm21 bdpolicy _Iperiod* if sample & !bddn1900, robust
display _newline "$header 8/OLS (low-income, outliers excluded, no aid^2*policy)"
regress bdgdpg bdaid bdaidpolicy bdlgdp bdethnf bdassas bdethnfassas bdssa bdeasia bdicrge bdm21 bdpolicy _Iperiod* if sample & !bdoutlier & !bddn1900, robust
display _newline "$header 8/OLS+ (low-income, with outliers but no aid^2*policy)"
regress bdgdpg bdaid bdaidpolicy bdlgdp bdethnf bdassas bdethnfassas bdssa bdeasia bdicrge bdm21 bdpolicy _Iperiod* if sample & !bddn1900, robust
display _newline "$header 8/2SLS (low-income, outliers excluded, no aid^2*policy)"
ivreg bdgdpg bdlgdp bdethnf bdassas bdethnfassas bdssa bdeasia bdicrge bdm21 bdpolicy _Iperiod* (bdaid bdaidpolicy = bdfrz bdcentam bdegypt bdarms1 bdarms1policy bdlpop bdlpoppolicy bdlpop2policy bdlgdppolicy bdlgdp2policy) if sample & !bdoutlier & !bddn1900, robust
display _newline "$header 8/2SLS+ (low-income, with outliers but no aid^2*policy)"
ivreg bdgdpg bdlgdp bdethnf bdassas bdethnfassas bdssa bdeasia bdicrge bdm21 bdpolicy _Iperiod* (bdaid bdaidpolicy = bdfrz bdcentam bdegypt bdarms1 bdarms1policy bdlpop bdlpoppolicy bdlpop2policy bdlgdppolicy bdlgdp2policy) if sample & !bddn1900, robust

drop sample

/* Now do new-data regressions */
foreach runcode in elrdatabdcos7093bdvars elrdata7093bdvars elrdatabdcos7097bdvars elrdata7097bdvars {
	if "`runcode'"=="elrdatabdcos7093bdvars" {
		global header "New data, BD countries, 1970-93, BD policy variables."
		gen sample = originalcountries & periodstart >= 1970 & periodend <= 1993
	}
	if "`runcode'"=="elrdata7093bdvars" {
		global header "New data, full sample, 1970-93, BD policy variables."
		gen sample = periodstart >= 1970 & periodend <= 1993 & country!="BHS" & country!="SGP"
	}
	if "`runcode'"=="elrdatabdcos7097bdvars" {
		global header "New data, BD countries, 1970-97, BD policy variables."
		gen sample = originalcountries & periodstart >= 1970 & periodend <= 1997
	}
	if "`runcode'"=="elrdata7097bdvars" {
		global header "New data, full sample, 1970-97, BD policy variables."
		gen sample = periodstart >= 1970 & periodend <= 1997 & country!="BHS" & country!="SGP"
	}

	gen elrpolicy = `runcode'p
	gen elroutlier = `runcode'o
	gen elraidpolicy = elraid * elrpolicy
	gen elraid2policy = elraid^2 * elrpolicy
	gen elrarms1policy = elrarms1 * elrpolicy
	gen elrlpoppolicy = elrlpop * elrpolicy
	gen elrlgdppolicy = elrlgdp * elrpolicy
	gen elrlpop2policy = elrlpop2 * elrpolicy
	gen elrlgdp2policy = elrlgdp2 * elrpolicy
	
	display _newline "$header Regression 1 (policy index-forming regression)"
	regress elrgdpg elrlgdp elrethnf elrassas elrethnfassas elrssa elreasia elricrge elrm21 elrbb elrinfl elrsacw _Iperiod* if sample, robust
	display _newline "Regress policy index provided in data set on policy variables to show the coefficients match those above."
	regress elrpolicy elrbb elrinfl elrsacw

	display _newline "$header 4/OLS (low- and middle-income, with aid^2*policy)"
	regress elrgdpg elraid elraidpolicy elraid2policy elrlgdp elrethnf elrassas elrethnfassas elrssa elreasia elricrge elrm21 elrpolicy _Iperiod* if sample, robust
	display _newline "$header 5/OLS (low- and middle-income, outliers excluded, no aid^2*policy)"
	regress elrgdpg elraid elraidpolicy elrlgdp elrethnf elrassas elrethnfassas elrssa elreasia elricrge elrm21 elrpolicy _Iperiod* if sample & !elroutlier, robust
	if "`runcode'"=="elrdata7097bdvars" {
		avplot elraidpolicy
	}
	display _newline "$header 5/OLS+ (low- and middle-income, with outliers but no aid^2*policy)"
	regress elrgdpg elraid elraidpolicy elrlgdp elrethnf elrassas elrethnfassas elrssa elreasia elricrge elrm21 elrpolicy _Iperiod* if sample, robust
	display _newline "$header 5/2SLS (low- and middle-income, outliers excluded, no aid^2*policy)"
	ivreg elrgdpg elrlgdp elrethnf elrassas elrethnfassas elrssa elreasia elricrge elrm21 elrpolicy _Iperiod* (elraid elraidpolicy = elrfrz elrcentam elregypt elrarms1 elrarms1policy elrlpop elrlpoppolicy elrlpop2policy elrlgdppolicy elrlgdp2policy) if sample & !elroutlier, robust
	display _newline "$header 5/2SLS+ (low- and middle-income, with outliers but no aid^2*policy)"
	ivreg elrgdpg elrlgdp elrethnf elrassas elrethnfassas elrssa elreasia elricrge elrm21 elrpolicy _Iperiod* (elraid elraidpolicy = elrfrz elrcentam elregypt elrarms1 elrarms1policy elrlpop elrlpoppolicy elrlpop2policy elrlgdppolicy elrlgdp2policy) if sample, robust
	display _newline "$header 7/OLS (low-income, with aid^2*policy)"
	regress elrgdpg elraid elraidpolicy elraid2policy elrlgdp elrethnf elrassas elrethnfassas elrssa elreasia elricrge elrm21 elrpolicy _Iperiod* if sample & !elrdn1900, robust
	display _newline "$header 8/OLS (low-income, outliers excluded, no aid^2*policy)"
	regress elrgdpg elraid elraidpolicy elrlgdp elrethnf elrassas elrethnfassas elrssa elreasia elricrge elrm21 elrpolicy _Iperiod* if sample & !elroutlier & !elrdn1900, robust
	display _newline "$header 8/OLS+ (low-income, with outliers but no aid^2*policy)"
	regress elrgdpg elraid elraidpolicy elrlgdp elrethnf elrassas elrethnfassas elrssa elreasia elricrge elrm21 elrpolicy _Iperiod* if sample & !elrdn1900, robust
	display _newline "$header 8/2SLS (low-income, outliers excluded, no aid^2*policy)"
	ivreg elrgdpg elrlgdp elrethnf elrassas elrethnfassas elrssa elreasia elricrge elrm21 elrpolicy _Iperiod* (elraid elraidpolicy = elrfrz elrcentam elregypt elrarms1 elrarms1policy elrlpop elrlpoppolicy elrlpop2policy elrlgdppolicy elrlgdp2policy) if sample & !elroutlier & !elrdn1900, robust
	display _newline "$header 8/2SLS+ (low-income, with outliers but no aid^2*policy)"
	ivreg elrgdpg elrlgdp elrethnf elrassas elrethnfassas elrssa elreasia elricrge elrm21 elrpolicy _Iperiod* (elraid elraidpolicy = elrfrz elrcentam elregypt elrarms1 elrarms1policy elrlpop elrlpoppolicy elrlpop2policy elrlgdppolicy elrlgdp2policy) if sample & !elrdn1900, robust

	drop elrpolicy elroutlier elraidpolicy elraid2policy elrarms1policy elrlpoppolicy elrlgdppolicy elrlpop2policy elrlgdp2policy sample
}


