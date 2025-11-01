-- Data cleaning

SELECT *
FROM layoffs;

-- 🧹 Data Cleaning with SQL: Key Steps
-- 1. Remove duplicates
--    - Identify and delete repeated records to ensure data uniqueness.
--
-- 2. Standardize data
--    - Correct inconsistent spellings.
--    - Ensure consistent letter casing (e.g., UPPER, lower, Proper Case).
--    - Format dates and numerical values uniformly.
--
-- 3. Handle null or blank values
--    - Replace missing data where possible, or remove incomplete records if necessary.
--
-- 4. Remove irrelevant or unnecessary columns
--    - Drop columns that do not contribute to analysis or insights.



-- Create a staging table (layoffs_staging) as a copy of the original layoffs table.
-- This allows safe data cleaning and transformations without altering the raw data.
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;


-- Removing duplicates
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- checking for duplicate data
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Create a second staging table (layoffs_staging2) for deduplication.
-- This table will be used to identify and remove duplicate rows safely.
-- A 'row_num' column is added to help track duplicates using ROW_NUMBER().
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

-- insert copy data into the new table
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location,
 industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- delete duplicate rows
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2;


-- Standardizing data

-- White lead spaces in company field
SELECT company, TRIM(company)
FROM layoffs_staging2;

-- update the table after trim
UPDATE layoffs_staging2
SET company = TRIM(company);

-- standardizing industry column
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- standardizing country column
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- convert the date entries from text format to date format
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Handling NULL and blanks

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL;

-- 
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT company, industry
FROM layoffs_staging2
WHERE company LIKE 'Airbnb%';

-- This query finds companies in the layoffs_staging2 table that have 
-- missing industry values (t1.industry IS NULL) in some records, 
-- but non-null industry values (t2.industry IS NOT NULL) in others. 
-- It helps identify which missing industry fields can be filled 
-- using existing data from the same company. 
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- This query updates missing industry values in the layoffs_staging2 table 
-- by copying non-null industry information from other records that belong 
-- to the same company. It ensures consistency by filling in NULL industry 
-- fields where possible based on existing data within the same company.
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2;

-- Remove any rows and columns we do not need
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Deleting rows which have total_laid_off and percentage_laid_off as nulls
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Dropping columns we do not need
SELECT *
FROM layoffs_staging2;

-- in this case, row_num was dropped since it was no longer necessary
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;