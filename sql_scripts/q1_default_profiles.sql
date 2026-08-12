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
       ORDER BY default_rate_pct DESC
       LIMIT 15;
       
       -- Result: risk concentrates in Low-skill Laborers (17.16% default, the
       -- highest), unstable housing (Rented apartment 12.32%, With parents
       -- 11.70%), and manual occupations (Drivers, Waiters/barmen, Laborers, all
       -- above 10%). Lower secondary education also stands out (10.93%).
       -- Conclusion: it's not one single factor -- low-skill occupation, unstable
       -- housing, and low education all point the same direction, and are likely
       -- correlated with each other. These combined profiles are the clearest
       -- candidates for extra guarantees or stricter terms.