SELECT *
FROM [dbo].[CovidDeaths]
ORDER BY 3,4

SELECT *
FROM [dbo].[CovidVaccinations]
ORDER BY 3,4

-- SELECT DATA THAT WE ARE GOING TO BE USING 

SELECT Location, date , total_cases, new_cases, total_deaths, population
FROM [dbo].[CovidDeaths]
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country 
SELECT Location, date , total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [dbo].[CovidDeaths]
WHERE location like '%poland%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows ehat percentage of population got Covid 
SELECT Location, date , population, total_cases,  (total_cases/population)*100 AS CasesPercentage
FROM [dbo].[CovidDeaths]
WHERE location like '%poland%'
ORDER BY 1,2

--Looking at countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount,  Max((total_cases/population)*100) AS CasesPercentage
FROM [dbo].[CovidDeaths]
GROUP BY Location, population
ORDER BY CasesPercentage DESC


--Looking at countries with Highest Death Rate compared to Population
SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount 
FROM [dbo].[CovidDeaths]
Where continent is not NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

--BREAKING BY CONTINENT
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount 
FROM [dbo].[CovidDeaths]
Where continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Global Number 
SELECT date , SUM(new_cases) as AllCases, SUM(cast(new_deaths as int)) as AllDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS AllDeathsProcentage
FROM [dbo].[CovidDeaths]
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


--Total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
FROM [dbo].[CovidDeaths] dea
JOIN [dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- USE CTE

with PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
FROM [dbo].[CovidDeaths] dea
JOIN [dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
Select *
FROM PopVsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVacinated
CREATE TABLE #PercentPopulationVacinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVacinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
FROM [dbo].[CovidDeaths] dea
JOIN [dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 AS PercentageOfVaccinatedPeople
FROM #PercentPopulationVacinated

-- Creatiing View to store data for visualizations 
Create View PercentPopulationVacinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
FROM [dbo].[CovidDeaths] dea
JOIN [dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null


SELECT *
FROM PercentPopulationVacinated
