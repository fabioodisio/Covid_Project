select *
From test..CovidDeaths
Where continent is not null
Order by 3,4

--select *
--From test..CovidVaccinations
--Order by 3,4


select Location, date, total_cases, new_cases, total_deaths, population
From test..CovidDeaths
Order by 1,2


-- Looking at total cases vs total deaths
-- Shows the likelyhood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From test..CovidDeaths
Where location like '%Brazil%'
and continent is not null
Order by 1,2


-- Looking at the total cases vs the population
-- shows percentage of population that got Covid
select Location, date,population, total_cases, (total_cases/population)*100 as DeathPercentage
From test..CovidDeaths
Where location like '%Brazil%'
Order by 1,2


--Looking at countries with highest infection rate compared to population
select Location,population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From test..CovidDeaths
--Where location like '%Brazil%'
Group by Location,population
Order by PercentPopulationInfected desc



-- Showing Countries with Highest death count per population
select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From test..CovidDeaths
--Where location like '%Brazil%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc



--Let's break things down by continet
select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From test..CovidDeaths
--Where location like '%Brazil%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


select location, Max(cast(Total_deaths as int)) as TotalDeathCount
From test..CovidDeaths
--Where location like '%Brazil%'
Where continent is null
Group by location
Order by TotalDeathCount desc



--Showing the continents with highest death count per population
select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From test..CovidDeaths
--Where location like '%Brazil%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc



-- Global Numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage --, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From test..CovidDeaths
--Where location like '%Brazil%'
where continent is not null
--group by date
Order by 1,2



--Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From test..CovidDeaths dea
join test..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 2,3



--Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From test..CovidDeaths dea
join test..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac



-- Temp Table

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From test..CovidDeaths dea
join test..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- creating view to store data for later visualizations

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From test..CovidDeaths dea
join test..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated