**************************
* create station dataset *
**************************
version 15

*commands: 
*to_date: convert dates from ims station spreadsheet to stata dates.
capture program drop to_date
program to_date
	args date_var
	capture confirm string var `date_var' // returns _rc == 0  if date_var is a string
	if _rc==0 { //if date_var is a string, changes it to stata date format
		gen `date_var'_s = date(`date_var', "MDY")
		drop `date_var'
		rename `date_var'_s `date_var'
		format `date_var' %td //puts date mask on date
	}
end

*format_station_info: recives a station_type and creates a dataset of all stations from that type.
capture program drop format_station_info
program format_station_info
	args station_type

	*translate variable names to english
	rename שםהתחנה station_name
	rename מספרהתחנה station_id
	rename שםהתחנהבלועזית eng_station_name
	rename סוגהתחנה station_type
	rename קואורדינטותברשתישראלהחדשה itm_x
	rename F itm_y
	rename קואורדינטותגיאוגרפיות utm_x
	rename H utm_y
	rename גובהמעלפניהיםמטר height
	rename תאריךהפתיחה opening_date
	rename תאריךהסגירה closing_date
	rename תקופתזמינותהנתונים available_period

	*drop first variable
	drop if _n==1

	*remove degree sign from coordinates 
	replace utm_x= substr(utm_x , 1, strlen(utm_x) - 2)
	replace utm_y= substr(utm_y , 1, strlen(utm_y) - 2)
	replace itm_x= substr(itm_x , 1, 6)
	replace itm_y= substr(itm_y , 1, 6)

	*destring coordinates and station ID
	destring itm_x itm_y utm_x utm_y station_id , replace

	*create  variables for station type (evaporation/rain/climate) and binary variable if station is automatic
	gen automated = (station_type == "אוטומאטית")
	replace station_type = "`station_type'"

	*format dates
	to_date opening_date
	to_date closing_date

	*Remove empty observations
	drop if station_id == .
end

************

*code: 

*set paths:
global station_info_path "${MyProject}\raw_data\meta_data_archiveIMS_0.xls"
global processed_station_data "${MyProject}\processed\station_data.dta"

*Import rain station information
import excel "$station_info_path", sheet("תחנות גשם") firstrow clear //Rain Stations
format_station_info "rain station"
drop  M-AS // drop empty columns importated from station spreadsheet
save "$processed_station_data" , replace

*Import climate station information
import excel "$station_info_path", sheet("תחנות אקלים") firstrow clear //Climate stations
format_station_info "climate station"
drop  M-AS // drop empty columns importated from station spreadsheet
append using "$processed_station_data"
save "$processed_station_data" , replace

*Import evaporation station information
import excel "$station_info_path", sheet("תחנות התאדות") firstrow clear //Evaporation stations
gen תקופתזמינותהנתונים = ""
format_station_info "evaporation station"
drop L-R // drop empty columns importated from station spreadsheet
append using "$processed_station_data"

*remove stations closed before 1990
keep if mi(closing_date) | closing_date>date("31dec1989","DMY")
drop if  station_type == "evaporation station"

*drop duplicates
duplicates drop station_id , force 

*create global for number of stations 
count if station_type == "climate station"
global cl_num = `r(N)'
count if station_type == "rain station"
global ra_num = `r(N)'

*merging stations with same coordinates:

*save station dataset
save "$processed_station_data" , replace
