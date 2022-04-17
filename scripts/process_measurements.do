***********************************************************
* create aggregate climate datasets of daily mesurements  *
***********************************************************
version 17
clear all

*commands:
*count_measurements: count number of stations that mesured metric in each date
 program define count_measurements
	syntax varlist using , path(string)
	collapse (count) `varlist', by(date)
	merge 1:1  date `using'  
	foreach metric in `varlist'{
		rename `metric' `metric'_obs
		replace `metric'_obs = 0 if _merge == 2
	}
	drop _merge
	save "`path'" , replace 
 end
 
*body:
*creates dates dataset:
set obs 10950 
gen date = "01/01/1990"
gen numdate = date(date, "DMY")
replace numdate = numdate + _n - 1 
drop date
rename numdate date
tempfile dates_file
save "`dates_file'" , replace
//save ${processed_path}\dates_file, replace 

*hourly wind data
import delim "${climate_path}\new_isr_gnd_obs_web.csv", clear
keep if year>1989 & year< 2021
keep wind_spd stn_num day year month
rename stn_num station_id
rename wind_spd wind_speed  
label var wind_speed "Wind speed (m/s)"
numdate daily date = month day year ,pattern("MDY")
recast long date
collapse (mean) wind_speed , by(station_id date)
gen year = year(date)
gen month = month(date)
gen day = day(date)
tempfile daily_wind_averages wind_count
save `daily_wind_averages', replace
set trace on 
//count_measurments wind_speed using "`dates_file'" , save("`wind_count'")
count_measurements wind_speed using "`dates_file'", path("`wind_count'")
	
*Other climate variables
import delim "${climate_path}\new_isr_daily_data_web.csv", clear
keep if year>1989 & year< 2021
keep stn_num year month day tmp_air_max tmp_air_min tmp_grass_min rpr_*

*rename variables
rename stn_num station_id
numdate daily date =  month day year ,pattern("MDY")
recast long date
rename tmp_air_max max_temp
rename tmp_air_min min_temp 
rename tmp_grass_min min_ground_temp
rename rpr_lightening rpr_lightning

*label variables
label var max_temp "Maximum temperature (celcius)"
label var min_temp "Minimum temperature (celcius)"
label var min_ground_temp "Minimum ground temperature (celcius)"

*rename and label variables that start with rpr
ds rpr_*
foreach varname in `r(varlist)' {
	local newvarname = subinstr("`varname'","rpr_","",.)
	rename `varname' `newvarname'
	label var `newvarname' "1 if `newvarname' 0 if no `newvarname'"
}
tempfile daily_climate_averages temp_count
save `daily_climate_averages', replace
count_measurements max_temp min_temp using "`dates_file'" , path("`temp_count'")

*rain 
**# Bookmark #1
import delim "${climate_path}\new_isr_rain_daily_web.csv", clear
keep if year>1989 & year< 2021
rename stn_num station_id
numdate daily date =  month day year ,pattern("MDY")
drop time_obs
recast long date
rename rain_06_next rain_amount

label var rain_amount "Daily rain amount (mm)"

*create merged dataset of daily observations
merge 1:1 station_id date using `daily_wind_averages'
drop _merge
merge 1:1 station_id date using `daily_climate_averages'
drop _merge

*create metrics of extreme weather: 
//local knot_to_ms 0.51444
//local ext_wind_speed 30*`knot_to_ms'
keep station_id wind_speed rain_amount max_temp min_temp date year month day

save "${processed_path}\daily_weather" ,replace

*create dataset of number of observations per day and metric
tempfile rain_count
count_measurements rain_amount using "`dates_file'" , path("`rain_count'")
merge 1:1 date using "`wind_count'" , nogen
merge 1:1 date using "`rain_count'" , nogen 
merge 1:m date using "${processed_path}\daily_weather"  , nogen keepusing(year month day)
save ${processed_path}\measurement_count , replace 

/*
collapse (sum) rain_amount wind_speed max_temp min_temp, by(date)
tempfile collapsed
save "`collapsed'" , replace
drop _all 
set obs 10950 
gen date = "01/01/1990"
gen numdate = date(date, "DMY")
replace numdate = numdate + _n - 1 
drop date
rename numdate date

*create monthly metrics 

/*
bysort month year station_id: egen missing_days_wind = count(wind_speed) if mi(wind_speed)
bysort month year station_id: egen missing_days_raim = count(rain_amount) if mi(rain_amount)
bysort month year station_id: egen missing_days_heat = count(max_temp) if mi(max_temp)
bysort month year station_id: egen missing_days_freeze = count(max_temp) if mi(min_temp)

collapse (count) ext_* missing_days*  , by(month year station_id)
save "${processed_path}\monthly_weather" ,replace

day month year

foreach metric of $metrics{ // wind, rain, heat and freeze
	gen ext_`metric' =  .
}

replace ext_wind = (wind_speed>`ext_wind_speed') & !mi(ext_wind)
gen ext_rain = (rain_amount>100) & !mi(ext_wind)
gen ext_heat = (max_temp>30) & !mi(ext_wind)
gen ext_freeze = (min_temp<2) & !mi(ext_wind)
