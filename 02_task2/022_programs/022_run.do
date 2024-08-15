*==============================================================================*
* UNICEF P3 test
*
* TASK 2: Produce a data perspective (1-2 pages) on the evolution of education 
*		  for 4-5 year old children, showing how performance evolves by month
*==============================================================================*

*-------------------------------------------------------------------------------
* Setup for this task
*-------------------------------------------------------------------------------

	* Check that project profile was loaded, otherwise stops code
	cap assert ${unicef_test_profile_is_loaded} == 1
	if _rc != 0 {
	  noi disp as error "Please execute the profile_unicef-test.do in the root of this project and try again."
	  exit
	}

	* Directory where to find the CSV (from the repo)
	local input_dir "${clone}/02_task2/021_rawdata/hosted_in_repo"
  
	* Directory where to save the newly created DTAs
	local output_dir "${clone}/02_task2/021_rawdata"

	* Directory where to save outputs
	local save_output "${clone}/02_task2/023_outputs"
	
*-------------------------------------------------------------------------------


*-------------------------------------------------------------------------------
* Sub-tasks for this task
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* [STEP 1] Import and prepare ZWE U5 data from CSV hosted in repo and convert to DTA
 
	* Import the ANC and SBA CSV data file downloaded from the UNICEF global data warehouse
	import delimited using "`input_dir'/zwe_u5_interview.csv", clear

	* Convert interview_date and child_birthday to Stata date format
*	gen interview_date = date(interview_date, "YMD")		// seems interview_date var name is showing up weirdly (ïinterview_date)
	rename ïinterview_date interview_date
	
	gen r_interview_date = date(interview_date, "MDY")	
	gen r_child_birthday = date(child_birthday, "MDY")
		
		** Check if recoding was successful
		list interview_date r_interview_date child_birthday r_child_birthday in 1/20
	
		** Drop original date variables with Stata date format ones
		drop interview_date child_birthday
	
		* Rename Stata date format vars
		rename r_interview_date interview_date
		rename r_child_birthday child_birthday

		* Format the dates properly for display
		format interview_date %td
		format child_birthday %td
	
	* Calculate age in months (365 / 12 = 30.42)
	gen child_age_months = (interview_date - child_birthday) / 30.42
	
		* Convert age in months to integer (it's floating right now so not whole number)
		gen child_age_months_full = floor(child_age_months)
		drop if child_age_months_full == .
	
	* Recode EC6-15 variables so yes = 1 and no = 0 and dk == 99 EXCEPT EC10 AND EC14-15 (need to be reverse coded)
		** Recode EC6-9, EC11-13 variables so yes = 1 and no = 0 and dk == 99 
		foreach var in ec6 ec7 ec8 ec9 ec11 ec12 ec13 {
			recode `var' (1 = 1) (2 = 0) (8 = 0) (9=0), gen(r_`var')
		}
		
		** Reverse code EC10 AND EC14-15 
		foreach var in ec10 ec14 ec15 {
			recode `var' (1 = 0) (2 = 1) (8 = 0) (9=0), gen(r_`var')
		}

		** Check if the recoding was successful
		list ec6 r_ec6 ec10 r_ec10 in 1/10
		
		** Replace original variables with recoded values
		foreach var in ec6 ec7 ec8 ec9 ec10 ec11 ec12 ec13 ec14 ec15 {
			replace `var' = r_`var'
			drop r_`var'
		}

		** Check if replacing vars was successful
		list ec6 - ec15 in 1/10

	
*-------------------------------------------------------------------------------	

* [STEP 2] Generate composite indicators for different educational domains/areas and full ECDI-10

	/*****************************
		Literacy & Math (EC6-8) 
	******************************/
	* Generate composite literacy & math var (at least 2 of the 3 vars (EC6-EC8) are true)
	gen lit_num = 0
	replace lit_num = 1 if ((ec6 == 1) + (ec7 == 1) + (ec8 == 1)) >= 2
	
	/*****************************
			Physical (E9-10) 
	******************************/
	* Generate composite physical education var (at least 1 of the 2 vars (EC9-10) are true)
	gen phys_ed = 0
	replace phys_ed = 1 if ((ec9 == 1) + (ec10 == 1)) >= 1
	
	
	/*****************************
			Learning (EC11-12) 
	******************************/
	* Generate composite learning var (at least 2 of the 3 vars (EC11-12) are true)
	gen learn = 0
	replace learn = 1 if ((ec11 == 1) + (ec12 == 1)) >= 1
	
	/*****************************
		Socio-emotional (EC13-15) 
	******************************/
	* Generate composite socio-emotional var (at least 2 of the 3 vars (EC13-15) are true)
	gen soc_emot = 0
	replace soc_emot = 1 if ((ec13 == 1) + (ec14 == 1) + (ec15 == 1)) >= 2
	
	
	/*****************************
		ECDI-10 FULL SCORE
	******************************/
	*Generate full ECDI-10 score - at least 3 of the 4 domains on track
	gen ecdi_10 = 0
	replace ecdi_10 = 1 if ((lit_num + phys_ed + learn + soc_emot) >= 3)

	
	*Save file
	save "`output_dir'/zwe_u5.dta", replace

*-------------------------------------------------------------------------------	

* [STEP 3]  Analyze data and generate table for different educational domains/areas and full ECDI-10
	
	* Convert age in months to integer (it's floating right now so not whole number)
	gen child_age_months_full = floor(child_age_months)
	drop if child_age_months_full == .
	
	* Calculate proportions of children developmentally on track for different domains and full ecdi_10
	collapse (mean) lit_num - ecdi_10
	
	foreach var in lit_num phys_ed learn soc_emot ecdi_10 {
			replace `var' = round(`var' * 100, 0.1)
		}

	*Generate table and export	// formatted table in Word and saved as sum_stats.png in 023_outputs
	asdoc tabstat lit_num phys_ed learn soc_emot ecdi_10, columns(statistics) save(table)	
		

*-------------------------------------------------------------------------------	

* [STEP 4] Analyze data by age in months and generate table for different educational domains/areas and full ECDI-10

	* Calculate proportions of children developmentally on track for all domains
	clear
	use "`output_dir'/zwe_u5.dta"
	collapse (mean) lit_num - ecdi_10, by(child_age_months_full)
	
	
	












	* Create bar graph
		** ANC4
		graph bar (asis) wgt_cvg_avg if indicator == "anc4", over(status, label(angle(45))) ///
		blabel(bar, format(%9.0f) size(small) color(black)) ///
		ytitle("Population-Weighted Coverage (%)", size(medium)) ///
		ylabel(0(10)100, angle(0)) /// 
		title("ANC4: Population-Weighted Coverage Average by Status", size(medium) ///
		justification(center)) ///
		graphregion(color(white)) ///
		plotregion(margin(zero)) ///
		yline(0, lcolor(black) lwidth(medium)) ///
		bar(1, color(pink))

		** Save the graph
		graph export "`save_output'/anc4.png", as(png) replace

		* For SBA
		graph bar (asis) wgt_cvg_avg if indicator == "sba", over(status, label(angle(45))) ///
		blabel(bar, format(%9.0f) size(small) color(black)) ///
		ytitle("Population-Weighted Coverage (%)", size(medium)) ///
		ylabel(0(10)100, angle(0)) ///
		title("Skilled Birth Attendant: Population-Weighted Coverage by Status", size(medium) ///
		justification(center)) ///
		graphregion(color(white)) ///
		plotregion(margin(zero)) ///
		yline(0, lcolor(black) lwidth(medium)) ///
		bar(1, color(purple))

		* Save the graph
		graph export "`save_output'/sba.png", as(png) replace

			
*-----------------------------------------------------------------------------
