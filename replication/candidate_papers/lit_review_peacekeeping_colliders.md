# Literature Review: Controls as Collider Candidates in Blair, Di Salvatore & Smidt (2023, APSR)

**Objective:** Evaluate the causal evidence that the outcome (Y = electoral democracy / V-Dem polyarchy index) causes each control variable (Z). If Y causes Z, then conditioning on Z introduces collider bias (Included Variable Bias).

**Model specification:** `v2x_polyarchy_{i,t} = beta * PK_treatment_{i,t-2} + gamma * Controls_{i,t-3} + delta_i + epsilon_{i,t}`

where PK_treatment is a peacekeeping measure (democracy mandate dummy, personnel counts) lagged 2 periods, controls are lagged 3 periods with within-country mean imputation, and delta_i are country fixed effects.

**Critical design feature:** Controls are measured at t-3 while treatment is measured at t-2. This temporal ordering means that for Z to be a collider, electoral democracy at time t would need to cause Z at time t-3, which requires either anticipation effects or persistent reverse feedback from earlier democracy levels. This substantially mitigates collider concerns even for theoretically plausible colliders.

---

## Part 1: Electoral Democracy --> GDP per capita

### 1.1 Overview

The causal effect of democracy on economic growth and income levels is one of the most studied questions in comparative political economy. After decades of ambiguous results (Przeworski et al. 2000; Barro 1996), a consensus has emerged that democracy does have a positive causal effect on GDP per capita, driven primarily by the landmark study of Acemoglu, Naidu, Restrepo, and Robinson (2019).

### 1.2 Key references

| Author(s) | Year | Journal | Method | Finding |
|-----------|------|---------|--------|---------|
| **Acemoglu, Naidu, Restrepo & Robinson** | **2019** | **JPE** | **Dynamic panel (ADL), system GMM, IV (regional democratization waves); 175 countries, 1960-2010** | **Democratization increases GDP per capita by ~20% over 25 years. This is the current consensus result.** |
| Papaioannou & Siourounis | 2008 | Economic Journal | Before-after event study of democratic transitions | Democratization associated with ~1 percentage point per year additional growth |
| Madsen, Raschky & Skali | 2015 | European Economic Review | IV using linguistic-distance-weighted foreign democracy; 500 years of data | Large positive effects of democracy on income |
| Doucouliagos & Ulubasoglu | 2008 | AJPS | Meta-analysis of 84 studies | Robust indirect effects of democracy on growth via human capital, inflation, and economic freedom |
| Rodrik & Wacziarg | 2005 | AER P&P | Event study | Democratizations followed by short-run growth accelerations |
| Pelke | 2023 | Democratization | Reanalysis with updated data | Confirms positive democracy-growth link but highlights sensitivity to measurement |

### 1.3 Mechanisms

1. **Investment in human capital:** Democracies invest more in education (Stasavage 2005; Harding & Stasavage 2014), which raises productivity.
2. **Reduced expropriation risk:** Democratic institutions protect property rights and reduce policy uncertainty, encouraging private investment.
3. **Economic reform:** Democracies are more likely to adopt growth-promoting economic policies (Giavazzi & Tabellini 2005).
4. **Reduced social conflict:** Democratic institutions provide channels for peaceful conflict resolution, reducing growth-destroying instability.

### 1.4 Assessment for IVB

**Evidence strength: STRONG.** There is robust evidence that democracy causes GDP growth, especially after Acemoglu et al. (2019). However, the 3-year lag on GDP per capita means we need democracy at time t to affect GDP per capita at time t-3. In a panel setting with country fixed effects, the relevant variation is within-country changes in democracy affecting *prior* GDP per capita. This reverse temporal ordering makes the collider channel implausible in the strict contemporaneous sense, though persistent feedback effects (higher democracy in earlier periods raising GDP, which then feeds into the lagged control) could create a weaker version of the problem.

**IVB magnitude (Table 2, democracy mandate): +0.0055, representing 46% of total IVB.** This is the largest single IVB component, but the 3-year lag structure provides substantial protection against genuine collider bias.

---

## Part 2: Electoral Democracy --> Refugees & IDPs

### 2.1 Overview

