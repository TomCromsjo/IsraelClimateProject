# IsraelClimateProject
## Readme
Creating a tool for interpolated historical climate data in any location in Israel and places under Israeli control. 

Last updated: 14/03/2022

in order to run the project, change `global MyProject` in [run_weather](run_weather.do) and run the code inside Stata. **run_weather.do** creates a dataset of average daily interpolated climate variables for each locality in Israel and it's territories between 1990-2020.   

The main folder is organized as follows:

1. ### [documentation](documentation) 
    Documentation for raw data taken from the Israel Central Bureau of Statistics [CBS](documentation\cbs) and the Israel Meteorological Service [IMS](documentation\ims).

2. ### [leeor](leeor)
    Old scripts and data for weather interpolation created by Leeor. currently contains: <space><space>  
        2.1 [weather_data_April21_Iddo.do](leeor/weather_data_April21_Iddo.do): script for creating `Village level data.dta` , a dataset of interpolated yearly averages of various climate variables. Requires raw-datasets not yet available to us. 

3. ### [processed](processed)
    All files in processed are .dta dataset unless stated otherwise.  
        3.1 [csv utf8 files](processed/csv utf8 files): Contains climate data csv files from [raw data](#raw-data) converted to utf-8 encoding.  
        3.2 [daily_weather](processed/daily_weather.dta): Daily climate-variable averages for all weather-stations in [station_data](processed/station_data.dta).   
        3.3 [distance_matrix](processed/distance_matrix.dta): distance matrix between every locality in [yeshov_list](processed/yeshov_list.dta) and the three closest[weather-stations](processed/station_data.dta) of each type. <space><space>    
        3.4 [merged_hourly_wind](processed/merged_hourly_wind): Hourly wind averages between 1.1.1990 - 12.4.1998. (The period recorded in [raw data\hourly wind](raw data\hourly wind) ).
        3.5 [station_data](processed/station_data.dta): aggregated station data for all stations in [raw data](#raw-data).
        3.6 [yeshov_list](processed/yeshov_list.dta): All localities that were under full Israeli sovergnity between 2003-2020. Including Israeli settelments in Gaza-strip and the West Bank that were evacuated in 2005.   

4. ### [run_weather.do](run_weather.do)  
5. ### [raw data](raw data):
    5.1 [Weather station data](raw data/meta_data_archiveIMS_0.xls) -  Retrived 08/02/2022 from https://ims.data.gov.il/sites/default/files/meta_data_archiveIMS_0.xls . 
    <details><summary>Sheets:</summary>
    <p>
        1. **תחנות גשם** - Rain stations 
        2. **תחנות אקלים** - Climate stations
        3. **תחנות התאדות** - Evaporation stations.
        -<details><summary>Variables:</summary>
    </p>
    </details>

    <details><summary>Variables:</summary>
    <p>
        - `שם התחנה` Station name.
        - `מספר התחנה` Station ID.
        - `שם התחנה בלועזית` Station name in English.
        - `סוג התחנה` Station type
        - `קוארדינטות ברשת ישראל החדשה` Coordinates on the Israeli Transverse Mercator (ITM). Also Known as the New Israel Grid.
            - `מזרח` East. 
            - `צפון` North.
        - `קואורדינטות גאוגרפיות` Universal Transverse Mercator (UTM) coordinates.
            - `אורך גיאוגרפי E` Longitude.
            - `רוחב גיאוגרפי N` Latitude.
        - `גובה מעל פני הים (מטר)` Height above sea level (meters).
        - `תאריך הפתיחה ` Opening date.
        - `תאריך הסגירה` Closing date.
        - `תקופת זמינות הנתונים` Availability period. (Not available for evaporation stations)
    </p>
    </details>
    For further information on the station dataset [click here](documentation\ims\מטה דטה של ארכיון הנתונים המטאורולוגיים.pdf) [^1] (in hebrew).  

#### Data downloaded from the IMS website:  
    5.2 [10 minute wind](raw data\10 minute wind) : contains 4 spreadsheets of 10 minute wind-data intervals recorded between 22.04.1998 and 27.06.2000. Retrived: 09/03/2022 . We will extend the time-period covered once we get an api token from the IMS. 

    <details><summary>Variables:</summary>
    <p>
        - `שם תחנה`: Station name.
        - `תאריך`:  Date.
        - `שעה- LST`: Time in Israel Standard Time (IST), equivalent to UTC+02:00 .   
        - `מהירות הרוח(m/s)`: The average recorded wind-speed in the 10 minutes preceding `שעה- LST`.
        - `זמן סיום 10 הדקות המקסימליות()` - the exact time (hh:mm) when the 10 minutes the maximum wind-speed was calculated ended. Ignore this column. 
    </p>
    </details>

    5.3 [daily hail and temperature](raw data/daily hail and temperature) : 6 spreadsheets of daily hail and temperature measurements, recorded between 01.01.1990 - 04.06.2021. Dates for hail refer to standard day (00:00-24:00). Temperature date is between UTC 18:00 in the previous day and UTC 18:00 in the current date. 

    <details><summary>Variables:</summary>
    <p>
        - `שם תחנה`: Station name.
        - `מספר תחנה` : Station ID. 
        - `תאריך`:  Date.
        - `טמפרטורת מינימום ליד הקרקע(C°)`: Minimum temperature (Celsius) recorded in the previous 12 hours to UTC 06 by a thermometer that is positioned 5-10 cm above ground. 
        - `טמפרטורת מינימום(C°)`: Minimum temperature (Celsius) recorded in the observation's date. 
        - `טמפרטורת מקסימום(C°)`: Maximum temperature (Celsius) recorded in the observation's date.
        -  `ברד()`: Hail. 1 if hail occurred in that date, 0 if not, "-" if missing. 
    </p>
    </details>
     
     5.4 [hourly wind](raw data\hourly wind) contains 4 spreadsheets of hourly wind-data intervals recorded between 01.01.1990 and 22.04.1198. Retrieved: 09/02/2022. 

       <details><summary>Variables:</summary>
    <p>
        - `שם תחנה`: Station name.
        - `מספר תחנה` : Station ID. 
        - `תאריך`:  Date.
        - `שעה- LST`: Time in Israel Standard Time (IST), equivalent to UTC+02:00 . 
        - `מהירות הרוח(m/s)`: The average recorded wind-speed in the hour preceding `שעה- LST`.
    </p>
    </details>
#### Data downloaded from the CBS website:
    5.5 [localities](raw data\localities): 3 spreadsheet each containing all localities that were under full Israeli sovereignty in 2003, 2010 and 2020. Retrieved: 28/02/2022. 

All files are comma-separated values files (.csv) encoded windows-1255 except [daily data  07092013 28032016](raw data\daily hail and temperature\daily data  07092013 28032016.csv) that was accidently converted to UTF-8, and the original file was lost. For further information on IMS climate data [click here](documentation\ims\_מדריך למשתמש בנתוני השמט עדכון 04.2021.pdf) [^2] (in Hebrew). 

6. ### [scripts](scripts) 
.do files used in the project:
 6.1 [format_localities](scripts\format_localities.do):  Creates [yeshov_list.dta](processed/yeshov_list.dta) from .
 6.2 [format_stations](scripts\format_stations.do): Creates [station_data](processed/station_data.dta) from [meta_data_archiveIMS_0.xls](raw data\meta_data_archiveIMS_0.xls)
 6.3 [process mesurments](scripts\process mesurments.do): Creates [daily_weather.dta](processed/daily_weather.dta) and [merged_hourly_wind.dta](processed/merged_hourly_wind) from IMS mesurment cvs files saved in [processed/csv utf8 files](processed/csv utf8 files).
 6.4 [distance matrix](scripts\distance_matrix.do): Creates a [distance_matrix](processed/distance_matrix.dta)
 6.5 [weather_average](scripts\weather_averages.do): Creates a dataset were each observation is a locality-date pair, for each date between 1990-2020 and the variables are inverse-distance weighted averages of the variables in [daily_weather](processed/daily_weather.dta).

[^1] Retrieved 09/02/2022 from https://ims.data.gov.il/sites/default/files/meta_archive_0.pdf
[^2] Retrieved 09/02/2022 from https://ims.data.gov.il/sites/default/files/%E2%80%8E%D7%9E%D7%93%D7%A8%D7%99%D7%9A%20%D7%9C%D7%9E%D7%A9%D7%AA%D7%9E%D7%A9%20%D7%91%D7%A0%D7%AA%D7%95%D7%A0%D7%99%20%D7%94%D7%A9%D7%9E%D7%98_%D7%A2%D7%93%D7%9B%D7%95%D7%9F%20%D7%9E%D7%90%D7%99%202015_1.pdf
