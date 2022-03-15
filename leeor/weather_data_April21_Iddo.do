** 	WEATHER DATA FOR IDDO **
* last modified: April 26th *

clear all
global path "C:\Users\Leeor Carasso-Lev\OneDrive\Documents\Faculty of Agriculture\Thesis 2021\data"

* WIND *

use "$path\wind90.dta"

foreach i in 91 92 93 94 95 96 97 98 99 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16{
append using "$path\wind`i'"
}

drop שםתחנה
rename מספרתחנה c_station_id
rename תאריך date
rename שעה time
rename מהירותהרוחקשר wind_speed

gen new_date = date(date, "DMY")
format new_date %td

by c_station_id new_date, sort: egen avg_speed = mean(wind_speed)

gen month = month(new_date)
gen year = year(new_date)
drop if missing(year)

collapse (max)wind_speed avg_speed, by(c_station_id new_date month year) 

foreach i in 1 2 3 4 5 6 7 8 9 10 11 12{
by c_station_id year, sort: egen m`i'_avg_wind = mean(avg_speed) if month==`i'
}

rename wind_speed max_wind
rename avg_speed avg_wind
rename year long_year

gen year = mod(long_year,100)
format year %02.0f

duplicates report c_station_id new_date
rename new_date date
order year

count if missing(max_wind)
count if missing(avg_wind)
count if missing(max_wind) & missing(max_wind)

gen w_measured = 0
replace w_measured=1 if !missing(max_wind) 
sum max_wind avg_wind

foreach i in 1 2{
gen bin_`i'=0
}

replace bin_1=1 if max_wind>=0 & max_wind<30
replace bin_2=1 if max_wind>=30 & max_wind<=70

rename bin_1 wind_0_30
rename bin_2 wind_30_70

gen ext_wind = 0 
replace ext_wind=1 if max_wind>=35 & !missing(max_wind)

collapse (sum)wind_0_30 wind_30_70 ext_wind w_measured ///
(max) m1_avg_wind m2_avg_wind m3_avg_wind m4_avg_wind m5_avg_wind m6_avg_wind ///
m7_avg_wind m8_avg_wind m9_avg_wind m10_avg_wind ///
m11_avg_wind m12_avg_wind (mean)avg_wind, by(long_year year c_station_id)

order c_station_id long_year year

duplicates report year c_station_id

save "C:\Users\Leeor Carasso-Lev\OneDrive\Documents\Faculty of Agriculture\weather for iddo\wind", replace

* RAIN *

clear all
use "$path\new_all_years_rain.dta"

drop ùíúçðä
rename îñôøúçðä r_station_id
rename úàøéê date
rename ëîåúâùíéåîéúîî rain_amount
rename åãâùíéåîé rain_code


gen new_date = date(date, "DMY")
format new_date %td
gen long_year=year(new_date)
gen year=mod(long_year,100)
gen month=month(new_date)
order year
format year %02.0f
sum rain_amount


gen r_measured=0
replace r_measured=1 if !missing(rain_amount)

order r_station_id long_year year month

foreach i in 1 3{
gen rain_bin`i' = 0
replace rain_bin`i' = 1 if rain_amount>=50*`i'-50 & rain_amount<100*`i' & !missing(rain_amount)
}

rename rain_bin1 rain_0_100
rename rain_bin3 rain_100_300

codebook month

gen count = 1 

foreach i in 1 2 3 4 5 6 7 8 9 10 11 12{
by r_station_id year, sort: egen m`i'_avg_rain = mean(rain_amount) if month==`i'
by r_station_id year, sort: egen m`i'_rain_days = total(count) if month==`i' & rain_amount!=0
}

sort r_station_id year month

by r_station_id year, sort: egen avg_rain = mean(rain_amount) if rain_amount!=0

rename rain_amount total_rain_amount

collapse (sum)total_rain_amount r_measured rain_0_100 rain_100_300 ///
(max) m1_avg_rain m2_avg_rain m3_avg_rain m4_avg_rain m5_avg_rain m6_avg_rain m7_avg_rain m8_avg_rain m9_avg_rain m10_avg_rain m11_avg_rain m12_avg_rain ///
m1_rain_days m2_rain_days m3_rain_days m4_rain_days m5_rain_days m6_rain_days m7_rain_days m8_rain_days m9_rain_days m10_rain_days m11_rain_days m12_rain_days ///
avg_rain, by(r_station_id year long_year)

sort r_station_id long_year

save "C:\Users\Leeor Carasso-Lev\OneDrive\Documents\Faculty of Agriculture\weather for iddo\rain", replace

* TEMP / DAILY *

clear all
use "$path\daily90.dta"
foreach i in 91 92 93 94 95 96 97 98 99 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16{
append using "$path\daily`i'"
}

