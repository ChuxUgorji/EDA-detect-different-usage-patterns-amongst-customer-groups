-- DATA PREPARATION, CLEANING AND TRANSFORMATION

## PREPARATION
-- script to check if imported data is complete
SELECT COUNT (ride_id)
FROM `bike-share-marketing-campaign.bike_share.January22_bike_share`; -- change table for each month

-- script to test if start_station and end_station data could be used in this project given a lot of observed missing data
-- there are 692 docking stations tracked by geotracking, hence we should have 692 unique station names or id if properly captured.
## Result: we have different number of station_names/id and over 692. We won't be able to use this data. Data for these fields are incosistent
-- I'd recommend improvement on geotracking to capture location record with better integrity.

SELECT COUNT (DISTINCT start_station_name) -- test with both station id and station name if either works
FROM `bike_share.September22_bike_share` -- flip between months to check if we have consistent numbers

-- script to append all tables with relevant data:
-- ride_id, member_casual, rideable_type, started_at, ended_at and forming a new temporary table Year22_bike_share

WITH Year22_bike_share AS (
  SELECT ride_id, member_casual, rideable_type, started_at, ended_at
  FROM `bike-share-marketing-campaign.bike_share.January22_bike_share`
  UNION ALL
  SELECT ride_id, member_casual, rideable_type, started_at, ended_at
  FROM `bike-share-marketing-campaign.bike_share.February22_bike_share`
  UNION ALL
  SELECT ride_id, member_casual, rideable_type, started_at, ended_at
  FROM `bike-share-marketing-campaign.bike_share.March22_bike_share`
  UNION ALL
  SELECT ride_id, member_casual, rideable_type, started_at, ended_at
  FROM `bike-share-marketing-campaign.bike_share.April22_bike_share`
  UNION ALL
  SELECT ride_id, member_casual, rideable_type, started_at, ended_at
  FROM `bike-share-marketing-campaign.bike_share.May22_bike_share`
  UNION ALL
  SELECT ride_id, member_casual, rideable_type, started_at, ended_at
  FROM `bike-share-marketing-campaign.bike_share.June22_bike_share`
  UNION ALL
  SELECT ride_id, member_casual, rideable_type, started_at, ended_at
  FROM `bike-share-marketing-campaign.bike_share.July22_bike_share`
  UNION ALL
  SELECT ride_id, member_casual, rideable_type, started_at, ended_at
  FROM `bike-share-marketing-campaign.bike_share.August22_bike_share`
  UNION ALL
  SELECT ride_id, member_casual, rideable_type, started_at, ended_at
  FROM `bike-share-marketing-campaign.bike_share.September22_bike_share`
  UNION ALL
  SELECT ride_id, member_casual, rideable_type, started_at, ended_at
  FROM `bike-share-marketing-campaign.bike_share.October22_bike_share`
  UNION ALL
  SELECT ride_id, member_casual, rideable_type, started_at, ended_at
  FROM `bike-share-marketing-campaign.bike_share.November22_bike_share`
  UNION ALL
  SELECT ride_id, member_casual, rideable_type, started_at, ended_at
  FROM `bike-share-marketing-campaign.bike_share.December22_bike_share`
)

SELECT *
FROM Year22_bike_share; -- saved as new table to be cleaned and transformed


-- script to test for complete data in append table Year22_bike_share
SELECT COUNT (ride_id)
FROM `bike-share-marketing-campaign.bike_share.Year22_bike_share`

## CLEANING
-- Test to check if duplicate records exist
## Result: NO DUPLICATES
SELECT COUNT (DISTINCT ride_id)
FROM `bike-share-marketing-campaign.bike_share.Year22_bike_share`

-- Test for consistent data (consistent spelling, extra/special characters) across rideable_type
## Result: rideable_type (data has an inaccurate category docked_bike): docked_bike, classic_bike, electric_bike
## docked_bike: these rideable_type appears incosistent, occurs only for casual members even though with travel times.
## The business also acknowledges it's bike offering are classic and electric bikes.Typically docked_bike should be bikes not in use.
## We would filter off these data as it might bias the data

SELECT DISTINCT (rideable_type) as bike_type
FROM `bike-share-marketing-campaign.bike_share.Year22_bike_share`

-- script to further investigate docked_bike type
SELECT rideable_type, member_casual, COUNT (*) AS number_of_members
FROM `bike_share.Year22_bike_share`
GROUP BY rideable_type, member_casual

-- Test for consistent data (consitent spelling, extra/special characters) across member_casual
## Result: member_casual (data is consistent): casual, member
SELECT DISTINCT (member_casual) as membership_type
FROM `bike-share-marketing-campaign.bike_share.Year22_bike_share`

-- Test each column if missing data exists for each field
## ride_id: none exists
## member_casual: none exists
## rideable_type: none exists
## started_at: none exists
## ended_at: none exists

SELECT started_at -- change field
FROM `bike-share-marketing-campaign.bike_share.Year22_bike_share`
WHERE started_at IS NULL; -- change field

-- script to evaluate if there exists any record where started_at is greater than (and equal to) ended_at
## Result: > Yes there exist 100 records where started_at is greater than ended_at
## Result: = Yes there exist 431 records where started_at is equal to ended_at
SELECT started_at, ended_at
FROM `bike-share-marketing-campaign.bike_share.Year22_bike_share`
WHERE started_at > ended_at -- change conditional operator to = for second test result


-- script to update Year22_bike_share table to correct records where started_at > ended_at by swapping those records
UPDATE `bike-share-marketing-campaign.bike_share.Year22_bike_share`
SET started_at = ended_at, ended_at = started_at
WHERE started_at > ended_at

-- script to drop off records where started_at = ended_at from Year22_bike_share table. The assumption is that these rides didn't happen
DELETE FROM `bike_share.Year22_bike_share`
WHERE started_at = ended_at

## TRANSFORM
-- Transform Year22_bike_share table to include the following calculated fields:
## travel_time - in minutes (use Timestamp_Diff) - we are basing in minutes since this is a more logical minimum baseline for most travel
## Clock in hours/time (Use Extract for hours, Extract and Trunc for time)
## Clock in Day (Use Extract DayofWeek and a nested query using CASE WHEN)
## Season (Use CASE WHEN with started_at)

SELECT *,
      TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS travel_time_in_minutes,
      EXTRACT (HOUR FROM started_at) AS clock_in_hour, TIME_TRUNC (EXTRACT (TIME FROM started_at), MINUTE) AS clock_in_time,
      EXTRACT (DAYOFWEEK FROM started_at) AS day_of_week,
      CASE WHEN (CAST(started_at AS DATE) BETWEEN '2022-01-01' AND '2022-03-19') OR (CAST(started_at AS DATE) BETWEEN '2022-12-21' AND '2022-12-31') THEN "Winter"
          WHEN CAST(started_at AS DATE) BETWEEN '2022-03-20' AND '2022-06-20' THEN "Spring"
          WHEN CAST(started_at AS DATE) BETWEEN '2022-06-21' AND '2022-09-22' THEN "Summer"
          WHEN CAST(started_at AS DATE) BETWEEN '2022-09-23' AND '2022-12-20' THEN "Autumn" -- CAST func used to convert timestamp to date inorder to include upper date range when evaluating case statement
          ELSE "missed_range"
          END AS season_of_the_year
FROM `bike_share.Year22_bike_share`

## Test season_of_the_year categorisation
## RESULT: all seasons are correctly categorised to corresponding date range
-- Test 1: to test that each date range corresponds to the correct season
SELECT MIN (started_at) AS Min_date, MAX (started_at) AS Max_date,
FROM (SELECT *,
      TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS travel_time_in_minutes,
      EXTRACT (HOUR FROM started_at) AS clock_in_hour, TIME_TRUNC (EXTRACT (TIME FROM started_at), MINUTE) AS clock_in_time,
      EXTRACT (DAYOFWEEK FROM started_at) AS day_of_week,
      CASE WHEN (CAST(started_at AS DATE) BETWEEN '2022-01-01' AND '2022-03-19') OR (CAST(started_at AS DATE) BETWEEN '2022-12-21' AND '2022-12-31') THEN "Winter"
           WHEN CAST(started_at AS DATE) BETWEEN '2022-03-20' AND '2022-06-20' THEN "Spring"
          WHEN CAST(started_at AS DATE) BETWEEN '2022-06-21' AND '2022-09-22' THEN "Summer"
          WHEN CAST(started_at AS DATE) BETWEEN '2022-09-23' AND '2022-12-20' THEN "Autumn" -- CAST func used to convert timestamp to date inorder to include upper date range when evaluating case statement
          ELSE "missed_range"
          END AS season_of_the_year
    FROM `bike_share.Year22_bike_share`) AS test_transform_table
