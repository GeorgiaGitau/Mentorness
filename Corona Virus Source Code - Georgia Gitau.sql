--1.Create a Corona Virus Table
CREATE TABLE Corona_Virus (
    Province VARCHAR,
    CountryRegion VARCHAR,
    Latitude FLOAT,
    Longitude FLOAT,
    Date DATE,
    Confirmed INTEGER,
    Deaths INTEGER,
    Recovered INTEGER);

--2.Check NULL values
SELECT *
FROM Corona_Virus
WHERE province IS NULL OR
      countryregion IS NULL OR
      latitude IS NULL OR
      longitude IS NULL OR
      date IS NULL OR
      confirmed IS NULL OR
      deaths IS NULL OR
      recovered IS NULL;

--3.Check total number of rows
SELECT COUNT(*) AS total_rows
FROM Corona_Virus;

--4.Check what is start_date and end_date
SELECT 
    MIN(date) AS start_date,
    MAX(date) AS end_date
FROM Corona_Virus;

--5.Number of month present in dataset
SELECT COUNT(DISTINCT EXTRACT(MONTH FROM date)) AS num_months
FROM Corona_Virus;

--6.Find monthly average for confirmed, deaths, recovered
SELECT 
    EXTRACT(YEAR FROM date) AS year,
    EXTRACT(MONTH FROM date) AS month,
    ROUND(AVG(confirmed), 0) AS avg_confirmed,
    ROUND(AVG(deaths), 0) AS avg_deaths,
    ROUND(AVG(recovered), 0) AS avg_recovered
FROM Corona_Virus
GROUP BY EXTRACT(YEAR FROM date), EXTRACT(MONTH FROM date)
ORDER BY year, month;

--7.Find most frequent value for confirmed, deaths, recovered each month
WITH MonthlyData AS (
    SELECT
        TO_CHAR(Date::date, 'YYYY-MM') AS YearMonth,
        Confirmed,
        Deaths,
        Recovered
    FROM
        Corona_Virus
),
Freq_Confirmed AS (
    SELECT
        YearMonth,
        Confirmed,
        COUNT(*) AS Frequency
    FROM
        MonthlyData
    GROUP BY
        YearMonth, Confirmed
    ORDER BY
        Frequency DESC
),
Freq_Deaths AS (
    SELECT
        YearMonth,
        Deaths,
        COUNT(*) AS Frequency
    FROM
        MonthlyData
    GROUP BY
        YearMonth, Deaths
    ORDER BY
        Frequency DESC
),
Freq_Recovered AS (
    SELECT
        YearMonth,
        Recovered,
        COUNT(*) AS Frequency
    FROM
        MonthlyData
    GROUP BY
        YearMonth, Recovered
    ORDER BY
        Frequency DESC
)
SELECT DISTINCT
    A.YearMonth,
    A.Confirmed AS Mode_Confirmed,
    B.Deaths AS Mode_Deaths,
    C.Recovered AS Mode_Recovered
FROM
    (SELECT * FROM Freq_Confirmed WHERE (YearMonth, Frequency) IN (SELECT YearMonth, MAX(Frequency) FROM Freq_Confirmed GROUP BY YearMonth)) A
    JOIN
    (SELECT * FROM Freq_Deaths WHERE (YearMonth, Frequency) IN (SELECT YearMonth, MAX(Frequency) FROM Freq_Deaths GROUP BY YearMonth)) B
    ON A.YearMonth = B.YearMonth
    JOIN
    (SELECT * FROM Freq_Recovered WHERE (YearMonth, Frequency) IN (SELECT YearMonth, MAX(Frequency) FROM Freq_Recovered GROUP BY YearMonth)) C
    ON A.YearMonth = C.YearMonth;

--8.Find minimum values for confirmed, deaths, recovered per year
SELECT 
	EXTRACT(YEAR FROM date) AS Year,
	MIN(Confirmed) AS Min_Confirmed,
	MIN(Deaths) AS Min_Deaths,
	MIN(Recovered) AS Min_Recovered
FROM Corona_Virus
WHERE Confirmed > 0 AND Deaths > 0 AND Recovered > 0
GROUP BY EXTRACT(YEAR FROM date)
ORDER BY Year;
  
--9.Find maximum values of confirmed, deaths, recovered per year
SELECT
  EXTRACT(YEAR FROM date) AS year,
  MAX(confirmed) AS min_confirmed,
  MAX(deaths) AS min_deaths,
  MAX(recovered) AS min_recovered
FROM Corona_Virus
GROUP BY EXTRACT(YEAR FROM date)
ORDER BY year;

--10.The total number of case of confirmed, deaths, recovered each month
SELECT EXTRACT(YEAR FROM date) AS Year,
       EXTRACT(MONTH FROM date) AS Month,
       SUM(Confirmed) AS Total_Confirmed,
       SUM(Deaths) AS Total_Deaths,
       SUM(Recovered) AS Total_Recovered
FROM Corona_Virus
GROUP BY EXTRACT(YEAR FROM date), EXTRACT(MONTH FROM date)
ORDER BY Year, Month;

--11.Check how corona virus spread out with respect to confirmed case
--   (Eg.: total confirmed cases, their average, variance & STDEV )
SELECT
    COUNT(*) AS Total_Cases,
    ROUND(AVG(Confirmed),0) AS Average_Confirmed,
    ROUND(VARIANCE(Confirmed),0) AS Variance_Confirmed,
    ROUND(STDDEV(Confirmed),0) AS Std_Dev_Confirmed
FROM
    Corona_Virus;

--12.Check how corona virus spread out with respect to death case per month
--      (Eg.: total confirmed cases, their average, variance & STDEV )
SELECT
    EXTRACT(YEAR FROM date) AS Year,
    EXTRACT(MONTH FROM date) AS Month,
    ROUND(COUNT(*), 0) AS Total_Cases,
    ROUND(AVG(Deaths), 0) AS Average_Deaths,
    ROUND(VARIANCE(Deaths), 0) AS Variance_Deaths,
    ROUND(STDDEV(Deaths), 0) AS Std_Dev_Deaths
FROM
    Corona_Virus
GROUP BY
    EXTRACT(YEAR FROM date),
    EXTRACT(MONTH FROM date)
ORDER BY
    Year, Month;

--13.Check how corona virus spread out with respect to recovered case
--      (Eg.: total confirmed cases, their average, variance & STDEV )
SELECT
    COUNT(*) AS Total_Cases,
    ROUND(AVG(Recovered), 0) AS Average_Recovered,
    ROUND(VARIANCE(Recovered), 0) AS Variance_Recovered,
    ROUND(STDDEV(Recovered), 0) AS Std_Dev_Recovered
FROM
    Corona_Virus;

--14.Find Country having highest number of the Confirmed case
SELECT CountryRegion, 
	SUM(Confirmed) AS Total_Confirmed
FROM Corona_Virus
GROUP BY CountryRegion
ORDER BY Total_Confirmed DESC
LIMIT 1;

--15.Find Country having lowest number of the death case
SELECT CountryRegion,
	SUM(Deaths) AS Total_Deaths
FROM Corona_Virus
GROUP BY CountryRegion
ORDER BY Total_Deaths
LIMIT 1;

--16.Find top 5 countries having highest recovered case
SELECT CountryRegion,
	SUM(Recovered) AS Total_Recovered
FROM Corona_Virus
GROUP BY CountryRegion
ORDER BY Total_Recovered DESC
LIMIT 5;