drop שםתחנה
rename מספרתחנה c_station_id
rename תאריך date
rename טמפמקס max_temp
rename טמפמינ min_temp
rename טמפמינלידהקרקע min_ground_temp

destring max_temp, replace force
destring min_temp, replace force
destring min_ground_temp, replace force

keep c_station_id date max_temp min_temp

gen new_date = date(date, "DMY")
format new_date %td

gen long_year = year(new_date)
gen year = mod(long_year, 100)
format year %02.0f
order year, after(c_station_id)
order c_station_id long_year year
gen month = month(new_date)
order month, after(year)

foreach var of varlist max_temp min_temp{ 
gen `var'_measured=0
replace `var'_measured=1 if !missing(`var')
}

sum max_temp
gen max_5_20 = 0
replace max_5_20 = 1 if max_temp>=-5 & max_temp<20

gen max_20_35 = 0 
replace max_20_35 = 1 if max_temp>=20 & max_temp<35 

gen max_35_50 = 0 
replace max_35_50 = 1 if max_temp>=35 & max_temp<50

sum min_temp
gen min_15_5 = 0
replace min_15_5 = 1 if min_temp>=-15 & min_temp<5

gen min_5_20 = 0
replace min_5_20 = 1 if min_temp>=5 & min_temp<20

gen min_20_40 = 0
replace min_20_40 = 1 if min_temp>=20 & min_temp<40

gen ext_freeze=0
replace ext_freeze=1 if min_temp<=0

gen ext_heat=0 
replace ext_heat=1 if max_temp>=39

/*5 phenological stages of citrus
gen n_dormancy = 0
replace n_dormancy = 1 if min_temp<-4 & max_temp>14

gen n_flowering = 0
replace n_flowering = 1 if min_temp<10 & max_temp>27

gen n_fruit_set = 0
replace n_fruit_set = 1 if min_temp<22 & max_temp>27

gen n_fruit_growth = 0
replace n_fruit_growth = 1 if min_temp<20 & max_temp>33

gen n_maturation = 0
replace n_maturation = 1 if min_temp<8 & max_temp>27
*/

foreach i in 1 2 3 4 5 6 7 8 9 10 11 12{
by c_station_id year, sort: egen m`i'_avg_max_temp = mean(max_temp) if month==`i'
by c_station_id year, sort: egen m`i'_avg_min_temp = mean(min_temp) if month==`i'
}

by c_station_id year, sort: egen avg_max_temp = mean(max_temp)
by c_station_id year, sort: egen avg_min_temp = mean(min_temp)

collapse (sum) max_temp_measured min_temp_measured max_5_20 max_20_35 max_35_50 ///
min_15_5 min_5_20 min_20_40 ext_freeze ext_heat ///
/*n_dormancy n_flowering n_fruit_set n_fruit_growth n_maturation*/ ///
(max) m1_avg_max_temp m1_avg_min_temp m2_avg_max_temp m2_avg_min_temp ///
m3_avg_max_temp m3_avg_min_temp m4_avg_max_temp m4_avg_min_temp ///
m5_avg_max_temp m5_avg_min_temp m6_avg_max_temp m6_avg_min_temp ///
m7_avg_max_temp m7_avg_min_temp m8_avg_max_temp m8_avg_min_temp ///
m9_avg_max_temp m9_avg_min_temp m10_avg_max_temp m10_avg_min_temp ///
m11_avg_max_temp m11_avg_min_temp ///
m12_avg_max_temp m12_avg_min_temp avg_max_temp avg_min_temp, ///
by(c_station_id long_year year)

save "C:\Users\Leeor Carasso-Lev\OneDrive\Documents\Faculty of Agriculture\weather for iddo\temp", replace

* Distances *

* CLIMATE STATIONS - LOCALITIES *

clear all
use "C:\Users\Leeor Carasso-Lev\OneDrive\Documents\Faculty of Agriculture\weather for iddo\villages.dta"

rename latituden l_latituden
rename longitudee l_longitudee

destring l_latituden, replace
destring l_longitudee , replace

geonear village_id l_latituden l_longitudee using "$path\climate_stations", n(station_id s_latituden s_longitudee) nearcount(4) 

expand 27, gen(year)
sort village_id
drop year
by village_id: gen year=_n
replace year = year+1989
rename year long_year
gen year = mod(long_year,100)
format year %02.0f
order village_id long_year year 
duplicates report year village_id

rename nid1 c1
rename nid2 c2
rename nid3 c3
rename nid4 c4
rename km_to_nid1 dist_c1
rename km_to_nid2 dist_c2
rename km_to_nid3 dist_c3
rename km_to_nid4 dist_c4

save "C:\Users\Leeor Carasso-Lev\OneDrive\Documents\Faculty of Agriculture\weather for iddo\c_dist", replace

* RAIN STATIONS - LOCALITIES *

