select * from coviddeathdata$
where continent is not null
order by 3,4

--select * from covidvaccinedata$

--Select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population from coviddeathdata$
where continent is not null
order by 1,2

--Looking at total cases vs total deaths
--shows liklihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage from coviddeathdata$
where location = 'United States' and continent is not null
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as percent_population_infected from coviddeathdata$
where location = 'United States' and continent is not null
order by 1,2


--looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as highest_infection_count,max((total_cases/population)*100) as percent_population_infected from coviddeathdata$
where continent is not null
group by location, population
order by percent_population_infected desc

--showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as totaldeathcount from coviddeathdata$
where continent is not null
group by location  
order by 2 desc

--LETS BREAK THINGS DOWN BY CONTINENT
--Showing the continents with the highest death count per population 

select continent, max(cast(total_deaths as int)) as totaldeathcount from coviddeathdata$
where continent is not null 
group by continent   
order by 2 desc


--Global numbers


select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage 
from coviddeathdata$
where continent is not null
group by date 
order by 1,2

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage 
from coviddeathdata$
where continent is not null
--group by date 
order by 1,2


--looking at total population vs vaccinations

select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated

from 
coviddeathdata$ dea
join covidvaccinedata$ vac 
on dea.location=vac.location 
and dea.date=vac.date 
where dea.continent is not null
order by 2,3

--option 1 use cte

with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated) as
(
select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated

from 
coviddeathdata$ dea
join covidvaccinedata$ vac 
on dea.location=vac.location 
and dea.date=vac.date 
where dea.continent is not null
)

select *, (rollingpeoplevaccinated/population)*100 as percentpopvaccinated
from popvsvac



--option 2 temp table

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated

select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated

from 
coviddeathdata$ dea
join covidvaccinedata$ vac 
on dea.location=vac.location 
and dea.date=vac.date 
--where dea.continent is not null



select *, (rollingpeoplevaccinated/population)*100 as percentpopvaccinated
from #percentpopulationvaccinated


--creating view to store data for later visualizations 

create view percentpopulationvaccinated as 
select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated

from 
coviddeathdata$ dea
join covidvaccinedata$ vac 
on dea.location=vac.location 
and dea.date=vac.date 
where dea.continent is not null
--order by 2,3

select * from percentpopulationvaccinated