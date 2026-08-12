-- Author: Aroa
-- Q1: Which applicant profiles concentrate the risk of default?

SELECT 'NAME_EDUCATION_TYPE' AS profile_dimension, NAME_EDUCATION_TYPE AS profile_value,
       COUNT(*) AS applicants, ROUND(AVG(TARGET)*100, 2) AS default_rate_pct
FROM application GROUP BY NAME_EDUCATION_TYPE HAVING COUNT(*) >= 100
UNION ALL
SELECT 'NAME_INCOME_TYPE', NAME_INCOME_TYPE, COUNT(*), ROUND(AVG(TARGET)*100, 2)
FROM application GROUP BY NAME_INCOME_TYPE HAVING COUNT(*) >= 100
UNION ALL
SELECT 'NAME_HOUSING_TYPE', NAME_HOUSING_TYPE, COUNT(*), ROUND(AVG(TARGET)*100, 2)
FROM application GROUP BY NAME_HOUSING_TYPE HAVING COUNT(*) >= 100
UNION ALL
SELECT 'OCCUPATION_TYPE', OCCUPATION_TYPE, COUNT(*), ROUND(AVG(TARGET)*100, 2)
FROM application GROUP BY OCCUPATION_TYPE HAVING COUNT(*) >= 100
UNION ALL
SELECT 'CODE_GENDER', CODE_GENDER, COUNT(*), ROUND(AVG(TARGET)*100, 2)
FROM application GROUP BY CODE_GENDER HAVING COUNT(*) >= 100
UNION ALL
SELECT 'OVERALL', 'All applicants', COUNT(*), ROUND(AVG(TARGET)*100, 2)
FROM application
ORDER BY default_rate_pct DESC;

-- Result: risk concentrates in low-skill jobs, unstable housing, and low
-- education -- all clearly above the 8.07% overall baseline (top: Low-skill
-- Laborers 17.16%, Rented apartment 12.32%, Lower secondary 10.93%).
-- Conclusion: same story from three different angles, probably correlated
-- with each other. These combined profiles are the ones worth extra
-- guarantees or stricter terms.