clear all
use "C:\Users\Leeor Carasso-Lev\OneDrive\Documents\Faculty of Agriculture\weather for iddo\villages.dta"

rename latituden l_latituden
rename longitudee l_longitudee

destring l_latituden, replace
destring l_longitudee , replace

geonear village_id l_latituden l_longitudee using ///
"$path\rain_stations", n(r_station_id r_latituden r_longitudee) nearcount(4) 

rename nid1 r1
rename km_to_nid1 dist_r1
rename nid2 r2
rename km_to_nid2 dist_r2
rename nid3 r3
rename km_to_nid3 dist_r3
rename nid4 r4
rename km_to_nid4 dist_r4

expand 27, gen(year)
sort village_id
drop year
by village_id: gen year=_n
replace year = year+1989
rename year long_year
gen year = mod(long_year,100)
order village_id long_year year
format year %02.0f
duplicates report year village_id

save "C:\Users\Leeor Carasso-Lev\OneDrive\Documents\Faculty of Agriculture\weather for iddo\r_dist", replace

* Weighing and Merging *

* WITH WIND *

clear all
global path "C:\Users\Leeor Carasso-Lev\OneDrive\Documents\Faculty of Agriculture\weather for iddo"
use "$path\c_dist.dta", replace

foreach i in 1 2 3 4{
rename c`i' c_station_id
merge m:1 year c_station_id using "$path\wind"
rename c_station_id c`i'
drop _merge
foreach var of varlist wind_0_30-avg_wind{
rename `var' c`i'_`var'
}
}

drop if missing(village_id)

//weighing

gen deno_1 = (1/dist_c1) if !missing(c1_w_measured)
gen deno_2 = (1/dist_c2) if !missing(c2_w_measured)
gen deno_3 = (1/dist_c3) if !missing(c3_w_measured)
gen deno_4 = (1/dist_c4) if !missing(c4_w_measured)

foreach i in 1 2 3 4{
replace deno_`i' = 0 if missing(deno_`i')
}

gen deno = deno_1 + deno_2 + deno_3 + deno_4

foreach i in 1 2 3 4{
gen weight`i'=(deno_`i')/deno 
}

foreach i in 1 2 3 4{
replace weight`i' = 0 if missing(weight`i')
} 


foreach var of varlist c1_wind_0_30-c4_avg_wind{
replace `var'=0 if missing(`var')
}

//weighted variables
gen wind_0_30 = (weight1 * c1_wind_0_30) + (weight2 * c2_wind_0_30) + (weight3 * c3_wind_0_30) + (weight4 * c4_wind_0_30)
gen wind_30_70 = (weight1 * c1_wind_30_70) + (weight2 * c2_wind_30_70) + (weight3 * c3_wind_30_70) + (weight4 * c4_wind_30_70)
gen ext_wind = (weight1 * c1_ext_wind) + (weight2 * c2_ext_wind) + (weight3 * c3_ext_wind) + (weight4 * c4_ext_wind)
gen m1_avg_wind = (weight1 * c1_m1_avg_wind) + (weight2 * c2_m1_avg_wind) + (weight3 * c3_m1_avg_wind) + (weight4 * c4_m1_avg_wind)
gen m2_avg_wind = (weight1 * c1_m2_avg_wind) + (weight2 * c2_m2_avg_wind) + (weight3 * c3_m2_avg_wind) + (weight4 * c4_m2_avg_wind)
gen m3_avg_wind = (weight1 * c1_m3_avg_wind) + (weight2 * c2_m3_avg_wind) + (weight3 * c3_m3_avg_wind) + (weight4 * c4_m3_avg_wind)
gen m4_avg_wind = (weight1 * c1_m4_avg_wind) + (weight2 * c2_m4_avg_wind) + (weight3 * c3_m4_avg_wind) + (weight4 * c4_m4_avg_wind)
gen m5_avg_wind = (weight1 * c1_m5_avg_wind) + (weight2 * c2_m5_avg_wind) + (weight3 * c3_m5_avg_wind) + (weight4 * c4_m5_avg_wind)
gen m6_avg_wind = (weight1 * c1_m6_avg_wind) + (weight2 * c2_m6_avg_wind) + (weight3 * c3_m6_avg_wind) + (weight4 * c4_m6_avg_wind)
gen m7_avg_wind = (weight1 * c1_m7_avg_wind) + (weight2 * c2_m7_avg_wind) + (weight3 * c3_m7_avg_wind) + (weight4 * c4_m7_avg_wind)
gen m8_avg_wind = (weight1 * c1_m8_avg_wind) + (weight2 * c2_m8_avg_wind) + (weight3 * c3_m8_avg_wind) + (weight4 * c4_m8_avg_wind)
gen m9_avg_wind = (weight1 * c1_m9_avg_wind) + (weight2 * c2_m9_avg_wind) + (weight3 * c3_m9_avg_wind) + (weight4 * c4_m9_avg_wind)
gen m10_avg_wind = (weight1 * c1_m10_avg_wind) + (weight2 * c2_m10_avg_wind) + (weight3 * c3_m10_avg_wind) + (weight4 * c4_m10_avg_wind)
gen m11_avg_wind = (weight1 * c1_m11_avg_wind) + (weight2 * c2_m11_avg_wind) + (weight3 * c3_m11_avg_wind) + (weight4 * c4_m11_avg_wind)
gen m12_avg_wind = (weight1 * c1_m12_avg_wind) + (weight2 * c2_m12_avg_wind) + (weight3 * c3_m12_avg_wind) + (weight4 * c4_m12_avg_wind)
gen avg_wind = (weight1 * c1_avg_wind) + (weight2 * c2_avg_wind) + (weight3 * c3_avg_wind) + (weight4 * c4_avg_wind)
//gen w_measured = (weight1 * c1_w_measured) + (weight2 * c2_w_measured) + (weight3 * c3_w_measured) + (weight4 * c4_w_measured)

