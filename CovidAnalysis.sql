CREATE DATABASE PORTFOLIOPROJECT

SELECT *
FROM CovidDeaths
WHERE continent is not null
ORDER BY 3,4 



--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4
-- SELECTING DATA TO BE USED


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Looking at Total cases vs Total Deaths

SELECT location, date, total_cases, (total_deaths/total_cases)*100
FROM CovidDeaths
ORDER BY 1,2

ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths FLOAT;


ALTER TABLE CovidDeaths
ALTER COLUMN total_cases FLOAT;
-- shows the likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs Population

-- The below query shows what percentage of population got Covid 
SELECT location, date, population, total_cases , (total_cases/population)*100 as PercentagePopulationInfected
FROM CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2


-- Looking at countries with the highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY PercentagePopulationInfected DESC


-- Showing the countries with the Highest Death Count per Population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- BREAKING DOWN THE RESULTS BY CONTINENTS

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Showing the continents with the highest death count per population

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT date, SUM(total_cases), SUM(new_deaths), SUM(new_deaths)/SUM(new_cases)*100  AS DeathPercentage
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2



-- Looking at Total Vaccination vs Vaccinations
SELECT *
FROM CovidDeaths dea
JOIN CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date

ALTER TABLE CovidVaccinations
ALTER COLUMN new_vaccinations FLOAT;


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- USE CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac




-- creating view to store data for visualizations

CREATE VIEW PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac