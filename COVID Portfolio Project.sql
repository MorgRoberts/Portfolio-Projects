--SELECT *
--FROM dbo.CovidVaccinations
--ORDER BY 3,4;

--SELECT *
--FROM dbo.CovidDeaths
--ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
ORDER BY 1,2;

--Looking at Total Cases vs Total Deaths 
--Shows likelihood of dying if you contract COVID in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM dbo.CovidDeaths
WHERE location = 'United States'
AND continent is not null
ORDER BY 1,2;

--Looking at Total Cases vs Population
--Shows what perentage of the population got COVID

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentagePopInfected
FROM dbo.CovidDeaths
WHERE location = 'United States'
AND continent is not null
ORDER BY 1,2;

--Looking at Countries with highest infection rate compared to population

SELECT continent, location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopInfected
FROM dbo.CovidDeaths
GROUP BY location, continent, population
ORDER BY PercentagePopInfected DESC;

--Showing Continents with the highest death count per pop

SELECT continent, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
FROM dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--Global Numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM dbo.CovidDeaths
WHERE continent is not null
GROUP  BY date
ORDER BY 1,2;

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2;

--Total population vs vaccinations

 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM dbo.CovidDeaths AS dea
JOIN dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent is not null
	ORDER BY 2,3;

--CTE

WITH PopvsVac (continent,location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM dbo.CovidDeaths AS dea
JOIN dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent is not null
	)
	SELECT *, (RollingPeopleVaccinated/population)*100
	FROM PopvsVac;

--TEMP table

CREATE TABLE #PercentPopVaccinated 
	(
	continent NVARCHAR (255),
	location NVARCHAR (255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
	)
INSERT INTO #PercentPopVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM dbo.CovidDeaths AS dea
JOIN dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopVaccinated

--Creating view to store data for later visualizations

CREATE VIEW PercentPopVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM dbo.CovidDeaths AS dea
JOIN dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent is not null;
	