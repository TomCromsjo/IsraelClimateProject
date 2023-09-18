**********************************************************
* create distance matrix between stations and localities *
**********************************************************
version 15

*command: create_dist_matrix
program define sort_closest
	args type num_stations
	forvalues i = 1/`num_stations' { // for number of stations defined in run_weather
		gen min_`type'`i'_name = ""
		egen double min_`type'station`i' = rowmin(*`type') 
		ds *`type'
		gen count = 0
		foreach varname in `r(varlist)' {
			replace count = count + 1 if `varname' ==  min_`type'station`i'
			replace min_`type'`i'_name = "`varname'" ///
			if (`varname' ==  min_`type'station`i') & (count == 1)
			replace `varname' = .  ///
			if (`varname' ==  min_`type'station`i') & (count == 1)
		}
		drop count
	}
end

*body:

use "$processed_path\station_data" , clear //import station dataset

*change itm axes to 100 meter resolution 
foreach ax in x y{
replace itm_`ax' = itm_`ax'/100
replace itm_`ax' = round(itm_`ax')
}
tostring itm_x itm_y station_id, replace 
gen coordinates= itm_x +itm_y  //create 8 digit itm coordinates 

*create unique identifier for each station
gen id_and_type = "s"+station_id + substr(station_type,1,2)
keep coordinates id_and_type

*create a wide dataset of stations and coordinates
//set trace off 
levelsof id_and_type, local(stations) // creates list of all stations

foreach station in  `stations' { // loop over stations
 levelsof coordinates if id_and_type == "`station'", local(coordinates) //create local with the coordinates of the stations
 gen `station' = `coordinates' // create variable with same name as station, and coordinate as value 
}
keep s* //keep only station-variables
tempfile station_coordinates 
count 
local expand = $yeshov_count -`r(N)' + 1
expand `expand' in `r(N)'
save `station_coordinates', replace //save station list as temp-file

*import localities
use "${processed_path}\yeshov_list" ,clear
tostring coordinates , replace 
drop year 
merge 1:1 _n using `station_coordinates' 

*create distance matrix 
gen y_itm_x = substr(coordinates,1,4)
gen y_itm_y = substr(coordinates,5,4)

*calculate distances
foreach var of varlist s* {
	gen s_itm_x = substr(`var',1,4)
	gen s_itm_y = substr(`var',5,4)
	destring y_itm_x - s_itm_y , replace 
	gen delta_x =  y_itm_x - s_itm_x
	gen delta_y =  y_itm_y - s_itm_y
	destring `var' , replace
	replace `var' = sqrt((delta_x)^2+(delta_y)^2)
	drop s_itm_x  - delta_y
}


*generate num_stations shortest distances
set trace on
if "$num_stations" == "max" {
	sort_closest cl $cl_num
	sort_closest ra $ra_num
}
else{
	foreach type in cl ra {
		sort_closest `type' $num_stations
	}
}

keep yeshov_name yeshov_code_cbs coordinates height min_*
save "$processed_path\distance_matrix" , replace 



/*
program define sort_closest
	args type num_stations
	gen name = ""
	gen dist =.
	ds *`type'
	local station_list = "`r(varlist)'"
	local sl_size = wordcount("`station_list'")
	
	forvalues i = 1/`num_stations' { // for number of stations defined in run_weather
		gen min_`type'`i'_name = ""
		egen double min_`type'station`i' = rowmin(*`type') 
		
		forvalues j =  1/`sl_size' {
			replace 
			replace min_`type'`i'_name = "`varname'" if `varname' ==  min_`type'station`i'
			replace `varname' = . if `varname' ==  min_`type'station`i'
		}
	}
    drop name dist
end
*/

