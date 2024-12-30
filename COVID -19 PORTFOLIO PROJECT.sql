
SELECT * 
FROM COVID.DBO.CovidDeaths
where continent is not null
ORDER BY 3,4


--SELECT * 
--FROM COVID.DBO.CovidVaccinations
--ORDER BY 3,4

----select data for usage 

--select location,date, total_cases, new_cases,total_deaths,population 
--from COVID.DBO.CovidDeaths
--order by total_Deaths asc 

----sorting out total cases vs total death 

--select location,date, total_cases,total_deaths, (total_cases/total_deaths)*100 as PercentageOfPopulationInfected
--from COVID.DBO.CovidDeaths
--where location like '%state%'
--order by 1,2


--sorting total cases vs population 
--this will show us what percentage got covid 

select location,date, (total_cases),population, (total_cases/population)*100 as PercentageOfPopulationInfected
from COVID.dbo.CovidDeaths
order by 1,2

--country with the highest covidcases 

select location,population, max(total_cases)as maximunCases, max(total_cases/population)*100 as PercentageOfPopulationInfected
from COVID.DBO.CovidDeaths
group by  location,population
order by PercentageOfPopulationInfected desc


--showing country with highest death per population 


select location, max(cast(total_deaths as int))as deathRate
from COVID.DBO.CovidDeaths
group by  location
order by deathRate desc


--BREAKING DOWN BY CONTINENT

select continent, max(CAST (total_deaths AS INT ))as deathRate
from COVID.DBO.CovidDeaths
group by  continent
order by deathRate desc

--total cases, new cases, total death, death percentage 

select  SUM(total_cases) AS sumtotal_cases,SUM(new_cases)as sumnew_cases ,SUM(CAST(total_deaths AS INT))as total_deaths,SUM(CAST(total_deaths AS INT))
/  SUM(total_cases)*100 as DeathPercentage 
from COVID.DBO.CovidDeaths
--order by total_Deaths asc

--LOOKING AT TOTAL POPULATION VS VACCINATION 

select deaths.continent, deaths.LOCATION, DEATHS.DATE, deaths.population, VACC.new_vaccinations
,sum (convert (int,VACC.new_vaccinations )) over (partition by deaths.LOCATION)as rollingPeopleVaccinated 
from COVID.DBO.CovidDeaths deaths
inner join COVID.dbo.CovidVaccinations vacc
on deaths.date = vacc.date
and deaths.location = vacc.location
WHERE deaths.continent IS NOT NULL and new_vaccinations is not null
order by 1,2

with cte_emmidynamics as
(select deaths.continent, deaths.LOCATION, DEATHS.DATE, deaths.population, VACC.new_vaccinations
,sum (convert (int,VACC.new_vaccinations )) over (partition by deaths.LOCATION)as rollingPeopleVaccinated 
from COVID.DBO.CovidDeaths deaths
inner join COVID.dbo.CovidVaccinations vacc
on deaths.date = vacc.date
and deaths.location = vacc.location
WHERE deaths.continent IS NOT NULL and new_vaccinations is not null
--order by 1,2
)


select *
from cte_emmidynamics

 select continent,date,location
 from CovidVaccinations 
 where date in (
 select date
 from CovidDeaths
 where new_cases > 45)


 --#temp table 


 drop table if exists #covid 
  create table #covid 
  (continent varchar(300),
  date nvarchar (300),
  location varchar (300)
  )

  insert into #covid
 select continent,date,location
 from CovidVaccinations 
 where date in (
 select date
 from CovidDeaths
 where location is null)

 select *
 from #covid

 --veiw to store data for latter visualisations 
 
 create view rollingPeopleVaccinated as 
select deaths.continent, deaths.LOCATION, DEATHS.DATE, deaths.population, VACC.new_vaccinations
,sum (convert (int,VACC.new_vaccinations )) over (partition by deaths.LOCATION)as rollingPeopleVaccinated 
from COVID.DBO.CovidDeaths deaths
inner join COVID.dbo.CovidVaccinations vacc
on deaths.date = vacc.date
and deaths.location = vacc.location
WHERE deaths.continent IS NOT NULL and new_vaccinations is not null
--order by 1,2

