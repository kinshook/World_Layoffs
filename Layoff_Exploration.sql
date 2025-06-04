
--Data Exploration from table layoffs using staging table--

Select
MAX(total_laid_off) AS Max_laid_off, MIN(total_laid_off) Min_laid_off, AVG(total_laid_off) AS Avg_laid_off
FROM staging_table
-- PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY total_laid_off) OVER() AS Median_Laid_off 

--SELECT * FROM staging_table
--WHERE company LIKE 'Zym%'
Select  DISTINCT company,location_c,	--Can use:Select DISTINCT company,location_c  to avoid repetition of company names with multiple entries in same/diff location
CASE
	WHEN total_laid_off IS NOT NULL THEN MAX(total_laid_off) OVER(PARTITION BY company,location_c ORDER BY company)
	WHEN total_laid_off IS NULL THEN MAX(percentage_laid_off) OVER(PARTITION BY company,location_c ORDER BY company)
	END AS Total_Or_Percent_laid_off
FROM staging_table



--Total layoffs in a company and industry in a particular year
Select company, industry, YEAR(date_) AS Year,
CASE
	WHEN total_laid_off IS NOT NULL THEN SUM(total_laid_off ) OVER(PARTITION BY company,YEAR(date_) ORDER BY YEAR(date_) DESC)
	WHEN total_laid_off IS NULL THEN SUM(percentage_laid_off) OVER(PARTITION BY company,YEAR(date_)  ORDER BY YEAR(date_) DESC)
END AS Total_Or_Percent_laid_off
FROM staging_table
--WHERE COUNT(SELECT YEAR(date_) FROM staging_table )>1
GROUP BY YEAR(date_),company,industry,total_laid_off,percentage_laid_off
ORDER BY YEAR(date_) DESC,total_laid_off DESC ,
  CASE WHEN total_laid_off IS NULL THEN percentage_laid_off END DESC 


--Companies that had multiple layoffs in a year
WITH YearSelection AS
(
  SELECT company, YEAR(date_) AS Years,
CASE
	WHEN total_laid_off IS NOT NULL THEN SUM(total_laid_off ) OVER(PARTITION BY company,YEAR(date_) ORDER BY YEAR(date_) DESC)
	WHEN total_laid_off IS NULL THEN SUM(percentage_laid_off) OVER(PARTITION BY company,YEAR(date_)  ORDER BY YEAR(date_) DESC)
END AS Total_Or_Percent_laid_off
FROM staging_table
GROUP BY YEAR(date_),company,industry,total_laid_off,percentage_laid_off
)
SELECT company, Years,COUNT(Years) FROM YearSelection
GROUP BY Years,company
HAVING COUNT(Years)>1

