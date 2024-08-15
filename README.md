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