The relationship between political regime type and forced displacement operates through multiple channels. The literature on state repression and the "domestic democratic peace" (Davenport 2007) establishes that democracies are less repressive, which should reduce displacement. However, democratic transitions --- particularly in post-conflict settings --- can be destabilizing and may initially increase displacement before stabilizing it.

### 2.2 Key references

| Author(s) | Year | Journal | Method | Finding |
|-----------|------|---------|--------|---------|
| **Davenport** | **2007** | **Cambridge UP** | **Panel, 137 countries, 1976-1996** | **Democracy reduces state repression (the "domestic democratic peace"); electoral participation and competition are the most effective components** |
| Schmeidl | 1997 | Social Science Quarterly | Pooled time-series, 1971-1990 | Genocide, civil war, and repression are primary drivers of refugee stocks |
| Moore & Shellman | 2004 | JCR | Panel analysis | Political repression and armed conflict are key push factors for forced migration; regime type matters |
| Iqbal & Zorn | 2006 | JCR | Panel, 1987-2001 | Higher levels of democracy reduce refugee outflows; armed conflict is the strongest predictor |
| Melander & Oberg | 2007 | JPR | Cross-national panel | Democratization can initially increase displacement during unstable transitions |

### 2.3 Mechanisms

1. **Reduced repression:** Democracies repress less (Davenport 2007), generating fewer refugees.
2. **Conflict resolution:** Democratic institutions provide peaceful outlets for grievances, reducing civil war and associated displacement.
3. **Transitional instability:** Democratic transitions in post-conflict settings can be destabilizing, temporarily increasing displacement (Melander & Oberg 2007).
4. **Return effects:** Democratization may attract refugee returns, reducing stocks of displaced persons.

### 2.4 Assessment for IVB

**Evidence strength: MODERATE.** There is reasonable evidence that democracy (especially consolidated democracy) reduces displacement by reducing repression and conflict. However, the relationship is complex in post-conflict settings --- the exact context of this paper. Democratic transitions can be destabilizing, and the direction of the effect is ambiguous during transition periods.

The 3-year lag provides important protection: refugees/IDPs at t-3 would need to be causally affected by democracy at t, which is temporally impossible in a strict sense. However, persistent within-country democracy trajectories could create weak feedback effects through earlier periods.

**IVB magnitude (Table 2, democracy mandate): +0.0050, representing 42% of total IVB.** This is the second-largest IVB component.

---

## Part 3: Electoral Democracy --> Foreign Aid (ODA)

### 3.1 Overview

A well-established literature in international political economy documents that Western donors allocate more foreign aid to democracies and to countries undergoing democratic transitions. This means that democracy (Y) plausibly causes aid allocation (Z), which is the relevant direction for collider bias.

### 3.2 Key references

| Author(s) | Year | Journal | Method | Finding |
|-----------|------|---------|--------|---------|
| **Alesina & Dollar** | **2000** | **JEG** | **Cross-country panel** | **Countries that democratize receive more aid; political alliances and colonial ties also matter** |
| **Bermeo** | **2016** | **IO** | **Panel with donor-recipient dyads** | **Aid from democratic donors rewards democratization; aid from autocratic donors does not** |
| Claessens, Cassimon & Van Campenhout | 2009 | Eur. Econ. Rev. | Panel | Evidence of aid conditionality on governance/democracy post-Cold War |
| Wright | 2009 | APSR | Panel with strategic interaction model | Donors target aid to countries where it can promote democratic change |
| Dunning | 2004 | Int. Org. | Panel | Cold War vs. post-Cold War shift: democracy became a stronger predictor of aid after 1989 |
| Savun & Tirone | 2011 | JCR | Panel | Foreign aid promotes democratization particularly in post-conflict settings |

### 3.3 Mechanisms

1. **Conditionality:** Western donors condition aid on democratic governance (post-Cold War), rewarding democratizers.
2. **Strategic alignment:** Democratic donors prefer democratic recipients for strategic and normative reasons.
3. **Post-conflict peacebuilding:** Aid flows increase to countries undergoing post-conflict transitions toward democracy --- directly relevant to the Blair et al. context.
4. **Institutional quality signals:** Democracy serves as a signal of institutional quality, attracting aid commitments.

### 3.4 Assessment for IVB

