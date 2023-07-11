/*

Covid 19 Data Exploration 

Skills used: Joins, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


-- Before performing my EDA, I noticed some columns had the wrong data type. 
-- So I had to correct that before performing my EDA.


ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_cases INT

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_deaths FLOAT

ALTER TABLE PortfolioProject..CovidVaccinations
ALTER COLUMN new_vaccinations FLOAT



-- Select data I will be using

SELECT * FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 3,4

SELECT * FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL 
order by 3,4

SELECT location, date, population, total_cases, new_cases, total_deaths
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Now let's look at the Total Cases vs Total Deaths


SELECT location, date, total_cases, total_deaths, 
ROUND((total_deaths/total_cases)*100, 3) AS death_percentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Now let's look at the Total Cases vs Population
-- This shows the percentage of population that got infected


SELECT location, date, population, total_cases, 
ROUND((total_cases/population)*100, 3) AS percentage_pop_infected
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Let's Look at Countries with the highest infection rate compared to population


SELECT location, population, MAX(total_cases) AS highest_infection_count, 
ROUND(MAX(total_cases/population)*100, 3) AS percentage_pop_infected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location, population
ORDER BY percentage_pop_infected DESC


-- Let's look at Countries with the highest death count per population


SELECT location, population, MAX(total_deaths) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location, population
ORDER BY total_death_count DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing Continents with the highest death count per population


SELECT continent, MAX(total_deaths) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY total_death_count DESC


-- GLOBAL NUMBERS


SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, 
SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL  
ORDER BY 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations)
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL  
ORDER BY 2,3


-- Using Temp Table to perform calculation on Partition By in previous query

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date


SELECT *, ROUND((rolling_people_vaccinated/Population)*100,2) AS  percentage_vaccinated
FROM #PercentPopulationVaccinated



-- Creating View to store data for later visualizations


CREATE VIEW PopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 