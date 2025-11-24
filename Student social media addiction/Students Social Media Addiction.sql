SELECT *
FROM student_addiction;

-- Finding out how many countries are in this dataset
SELECT COUNT(DISTINCT Country)
FROM student_addiction;

-- Finding how many unique social media platforms are there
SELECT DISTINCT most_used_platform
FROM student_addiction;

-- avg usage hours by gender
SELECT Gender, ROUND(AVG(Avg_Daily_Usage_Hours), 1) AS avg_usage_hours
FROM student_addiction
GROUP BY Gender;

-- avg sleeping hours by academic level
SELECT Academic_Level, ROUND(AVG(Sleep_Hours_Per_Night), 1) AS avg_sleeping_hours
FROM student_addiction
GROUP BY Academic_Level;

-- Finding out how many people use various platforms
SELECT Most_Used_Platform,
	COUNT(CASE WHEN Most_Used_Platform = 'Instagram' THEN 1
		  WHEN Most_Used_Platform = 'Twitter' THEN 1
          WHEN Most_Used_Platform = 'Tiktok' THEN 1 
          WHEN Most_Used_Platform = 'Youtube' THEN 1
          WHEN Most_Used_Platform = 'Facebook' THEN 1 
          WHEN Most_Used_Platform = 'LinkedIn' THEN 1 
          WHEN Most_Used_Platform = 'Snapchat' THEN 1
          WHEN Most_Used_Platform = 'LINE' THEN 1
          WHEN Most_Used_Platform = 'KakaoTalk' THEN 1
          WHEN Most_Used_Platform = 'VKontakte' THEN 1 
          WHEN Most_Used_Platform = 'WhatsApp' THEN 1
          WHEN Most_Used_Platform = 'WeChat' THEN 1 END) AS user_count
FROM student_addiction
GROUP BY  Most_Used_Platform
ORDER BY 2 DESC;
-- When we run the above query, we can deduce that instagram has the most users while Youtube has the least users

-- Listing all undergraduates who use social media
SELECT age, academic_level, most_used_platform, Avg_Daily_Usage_Hours, country, Affects_Academic_Performance
FROM student_addiction
WHERE Academic_Level = 'Undergraduate'
ORDER BY 1;

-- Listing all high school students who use social media
SELECT age, academic_level, most_used_platform, Avg_Daily_Usage_Hours, country, Affects_Academic_Performance
FROM student_addiction
WHERE Academic_Level = 'High School'
ORDER BY 1;

-- Listing all graduates who use social media including their age, country, avg daily usage hours and their academic performance
SELECT age, academic_level, most_used_platform, Avg_Daily_Usage_Hours, country, Affects_Academic_Performance
FROM student_addiction
WHERE Academic_Level = 'Graduate'
ORDER BY 1;

SELECT *
FROM student_addiction;

-- Ranking the most used platforms to the least used by each academic level based on average usage hours
SELECT Academic_Level, Most_Used_Platform, ROUND(AVG(Avg_Daily_Usage_Hours), 1) AS avg_usage_hours,
	DENSE_RANK() OVER (PARTITION BY Academic_Level ORDER BY ROUND(AVG(Avg_Daily_Usage_Hours), 1) DESC) AS rankings
FROM student_addiction
GROUP BY Academic_Level, Most_Used_Platform
ORDER BY 1;

-- Countries that have their average avg usage hours greater than 5 hours
SELECT country, Most_Used_Platform, round(avg(Avg_Daily_Usage_Hours), 1) AS avg_usage_hours
FROM student_addiction
GROUP BY country, Most_Used_Platform
HAVING avg(Avg_Daily_Usage_Hours) > 5
ORDER BY 3;

SELECT age, academic_level, most_used_platform, Avg_Daily_Usage_Hours, country, Affects_Academic_Performance, Sleep_Hours_Per_Night
FROM student_addiction
-- WHERE Academic_Level = 'Graduate'
ORDER BY 1, 2, 7;

-- Average usage hours and how it relates to student slleping hours grouped by academic level
SELECT Academic_Level, round(avg(Avg_Daily_Usage_Hours), 1) AS avg_usage_hours, round(avg(Sleep_Hours_Per_Night), 1) AS avg_sleep_hours
FROM student_addiction
GROUP BY Academic_Level;

