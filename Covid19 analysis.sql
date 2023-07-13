


-- Before performing my EDA, I noticed some columns had the wrong data type. 
-- So I had to correct that before performing my EDA.


ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_cases BIGINT

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_deaths FLOAT

ALTER TABLE PortfolioProject..CovidVaccinations
ALTER COLUMN new_vaccinations FLOAT


-- Make sure all data is imported correctly


SELECT * FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 3,4


SELECT location, date, population, total_cases, new_cases, total_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1,2

/*

Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Converting Data Types

*/


-- GLOBAL NUMBERS

-- Looking at total cases, total deaths, total rocovered, death percentage per total cases 
-- and recovery percentage per total cases

SELECT SUM(new_cases) AS total_cases_worldwide, SUM(new_deaths) AS total_deaths_worlwide,
SUM(new_cases) - SUM(new_deaths) AS total_recovered,
ROUND(SUM(new_deaths)/SUM(new_cases)*100,2) AS death_percentage,
ROUND((SUM(new_cases) - SUM(new_deaths))/SUM(new_cases)*100,2) AS recovery_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL  


 -- I will make use of temp tables to be able to calculate per world population


DROP TABLE IF exists #world_population
CREATE TABLE #world_population
(
total_cases_worldwide numeric,
total_deaths_worldwide numeric,
)
INSERT INTO #world_population
SELECT SUM(new_cases) AS total_cases_worldwide, SUM(new_deaths) AS total_deaths_worlwide
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 


DROP TABLE IF exists #world_population2
CREATE TABLE #world_population2
(
location nvarchar(255),
population numeric,
)
INSERT INTO #world_population2
select location, population from PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population


DROP TABLE IF exists #world_population3
CREATE TABLE #world_population3
(
world_population numeric,
)
INSERT INTO #world_population3
SELECT SUM(population) AS world_population FROM #world_population2


DROP TABLE IF exists #world_population4
CREATE TABLE #world_population4
(
world_population float,
total_cases_worldwide int,
total_deaths_worldwide int
)
INSERT INTO #world_population4
SELECT * FROM #world_population3
CROSS JOIN #world_population

SELECT * FROM #world_population4


-- Looking at the percentage of world population that got infected.

SELECT world_population, total_cases_worldwide, 
ROUND((total_cases_worldwide/world_population) * 100, 2) AS percentage_infected
FROM #world_population4


-- Now looking at the mortality rate, and recovery rate per world population

SELECT world_population, total_deaths_worldwide, 
ROUND((total_deaths_worldwide/world_population) * 100, 2) AS mortality_rate
FROM #world_population4

SELECT world_population, (total_cases_worldwide - total_deaths_worldwide)
AS total_recovered,
ROUND((total_cases_worldwide - total_deaths_worldwide)/world_population * 100, 2) 
AS percentage_recovered
FROM #world_population4


-- BREAKING THINGS DOWN BY TOP 5 COUNTRIES

-- Top 5 countries with the most cases

SELECT TOP 5 location AS country, MAX(total_cases) AS total_cases 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_cases DESC

-- Top 5 countries with the most deaths

SELECT TOP 5 location AS country, MAX(total_deaths) AS total_deaths 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_deaths desc


-- Total Cases vs Total Deaths
-- Looking at the top 5 countries with the hghest death percentage per total cases


SELECT TOP 5 location AS country, MAX(total_cases) AS total_cases, MAX(total_deaths) AS total_deaths, 
ROUND(MAX(total_deaths)/MAX(total_cases)*100, 2) AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY death_percentage DESC


-- Looking at the top 5 countries with the highest Mortality rate


SELECT TOP 5 location AS country, population, MAX(total_deaths) AS total_deaths, 
ROUND(MAX(total_deaths)/population*100, 2) AS mortality_rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY mortality_rate DESC


-- Now let's look at the Total Recovered

SELECT TOP 5 location AS country, MAX(total_cases) AS total_cases, MAX(total_deaths) AS total_deaths,
(MAX(total_cases) - MAX(total_deaths)) AS total_recovered
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_recovered DESC


-- Using CTE, I will calculate the percentage of recovery

WITH 
Recovery AS(
SELECT location AS country, MAX(total_cases) AS total_cases, MAX(total_deaths) AS total_deaths,
(MAX(total_cases) - MAX(total_deaths)) AS total_recovered
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
)
SELECT TOP 5 *, ROUND((total_recovered/total_cases)*100, 2) AS percentage_recovered
FROM Recovery ORDER BY percentage_recovered DESC



-- Total Cases vs Population


-- Let's Look at Countries with the highest infection rate per population


SELECT TOP 5 location, population, MAX(total_cases) AS infection_count, 
ROUND(MAX(total_cases/population)*100, 2) AS percentage_pop_infected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location, population
ORDER BY percentage_pop_infected DESC



-- LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing Continents with the highest death count per population


SELECT continent, SUM(new_deaths) AS total_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY total_deaths DESC


SELECT continent, SUM(new_cases) AS total_cases
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY total_cases DESC




