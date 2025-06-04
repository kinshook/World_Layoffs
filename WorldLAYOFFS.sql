CREATE DATABASE WorldLayoffs
USE WorldLayoffs

SELECT * FROM layoffs;

--Creating a new table as a staging table to manipulate on
DROP TABLE IF EXISTS staging_table;
CREATE TABLE staging_table(
company	VARCHAR(50)	,
location_c	NVARCHAR(50)	,
industry	VARCHAR(50)	,
total_laid_off	VARCHAR(20)	,
percentage_laid_off	VARCHAR(20)	,
date_	VARCHAR(20)	,
stage	VARCHAR(20)	,
country	VARCHAR(50)	,
funds_raised_millions	VARCHAR(20)	
);

SELECT * FROM staging_table ORDER BY company;		--ensure sucessful creation of the required schema

ALTER TABLE staging_table
ALTER COLUMN company VARCHAR(50); --Since 'freq. therapeutics' was getting truncated; orig.ly I had company as VARCHAR(20)

INSERT INTO staging_table		--txfer all data to the staging table from layoffs
SELECT * FROM layoffs;


									---DATA CLEANING---



WITH RowsNum AS
(
	SELECT *,  ROW_NUMBER() OVER(PARTITION BY company,location_c,industry,total_laid_off,percentage_laid_off,date_,stage,country,funds_raised_millions ORDER BY company) AS row_num
FROM staging_table 
)
DELETE  FROM RowsNum
WHERE total_laid_off is NULL AND percentage_laid_off IS NULL
 SELECT * FROM RowsNum
	WHERE total_laid_off is NULL AND percentage_laid_off IS NULL

 --SELECT *  FROM RowsNum
 --WHERE percentage_laid_off IS null
UPDATE RowsNum
Set funds_raised_millions = null
WHERE funds_raised_millions  ='Null'




--SELECT *  FROM RowsNum
--WHERE total_laid_off IS NULL OR total_laid_off='NULL'

--CHECK for duplicacy

SELECT * FROM RowsNum	--Selects and Confirms the presence of duplicate rows
DELETE FROM RowsNum   --Deletes duplicate rows
WHERE row_num>1

--SELECT * FROM RowsNum
--WHERE company='Cazoo'	--check to ensure the duplicate data has been cleared
--SELECT company ,		--Don't select for updating a col;use UPDATE



--SELECT * FROM fn_dblog(NULL,NULL);

/*RESTORE LOG WorldLayoffs
FROM DISK = 'D:\Codebasics\Alex dataset DataCleaning\WorldLayoffs.sql.bak'
WITH STOPBEFOREMARK = 'lsn:00000028:000002E8:0002';*/


								--STANDARDIZING the data

--SELECT company, LTRIM(company)	--Removing the trailing spaces;checked with select statement then update
UPDATE RowsNum
SET company=LTRIM(company)
WHERE SUBSTRING(company,1,1)=' ';


UPDATE RowsNum
SET industry= 'Crypto'
WHERE industry LIKE 'Crypto%'


SELECT * FROM RowsNum		--Since other fields in these blanks industry col are populated we fill the blank=null
UPDATE RowsNUM
SET industry = null
WHERE industry=''

--SELECT * FROM RowsNum
--WHERE company='Airbnb'

--WHERE industry is null OR industry='null' AND company='Airbnb'
/*SELECT r.company,r2.company, r.industry,r2.industry FROM RowsNum r
JOIN staging_table r2
ON r.company=r2.company
--SET r.industry=r2.industry
WHERE r.industry IS NULL AND r2.industry IS NOT NULL*/

--UPDATE RowsNum		--as MSSQL doesn't support JOIN inside an UPDATE statement directly we use the approach mentioned ahead
--JOIN staging_table r2
--ON RowsNum.company=r2.company
--SET RowsNum.industry=r2.industry
--WHERE RowsNum.industry IS NULL AND r2.industry IS NOT NULL

--MSSQL APPROACH
UPDATE r		
SET r.industry=r2.industry
FROM RowsNum r
JOIN staging_table r2
ON r.company=r2.company
WHERE r.industry IS NULL AND r2.industry IS NOT NULL 


--CHECK if industry is fillable
--SELECT * FROM RowsNum
--WHERE company LIKE 'Bal%'		--non-fillable perecntage layoffs=null where industry is null
--WHERE industry is NULL OR industry='null'

/*Alternative Approach specifically in MSSQl*/
--MERGE INTO RowsNum AS rn
--USING staging_table AS r2
--ON rn.company = r2.company
--WHEN MATCHED AND rn.industry IS NULL AND r2.industry IS NOT NULL
--THEN UPDATE SET rn.industry = r2.industry;

UPDATE RowsNum		--Updating the stage; Replacing null with Unknown since unknown also pre-existed
SET stage='Unknown'
WHERE stage='Null'
--SELECT DISTINCT stage FROM RowsNum
--ORDER BY stage

UPDATE RowsNum				--Setting the country where the '.' was creating an issue resulting in US 
SET country='United States'		--resulting in two diff countries
WHERE country='United States.'

/*SELECT country FROM RowsNum
WHERE country='United States.'*/


/*Converting the DataTypes from VARCHAR to each Respective Types using the same format for each converted column*/
UPDATE RowsNum
Set total_laid_off= null
WHERE total_laid_off ='Null'

ALTER TABLE staging_table
Alter COLUMN total_laid_off INT

Alter Table staging_table
ALTER COLUMN percentage_laid_off DECIMAL(10,2)

ALTER TABLE staging_table
ALTER COLUMN date_ DATE

Alter Table staging_table
ALTER COLUMN funds_raised_millions DECIMAL(10,2)

--SELECT *,FORMAT(date_,'d','en-Uk' ) From staging_table	 ---OUTPUTS format of type:3/6/2023


--SELECT convert(varchar, getdate(), 101)	--GIVES current date
