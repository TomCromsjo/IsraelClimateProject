
*matches yeshov codes from insurance dataset to weather dataset*
use "${processed_path}\yeshov_list" ,clear
duplicates drop yeshov_code_cbs , force
duplicates tag yeshov_name , gen(tag)
drop if year == 2020 & tag == 1
keep yeshov_name yeshov_code_cbs 
tempfile yeshov_list
save "`yeshov_list'" , replace

use "$thesis\MixedLogitData_processed.dta", clear
duplicates drop year yeshov_code , force 
keep yeshov_code yeshov_name year sector_code sector_name

merge m:1 yeshov_name using "$locality_path\yeshov_dictionary" 
replace yeshov_name = cbs_yeshov_name if _merge == 3
drop _merge

merge m:1 yeshov_name using "`yeshov_list'", keepusing(yeshov_code_cbs)
sort yeshov_name

tempfile thesis_locals
save "`thesis_locals'" , clear


