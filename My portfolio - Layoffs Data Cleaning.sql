-- Data cleaning

SELECT *
FROM layoffs;

-- What to cover in data cleaning with SQL
-- 1. Remove duplicates
-- 2. Standardize the data - check for spellings, cases i.e. upper, lower etc
-- 3. Null values or blank values
-- 4. Remove any irrelevant columns


-- creating a copy of the layoffs table so as to work with it and avoid using the original raw data
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

-- checking duplicate data
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

-- create a copy table for deleting the duplicate rows
-- row_num column was also added
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