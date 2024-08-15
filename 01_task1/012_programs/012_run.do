*==============================================================================*
* UNICEF P3 test
*
* TASK 1: calculates population-weighted coverage of health services (ANC & SBA)
* 		  for countries categorized as on-track and off-track in achieving
* 		  under-5 mortality targets as of 2023
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

*-------------------------------------------------------------------------------


*-------------------------------------------------------------------------------
* Sub-tasks for this task
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
* [STEP 1] Import and clean rawdata from CSVs hosted in repo into DTAs and prepare files for merging

	* Directory where to find the CSVs (from the repo)
	global input_dir "${clone}/01_task1/011_rawdata/hosted_in_repo"
  
	* Directory where to save the newly created DTAs
	global output_dir "${clone}/01_task1/011_rawdata"

	* Directory where to save outputs
	global save_output "${clone}/01_task1/013_outputs"
	
	/**************************
			ANC SBA Data 
	**************************/
 
	* Import the ANC and SBA CSV data file downloaded from the UNICEF global data warehouse
	import delimited using "${input_dir}/anc_sba_countries.csv", clear

	* Save file
	save "${output_dir}/anc_sba.dta", replace

	*Clean file
		** Drop unnecessary vars
		drop dataflow sexsex unit_multiplierunitmultiplier - ref_periodreferenceperiod coverage_timetheperiodoftimeforw agecurrentage
		
		** Rename variables so that shorter and easier to work with
		rename ref_areageographicarea country
		rename indicatorindicator indicator
		rename time_periodtimeperiod year
		rename obs_valueobservationvalue value
		
		** Separate ISO3 and country 
		split country, parse(: )
		drop country
		rename country1 iso3
		rename country2 country
		
			*** In case of any extra spaces, trim iso3 and country vars
			replace iso3 = trim(iso3)
			replace country = trim(country)
		
		** Replace indicator value labels so that shorter and easier to work with
		replace indicator = "anc4" if strpos(indicator, "ANC")
		replace indicator = "sba" if strpos(indicator, "SAB")
		
		** Generate "latest" variable and keep only latest year for countries with multiple years of data
		sort country indicator year
		bysort country indicator (year): gen latest = _n == _N
		keep if latest == 1
		drop latest
		
		** Order variables
		order iso3 country year indicator value
		
	*Save file
	save "${output_dir}/anc_sba.dta", replace	

	/**************************
		WPP 2022 Data 
	**************************/
 
	* Import the WPP projected 2022 file, which includes births
	clear
	import delimited using "${input_dir}/wpp_proj.csv", varnames(13) clear

	* Save file
	save "${output_dir}/wpp_proj.dta", replace

	*Clean file
		** Keep WPP data only at country level
		keep if strpos(type, "Country")
		
		** Keep WPP data only for year 2022
		drop if year > 2022
		
		** Drop unnecessary vars
		keep regionsubregioncountryorarea iso3alphacode year birthsthousands
		
		** Rename variables so that shorter and easier to work with
		rename regionsubregioncountryorarea country
		rename iso3alphacode iso3
		rename birthsthousands births
		
		** Clean and update births variable and values - e.g. space is used for thousands separator
			*** Trim births var in case of any random spaces
			replace births = trim(births)
		
			*** Generate births_2 variable without any space for thousands separator
			gen births_2 = subinstr(births, " ", "", .)
			
			*** Destring births_2
			destring births_2, replace		//Note: seems that there are nonnumeric values
				tab births_2, miss
				drop if births_2 == "..."
			destring births_2, replace		
			
			*** Multiply births by 1000 for full value (var was births thousands)
			replace births_2 = births_2 * 1000
			
			*** Drop births and rename births_2
			drop births
			rename births_2 births
		
	*Save file
	save "${output_dir}/wpp_proj.dta", replace	
	
	
	/**************************************
		On track and off track countries
	***************************************/
	
	* Import the on/off track file
	clear
	import delimited using "${input_dir}/on_off_track_countries.csv", varnames(1) clear

	* Save file
	save "${output_dir}/status.dta", replace
	
	* Rename variables so that they match for merging files
	rename officialname country
	rename iso3code iso3
	rename statusu5mr status
	
	* Update value labels for "status" var to match U5 mortality classifications
	replace status = "on-track" if status == "Achieved"	|	///
								   status == "On Track"
	replace status = "off-track" if strpos(status, "Acceleration")
	
	* Save file
	save "${output_dir}/status.dta", replace
	
*-------------------------------------------------------------------------------	

* [STEP 2] Merge all 3 files from [STEP 1] - anc_sba.dta, wpp_2022.dta, status.dta

	* Merge anc_sba with wpp_2022 
	clear 
	use "${output_dir}/anc_sba.dta"
	
	merge m:1 iso3 using "${output_dir}/wpp_proj.dta"
	drop if _merge == 2
	drop _merge
	
	* Merge with status file (on/off track
	merge m:1 iso3 using "${output_dir}/status.dta"
	drop if _merge != 3
	drop _merge

	* Save file
	save "${output_dir}/combined.dta", replace

*-------------------------------------------------------------------------------	

* [STEP 3] Calculate weighted coverage for ANC and SBA

	* Generate weighted coverage variable "wgt_cvg"
	gen wgt_cvg = (value / 100) * births

	* Sum up data for weighted coverage and births by on vs off track countries
	collapse (sum) wgt_cvg births, by(indicator status)	

	* Generate population-weighted coverage average "wgt_cvg_avg"
	gen wgt_cvg_avg = (wgt_cvg / births) * 100

	* Drop variables that aren't necessary for visualizations/reporting
	drop births wgt_cvg

	* Save population weighted coverage average
	save "${output_dir}/pop_wgt_cvg_avg.dta", replace
	
	*Export results to CSV file 
	export excel using "${save_output}/anc_sba_pop_wgt_cvg_avg.xlsx", firstrow(variables) replace
	
*-------------------------------------------------------------------------------	

* [STEP 4] Create visualization comparing population-weighted coverage estimates

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
		graph export "${save_output}/anc4.png", as(png) replace

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
		graph export "${save_output}/sba.png", as(png) replace

	
	
*-----------------------------------------------------------------------------
