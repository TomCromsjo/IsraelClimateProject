******************************************************
* create daily averages for Israel between 1990-2020 *
******************************************************
version 17
clear all

*commands:
*merge_weather: merge climate data from daily_weather
program define merge_weather 
	args metric station_type
	local i 1
	foreach var of varlist min_`station_type'*_name { // for each of the closest stations to the locality
	
		*format station_id to match the format at station_data.dta
		gen station_id = `var'
		replace station_id = substr(station_id,2,strlen(station_id)-3 ) 
		destring station_id, replace 
	
		*merge weather-variables
		ds //create list of all variables
		local vars `r(varlist)' //rename variable-list "vars"
		merge m:1 station_id date using "${processed_path}\daily_weather" ///
		,keepusing(`metric') nogen 
		drop if yeshov_code_cbs == . // drop observations missing from 'using
		rename `metric' `metric'`i' // rename all variables from 'using'
		gen `metric'_`var' = `var'
		gen `metric'_min_`station_type'station`i' =  min_`station_type'station`i'
		local ++i
		drop station_id					
	}		
end

*replace_missing:  replaces missing climate measurement with the measurement from the closest non-missing station
capture  program drop replace_missing 
program define replace_missing 
	args metric station_type
	local runs 0
	ds `metric'*  //create list of weather variables 
	local word_count `word count of `r(varlist)''  // local macro of number of weather-variables
	local word_count = `word_count' - 1
	local counter 0
	while `counter' != 3 {
		forvalues n = 1/`word_count'{
			replace `metric'_min_`station_type'`n'_name = `metric'_min_`station_type'`n+1'_name ///
			if mi(`metric'`n')
			replace `metric'_min_`station_type'station`n' = `metric'_min_`station_type'station`n+1' ///
			if mi(`metric'`n')
			replace `metric'`n' = `metric'`n+1' ///
			if mi(`metric'`n') //replace 'var' by 'next_var' if 'var' is missing
		}
		ds `metric'*  //create list of weather variables
		forvalues i = 1/3 {
			qui misstable sum `: word `i' of `r(varlist)''
			if `r(N_eq_dot)' != 0 {
				local counter = `counter' + 1
			}
		}
		local ++runs
		if `runs' == 25 {
			local counter 3 //exit after 25 runs
		}		
	}
end

*body:

* creates one observation for every day between 1990-2020
use "${processed_path}\yeshov_list" , clear //import locality list
keep yeshov_code_cbs yeshov_name
expand 10950  // create a copy of the locality for each day
gen date = "01/01/1990"
gen numdate = date(date, "DMY")
bysort yeshov_code: replace numdate = numdate + _n - 1 //label observations with succeeding dates
format numdate %td
drop date
rename numdate date

* merge distance_matrix.dta 
merge m:1 yeshov_code_cbs using "${processed_path}\distance_matrix" ,nogenerate
set trace on 

* merge daily weather data from daily_weather.dta
set trace on
merge_weather wind_speed cl 
set trace on 
replace_missing wind_speed cl
merge_weather rain_amount ra 
, station_type("ra")

save "${processed_path}\yeshov_weather_daily" , replace

foreach metric in rain wind max_temp min_temp {	//loop over weather variables
	ds `metric'*  //create list of weather variables 
	local varlist `r(varlist)' // rename weather-variable-list varlist
	local words `: word count `varlist''' // local macro of number of weather-variables
	local var_count `words' - 1
	foreach i in `var_count'{
		local `var' `:word `i' of `varlist'' // define 'var' as the i'th weather-variable
		local `next_var' `:word `i+1' of `varlist'' // define 'next_var' as the variable after 'var'
		replace `var' = `next_var' if mi(`var')  
	}
} 
