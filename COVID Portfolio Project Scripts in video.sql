SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4



--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases,total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

-- Looking Total Cases Vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Cameroon%'
and continent is not null
ORDER BY 1, 2

-- Looking at the total cases Vs the population
-- Shows what percentage of population got covid 
SELECT Location, date,population, total_cases, (total_cases/ population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Cameroon%'
ORDER BY 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/ population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Cameroon%'
GROUP BY Location, population 
ORDER BY PercentPopulationInfected DESC

-- Showing the Countries with the Highest Death Count per Population
-- "cast...as" helps to convert from nvarchar to int

SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Cameroon%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- Let's break things down by Continents

-- Showing the Continent with the Highest Death Count

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Cameroon%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Global Numbers
-- total cases, deaths numbers all around the world

SELECT  SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM (new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Cameroon%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2

-- Looking at the Total Population Vs Vaccinations
-- convert and cast in do exactly the same thing

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition BY dea.Location Order BY dea.location,
dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population) *100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3


--Use CTE

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeoplevacinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition BY dea.Location Order BY dea.location,
dea.date) AS RollingPeoplevacinated
--, (RollingPeopleVaccinated/dea.population) *100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)

SELECT *,  (RollingPeoplevacinated/Population)*100
FROM PopVsVac

--Temp Table
-- the variable type should be specified

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PopVsVac AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition BY dea.Location Order BY dea.location,
dea.date) AS RollingPeoplevacinated
--, (RollingPeopleVaccinated/dea.population) *100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3


SELECT *
FROM PopVsVac