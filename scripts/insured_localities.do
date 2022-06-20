**********************************************
*matches insurance dataset to weather dataset*
**********************************************
version 17
frame change default

*import and save the locality dictionary
import excel "$locality_path\yeshov_dictionary.xlsx", sheet("Sheet1") firstrow clear
save "$locality_path\yeshov_dictionary" , replace

*create yeshov_list temporary file 
use "${processed_path}\yeshov_list" ,clear
duplicates drop yeshov_code_cbs , force
duplicates tag yeshov_name , gen(tag)
drop if year == 2020 & tag == 1
keep yeshov_name yeshov_code_cbs 
tempfile yeshov_list
replace yeshov_name = "מודיעין מכבים רעות"  if yeshov_code_cbs == 1200 
replace yeshov_name = "סביון"  if yeshov_code_cbs == 587
replace yeshov_name = "קדימה-צורן"  if yeshov_code_cbs == 195
replace yeshov_name = "בנימינה-גבעת עדה" if yeshov_code_cbs == 9800
save "`yeshov_list'" , replace

*create a dataset of each locality and years in which it was insured at
use "$thesis\MixedLogitData_processed.dta", clear
duplicates drop year yeshov_code , force 
keep yeshov_code yeshov_name year sector_code sector_name

*translate the locality names in the insurance dataset to those in the cbs dataset
merge m:1 yeshov_name using "$locality_path\yeshov_dictionary" 
replace yeshov_name = cbs_yeshov_name if _merge == 3
drop if _merge == 2 | yeshov_name == "null"
drop _merge

*merge insured locality dataset the cbs dataset
frame copy default input_localities_multiple 
merge m:1 yeshov_name using "`yeshov_list'", keepusing(yeshov_code_cbs)
sort yeshov_name
keep if _merge == 3
drop _merge
duplicates drop year yeshov_code_cbs , force 
save "$processed_path\insured_localities", replace 

*save insured-locality list
frame copy input_localities_multiple  input_localities_single 
duplicates drop yeshov_name, force
keep yeshov_code yeshov_code_cbs yeshov_name 


