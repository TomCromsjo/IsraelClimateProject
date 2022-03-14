*create yeshov dataset
local namelist "yeshov_name yeshov_code_cbs height coordinates"

capture program drop rename_save 
program define rename_save 
syntax namelist, year(integer) sheet(string) format(string)

	local englist "yeshov_name yeshov_code_cbs height coordinates"

	import excel "${locality_path}\bycode`year'.`format'", sheet("`sheet'") firstrow clear
	forvalues i = 1/4{
		rename `:word `i' of `namelist'' `:word `i' of `englist''
	}
	keep `englist'
	gen year = `year' 

	save processed\yeshov_list`year', replace 
	
end
//set trace on 

rename_save שםיישוב סמליישוב גובהממוצע קואורדינטות ,year(2020) sheet("קובץ יישובים 2020") format("xlsx")
rename_save שםיישוב סמליישוב גובהממוצע נקודתציוןמרכזית ,year(2010) sheet(2010) format("xls")
rename_save שםיישובמלא סמליישוב גובהבמטרים קואורדינטות ,year(2003) sheet("by code") format("xls")


replace coordinates = subinstr(coordinates," ","",.) 
destring coordinates, replace 

merge 1:1 yeshov_code using "processed\yeshov_list2010", ///
keepusing(`namelist' year) nogenerate update
drop if coordinates > 1000000000

merge 1:1 yeshov_code using "processed\yeshov_list2020", ///
keepusing(`namelist' year) update

drop if coordinates<10000000 | coordinates ==. //removes coordinates with less than 8 digits

*turn 2020 coordinates to 4 digit format


tostring coordinates , replace 
local if "if _merge == 2"
local s 1
foreach ax in x y{
gen itm_`ax' =  substr(coordinates, `s' , 5) `if' 
destring itm_`ax'  , replace
replace itm_`ax' = itm_`ax'/10
replace itm_`ax' = round(itm_`ax')
tostring itm_`ax'  , replace
local s = `s' + 5
}
 
replace coordinates = itm_x +itm_y `if' 
drop _merge itm_*

save "processed\yeshov_list" ,replace

foreach year of numlist 2003 2010 2020 {
erase "processed\yeshov_list`year'.dta"
}



