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
global MyProject "C:\Users\owner\Documents\GitHub\IsraelClimateProject"

global locality_path "${MyProject}\raw_data\localities"
global climate_path "${MyProject}\raw_data\climate"
global script_path "${MyProject}\scripts"
global processed_path "${MyProject}\processed"

assert !missing("$MyProject")

*run program


do "${script_path}\format_localities.do" // Creates yeshov_list.dta, a dataset of all localities in Israel and it's settelments. 
do "${script_path}\format_stations.do" // Creates station_data.dta, a dataset of all historical and current weather-stations under Israeli control.
do "${script_path}\process_mesurments.do" // Creates daily_weather.dta and merged_hourly_wind.dta using IMS mesurments. 
do "${script_path}\distance_matrix.do" // Creates a distance matrix between each weather-station in station_data.dta and each locality in yeshov_list.dta
do "${scripts_path}\weather_averages.do" // Creates distance weighted averages of weather variables for each locality and dae between 1990-2020

** EOF
