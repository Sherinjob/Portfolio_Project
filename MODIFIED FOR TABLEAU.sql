SELECT *
FROM [Portfolio Project]..CovidDeaths$
where continent is not NULL
ORDER BY 3,4

--SELECT *
--FROM [Portfolio Project]..CovidVaccinations$
--ORDER BY 3,4

--Selecting the required data that we needed from table
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM [Portfolio Project]..CovidDeaths$
where continent is not NULL
order by 1,2

--Checking total_deaths Vs total_cases
--The chances of death in your country if infected with covid

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS "% of death"
FROM [Portfolio Project]..CovidDeaths$
WHERE location='India' and continent is not NULL
order by '% of death' desc

--The scenario of Total cases Vs Population
--The % of population got covid

SELECT location,date,total_cases,population,(total_cases/population)*100 AS "% of cases"
FROM [Portfolio Project]..CovidDeaths$
where continent is not NULL
--WHERE location='India'
order by '% of cases' desc

--3
--Finding out maximum Percentage of total cases by Country wise in descending order
SELECT location,max(total_cases)as "Highestinfected",population,max(total_cases/population)*100 as "% of cases"
FROM [Portfolio Project]..CovidDeaths$
where continent is not NULL
GROUP BY location,population
order by '% of cases' desc

--Showing the death rate in % of population
--SELECT location,max(total_deaths)as "Highestdeath",population,max(total_deaths/population)*100 as "% of death"
--FROM [Portfolio Project]..CovidDeaths$
--GROUP BY location,population
--order by '% of death' desc

SELECT location,max(total_deaths)as "highestdeath count"
FROM [Portfolio Project]..CovidDeaths$
where continent is not NULL
GROUP BY location
order by "highestdeath count" desc

--Grouping highestdeathcount by continent

SELECT continent,sum(total_deaths)as "deathcount"
FROM [Portfolio Project]..CovidDeaths$
Where continent is not null
GROUP BY continent
order by "deathcount" desc

--1
--The world total number of cases
SELECT location,sum(new_cases)as "World cases",sum(new_deaths) as "World deaths",sum(new_deaths)/sum(new_cases)*100
as "Death percentage"
FROM [Portfolio Project]..CovidDeaths$
Where continent is null and location not in ('European Union','International')
--group by date
group by location
order by 1,2

--Total Death percentage across world

SELECT sum(new_cases)as "World new cases",sum(new_deaths) as "World new deaths",sum(new_deaths)/sum(new_cases)*100
as "Death percentage"
FROM [Portfolio Project]..CovidDeaths$
Where continent is not null
order by 1,2

--COVID VACCINATION

SELECT *
FROM [Portfolio Project]..CovidVaccinations$

--Joining the two tables

SELECT *
FROM [Portfolio Project]..CovidDeaths$ de
join [Portfolio Project]..CovidVaccinations$ va
on de.location=va.location and de.date=va.date

--Population Vs Vaccination

SELECT DE.CONTINENT, DE.LOCATION,DE.DATE,DE.POPULATION,VA.NEW_VACCINATIONS,
SUM(VA.NEW_VACCINATIONS) OVER (PARTITION BY DE.LOCATION ORDER BY DE.LOCATION,DE.DATE) AS TOTAL_VACCINATED
FROM [Portfolio Project]..CovidDeaths$ de
join [Portfolio Project]..CovidVaccinations$ va
on de.location=va.location and de.date=va.date
WHERE de.continent is not null
--4
--To make use of the new column,using the CTE

With PopVac(continent,location,date,population,new_vaccinations,total_vaccinated)
as
(
SELECT DE.CONTINENT, DE.LOCATION,DE.DATE,DE.POPULATION,VA.NEW_VACCINATIONS,
SUM(VA.NEW_VACCINATIONS) OVER (PARTITION BY DE.LOCATION ORDER BY DE.LOCATION,DE.DATE) AS TOTAL_VACCINATED
FROM [Portfolio Project]..CovidDeaths$ de
join [Portfolio Project]..CovidVaccinations$ va
on de.location=va.location and de.date=va.date
WHERE de.continent is not null
)

select location,date,(total_vaccinated/population)*100 as "%Vaccinated"
from PopVac
where location in('Canada','India') and date BETWEEN '2020-12-15 00:00:00.000' AND '2021-04-30 00:00:00.000'

--TEMP TABLE
DROP TABLE #Percentagepopulationvaccinated
CREATE TABLE  #Percentagepopulationvaccinated
(continent nvarchar(255),location nvarchar(255),date datetime,population numeric,
new_vaccinations numeric, total_vaccinated numeric)


INSERT INTO #Percentagepopulationvaccinated
SELECT DE.CONTINENT, DE.LOCATION,DE.DATE,DE.POPULATION,VA.NEW_VACCINATIONS,
SUM(VA.NEW_VACCINATIONS) OVER (PARTITION BY DE.LOCATION ORDER BY DE.LOCATION,DE.DATE) AS TOTAL_VACCINATED
FROM [Portfolio Project]..CovidDeaths$ de
join [Portfolio Project]..CovidVaccinations$ va
on de.location=va.location and de.date=va.date
WHERE de.continent is not null
order by 1,2

select *,(total_vaccinated/population)*100 as "%Vaccinated"
from #Percentagepopulationvaccinated


--TO CREATE VIEW

CREATE VIEW POpulationVaccinatedPercentage1 as
SELECT DE.CONTINENT, DE.LOCATION,DE.DATE,DE.POPULATION,VA.NEW_VACCINATIONS,
SUM(VA.NEW_VACCINATIONS) OVER (PARTITION BY DE.LOCATION ORDER BY DE.LOCATION,DE.DATE) AS TOTAL_VACCINATED
FROM [Portfolio Project]..CovidDeaths$ de
join [Portfolio Project]..CovidVaccinations$ va
on de.location=va.location and de.date=va.date
WHERE de.continent is not null

select *
from POpulationVaccinatedPercentage1
