--Select *
--From PortfolioProject..CovidDeaths$
--order BY 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order BY 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
ORDER BY 1,2

-- Viewing the relationship between Total Cases and Total Deaths 

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS percentage_deaths

FROM PortfolioProject..CovidDeaths$
WHERE Location like '%states%'
ORDER BY 1,2

--- Percentage of US Population that have been infected with Covid-19

Select Location, date, population, total_cases, (total_cases/population)*100 AS US_Infection_Percentage

FROM PortfolioProject..CovidDeaths$
WHERE Location like '%states%'
ORDER BY 1,2

Select Location, population, MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/population))*100 AS PercentPopulation_Infected
FROM PortfolioProject..CovidDeaths$
-- WHERE Location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulation_Infected desc

-- Create View for HighestInfection Numbers
Create View HighC19Infection as
Select Location, population, MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/population))*100 AS PercentPopulation_Infected
FROM PortfolioProject..CovidDeaths$
-- WHERE Location like '%states%'
GROUP BY Location, Population
--ORDER BY PercentPopulation_Infected desc


-- Country with the Highest Total Death Count
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
-- WHERE Location like '%states%'
WHERE continent is not null
GROUP BY Location 
ORDER BY TotalDeathCount desc

-- Continent with the Highest Death Count

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is null
GROUP BY continent 
ORDER BY TotalDeathCount desc

-- Global Covid-19 Death Percentages
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

-- Storing C19 Death Percentages for future Data Visualization
CREATE View  GlobalDeathNumbers as
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
--order by 1,2

-- Let's look at Covid Vaccinations rate now

Select *
FROM PortfolioProject..CovidVaccinations$


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location,
dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


-- Using CTE
With PopvsVac (continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location,
dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)

-- USE CTE

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location,
dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 as Vaccination_Percentage
FROM #PercentPopulationVaccinated

-- Creating view for Data Visualization

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location,
dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3



select *
FROM PercentPopulationVaccinated