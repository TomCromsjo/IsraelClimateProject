**********************
* OVERVIEW
*   This script generates datasets for https://github.com/TomCromsjo/IsraelClimateProject
*   All raw data are stored in /raw data
*
* SOFTWARE REQUIREMENTS
*   Analyses run on Windows using Stata version 15 
*
*This script uses a template provided by Reif j. (2019) , Github repository https://github.com/reifjulian/my-project
**********************
clear
set more off

* User must define this global macro to point to the folder path that includes this run.do script
global MyProject "C:\Users\owner\Dropbox\Thesis\Weather"
cd "$MyProject"

global locality_path "raw data\localities"

assert !missing("$MyProject")

*run program


do "scripts/format_localities.do" // Creates yeshov_list.dta, a dataset of all localities in Israel and it's settelments. 
do "scripts/format_stations.do" // Creates station_data.dta, a dataset of all historical and current weather-stations under Israeli control.
do "scripts/process mesurments.do" // Creates daily_weather.dta and merged_hourly_wind.dta using IMS mesurments. 
do "scripts/distance matrix.do" // Creates a distance matrix between each weather-station in station_data.dta and each locality in yeshov_list.dta
do "scripts/weather-average.do" // Creates distance weighted averages of weather variables for each locality and dae between 1990-2020

** EOF
