# IVB Assessment: Nunn & Wantchekon (2011, AER)
# "The Slave Trade and the Origins of Mistrust in Africa"

**Date:** 2026-02-27
**Verdict: GOOD candidate for IVB analysis (with caveats)**

---

## 1. Paper Summary

Nunn & Wantchekon (2011) examine whether the transatlantic and Indian Ocean slave trades caused a persistent culture of mistrust in Africa. Using individual-level data from the 2005 Afrobarometer survey (~20,000 respondents across 17 sub-Saharan African countries), they regress contemporary trust levels on historical slave exports at the ethnic group level. The key finding is that individuals whose ancestors belonged to ethnic groups more heavily raided during the slave trade exhibit lower trust today -- in their relatives, neighbors, coethnics, and local government.

The paper uses three identification strategies:
1. OLS with extensive controls (selection-on-observables)
2. Altonji-Elder-Taber (2005) selection ratios
3. IV using historical distance from the coast as an instrument

---

## 2. Main Specification

### Estimating Equation (Equation 1, p. 3231)

```
trust_{i,e,d,c} = alpha_c + beta * slave_exports_e + X'_{i,e,d,c} * Gamma
                   + X'_{d,c} * Omega + X'_e * Phi + epsilon_{i,e,d,c}
```

Where:
- i = individual, e = ethnic group, d = district, c = country
- trust = one of five trust measures (0-3 scale): trust in relatives, neighbors, local council, intragroup trust, intergroup trust
- slave_exports_e = ln(1 + exports/area) for the ethnic group (baseline measure, from Table 1, column 5)
- alpha_c = country fixed effects
- X_{i,e,d,c} = individual-level controls
- X_{d,c} = district-level controls
- X_e = ethnicity-level controls (added in Tables 3, 5, 6)

### Key Features:
- **Cross-sectional** data (not panel/TSCS)
- **OLS** estimation (linear regression)
- **Individual-level** unit of observation
- Standard errors clustered at ethnicity and district levels (two-way clustering)
- R-squared: 0.13-0.21 depending on trust measure and specification

---

## 3. All Control Variables

### A. Individual-Level Controls (X_{i,e,d,c})
1. Age (continuous)
2. Age squared (continuous)
3. Gender indicator (binary)
4. Urban location indicator (binary)
5. Five living conditions fixed effects (categorical -> dummies)
6. Ten education fixed effects (categorical -> dummies)
7. 18 religion fixed effects (categorical -> dummies)
8. 25 occupation fixed effects (categorical -> dummies)

### B. District-Level Controls (X_{d,c})
9. Ethnic fractionalization of the district (continuous)
10. Share of district population that is same ethnicity as respondent (continuous)

### C. Country Fixed Effects
11. Country fixed effects (alpha_c) -- 17 country dummies

### D. Ethnicity-Level Colonial Controls (added in Table 3, X_e)
12. Colonial population density (continuous: log of colonial-era population density)
13. Malaria ecology/prevalence index (continuous)
14. 1400 urbanization indicator (binary: city with >20,000 inhabitants in 1400)
15. Eight fixed effects for sophistication of precolonial settlement (categorical -> dummies)
16. Number of jurisdictional hierarchies beyond the local community (continuous/ordinal)
17. Colonial railway network indicator (binary)
18. Precolonial European explorer contact indicator (binary)
19. Missions per square kilometer during colonial period (continuous)

### E. Additional IV Controls (added in Table 6)
20. Reliance on fishing (continuous: fraction of food from fish, from Ethnographic Atlas)
21. Distance to closest Saharan trade city (continuous)
22. Distance to closest Saharan trade route (continuous)

---

## 4. Best Table/Column for IVB

**Table 3, Column 2: "Trust of neighbors"** is the best candidate.

