#1----------------------------------------
CREATE DATABASE ZOMATO_PROJECT;
USE ZOMATO_PROJECT;
SHOW TABLES;

SELECT COUNT(*) FROM zomato_data;
SELECT COUNT(*) FROM country;
SELECT COUNT(*) FROM date;
SELECT COUNT(*) FROM currency;
SELECT * FROM zomato_data LIMIT 5;

#2------------------------------------------
SELECT `Year Opening`, `Month Opening`, `Day Opening`
FROM zomato_data
LIMIT 10;

ALTER TABLE zomato_data
ADD COLUMN Datekey_Opening DATE;

SET SQL_SAFE_UPDATES = 0;

UPDATE ZOMATO_DATA SET DATEKEY_OPENING = STR_TO_DATE
(CONCAT(`Year Opening`, '-', `Month Opening`, '-', `Day Opening`), '%Y-%m-%d');

SELECT MIN(Datekey_Opening), MAX(Datekey_Opening)
FROM zomato_data;

CREATE TABLE calendar(DateKey INT PRIMARY KEY,
					  FullDate DATE,
					  Year INT,
					  Quarter INT,
					  Month INT,
					  MonthName VARCHAR(20),
					  Week INT,
					  Day INT,
					  DayName VARCHAR(20));

SET SESSION cte_max_recursion_depth = 4000;

INSERT INTO calendar (DateKey, FullDate, Year, Quarter, Month, MonthName, Week, Day, DayName)
WITH RECURSIVE CalendarDates AS (SELECT DATE('2010-01-01') AS dt

UNION ALL

SELECT dt + INTERVAL 1 DAY
FROM CalendarDates
WHERE dt < '2018-12-28')

SELECT 
CAST(DATE_FORMAT(dt,'%Y%m%d') AS UNSIGNED), dt, YEAR(dt), QUARTER(dt), MONTH(dt),
MONTHNAME(dt), WEEKOFYEAR(dt), DAY(dt), DAYNAME(dt)
FROM CalendarDates;

SELECT * FROM CALENDAR;
SELECT COUNT(*) AS Total_Dates FROM calendar;
SELECT * FROM calendar LIMIT 5;

ALTER TABLE calendar
ADD COLUMN FinancialMonth VARCHAR(5),
ADD COLUMN FinancialQuarter VARCHAR(5);

UPDATE calendar SET WeekdayName = DAYNAME(FullDate);

UPDATE calendar SET FinancialMonth =
CASE
    WHEN MONTH = 4 THEN 'FM1'
    WHEN MONTH = 5 THEN 'FM2'
    WHEN MONTH = 6 THEN 'FM3'
    WHEN MONTH = 7 THEN 'FM4'
    WHEN MONTH = 8 THEN 'FM5'
    WHEN MONTH = 9 THEN 'FM6'
    WHEN MONTH = 10 THEN 'FM7'
    WHEN MONTH = 11 THEN 'FM8'
    WHEN MONTH = 12 THEN 'FM9'
    WHEN MONTH = 1 THEN 'FM10'
    WHEN MONTH = 2 THEN 'FM11'
    WHEN MONTH = 3 THEN 'FM12'
END;

ALTER TABLE calendar DROP COLUMN WeekdayName;
ALTER TABLE calendar CHANGE DayName WeekdayName VARCHAR(20);

UPDATE calendar
SET FinancialQuarter =
CASE
    WHEN FinancialMonth IN ('FM1','FM2','FM3') THEN 'FQ1'
    WHEN FinancialMonth IN ('FM4','FM5','FM6') THEN 'FQ2'
    WHEN FinancialMonth IN ('FM7','FM8','FM9') THEN 'FQ3'
    WHEN FinancialMonth IN ('FM10','FM11','FM12') THEN 'FQ4'
END;

#3-----------------------------------------
SELECT * FROM currency;
DESC currency;

ALTER TABLE zomato_data
ADD COLUMN Average_Cost_for_two_USD DECIMAL(10,2);

UPDATE zomato_data z
JOIN currency c
ON z.Currency = c.Currency
SET z.Average_Cost_for_two_USD =
ROUND(z.Average_Cost_for_two * c.`USD Rate`,2);

SELECT * FROM ZOMATO_DATA;
SELECT RestaurantName, Average_Cost_for_two_USD
FROM zomato_data
LIMIT 10;

#4------------------------------------------
SELECT * FROM COUNTRY;
SELECT  
	COUNT(z.RestaurantID) AS Number_of_Restaurants,
    c.Countryname,
    z.City
FROM zomato_data z
JOIN country c
ON z.CountryCode = c.CountryID
GROUP BY
    c.Countryname,
    z.City
ORDER BY
    Number_of_Restaurants DESC;

#5--------------------------------------------
SELECT * FROM zomato_data;
SELECT * FROM CALENDAR;

SELECT 
	C.YEAR, C.QUARTER, C.MONTHNAME,
    COUNT(Z.RestaurantID) AS TOTAL_RESTAURANTS_OPENED
FROM zomato_data z
	JOIN CALENDAR C
	ON Z.Datekey_Opening=C.FULLDATE
GROUP BY
	C.YEAR, C.QUARTER, C.MONTHNAME
ORDER BY 
	C.YEAR, C.QUARTER, C.MONTHNAME DESC;

#6---------------------------------------------
SELECT    
    Rating,
    COUNT(RestauranTID) AS Number_of_Restaurants
FROM zomato_data
WHERE Rating IS NOT NULL
GROUP BY Rating
ORDER BY Rating DESC;

#7----------------------------------------------
SELECT   
    CASE
        WHEN Average_Cost_for_two BETWEEN 0 AND 500 THEN 'Budget (0-500)'
        WHEN Average_Cost_for_two BETWEEN 501 AND 1000 THEN 'Affordable (501-1000)'
        WHEN Average_Cost_for_two BETWEEN 1001 AND 2000 THEN 'Premium (1001-2000)'
        ELSE 'Luxury (Above 2000)'
    END AS Price_Bucket,
    COUNT(RestaurantName) AS Number_of_Restaurants
FROM zomato_data
GROUP BY Price_Bucket
ORDER BY Number_of_Restaurants DESC;

#8--------------------------------------------
SELECT   
    Has_Table_booking,
    COUNT(*) AS Number_of_Restaurants,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS Percentage
FROM zomato_data
GROUP BY Has_Table_booking;

#9--------------------------------------
SELECT   
    Has_Online_delivery,
    COUNT(*) AS Number_of_Restaurants,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS Percentage
FROM zomato_data
GROUP BY Has_Online_delivery;
