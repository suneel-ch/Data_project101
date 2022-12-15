-- select the data we are going to using 

select location, date, total_cases, new_cases,total_deaths, population
from Project_01..CovidDeaths
order by 1,2

--looking at Total cases Vs Total deaths
-- shows the likelyhood of dying 
select location, date, total_cases,total_deaths, (total_deaths / total_cases)* 100 as DeathPercentage
from Project_01..CovidDeaths
where location like '%Nepal%'
order by 1,2

--Looking at total cases vs the population
-- shows what percentage got covid
select location, date,population, total_cases, (total_cases / population)* 100 as CasesPercentage
from Project_01..CovidDeaths
where location like '%Nepal%'
order by 1,2





-- highest infection rate by country compared to population 

select location, population, max(total_cases) as highestInfectionCount, max((total_cases / population)* 100) as PercentPoulation 
from Project_01..CovidDeaths
group by location, population
--where location like '%Nepal%'
order by PercentPoulation desc

-- showing the Country with higest Death count per population 

select location, max(cast(total_deaths as int)) as TotalDeathCount
from Project_01..CovidDeaths
where continent is not null
group by location
--where location like '%Nepal%'
order by TotalDeathCount desc

-- order by continent
-- -- Showing the continet with highest death count 
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from Project_01..CovidDeaths
where continent is not null
group by continent
--where location like '%Nepal%'
order by TotalDeathCount desc

--Global numbers

select  sum(new_cases)as total_cases, sum(cast (new_deaths as int)) as total_deaths ,
sum(cast (new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from Project_01..CovidDeaths
where continent is not null
--group by date
order by 1,2


-- looking at total popualtion vs Vaccination 
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
,sum(convert(bigint , vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location, dea.date) as 
rollingPeopleVaccinated,

from Project_01..CovidDeaths dea
Join Project_01..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = dea.date
where dea.continent is not null
order by 2,3
	

-- use CTE

with popvsVac (continent, location, date, population, new_vaccinations, rollingPeopleVaccinated)
as 
(
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
,sum(convert(bigint , vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location, dea.date) as 
rollingPeopleVaccinated
from Project_01..CovidDeaths dea
Join Project_01..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = dea.date
where dea.continent is not null
--order by 2,3
)

select * , (rollingPeopleVaccinated/population) * 100
from popvsVac


--temp table 
Create table #percentPopulationVaccination
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)


insert into #percentPopulationVaccination
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
,sum(convert(bigint , vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location, dea.date) as 
rollingPeopleVaccinated
from Project_01..CovidDeaths dea
Join Project_01..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = dea.date
where dea.continent is not null
--order by 2,3

select * , (rollingPeopleVaccinated/population) * 100
from #percentPopulationVaccination

--creating view to store data for later visualization 
create view percentPopulationVaccination as 
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
,sum(convert(bigint , vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location, dea.date) as 
rollingPeopleVaccinated
from Project_01..CovidDeaths dea
Join Project_01..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = dea.date
where dea.continent is not null
--order by 2,3