Rationale:
- Trust in neighbors is the most commonly cited dependent variable in the paper
- Table 3 includes the fullest OLS specification with all control categories: individual controls, district controls, ethnicity-level colonial controls, colonial population density, AND country fixed effects
- Coefficient: beta = -0.202 (SE = 0.031), highly significant
- N = 16,679 individuals; 147 ethnicity clusters; 1,187 district clusters
- R-squared = 0.16
- This is pure OLS (not IV), which is required for FWL-based IVB

Alternative: Table 2, Column 2 (trust of neighbors, baseline controls without colonial controls) could also work. Coefficient = -0.159 (SE = 0.034), N = 20,027.

---

## 5. IVB Feasibility Assessment

### Requirement 1: Linear OLS regression -- SATISFIED

The baseline and extended specifications are all OLS. Equation (1) is a standard linear regression. The FWL theorem applies directly. The paper also estimates ordered logit as a robustness check but the main results are OLS.

### Requirement 2: Continuous controls -- PARTIALLY SATISFIED

Many controls are categorical (entered as fixed effects): living conditions (5 dummies), education (10 dummies), religion (18 dummies), occupation (25 dummies), settlement sophistication (8 dummies). These are not continuous.

However, several important controls ARE continuous or nearly continuous:
- **Age** and **age squared** (continuous)
- **Ethnic fractionalization** (continuous, 0-1)
- **Share same ethnicity** (continuous, 0-1)
- **Colonial population density** (continuous, log scale)
- **Malaria ecology index** (continuous)
- **Missions per sq km** (continuous)
- **Number of jurisdictional hierarchies** (continuous/ordinal)
- **Reliance on fishing** (continuous)
- **Distance to Saharan city/route** (continuous)

**For IVB analysis, focus on the continuous controls.** The categorical fixed effects (religion, education, occupation, living conditions) can be left in the regression -- they just won't be the focus of the IVB calculation. IVB is computed one control at a time, so we can select the continuous ones.

### Requirement 3: Selection-on-observables design -- SATISFIED

The paper explicitly employs a selection-on-observables strategy for its OLS estimates. The entire logic of Tables 2-4 is:
1. Show baseline OLS correlation (Table 1-2)
2. Show robustness to adding observable controls (Table 3)
3. Use Altonji-Elder-Taber (2005) ratios to assess potential bias from unobservables (Table 4)

The paper states (p. 3235): "We control for observable characteristics of ethnic groups that may be correlated with the slave trade and subsequent trust." This is textbook selection-on-observables reasoning.

The IV strategy (Tables 5-6) is supplementary. The OLS results with controls are presented as the primary evidence of robustness.

### Requirement 4: Plausible colliders -- ASSESSED BELOW

---

## 6. Collider Candidates

For a control Z to be a collider, we need:
- D -> Z: slave trade intensity affects Z
- Y -> Z: trust affects Z
- (Z is included as a control in the regression)

### 6.1 Colonial Population Density (STRONG collider candidate)

**D -> Z (slave trade -> colonial population density):** Very plausible. Nunn (2008, QJE) showed that the slave trade devastated African economies and reduced population. Areas more heavily raided would have had lower population density in the colonial era. This is a direct consequence of the slave trade.

**Y -> Z (trust -> population density):** Plausible through a development channel. Higher-trust communities may have had better cooperation, more trade, and higher population retention/growth, leading to higher colonial-era population density. Alternatively, trust is correlated with institutional quality, which affects population density.

**Note:** This variable is measured in the colonial period (early 20th century), which is AFTER the slave trade (ended ~1900) but BEFORE the trust measurement (2005). This temporal ordering makes it a particularly interesting collider: the slave trade (1400-1900) -> colonial population density (early 1900s) <- trust norms (which were already evolving).

**Counter-argument as confounder:** Colonial population density may also be a confounder if it independently affects trust through mechanisms unrelated to the slave trade (e.g., urbanization effects on social norms). The authors include it precisely for this reason. It is BOTH a plausible confounder and a plausible collider.

### 6.2 Ethnic Fractionalization of District (MODERATE collider candidate)

