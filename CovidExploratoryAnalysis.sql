--Initial Data Selection For Analysis

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM CovidDeaths
Where continent is not null
ORDER BY 1,2

--Total Cases Vs Total Deaths

SELECT location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 AS TotalDeaths_Percentage_Per_TotalCases 
FROM CovidDeaths
Where continent is not null
ORDER BY 1,2



--Total Cases Vs Total Deaths in Pakistan
--Likelihood of dying if you contract Covid

SELECT location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 AS TotalDeaths_Percentage_Per_TotalCases 
FROM CovidDeaths
WHERE (location = 'Pakistan' AND continent is not null)
ORDER BY 1,2



--Total Cases Vs Population

SELECT location, date, population, total_cases, total_deaths, (total_cases/population)*100 AS Percent_Population_Infected 
FROM CovidDeaths
--WHERE (location = 'Pakistan' AND continent is not null)
ORDER BY 1,2



--Country with Highest Infection Rate Compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) AS Percent_Population_Infected 
FROM CovidDeaths
--WHERE (location = 'Pakistan' AND continent is not null)
GROUP BY location, population
ORDER BY Percent_Population_Infected desc



--Highest Death Count Per Country
SELECT location, population, MAX(CAST(total_deaths as bigint)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null	
GROUP BY location, population
ORDER BY TotalDeathCount desc



--Highest Deaths Count Per Continent
SELECT continent, MAX(CAST(total_deaths as bigint)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null	
GROUP BY continent
ORDER BY TotalDeathCount desc



--GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS Total_New_Cases_Each_Day, SUM(CAST(new_deaths AS bigint)) AS Total_New_Deaths_Each_Day, SUM(CAST(new_deaths AS bigint))/SUM(new_cases) AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


--GLOBAL NUMBERS (Total Deaths & Cases Until Today)
SELECT SUM(new_cases) AS Total_New_Cases, SUM(CAST(new_deaths AS bigint)) AS Total_New_Deaths, SUM(CAST(new_deaths AS bigint))/SUM(new_cases) AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null



--Total Populations Vs Vacciantions
SELECT dea.continent, dea.location,	dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) AS Total_Commulative_Vaccinations
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
Order By 2,3



--CTE to Calculate Percentage Against Commulative Vaccinations

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, Total_Commulative_Vaccinations)
AS
(
SELECT dea.continent, dea.location,	dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) AS Total_Commulative_Vaccinations
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--Order By 2, 3
)

SELECT *, (Total_Commulative_Vaccinations/Population)*100
FROM PopVsVac




--Temp Table to Calculate Percentage Against Commulative Vaccinations

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
Total_Commulative_Vaccinations numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location,	dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) AS Total_Commulative_Vaccinations
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--Order By 2, 3

SELECT *, (Total_Commulative_Vaccinations/Population)*100
FROM #PercentPopulationVaccinated



--Creatign a View for Visualization

Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location,	dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) AS Total_Commulative_Vaccinations
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--Order By 2, 3

SELECT *, (Total_Commulative_Vaccinations/Population)*100
FROM #PercentPopulationVaccinated