gen w_measured = c1_w_measured + c2_w_measured + c3_w_measured + c4_w_measured

keep village_id long_year year l_latituden l_longitudee ///
c1 dist_c1 c2 dist_c2 c3 dist_c3 c4 dist_c4 ///
wind_0_30 wind_30_70 ext_wind m1_avg_wind m2_avg_wind m3_avg_wind m4_avg_wind ///
m5_avg_wind m6_avg_wind m7_avg_wind m8_avg_wind m9_avg_wind m10_avg_wind ///
m11_avg_wind m12_avg_wind avg_wind w_measured

duplicates report village_id year
save "$path\weighted_wind", replace

* WITH TEMP *

clear all
use "$path\c_dist.dta", replace

foreach i in 1 2 3 4{
rename c`i' c_station_id
merge m:1 year c_station_id using "$path\temp"
rename c_station_id c`i'
drop _merge
foreach var of varlist max_temp_measured-avg_min_temp{ 
rename `var' c`i'_`var'
}
}

drop if missing(village_id)

//weighing

gen deno_1 = (1/dist_c1) if !missing(c1_max_temp_measured)
gen deno_2 = (1/dist_c2) if !missing(c2_max_temp_measured)
gen deno_3 = (1/dist_c3) if !missing(c3_max_temp_measured)
gen deno_4 = (1/dist_c4) if !missing(c4_max_temp_measured)

foreach i in 1 2 3 4{
replace deno_`i' = 0 if missing(deno_`i')
}

gen deno = deno_1 + deno_2 + deno_3 + deno_4

foreach i in 1 2 3 4{
gen weight`i'=(deno_`i')/deno if !missing(c`i'_max_temp_measured)
}

foreach i in 1 2 3 4{
replace weight`i' = 0 if missing(weight`i')
}

foreach var of varlist c1_max_temp_measured-c4_avg_min_temp{
replace `var'=0 if missing(`var')
}

