* creates one observation for evrey day between 1990-2020
use "processed\yeshov_list" , clear
keep yeshov_code_cbs yeshov_name
expand 10950  
gen date = "01/01/1990"
gen numdate = date(date, "DMY")
bysort yeshov_code: replace numdate = numdate + _n - 1
format numdate %td
drop date
rename numdate date

* merge distance_matrix.dta 
merge m:1 yeshov_code_cbs using "processed\distance_matrix" ,nogenerate

//preserve

set trace on 

* merge daily weather data from daily_weather.dta

local i 1

foreach var of varlist min*_name{

	gen station_id = `var'
	replace station_id = substr(station_id,2,strlen(station_id)-3 )
	destring station_id, replace 
	ds 
	local vars `r(varlist)'
	merge m:1 station_id date using "processed\daily_weather" , nogen
	drop if yeshov_code_cbs == .
	ds `vars', not
	foreach varname in `r(varlist)'{
		rename `varname' `varname'`i'
	}
	local ++i
	drop station_id 
} 
