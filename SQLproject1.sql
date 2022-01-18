select * from PortfolioProject1..Coviddeaths
order by 3,4

select * from PortfolioProject1..Covidvaccinations
order by 3,4

--Select data that we are gonna be using

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject1..Coviddeaths order by 1,2


-- looking at total cases vs total deaths

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject1..Coviddeaths order by 1,2

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject1..Coviddeaths where location='venezuela' order by 1,2

-- looking at total cases vs Population

select Location, date, total_cases, population, (total_cases/population)*100 as infection_percentage
from PortfolioProject1..Coviddeaths where location='venezuela' order by 1,2

-- looking at countries with highest infection rate compared to population

select Location, MAX(total_cases) as highest_infection_count, population, max((total_cases/population))*100 
as infection_percentage
from PortfolioProject1..Coviddeaths 
Group by location, population
order by infection_percentage desc

-- showing countries with Highest Death Count per population

select Location, MAX(cast(total_deaths as int)) as Total_death_count from PortfolioProject1..Coviddeaths 
where continent is not null
Group by location
order by Total_death_count desc

-- LET'S BREAK THINGS DOWN BY CONTINENT(highest death count per population)

select continent, MAX(cast(total_deaths as int)) as Total_death_count from PortfolioProject1..Coviddeaths 
where continent is not null
Group by continent
order by Total_death_count desc

-- GLOBAL NUMBERS

select sum(new_cases) as total_cases, sum(cast(new_Deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from PortfolioProject1..Coviddeaths WHERE continent is not null order by 1,2

--JOIN USAGE

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as
rollingvaccinations --, (rollingvaccinations/population)*100
from PortfolioProject1..Coviddeaths dea
join PortfolioProject1..Covidvaccinations vac on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null --order by 2,3

-- USE CTE

with popvsvac (continent, location, date, population, new_vaccinations, rollingvaccinations) as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as
rollingvaccinations 
from PortfolioProject1..Coviddeaths dea
join PortfolioProject1..Covidvaccinations vac on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null --order by 2,3
)
select *,(rollingvaccinations/population)*100 from popvsvac

-- USE TEMP TABLE 
DROP table if exists #percentpopulationvaccinated
Create table #percentpopulationvaccinated 
(continent nvarchar(255),
location nvarchar(255), 
date datetime,
population numeric,
new_vaccinations numeric, 
rollingvaccinations numeric)

insert into #percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as
rollingvaccinations --, (rollingvaccinations/population)*100
from PortfolioProject1..Coviddeaths dea
join PortfolioProject1..Covidvaccinations vac on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null --order by 2,3

select *,(rollingvaccinations/population)*100 from #percentpopulationvaccinated

-- creating view to store data for later visualizations

create view percentpopulationvaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as
rollingvaccinations --, (rollingvaccinations/population)*100
from PortfolioProject1..Coviddeaths dea
join PortfolioProject1..Covidvaccinations vac on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null --order by 2,3

