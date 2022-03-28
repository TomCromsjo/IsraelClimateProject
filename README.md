# IsraelClimateProject
## Readme
Creating a tool for interpolated historical climate data in any location in Israel and places under Israeli control. 

Last updated: 28/03/2022

in order to run the project, change `global MyProject` in [run_weather](run_weather.do) and run the code inside Stata. **run_weather.do** creates a dataset of average daily interpolated climate variables for each locality in Israel and it's territories between 1990-2020.   

The main folder is organized as follows:

1. ### [documentation](documentation) 
    Documentation for raw data taken from the Israel Central Bureau of Statistics [CBS](documentation\cbs) and the Israel Meteorological Service [IMS](documentation\ims).

2. ### [leeor](leeor)
    Old scripts and data for weather interpolation created by Leeor. currently contains: <space><space>  
        2.1 [weather_data_April21_Iddo.do](leeor/weather_data_April21_Iddo.do): script for creating `Village level data.dta` , a dataset of interpolated yearly averages of various climate variables. Requires raw-datasets not yet available to us. 

3. ### [processed](processed)
    All files in processed are .dta dataset unless stated otherwise.   
        3.1 [daily_weather](processed/daily_weather.dta): Daily climate-variable averages for all weather-stations in [station_data](processed/station_data.dta).  
        3.2  [measurement_count](processed\measurement_count.dta): Lsits for each day between 1990-2020 how many observations are there by IMS stations for 4 variables: rain amount, minimum temperature, maximum temperature, and average wind speed.  
        3.3 [distance_matrix](processed/distance_matrix.dta): distance matrix between every locality in [yeshov_list](processed/yeshov_list.dta) and the three closest[weather-stations](processed/station_data.dta) of each type. <space><space>    
        3.4 [merged_hourly_wind](processed/merged_hourly_wind): Hourly wind averages between 1.1.1990 - 12.4.1998. (The period recorded in [raw data\hourly wind](raw data\hourly wind) ). <space><space>  
        3.5 [station_data](processed/station_data.dta): aggregated station data for all stations in [raw data](#raw_data). <space><space>  
        3.6 [yeshov_list](processed/yeshov_list.dta): All localities that were under full Israeli sovergnity between 2003-2020. Including Israeli settelments in Gaza-strip and the West Bank that were evacuated in 2005.   

4. ### [run_weather.do](run_weather.do)  
5. ### [raw data](/raw_data):
    5.1 [Weather station data](raw_data/meta_data_archiveIMS_0.xls): Retrived 08/02/2022 from https://ims.data.gov.il/sites/default/files/meta_data_archiveIMS_0.xls . 
    <details><summary>Sheets:</summary>
        1. <b> תחנות גשם </b> : Rain stations. <br> 
        2. <b>תחנות אקלים </b> : Climate stations. <br>
        3. <b>תחנות התאדות</b> : Evaporation stations. 
    </details>

    <details><summary>Variables:</summary>
        <ul>
        <li> <code>שם התחנה</code>: Station name. </li>
        <li> <code>מספר התחנה</code>: Station ID. </li>
        <li> <code>שם התחנה בלועזית</code>: Station name in English. </li>
        <li> <code>סוג התחנה</code>: Station type. </li>
        <li> <code>קוארדינטות ברשת ישראל החדשה</code>: Coordinates on the Israeli Transverse Mercator (ITM). Also Known as the New Israel Grid. </li>
            <ul>
            <li> <code>מזרח</code>: East. </li> 
            <li> <code>צפון</code>: North. </li>
            </ul>
        <li> <code>קואורדינטות גאוגרפיות</code> Universal Transverse Mercator (UTM) coordinates. </li>
            <ul>
            <li> <code>אורך גיאוגרפי E</code>: Longitude. </li>
            <li> <code>רוחב גיאוגרפי N</code>: Latitude. </li>
            </ul>
        <li> <code>גובה מעל פני הים (מטר)</code>: Height above sea level (meters). </li>
        <li> <code>תאריך הפתיחה </code>: Opening date. </li>
        <li> <code>תאריך הסגירה</code> Closing date. </li>
        <li> <code>תקופת זמינות הנתונים</code> Availability period. (Not available for evaporation stations) </li>
        </ul>
    </details>

    For further information on the station dataset [click here](documentation\ims\מטה-דטה-של-ארכיון-הנתונים-המטאורולוגיים.pdf)[^1] (in hebrew).  

    **Data downloaded from the Data.gov.il**:  
    5.2 [climate](raw_data/climate): bulk mesurement csv files downloaded from https://data.gov.il/dataset/481 20/03/2022  
    
    5.2.1 [daily rain](raw_data\climate\new_isr_rain_daily_web.csv) 

    5.3 [daily mesurements](raw_data\climate\new_isr_daily_data_web.csv) 
     
    5.4 [hourly wind](raw_data\raw_data\climate\new_isr_gnd_obs_web.csv)

   For further information on IMS climate data [click here](documentation\ims\_מדריך-למשתמש-בנתוני-השמט-עדכון-04.2021.pdf) [^2] (in Hebrew).

    **Data downloaded from the CBS website**:</br>
    5.3 [localities](\raw_data\localities): 3 spreadsheet each containing all localities that were under full Israeli sovereignty in 2003, 2010 and 2020. Retrieved: 28/02/2022. 

      

6. ### [scripts](\scripts) 
    .do files used in the project:</br>
    6.1 [format_localities](scripts\format_localities.do): Creates [yeshov_list.dta](processed/yeshov_list.dta).</br>
    6.2 [format_stations](scripts\format_stations.do): Creates [station_data](processed/station_data.dta) from [meta_data_archiveIMS_0.xls](raw-data\meta_data_archiveIMS_0.xls). </br>
    6.3 [process_measurements](scripts\process_measurements.do): Creates [daily_weather.dta](processed/daily_weather.dta) and [merged_hourly_wind.dta](processed/merged_hourly_wind) from IMS mesurment cvs files saved in [processed/csv-utf8 files](processed/csv-utf8-files). </br>
    6.4 [distance_matrix](scripts\distance_matrix.do): Creates a [distance_matrix](processed/distance_matrix.dta)
    6.5 [weather_average](scripts\weather_averages.do): Creates a dataset were each observation is a locality-date pair, for each date between 1990-2020 and the variables are inverse-distance weighted averages of the variables in [daily_weather](processed/daily_weather.dta). </br>

[^1]: Retrieved 09/02/2022 from https://ims.data.gov.il/sites/default/files/meta_archive_0.pdf
[^2]: Retrieved 09/02/2022 from https://ims.data.gov.il/sites/default/files/%E2%80%8E%D7%9E%D7%93%D7%A8%D7%99%D7%9A%20%D7%9C%D7%9E%D7%A9%D7%AA%D7%9E%D7%A9%20%D7%91%D7%A0%D7%AA%D7%95%D7%A0%D7%99%20%D7%94%D7%A9%D7%9E%D7%98_%D7%A2%D7%93%D7%9B%D7%95%D7%9F%20%D7%9E%D7%90%D7%99%202015_1.pdf
