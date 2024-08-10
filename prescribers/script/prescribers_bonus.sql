-- 1. How many npi numbers appear in the prescriber table but not in the prescription table?
SELECT COUNT(*)
FROM
	(SELECT npi
	FROM prescriber
	EXCEPT
	SELECT npi
	FROM prescription);


-- 2.
--     a. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice.
SELECT generic_name, SUM(total_claim_count)
FROM drug
LEFT JOIN prescription
	USING (drug_name)
LEFT JOIN prescriber
	USING (npi)
WHERE specialty_description = 'Family Practice'
GROUP BY generic_name
ORDER BY SUM(total_claim_count) DESC
LIMIT 5;

--     b. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Cardiology.

SELECT generic_name, SUM(total_claim_count)
FROM drug
LEFT JOIN prescription
	USING (drug_name)
LEFT JOIN prescriber
	USING (npi)
WHERE specialty_description = 'Cardiology'
GROUP BY generic_name
ORDER BY SUM(total_claim_count) DESC
LIMIT 5;

--     c. Which drugs are in the top five prescribed by Family Practice prescribers and Cardiologists? Combine what you did for parts a and b into a single query to answer this question.

(SELECT generic_name
--SUM(total_claim_count) AS sum_claim_count
FROM drug
inner JOIN prescription
	USING (drug_name)
inner JOIN prescriber
	USING (npi)
WHERE specialty_description = 'Family Practice'
GROUP BY generic_name
ORDER BY SUM(total_claim_count) DESC
LIMIT 5
)
INTERSECT
(
SELECT 
	generic_name
-- 	SUM(total_claim_count) AS sum_claim_count
FROM drug
inner JOIN prescription
	USING (drug_name)
inner JOIN prescriber
	USING (npi)
WHERE specialty_description = 'Cardiology'
GROUP BY generic_name
ORDER BY SUM(total_claim_count) DESC
LIMIT 5);

--COMMENT OUT SUM(TOTAL_CLAIM_COUNT) BECAUSE IT'S COMPARING THE NAME + COUNT INSTEAD OF JUST THE NAME

-- 3. Your goal in this question is to generate a list of the top prescribers in each of the major metropolitan areas of Tennessee.
--     a. First, write a query that finds the top 5 prescribers in Nashville in terms of the total number of claims (total_claim_count) across all drugs. Report the npi, the total number of claims, and include a column showing the city.

SELECT
	p.npi,
	p.nppes_provider_city AS city,
	SUM(rx.total_claim_count) AS sum_of_count
FROM prescriber p
INNER JOIN prescription rx
 	USING(npi)
WHERE p.nppes_provider_city = 'NASHVILLE'
GROUP BY 
	p.npi,
	p.nppes_provider_city
ORDER BY sum_of_count DESC
LIMIT 5;

--     b. Now, report the same for Memphis.
SELECT
	p.npi,
	p.nppes_provider_city AS city,
	SUM(rx.total_claim_count) AS sum_of_count
FROM prescriber p
INNER JOIN prescription rx
 	USING(npi)
WHERE p.nppes_provider_city = 'MEMPHIS'
GROUP BY 
	p.npi,
	p.nppes_provider_city
ORDER BY sum_of_count DESC
LIMIT 5;
    
--     c. Combine your results from a and b, along with the results for Knoxville and Chattanooga.

(SELECT
	p.npi,
	p.nppes_provider_city AS city
FROM prescriber p
INNER JOIN prescription rx
 	USING(npi)
WHERE p.nppes_provider_city = 'NASHVILLE'
GROUP BY 
	p.npi,
	p.nppes_provider_city
ORDER BY sum_of_count DESC
LIMIT 5
)
UNION
(SELECT
	p.npi,
	p.nppes_provider_city AS city
FROM prescriber p
INNER JOIN prescription rx
 	USING(npi)
WHERE p.nppes_provider_city = 'MEMPHIS'
GROUP BY 
	p.npi,
	p.nppes_provider_city
ORDER BY sum_of_count DESC
LIMIT 5
)
UNION
(
SELECT
	p.npi,
	p.nppes_provider_city AS city
FROM prescriber p
INNER JOIN prescription rx
 	USING(npi)
WHERE p.nppes_provider_city = 'CHATTANOOGA'
GROUP BY 
	p.npi,
	p.nppes_provider_city
ORDER BY SUM(rx.total_claim_count) DESC
LIMIT 5
)
UNION
(
SELECT
	p.npi,
	p.nppes_provider_city AS city
FROM prescriber p
INNER JOIN prescription rx
 	USING(npi)
WHERE p.nppes_provider_city = 'KNOXVILLE'
GROUP BY 
	p.npi,
	p.nppes_provider_city
ORDER BY SUM(rx.total_claim_count) DESC
LIMIT 5
);

-- 4. Find all counties which had an above-average number of overdose deaths. Report the county name and number of overdose deaths.

SELECT county, ROUND(AVG(overdose_deaths),2) AS avg_od_deaths
FROM fips_county f
INNER JOIN overdose_deaths od
	ON CAST(f.fipscounty AS INT) = od.fipscounty
GROUP BY county
HAVING AVG(overdose_deaths) > 
	(SELECT AVG(overdose_deaths)
	FROM overdose_deaths od)
ORDER BY  avg_od_deaths DESC;

-- 5.
--     a. Write a query that finds the total population of Tennessee.

SELECT SUM(population)
FROM population;
    
--     b. Build off of the query that you wrote in part a to write a query that returns for each county that county's name, its population, and the percentage of the total population of Tennessee that is contained in that county.

SELECT 
	county, 
	population,
	ROUND((population/(SELECT SUM(population) FROM population)*100), 2) as percentage_of_state_pop
FROM fips_county
INNER JOIN population
	USING(fipscounty)
ORDER BY percentage_of_state_pop DESC