**D -> Z:** The slave trade may have increased ethnic fractionalization by disrupting ethnic group boundaries, causing displacement and migration. Areas more affected by the slave trade may have more fragmented ethnic compositions today.

**Y -> Z:** Trust may affect residential sorting. In high-trust areas, ethnic groups may be more willing to live together (lower segregation), affecting fractionalization measures. Alternatively, low trust may drive ethnic sorting.

**Note:** This is measured contemporaneously from the Afrobarometer sample itself.

### 6.3 Malaria Ecology Index (WEAK collider candidate)

**D -> Z:** Weak. Malaria ecology is largely determined by geography/climate, not by the slave trade. The slave trade may have indirectly affected malaria (e.g., through land use changes, population movements), but this is a stretch.

**Y -> Z:** Very weak. Trust does not plausibly affect mosquito prevalence.

**Assessment:** Malaria ecology is more plausibly a confounder (malaria -> slave trade susceptibility AND malaria -> trust), not a collider. This control is likely benign for IVB.

### 6.4 Precolonial Settlement Sophistication / Jurisdictional Hierarchies (MODERATE collider candidate)

**D -> Z:** The slave trade disrupted existing political institutions and settlement patterns. Nunn (2008) documents this. However, these variables are measured from the Ethnographic Atlas, which documents conditions roughly at the time of European contact -- potentially overlapping with the slave trade period.

**Y -> Z:** Pre-existing trust norms (before/during the slave trade) could have affected political organization. Higher-trust societies may have developed more complex governance.

**Assessment:** The temporal ordering is ambiguous, which weakens the collider argument.

### 6.5 Education Fixed Effects (STRONG collider candidate -- but categorical)

**D -> Z:** The slave trade devastated human capital accumulation. Nunn (2008) documents this extensively. Areas more affected by the slave trade have lower educational attainment today.

**Y -> Z:** Trust affects educational outcomes. Higher-trust communities invest more in public goods including education (Knack & Keefer 1997). Individuals with higher trust may also have higher educational motivation.

**Problem:** Education is entered as 10 fixed effects (categorical dummies), not as a continuous variable. This makes IVB computation less straightforward, though in principle one could compute IVB for each dummy or for a continuous education measure.

### 6.6 Occupation Fixed Effects (MODERATE collider candidate -- but categorical)

**D -> Z:** The slave trade affected economic structures and occupational distributions.

**Y -> Z:** Trust affects labor market outcomes and occupational choices (Bloom et al. 2008 on management practices; Francois et al. 2010 on competition and trust).

**Same problem:** 25 occupation dummies, not continuous.

### 6.7 Living Conditions Fixed Effects (MODERATE collider candidate -- but categorical)

**D -> Z:** Slave trade -> economic devastation -> worse living conditions today.

**Y -> Z:** Trust -> cooperation -> better public goods -> better living conditions.

**Same problem:** 5 living conditions dummies.

### 6.8 Urban Location Indicator (MODERATE collider candidate -- binary)

**D -> Z:** The slave trade affected urbanization patterns. Areas more raided may have lower urbanization (or conversely, displaced populations may have migrated to cities).

**Y -> Z:** Trust affects the decision to migrate to urban areas and the viability of urban agglomerations.

**Problem:** Binary variable.

---

## 7. Summary Assessment

### Strengths for IVB application:
1. **Pure OLS specification** -- FWL theorem applies perfectly
2. **Selection-on-observables design** -- the paper explicitly uses this framework
3. **Multiple continuous controls** that are plausible colliders: colonial population density, ethnic fractionalization, share same ethnicity, malaria index, missions density, jurisdictional hierarchies
4. **Large sample** (~16,000-20,000 observations) -- precise estimation of auxiliary regressions
5. **Cross-sectional** -- simpler than TSCS; IVB formula applies without dynamic complications
6. **High-profile AER paper** -- good illustration for IVB methodology
7. **Colonial population density** is an especially compelling collider: clear D->Z path (Nunn 2008), plausible Y->Z path, and it is continuous

