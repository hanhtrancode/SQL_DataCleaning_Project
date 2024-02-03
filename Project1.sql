--Select data that we are going to use

select location, date, total_cases, new_cases,total_deaths, population
from coviddeaths
order by 1,2

--Looking at total cases vs total deaths
--Shows likelihood of dying of you contract covid in your country

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths
where location like '%state%'
order by 1,2

--Looking at total cases vs population
--Shows percentage of population got Covid

select location, date, total_cases,population, (total_cases/population)*100 as InfectionRate
from coviddeaths
where location like '%state%'
order by 1,2

--Looking at Countries with highest Infection rate 
select location, population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPoplulationInfected
from  coviddeaths
group by location, population
order by 4 desc

--Showing countries with highest DEATH COUNT PER POPULATION

select location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
from coviddeaths
where continent is not null
group by location
order by 2 desc

--let's break things down by continent
--Showing continents with the highest deathcount
select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from coviddeaths
where continent is not null
group by continent
order by 2 desc

-- Global Numbers

select  
	date, 
	sum(new_cases)  as total_cases, --What if i use sum(total_cases)
	sum(cast(new_deaths as int)) as total_deaths,
	sum(cast(new_deaths as int ))/sum(new_cases)*100 as DeathPercentage
--Phần này của Alex the Analyst đã sai khi ti nhs new_cases và new_deaths  như là total_cases, total_deaths
from coviddeaths
where continent is not null
group by date
order by 1,2

--Phần chứng minh con số của Alex là sai
select date,  sum(total_cases), sum(new_cases) from coviddeaths
where continent is not null
group by  date
order by date

--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

	--nếu mà trong partition mình dùng order by date, thì phải đến cái ngày đó, nó mới cộng
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null and dea.location= 'Vietnam'
order by 1,2,3
	
--Use CTE

with PopvsVac as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

	--nếu mà trong partition mình dùng order by date, thì phải đến cái ngày đó, nó mới cộng
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null and dea.location= 'Vietnam'

)

select *,(RollingPeopleVaccinated/Population)*100
from PopvsVac


--Temp 
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from CovidDeaths dea
join CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null and dea.location= 'Vietnam'

select *,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--Creat view to store data for later visualizations

create view PercentPopulationVaccinated as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from CovidDeaths dea
join CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null and dea.location= 'Vietnam'

