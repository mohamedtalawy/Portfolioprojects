select *
FROM portfolio..CovidDeaths$
where continent is not null
order by 3,4
--select *
--FROM portfolio..CovidVaccinations$
--order by 3,4

----select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
FROM portfolio..CovidDeaths$
order by 1,2
--looking at total cases vs total  deaths

------show what percentage of population got covid
Select location, date, total_cases, population , (total_cases/population)*100 as Percentpopulationinfected
FROM portfolio..CovidDeaths$
--where location= 'Egypt'
order by 1,2

----looking at countries with highest infection rate 
Select location, population, MAX(total_cases) as HighestInfectionCount , MAX(total_cases/population)*100 as Percentpopulationinfected
FROM portfolio..CovidDeaths$
--where location= 'Egypt'
Group by location, population
order by Percentpopulationinfected desc

-- This is showing the countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as totaldeathcount
FROM portfolio..CovidDeaths$

--where location= 'Egypt'
Group by location
order by totaldeathcount desc 

-- lets break things down by contenint
Select continent, MAX(cast(total_deaths as int)) as totaldeathcount
FROM portfolio..CovidDeaths$

where continent is not null
Group by continent
order by totaldeathcount desc 

-- showing the continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as totaldeathcount
FROM portfolio..CovidDeaths$

where continent is not null
Group by continent
order by totaldeathcount desc

--global numbers

Select sum(new_cases) as totalcases, sum(cast( new_deaths as int)) as totaldeaths,  sum(cast (new_deaths as int))/sum(new_cases) as deathspercentages
FROM portfolio..CovidDeaths$
--where location= 'Egypt'
where continent is not null
--group by date 
order by 1,2


--looking at total population vs vaccinations
-- use CTE

with popvsvac(continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
, sum(CONVERT(int, vac.new_vaccinations ))  over (partition by dea.location order by dea.location , dea.date) as rollingpeoplevaccinated
From portfolio..CovidDeaths$ dea
join portfolio..CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(rollingpeoplevaccinated/population)*100
from popvsvac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

