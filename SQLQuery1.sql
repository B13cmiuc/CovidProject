
select location , date , population, total_cases , new_cases, total_deaths
from Portfolio_Project..covid_Death
order by 1,2

-- looking at total cases vs total deaths

select location, date, total_cases, total_deaths , (total_deaths / total_cases)*100 as death_percentage
from Portfolio_Project..covid_Death
order by 1,2

-- death percentage from covid in Morocco
select location, date,(total_deaths / total_cases)*100 as death_percentage
from Portfolio_Project..covid_Death
where location like '%occo%'
order by 2 desc

-- Percentage of infected people from the population in Morocco
select location, date,population, total_cases, (total_cases/ population)*100 as infection_percentage
from Portfolio_Project..covid_Death
where location like '%occo%'
order by 2 desc

-- countries with Highest Infection Rate within the population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio_Project..covid_Death
Group by Location, Population
order by PercentPopulationInfected desc

-- countries with Highest Death Count per Population
Select Location, MAX(Total_deaths) as TotalDeathCount
From Portfolio_Project..covid_Death
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- continents stats
-- continents with Highest Death Count per Population

--Select location,MAX(Total_deaths) as TotalDeathCount
--From Portfolio_Project..covid_Death
--Where continent is null and location not like '%income'
--Group by location
--order by 2 desc

Select continent, MAX(Total_deaths) as TotalDeathCount
From Portfolio_Project..covid_Death
Where continent is not null
Group by continent
order by 2 desc

-- death percentage from covid per continent per current date
select continent, sum(new_cases) as totalCasesContinent, sum(cast(new_deaths as int)) as totalDeathsContinent, (SUM(cast(new_deaths as int))/SUM(New_Cases))*100 as DeathPercentage , MAX(date) as currentDate
from Portfolio_Project..covid_Death
where continent is not null
group by continent
order by 4 desc

------------------------------------------------------


-- Vaccination rate within the population per country per last date statistics
Select dea.location, max(dea.date) as updatedDay, sum(cast(new_vaccinations as bigint)) as totalVaccCountry, (sum(cast(new_vaccinations as bigint)/ dea.population)*100) as VaccRateCountry
from Portfolio_Project..covid_Death dea	
Join Portfolio_Project..covid_vaccination vacci
	on dea.location = vacci.location and dea.date = vacci.date
where new_vaccinations is not null and dea.continent is not null
group by dea.location
order by 4 desc

-- Total vaccination within the population per continent per last date statistics
Select dea.continent, max(dea.date) as updatedDay, sum(cast(new_vaccinations as bigint)) as totalVaccContinent
from Portfolio_Project..covid_Death dea	
Join Portfolio_Project..covid_vaccination vacci
	on dea.location = vacci.location and dea.date = vacci.date
where new_vaccinations is not null and dea.continent is not null
group by dea.continent
order by 3 desc

-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vacci.new_vaccinations
, SUM(CONVERT(bigint,vacci.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from Portfolio_Project..covid_Death dea	
Join Portfolio_Project..covid_vaccination vacci
	on dea.location = vacci.location and dea.date = vacci.date
where dea.continent is not null 
order by 2,3

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
Select dea.continent, dea.location, dea.date, dea.population, vacci.new_vaccinations
, SUM(CONVERT(bigint,vacci.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..covid_Death dea
Join Portfolio_Project..covid_vaccination vacci
	On dea.location = vacci.location
	and dea.date = vacci.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vacci.new_vaccinations
, SUM(CONVERT(bigint,vacci.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..covid_Death dea
Join Portfolio_Project..covid_vaccination vacci
	On dea.location = vacci.location
	and dea.date = vacci.date
where dea.continent is not null 