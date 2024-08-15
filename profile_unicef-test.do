*==============================================================================*
*! UNICEF Test - P3

*! PROFILE: Required step before running any do-files in this project
*==============================================================================*

quietly {

  /*
  Steps in this do-file:
  1) General program setup
  2) Define user-dependant path for local clone repo
  3) Check if can access UNICEF network path and UNICEF datalibweb
  4) Download and install required user written ado's
  5) Flag that profile was successfully loaded
  */

  *-----------------------------------------------------------------------------
  * 1) General program setup
  * This section is standard in UNICEF-Analytics repos
  * It is not required for the replication of the main results, but it is 
  * recommended to keep it to ensure that the code runs smoothly
  *-----------------------------------------------------------------------------
  
  clear               all
  capture log         close _all
  set more            off
  set varabbrev       off, permanently
  set emptycells      drop
  set maxvar          2048
  set linesize        135
  version             15
  global master_seed  123456789

  *-----------------------------------------------------------------------------
  * 2) Define user-dependant path for local clone repo
  *-----------------------------------------------------------------------------
  * Change here only if this repo is renamed
  * This is the name of the repo as it appears in GitHub
  * It is also the name of the folder that contains the local clone
  * This is also the name of the master run do-file as it appears in GitHub 
  *-----------------------------------------------------------------------------

  local this_repo     "unicef-test"
  * Change here only if this master run do-file is renamed
  local this_run_do   "run_unicef-test.do"

  * The remaining of this section is standard in UNICEF repos

  * One of two options can be used to "know" the clone path for a given user
  * A. the user had previously saved their GitHub location with -whereis-,
  *    so the clone is a subfolder with this Project Name in that location
  * B. through a window dialog box where the user manually selects a file


 *-----------------------------------------------------------------------------
  * Define user-dependant path for local clone repo
  *-----------------------------------------------------------------------------
  /* 
  * Add your username and path to the local clone repo below

    * <add your name>
      else if inlist("`c(username)'","<add your Windows login>") {
        global inputdata   "<add your personal folder path>"
      }

  * Add yourself by copying the code in lines 63 to 66, and pasting below to making sure 
  * to adapt your clone to your specific path, when needed.
  */
  *---------------------------------------------
  * past your user-dependant path for local clone repo below this line


    *<Paste your path here>

    * Joao Pedro Azevedo
      else if inlist("`c(username)'","azeve") {
        global inputdata   "<add your personal folder path>"
      }
	  
	* Ayca Donmez  
	  else if inlist("`c(username)'","adonmez") {
        global inputdata   "<add your personal folder path>"
      }
	  
	*Savvy Brar
	   else if inlist("`c(username)'","sbrar") {
        global inputdata   "C:/Users/`c(username)'/Github"
      }

	  else if inlist("`c(username)'","vrmehra") {
        global inputdata   "<add your personal folder path>"
      }
	  
  *---------------------------------------------
  * do not edit anything below this line unless you know what you are doing! 
  * if you are not sure, please ask for help!
  else {
    noi disp as error _newline "{phang}Your username [`c(username)'] could not be matched with any specified clone location. Please update the initialization lines in the master run do-file accordingly and try again.{p_end}"
    error 2222
  }

  * Method A - Github location stored in -whereis-
  *---------------------------------------------
  capture whereis github
  if _rc == 0 global clone "`r(github)'/`this_repo'"

  * Method B - clone selected manually
  *---------------------------------------------
  else {
    * Display an explanation plus warning to force the user to look at the dialog box
    noi disp as txt `"{phang}Your GitHub clone local could not be automatically identified by the command {it: whereis}, so you will be prompted to do it manually. To save time, you could install -whereis- with {it: ssc install whereis}, then store your GitHub location, for example {it: whereis github "C:/Users/AdaLovelace/GitHub"}.{p_end}"'
    noi disp as error _n `"{phang}Please use the dialog box to manually select the file `this_run_do' in your machine.{p_end}"'

    * Dialog box to select file manually
    capture window fopen path_and_run_do "Select the master do-file for this project (`this_run_do'), expected to be inside any path/`this_repo'/" "Do Files (*.do)|*.do|All Files (*.*)|*.*" do

    * If user clicked cancel without selecting a file or chose a file that is not a do, will run into error later
    if _rc == 0 {

      * Pretend user chose what was expected in terms of string lenght to parse
      local user_chosen_do   = substr("$path_and_run_do",   - strlen("`this_run_do'"),     strlen("`this_run_do'") )
      local user_chosen_path = substr("$path_and_run_do", 1 , strlen("$path_and_run_do") - strlen("`this_run_do'") - 1 )

      * Replace backward slash with forward slash to avoid possible troubles
      local user_chosen_path = subinstr("`user_chosen_path'", "/", "/", .)

      * Check if master do-file chosen by the user is master_run_do as expected
      * If yes, attributes the path chosen by user to the clone, if not, exit
      if "`user_chosen_do'" == "`this_run_do'"  global clone "`user_chosen_path'"
      else {
        noi disp as error _newline "{phang}You selected $path_and_run_do as the master do file. This does not match what was expected (any path/`this_repo'/`this_run_do'). Code aborted.{p_end}"
        error 2222
      }
    }
  }

  * Regardless of the method above, check clone
  *---------------------------------------------
  * Confirm that clone is indeed accessible by testing that master run is there
  * If not, abort
  *-----------------------------------------------------------------------------
  
  cap confirm file "${clone}/`this_run_do'"	
  if _rc != 0 {
    noi disp as error _n `"{phang}Having issues accessing your local clone of the `this_repo' repo. Please double check the clone location specified in the run do-file and try again.{p_end}"'
    error 2222
  }

  *-----------------------------------------------------------------------------
  * 3) Download and install required user written ado's
  *-----------------------------------------------------------------------------
  * Fill this list will all user-written commands this project requires
  * that can be installed automatically from ssc
  * Note: this list is not exhaustive, it is only the ones that are not
  * already installed in the standard Stata installation
  *-----------------------------------------------------------------------------
  *hoishapely

  local user_commands hoi catenate  wbopendata carryforward _gwtmean estout grqreg missings adecomp repest tablemat xsvmat alorenz filelist psmatch2 tknz schemepack

  * Loop over all the commands to test if they are already installed, if not, then install
  * Note: the command -which- is used to test if a command is already installed

  foreach command of local user_commands {
    cap which `command'
    if _rc == 111 ssc install `command'
  }

  * Set up the default graph scheme and font  
  set scheme white_tableau
  graph set window fontface "arial narrow"

  *-----------------------------------------------------------------------------
  * 4) Paths
  *---------------------------------------------------------------------------
  /// Set dependancies directories
      
    global gitdir         "${clone}"
	global savedir		  "${gitdir}/unicef-test"

  *-----------------------------------------------------------------------------
  * 5) Load other auxiliary programs, that are found in this Repo
  *-----------------------------------------------------------------------------
  
  * not needed

  *-----------------------------------------------------------------------------
  * 6) Check if can access UNICEF teams folder
  *-----------------------------------------------------------------------------
  * UNICEF teams folder is always the same for everyone, but may not be available
  * if the user is not access to a UNICEF computer
  * If not available, then use the local clone repo as the teams folder
  *-----------------------------------------------------------------------------

  cap cd "${teams}"

  * Both the UNICEF teams folder are only used to update the repo (task 04),
  * it is not a problem for users external to UNICEF attempting to replicate main results
  *-----------------------------------------------------------------------------
  * 5) Flag that profile was successfully loaded
  *-----------------------------------------------------------------------------
  * This flag is used to avoid running this profile again if the user runs
  * the master run do-file again
  *-----------------------------------------------------------------------------
  noi disp as result _n `"{phang}`this_repo' clone sucessfully set up (${clone}).{p_end}"'
  global unicef_test_profile_is_loaded = 1

  *-----------------------------------------------------------------------------

}
