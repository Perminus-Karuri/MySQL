-- Exploratory Data Analysis (EDA)


-- Skills demonstrated in this section are:
-- 1. Data inspection
-- 2. Aggregation function such as MAX, MIN, GROUP BY
-- 3. Use of Common Table Expressions (CTE) for analysis
-- 4. Use of window functions for rolling totals such as DENSE_RANK() and SUM() OVER()
-- 5. Conditional filtering and sorting using WHERE and ORDER BY

-- Data inspection
SELECT *
FROM layoffs_staging2;

-- Finding the maximum of total people laid off and also the percentage
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Filtering companies that 100% layoff and sorting them by funds they raised
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Find the company with the highest total number of layoffs and sorting them by 2nd column
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Finding the date when layoff started in this dataset
SELECT MIN(date), MAX(date)
FROM layoffs_staging2;

-- Find the industry with the highest total number of layoffs
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Find the industry with the highest total number of layoffs
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Find which year had the highest total number of layoffs
SELECT YEAR(date), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(date)
ORDER BY 2 DESC;

WITH Rolling_layoffs AS
(
SELECT SUBSTRING(date, 1, 7) AS 'Month', SUM(total_laid_off) AS 'layoff_total'
FROM layoffs_staging2
WHERE SUBSTRING(date, 1, 7) IS NOT NULL
GROUP BY Month
ORDER BY 1 ASC
)
SELECT Month, layoff_total, SUM(Layoff_total) OVER(ORDER BY Month) AS rolling_total
FROM Rolling_layoffs
GROUP BY Month;

-- Find the top 5 companies with the most layoffs per year
WITH Company_Year (company, year, total_laid_off) AS 
(
SELECT company, YEAR(date), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(date)
), Company_Ranks AS 
(
SELECT *,
DENSE_RANK() OVER (PARTITION BY year ORDER BY total_laid_off DESC) AS Rankings
FROM Company_Year
WHERE year IS NOT NULL
)
SELECT *
FROM Company_Ranks
WHERE Rankings <= 5;

-- Finding the top 5 insutries with most layoffs per year
WITH Industry_Year (industry, year, total_laid_off) AS
(
SELECT industry, YEAR(date), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry, YEAR(date)
), Industry_Rank AS
(
SELECT *, DENSE_RANK() OVER (PARTITION BY year ORDER BY total_laid_off DESC) AS industry_rank 
FROM Industry_Year
WHERE year IS NOT NULL
)
SELECT *
FROM Industry_Rank
WHERE industry_rank <= 5;






