Select *
From tutorial..deaths
order by 3,4

--Select *
--From tutorial..vaccinations
--order by 3,4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From tutorial..deaths
order by 1,2

--Looking at total cases vs total deaths
--Shows likelihood of dying if infected
Select location, date, total_cases, population, total_deaths, total_cases/population*100 as Perc
From tutorial..deaths
Where location = 'Argentina'
order by 1,2 

--Showing largest infection rate
Select location, population, MAX(total_cases) as Highest_inf_count, MAX((total_cases/population)*100) as Perc
From tutorial..deaths
Group by location, population
order by 4 Desc

--Showing highest death count
Select location, MAX(cast(total_deaths as int)) as Totaldeath
From tutorial..deaths
Group by location
order by 2 desc

--Remove empty cells from table
Select location, MAX(cast(total_deaths as int)) as Totaldeath
From tutorial..deaths
where continent != ' '
Group by location
order by 2 desc

--Same but for contients
Select continent, MAX(cast(total_deaths as int)) as Totaldeath
From tutorial..deaths
where continent != ' '
Group by continent
order by 2 desc


--REPLACE EMPTY VALUES WITH NULL, if i dont do this, the folllowing function has to divide by 0
UPDATE tutorial..deaths 
SET new_cases = NULL 
WHERE new_cases = 0




--GLOBAL NUMBERS
--SUM(cast(new_deaths as int)) 
Select date, sum(new_cases), SUM(cast(new_deaths as int)), (SUM(cast(new_deaths as int))/sum(new_cases))*100 as Perc
From tutorial..deaths
Where location = 'Argentina'
and continent != ' ' 
Group by date
order by 1,2 

--Vaccines vs Deaths | joining
Select *
From tutorial..vaccinations vac
Join tutorial..deaths dea
	on dea.location=vac.location
	and dea.date=vac.date

--Fix numbers
UPDATE tutorial..vaccinations
set new_vaccinations= cast(replace(new_vaccinations, '.0','') as integer)

select cast(replace(new_vaccinations, '.0','') as integer)
From tutorial..vaccinations


select new_vaccinations
From tutorial..vaccinations


--As bigint because as int is too big to handle + --use cte
With pop_vs_vac (Continent, location, date, population, new_vaccinations, roll_people_vac) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as roll_people_vac
From tutorial..deaths dea
Join tutorial..vaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent != ' '
)
Select *, (roll_people_vac/population)*1000 as perc_vacunated --population has an extra 0 for some reason
from pop_vs_vac


DROP Table if exists #percentage_pop_vac
Create table #percentage_pop_vac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
roll_people_vac numeric
)

Insert into #percentage_pop_vac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as roll_people_vac
From tutorial..deaths dea
Join tutorial..vaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
--where dea.continent != ' '

Select *, (roll_people_vac/population)*1000 as perc_vacunated --population has an extra 0 for some reason
from #percentage_pop_vac

--Create view 
Create view percentage_pop_vac as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as roll_people_vac
From tutorial..deaths dea
Join tutorial..vaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent != ' '
--order by 2,3

--grant permissions to the view

Grant insert on [dbo].[percentage_pop_vac] to dbo

Grant insert on [dbo].[percentage_pop_vac] to db_owner

--whats my user name
SELECT CURRENT_USER;  
GO  
--My service name
SELECT servicename, service_account
FROM sys.dm_server_services
GO

--My permissions
SELECT * 
FROM fn_my_permissions (NULL, 'DATABASE');
GO

--Get users list
SELECT * FROM sysusers

--Somehow with all of this it got fixed


Select *
From percentage_pop_vac