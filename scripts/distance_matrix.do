clear all
use "processed\station_data" , clear

foreach ax in x y{
replace itm_`ax' = itm_`ax'/100
replace itm_`ax' = round(itm_`ax')
}

tostring itm_x itm_y station_id, replace 
gen id_and_type = "s"+station_id + substr(station_type,1,2)
gen coordinates= itm_x +itm_y 
keep coordinates id_and_type
levelsof id_and_type, local(levels)

foreach level in  `levels'{
 levelsof coordinates if id_and_type == "`level'", local(coordinates)
 gen `level' = `coordinates' 
}
keep s*
tempfile station_coordinates 
save `station_coordinates', replace 
use "processed\yeshov_list" ,clear
tostring coordinates , replace 
drop year
merge 1:1 _n using `station_coordinates'
drop if _merge == 2
drop _merge


*create distance matrix 

local obs = _N 
gen y_itm_x = substr(coordinates,1,4)
gen y_itm_y = substr(coordinates,5,4)

set trace on 
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


*generate 3 shortest distances

foreach type in ev cl ra {

	forvalues i = 1/3 {
		gen min_`type'`i'_name = ""
		egen double min_`type'station`i' = rowmin(*`type')
		ds *`type'
		foreach varname in `r(varlist)' {
		//dis `varname'
			replace min_`type'`i'_name = "`varname'" if `varname' ==  min_`type'station`i'
			replace `varname' = . if `varname' ==  min_`type'station`i'
		}
	}
}

keep yeshov_name yeshov_code_cbs coordinates height min_*
save "processed\distance_matrix" , replace 