WHERE season_of_the_year = "Spring" -- modify to season_of_the_year (Spring, Summer, Autumn, Winter)

-- Test 2: to test that we do not have any missed_range in the category, and that only 4 seasons exists
SELECT DISTINCT season_of_the_year
FROM (SELECT *,
        TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS travel_time_in_minutes,
        EXTRACT (HOUR FROM started_at) AS clock_in_hour, TIME_TRUNC (EXTRACT (TIME FROM started_at), MINUTE) AS clock_in_time,
        EXTRACT (DAYOFWEEK FROM started_at) AS day_of_week,
        CASE WHEN (CAST(started_at AS DATE) BETWEEN '2022-01-01' AND '2022-03-19') OR (CAST(started_at AS DATE) BETWEEN '2022-12-21' AND '2022-12-31') THEN "Winter"
            WHEN CAST(started_at AS DATE) BETWEEN '2022-03-20' AND '2022-06-20' THEN "Spring"
            WHEN CAST(started_at AS DATE) BETWEEN '2022-06-21' AND '2022-09-22' THEN "Summer"
            WHEN CAST(started_at AS DATE) BETWEEN '2022-09-23' AND '2022-12-20' THEN "Autumn" -- CAST func used to convert timestamp to date inorder to include upper date range when evaluating case statement
            ELSE "missed_range"
            END AS season_of_the_year
      FROM `bike_share.Year22_bike_share`) AS test_transform_table

-- Test 3: to test that the season winter has no categorisation outside the date range 2022-12-21 - 2022-03-19 or exist between the spring (2022-03-20) to Autumn (2022-12-20) date range
--         this follow up test is to double check since the date range test in test 1 reflects a min and max date range equal to the start and end date of the year.
SELECT DISTINCT season_of_the_year
FROM (SELECT *,
        TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS travel_time_in_minutes,
        EXTRACT (HOUR FROM started_at) AS clock_in_hour, TIME_TRUNC (EXTRACT (TIME FROM started_at), MINUTE) AS clock_in_time,
        EXTRACT (DAYOFWEEK FROM started_at) AS day_of_week,
        CASE WHEN (CAST(started_at AS DATE) BETWEEN '2022-01-01' AND '2022-03-19') OR (CAST(started_at AS DATE) BETWEEN '2022-12-21' AND '2022-12-31') THEN "Winter"
            WHEN CAST(started_at AS DATE) BETWEEN '2022-03-20' AND '2022-06-20' THEN "Spring"
            WHEN CAST(started_at AS DATE) BETWEEN '2022-06-21' AND '2022-09-22' THEN "Summer"
            WHEN CAST(started_at AS DATE) BETWEEN '2022-09-23' AND '2022-12-20' THEN "Autumn" -- CAST func used to convert timestamp to date inorder to include upper date range when evaluating case statement
            ELSE "missed_range"
            END AS season_of_the_year
      FROM `bike_share.Year22_bike_share`) AS test_transform_table
WHERE CAST (started_at AS DATE) BETWEEN '2022-03-20' AND '2022-12-20'


## Test Day of Week
## RESULT: There are 7 distinct day_of_week ranging from 1-7
-- test that there are 7 distinct day_of_week ranging from 1-7
SELECT DISTINCT day_of_week
FROM (SELECT *,
      TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS travel_time_in_minutes,
      EXTRACT (HOUR FROM started_at) AS clock_in_hour, TIME_TRUNC (EXTRACT (TIME FROM started_at), MINUTE) AS clock_in_time,
      EXTRACT (DAYOFWEEK FROM started_at) AS day_of_week,
      CASE WHEN (CAST(started_at AS DATE) BETWEEN '2022-01-01' AND '2022-03-19') OR (CAST(started_at AS DATE) BETWEEN '2022-12-21' AND '2022-12-31') THEN "Winter"
          WHEN CAST(started_at AS DATE) BETWEEN '2022-03-20' AND '2022-06-20' THEN "Spring"
          WHEN CAST(started_at AS DATE) BETWEEN '2022-06-21' AND '2022-09-22' THEN "Summer"
          WHEN CAST(started_at AS DATE) BETWEEN '2022-09-23' AND '2022-12-20' THEN "Autumn" -- CAST func used to convert timestamp to date inorder to include upper date range when evaluating case statement
          ELSE "missed_range"
          END AS season_of_the_year
      FROM `bike_share.Year22_bike_share`) as test_transform_table
ORDER BY day_of_week

## Test Clock in hours & time
-- Test 1: test that there are 24 distinct hours ranging from 0-23
SELECT DISTINCT clock_in_hour
FROM (SELECT *,
      TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS travel_time_in_minutes,
      EXTRACT (HOUR FROM started_at) AS clock_in_hour, TIME_TRUNC (EXTRACT (TIME FROM started_at), MINUTE) AS clock_in_time,
      EXTRACT (DAYOFWEEK FROM started_at) AS day_of_week,
      CASE WHEN (CAST(started_at AS DATE) BETWEEN '2022-01-01' AND '2022-03-19') OR (CAST(started_at AS DATE) BETWEEN '2022-12-21' AND '2022-12-31') THEN "Winter"
          WHEN CAST(started_at AS DATE) BETWEEN '2022-03-20' AND '2022-06-20' THEN "Spring"
          WHEN CAST(started_at AS DATE) BETWEEN '2022-06-21' AND '2022-09-22' THEN "Summer"
          WHEN CAST(started_at AS DATE) BETWEEN '2022-09-23' AND '2022-12-20' THEN "Autumn" -- CAST func used to convert timestamp to date inorder to include upper date range when evaluating case statement
          ELSE "missed_range"
          END AS season_of_the_year
      FROM `bike_share.Year22_bike_share`) as test_transform_table
ORDER BY clock_in_hour

-- Test 2: test that the min and max time range are 00:00:00 and 23:59:00 respectively
SELECT MIN (clock_in_time) AS min_clock_in_time, MAX (clock_in_time) AS max_clock_in_time
FROM (SELECT *,
      TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS travel_time_in_minutes,
      EXTRACT (HOUR FROM started_at) AS clock_in_hour, TIME_TRUNC (EXTRACT (TIME FROM started_at), MINUTE) AS clock_in_time,
      EXTRACT (DAYOFWEEK FROM started_at) AS day_of_week,
      CASE WHEN (CAST(started_at AS DATE) BETWEEN '2022-01-01' AND '2022-03-19') OR (CAST(started_at AS DATE) BETWEEN '2022-12-21' AND '2022-12-31') THEN "Winter"
          WHEN CAST(started_at AS DATE) BETWEEN '2022-03-20' AND '2022-06-20' THEN "Spring"
          WHEN CAST(started_at AS DATE) BETWEEN '2022-06-21' AND '2022-09-22' THEN "Summer"
          WHEN CAST(started_at AS DATE) BETWEEN '2022-09-23' AND '2022-12-20' THEN "Autumn" -- CAST func used to convert timestamp to date inorder to include upper date range when evaluating case statement
          ELSE "missed_range"
          END AS season_of_the_year
      FROM `bike_share.Year22_bike_share`) as test_transform_table

## Test travel_time_in_minutes
-- Test 1: test if there are records with less than 1 minute, hence travel_time_in_minutes = 0
## RESULT: Yes, there are records with less than 1 minute travel (0 minutes).
-- when checked what could lead to such rides these observations came in
-- that rides less than 1 minute are either due to continuation rides from riders who want to avoid extra charges, other explanations could be
-- riders who didn't eventually take on their full rides as planned, or riders who noticed fault with bikes
-- Action: Caveat to filter off to avoid biasing the data
SELECT MIN (travel_time_in_minutes) AS min_travel_time, MAX (travel_time_in_minutes) AS max_travel_time
FROM (SELECT *,
      TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS travel_time_in_minutes,
      EXTRACT (HOUR FROM started_at) AS clock_in_hour, TIME_TRUNC (EXTRACT (TIME FROM started_at), MINUTE) AS clock_in_time,
      EXTRACT (DAYOFWEEK FROM started_at) AS day_of_week,
      CASE WHEN (CAST(started_at AS DATE) BETWEEN '2022-01-01' AND '2022-03-19') OR (CAST(started_at AS DATE) BETWEEN '2022-12-21' AND '2022-12-31') THEN "Winter"
          WHEN CAST(started_at AS DATE) BETWEEN '2022-03-20' AND '2022-06-20' THEN "Spring"
          WHEN CAST(started_at AS DATE) BETWEEN '2022-06-21' AND '2022-09-22' THEN "Summer"
          WHEN CAST(started_at AS DATE) BETWEEN '2022-09-23' AND '2022-12-20' THEN "Autumn" -- CAST func used to convert timestamp to date inorder to include upper date range when evaluating case statement
          ELSE "missed_range"
          END AS season_of_the_year
      FROM `bike_share.Year22_bike_share`) as test_transform_table