gen max_5_20 = (weight1 * c1_max_5_20) + (weight2 * c2_max_5_20) + (weight3 * c3_max_5_20) + (weight4 * c4_max_5_20)
gen max_20_35 = (weight1 * c1_max_20_35) + (weight2 * c2_max_20_35) + (weight3 * c3_max_20_35) + (weight4 * c4_max_20_35)
gen max_35_50 = (weight1 * c1_max_35_50) + (weight2 * c2_max_35_50) + (weight3 * c3_max_35_50) + (weight4 * c4_max_35_50)
gen min_15_5 = (weight1 * c1_min_15_5) + (weight2 * c2_min_15_5) + (weight3 * c3_min_15_5) + (weight4 * c4_min_15_5)
gen min_5_20 = (weight1 * c1_min_5_20) + (weight2 * c2_min_5_20) + (weight3 * c3_min_5_20) + (weight4 * c4_min_5_20) 
gen min_20_40 = (weight1 * c1_min_20_40) + (weight2 * c2_min_20_40) + (weight3 * c3_min_20_40) + (weight4 * c4_min_20_40) 
gen ext_freeze = (weight1 * c1_ext_freeze) + (weight2 * c2_ext_freeze) + (weight3 * c3_ext_freeze) + (weight4 * c4_ext_freeze) 
gen ext_heat = (weight1 * c1_ext_heat) + (weight2 * c2_ext_heat) + (weight3 * c3_ext_heat) + (weight4 * c4_ext_heat)   
//gen n_dormancy = (weight1 * c1_n_dormancy) + (weight2 * c2_n_dormancy) + (weight3 * c3_n_dormancy) + (weight4 * c4_n_dormancy)   
//gen n_flowering = (weight1 * c1_n_flowering) + (weight2 * c2_n_flowering) + (weight3 * c3_n_flowering) + (weight4 * c4_n_flowering) 
//gen n_fruit_set = (weight1 * c1_n_fruit_set) + (weight2 * c2_n_fruit_set) + (weight3 * c3_n_fruit_set) + (weight4 * c4_n_fruit_set) 
//gen n_fruit_growth = (weight1 * c1_n_fruit_growth) + (weight2 * c2_n_fruit_growth) + (weight3 * c3_n_fruit_growth) + (weight4 * c4_n_fruit_growth) 
//gen n_maturation = (weight1 * c1_n_maturation) + (weight2 * c2_n_maturation) + (weight3 * c3_n_maturation) + (weight4 * c4_n_maturation)
gen m1_avg_max_temp = (weight1 * c1_m1_avg_max_temp) + (weight2 * c2_m1_avg_max_temp) + (weight3 * c3_m1_avg_max_temp) + (weight4 * c4_m1_avg_max_temp)
gen m1_avg_min_temp = (weight1 * c1_m1_avg_min_temp) + (weight2 * c2_m1_avg_min_temp) + (weight3 * c3_m1_avg_min_temp) + (weight4 * c4_m1_avg_min_temp)
gen m2_avg_max_temp = (weight1 * c1_m2_avg_max_temp) + (weight2 * c2_m2_avg_max_temp) + (weight3 * c3_m2_avg_max_temp) + (weight4 * c4_m2_avg_max_temp)
gen m2_avg_min_temp = (weight1 * c1_m2_avg_min_temp) + (weight2 * c2_m2_avg_min_temp) + (weight3 * c3_m2_avg_min_temp) + (weight4 * c4_m2_avg_min_temp)
gen m3_avg_max_temp = (weight1 * c1_m3_avg_max_temp) + (weight2 * c2_m3_avg_max_temp) + (weight3 * c3_m3_avg_max_temp) + (weight4 * c4_m3_avg_max_temp)
gen m3_avg_min_temp = (weight1 * c1_m3_avg_min_temp) + (weight2 * c2_m3_avg_min_temp) + (weight3 * c3_m3_avg_min_temp) + (weight4 * c4_m3_avg_min_temp)
gen m4_avg_max_temp = (weight1 * c1_m4_avg_max_temp) + (weight2 * c2_m4_avg_max_temp) + (weight3 * c3_m4_avg_max_temp) + (weight4 * c4_m4_avg_max_temp)
gen m4_avg_min_temp = (weight1 * c1_m4_avg_min_temp) + (weight2 * c2_m4_avg_min_temp) + (weight3 * c3_m4_avg_min_temp) + (weight4 * c4_m4_avg_min_temp)
gen m5_avg_max_temp = (weight1 * c1_m5_avg_max_temp) + (weight2 * c2_m5_avg_max_temp) + (weight3 * c3_m5_avg_max_temp) + (weight4 * c4_m5_avg_max_temp)
gen m5_avg_min_temp = (weight1 * c1_m5_avg_min_temp) + (weight2 * c2_m5_avg_min_temp) + (weight3 * c3_m5_avg_min_temp) + (weight4 * c4_m5_avg_min_temp)
gen m6_avg_max_temp = (weight1 * c1_m6_avg_max_temp) + (weight2 * c2_m6_avg_max_temp) + (weight3 * c3_m6_avg_max_temp) + (weight4 * c4_m6_avg_max_temp)
gen m6_avg_min_temp = (weight1 * c1_m6_avg_min_temp) + (weight2 * c2_m6_avg_min_temp) + (weight3 * c3_m6_avg_min_temp) + (weight4 * c4_m6_avg_min_temp)
gen m7_avg_max_temp = (weight1 * c1_m7_avg_max_temp) + (weight2 * c2_m7_avg_max_temp) + (weight3 * c3_m7_avg_max_temp) + (weight4 * c4_m7_avg_max_temp)
gen m7_avg_min_temp = (weight1 * c1_m7_avg_min_temp) + (weight2 * c2_m7_avg_min_temp) + (weight3 * c3_m7_avg_min_temp) + (weight4 * c4_m7_avg_min_temp)
gen m8_avg_max_temp = (weight1 * c1_m8_avg_max_temp) + (weight2 * c2_m8_avg_max_temp) + (weight3 * c3_m8_avg_max_temp) + (weight4 * c4_m8_avg_max_temp)
gen m8_avg_min_temp = (weight1 * c1_m8_avg_min_temp) + (weight2 * c2_m8_avg_min_temp) + (weight3 * c3_m8_avg_min_temp) + (weight4 * c4_m8_avg_min_temp)
gen m9_avg_max_temp = (weight1 * c1_m9_avg_max_temp) + (weight2 * c2_m9_avg_max_temp) + (weight3 * c3_m9_avg_max_temp) + (weight4 * c4_m9_avg_max_temp)
gen m9_avg_min_temp = (weight1 * c1_m9_avg_min_temp) + (weight2 * c2_m9_avg_min_temp) + (weight3 * c3_m9_avg_min_temp) + (weight4 * c4_m9_avg_min_temp)
gen m10_avg_max_temp = (weight1 * c1_m10_avg_max_temp) + (weight2 * c2_m10_avg_max_temp) + (weight3 * c3_m10_avg_max_temp) + (weight4 * c4_m10_avg_max_temp)
gen m10_avg_min_temp = (weight1 * c1_m10_avg_min_temp) + (weight2 * c2_m10_avg_min_temp) + (weight3 * c3_m10_avg_min_temp) + (weight4 * c4_m10_avg_min_temp)
gen m11_avg_max_temp = (weight1 * c1_m11_avg_max_temp) + (weight2 * c2_m11_avg_max_temp) + (weight3 * c3_m11_avg_max_temp) + (weight4 * c4_m11_avg_max_temp)
gen m11_avg_min_temp = (weight1 * c1_m11_avg_min_temp) + (weight2 * c2_m11_avg_min_temp) + (weight3 * c3_m11_avg_min_temp) + (weight4 * c4_m11_avg_min_temp)
gen m12_avg_max_temp = (weight1 * c1_m12_avg_max_temp) + (weight2 * c2_m12_avg_max_temp) + (weight3 * c3_m12_avg_max_temp) + (weight4 * c4_m12_avg_max_temp)
gen m12_avg_min_temp = (weight1 * c1_m12_avg_min_temp) + (weight2 * c2_m12_avg_min_temp) + (weight3 * c3_m12_avg_min_temp) + (weight4 * c4_m12_avg_min_temp)
gen avg_max_temp = (weight1 * c1_avg_max_temp) + (weight2 * c2_avg_max_temp) + (weight3 * c3_avg_max_temp) + (weight4 * c4_avg_max_temp)
gen avg_min_temp = (weight1 * c1_avg_min_temp) + (weight2 * c2_avg_min_temp) + (weight3 * c3_avg_min_temp) + (weight4 * c4_avg_min_temp)

