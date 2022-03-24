/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
Project walkthrough by Alex The Analyst on Youtube
*/

Select * From coviddeathdata$
Where continent is not null
Order by 3,4

--Select Data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population 
From coviddeathdata$
Where continent is not null
Order by 1,2

--Total Cases vs Total Deaths
--Shows liklihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage 
From coviddeathdata$
Where location like '%states%' and continent is not null
Order by 1,2

--Total Cases vs Population
--Shows what percentage of population got covid

Select location, date, total_cases, population, (total_cases/population)*100 as percent_population_infected 
From coviddeathdata$
Where 
--location like '%states%' and 
continent is not null
Order by 1,2

--Countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as highest_infection_count,max((total_cases/population)*100) as percent_population_infected 
From coviddeathdata$
Where continent is not null
Group by location, population
Order by percent_population_infected desc

--Countries with highest death count

Select location, max(cast(total_deaths as int)) as totaldeathcount 
From coviddeathdata$
Where continent is not null
Group by location  
Order by 2 desc

-- BREAKING THINGS DOWN BY CONTINENT

--Continents with highest death count

Select continent, max(cast(total_deaths as int)) as totaldeathcount 
From coviddeathdata$
Where continent is not null 
Group by continent   
Order by 2 desc

--Global numbers

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage 
From coviddeathdata$
Where continent is not null
--Group by date 
Order by 1,2

--Total Population vs Vaccinations

Select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
From coviddeathdata$ dea
Join covidvaccinedata$ vac 
        on dea.location=vac.location 
        and dea.date=vac.date 
Where dea.continent is not null
Order by 2,3

--Using CTE to perform Calculation on Partition By in previous query

With popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated) as
(
Select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
From coviddeathdata$ dea
Join covidvaccinedata$ vac 
        on dea.location=vac.location 
        and dea.date=vac.date 
Where dea.continent is not null
--Order by 2,3
)

Select *, (rollingpeoplevaccinated/population)*100 as percentpopvaccinated
From popvsvac


-- Using Temp Table to perform Calculation on Partition By in previous query

Drop table if exists #percentpopulationvaccinated
Create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

Insert into #percentpopulationvaccinated

Select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
From coviddeathdata$ dea
Join covidvaccinedata$ vac 
          on dea.location=vac.location 
          and dea.date=vac.date 
--Where dea.continent is not null
--Order by 2,3

Select *, (rollingpeoplevaccinated/population)*100 as percentpopvaccinated
From #percentpopulationvaccinated


--Creating view to store data for later visualizations 

Create view percentpopulationvaccinated as 
Select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated

From 
coviddeathdata$ dea
Join covidvaccinedata$ vac 
          on dea.location=vac.location 
          and dea.date=vac.date 
Where dea.continent is not null
--order by 2,3