-- most used social platform with over 10 users per country
WITH paltform_country AS (
SELECT Most_Used_Platform, Country,
	COUNT(CASE WHEN Most_Used_Platform = 'Instagram' THEN 1
		  WHEN Most_Used_Platform = 'Twitter' THEN 1
          WHEN Most_Used_Platform = 'Tiktok' THEN 1 
          WHEN Most_Used_Platform = 'Youtube' THEN 1
          WHEN Most_Used_Platform = 'Facebook' THEN 1 
          WHEN Most_Used_Platform = 'LinkedIn' THEN 1 
          WHEN Most_Used_Platform = 'Snapchat' THEN 1
          WHEN Most_Used_Platform = 'LINE' THEN 1
          WHEN Most_Used_Platform = 'KakaoTalk' THEN 1
          WHEN Most_Used_Platform = 'VKontakte' THEN 1 
          WHEN Most_Used_Platform = 'WhatsApp' THEN 1
          WHEN Most_Used_Platform = 'WeChat' THEN 1 END) AS user_count
FROM student_addiction
GROUP BY  Most_Used_Platform, Country
ORDER BY 3 DESC)
SELECT *
FROM paltform_country
WHERE user_count > 10;

-- Finding students who are in a complicated relationship and have had more than 2 conflicts over social media
-- also finding their average daily usage hours and the platform they use
SELECT Age, Gender, Academic_Level, Most_Used_Platform, Avg_Daily_Usage_Hours, Relationship_Status, Conflicts_Over_Social_Media, Affects_Academic_Performance
FROM student_addiction
WHERE Relationship_Status LIKE '%Complica%' AND Conflicts_Over_Social_Media > 2
ORDER BY 1, 5;
-- Findings: most students who use instagram have complicated relationships and are aged between 18 and 21
--  		 students who are in complicated relationships also have their academic performance affected.

-- Finding students who are in a relationship and have had more than 2 conflicts over social media
-- also finding their average daily usage hours and the platform they use
SELECT Age, Gender, Academic_Level, Most_Used_Platform, Avg_Daily_Usage_Hours, Relationship_Status, Conflicts_Over_Social_Media, Affects_Academic_Performance
FROM student_addiction
WHERE Relationship_Status = 'In Relationship' AND Conflicts_Over_Social_Media > 2
ORDER BY 1, 5;
-- Findings: most students who use instagram have complicated relationships and are aged between 20 and 22
--  		 students who are in complicated relationships also have their academic performance affected.

-- Finding out how avg daily usage hours and sleep hours relate to academic performance
SELECT Age, Gender, Academic_Level, Most_Used_Platform, Avg_Daily_Usage_Hours, Sleep_Hours_Per_Night, Affects_Academic_Performance
FROM student_addiction
WHERE Avg_Daily_Usage_Hours >= 5;
-- Findings: Use of social media for 5 or more hours, affects the performance of majority of the students
-- 			 Majority of the students whose academic performance is affected sleep for less than 7 hours. 
 
-- Using CTE to add new columns that categorise Mental health score and Addicted score
-- Find students who are highly addicted to social media, average usage time, sleeping hours
WITH addict_cte AS (
SELECT *,
       (CASE WHEN Mental_Health_Score IN (1,2,3) THEN 'Poor'
			 WHEN Mental_Health_Score IN (4,5,6) THEN 'Moderate'
             WHEN Mental_Health_Score IN (7,8,9) THEN 'Good'
       END) AS mental_category,
       (CASE WHEN Addicted_Score IN (1,2,3) THEN 'Less addicted'
			 WHEN Addicted_Score IN (4,5,6) THEN 'Medium addicted'
			 WHEN Addicted_Score IN (7,8,9) THEN 'Highly addicted'
       END) AS addiction_category
FROM student_addiction)
SELECT Age, Gender, Most_Used_Platform, Academic_Level, Affects_Academic_Performance, Sleep_Hours_Per_Night, Mental_category, Avg_Daily_Usage_Hours, addiction_category
FROM addict_cte
WHERE Affects_Academic_Performance = 'Yes' AND addiction_category = 'Highly addicted';
-- Findings: Students who are highly addicted to social media also see their acedemic performance affected/deteroriate
-- 			 Although some students, spend less time on social media and have enough/adequate sleep,
-- 			 they still perform poorly, which would show they don't study enough. 

-- Finding out how many students there are in each category of addiction
WITH addict_cte AS (
SELECT *,
       (CASE WHEN Mental_Health_Score IN (1,2,3) THEN 'Poor'
			 WHEN Mental_Health_Score IN (4,5,6) THEN 'Moderate'
             WHEN Mental_Health_Score IN (7,8,9) THEN 'Good'
       END) AS mental_category,
       (CASE WHEN Addicted_Score IN (1,2,3) THEN 'Less addicted'
			 WHEN Addicted_Score IN (4,5,6) THEN 'Medium addicted'
			 WHEN Addicted_Score IN (7,8,9) THEN 'Highly addicted'
       END) AS addiction_category
FROM student_addiction)
SELECT addiction_category, Academic_level,
		COUNT(CASE WHEN addiction_category = 'Less addicted' THEN 1 
				   WHEN addiction_category = 'Medium addicted' THEN 1 
                   WHEN addiction_category = 'Highly addicted' THEN 1 
				END) AS addict_count
FROM addict_cte
GROUP BY addiction_category, Academic_level
ORDER BY 2, 3;