## FULL TABLE TRANSFORMATION FOR ANALYSIS
-- expand Day_of_week into clock_in_day, expressed as Sunday, Monday, ..., Saturday
SELECT *,
      CASE WHEN day_of_week = 1 THEN "Sunday"
            WHEN day_of_week = 2 THEN "Monday"
            WHEN day_of_week = 3 THEN "Tuesday"
            WHEN day_of_week = 4 THEN "Wednesday"
            WHEN day_of_week = 5 THEN "Thursday"
            WHEN day_of_week = 6 THEN "Friday"
            WHEN day_of_week = 7 THEN "Saturday"
            ELSE "missed_cat"
            END AS clock_in_day
FROM (SELECT *,
      TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS travel_time_in_minutes,
      EXTRACT (HOUR FROM started_at) AS clock_in_hour, TIME_TRUNC (EXTRACT (TIME FROM started_at), MINUTE) AS clock_in_time,
      EXTRACT (DAYOFWEEK FROM started_at) AS day_of_week,
      CASE WHEN (CAST(started_at AS DATE) BETWEEN '2022-01-01' AND '2022-03-19') OR (CAST(started_at AS DATE) BETWEEN '2022-12-21' AND '2022-12-31') THEN "Winter"
          WHEN CAST(started_at AS DATE) BETWEEN '2022-03-20' AND '2022-06-20' THEN "Spring"
          WHEN CAST(started_at AS DATE) BETWEEN '2022-06-21' AND '2022-09-22' THEN "Summer"
          WHEN CAST(started_at AS DATE) BETWEEN '2022-09-23' AND '2022-12-20' THEN "Autumn" -- CAST func used to convert timestamp to date inorder to include upper date range when evaluating case statement
          ELSE "missed_range"
          END AS season_of_the_year
      FROM `bike_share.Year22_bike_share`) as test_transform_table -- FULL TABLE TRANSFORMATION FOR ANALYSIS

## Test if we have any missed_cat in clock_in_day
## RESULT: no missed_cat, clock_in_day correctly categorised
SELECT DISTINCT clock_in_day
FROM (SELECT *,
      CASE WHEN day_of_week = 1 THEN "Sunday"
            WHEN day_of_week = 2 THEN "Monday"
            WHEN day_of_week = 3 THEN "Tuesday"
            WHEN day_of_week = 4 THEN "Wednesday"
            WHEN day_of_week = 5 THEN "Thursday"
            WHEN day_of_week = 6 THEN "Friday"
            WHEN day_of_week = 7 THEN "Saturday"
            ELSE "missed_cat"
            END AS clock_in_day
      FROM (SELECT *,
            TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS travel_time_in_minutes,
            EXTRACT (HOUR FROM started_at) AS clock_in_hour, TIME_TRUNC (EXTRACT (TIME FROM started_at), MINUTE) AS clock_in_time,
            EXTRACT (DAYOFWEEK FROM started_at) AS day_of_week,
            CASE WHEN (CAST(started_at AS DATE) BETWEEN '2022-01-01' AND '2022-03-19') OR (CAST(started_at AS DATE) BETWEEN '2022-12-21' AND '2022-12-31') THEN "Winter"
                  WHEN CAST(started_at AS DATE) BETWEEN '2022-03-20' AND '2022-06-20' THEN "Spring"
                  WHEN CAST(started_at AS DATE) BETWEEN '2022-06-21' AND '2022-09-22' THEN "Summer"
                  WHEN CAST(started_at AS DATE) BETWEEN '2022-09-23' AND '2022-12-20' THEN "Autumn" -- CAST func used to convert timestamp to date inorder to include upper date range when evaluating case statement
                  ELSE "missed_range"
                  END AS season_of_the_year
            FROM `bike_share.Year22_bike_share`) as test_transform_table) AS test_table


