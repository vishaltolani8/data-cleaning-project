-- Exploratory Data Analysis EDA

-- in EDA we don't have such default operation to perform, we retrieve data and then see what to be changed.

select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2;

select *
from layoffs_staging2
where percentage_laid_off = 1;

select company, sum(total_laid_off)
from layoffs_staging2
group by company 
order by 2 desc;

-- checking date, in which time frame kayoff happened
select min(`date`), max(`date`)
from layoffs_staging2;

-- lets see which industry had most laid offs
select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

-- checking which country had most lay offs
select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;

-- checking total laid off year wise
select YEAR(`date`), sum(total_laid_off)
from layoffs_staging2
group by YEAR(`date`)
order by 2 desc;

-- cheking month wise
select substring(`date`, 6,2) AS `Month`
from layoffs_staging2
where substring(`date`, 6,2) IS NOT NULL
group by `Month`
order by 1 desc;

-- cheching with rolling total, its great for visualization.

with Rolling_Total AS
(
select substring(`date`, 1,7) AS `Month`, sum(total_laid_off) AS total_offs
from layoffs_staging2
where substring(`date`, 1,7) IS NOT NULL
group by `Month`
order by 1 ASC
)
select `Month`, total_offs,
sum(total_offs) over(order by `Month`) AS rolling_total
from Rolling_total;

-- checking company 
select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

select company, YEAR(`date`), SUM(total_laid_off)
from layoffs_staging2
group by company, YEAR(`date`)
order by 3 desc;

-- checking top 5 companies that laid off most year wise.

With Company_Year (company, years, total_laid_off) AS (
select company, YEAR(`date`), SUM(total_laid_off)
from layoffs_staging2
group by company, YEAR(`date`)
), Company_years_rank AS
(
select *, dense_rank() over (partition by years order by total_laid_off desc) AS Ranking
from Company_Year
where years IS NOT NULL
)
select *
from Company_years_rank
where Ranking <= 5;