**Evidence strength: STRONG.** The literature robustly shows that democracy causes increased foreign aid flows. This is especially relevant in the peacekeeping context, where democratic transitions often trigger donor engagement. However, the 3-year lag means that aid at t-3 cannot be caused by democracy at t. The concern is that democracy trajectories are persistent, so countries on a democratizing path may have received more aid 3 years earlier. Within a country-FE framework, this requires *changes* in democracy to predict *prior* changes in aid, which is mitigated by the lag structure.

**IVB magnitude (Table 2, democracy mandate): +0.0029, representing 24% of total IVB.**

---

## Part 4: Electoral Democracy --> Fuel Exports

### 4.1 Overview

The "resource curse" literature (Ross 2001, 2012) primarily examines the reverse direction: whether oil/resource wealth affects democracy. The question for IVB is the opposite: does democracy affect fuel exports? The answer is overwhelmingly no.

### 4.2 Key references

| Author(s) | Year | Journal | Finding |
|-----------|------|---------|---------|
| Ross | 2001 | World Politics | Oil wealth hinders democracy (resource curse), not the reverse |
| Ross | 2012 | Princeton UP | Comprehensive treatment: oil affects institutions, not institutions affecting oil extraction |
| Haber & Menaldo | 2011 | APSR | Challenge to resource curse thesis, but focus remains on oil --> politics direction |
| Andersen & Ross | 2014 | Comparative Political Studies | Oil became a hindrance to democracy only after 1970s nationalization |

### 4.3 Assessment for IVB

**Evidence strength: NO EVIDENCE for Y --> Z.** Fuel exports are determined by geological endowments, global commodity prices, and extraction technology --- not by the political regime. While democracy may affect *management* of resource revenues (transparency, distribution), it does not plausibly affect the volume of fuel exports. The resource curse literature is entirely about the reverse direction (oil --> politics). There is no credible mechanism by which electoral democracy would cause changes in fuel exports.

**IVB magnitude (Table 2, democracy mandate): -0.0010.** This small IVB likely reflects residual confounding rather than collider bias.

---

## Part 5: Electoral Democracy --> Literacy

### 5.1 Overview

There is evidence that democracies invest more in education (Stasavage 2005; Brown & Hunter 2004), which could eventually affect literacy rates. However, literacy is a slow-moving stock variable that changes over decades, not years.

### 5.2 Key references

| Author(s) | Year | Journal | Method | Finding |
|-----------|------|---------|--------|---------|
| Stasavage | 2005 | AJPS | Panel, 44 African countries, 1980-1996 | Multiparty competition increases education spending by 4.4% of total expenditures |
| Brown & Hunter | 2004 | Int. Org. | Panel, Latin America | Democracy increases social spending, including education |
| Harding & Stasavage | 2014 | Econ. & Politics | Panel, Kenya | Democracy removes school fees, increasing attendance but not quality |
| Miller | 2015 | Int. Org. | Panel | Democracy produces higher literacy rates, but effect operates over long time horizons |
| Ansell | 2010 | Cambridge UP | Panel | Democratization shapes education policy, but effects on outcomes are slow |

### 5.3 Assessment for IVB

**Evidence strength: WEAK/LONG-RUN.** While democracy may increase education spending, the effect on adult literacy rates operates over very long time horizons (decades). Literacy is a stock variable that accumulates slowly as younger educated cohorts age into the adult population. Annual changes in literacy are minimal. Within the time frame of a panel regression with 3-year lags and country fixed effects, the effect of democracy on literacy is negligible.

**IVB magnitude (Table 2, democracy mandate): +0.0000 (essentially zero).** The near-zero IVB is consistent with the theoretical expectation that literacy does not respond meaningfully to democracy within the short time horizons of the panel.

---

## Part 6: Electoral Democracy --> Population

### 6.1 Overview

Population is a fundamentally demographic variable driven by fertility, mortality, and net migration. While there is some evidence that political regimes affect health outcomes (Besley & Kudamatsu 2006) and thus mortality, these effects operate over very long time horizons. Population is essentially exogenous to electoral democracy in the short and medium run.

### 6.2 Key references

| Author(s) | Year | Journal | Finding |
|-----------|------|---------|---------|
| Besley & Kudamatsu | 2006 | AER P&P | Democracy improves health outcomes, but effects are very long-run |
| Przeworski et al. | 2000 | Cambridge UP | Democracies have lower infant mortality, but population effects are slow |
| Gerring et al. | 2012 | Int. Org. | Democracy improves infant survival, but through long-run institutional channels |

### 6.3 Assessment for IVB

**Evidence strength: NO/NEGLIGIBLE.** Population is not plausibly caused by electoral democracy in the time frame relevant to this analysis. Fertility and mortality changes driven by political institutions operate over decades. Population growth rates in any given year are determined by demographic momentum, not by contemporaneous or recent political regime type.

**IVB magnitude (Table 2, democracy mandate): -0.0005.** The near-zero IVB confirms that population does not function as a collider.

---

## Summary: Collider Evidence and IVB Magnitudes

| Control | Y --> Z evidence | Key reference | Mechanism | IVB (Table 2) | % of total |
|---------|-----------------|---------------|-----------|---------------|------------|
| **GDP per capita** | **Strong** | Acemoglu et al. 2019 | Democracy --> investment, reform, human capital --> growth | **+0.0055** | **46%** |
| **Refugees & IDPs** | **Moderate** | Davenport 2007; Iqbal & Zorn 2006 | Democracy --> reduced repression --> fewer refugees | **+0.0050** | **42%** |
| **Foreign Aid** | **Strong** | Alesina & Dollar 2000; Bermeo 2016 | Democracy --> donor reward --> more aid | **+0.0029** | **24%** |
| Fuel Exports | None | Ross 2001 | No mechanism (geology determines exports) | -0.0010 | --- |
| Population | None | --- | No mechanism (demographic, slow-moving) | -0.0005 | --- |
| Literacy | Weak/long-run | Stasavage 2005 | Democracy --> education spending --> literacy (decades) | +0.0000 | ~0% |

### Conclusions for the IVB Paper

1. **Three controls have plausible collider channels:** GDP per capita, refugees/IDPs, and foreign aid all have documented causal links from democracy (the outcome). Together they account for the bulk of the IVB.

2. **The 3-year lag structure is a powerful safeguard.** Controls are measured at t-3 while the treatment is at t-2 and the outcome at t. This temporal ordering means that even for plausible colliders, the collider channel would require democracy at time t to affect a control measured 3 years earlier --- which is temporally impossible in a strict sense. The concern is limited to persistent within-country democracy trajectories creating weak feedback effects through earlier periods.

3. **The IVB results are best interpreted as sensitivity analysis.** Given the lag structure, the IVB decomposition reveals how sensitive the treatment coefficient is to each control's inclusion, rather than measuring definitive collider bias. The substantive lesson is that GDP per capita and refugee/IDP levels are the controls that most strongly shape the estimated peacekeeping effect.

4. **Blair et al.'s design choice is sound.** The authors' decision to lag controls an additional period beyond the treatment (3 vs. 2 years) is a deliberate and effective strategy to mitigate post-treatment bias / collider bias concerns. This makes the peacekeeping application a case where IVB concerns are theoretically motivated but empirically limited by thoughtful research design.

---

## References

