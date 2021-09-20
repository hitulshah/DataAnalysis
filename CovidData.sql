Select*
From portfolio..covidDeaths
Where continent is not null
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From portfolio..covidDeaths
order by 1,2

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From portfolio..covidDeaths
Where location like '%states%'
order by 1,2

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From portfolio..covidDeaths
Where location like '%states%'
order by 1,2

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From portfolio..covidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

Select Location, MAX(cast(total_deaths as int)) as HighestDeathCount
From portfolio..covidDeaths
Where continent is not null
--Where location like '%states%'
Group by Location
order by HighestDeathCount desc

Select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
From portfolio..covidDeaths
Where continent is not null
--Where location like '%states%'
Group by continent
order by HighestDeathCount desc

--GLOBAL NUMBERS
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, ( SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From portfolio..covidDeaths
--Where location like '%states%'
Where continent is not null
Group by date
order by 1,2



With PopvsVac (Continent, Location, date,population,new_vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location) as RollingPeopleVaccinated
From portfolio..CovidDeaths dea
Join portfolio..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
and dea.location like '%India%'
--order by 2,3
)
Select*, (RollingPeopleVaccinated/population)*100
From PopvsVac


--Temp Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location) as RollingPeopleVaccinated
From portfolio..CovidDeaths dea
Join portfolio..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
--order by 2,3
Select*, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

Create View PercentPopulationVaccinated1 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location) as RollingPeopleVaccinated
From portfolio..CovidDeaths dea
Join portfolio..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
--order by 2,3

Select*
From PercentPopulationVaccinated1
