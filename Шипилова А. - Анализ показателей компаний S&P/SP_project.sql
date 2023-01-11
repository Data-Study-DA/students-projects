--Проверяем загрузку данных 

SELECT*
FROM df_SP2;

--Смотрим наиболее успешные компании, сектора по EBITDA. Получаем, что более всего в Топ20 по EBITDA компаний сектора Информационные технологии.
SELECT Name,
	   Sector,
	   EBITDA 
FROM df_SP2
ORDER BY EBITDA DESC
LIMIT 20;

--Смотрим среднюю и суммарную EBITDA  по секторам. 
--По средней EBITDA наиболее успешные компании Телекоммуникационные услуги, по суммарной по сектору EBITDA- Информационные технологии
SELECT Sector,
	   Name,
	   Market_cap,
	   EBITDA,
	   avg(EBITDA) OVER (PARTITION BY Sector) AS AVG_Sector_EBITDA,
	   sum(EBITDA) OVER (PARTITION BY Sector) AS Sector_EBITDA
FROM df_SP2
ORDER BY Sector_EBITDA DESC;


--Считаем количество компаний по секторам

SELECT Sector,
	   COUNT(Sector) AS Companies_number
FROM df_SP2
GROUP BY 1
ORDER BY 2 DESC;

--Смотрим компании по секторам и срок окупаемости, сорьтруем внутри секторов по возрастанию

SELECT Sector,
	   Name,
	   Price_to_earnings
FROM df_SP2
WHERE Price_to_earnings > 0
GROUP BY 1,2
ORDER BY Sector, Price_to_earnings ASC;



SELECT *
FROM (
	SELECT Sector,
	       Name,
	       Earning_per_share,
	       Market_cap,
	       EBITDA,
	       RANK() OVER(PARTITION BY Sector ORDER BY Earning_per_share DESC) AS Raiting 
FROM df_SP2 
GROUP BY 1,2
)
WHERE Raiting <=3

--Посмотри компании с низким сроком окупаемости вложенных денег и высокой оценкой рынком ее стабильности
-- Первые три места у компаний сектора здравоохранения, но по AmerisourceBergen Corp  стиоит принять во внимание оценку компании (P/B>5)

WITH Investor_set AS (
SELECT Name,
	   Sector,
	   Market_cap,
	   Price_to_sales
	   Price_to_earnings,
	   Dividend_yield,
	   Price_to_book
FROM df_SP2 
)
SELECT Name,
	   Sector,
	   Price_to_earnings,
	   Price_to_book 
FROM Investor_set
WHERE Price_to_book > 1
ORDER BY Price_to_earnings ASC;

-- Аналогичные показатели по промышленности

WITH Investor_set AS (
SELECT Name,
	   Sector,
	   Market_cap,
	   Price_to_sales
	   Price_to_earnings,
	   Dividend_yield,
	   Price_to_book
FROM df_SP2 
)
SELECT Name,
	   Sector,
	   Price_to_earnings,
	   Price_to_book 
FROM Investor_set
WHERE Price_to_book > 1
AND Sector = 'Industrials'
ORDER BY Price_to_earnings ASC

--Отфильтруем по одной компании из сектора по дивидендной доходности с P/B>1 (оценка компании рынком) и отсортируем по рыночной капитализации.
SELECT Name,
	   Sector,
	   Price_to_earnings,
	   Price_to_book,
	   Dividend_yield,
	   Raiting_dividend,
	   Market_cap
FROM ( 
	SELECT Name,
	   	   Sector,
	       Market_cap,
	       Price_to_sales
	       Price_to_earnings,
	       Dividend_yield,
	       Market_cap,
	       ROW_NUMBER() OVER (PARTITION BY Sector ORDER BY Dividend_yield DESC) AS Raiting_dividend,
	       Price_to_book
FROM df_SP2 
WHERE Dividend_yield > 0
AND Price_to_book > 1
GROUP BY Sector, Name)
WHERE Raiting_dividend = 1
ORDER BY Market_cap DESC






