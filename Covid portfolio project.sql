
select * 
from CovidDeaths

--alter table CovidDeaths alter column date datetime

-- Looking at total Cases vs Total Deaths

-- i) shows likelihood of dying if you contract Covid in your country 

select location, date, total_cases, total_deaths, 
(CAST (total_deaths as float)/NULLIF(total_cases,0))*100 as Death_Percentage
from CovidDeaths
where location ='India'
order by 1,2


-- ii) shows likelihood of dying if you contract Covid in USA

select location, date, total_cases, total_deaths, (CAST (total_deaths as float)/NULLIF(total_cases,0))*100 as Death_Percentage
from CovidDeaths
where location like '%states%'
order by 1,2


-- Looking at the local cases vs population

select location, date, total_cases, population, (CAST(total_cases as float)/NULLIF(population,0))* 100 as PercentPopulation_infected
from CovidDeaths
--where location like 'INDIa'
order by 1,2

-- Looking at Countries with Highest Infection Rate Compared to Population

select * into #HighestInfectionRate
from
(select location, population, Max(total_cases) as highestInfectionCount,
Max((CAST(total_cases as float))/NULLIF(population,0))* 100 as PercentPopulationinfected,
DENSE_RANK() over (order by (Max((CAST(total_cases as float))/NULLIF(population,0))* 100) desc) as InfectionRateRank
from CovidDeaths
--where location like 'INDIA'
group by location, population) as T1

-- To check the HighestInfectionRate_Rank of a particular country

select location, InfectionRateRank 
from #HighestInfectionRate
where location = 'India'


--  Showing Countries with the Highest death Count per Population

select location, Max(total_deaths) as TotalDeathCount
from CovidDeaths
where location not in 
('Europe', 'Africa','North America','South America', 'Australia','Antartica','Asia', 'European Union', 'World')
group by location
order by TotalDeathCount desc;

--Showing Continents with the Highest death Count per Population

select continent, Max(total_deaths) as HighestDeathCount
from CovidDeaths
where continent in ('Europe', 'Africa','North America','South America', 'Australia','Antartica','Asia')
group by continent
order by HighestDeathCount desc;


-- Global numbers

-- Total deaths globally w.r.t. date

select sum(new_cases)as total_cases,sum(new_deaths) as total_deaths, 
(sum(new_deaths)/NULLIF(sum(new_cases),0)) *100 as Death_Percentage
from CovidDeaths
where location not in ('europe', 'africa','Asia',
'North America','South America','Australia', 'World','european union')
order by 1,2


select date, sum(new_cases)as total_cases,sum(new_deaths) as total_deaths, 
(sum(new_deaths)/NULLIF(sum(new_cases),0)) *100 as Death_Percentage
from CovidDeaths
where location not in ('europe', 'africa','Asia',
'North America','South America','Australia', 'World','european union')
group by date
order by 1,2

-- Total population vs vaccinations

select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
Sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.date= vac.date
and dea.location= vac.location
where dea.location not in ('europe', 'africa','Asia',
'North America','South America','Australia', 'World','european union')
order by 2,3

--Alter table CovidVaccinations alter column new_vaccinations int

-- USE CTE

with PopvsVAC as
(
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
Sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.date= vac.date
and dea.location= vac.location
where dea.location not in ('europe', 'africa','Asia',
'North America','South America','Australia', 'World','european union')
)

select *, Convert(float,RollingPeopleVaccinated)/Nullif(population,0) * 100 as  PercentagePeopleVaccinatedpercountry
from PopvsVAC
order by 2,3


-- TEMP TABLE

Drop Table if exists #PercentpopulationVaccinated
create table #PercentpopulationVaccinated
( continent varchar(255),
  location varchar(255), 
  date datetime, 
  population numeric,
  New_vaccinations numeric,
  RollingPeopleVaccinated numeric
)

Insert into #PercentpopulationVaccinated
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
Sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.date= vac.date
and dea.location= vac.location
where dea.location not in ('europe', 'africa','Asia',
'North America','South America','Australia', 'World','european union')

select *, Convert(float,RollingPeopleVaccinated)/Nullif(population,0) * 100 as  PercentagePeopleVaccinatedpercountry
from #PercentpopulationVaccinated
order by 2,3


-- Creating view to store data for later visualizations 

Create view RollingPopulationVaccinated as
(select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
Sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.date= vac.date
and dea.location= vac.location
where dea.location not in ('europe', 'africa','Asia',
'North America','South America','Australia', 'World','european union'))

Create view PercentPopulationVaccinated as
with PopvsVAC as
(
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
Sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.date= vac.date
and dea.location= vac.location
where dea.location not in ('europe', 'africa','Asia',
'North America','South America','Australia', 'World','european union')
)


select *, Convert(float,RollingPeopleVaccinated)/Nullif(population,0) * 100 as  PercentagePeopleVaccinatedpercountry
from PopvsVAC
--order by 2,3


Select * 
from PercentPopulationVaccinated
