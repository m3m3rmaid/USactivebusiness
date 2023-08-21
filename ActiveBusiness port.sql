--Listing of Active Businesses Metadata Updated: June 17, 2023 Listing of all active businesses in city of Los Angeles currently registered with the Office of Finance, United States. 
-- From website (https://catalog.data.gov/dataset/listing-of-active-businesses)
--An "active" business is defined as a registered business whose owner has not notified the Office of Finance of a cease of business operations. Update Interval: Monthly.

SELECT TOP(100)*
  FROM [PortProject].[dbo].[ActiveBusiness$]


-- What we originally notice from raw data

--Total active business is 572695
SELECT COUNT(LOCATIONACCOUNT)
  FROM [PortProject].[dbo].[ActiveBusiness$]
  WHERE NAICS is NULL

 -- 62538 ACCOUNTS have NO NAICS which is 10 percentage

 SELECT TOP(1000)*
  FROM [PortProject].[dbo].[ActiveBusiness$]
  WHERE NAICS is NULL

 SELECT COUNT(LOCATIONACCOUNT)
  FROM [PortProject].[dbo].[ActiveBusiness$]
  WHERE LOCATIONSTARTDATE is NULL


  -- 191978 ACCOUNTS have no exact locationstartdate but still active which is 33.5 %

 SELECT COUNT(LOCATIONACCOUNT)
  FROM [PortProject].[dbo].[ActiveBusiness$]
  WHERE ZIPCODE <> MAILINGZIPCODE

-- 179240 ACCOUNT has different address for mailing and operative location


--- Clean the data

-- Standardize Date Format
Select LOCATIONSTARTDATE, Convert(date,LOCATIONSTARTDATE)
From PortProject.dbo.ActiveBusiness$

ALTER TABLE PortProject.dbo.ActiveBusiness$
Add StartDateConverted Date;

Update PortProject.dbo.ActiveBusiness$
Set StartDateConverted = Convert(date,Convert(date,LOCATIONSTARTDATE))

-----------------------------------------------------------------------------------------------------
--USE UPPER LETTER FOR StreetAddress CITY, Mailling Address, MailingCity

Select STREETADDRESS, UPPER(STREETADDRESS) , CITY, UPPER(CITY) , 
		MAILINGADDRESS, UPPER(MAILINGADDRESS) ,MAILINGCITY,UPPER(MAILINGCITY)
FROM PortProject.dbo.ActiveBusiness$

ALTER TABLE PortProject.dbo.ActiveBusiness$
Add StreetAddressConverted nvarchar(255),
	CityConverted nvarchar(255),
	MailingAddressConverted nvarchar(255),
	MailingCityConverted nvarchar(255);

Update PortProject.dbo.ActiveBusiness$
Set StreetAddressConverted = UPPER(STREETADDRESS),
	CityConverted = UPPER(CITY),
	MailingAddressConverted = UPPER(MAILINGADDRESS),
	MailingCityConverted = UPPER(MAILINGCITY)


Select Top(100) *
FROM PortProject.dbo.ActiveBusiness$
-----------------------------------------------------------------------------------------------------
---Analyse the data

--- Which are the top 10 most active businesses
With Totalbiz AS(
	SELECT Distinct(NAICS), Count(BUSINESSNAME) AS NumberBusiness
	FROM [PortProject].[dbo].[ActiveBusiness$] 
	GROUP BY NAICS)
Select sum(Numberbusiness) AS TotalBusiness
From Totalbiz

SELECT Distinct(NAICS), Count(BUSINESSNAME) AS NumberBusiness
	FROM [PortProject].[dbo].[ActiveBusiness$] 
	WHERE NAICS is not NULL
	GROUP BY NAICS
	ORDER BY NumberBusiness DESC


-- Calculate the portion of businesses in each NAICS code and pinpoint both the highest and lowest 10 performing businesses.
WITH Totalbizz AS (
    SELECT DISTINCT NAICS, COUNT(BUSINESSNAME) AS NumberBusiness
    FROM [PortProject].[dbo].[ActiveBusiness$]
    GROUP BY NAICS
)
SELECT NAICS, CAST(NumberBusiness * 100.0 / (SELECT SUM(NumberBusiness) FROM Totalbizz) AS DECIMAL(10, 2)) AS PercentageTotal
FROM Totalbizz
ORDER BY PercentageTotal DESC

-- 10.92 % of active business has no NAICS


WITH Totalbizz AS (
    SELECT DISTINCT NAICS, COUNT(BUSINESSNAME) AS NumberBusiness
    FROM [PortProject].[dbo].[ActiveBusiness$]
	WHERE NAICS is not NULL
    GROUP BY NAICS
)
SELECT  NAICS, CAST(NumberBusiness * 100.0 / (SELECT SUM(NumberBusiness) FROM Totalbizz) AS DECIMAL(10, 2)) AS PercentageTotal
FROM Totalbizz 
ORDER BY PercentageTotal DESC



---bottom 10 businesses

WITH Totalbizz AS (
    SELECT DISTINCT NAICS, COUNT(BUSINESSNAME) AS NumberBusiness
    FROM [PortProject].[dbo].[ActiveBusiness$]
	WHERE NAICS is not NULL
    GROUP BY NAICS
)
SELECT  NAICS, CAST(NumberBusiness * 100.0 / (SELECT SUM(NumberBusiness) FROM Totalbizz) AS DECIMAL(10, 2)) AS PercentageTotal
FROM Totalbizz 
ORDER BY PercentageTotal;

-----------------------
--- Average business life span for each distinct NAICS code, along with its description. 

SELECT NAICS, PRIMARYNAICSDESCRIPTION, AVG(YearinBiz) AS AvgLifeSpan
FROM [PortProject].[dbo].[ActiveBusiness$]
WHERE NAICS IS NOT NULL
GROUP BY NAICS, PRIMARYNAICSDESCRIPTION
ORDER BY AvgLifeSpan DESC;

-----------------------
--district that has business operate the most and least
SELECT CITY, COUNT(CITY) AS BizinCity
    FROM [PortProject].[dbo].[ActiveBusiness$]
	WHERE NAICS is not NULL
	GROUP BY CITY
	ORDER BY BizinCity DESC

--- TOP 10 active biz are in LA

------------------------------------------------
--Breaking location into latitude and longitude

SELECT 
  SUBSTRING(location, 2, CHARINDEX(',', location) - 2) AS Latitude,
  SUBSTRING(location, CHARINDEX(',', location) + 2, LEN(location) - CHARINDEX(',', location) - 2) AS Longitude
FROM [PortProject].[dbo].[ActiveBusiness$]

ALTER TABLE PortProject.dbo.ActiveBusiness$
Add Latitude float ,
	Longitude float;

Update PortProject.dbo.ActiveBusiness$
Set Latitude = SUBSTRING(location, 2, CHARINDEX(',', location) - 2),
	Longitude = SUBSTRING(location, CHARINDEX(',', location) + 2, LEN(location) - CHARINDEX(',', location) - 2);

------------------------------------------------
--Breaking Locationstartdate to year in order to see how many years business operated, How many years is oldest and 
SELECT SUBSTRING(CONVERT(VARCHAR, LOCATIONSTARTDATE, 120), 1, CHARINDEX('-', CONVERT(VARCHAR, LOCATIONSTARTDATE, 120))-1) AS StartYear
FROM PortProject.dbo.ActiveBusiness$;

ALTER TABLE PortProject.dbo.ActiveBusiness$
Add StartYear int,
	YearinBiz int

Update PortProject.dbo.ActiveBusiness$
Set StartYear = SUBSTRING(CONVERT(VARCHAR, LOCATIONSTARTDATE, 120), 1, CHARINDEX('-', CONVERT(VARCHAR, LOCATIONSTARTDATE, 120))-1)
	

Update PortProject.dbo.ActiveBusiness$
Set YearinBiz = 2023-StartYear

-----------------------------------------------------------------------------------------

--Location for map

SELECT CITY, LOCATION, COUNT(BUSINESSNAME) AS NumberBusiness
FROM [PortProject].[dbo].[ActiveBusiness$]
WHERE NAICS IS NOT NULL AND LOCATION IS NOT NULL AND LOCATION != '(0.0, 0.0)'
GROUP BY LOCATION,CITY
ORDER BY NumberBusiness DESC;


---------------------------------------------------------------------------------------


--Delete Unused Columns LOCATIONDESCRIPTION, LOCATIONENDDATE
Select *
From [PortProject].[dbo].[ActiveBusiness$]

Alter Table  [PortProject].[dbo].[ActiveBusiness$]
Drop Column LOCATIONENDDATE

Alter Table  [PortProject].[dbo].[ActiveBusiness$]
Drop Column STREETADDRESS, LOCATIONDESCRIPTION,LOCATIONSTARTDATE
