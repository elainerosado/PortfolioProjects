SELECT *
FROM PortfolioProject..CovidDeaths_CSV
Where continent is not null 
order by 3,4 



--SELECT *
--FROM PortfolioProject..CovidVaccinations_CVS
--order by 3,4 

select location,date, total_cases, new_cases,total_deaths,population_density
from PortfolioProject..CovidDeaths_CSV
Where continent is not null 
order by 1,2


--Looking at Total Cases vs Total Deaths

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths_CSV
where location like '%states%'
and continent is not null 
order by 1,2 

--total cases vs population
---shows what percentage of population got covid 

Select location,date,total_cases,population_density,(total_deaths/population_density)*100 as PercentagePupulationInfected
from PortfolioProject..CovidDeaths_CSV
--where location like '%states%'
Where continent is not null 
order by 1,2 

--Looking at Countries with Highest Infection Rate compared to Population

Select location,population_density, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population_density)*100 as PercetagePopulationInfected  
from PortfolioProject..CovidDeaths_CSV
--where location like '%states%'
Where continent is not null 
Group by location, population_density
order by PercetagePopulationInfected  desc

--Showing countries with highest death count per population 

Select location, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths_CSV
--where location like '%states%'
Where continent is not null 
group by location
order by TotalDeathCount desc


--Showing continent with highest death count per population 

Select continent, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths_CSV
--where location like '%states%'
Where continent is not null 
group by continent
order by TotalDeathCount desc


--Global numbers by date  

Select date, SUM(new_cases), SUM(new_deaths), SUM( new_deaths) / SUM(New_cases) *100 as DeathPercentage
from PortfolioProject..CovidDeaths_CSV
--where location like '%states%'
where continent is not null 
group by date 
order by 1,2 

-- Global number 
Select SUM(new_cases), SUM(new_deaths), SUM( new_deaths) / SUM(New_cases) *100 as DeathPercentage
from PortfolioProject..CovidDeaths_CSV
--where location like '%states%'
where continent is not null 
--group by date 
order by 1,2 


--Total Population vs Vaccinations 

Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated,
(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths_CSV dea 
Join PortfolioProject..CovidVaccinations_CVS vac 
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 1,2,3

--CTE 

with PopVsVac (continent, location, date, population_density ,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths_CSV dea 
Join PortfolioProject..CovidVaccinations_CVS vac 
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)

Select* , (RollingPeopleVaccinated/population_density)*100 
FROM PopVsVac



--TEMP TABLE 

DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population_density numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric, 
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths_CSV dea 
Join PortfolioProject..CovidVaccinations_CVS vac 
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3 


Select* , (RollingPeopleVaccinated/Population_density)*100 
FROM #PercentPopulationVaccinated



--View to store data for later visualization 

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths_CSV dea 
Join PortfolioProject..CovidVaccinations_CVS vac 
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 



-- How many peeople got vaccinated vs deaths 

Select dea.continent, dea.location, dea.date, dea.population_density,dea.new_deaths,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
,SUM(dea.new_deaths) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopledeaths
From PortfolioProject..CovidDeaths_CSV dea 
Join PortfolioProject..CovidVaccinations_CVS vac 
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

---- How many peeople got vaccinated vs deaths in US

Select dea.continent, dea.location, dea.date, dea.population_density,dea.new_deaths,vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
,SUM(dea.new_deaths) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopledeaths
From PortfolioProject..CovidDeaths_CSV dea 
Join PortfolioProject..CovidVaccinations_CVS vac 
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and dea.location like '%states%'

