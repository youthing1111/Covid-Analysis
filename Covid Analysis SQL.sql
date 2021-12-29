create table covid1(
    SNo VARCHAR(100),
    ObservationDate date,
    State VARCHAR(100),
    Country VARCHAR(100),
    Last_Update VARCHAR(100),
    Confirmed VARCHAR(100),
    Deaths VARCHAR(100),
    Recovered VARCHAR(100)
);

bulk insert covid1 from  'E:\covid_19_data.csv'
with(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);

select format ([ObservationDate],'yyyy-MM-dd') as 'ObservationDate'
from covid1;

select * from covid1
order by ObservationDate ASC,Country ;

ALTER table covid1 alter COLUMN Confirmed FLOAT;
ALTER table covid1 alter COLUMN Deaths NUMERIC(10,2);
ALTER table covid1 alter COLUMN Recovered FLOAT;

select ObservationDate,State,Country,Confirmed,Deaths, (Deaths/Confirmed)*100 as DealthPercentage 
from covid1
order by Country,ObservationDate;

update covid1
set Country = 'China'
where Country = 'Mainland China';

update covid1
set Country = 'United States'
where Country = 'US';

update covid1
set Country = 'United Kingdom'
where Country = 'UK';

create table Population1(
    Country VARCHAR(100),
    Population int
);

bulk insert Population1 from  'E:\country_population_2020.csv'
with(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);

select * from Population1
select ObservationDate, Country, sum(Confirmed) as ConfirmedPerDay, sum(Deaths) as DealthPerDay, sum(Recovered) as RecoverdPerDay
into Covid19
from covid1
group by ObservationDate, Country
order by ObservationDate;

select Country, max(ConfirmedPerDay) as TotalConfirmed, max(DealthPerDay) as TotalDealth, max(RecoverdPerDay) as TotalRecovered
into Covid20
from Covid19
group by country
order by TotalConfirmed DESC;

select Covid20.Country, Covid20.TotalConfirmed, Covid20.TotalDealth,Covid20.TotalRecovered, Population1.Population
into CovidFinal
from Covid20
left join Population1 on Covid20.Country = Population1.Country;

-- Total Confirmed vs Total Death
-- Show likelihood of dying if you infected with Covid in your country

select Country, TotalConfirmed, TotalDealth, (TotalDealth/TotalConfirmed)*100 as DealthPercentage 
from CovidFinal
order by TotalConfirmed DESC;

-- TotalConfirmed vs Population
-- Show percentage of population infected with Covid

select Country, Population, TotalConfirmed, (TotalConfirmed/Population)*100 as PercentagePopulationInfected
from CovidFinal
order by Population desc;

--TotalDeath vs Population
--Show the percentage of death by Covid per population

select Country, TotalDealth, Population, (TotalDealth/Population)*100 as DeathPercentageByPopulation
from CovidFinal
order by DeathPercentageByPopulation desc;

--TotalConfirmed vs TotalRecovered

select Country, TotalConfirmed, TotalRecovered, (TotalRecovered/TotalConfirmed) as RecoveredPercentage
from CovidFinal
order by TotalConfirmed desc;

--GlobalNumber

select sum(TotalConfirmed) as GlobalConfirmed, sum(TotalDealth) as GlobalDeath, sum(TotalRecovered) as GlobalRecovered
from CovidFinal;