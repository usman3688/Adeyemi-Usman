Select *
from PortfolioProject..CovidDeaths
where location is not null
order by 3,4


--Select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

---Select the Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


---we will be looking at the total cases vs total deaths
---Shows likelihood of dying if you contract covid in your country.

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%nigeria%'
and continent is not null
order by 1,2


--Looking at total cases Vs Population
--Shows what pecentage of the popolation has contracted Covid

Select location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationaffected
from PortfolioProject..CovidDeaths
where location like '%nigeria%'
order by 1,2


--looking at countries with highest infection rate compared to poplation

Select location,  Population, Max(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationaffected
from PortfolioProject..CovidDeaths
--where location like '%nigeria%'
group by location,  Population
order by PercentPopulationaffected desc

--countries with the highest death count per population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where location is not null
group by location
order by TotalDeathCount  desc

--BREAKING THINGS DOWN BY CONTINENT


--Showing Continents with the highest death count per population


Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

Select date, Sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total,  sum(cast(new_deaths as int))/sum(New_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
group by date
order by 1,2


Select Sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total,  sum(cast(new_deaths as int))/sum(New_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
--group by date
order by 1,2


--Looking at total population Vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPpleVac
from PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccinations Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
--where dea.continent is not null
order by 2,3


--USE CTE

with PopVsVac (continent, location, date, population, new_vaccinations, RollingPpleVac)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPpleVac
from PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccinations Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
--where dea.continent is not null
--order by 2,3
)

Select *, (RollingPpleVac/population)*100
from PopVsVac


-- TEMP TABLE

drop table if exists #percentpopulationVaccinated
create table #percentpopulationVaccinated 
(
continent nvarchar(255),
location nvarchar(255),
Date Datetime,
population numeric,
new_vaccinations numeric,
rollingPplevac numeric
)
insert into #percentpopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPpleVac
from PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccinations Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPpleVac/population)*100
from  #percentpopulationVaccinated

--creating view to store data for later visualizations

Create view percentpopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPpleVac
from PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccinations Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where dea.continent is not null
--order by 2,3

Select *
from percentpopulationVaccinated

create view RollingPpleVac as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPpleVac
from PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccinations Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
--where dea.continent is not null
--order by 2,3

Select *
from RollingPpleVac