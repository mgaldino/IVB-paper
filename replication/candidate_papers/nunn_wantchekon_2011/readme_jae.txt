Koen Deconinck and Marijke Verpoorten, "Narrow and Scientific 
Replication of 'The Slave Trade and the Origins of Mistrust in Africa'", 
Journal of Applied Econometrics, Vol. 28, No. 1, 2013, pp. 166-169.

Our dataset is stored both in ASCII format and in Stata's .dta format, 
which we used. In addition, we include our code (in Stata's do-file 
format). The full questionnaires and codebooks of the survey data used 
in our analysis can be found at www.afrobarometer.org.

The file containing Stata data is NunnWantchekon_Dataset.dta. It is
zipped in the file dv-stata-data.zip.

There are two files containing raw data:

  NunnWantchekon_Dataset_label.raw

and

  NunnWantchekon_Dataset_nolabel.raw.

The paper uses survey data with qualitative answers which are coded
numerically. In the "labelled" version, answers are written out in
full, e.g. "not satisfied", "satisfied", and so on. In the
"unlabelled" version, answers are converted to numerical codes.

The do-file is NunnWantchekon.do. All three of these files are ASCII
files in DOS format and are zipped in the file dv-files.zip.
Unix/Linux users should use "unzip -a".

The rest of this file documents the construction of the dataset used
in our replication.

1. Narrow Replication: 

The narrow replication was performed using the original dataset used
by the authors. This dataset is available in Stata's .dta-format from
Nathan Nunn's personal website:

http://www.economics.harvard.edu/faculty/nunn/data_nunn

Nathan Nunn also provides other materials used in the construction of
his dataset. In addition, the web appendix to the original paper
explains the data sources used by Nunn and Wantchekon:

http://www.economics.harvard.edu/faculty/nunn/files/Appendix_MS_AER_2009_0252_R2.pdf

2. Scientific Replication:

