--Covid 19 Data Exploration

-- Viewing the Covid Death data sorted by location and date
-- Adding the WHERE clause to check if there are null values in a column (i.e.,continent)
SELECT *
FROM PortfolioProject..CovidDeaths
-- WHERE continent is null
ORDER BY 3,4

-- Covid Death data specifying the columns needed
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Total Cases vs Total Deaths filtering the location to Philippines
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
FROM PortfolioProject..CovidDeaths
WHERE location='Philippines'
ORDER BY 1,2

-- Total Cases vs Populations filtering the location to Philippines
SELECT location, date, total_cases, population, (total_cases/population)*100 as CaseRate
FROM PortfolioProject..CovidDeaths
WHERE location='Philippines'
ORDER BY 1,2

-- Countries with highest case rate per population
SELECT location, population, MAX(total_cases) as HighestCase, MAX(total_cases/population)*100 as PopulationCaseRate
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PopulationCaseRate desc

-- Countries with highest death rate per population
SELECT location, population, MAX(cast(total_deaths as int)) as HighestDeath, MAX(cast(total_deaths as int)/population)*100 as PopulationDeathRate
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PopulationDeathRate desc

-- Countries with highest death count
-- Filter out the nulls in continent column
SELECT location, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY HighestDeathCount desc

-- Global daily death percentage
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- CTE
WITH PopulationvsVaccination
(Continent, Location, Date, Population, New_Vaccinations,RollingVaccinationCount)
AS
(
-- Join CovidDeaths and CovidVaccinations
-- Total Population vs Vaccinations
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cast(cv.new_vaccinations as int)) OVER (Partition by cd.location ORDER BY cd.location, cd.date) as RollingVaccinationCount
FROM PortfolioProject..CovidDeaths as cd
JOIN PortfolioProject..CovidVaccinations as cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null
)
SELECT *, (RollingVaccinationCount/Population)*100
FROM PopulationvsVaccination
ORDER BY location

-- Create Table
DROP TABLE if exists PopvsVaccination
CREATE TABLE PopvsVaccination
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric,
RollingVaccinationCount numeric
)

INSERT INTO PopvsVaccination
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cast(cv.new_vaccinations as int)) OVER (Partition by cd.location ORDER BY cd.location, cd.date) as RollingVaccinationCount
FROM PortfolioProject..CovidDeaths as cd
JOIN PortfolioProject..CovidVaccinations as cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null

SELECT *, (RollingVaccinationCount/Population)*100
FROM PopvsVaccination
ORDER BY location

-- Create View
CREATE VIEW VaccinatedPopulation as
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cast(cv.new_vaccinations as int)) OVER (Partition by cd.location ORDER BY cd.location, cd.date) as RollingVaccinationCount
FROM PortfolioProject..CovidDeaths as cd
JOIN PortfolioProject..CovidVaccinations as cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null

Select *
From VaccinatedPopulation