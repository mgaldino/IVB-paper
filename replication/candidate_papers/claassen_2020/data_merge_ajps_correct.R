#### Does Public Support Help Democracy Survive?
#### Christopher Claassen
#### AJPS Replication file: constructing main dataset using own esimates of support and satisfaction

#### Note: this file merges estimates of democratic support and satisfaction with the other 
#### country-year covariates. It is an optional step. Estimates of support and satisfaction are already 
#### included in the dataset Support_democracy_ajps_correct.csv


# Working directory
WD = rstudioapi::getActiveDocumentContext()$path 
setwd(dirname(WD))
print( getwd() )

# Get data
sd.panel = read.csv("Support_democracy_ajps_correct.csv")
sup.est = read.csv("stan_est_sup_dem_m5.csv")

# Trim data
sd.pan2 = subset(sd.panel, select = -c(SupDem_trim, SupDem_Democ, SupDem_Autoc, SupDem_m1, SupDem_democ_m1, SupDem_autoc_m1))
sup.est = sup.est[, c("Country", "Year", "SupDem_trim")]

# Merge data
sd1 = merge(sd.pan2, sup.est, by=c("Country", "Year"), all.x=TRUE)

# Create lagged sup dem
cnts = unique(sd1$Country)
yrs = 1988:2017
sd1$SupDem_m1 = NA

for(i in 1:length(cnts)) {
  for(j in yrs) {
    sd1[sd1$Country==cnts[i] & sd1$Year==j, "SupDem_m1"] =
      sd1[sd1$Country==cnts[i] & sd1$Year==j-1, "SupDem_trim"]
  }
}

# Create change variables
sd1$ChgSup = sd1$SupDem_trim - sd1$SupDem_m1

# Create democ vs autoc indicators for support and satisfaction
regime = ifelse(sd1$Regime_VD > 1, 1, 0)
sd1$SupDem_Democ = regime * sd1$SupDem_trim
sd1$SupDem_Autoc = (1-regime) * sd1$SupDem_trim

# Create lagged sup dem autoc and democ
sd1$SupDem_democ_m1 = NA
sd1$SupDem_autoc_m1 = NA

for(i in 1:length(cnts)) {
  for(j in yrs) {
    sd1[sd1$Country==cnts[i] & sd1$Year==j, "SupDem_democ_m1"] =
      sd1[sd1$Country==cnts[i] & sd1$Year==j-1, "SupDem_Democ"]
    sd1[sd1$Country==cnts[i] & sd1$Year==j, "SupDem_autoc_m1"] =
      sd1[sd1$Country==cnts[i] & sd1$Year==j-1, "SupDem_Autoc"]
  }
}

write.csv(sd1, "Support_democracy_ajps_correct.csv", row.names=FALSE)
