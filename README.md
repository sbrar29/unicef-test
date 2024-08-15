# unicef-test

# Steps:
- 1) Run `profile_unicef-test.do`: Stata script to set up profile BEFORE running remaining do.files
- 2) Run `run_unicef-test.do`: Stata script to generate CSV files and outputs

# Task 1: Population-Weighted Coverage Calculation (2018-2022)

## Description
This repository contains Stata code to calculate the population-weighted coverage for antenatal care (ANC) and skilled birth attendance (SBA) for the period 2018-2022.

## Files
- `012_run.do`: Under 01_task1 > 012_programs - Stata script to calculate population-weighted coverage for ANC and SBA for on-track and off-track countries.
- `pop_wgt_cvg_avg.dta`: Under 01_task1 > 011_rawdata - Resulting Stata dataset with the calculated coverage.
- `anc_sba_pop_wgt_cvg_avg.xlsx`: Under 01_task1 > 013_outputs - XLSX file with the results
- `anc4.png`: Under 01_task1 > 013_outputs - ANC4 visualization
- `sba.png`: Under 01_task1 > 013_outputs - SBA visualization

# Task 2: Data Perspective on the evolution of education for 4- to 5-year-old children 

## Description
This repository contains Stata code to analyze data from Zimbabwe (MICS 2019) and generate a Data Perspective.

## Files
- `022_run.do`: Under 02_task2 > 022_programs - Stata script to analyze data and generate table and graph.
- `pop_wgt_cvg_avg.dta`: Under 02_task2 > 021_rawdata - Resulting Stata dataset
- `table_1.doc`: Under 02_task2 > 023_outputs - Summary statistics table (editable in Word)
- `sum_stats.png`: Under 02_task2 > 023_outputs - Summary statistics table
- `results.csv`: Under 02_task2 > 023_outputs - Results output for month-by-month analysis
- `graph.png`: Under 02_task2 > 023_outputs - Month by month visualization
- `data_perspective.pdf`: Under 02_task2 > 023_outputs - Data Perspective PDF


