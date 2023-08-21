/*

Queries used for Tableau Project

*/

-- 1. Total registered active business with NAICS industry code

SELECT COUNT(LOCATIONACCOUNT) as TotalBusiness
  FROM [PortProject].[dbo].[ActiveBusiness$]
  WHERE NAICS is not null

--2.Which are the top 10 most active businesses by NAICS code?


WITH Totalbiz AS (
    SELECT DISTINCT NAICS, COUNT(BUSINESSNAME) AS NumberBusiness
    FROM [PortProject].[dbo].[ActiveBusiness$]
    WHERE NAICS IS NOT NULL
    GROUP BY NAICS
)
SELECT SUM(Numberbusiness) AS TotalBusiness
FROM Totalbiz;

WITH TopNAICS AS (
    SELECT DISTINCT TOP 10 NAICS, COUNT(BUSINESSNAME) AS NumberBusiness, PRIMARYNAICSDESCRIPTION
    FROM [PortProject].[dbo].[ActiveBusiness$]
    WHERE NAICS IS NOT NULL
    GROUP BY NAICS, PRIMARYNAICSDESCRIPTION
    ORDER BY NumberBusiness DESC
)
SELECT *
FROM TopNAICS;

--3. Which are the bottom 10 least active businesses by NAICS code?

WITH Totalbiz AS (
    SELECT DISTINCT NAICS, COUNT(BUSINESSNAME) AS NumberBusiness
    FROM [PortProject].[dbo].[ActiveBusiness$]
    WHERE NAICS IS NOT NULL
    GROUP BY NAICS
)
SELECT SUM(Numberbusiness) AS TotalBusiness
FROM Totalbiz;

WITH BottomNAICS AS (
    SELECT DISTINCT TOP 10 NAICS, COUNT(BUSINESSNAME) AS NumberBusiness, PRIMARYNAICSDESCRIPTION
    FROM [PortProject].[dbo].[ActiveBusiness$]
    WHERE NAICS IS NOT NULL
    GROUP BY NAICS, PRIMARYNAICSDESCRIPTION
    ORDER BY NumberBusiness ASC -- Order in ascending to get the bottom 10
)
SELECT *
FROM BottomNAICS;

--4 Average business life span of each NAICS


SELECT NAICS, PRIMARYNAICSDESCRIPTION, AVG(YearinBiz) AS AvgLifeSpan
FROM [PortProject].[dbo].[ActiveBusiness$]
WHERE NAICS IS NOT NULL
GROUP BY NAICS, PRIMARYNAICSDESCRIPTION
ORDER BY AvgLifeSpan DESC;

--5. District with the highest business activity to lowest.
SELECT CITY, COUNT(CITY) AS BizinCity
    FROM [PortProject].[dbo].[ActiveBusiness$]
	WHERE NAICS is not NULL
	GROUP BY CITY
	ORDER BY BizinCity DESC

--6. Location 

SELECT CITY, LOCATION, COUNT(BUSINESSNAME) AS NumberBusiness
FROM [PortProject].[dbo].[ActiveBusiness$]
WHERE NAICS IS NOT NULL AND LOCATION IS NOT NULL AND LOCATION != '(0.0, 0.0)'
GROUP BY LOCATION,CITY
ORDER BY NumberBusiness DESC;