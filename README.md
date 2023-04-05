
# **Exploratory Data Analysis: Detect how different customer types use a bike sharing service differently. Done with SQL (BigQuery) & Tableau**


## **Project Background & Deliverable** 
In this project I was embedded within a marketing analytics team for a bike sharing company. The company had established that customers who opted in for annual subscription were more profitable to the business. The marketing team now  wants to pivot it’s marketing strategy to convert customers considered as casual subscribers into annual subscribers inorder to maximize future growth of the business. My role’s to help the business understand how annual subscribers and casual subscribers use their service differently, and my recommendations. From these insights the marketing team will design a new marketing strategy aimed to convert casual users to annual subscribers. 

Casual subscribers are users who would either opt in for a single ride or day subscription with access to use their classic bikes for either 30mins or 3 hours respectively at a paid fee. Alternatively they could pay to use their e-bikes at about $0.42/min. Annual subscribers paid a one time annual fee to use their classic bikes for 45 mins per ride or use an e-bike at a discounted rate of $0.17/minute.


## **Steps taken towards deliverable**
1. Stakeholder conversations to establish business question(s) & importance of the business question(s) to the business. 
2. Identify available data and relevance to the business question.
3. Extract and Prepare Data
4. Clean and Transform Data for analysis
5. Exploratory data analysis
6. Prepare executive summary on findings

## **Tools employed**
1. **SQL:** for loading data, cleaning, transformation and exploration
2. **Tableau:** for analysis, visualisation and executive story
3. **Google slides:** complementary tool for building out executive summary on tableau story.

## **Delivered Item**
[Executive summary on findings: Tableau story](https://public.tableau.com/shared/PRBD7FPH9?:display_count=n&:origin=viz_share_link)

This tableau story brings together all the analysis & visualisation done on tableau worksheets and dashboards.



## About the Data
[Download Original Data Set](https://drive.google.com/drive/folders/1yzkQWU0d76jG9jes5i2RJ8jU8Gl0Ktn5?usp=share_link)
  |  [Download cleaned & transformed data](https://www.kaggle.com/datasets/chuxugorji/bike-share)

We analyzed most recent data, 1 year record of all rides amounting to over 5million records. Data was stored in monthly sets as csv files on the company’s extraction site.  Due to the large amount of data for each month exceeding Excel and Power query’s capacity that informed the decision to use SQL, especially for appending all data, cleaning, and transformation for analysis. Further more selecting Tableau to be efficient with time spent on analysis and visualisation. Just to caveat that these data is currently open sourced hence why I can share and talk about this on my portfolio. 


**p.s**: a column clock_in_hour (int) was used as an experimental field, clock_in_time is the useful column used in analysis

## Data Preparation, cleaning and transformation on SQL
[see SQL queries](https://github.com/Codesoil/EDA-detect-different-usage-patterns-amongst-customer-groups/blob/main/Sql-queries-bike-share-EDA.sql)

#### Preparation: For preparation I took consideration of the following, while not an exhaustive list of all actions taken, these were key:
1. Securely storing data
2. Rename files with a standard naming convention
3. Load and check for completeness of data, ran tests on SQL to check for truncated data
4. Determine useful data
5. Check data type and header for each variable is the same across each monthly record
6. Final action, append all useful data using SQL UNION

#### **Cleaning & Transformation:** I tested & cleaned for the following across the data set:
1. Truncated data
2. Duplicate records
3. Inconsistent spelling, extra spaces and characters
4. Nulls or missing data
5. Records where ride start time (started_at) could be greater than (and also equal to) ride end time (ended_at)


Further transformed data set to include new calculated fields to enable analysis
1. Travel_time_in_minutes
2. Ride start time (clock_in_time) - renamed to Time of Day (in tableau)
3. Ride start Day (clock_in_day) - renamed to Day of Ride (in Tableau)
4. Season of the year

## Analysis, Visualization and final executive story on Tableau
[view full body of analysis work on tableau public](https://public.tableau.com/views/bike-share-marketing/AverageTraveltimebyUserGroup?:language=en-GB&:display_count=n&:origin=viz_share_link)


In our analysis we explored the following 
1. if there's a difference in Average travel time between customer types, 
2. if there's a difference in service demand trend based on the day of the week
3. if there's a difference in service demand trend based on the time of the day
4. if there's a difference in service demand trend based on the season of the year


**p.s**: we didn't explore difference in bike type preference because the entry point to each bike type was flexxible for casual riders and fixed for annual subscribers, hence the underlying basis for usage would be biased.

