SELECT *
FROM SQL_project..CovidDeaths
WHERE continent is not null
ORDER BY 3,4


--SELECT *
--FROM SQL_project..CovidVaccination
--ORDER BY 3,4

--Selecting data to be used--
SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM SQL_project..CovidDeaths
ORDER BY 1,2

-- Total cases vs Total deaths--
--Indicates chance of dying if contracted with covid in redpective country--
SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
FROM SQL_project..CovidDeaths
WHERE location like '%India%'
ORDER BY 1,2

-- Total cases vs Population--
SELECT Location,date,Population,total_cases,(total_cases/population)*100 as Percentpopulationinfected
FROM SQL_project..CovidDeaths
WHERE location like '%India%'
ORDER BY 1,2

--Countries with highest infection rate compared to their population--
SELECT Location,Population,MAX(total_cases)as Highestinfection,MAX((total_cases/population))*100 as Percentpopulationinfected
FROM SQL_project..CovidDeaths
Group by Location,Population
ORDER BY Percentpopulationinfected desc

--Countries with highest death count per population--
SELECT Location,MAX(cast(Total_deaths as int)) as  Totaldeathcount
FROM SQL_project..CovidDeaths
WHERE continent is not null
Group by Location
ORDER BY Totaldeathcount desc

-- To check data Continet wise--
SELECT continent,MAX(cast(Total_deaths as int)) as  Totaldeathcount
FROM SQL_project..CovidDeaths
WHERE continent is not null
Group by continent
ORDER BY Totaldeathcount desc

-- Global numbers--
SELECT SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
FROM SQL_project..CovidDeaths
WHERE continent is not null
--group by date
order by 1,2

---Total population vs vaccinated 
SELECT dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations
, SUM (CONVERT(int,vacc.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
FROM SQL_project..CovidDeaths dea
JOIN SQL_project..Covidvaccination vacc
	on dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null
order by 2,3

-- Using CTE--
WITH popvsvacc(Continent,Location,Date,Population,New_vaccinations,RollingPeopleVaccinated)
as
(SELECT dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations
, SUM (CONVERT(int,vacc.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM SQL_project..CovidDeaths dea
JOIN SQL_project..Covidvaccination vacc
	on dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM popvsvacc

-- Temp table--

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations
, SUM (CONVERT(bigint,vacc.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM SQL_project..CovidDeaths dea
JOIN SQL_project..Covidvaccination vacc
	on dea.location = vacc.location
	and dea.date = vacc.date
--where dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creatibg view to store data for later visualisations--
CREATE view PercentpopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations
, SUM (CONVERT(bigint,vacc.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM SQL_project..CovidDeaths dea
JOIN SQL_project..Covidvaccination vacc
	on dea.location = vacc.location
	and dea.date = vacc.date
--where dea.continent is not null
--order by 2,3