gen max_temp_measured = c1_max_temp_measured + c2_max_temp_measured + c3_max_temp_measured + c4_max_temp_measured
gen min_temp_measured = c1_min_temp_measured + c2_min_temp_measured + c3_min_temp_measured + c4_min_temp_measured

keep village_id long_year year l_latituden l_longitudee c1 dist_c1 ///
c2 dist_c2 c3 dist_c3 c4 dist_c4 max_temp_measured min_temp_measured max_5_20 ///
max_20_35 max_35_50 min_15_5 min_5_20 min_20_40 ext_freeze ext_heat /*n_dormancy ///
n_flowering n_fruit_set n_fruit_growth n_maturation*/ m1_avg_max_temp m1_avg_min_temp ///
m2_avg_max_temp m2_avg_min_temp m3_avg_max_temp m3_avg_min_temp m4_avg_max_temp ///
m4_avg_min_temp m5_avg_max_temp m5_avg_min_temp m6_avg_max_temp m6_avg_min_temp ///
m7_avg_max_temp m7_avg_min_temp m8_avg_max_temp m8_avg_min_temp m9_avg_max_temp ///
m9_avg_min_temp m10_avg_max_temp m10_avg_min_temp m11_avg_max_temp m11_avg_min_temp ///
m12_avg_max_temp m12_avg_min_temp avg_max_temp avg_min_temp 
 
duplicates report village_id year
 
save "$path\weighted_temp", replace

* WITH RAIN *

clear all
use "$path\r_dist.dta", replace

foreach i in 1 2 3 4{
rename r`i' r_station_id
merge m:1 year r_station_id using "$path\rain"
rename r_station_id r`i'
drop _merge
foreach var of varlist total_rain_amount-avg_rain{
rename `var' r`i'_`var'
}
}

drop if missing(village_id)

//weighing

gen deno_1 = (1/dist_r1) if !missing(r1_r_measured)
gen deno_2 = (1/dist_r2) if !missing(r2_r_measured)
gen deno_3 = (1/dist_r3) if !missing(r3_r_measured)
gen deno_4 = (1/dist_r4) if !missing(r4_r_measured)

foreach i in 1 2 3 4{
replace deno_`i' = 0 if missing(deno_`i')
}

gen deno = deno_1 + deno_2 + deno_3 + deno_4

foreach i in 1 2 3 4{
gen weight`i'=(deno_`i')/deno if !missing(r`i'_r_measured)
}

foreach i in 1 2 3 4{
replace weight`i' = 0 if missing(weight`i')
}

foreach var of varlist r1_total_rain_amount- r4_avg_rain{
replace `var'=0 if missing(`var')
}

