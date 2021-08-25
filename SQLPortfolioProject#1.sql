select *
from PortfolioProject..CovidDeahts$
order by 3,4


select *
from PortfolioProject..Covidvaccinations$
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeahts$
order by 1,2

alter table [dbo].[CovidDeahts$]
alter column new_vaccinations decimal;

alter table [dbo].[Covidvaccinations$]
alter column new_vaccinations decimal;


-- Looking at total cases vs total Deaths 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeahts$
where location like '%states%'
order by 1,2


-- Looking at total cases vs population
select location, date, total_cases,population, (total_cases/population)*100 as DeathPercentage
from PortfolioProject..CovidDeahts$
where location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as HighesInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeahts$
--where location like '%states%'
Group by location, population
order by PercentagePopulationInfected desc

-- Looking at countries with highest Death count per population
select location, max(total_deaths) as TotalDeathCount 
from PortfolioProject..CovidDeahts$
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- Let's break things down by continent
select continent, max(total_deaths) as TotalDeathCount 
from PortfolioProject..CovidDeahts$
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global numbers

select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage 
from PortfolioProject..CovidDeahts$
where continent is not null
--group by date
order by 1,2


-- Join

select *
from PortfolioProject..CovidDeahts$ dea
join PortfolioProject..Covidvaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date

-- Looking at total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeahts$ dea
join PortfolioProject..Covidvaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 order by 2,3

-- Use CTE

With PopvsVac (Continent, location, date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeahts$ dea
join PortfolioProject..Covidvaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	-- order by 2,3
	 )
	 Select *, (RollingPeopleVaccinated/Population)*100
	 from PopvsVac

-- TEM TABLE

Drop table if exists #PercentedPopulationVaccinated
Create Table #PercentedPopulationVaccinated
(Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentedPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeahts$ dea
join PortfolioProject..Covidvaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	-- order by 2,3

	Select *, (RollingPeopleVaccinated/Population)*100
	 from #PercentedPopulationVaccinated


-- CREATING VIEW TO STORE DATA FOR LATER VIZUALIZATION

create view PercentedPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeahts$ dea
join PortfolioProject..Covidvaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 --order by 2,3

select *
from PercentedPopulationVaccinated