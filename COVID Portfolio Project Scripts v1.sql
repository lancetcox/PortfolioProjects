SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, New_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs. Total Deaths
-- Shows likelihood of dying if you contract COVID in your country

SELECT Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states'
ORDER BY 1,2

-- Looking at Total Cases vs. Population
-- Shows what percentage of population got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS Percent_Population_Infected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 AS Percent_Population_Infected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states'
GROUP BY Location, Population
ORDER BY Percent_Population_Infected DESC

-- Looking at Countries with Highest Death Count per Population

SELECT Location, MAX(CAST(total_deaths as int)) as Total_Death_Count
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states'
WHERE continent is not null
GROUP BY location
ORDER BY Total_Death_Count DESC



-- BREAK THINGS DOWN BY CONTINENT

-- Looking at continents with highest death count per population

SELECT continent, MAX(CAST(total_deaths as int)) as Total_Death_Count
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states'
WHERE continent is not null
GROUP BY continent
ORDER BY Total_Death_Count DESC




-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases) *100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--Looking at Total Population vs. Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
, (rolling_vaccinations/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3



-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_vaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
--, (rolling_vaccinations/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (rolling_vaccinations/population)*100
FROM PopvsVac



-- TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
--, (rolling_vaccinations/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (rolling_vaccinations/population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPeopleVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
--, (rolling_vaccinations/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPeopleVaccinated