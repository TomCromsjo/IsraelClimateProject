*************************
* create yeshov dataset *
*************************
version 15

*commands:
*rename_save: imports cbs locality lists and renames their variables
capture program drop rename_save 
program define rename_save 
syntax namelist, year(integer) sheet(string) format(string)

	local englist "yeshov_name yeshov_code_cbs height coordinates" //list of english translations of variables from the locality file.

	import excel "${locality_path}\bycode`year'.`format'", sheet("`sheet'") firstrow clear //import cbs locality file.
	forvalues i = 1/4{
		rename `:word `i' of `namelist'' `:word `i' of `englist'' //rename the variables from the cbs locality file.
	}
	keep `englist' 
	gen year = `year' 
	save processed\yeshov_list`year', replace 
end

**********

*code:

local varlist "yeshov_name yeshov_code_cbs height coordinates" //the variable list that is kept from each locality file. 

*runs rename_save on the cbs localitiy spreadsheets. 
rename_save שםיישוב סמליישוב גובהממוצע קואורדינטות ,year(2020) sheet("קובץ יישובים 2020") format("xlsx")
rename_save שםיישוב סמליישוב גובהממוצע נקודתציוןמרכזית ,year(2010) sheet(2010) format("xls")
rename_save שםיישובמלא סמליישוב גובהבמטרים קואורדינטות ,year(2003) sheet("by code") format("xls")

*format coordinates
replace coordinates = subinstr(coordinates," ","",.) 
destring coordinates, replace 

*merges yeshov_list2010 and 2020 into yeshov_list2003
merge 1:1 yeshov_code using "processed\yeshov_list2010", ///
keepusing(`varlist' year) nogenerate update
drop if coordinates > 1000000000 //removes coordinates for places that aren't localities (with less than 8 digits)

merge 1:1 yeshov_code using "processed\yeshov_list2020", ///
keepusing(`varlist' year) update

drop if coordinates<10000000 | coordinates ==. //removes coordinates for places that aren't localities (with less than 8 digits, or missing)

*turn 2020 coordinates to 4 digit format
tostring coordinates , replace 
local if_2020 "if _merge == 2"
local position 1
foreach ax in x y{
	gen itm_`ax' =  substr(coordinates, `position' , 5) `if_2020' //extract longitude and latitude from coordinates
	destring itm_`ax'  , replace
	replace itm_`ax' = itm_`ax'/10
	replace itm_`ax' = round(itm_`ax')
	tostring itm_`ax'  , replace
	local position = `position' + 5
}
 
replace coordinates = itm_x +itm_y `if_2020' //creates 8 digit coordinates
drop _merge itm_* //drop -merge and itm coordinates

*save a locality list of all israeli localities that existed between 2003-2020
save "processed\yeshov_list" ,replace

*erase yearly yeshov lists
foreach year of numlist 2003 2010 2020 {
erase "processed\yeshov_list`year'.dta"
}



