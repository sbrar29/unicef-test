*==============================================================================*
*! UNICEF P3 test run

*! MASTER RUN: Executes all tasks sequentially
*==============================================================================*

* Check that project profile was loaded, otherwise stops code
cap assert ${unicef_test_profile_is_loaded} == 1
 
if _rc {
  noi disp as error "Please execute the profile initialization do in the root of this project and try again."
  exit 601
}

*-------------------------------------------------------------------------------
* Run all tasks in this project
*-------------------------------------------------------------------------------

* HIV
do "${clone}/00_master/012_programs/0122_stata/0123_hiv.do"


*-------------------------------------------------------------------------------
