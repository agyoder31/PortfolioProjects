--SELECT * FROM PortfolioProject..RealEstateFinancials
--Order By 2

--SELECT * FROM PortfolioProject..RealEstateClass
--Order By 2,4

-- Temp Table

DROP TABLE IF EXISTS #CT_HomeSales
CREATE TABLE #CT_HomeSales
(
[Serial Number] numeric,
[Date Recorded] date,
[Assessed Value] numeric,
[Sale Amount] numeric,
[Sales Ratio] numeric,
Town nvarchar(255),
[Residential Type] nvarchar(255),
[Rolling Town Sales] numeric
)


INSERT INTO #CT_HomeSales
SELECT fin.[Serial Number], fin.[Date Recorded], fin.[Assessed Value], fin.[Sale Amount], fin.[Sales Ratio], cla.Town, cla.[Residential Type],
SUM(fin.[Sale Amount]) OVER (PARTITION BY cla.Town Order By fin.[Date Recorded]) AS [Rolling Town Sales]
FROM RealEstateFinancials fin
JOIN RealEstateClass cla
	ON fin.[Serial Number] = cla.[Serial Number]
	WHERE cla.[Property Type] <> 'Commercial' AND fin.[Serial Number] <> 70086
ORDER BY 6,2 desc

--Creating View for Visualizations
--
DROP VIEW IF EXISTS AvgRatio
--
CREATE VIEW AvgRatio AS
SELECT 
	cla.Town, 
	fin.[Date Recorded], 
	CAST (fin.[Sales Ratio] AS DECIMAL(10, 2)) AS SalesRatio,
	CAST (
		AVG(fin.[Sales Ratio]) OVER (PARTITION BY cla.Town ORDER BY fin.[Date Recorded]) AS DECIMAL(10,2)) AS [Running Avg Sales Ratio]
FROM RealEstateFinancials fin
JOIN RealEstateClass cla
	ON fin.[Serial Number] = cla.[Serial Number]
	WHERE cla.[Property Type] <> 'Commercial' AND cla.Town <> '***Unknown***' AND fin.[Sales Ratio] <> 0
--