### Weaknesses/Caveats:
1. **Many controls are categorical** -- education (10 FE), occupation (25 FE), religion (18 FE), living conditions (5 FE), settlement sophistication (8 FE). IVB for dummies is less intuitive than for continuous variables.
2. **Treatment varies at ethnicity level, not individual level** -- slave exports are constant within ethnic groups. The IVB formula still applies, but the effective sample size for the D->Z and Y->Z relationships is the number of ethnic groups (~147-185), not the number of individuals.
3. **Not a TSCS/panel** -- the paper is cross-sectional. The IVB formula still works for cross-sections, but the original IVB paper may have focused on TSCS applications. (Per the user's note, this is fine.)
4. **The strongest collider candidates (education, occupation, living conditions) are categorical**, while the continuous controls (colonial population density, malaria, etc.) have more ambiguous collider status.
5. **Data extraction blocked** -- I was unable to extract the zip files due to sandbox restrictions. The user will need to manually extract `dv-files.zip` and `dv-stata-data.zip` to access the .do file (`NunnWantchekon.do`) and .dta file (`NunnWantchekon_Dataset.dta`).

### Best IVB Target:
**Colonial population density** (continuous, ln scale) in the Table 3 specification.
- theta* = coefficient of colonial pop density in the trust regression (conditional on other controls)
- pi = coefficient of slave exports in an auxiliary regression of colonial pop density on slave exports (conditional on other controls)
- IVB = -theta* x pi

This is the single best collider candidate because:
1. It is continuous
2. D->Z is strongly documented (Nunn 2008)
3. Y->Z is plausible (trust -> cooperation -> development -> population density)
4. It is included in the main specification (Table 3)

---

## 8. Verdict

**GOOD candidate for IVB analysis.**

The paper satisfies the core requirements: linear OLS, selection-on-observables design, continuous controls that are plausible colliders. The best target for IVB computation is the colonial population density control in the Table 3 specification. Secondary targets include ethnic fractionalization, missions density, and jurisdictional hierarchies.

The main limitation is that many of the most compelling colliders (education, occupation, living conditions) are categorical, not continuous. However, colonial population density alone provides a strong demonstration case.

---

## 9. Data Availability

### Downloaded:
- Paper PDF: `/Users/manoelgaldino/Documents/DCP/Papers/IVB/IVB-paper/replication/candidate_papers/nunn_wantchekon_2011/paper.pdf`
- JAE Replication files (Deconinck & Verpoorten 2013, which includes the original N&W data and do-file):
  - `dv-files.zip` (2.2 MB) -- contains NunnWantchekon.do and raw data files
  - `dv-stata-data.zip` (858 KB) -- contains NunnWantchekon_Dataset.dta
  - Source: http://qed.econ.queensu.ca/jae/2013-v28.1/deconinck-verpoorten/
- README: `readme_jae.txt`

### Not yet extracted:
The zip files need to be manually extracted (sandbox blocked extraction).
Run: `unzip dv-files.zip` and `unzip dv-stata-data.zip` in the nunn_wantchekon_2011 directory.

### Original ICPSR deposit:
https://www.openicpsr.org/openicpsr/project/112479/version/V1/view (requires ICPSR login)
Contains: Nunn_Wantchekon_AER_2011.dta and associated files.

---

## 10. Key References

- Nunn, N. & Wantchekon, L. (2011). "The Slave Trade and the Origins of Mistrust in Africa." *American Economic Review*, 101(7), 3221-3252.
- Nunn, N. (2008). "The Long-Term Effects of Africa's Slave Trades." *Quarterly Journal of Economics*, 123(1), 139-176.
- Deconinck, K. & Verpoorten, M. (2013). "Narrow and Scientific Replication of 'The Slave Trade and the Origins of Mistrust in Africa'." *Journal of Applied Econometrics*, 28(1), 166-169.
- Altonji, J.G., Elder, T.E., & Taber, C.R. (2005). "Selection on Observed and Unobserved Variables." *Journal of Political Economy*, 113(1), 151-184.