gen total_rain_amount = (weight1 *	r1_total_rain_amount) + (weight2 *	r2_total_rain_amount) + (weight3 *	r3_total_rain_amount) + (weight4 * r4_total_rain_amount) 
gen rain_0_100 = (weight1 *	r1_rain_0_100) + (weight2 *	r2_rain_0_100) + (weight3 *	r3_rain_0_100) + (weight4 * r4_rain_0_100) 
gen rain_100_300 = (weight1 *	r1_rain_100_300) + (weight2 *	r2_rain_100_300) + (weight3 *	r3_rain_100_300) + (weight4 * r4_rain_100_300)  
gen m1_avg_rain = (weight1 *	r1_m1_avg_rain) + (weight2 *	r2_m1_avg_rain) + (weight3 *	r3_m1_avg_rain) + (weight4 * r4_m1_avg_rain) 
gen m2_avg_rain = (weight1 *	r1_m2_avg_rain) + (weight2 *	r2_m2_avg_rain) + (weight3 *	r3_m2_avg_rain) + (weight4 * r4_m2_avg_rain) 
gen m3_avg_rain = (weight1 *	r1_m3_avg_rain) + (weight2 *	r2_m3_avg_rain) + (weight3 *	r3_m3_avg_rain) + (weight4 * r4_m3_avg_rain) 
gen m4_avg_rain = (weight1 *	r1_m4_avg_rain) + (weight2 *	r2_m4_avg_rain) + (weight3 *	r3_m4_avg_rain) + (weight4 * r4_m4_avg_rain) 
gen m5_avg_rain = (weight1 *	r1_m5_avg_rain) + (weight2 *	r2_m5_avg_rain) + (weight3 *	r3_m5_avg_rain) + (weight4 * r4_m5_avg_rain) 
gen m6_avg_rain = (weight1 *	r1_m6_avg_rain) + (weight2 *	r2_m6_avg_rain) + (weight3 *	r3_m6_avg_rain) + (weight4 * r4_m6_avg_rain) 
gen m7_avg_rain = (weight1 *	r1_m7_avg_rain) + (weight2 *	r2_m7_avg_rain) + (weight3 *	r3_m7_avg_rain) + (weight4 * r4_m7_avg_rain) 
gen m8_avg_rain = (weight1 *	r1_m8_avg_rain) + (weight2 *	r2_m8_avg_rain) + (weight3 *	r3_m8_avg_rain) + (weight4 * r4_m8_avg_rain) 
gen m9_avg_rain = (weight1 *	r1_m9_avg_rain) + (weight2 *	r2_m9_avg_rain) + (weight3 *	r3_m9_avg_rain) + (weight4 * r4_m9_avg_rain) 
gen m10_avg_rain = (weight1 *	r1_m10_avg_rain) + (weight2 *	r2_m10_avg_rain) + (weight3 *	r3_m10_avg_rain) + (weight4 * r4_m10_avg_rain) 
gen m11_avg_rain = (weight1 *	r1_m11_avg_rain) + (weight2 *	r2_m11_avg_rain) + (weight3 *	r3_m11_avg_rain) + (weight4 * r4_m11_avg_rain) 
gen m12_avg_rain = (weight1 *	r1_m12_avg_rain) + (weight2 *	r2_m12_avg_rain) + (weight3 *	r3_m12_avg_rain) + (weight4 * r4_m12_avg_rain) 
gen m1_rain_days = (weight1 *	r1_m1_rain_days) + (weight2 *	r2_m1_rain_days) + (weight3 *	r3_m1_rain_days) + (weight4 * r4_m1_rain_days) 
gen m2_rain_days = (weight1 *	r1_m2_rain_days) + (weight2 *	r2_m2_rain_days) + (weight3 *	r3_m2_rain_days) + (weight4 * r4_m2_rain_days) 
gen m3_rain_days = (weight1 *	r1_m3_rain_days) + (weight2 *	r2_m3_rain_days) + (weight3 *	r3_m3_rain_days) + (weight4 * r4_m3_rain_days) 
gen m4_rain_days = (weight1 *	r1_m4_rain_days) + (weight2 *	r2_m4_rain_days) + (weight3 *	r3_m4_rain_days) + (weight4 * r4_m4_rain_days) 
gen m5_rain_days = (weight1 *	r1_m5_rain_days) + (weight2 *	r2_m5_rain_days) + (weight3 *	r3_m5_rain_days) + (weight4 * r4_m5_rain_days) 
gen m6_rain_days = (weight1 *	r1_m6_rain_days) + (weight2 *	r2_m6_rain_days) + (weight3 *	r3_m6_rain_days) + (weight4 * r4_m6_rain_days)
gen m7_rain_days = (weight1 *	r1_m7_rain_days) + (weight2 *	r2_m7_rain_days) + (weight3 *	r3_m7_rain_days) + (weight4 * r4_m7_rain_days) 
gen m8_rain_days = (weight1 *	r1_m8_rain_days) + (weight2 *	r2_m8_rain_days) + (weight3 *	r3_m8_rain_days) + (weight4 * r4_m8_rain_days) 
gen m9_rain_days = (weight1 *	r1_m9_rain_days) + (weight2 *	r2_m9_rain_days) + (weight3 *	r3_m9_rain_days) + (weight4 * r4_m9_rain_days) 
gen m10_rain_days = (weight1 *	r1_m10_rain_days) + (weight2 *	r2_m10_rain_days) + (weight3 *	r3_m10_rain_days) + (weight4 * r4_m10_rain_days) 
gen m11_rain_days = (weight1 *	r1_m11_rain_days) + (weight2 *	r2_m11_rain_days) + (weight3 *	r3_m11_rain_days) + (weight4 * r4_m11_rain_days) 
gen m12_rain_days = (weight1 *	r1_m12_rain_days) + (weight2 *	r2_m12_rain_days) + (weight3 *	r3_m12_rain_days) + (weight4 * r4_m12_rain_days) 
gen avg_rain =  (weight1 *	r1_avg_rain) + (weight2 *	r2_avg_rain) + (weight3 *	r3_avg_rain) + (weight4 * r4_avg_rain) 

