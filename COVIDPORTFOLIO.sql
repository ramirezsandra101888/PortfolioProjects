SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using. 

SELECT Location,date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1,2


--Looking at Total Cases vs Total Deaths
--This shows the likelihoodof dying if you contract covid in your country 

SELECT Location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
WHERE continent is not null
order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

SELECT Location,date,  Population,total_cases, (total_cases/Population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
order by 1,2

--Looking at Countries with the Highest Infection Rate compared to Population

SELECT Location,  Population,max(total_cases) as HighestInfectionCount, max((total_cases/Population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location,Population
WHERE continent is not null
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count Per Population

SELECT Location,MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Where continent is not null
GROUP BY Location 
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT 

--Showing the Continents with the Highest Death Count Per Population

SELECT continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Where continent is not null
GROUP BY continent
order by TotalDeathCount desc

--GLOBAL NUMBERS 

SELECT SUM(New_cases) as total_cases,SUM(CAST(new_deaths as int))as total_deaths,SUM(CAST(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--group by date
order by 1,2


--Looking at Total Population vs Vaccinations 

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,Sum(cast(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location Order By dea.Location,dea.Date) as RollingPeopleVaccinated
,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location =vac.location
   and dea.date=vac.date
   where dea.continent is not null
   order by 2,3


   --USE CTE	
With PopvsVac(Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,Sum(cast(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location Order By dea.Location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location =vac.location
   and dea.date=vac.date
   where dea.continent is not null
--order by 2,3
   )
SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac



--Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric	
)

Insert Into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,Sum(cast(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location Order By dea.Location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location =vac.location
   and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

SELECT *,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,Sum(cast(vac.new_vaccinations as int)) OVER(PARTITION BY dea.location Order By dea.Location,dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location =vac.location
   and dea.date=vac.date
where dea.continent is not null
--order by 2,3


SELECT *
FROM PercentPopulationVaccinated


