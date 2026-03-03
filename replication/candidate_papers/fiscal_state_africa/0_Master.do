*******************************************************************
* Replication files Albers, Jerven, Suesse (2022): `Fiscal State' *
*******************************************************************

clear all

**** The following additional stata packages may have to be installed:

				 /*
					ssc install 	estout 

					ssc install		reghdfe

					ssc install		renvarlab

					ssc install		ftools

					ssc install		interflex

					ssc install		sutex2
					
					
					* set graphic schemes
					set		scheme plotplain				
					set		scheme lean2	
 
					*/


**** Set user directory (Please change this to your respective directory in which the replication file is unzipped)
	

	* INSERT THE LOCATION OF THE UNZIPPED FOLDER HERE
	
cd "INSERT THE LOCATION OF THE UNZIPPED FOLDER HERE/AJS_REPLICATION_Fiscal State in Africa"
   
**** Data generation
	
	* Nomenclature (iso codes/names) & coding of colonizer, socialist systems and UN regions  + 	*(.1)
	
		do "1_1_DataGeneration_Nomenclature"
	 
	 
	* Generate and load Fiscal data
	 
		* Fiscal data						*(.2)
	 	do "1_2_DataGeneration_FiscalData"
		
		* Forced Labour						*(.3)
		do "1_3_DataGeneration_ForcedLabour"

	 
	 * Load controls
	 
		*Time invariant						*(.4a)
		do "1_4a_DataGeneration_TimeInvariantControls"
		
		*GDP control						*(.4b)
		do "1_4b_DataGeneration_GDPcontrol"
			
			
			
			
	* Load Covariates of interest
	
				
				* Democracy					*(.5)
				do "1_5_DataGeneration_Democracy"

				* Regime turnover			*(.6)
				do "1_6_DataGeneration_RegimeTurnover"
			
				* Common interest shocks	*(.7)
						
					* Conflict		*(.7a)
 					do "1_7a_DataGeneration_Conflict"
					
					* Disasters		*(.7b)
					do "1_7b_DataGeneration_Disaster"
					
					
				* External finance variables *(.8)
						
					* Finance					*(.8a)
					do "1_8a_DataGeneration_Finance"
					
					* ODA						*(.8b)
					do "1_8b_DataGeneration_ODA"	
					
					* Resources					*(.8c)
					do "1_8c_DataGeneration_Resources"	
					
	
	* Collapse to 5 year panel    
	
		* Main dataset
		do "1_9_DataGeneration_CollapsePanel"
		
		* Alternative 5-year windows
		do "1_9b_DataGeneration_CollapsePanel_alternativeWindows"

	* Binning the data
	
	do "1_10_BinningData"

	 
	
 				
			
**** generate Figure (1)


	do "2_MainFigures"


****  generate Tables  (main paper)

	
	
	* Table 1
	do "3_Tables_1_Benchmark"	
	
	* Table 2
	do "3_Tables_2_Turnover"
	
	* Table 3
	do "3_Tables_3_CohesiveInstitutions"
	
	* Table 4
	do "3_Tables_4_Conflict"
	
	* Table 5
	do "3_Tables_5_Conflict_civil"
	
	
	
 
	 
	
*   Appendix Tables and Figures 
	
		* Summary statistics/tables/validation of variables
			
			* Figures describing and validating dataset 						(Figures in Section 2.2) 
			do "4_1a_AppendixFigures_Dataset"				
			
			
 			* Figure validating deflator  										(Figures in  Section 2.3)
			do "4_1b_AppendixFigures_Figure1DifferentSamples" 

			
 			* Figure showing trade cost vs. trade taxation 						(Figures in  Section 2.4)			
			do "4_1c_TradeCostTradeTaxation"
			
			
			* Figure validating capacity measure with tax rates  				(Table in Section 2.5.2)
			do "4_1d_Taxrates"
			
			* Figure validating deflator  										(Figures in 2.5.2)
			do "4_1e_AppendixFigures_DeflatorComparison"			
			
			
			* Estimates validating access measures								(Table in Section 3.4)
			do "4_1f_AppendixTables_ValidationAccessMeasures"
			
			
			* Table summary statistics											(Table 4.1  in Section 4)
 			do "4_2a_SummaryStats"
			
			
			* Table growth rates												(Table 4.2  in Section 4)
 			do "4_2b_AppendixTable_GrowthRates"
			
			
			
	* Robustness regressions (Benchmark)
	
			* Changing window sizes												(Figures in Section 5.4)
			do "4_3e_AppendixTables_RotationWindows_graphics_6SPEC"				
			
	
	
			* Annual vs. 5-year window Benchmark 								(Figures in Section 5.1)
			do "4_3a_AppendixTables_annualvsbenchmark_6SPEC.do"
		
		
			* Specification in levels 											(Table  in Section 5.2)
			do "4_3b_Levels"
	
	
			* Benchmark sample 													(Table Table 5.2 in Section 5.3)
			do "4_3c_AppendixTable_BenchmarkSample"
			
			
			* Controls 															(Table Table 5.3 in Section 5.3)
			do "4_3d_AppendixTable_BenchmarkControls"
			
			
			* Alternative democracy measures 									(Figures in Section 5.5)
			do "4_3f_AppendixTables_AlternativeDemocracyIndices_6SPEC"
			
			* Alternative aid measures											(Table 5.4 in Section 5.6)
			do "4_3g_AppendixTable_AlternativeAidMeasures"						
			
			* Alternative resource measures										(Table 5.5 in Section 5.6)
			do "4_3h_AppendixTable_AlternativeResources"
			
			* Alternative samples resources										(Table 5.6 in Section 5.6)
			do "4_3i_AppendixTable_ResourcesSamples"
 			
			*  Additional result on Leader turnover 							(Table in Section 5.7)		  
			do "4_3j_AppendixTables_Turnover_Leader"
 
			
		
			
	
	
	
	
	
