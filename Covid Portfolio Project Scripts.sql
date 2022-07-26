SELECT *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--SELECT *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select data to be used

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Examining Total Cases by Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2
	-- Shows likelyhood of death if contracting Covid by Country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'United States'
order by 1,2
	-- Shows likelyhood of death if contracting Covid in the USA

-- Total Cases by Population

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentageCovidPop
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2
	-- Shows what percentage of each countries population reported getting covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentageCovidPop
From PortfolioProject..CovidDeaths
Where location = 'United States'
order by 1,2
	-- Percentage of the USA Population that reported having covid

-- Countries with highest Infection Rate by Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
order by PercentagePopInfected desc

-- Countries with Highest Death Count by Population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

-- Breakdown by continent with highest deathcount

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount desc

-- Global numbers

Select date, Sum(new_cases) as TotalGlobalCases, Sum(cast(new_deaths as int)) as TotalGlobalDeaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as GlobalDeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
group by date
order by 1,2
	-- Global cases, deaths, and percentage each day

Select Sum(new_cases) as TotalGlobalCases, Sum(cast(new_deaths as int)) as TotalGlobalDeaths, 
Sum(cast(new_deaths as int))/Sum(new_cases)*100 as GlobalDeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2
	--Aggregated Global cases, deaths, and percentage

Select Sum(population) as GlobalPopulation, Sum(new_cases) as TotalGlobalCases, 
Sum(cast(new_deaths as int)) as TotalGlobalDeaths, 
Sum(new_cases)/Sum(population)*100 as GlobalInfectionRatePercentage, 
Sum(cast(new_deaths as int))/Sum(new_cases)*100 as GlobalDeathPercentageForInfected
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2
	--Aggregated global cases, deaths, cases percentage, deaths percentage


-- Explore CovidVaccinations Table

Select *
From PortfolioProject..CovidVaccinations

--Join CovidDeaths and CovidVaccinations

Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Total Population by Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(bigint, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingCountVaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
-- Rolling count of vaccinations by country and date


--CTE to create RollingCountVaccinations used in RollingCountVaccinationsPercentage

With PopvsVac (Continent, Location, Date, Population, NewVaccinations, RollingCountVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(bigint, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingCountVaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingCountVaccinations/Population)*100 as RollingCountVaccinationsPercentage
From PopvsVac


--Tempt Table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
NewVaccinations numeric,
RollingCountVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(bigint, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingCountVaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select*, (RollingCountVaccinated/Population)*100 as RollingCountVaccinationsPercentage
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(bigint, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingCountVaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select*
From PercentPopulationVaccinated