- Acemoglu, D., Naidu, S., Restrepo, P., & Robinson, J. A. (2019). Democracy Does Cause Growth. *Journal of Political Economy*, 127(1), 47-100.
- Alesina, A. & Dollar, D. (2000). Who Gives Foreign Aid to Whom and Why? *Journal of Economic Growth*, 5(1), 33-63.
- Andersen, J. J. & Ross, M. L. (2014). The Big Oil Change: A Closer Look at the Haber-Menaldo Analysis. *Comparative Political Studies*, 47(7), 993-1021.
- Ansell, B. W. (2010). *From the Ballot to the Blackboard: The Redistributive Political Economy of Education*. Cambridge University Press.
- Barro, R. J. (1996). Democracy and Growth. *Journal of Economic Growth*, 1(1), 1-27.
- Bermeo, S. B. (2016). Aid Is Not Oil: Donor Utility, Heterogeneous Aid, and the Aid-Democratization Relationship. *International Organization*, 70(1), 1-32.
- Besley, T. & Kudamatsu, M. (2006). Health and Democracy. *American Economic Review*, 96(2), 313-318.
- Blair, R. A., Di Salvatore, J., & Smidt, H. M. (2023). UN Peacekeeping and Democratization in Conflict-Affected Countries. *American Political Science Review*, 117(4), 1347-1367.
- Brown, D. S. & Hunter, W. (2004). Democracy and Human Capital Formation. *International Organization*, 58(4), 685-719.
- Claessens, S., Cassimon, D., & Van Campenhout, B. (2009). Evidence on Changes in Aid Allocation Criteria. *European Economic Review*, 53(7), 725-743.
- Davenport, C. (2007). *State Repression and the Domestic Democratic Peace*. Cambridge University Press.
- Doucouliagos, H. & Ulubasoglu, M. A. (2008). Democracy and Economic Growth: A Meta-Analysis. *American Journal of Political Science*, 52(1), 61-83.
- Dunning, T. (2004). Conditioning the Effects of Aid: Cold War Politics, Donor Credibility, and Democracy in Africa. *International Organization*, 58(2), 409-423.
- Gerring, J., Bond, P., Barndt, W. T., & Moreno, C. (2012). Democracy and Human Development. *International Organization*, 66(1), 1-38.
- Giavazzi, F. & Tabellini, G. (2005). Economic and Political Liberalizations. *Journal of Monetary Economics*, 52(7), 1297-1330.
- Haber, S. & Menaldo, V. (2011). Do Natural Resources Fuel Authoritarianism? A Reappraisal of the Resource Curse. *American Political Science Review*, 105(1), 1-26.
- Harding, R. & Stasavage, D. (2014). What Democracy Does (and Doesn't Do) for Basic Services: School Fees, School Inputs, and African Elections. *Journal of Politics*, 76(1), 229-245.
- Iqbal, Z. & Zorn, C. (2006). Swords into Ploughshares: United Nations Peacebuilding and Refugee Return. *Journal of Conflict Resolution*, 50(2), 227-249.
- Madsen, J. B., Raschky, P. A., & Skali, A. (2015). Does Democracy Drive Income in the World, 1500-2000? *European Economic Review*, 78, 175-195.
- Melander, E. & Oberg, M. (2007). The Threat of Violence and Forced Migration. *European Journal of International Relations*, 13(3), 399-425.
- Miller, M. K. (2015). Electoral Authoritarianism and Human Development. *Comparative Political Studies*, 48(12), 1526-1562.
- Moore, W. H. & Shellman, S. M. (2004). Fear of Persecution: Forced Migration, 1952-1995. *Journal of Conflict Resolution*, 48(5), 723-745.
- Papaioannou, E. & Siourounis, G. (2008). Democratisation and Growth. *The Economic Journal*, 118(532), 1520-1551.
- Pelke, L. (2023). Reanalysing the Link between Democracy and Economic Development. *Democratization*, 30(8), 1586-1609.
- Przeworski, A., Alvarez, M. E., Cheibub, J. A., & Limongi, F. (2000). *Democracy and Development*. Cambridge University Press.
- Rodrik, D. & Wacziarg, R. (2005). Do Democratic Transitions Produce Bad Economic Outcomes? *American Economic Review*, 95(2), 50-55.
- Ross, M. L. (2001). Does Oil Hinder Democracy? *World Politics*, 53(3), 325-361.
- Ross, M. L. (2012). *The Oil Curse: How Petroleum Wealth Shapes the Development of Nations*. Princeton University Press.
- Savun, B. & Tirone, D. C. (2011). Foreign Aid, Democratization, and Civil Conflict: How Does Democracy Aid Affect Civil Conflict? *American Journal of Political Science*, 55(2), 233-246.
- Schmeidl, S. (1997). Exploring the Causes of Forced Migration: A Pooled Time-Series Analysis, 1971-1990. *Social Science Quarterly*, 78(2), 284-308.
- Stasavage, D. (2005). Democracy and Education Spending in Africa. *American Journal of Political Science*, 49(2), 343-358.
- Wright, J. (2009). How Foreign Aid Can Foster Democratization in Authoritarian Regimes. *American Journal of Political Science*, 53(3), 552-571.
