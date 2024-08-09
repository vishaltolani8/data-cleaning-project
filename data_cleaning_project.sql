-- Data Cleaning project --

-- 1. Remove the duplicate
-- 2. Standarize the date
-- 3. Null or blank values
-- 4. Remove Any columns

SELECT *
FROM world_layoffs.layoffs;

-- Create another table and copy the collected data

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT into layoffs_staging
SELECT * from layoffs;

select * from layoffs_staging;

-- usinng row number over partition by to check duplicate, if row number found greater then 1 it means it has duplicates
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) as row_num FROM  layoffs_staging;

-- now puting the query in a CTE or we can use sub Query to find where the row_num is greator then 1
WITH dublicate_cte AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions )
as row_num FROM  layoffs_staging
)
SELECT * from dublicate_cte
where row_num > 1;

-- now if we remove 1 dublicate it will ddelete the other one too, to fix the problem we need to create another table.
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
  `row_nnum` INT
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
 
 -- now we have to insert data in the table
 
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions )
as row_num FROM  layoffs_staging;

-- now safely deleting fomt this table
set SQL_SAFE_UPDATES = 0;
DELETE
FROM layoffs_staging2 WHERE row_nnum = 2;
set SQL_SAFE_UPDATES = 1;

select * 
 from layoffs_staging2;
 
 -- STANDDARDIZING DATA -- finding issues and fixing it
 
 SELECT company, trim(company) as no_extra_spaces
 from layoffs_staging2;
 
 -- Updating company and removing the extra spaces
 Update layoffs_staging2 set company = trim(company);
 
 -- checking and removing the muti valued data in attribute
 
 select DISTINCT industry from layoffs_staging2 order by 1;
 
 Update layoffs_staging2
 set industry = 'Crypto'
 where industry LIKE 'Crypto%';

select DISTINCT country, Trim(TRAILING '.' from country) as trimmed
from layoffs_staging2 order by 1;

Update layoffs_staging2 set country = trim(Trailing '.' from country)
where country LIKE 'United States%';

-- wroking with date
select `date`
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

-- changing date data type, text to Date
ALTER table layoffs_staging2
MODIFY COLUMN `date` Date;

-- joining same table to making null attribute values to usable.
select * from layoffs_staging2
where company = 'Airbnb'; -- we see here the two records but the industry is missing in one. we know what industry it is. wo we can write is by seeing the other record or Airbnb.

-- lets check how many more records are like this. 
select t1.industry, t2.industry
from layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    where t1.industry = '' OR t1.industry IS NULL
    AND t2.industry IS NOT null;
    
-- making the empty value to Null for better operation
UPdate layoffs_staging2
set industry = NULL
where industry = '';

Update layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
set t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT null;	

select *
from layoffs_staging2
where industry IS Null
OR industry = '';

-- deleting null rows thats not useful
select *
from layoffs_staging2
where total_laid_off IS Null
AND percentage_laid_off IS NULL;

DELETE from
layoffs_staging2
where total_laid_off IS Null
AND percentage_laid_off IS NULL;

-- we ddon't need column row_nnum anymore
Alter table layoffs_staging2
DROP column row_nnum;

select *
from layoffs_staging2;