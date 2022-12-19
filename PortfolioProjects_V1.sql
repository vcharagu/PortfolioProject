


select location,date,total_cases,new_cases,total_deaths,population
from mememe..CovidDeaths$ 
where continent is not null
order by 1,2

--Looking at Total cases vs Total Deaths


select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from mememe..CovidDeaths$ 
where continent is not null 

--where location like '%states%'
order by 1,2


--Looking at Total cases vs Population
select location,date,total_cases,population, (total_cases/population)*100 as PercentPopulationInfected
from mememe..CovidDeaths$ 
where continent is not null

--where location like '%states%'
order by 1,2 

--Coubtries with highest infection rates compared to population

select location,population, MAX(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as PercentagePopulationInfected
from mememe..CovidDeaths$ 
where continent is not null

--where location like '%states%'
Group by location,population
order by PercentagePopulationInfected desc



--Coutries with the highest Death count per population


select continent,Max(Cast(total_deaths as int)) as TotalDeathCount
from mememe..CovidDeaths$ 
where continent is not null

--where location like '%states%'
Group by continent
order by TotalDeathCount desc


--Showing continents with highest death count per population

select continent,Max(Cast(total_deaths as int)) as TotalDeathCount
from mememe..CovidDeaths$ 
where continent is not null

--where location like '%states%'
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS--
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from mememe..CovidDeaths$ 
where continent is not null
--group by date
order by 1,2


--JOIN
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER
(Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from mememe..CovidDeaths$ dea
join mememe..CovidVaccines vac
	on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

 
--USE CTE

With PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER
(Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from mememe..CovidDeaths$ dea
join mememe..CovidVaccines vac
	on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

)

select *,(RollingPeopleVaccinated/population)*100
from PopvsVac


--TEMP TABLE
DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated 
(
continent nvarchar(255),location nvarchar(255),date datetime,population numeric,new_vaccination numeric,RollingPeopleVaccinated numeric  


)

Insert into #PercentagePopulationVaccinated

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER
(Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from mememe..CovidDeaths$ dea
join mememe..CovidVaccines vac
	on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


select *,(RollingPeopleVaccinated/population)*100
from #PercentagePopulationVaccinated



------create view for data visualization

Create View PercentagePopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER
(Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from mememe..CovidDeaths$ dea
join mememe..CovidVaccines vac
	on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 


SELECT TOP (1000) [continent]
      ,[location]
      ,[date]
      ,[population]
      ,[new_vaccinations]
      ,[RollingPeopleVaccinated]
  FROM [mememe].[dbo].[PercentagePopulationVaccinated]