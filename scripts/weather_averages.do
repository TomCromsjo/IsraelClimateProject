******************************************************
* create daily averages for Israel between 1990-2020 *
******************************************************
version 17
frame change default
set varabbrev on

*commands:
*merge_weather: merge climate data from daily_weather
program define merge_weather 
	syntax varlist , metric(string) station_type(string) STARTing_value(integer)
	local i `starting_value'
	foreach var of varlist `varlist' { // for each of the closest stations to the locality
	
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
	drop min_`station_type'* 
end

*find_nearest:
program define find_nearest
	args m_size
	
	tempvar count
	gen `count' = 10
	forvalues i = 11/`m_size' {
		replace `count' = `count' +1 if !mi(wind_speed`i')
		forvalues j = 11/`m_size'{
			replace wind_speed`j' = wind_speed`i' if `count' == `j' & !mi(wind_speed`i')
			replace wind_speed_min_cl`j'_name = wind_speed_min_cl`i'_name if `count' ==  `j' & !mi(wind_speed`i')
			replace wind_speed_min_clstation`j' = wind_speed_min_clstation`i' if `count' == `j' & !mi(wind_speed`i')
			if `j' != `i' {
				replace wind_speed`i' =. if `count' == `j' & !mi(wind_speed`i') 
				replace wind_speed_min_cl`i'="" if `count' ==  `j' & !mi(wind_speed`i') 
				replace wind_speed_min_clstation`i'=. if `count' == `j' & !mi(wind_speed`i') 
			}
		}	
	}
end

*body:

* creates one observation for every day between 1990-2020
use "$processed_path\yeshov_list" , clear //import locality list
keep yeshov_code_cbs yeshov_name
expand 10957  // create a copy of the locality for each day
gen date = "01/01/1990"
gen numdate = date(date, "DMY")
bysort yeshov_code_cbs: replace numdate = numdate + _n - 1 //label observations with succeeding dates
format numdate %td
drop date
rename numdate date

*keep only observations for relevant localities
gen year = year(date)
merge m:1 yeshov_code_cbs year using "$processed_path\insured_localities" , keepusing(yeshov_code) keep(3) nogen 
//erase "$processed_path\insured_localities.dta"
 
* merge distance_matrix.dta 
global matched 0
global m_size 13 
global N = _N
tempfile completed_dates
tempfile new_dates
local station_type cl 
set trace on 
local metric "wind_speed"
local type "cl"


while $matched != 5 {
	if $m_size == 13 {
		local starting_value 11
		merge m:1 yeshov_code_cbs using "${processed_path}\distance_matrix"  ///
		, keepusing(min_cl11_name - min_clstation$m_size) nogen keep(3)	
		merge_weather min_`station_type'*_name , metric("wind_speed") ///
		station_type("cl")  start(`starting_value')
		local starting_value = 14
		
	}
	else {
		dis `starting_value'
		merge m:1 yeshov_code_cbs using "${processed_path}\distance_matrix"  ///
		, keepusing(min_cl${m_size}_name - min_clstation$m_size) nogen keep(3)	
		merge_weather min_`station_type'`starting_value'_name , metric("wind_speed") ///
		station_type("cl")  start(`starting_value')
		local starting_value = `starting_value' +1
	}
	find_nearest $m_size
	gen full = (!mi(wind_speed11) & !mi(wind_speed12) & !mi(wind_speed13))
	preserve
	keep if full == 1
	gen `metric'_average = (`metric'_min_`type'station11 * `metric'11 ///
	+`metric'_min_`type'station12 *`metric'12+`metric'_min_`type'station13 * `metric'13)/ ///
	(`metric'_min_`type'station11+`metric'_min_`type'station12+`metric'_min_`type'station13)
	keep yeshov_code_cbs yeshov_code yeshov_name date year `metric'_average 
	if $m_size == 13 {
		save "$processed_path\weather_averages" , replace
	}
	else {
		save "`new_dates'" , replace
		use "$processed_path\weather_averages" , clear
		append using "`new_dates'"
		save "$processed_path\weather_averages" , replace
	}
	restore
	count if full == 1
	global matched = $matched + `r(N)'
	//global matched = $matched + 1
	dis $matched
	drop if full == 1
	//forvalues i = ${m_size}(-1)1 {
		//count if !mi(wind_speed`i')
		//if `r(N)' == 0{
			//drop wind_speed`i' wind_speed_min_cl`i'_name wind_speed_min_clstation`i'
			//local var_number `i'
		//}
	//}
	drop full

}	

