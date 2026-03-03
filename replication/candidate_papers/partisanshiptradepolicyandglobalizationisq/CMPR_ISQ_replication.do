
gen lnpop=ln(p6pop)
gen lnrgdp=ln(p6rlgdpp)
gen fa11ncl1x=fa11ncl1+1
gen preslr1x=pres* fa11ncl1x
gen erlr1x= fa11ncl1x*erule
gen openlr=p6open*fa11ncl1
gen tclr=cfworld*fa11ncl1
gen eulr=eu*fa11ncl1x
gen lr2=fa11ncl1*fa11ncl1

*** TABLE 1: SUMMARY STATISTICS
summ ftnew2 fa11ncl1 year lnpop p6open lnrgdp cfworld hegemonb  abseatl1 pres erule preslr1x erlr1x openlr tclr lr2 eu eulr


*** TABLE 2: REGRESSION 1
xi: xtgls  ftnew2 fa11ncl1 year lnpop lnrgdp i.ptyold , force p(h) corr(ar1)

*** TABLE 2: REGRESSION 2
xi: xtgls  ftnew2 fa11ncl1 year lnpop p6open lnrgdp cfworld hegemonb   abseatl1 i.ptyold , force p(h) corr(ar1)


*** TABLE 2: REGRESSION 3
xi: xtgls  ftnew2 fa11ncl1 year lnpop p6open lnrgdp cfworld hegemonb  abseatl1 pres erule i.ptyold , force p(h) corr(ar1)

*** TABLE 2: REGRESSION 4
xi: xtgls  ftnew2 fa11ncl1 year lnpop p6open lnrgdp cfworld hegemonb  abseatl1 pres erule i.country , force p(h) corr(ar1)

*** TABLE 2: REGRESSION 5
xi: xtgls  ftnew2 fa11ncl1 year lnpop p6open lnrgdp cfworld hegemonb   abseatl1 pres erule  eu eulr  i.ptyold , force p(h) corr(ar1)
lincom fa11ncl1 +eulr

*** TABLE 3: REGRESSION 6 (Column 1)
xi: xtgls  ftnew2 fa11ncl1 year lnpop p6open lnrgdp cfworld hegemonb   abseatl1 pres erule preslr1x i.ptyold , force p(h) corr(ar1)
lincom fa11ncl1+ preslr1x

*** TABLE 3: REGRESSION 7 (Column 2)
xi: xtgls  ftnew2 fa11ncl1 year lnpop p6open lnrgdp cfworld hegemonb   abseatl1 pres erule  erlr1x i.ptyold , force p(h) corr(ar1)
lincom fa11ncl1+  erlr1x

*** TABLE 3: REGRESSION 8 (Column 3)
xi: xtgls  ftnew2 fa11ncl1 year lnpop p6open lnrgdp cfworld hegemonb   abseatl1 pres erule  preslr1x  erlr1x i.ptyold , force p(h) corr(ar1)
lincom fa11ncl1+  erlr1x+ preslr1x

*** TABLE 4: REGRESSION 9 (Column 1)
xi: xtgls  ftnew2 fa11ncl1 year lnpop p6open lnrgdp cfworld hegemonb   abseatl1 pres erule openlr i.ptyold , force p(h) corr(ar1)
lincom fa11ncl1+openlr

*** TABLE 4: REGRESSION 10 (Column 2)
xi: xtgls  ftnew2 fa11ncl1 year lnpop p6open lnrgdp cfworld hegemonb   abseatl1 pres erule openlr tclr i.ptyold , force p(h) corr(ar1)
lincom fa11ncl1+openlr+tclr

*** TABLE 4: REGRESSION 11 (Column 3)
xi: xtgls  ftnew2 fa11ncl1 year lnpop p6open lnrgdp cfworld hegemonb   abseatl1 pres erule openlr tclr  preslr1x erlr1x i.ptyold , force p(h) corr(ar1)
lincom fa11ncl1+openlr+tclr+preslr1x+erlr1x
