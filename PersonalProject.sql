SELECT * FROM [dbo].[CovidDeaths]
ORDER BY 3,4;

--SELECT * FROM [dbo].[CovidVaccinations]
--ORDER BY 3,4;

SELECT location,date, total_cases, total_deaths, new_cases,population FROM 
[dbo].[CovidDeaths]
ORDER BY 1,2;

--TASK 1
--TOTAL CASES/TOTAL DEATH
SELECT location,date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage FROM 
[dbo].[CovidDeaths]
ORDER BY 1,2;

--likimgjood of dyinng if you contract covid in your country
SELECT location,date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage FROM
[dbo].[CovidDeaths]
WHERE location = 'Nigeria'
ORDER BY 1,2;

--looking at total cases/population
--shows what percentage of population got covid

SELECT location,date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected FROM 
[dbo].[CovidDeaths]
--WHERE location = 'Nigeria'
ORDER BY 1,2;

--Country with the highest infection rate compared to population
SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS PercentPopulationInfected FROM 
[dbo].[CovidDeaths]
--WHERE location = 'Nigeria'
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC;

--Countries with the highest population count per population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount FROM 
[dbo].[CovidDeaths]
--WHERE location = 'Nigeria'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

--Breakig it down by continent

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount FROM 
[dbo].[CovidDeaths]
--WHERE location = 'Nigeria'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


--showing the continents with the highest dealth counts
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount FROM 
[dbo].[CovidDeaths]
--WHERE location = 'Nigeria' 
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--GLOBAL NUMBERS

SELECT SUM(new_cases) AS Tota_cases, SUM(CAST (new_deaths AS INT)) AS Total_deaths, SUM(CAST (new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage 
FROM [dbo].[CovidDeaths]
--WHERE location = 'Nigeria' 
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;

SELECT * FROM [dbo].[CovidVaccinations];

--JOING BOTH TABLES

SELECT * FROM [dbo].CovidDeaths dea
JOIN  [dbo].[CovidVaccinations] vac
 ON dea.location=vac.location AND dea.date=vac.date;

 --total populationn vs total vaccination
 SELECT dea.continent,dea.location,dea.population, dea.date, vac.new_vaccinations FROM [dbo].CovidDeaths dea
JOIN  [dbo].[CovidVaccinations] vac
 ON dea.location=vac.location AND dea.date=vac.date
 WHERE dea.continent IS NOT NULL
 ORDER BY 2,3;

 SELECT dea.continent,dea.location,dea.population, dea.date, vac.new_vaccinations,
 SUM (CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RolligPeopleVaccinated
 FROM [dbo].CovidDeaths dea
JOIN  [dbo].[CovidVaccinations] vac
 ON dea.location=vac.location AND dea.date=vac.date
 WHERE dea.continent IS NOT NULL
 ORDER BY 2,3;

 --USING CTE
 With PopvsVac (continent, location, population, date, new_vaccinations, RollingPeopleVaccinated)
 AS
 (
 SELECT dea.continent,dea.location,dea.population, dea.date, vac.new_vaccinations
 ,SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
 FROM [dbo].[CovidDeaths] dea
 JOIN  [dbo].[CovidVaccinations] vac
 ON dea.location = vac.location AND dea.date = vac.date
 WHERE dea.continent IS NOT Null
--ORDER BY 2,3 
) SELECT *, (RollingPeopleVaccinated/population)*100
 FROM PopvsVac
 

 --TEMP TABLE
 DROP TABLE IF EXIST #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
(continent NVARCHAR(255),
location NVARCHAR(255),
date datetime,
population numeric,
new_vaccinated numeric,
RollingPeopleVaccinated numeric)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [dbo].[CovidDeaths] dea
JOIN [dbo].[CovidVaccinations] vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT Null
--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated
 

--CREATE VIEW TO STORE LATER FOR VISULIATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [dbo].[CovidDeaths] dea
JOIN [dbo].[CovidVaccinations] vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT Null
--ORDER BY 2,3;

SELECT * FROM PercentPopulationVaccinated 