For our scientific replication, we used the 2008 version of the
Afrobarometer survey, instead of the 2005 survey used by Nunn and
Wantchekon. The Afrobarometer survey data, questionnaires/codebook and
other materials can be found at the Afrobarometer website
(http://afrobarometer.org/) 

We followed the procedure outlined in the appendix to the original
paper to construct our dataset in a comparable way.

The construction of the dataset consisted of several steps. 

First, we linked ethnicities as reported in Afrobarometer 2008 to
ethnicities as described by Murdock (1959)'s classification of African
ethnicities. Second, for those ethnic groups which were not included
in the original paper, we constructed ethnicity-based covariates
similar to those used by Nunn and Wantchekon.

We did this using documentation and extra data generously provided to
us by Nathan Nunn.

-- Some variables are based on historical/anthropological data (e.g.
the Ethnographic Atlas), provided by Nunn.

-- Other variables had to be calculated using Murdock's 1959 map of
African ethnicities and their homelands (e.g. the size of the
homelands and the distance to the coast)

This calculation was performed using ArcGIS and using Nathan Nunn's
digitized version of the Murdock 1959 map. Third, using extra
information provided by Afrobarometer on the name of the town/village
of every respondent in the survey, we used Google Maps to find the GPS
coordinates of every respondent. With these GPS coordinates and the
1959 Murdock map, we used ArcGIS to find the ethnic group originally
living in the current location of the respondent.

Based on the variables collected in this way, it was straightforward
to calculate all necessary covariates.

Below, we provide more information on the ethnic groups included in
our dataset.

ETHIC GROUPS IN AFROBAROMETER 2008

Afrobarometer 2008 contains several ethnic groups not included in the
Afrobarometer 2005.  The extra ethnicities are mostly due to the
addition of two new countries (Liberia and Burkina Faso) and the fact
that in AB2005 the question about ethnicity had not been asked in
Zimbabwe, while this question was included in AB2008.  However, in
several other countries the range of ethnicities in the survey has
expanded as well.  For example, in 2005 the Afrobarometer included
only 6 ethnic groups for Ghana, one of which was "other northern
languages".  In the 2008 Afrobarometer, 24 ethnic groups are included
for Ghana.  This note details how many new ethnic groups are available
in our replication dataset as compared to the original N&W dataset.

In order to match Afrobarometer 2008 ethnicities with data on slave
trades, we used the following procedure. 

First, we matched names of 2008 ethnicities with names of 2005
ethnicities, to exploit the correspondences made by Nunn and
Wantchekon (2011) wherever available. 

If the ethnic group did not appear in the dataset used by Nunn and
Wantchekon, we matched ethnic groups to Murdock's ethnicities using
the following approach. 

First, if the name of the ethnic group as stated appeared in Murdock
(1959), we matched it to a Murdock ethnicity. 

If the name, as stated, was not found in Murdock (1959), we used Olson
(1996) to check alternative spellings, or we used information on the
language spoken at home by the respondent (q3 in the Afrobarometer
survey) combined with information from the Ethnologue: Languages of
the World database (Lewis, 2009), available online at
www.ethnologue.com, to find the corresponding ethnic group in Murdock
(1959). 

Of the 27,713 individuals in the Afrobarometer Round 4 (2008), 3234
respondents stated their ethnicity in a way that inherently could not
be matched to indigenous ethnic groups (Table 1).

Table 1. European or Non-Indigenous Ethnic Identifications and Missing Values  
Description	         Number
African                     373
Afrikaaner                   40
Afrikaans/Afrikaner/Boer    310
Amerivan or European	     30
Coloured                    230
Don't know                  520
English                     108
German                        4
Missing                      26
National ID only or don't think in those terms  850
Portuguese                    9
Refused                      58
Relacionado com o estado de espirito  8
Related to age               9
Related to class             4
Related to gender           15
Related to occupation       19
Related to political-partisan affiliation  3
Related to race              4
Related to regional origin (badio/sampadjudo)  33
Related to religion         10
White/European              16
Others                     555
TOTAL                      3234

Of the 555 individuals who gave "other" as their ethnic group, 306
also gave "other" as their home language. Of those who did indicate a
specific language, many indicate a language which is linked to a
specific ethnic group (in which case it would probably be incorrect to
assign these individuals to that ethnic group, since they did not
identify themselves with it) or a national language (e.g. Swahili),
which makes it impossible to link them to an original ethnic group.

For these reasons we have chosen to drop the group of "others"
altogether. By matching names of the 2008 ethnicities with names of
the 2005 ethnicities, we were able to link 181 ethnic groups (16,246
respondents) immediately and another 35 ethnicities (2,582
respondents) after adjusting minor changes in spelling (e.g.
"khasonk" could be matched to "khassonke").

Eight extra ethnic groups (totaling 429 individuals) were matched with
an ethnic group available in the N&W dataset but which N&W could not
link to a Murdock name.  Of the remaining ethnicities, the approach
outlined above allowed us to find a match for 131 ethnic groups
(counting 4,651 individuals).  For 24 ethnicities (571 respondents) we
were unable to find a corresponding Murdock name. 

Hence, in total we have

-- 216 ethnic groups (18,828 individuals) corresponding to an
   ethnicity included in N&W and matched to a Murdock name

-- 8 ethnic groups (429 individuals) corresponding to an ethnicity
   included in N&W for which they could not find a Murdock name

-- 131 ethnic groups (4,651 individuals) not included in the original
   N&W dataset which we could match to a Murdock name

-- 24 ethnic groups (571 individuals) not included in the original N&W
   dataset which we could not match to a Murdock name

Ethnic groups on which covariates were needed:

There are 69 Murdock ethnicities (accounting for 3,009 respondents)
for which Nunn and Wantchekon's original dataset did provide slave
trade data but for which we didn't have other covariates. 

The following table lists these ethnicities, for which we constructed
the necessary covariates using the procedure outlined above.

                murdock_name |      Freq.     Percent        Cum.
-----------------------------+-----------------------------------
                      ACHOLI |        179        5.95        5.95
                        ANYI |         19        0.63        6.58
                      ASSINI |         12        0.40        6.98
                       BANDA |          5        0.17        7.15
                      BASARI |          9        0.30        7.44
                       BASSA |        151        5.02       12.46
                        BENA |         18        0.60       13.06
                     BIRIFON |          9        0.30       13.36
                      BORANA |          7        0.23       13.59
                         BUA |         12        0.40       13.99
                      BUILSA |          6        0.20       14.19
                        BURA |         16        0.53       14.72
                     BUSANSI |         73        2.43       17.15
                         DAN |         80        2.66       19.81
                       DIULA |          6        0.20       20.01
                      GBANDE |         22        0.73       20.74
                        GOLA |         53        1.76       22.50
                       GREBO |        143        4.75       27.25
                     GRUNSHI |         35        1.16       28.41
                       GUANG |         10        0.33       28.75
                        GUIN |         12        0.40       29.15
                         GUN |         78        2.59       31.74
                     GURENSI |         89        2.96       34.70
                       GURMA |         49        1.63       36.32
                          HA |         48        1.60       37.92
                      HEIKUM |          8        0.27       38.19
                     HLENGWE |         30        1.00       39.18
                       IRAQW |         37        1.23       40.41
                       JUKUN |          7        0.23       40.64
                     KAMBERI |         10        0.33       40.98
                    KARABORO |         13        0.43       41.41
                       KINGA |         10        0.33       41.74
                       KISSI |         48        1.60       43.34
                    KONKOMBA |         11        0.37       43.70
                    KOREKORE |         87        2.89       46.59
                      KPELLE |        286        9.50       56.10
                        KRAN |         49        1.63       57.73
                         KRU |         70        2.33       60.05
                       LANGO |        187        6.21       66.27
                     LIPTAKO |         81        2.69       68.96
                        LOBI |         19        0.63       69.59
                        MADA |          9        0.30       69.89
                    MAMPRUSI |         16        0.53       70.42
                     MANYIKA |         80        2.66       73.08
                       MARGI |         12        0.40       73.48
                     MATENGO |         12        0.40       73.88
                     MATUMBI |         11        0.37       74.24
                       MENDE |          9        0.30       74.54
                      MUMUYE |          8        0.27       74.81
                       MWERA |         19        0.63       75.44
                       NGERE |        106        3.52       78.96
                    NGONYELU |          7        0.23       79.20
                      NUBIAN |          7        0.23       79.43
                      POGORO |         17        0.56       79.99
                        POPO |          6        0.20       80.19
                       RANGI |         11        0.37       80.56
                       RONGA |         25        0.83       81.39
                        SAPO |         11        0.37       81.75
                    SHAMBALA |         18        0.60       82.35
                      SHASHI |         27        0.90       83.25
                     TANGALE |          8        0.27       83.52
                      THLARU |          8        0.27       83.78
                        TOMA |         98        3.26       87.04
                      TSWANA |          7        0.23       87.27
                     TUKULOR |        296        9.84       97.11
                         VAI |         42        1.40       98.50
                      ZARAMO |         18        0.60       99.10
                       ZERMA |          2        0.07       99.17
                      ZIGULA |         25        0.83      100.00
-----------------------------+-----------------------------------
                       Total |      3,009      100.00 

References

Lewis, M. Paul (ed.) (2009) Ethnologue: Languages of the World, 16th
edition, SIL International (Dallas, Texas). Available online at
www.ethnologue.com 

Murdock, G.P. (1959) Africa. Its Peoples and Their Culture History,
McGraw-Hill Book Company (New York, Toronto, London), 456p.

Nunn, N. and L. Wantchekon (2010) Web appendix for "The Slave
Trades and the Origins of Mistrust in Africa", available at
http://www.economics.harvard.edu/faculty/nunn/papers_nunn 

Nunn, N. and L. Wantchekon (2011) "The Slave Trades and the Origins of
Mistrust in Africa," American Economic Review, forthcoming.

Olson, J.S. (1996) The Peoples of Africa. An Ethnohistorical
Dictionary, Greenwoord Press (Westport, Connecticut & London), 681p.
