capture program drop format_measurements
program define format_measurements
syntax namelist 
	
	local j=1
	foreach var of varlist _all {
		local eng_varname: word `j' of `namelist' 
		rename  `var' `eng_varname'
		local ++j
	}  

	foreach var of varlist _all {
		cap replace `var' = "" if `var' == "-"
		destring `var' , replace
		} 
		   
	gen numdate = date(date, "DMY")
	format numdate %td
	local datepos: list posof "date" in namelist
	drop date
	rename numdate date
	qui: ds 
	dis `:word `datepos' of r(varlist)'
	order date, before(`:word `datepos' of `r(varlist)'')
end

capture program drop merge_measurements
program define merge_measurements
syntax namelist , [drop(namelist) save(string)] labels(string asis) FIRST_obs(integer) ///
LAST_obs(integer) 

	use "processed\measurement_data_files.dta", clear
	forvalues i=`first_obs'/`last_obs' {
		use "processed\measurement_data_files.dta" in `i', clear	
		local f = dirname + "/" + filename
		import delimited "`f'", encoding(utf8) clear
		
		foreach var in `drop' {
		cap drop `var'
		}
		
		format_measurements `namelist'
		
		local j = 1
		foreach label in "`labels'"  {
			cap label var `:word `j' of `namelist'' "`label'" 
			local ++j
		}

		tempfile save`i'
		save "`save`i''", replace		 

	}

	local second_obs  = `first_obs' + 1
	use "`save`first_obs''", clear
	forvalues i=`second_obs'/`last_obs' {
		append using "`save`i''"
    }
	duplicates drop 
	cap save "`save'" , replace
end

*create file list

local directory_name "processed\csv utf8 files"
filelist, dir("`directory_name'") save("processed\measurement_data_files") replace 

*format data -
 

 *hail and temperature 
merge_measurements station_name station_id date max_temp min_temp min_ground_temp hail, ///
labels(" "" "" "maximum temperature (c)" "minimum temperature (c)" "minimum ground temperature (c)" ") ///
drop(v8) first(1) last(6) save("processed\merged_hail_temp")

 *daily rain 
set trace on 
merge_measurements station_name station_id date daily_rain_amount daily_rain_code, /// 
labels(" ""  "" "daily rain amount (mm)"  " ) ///
drop(v6 v7) first(7) last(12) 

duplicates drop station_id date, force 
save "processed\merged_daily_rain", replace 

 *hourly wind speed
merge_measurements station_name station_id date hour wind_speed, ///
labels (" "" ""  "hour (LST)"  "wind speed (m/s)" ") ///
drop(v6) first(13) last(16) save("processed\merged_hourly_wind")

*create average daily wind dataset
collapse  (mean) wind_speed, by(station_name station_id date)
rename wind_speed avg_daily_wind_speed 
save "processed\average_daily_wind" , replace 

*create merged dataset of daily observations
merge 1:1 station_id date using "processed\merged_hail_temp"
drop _merge
merge 1:1 station_id date using "processed\merged_daily_rain"
save "processed\daily_weather" ,replace



*/* notes - create merged dataset of monthly averages for each station

drop _merge

 
gen month = month(date)
gen year = year(date)

*rain 
foreach var of `namelist' {
	bysort year month: egen avg_monthly_`var' = mean(`var')
}
collapse 

/* notes -  Shaham Data
set trace on 
filelist, dir("raw data\meteorological data") save("processed\moag_data") replace maxdeep(2)
use "processed\moag_data.dta" , clear

         local obs = _N
		 dis `obs'
 forvalues i=1/`obs' {
	use "processed\moag_data.dta" in `i', clear
	
	local f = dirname + "/" + filename
    import excel "`f'", sheet("גיליון1")  clear 
	local station = B[1]
	gen station = "`station'"
	drop if _n == 1

	foreach var of varlist _all {
		local varname = `var'[1]
		local varname = subinstr("`varname'",".","",.)
		local units = `var'[2]
			  
		if "`units'" == "רc" {
			local units Celsius
			}
		rename `var'  `varname'
		label var `varname' "`varname' (`units')"
		}

	drop if _n < 3  // Drops first two rows
	 
	foreach var of varlist _all {
		replace `var' = "" if `var' == "NoData"
		if "`var'" != "Date" {
			destring `var' , replace 
			}
		} 
		   
	drop if Date == ""
	numdate daily date = Date ,pattern("MDY")
	drop Date
	rename `station' station
		   
           gen source = "`f'"
           tempfile save`i'
           save "`save`i''"		 

         }

         use "`save1'", clear
         forvalues i=2/`obs' {
           append using "`save`i''"
         }

import excel "C:\Users\owner\Dropbox\Thesis\Weather\raw data\meteorological data\2003\lahish2003.xls", ///
 sheet("גיליון1")  clear
 
 


** **
/* Sources filelist help 
