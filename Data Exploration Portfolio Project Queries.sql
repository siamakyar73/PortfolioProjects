--Select *
--From PortfolioProject..CovidDeaths
--where continent is not null
--order by 3,4


--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--select data that we are going to be using


select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2


-- Looking at total cases vs total deaths in United kingdom

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location = 'United kingdom'
order by 1,2

-- Looking at total cases vs population in United kingdom
--shows the likelihood of dying if you contract covid in United Kingdom
select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where location = 'United kingdom'
order by 1,2

-- Looking at countries with Highest Infection Rate compared to population

select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group By Location, population
order by 4 desc


select Location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group By Location, population, date
order by 5 desc
-- Looking at countries with Highest death counts

select Location, MAX(cast(total_deaths as int)) as TotalDeath
From PortfolioProject..CovidDeaths
where continent is not null
Group By Location, population
order by 2 desc

--Let's break things down by continent

select continent, MAX(cast(total_deaths as int)) as TotalDeath
From PortfolioProject..CovidDeaths
where continent is not null
Group By continent
order by 2 desc

--It shows some of the numbers wrong. The best way is to do the following:
select location, MAX(cast(total_deaths as int)) as TotalDeath
From PortfolioProject..CovidDeaths
where continent is null
Group By location
order by 2 desc

--Global numbers


select date, SUM(new_cases), SUM(CAST(new_deaths as int)), SUM(CAST(new_deaths as int))/SUM(new_cases) as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
Group By date
order by 1,2

select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 On dea.location = vac.location and dea.date = vac.date

 --looking at total vaccination vs population 

 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 On dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


--how to use "Partition by" >> it will sum the number of new vaccinations for each country and start the counter with each new country
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
 dea.date) as TotalPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 On dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--Use CTE

With PopvsVac (Continet, Location, date, population, new_vaccinations, TotalPeopleVaccinated)
as
(
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
 dea.date) as TotalPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 On dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)

Select *, (TotalPeopleVaccinated/population)*100
From PopvsVac

--Create table


Drop table if exists #PercentPopulationVaccinated
USE PortfolioProject
GO
Create table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	TotalPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as TotalPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 On dea.location = vac.location and dea.date = vac.date
--where dea.continent is not null

Select *,  (TotalPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Create view 
DROP VIEW [PercentPopulationVaccinated]
USE PortfolioProject
GO
Create View  PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as TotalPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
 On dea.location = vac.location and dea.date = vac.date
where dea.continent is not null