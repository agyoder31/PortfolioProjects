-- This is a short player review of the Detoit Tigers 2023 season. 

-- Deleting unwanted rows
DELETE FROM Hitters WHERE Pos IS NULL

-- Query 1: Identify which players negatively impacted the team with a sufficient sample size

SELECT Name, WAR FROM Hitter_Value
WHERE WAR < 0.0 
	AND PA > 75 
UNION 
SELECT Name, WAR FROM Pitcher_Value
WHERE WAR < 0.0
	AND (IP > 50
	OR G > 10)
ORDER BY WAR

-- Query 2: Identify which form of aquisition provided the most return in 2023

WITH CombinedResults AS (
    SELECT Acquired, SUM(WAR) AS Acquisition_WAR, COUNT(*) AS Player_Count
    FROM (
        SELECT Acquired, WAR
        FROM Hitter_Value
        UNION ALL
        SELECT Acquired, WAR
        FROM Pitcher_Value
    ) AS subquery
    GROUP BY Acquired
)
SELECT Acquired, SUM(Acquisition_WAR) AS Total_Acquisition_WAR, SUM(Player_Count) AS Total_PlayerCount, ROUND(SUM(Acquisition_WAR)/SUM(Player_Count),1) AS Acquired_Avg
FROM CombinedResults
GROUP BY Acquired
ORDER BY Total_Acquisition_War DESC;

-- Query 3: Identify which players provide the most production based on their salary (Salary data may not be provided for players who did not make the opening day roster
	-- Needed to use the subquery due to Format claue changing the Millions_Spent_For_1WAR to a string

SELECT Name, WAR, Salary, 
       CAST(FORMAT((Salary/WAR)/1000000,'N1') AS DECIMAL(10, 1)) Millions_Spent_For_1WAR
FROM Hitter_Value
WHERE Salary IS NOT NULL AND WAR >= 0.5
UNION ALL
SELECT Name, WAR, Salary, 
       CAST(FORMAT((Salary/WAR)/1000000,'N1') AS DECIMAL(10, 1)) Millions_Spent_For_1WAR
FROM Pitcher_Value
WHERE Salary IS NOT NULL AND WAR >= 0.5
ORDER BY Millions_Spent_For_1WAR;

-- Query 4: Identify the impact of walked batters on a pitcher ERA
--*League average walk rate in 2023 was 3.3

SELECT Name, [ERA+], BB9
FROM Pitchers
WHERE BB9 >3.3 AND (G >=10 OR IP >=50)
ORDER BY BB9 DESC

SELECT Name, [ERA+], BB9
FROM Pitchers
WHERE BB9 <3.3 AND (G >=10 OR IP >=50)
ORDER BY BB9 ASC

SELECT ROUND((SUM(ER)/SUM(IP))*9,3) AS High_Walk_ERA
FROM Pitchers 
WHERE BB9 >3.3 AND (G >=10 OR IP >=50)

SELECT ROUND((SUM(ER)/SUM(IP))*9,3) AS Low_Walk_ERA
FROM Pitchers 
WHERE BB9 <3.3 AND (G >=10 OR IP >=50)

-- Comparing the walk results to a similar study on strikeouts
--* League average strikeout rate in 2023 is 8.7

SELECT Name, [ERA+], SO9
FROM Pitchers
WHERE SO9 >8.7 AND (G >=10 OR IP >=50)
ORDER BY SO9 DESC

SELECT Name, [ERA+], SO9
FROM Pitchers
WHERE SO9 <8.7 AND (G >=10 OR IP >=50)
ORDER BY SO9 ASC

SELECT ROUND((SUM(ER)/SUM(IP))*9,3) AS High_K_ERA
FROM Pitchers 
WHERE SO9 >8.7 AND (G >=10 OR IP >=50)

SELECT ROUND((SUM(ER)/SUM(IP))*9,3) AS Low_K_ERA
FROM Pitchers 
WHERE SO9 <8.7 AND (G >=10 OR IP >=50)

--*This is a fascinating result. I would be interested to run this same study leaguewide. I imagine this result doesn't hold up with higher strikeout rates leading to a worse ERA.
--*There is a longstanding debate between what is more valuable as a pitcher: being able to minimize walks or maximize strikeouts. For the 2023 Tigers, minimizing walks led to greater success. 

--Query 5: Identifying which metric (WAR or WAA) was more accurate based on the Detroit Tigers 2023 actualized win total of 78

SELECT 
    (SELECT SUM(WAR) FROM Hitter_Value) AS HWAR,
    (SELECT SUM(WAR) FROM Pitcher_Value) AS PWAR,
    (SELECT SUM(WAR) FROM Hitter_Value) + (SELECT SUM(WAR) FROM Pitcher_Value) AS TotalWAR,
	(SELECT SUM(WAR) FROM Hitter_Value) + (SELECT SUM(WAR) FROM Pitcher_Value) + (0.294 * 162) AS WarWins

SELECT 
    (SELECT SUM(WAA) FROM Hitter_Value) AS HWAA,
    (SELECT SUM(WAA) FROM Pitcher_Value) AS PWAA,
    (SELECT SUM(WAA) FROM Hitter_Value) + (SELECT SUM(WAA) FROM Pitcher_Value) AS TotalWAA,
	(SELECT SUM(WAA) FROM Hitter_Value) + (SELECT SUM(WAA) FROM Pitcher_Value) + 81 AS WAAWins

--The team's actual win total finished at 78. So both metrics graded out lower than actual value, with WAA being slightly more accurate. This is another study that would be interesting to expand out leaguewide. 