--script to test day_of_week and clock_in_day are correctly categorised
## RESULT: correctly categorised
SELECT day_of_week, clock_in_day
FROM (SELECT *,
      CASE WHEN day_of_week = 1 THEN "Sunday"
            WHEN day_of_week = 2 THEN "Monday"
            WHEN day_of_week = 3 THEN "Tuesday"
            WHEN day_of_week = 4 THEN "Wednesday"
            WHEN day_of_week = 5 THEN "Thursday"
            WHEN day_of_week = 6 THEN "Friday"
            WHEN day_of_week = 7 THEN "Saturday"
            ELSE "missed_cat"
            END AS clock_in_day
      FROM (SELECT *,
            TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS travel_time_in_minutes,
            EXTRACT (HOUR FROM started_at) AS clock_in_hour, TIME_TRUNC (EXTRACT (TIME FROM started_at), MINUTE) AS clock_in_time,
            EXTRACT (DAYOFWEEK FROM started_at) AS day_of_week,
            CASE WHEN (CAST(started_at AS DATE) BETWEEN '2022-01-01' AND '2022-03-19') OR (CAST(started_at AS DATE) BETWEEN '2022-12-21' AND '2022-12-31') THEN "Winter"
                  WHEN CAST(started_at AS DATE) BETWEEN '2022-03-20' AND '2022-06-20' THEN "Spring"
                  WHEN CAST(started_at AS DATE) BETWEEN '2022-06-21' AND '2022-09-22' THEN "Summer"
                  WHEN CAST(started_at AS DATE) BETWEEN '2022-09-23' AND '2022-12-20' THEN "Autumn" -- CAST func used to convert timestamp to date inorder to include upper date range when evaluating case statement
                  ELSE "missed_range"
                  END AS season_of_the_year
            FROM `bike_share.Year22_bike_share`) as test_transform_table) AS test_table
GROUP BY clock_in_day, day_of_week
ORDER BY day_of_week

-- export and save as new table (full table transformation for analysis) as bike_share_analysis_table. Note that this new table still maintains travel-time_in_minutes = 0 and rideable_type = docked_bike,
-- they will both be filtered off during analysis

## ANALYSIS
## total number of useful data points for analysis across member groups
SELECT member_casual, COUNT (*) AS total
FROM `bike_share.bike_share_analysis_table`
WHERE travel_time_in_minutes != 0 AND rideable_type != "docked_bike"
GROUP BY member_casual

## 1 - Travel time: Is there a difference in the (average) travel time traveled between casual and annual members?
-- RESULT: casual members avg_ride_length = 21 mins ; members avg_ride_length = 13 mins

SELECT member_casual AS User_Group,
      ROUND (AVG(travel_time_in_minutes),0) AS average_ride_length
FROM `bike_share.bike_share_analysis_table`
WHERE travel_time_in_minutes != 0 AND rideable_type != "docked_bike"
GROUP BY User_Group

## 1b. Average travel time across both user groups by day
SELECT member_casual AS User_Group,
      clock_in_day AS Time_of_Day,
      ROUND (AVG(travel_time_in_minutes),0) AS average_ride_length
FROM `bike_share.bike_share_analysis_table`
WHERE travel_time_in_minutes != 0 AND rideable_type != "docked_bike"
GROUP BY User_Group, Time_of_Day

## 1c. Average travel time across both user groups by season of the year
SELECT member_casual AS User_Group,
      season_of_the_year AS Season,
      ROUND (AVG(travel_time_in_minutes),0) AS average_ride_length
FROM `bike_share.bike_share_analysis_table`
WHERE travel_time_in_minutes != 0 AND rideable_type != "docked_bike"
GROUP BY User_Group, Season
ORDER BY Season

-- move bike_share_analysis_table to Tabelau for analysis and visualization for time efficiency
