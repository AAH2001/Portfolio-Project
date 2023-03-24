select*
from portfolioproject.coviddeaths
where continent <> ''
order by 3,4;


-- Select Data that we are going to be starting with
select location, 
date ,
 total_cases ,
 new_cases,
 total_deaths, 
 population 
from portfolioproject.coviddeaths
where continent <> ''
order by 1 , 2;


-- discovered that the date coulum formated as text
-- lets convert it to a date format
update covidvaccinations
set date = STR_TO_DATE(date, '%m/%d/%Y') ;


-- looking at total cases vs total dethes
-- Shows likelihood of dying if you contract covid in your saudi
select location, date ,
 total_cases ,total_deaths,
 population ,
 (total_deaths /  total_cases) * 100 as deathes_rate
from portfolioproject.coviddeaths
where location like '%saudi%'
and continent <> ''
order by 1 , 2;


-- looking at total cases vs popaulation 
-- Shows what percentage of population infected with Covid
select location, 
date ,
new_cases,
 total_cases ,
 population , 
 (total_cases/population)*100 as infection_rate
from portfolioproject.coviddeaths
-- where location like '%saudi%'
where continent <> ''
order by 1 , 2;



-- looking at countries with highest infection rate 
select location , 
 population , 
max(total_cases) as  total_death_count  , 
 max((total_cases/population))*100 as infection_rate
from portfolioproject.coviddeaths
-- where location like '%saudi%'
where continent <> ''
group by location , population
order by 4 desc;

-- showing countries highest death count
select location, 
max(total_deaths) as total_death_count
from portfolioproject.coviddeaths
-- where location like '%saudi%'
where continent <> ''
group by location 
order by 2 desc;


-- lets breek things down to continent
select continent, 
max(total_deaths) as total_death_count
from portfolioproject.coviddeaths
-- where location like '%saudi%'
where continent <> ''
group by continent 
order by 2 desc;


-- lets breek things down globally
Select  date ,
SUM(new_cases) as total_cases,
 SUM(new_deaths ) as total_deaths, 
 SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From portfolioproject.coviddeaths
-- Where location like '%saudi%'
where continent <> ""
Group By date
order by 1 ;


-- loking at total total vaccinations vs population 

with vaccinations_CIT (location , date, new_vaccinations, population , vaccinations_rate )
as
(
select cd.location ,
 cd.date ,
 cv.new_vaccinations , 
 cd.population ,
 max(cv.new_vaccinations) OVER (partition by cv.location ) vaccinations_rate
from portfolioproject.covidvaccinations cd
join portfolioproject.covidvaccinations cv
on cd.date = cv.date and cd.location = cv.location

)
select *, (rolling_people_vaccinations/population)*100
from vaccinations_CIT
Where location like '%saudi%'

-- Temp Table

create TEMPORARY TABLE  vaccinations_temp
 as (select
cd.location ,
 cd.date ,
 cv.new_vaccinations , 
 cd.population ,
 max(cv.people_vaccinated) OVER (partition by cv.location ) 
from portfolioproject.covidvaccinations cd
join portfolioproject.covidvaccinations cv
on cd.date = cv.date and cd.location = cv.location
);
 



-- Creating View to store data for later visualizations

create view vaccinations_vs_people as
select cd.date , cd.location ,cd.population, cv.people_vaccinated , 
 max(((cv.people_vaccinated/cv.population))*100) over(partition by cv.location) as vaccinations_rate
from portfolioproject.covidvaccinations cd
join portfolioproject.covidvaccinations cv
on cd.date = cv.date and cd.location = cv.location 
where cd.continent <> ""
-- Where cd.location like '%saudi%'
order by cd.location , cd.date
