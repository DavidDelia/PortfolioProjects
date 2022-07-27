/*
Covid-19 Data Exploration via SQL
Sourced: Our World in Data

Demonstrates: CTE's, Joins, Temp Tables, Windows Functions, Aggregate Functions, View Creation, Data Type Conversion
*/

SELECT *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

-- Select Data to be Used

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Data on Total Cases by Total Deaths

	-- Percent Chance of Death if Contracted Covid by Country
Select Location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2
	
	-- Percent Chance of Death if Contracted Covid in the USA
Select Location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'United States'
order by 1,2
	
	-- Alternate of Percent Chance of Death if Contracting Covid in the USA
Select Location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '&States%'
order by 1,2
	

-- Data on Total Cases by Population

	-- Percentage of Country Population Reported Covid Infection by Date
Select Location, date, population, total_cases, 
(total_cases/population)*100 as PercentageCovidPop
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2
	
	-- Percentage of USA Population Reported Covid Infection by Date
Select Location, date, population, total_cases, 
(total_cases/population)*100 as PercentageCovidPop
From PortfolioProject..CovidDeaths
Where location = 'United States'
order by 1,2

-- Data on Highest Infections by Population

	-- Highest Infections by country as percentage
Select Location, population, MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/population))*100 as PercentagePopInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
order by PercentagePopInfected desc

-- Data on Highest Death Count per Population

	--Countries with Highest Death Count by Population
Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

	-- Continents with Highest Death Count by Population
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Covid-19 Numbers

	-- Global Case Count, Death Count, and Death Percentage by Date
Select date, Sum(new_cases) as TotalGlobalCases, 
Sum(cast(new_deaths as int)) as TotalGlobalDeaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as GlobalDeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
group by date
order by 1,2

	--Aggregated Global Case Count, Death Count, and Death Percentage
Select Sum(new_cases) as TotalGlobalCases, 
Sum(cast(new_deaths as int)) as TotalGlobalDeaths, 
Sum(cast(new_deaths as int))/Sum(new_cases)*100 as GlobalDeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

	--Aggregated Global Population, Case Count, Death Count, Case Percentage by Population, and Deaths Percentage by Case Count
Select Sum(population) as GlobalPopulation, Sum(new_cases) as TotalGlobalCases, 
Sum(cast(new_deaths as int)) as TotalGlobalDeaths, 
Sum(new_cases)/Sum(population)*100 as GlobalInfectionRatePercentage, 
Sum(cast(new_deaths as int))/Sum(new_cases)*100 as GlobalDeathPercentageForInfected
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


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

	-- Rolling Count of Vaccinations by Country and Date
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(bigint, vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingCountVaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- CTE to create RollingCountVaccinations used in RollingCountVaccinationsPercentage

	--Rolling Count of Vaccinations by Country and Date as Percentage of Population
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


-- Tempt Table for creating RollingCountVaccinations used in RollingCountVaccinationsPercentage

	-- Rolling Count of Vaccinations by Country and Date as Percentage of Population
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

	-- Executing Temp Table
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
where dea.continent is not null;
