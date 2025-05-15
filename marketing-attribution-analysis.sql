# 📊 Marketing Attribution & ROI Model

-- This project analyzes marketing channel performance using a synthetic dataset of 5,000 records. Built using **MySQL, Excel, and Power BI**, it helps assess spend efficiency, campaign ROI, and conversion insights.

 -- Tools Used

-- MySQL (ETL + Querying)
-- Microsoft Excel (Data Cleaning + Calculations)

create database marketing_db ;

USE marketing_db;

CREATE TABLE marketing_attribution (
     UserID INT,
     Date DATE,
     Channel VARCHAR(50),
     Campaign VARCHAR(100),
     Impressions INT,
     Clicks INT,
     Conversions INT,
     Cost DECIMAL(10,2)
);

INSERT INTO marketing_attribution VALUES
(1, '2024-12-05', 'Email', 'Summer Sale', 10, 3, 0, 24.50),
(1, '2024-12-07', 'Google Ads', 'Holiday Blast', 7, 2, 1, 21.35),
(2, '2024-12-12', 'Social Media', 'Flash Deal', 15, 4, 0, 34.75),
(3, '2024-12-15', 'Affiliate', 'Weekend Promo', 5, 1, 0, 10.50),
(4, '2024-12-18', 'Direct', 'New Arrivals', 8, 2, 1, 19.60);

-- Total spend by channel

SELECT Channel, SUM(Cost) AS TotalSpend
FROM marketing_attribution
GROUP BY Channel
ORDER BY TotalSpend DESC;

--  Total conversions and conversion rate per channel

SELECT
  Channel,
  SUM(Conversions) AS TotalConversions,
  SUM(Clicks) AS TotalClicks,
  ROUND(SUM(Conversions)/NULLIF(SUM(Clicks),0)*100, 2) AS ConversionRatePct
FROM marketing_attribution
GROUP BY Channel
ORDER BY ConversionRatePct DESC;

--  Cost per acquisition (CPA) by campaign

SELECT
  Campaign,
  SUM(Cost) / NULLIF(SUM(Conversions), 0) AS CPA
FROM marketing_attribution
GROUP BY Campaign
HAVING SUM(Conversions) > 0
ORDER BY CPA ASC;

--  Monthly spend trend by channel

SELECT
  DATE_FORMAT(Date, '%Y-%m') AS YearMonth,
  Channel,
  SUM(Cost) AS MonthlySpend
FROM marketing_attribution
GROUP BY YearMonth, Channel
ORDER BY YearMonth, Channel;

--  Top 5 campaigns by conversions

SELECT Campaign, SUM(Conversions) AS TotalConversions
FROM marketing_attribution
GROUP BY Campaign
ORDER BY TotalConversions DESC
LIMIT 5;

--  Click-through rate (CTR) per channel

SELECT
  Channel,
  ROUND(SUM(Clicks)/NULLIF(SUM(Impressions),0)*100, 2) AS CTR_Pct
FROM marketing_attribution
GROUP BY Channel
ORDER BY CTR_Pct DESC;

--  Users with highest conversions

SELECT UserID, SUM(Conversions) AS TotalConversions
FROM marketing_attribution
GROUP BY UserID
ORDER BY TotalConversions DESC
LIMIT 10;

--  Average cost per click (CPC) by channel

SELECT
  Channel,
  ROUND(SUM(Cost)/NULLIF(SUM(Clicks),0), 2) AS AvgCPC
FROM marketing_attribution
GROUP BY Channel
ORDER BY AvgCPC;

--  Campaign effectiveness ranking (Conversions per Cost) 

SELECT
  Campaign,
  SUM(Conversions) / NULLIF(SUM(Cost), 0) AS ConversionsPerDollar
FROM marketing_attribution
GROUP BY Campaign
ORDER BY ConversionsPerDollar DESC;

--  Channels contributing to 80% of total spend (Pareto analysis)

SELECT Channel, SUM(Cost) AS Spend
FROM marketing_attribution
GROUP BY Channel
ORDER BY Spend DESC;
-- You would analyze cumulative sum outside SQL or with window functions.

--  Rolling 7-day average conversions per channel

SELECT
  Date,
  Channel,
  ROUND(AVG(Conversions) OVER (PARTITION BY Channel ORDER BY
      Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW),
         2) AS Rolling7DayConversions
FROM marketing_attribution
ORDER BY Channel, Date;

--  Average impressions per user

SELECT
  UserID,
  AVG(Impressions) AS AvgImpressions
FROM marketing_attribution
GROUP BY UserID
ORDER BY AvgImpressions DESC
LIMIT 10;

--  Calculate ROI assuming fixed revenue per conversion

SELECT
  Campaign,
  SUM(Conversions) * 100 AS Revenue,
  SUM(Cost) AS Spend,
  ROUND((SUM(Conversions)*100 - SUM(Cost)) / NULLIF(SUM(Cost),0) * 100, 2) AS ROI_Percent
FROM marketing_attribution
GROUP BY Campaign
ORDER BY ROI_Percent DESC;

--  Compare weekday vs weekend performance

SELECT
  CASE WHEN DAYOFWEEK(Date) IN (1,7) THEN 'Weekend' ELSE 'Weekday' END AS DayType,
  SUM(Conversions) AS TotalConversions,
  SUM(Cost) AS TotalSpend
FROM marketing_attribution
GROUP BY DayType;

--  Users with multiple campaign conversions

SELECT UserID, COUNT(DISTINCT Campaign) AS CampaignCount
FROM marketing_attribution
WHERE Conversions > 0
GROUP BY UserID
HAVING CampaignCount > 1
ORDER BY CampaignCount DESC;

