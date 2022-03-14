capture program drop to_date
program to_date
args date_var
capture confirm string var `date_var'
if _rc==0 {
gen `date_var'_s = date(`date_var', "MDY")
drop `date_var'
rename `date_var'_s `date_var'
}
end

capture program drop format_station_info
program format_station_info
args station_type

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
drop if _n==1
replace station_type = "`station_type'"
gen automated = (station_type == "אוטומאטית")
replace utm_x= substr(utm_x , 1, strlen(utm_x) - 2)
replace utm_y= substr(utm_y , 1, strlen(utm_y) - 2)
replace itm_x= substr(itm_x , 1, 6)
replace itm_y= substr(itm_y , 1, 6)

destring station_id, replace
destring itm_x, replace
destring itm_y, replace
destring utm_x, replace 
destring utm_y , replace

*format dates

to_date opening_date
to_date closing_date

*Remove empty observations
drop if station_id == .
end

*Import station data:
global station_info_path "raw data\meta_data_archiveIMS_0.xls"

//set trace on
*Import rain station information
import excel "$station_info_path", sheet("תחנות גשם") firstrow clear //Rain Stations
format_station_info "rain station"
drop  M-AS
save "processed\station_data.dta" , replace

*Import climate station information
import excel "$station_info_path", sheet("תחנות אקלים") firstrow clear //Climate stations
format_station_info "climate station"
drop  M-AS
append using "processed\station_data.dta"

save "processed\station_data.dta" , replace

*Import evaporation station information
import excel "$station_info_path", sheet("תחנות התאדות") firstrow clear //Evaporation stations
gen תקופתזמינותהנתונים = ""
format_station_info "evaporation station"
drop L-R
append using "processed\station_data.dta"

save "processed\station_data.dta" , replace
