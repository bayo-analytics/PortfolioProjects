select * from dbo.CovidDeaths$
order by 3,4
--select * from dbo.CovidVaccinations
--order by 3,4
--select data that are to be used
select location,date,total_cases,new_cases,total_deaths,population from dbo.CovidDeaths$
order by 1,2

--Looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as deathpercentage from dbo.CovidDeaths$
where location like '%Nigeria%'
order by 1,2

--Looking at total cases vs population
--shows what percentage of population got covid
select location,date,population,total_cases, (total_cases/population)*100 as deathpercentage from dbo.CovidDeaths$
where location like '%Nigeria%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to population 

select location,population,max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected from dbo.CovidDeaths$
--where location like '%Nigeria%'
group by location,population
order by 4  desc

--Showing countries with the highest death count per population

select location,max(cast(total_deaths as int)) as TotalDeathCount from dbo.CovidDeaths$
--where location like '%Nigeria%'
where continent is null
group by location
order by 2 DESC

--Showing continents with the highest death counts

select continent,max(cast(total_deaths as int)) as TotalDeathCount from dbo.CovidDeaths$
--where location like '%Nigeria%'
where continent is not null
group by continent
order by 2 DESC

--GLOBAL NUMBERS

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(new_cases)/sum(cast(new_deaths as int)) as deathpercentage
from dbo.CovidDeaths$
--where location like '%Nigeria%'
where continent is not null
--group by date
order by 1,2
select * from dbo.CovidVaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))  over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated from dbo.CovidDeaths$ dea
join dbo.CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--USE CTE
with PopvsVar(Continent,Location,Date,Population,New_vaccinations,RollingPeopleVaccinated) 
as (select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))  over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated from dbo.CovidDeaths$ dea
join dbo.CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null)
--=order by 2,3
select *,(RollingPeopleVaccinated/Population)*100 from PopvsVar

--TEMP TABLE
DROP TABLE PercentagePopulationVaccinated
create table PercentagePopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population int,
New_vaccinations int,
RollingPeopleVaccinated int)

insert into PercentagePopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))  over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated from dbo.CovidDeaths$ dea
join dbo.CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3
select *,(RollingPeopleVaccinated/Population)*100 from PercentagePopulationVaccinated

--Creating view to store data for later visualization

select * from PercentagePopulationVaccinated