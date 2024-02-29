SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--WHERE continent is not null
--ORDER BY 3,4

--Selecting Data

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

--Total Cases vs Total Deaths
--Likelihood of death given you have COVID

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows percent of population with COVID

SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
ORDER BY 1,2

 --Country with highest infection rate vs population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as InfectionPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location, population
ORDER BY InfectionPercentage desc

-- Countries with Highest Death Count Per Population

SELECT location, MAX(cast(total_deaths as int)) as DeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY DeathCount desc

-- By Continent 

SELECT continent, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- OR 

SELECT location, MAX(cast(total_deaths as int)) as TDC
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent IS NULL
GROUP BY location
ORDER BY TDC desc;

-- Global Numbers

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
ORDER BY 1,2

-- Vaccinations Table 

SELECT *
FROM PortfolioProject..CovidVaccinations$

-- Joined

SELECT *
FROM PortfolioProject..CovidDeaths$ dea
JOIN  PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location AND dea.date = vac.date

-- Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingTotalVaccincations
FROM PortfolioProject..CovidDeaths$ dea
JOIN  PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- CTE (Common Table Expressions)

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingTotalVaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingTotalVaccinations
FROM PortfolioProject..CovidDeaths$ dea
JOIN  PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingTotalVaccinations/Population)*100 as RollingPercentage
FROM PopvsVac
ORDER BY 2,3

-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE  #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingTotalVaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingTotalVaccinations
FROM PortfolioProject..CovidDeaths$ dea
JOIN  PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingTotalVaccinations/Population)*100 as RollingPercentage
FROM #PercentPopulationVaccinated
ORDER BY 2,3

-- Creating View for Visualizations

USE PortfolioProject
GO
--

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingTotalVaccinations
FROM PortfolioProject..CovidDeaths$ dea
JOIN  PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

-- REFERENCES:

-- Followed this video tutorial: https://www.youtube.com/watch?v=qfyynHBFOsM&list=PLUaB-1hjhk8H48Pj32z4GZgGWyylqv85f