gen r_measured = r1_r_measured + r2_r_measured + r3_r_measured + r4_r_measured

keep village_id long_year year l_latituden l_longitudee ///
r1 dist_r1 r2 dist_r2 r3 dist_r3 r4 dist_r4 total_rain_amount rain_0_100 ///
rain_100_300 m1_avg_rain m2_avg_rain m3_avg_rain m4_avg_rain m5_avg_rain ///
m6_avg_rain m7_avg_rain m8_avg_rain m9_avg_rain m10_avg_rain m11_avg_rain ///
m12_avg_rain m1_rain_days m2_rain_days m3_rain_days m4_rain_days m5_rain_days ///
m6_rain_days m7_rain_days m8_rain_days m9_rain_days m10_rain_days m11_rain_days ///
m12_rain_days avg_rain r_measured

duplicates report village_id year

save "$path\weighted_rain", replace

* MERGE ALL *

clear all
use "$path\weighted_temp.dta"

merge 1:1 year village_id long_year using "$path\weighted_rain"
drop _merge
merge 1:1 year village_id long_year using "$path\weighted_wind"
drop _merge

save "$path\localities_weather", replace

sort village_id long_year

sum

order long_year

// moving averages (avg weather data of former 3 years) 

clear all
use "$path\localities_weather"

sort village_id long_year
by village_id, sort: gen index = _n
order index

order max_temp_measured min_temp_measured r_measured w_measured, last
order r1 dist_r1 r2 dist_r2 r3 dist_r3 r4 dist_r4, after(dist_c4)

foreach var of varlist ext_freeze ext_heat avg_max_temp avg_min_temp ///
total_rain_amount avg_rain ext_wind avg_wind{
//max_5_20-avg_wind{
gen `var'_ma = 0
gen `var'_last_year = 0
gen `var'_last_two = 0
gen `var'_last_three = 0
foreach i in 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27{
by village_id, sort: replace `var'_ma = (`var'[`i'-1]+`var'[`i'-2]+`var'[`i'-3])/3 if index==`i'
order `var'_ma, after(`var')
by village_id, sort: replace `var'_last_year = `var'[`i'-1] if index==`i'
order `var'_last_year, after(`var'_ma)
by village_id, sort: replace `var'_last_two = `var'[`i'-2] if index==`i'
order `var'_last_two, after(`var'_last_year)
by village_id, sort: replace `var'_last_three = `var'[`i'-3] if index==`i'
order `var'_last_three, after(`var'_last_two)
}
} 

save "$path\weather", replace


/*
//final table to merge with insurance data
* MERGE WEATHER DATA WITH INSURANCE DATA *
clear all
cd "C:\Users\Leeor Carasso-Lev\OneDrive\Documents\Faculty of Agriculture\Thesis 2021"
use "Village level data.dta"
//organized insurance data from iddo

keep id-inputs_index

save "C:\Users\Leeor Carasso-Lev\OneDrive\Documents\Faculty of Agriculture\Thesis 2021\data\insurance_thesis", replace

clear all
cd "C:\Users\Leeor Carasso-Lev\OneDrive\Documents\Faculty of Agriculture\Thesis 2021\data"
use "insurance_thesis.dta"

merge m:1 long_year year kod_yeshuv using localities_weather_MA_thesis

sort kod_yeshuv long_year

save "C:\Users\Leeor Carasso-Lev\OneDrive\Documents\Faculty of Agriculture\Thesis 2021\data\data_thesis", replace

//list of vars
describe, replace
export excel name type isnumeric varlab using list.xlsx, firstrow(variables) replace


drop if missing(id)
drop year
rename long_year year
*/
