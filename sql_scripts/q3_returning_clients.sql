-- Q3 Is a returning client a better client than a new one?

-- Total clients in the current application
SELECT COUNT(*) AS total_clients
FROM application;

-- Total returning clients (clients with at least one previous application)
SELECT COUNT(DISTINCT SK_ID_CURR) AS returning_clients 
FROM previous_application;

-- Total new clients (clients with no previous applications)                         
SELECT COUNT(*) AS new_clients
FROM application
WHERE SK_ID_CURR NOT IN (
					SELECT DISTINCT SK_ID_CURR
					FROM previous_application);
                    
-- Compare default risk between new and returning clients
SELECT 
	CASE 
		WHEN a.SK_ID_CURR IN (SELECT DISTINCT SK_ID_CURR FROM previous_application) 
        THEN 'Returning'
        ELSE 'New'
	END AS client_type,
    COUNT(*) AS total_clients,
    SUM(TARGET) AS defaults, 								-- TARGET = 0 no default, TARGET = 1 default
    ROUND(100 * AVG(TARGET), 2) AS default_rate_percent		-- Percentage of clients in the group who defaulted
	FROM application AS a
    GROUP BY client_type;
    
-- KEY FINDING:

-- Returning clients have a higher default rate than new clients (8.19% vs 5.96%)
-- They have a difference of 2.23 percentage points.

-- Returning clients do not appear to be safer customers than new clients.
-- Having previous applications should not be considered an indicator of lower default risk.



-- Analize whether previous applications history is associated with current default risk among returning clients.
SELECT 
    previous_history,
    COUNT(*) AS total_clients,
    SUM(TARGET) AS defaults,
    ROUND(100 * AVG(TARGET), 2) AS default_rate_percent
FROM (
    SELECT 
        p.SK_ID_CURR,
        a.TARGET,
        CASE 
            WHEN MAX(p.NAME_CONTRACT_STATUS = 'Refused') = 1 THEN 'Had Refused'
            WHEN MAX(p.NAME_CONTRACT_STATUS = 'Canceled') = 1 THEN 'Had Canceled'
            ELSE 'No Refused or Canceled'
        END AS previous_history
    FROM previous_application AS p
    JOIN application AS a
        ON p.SK_ID_CURR = a.SK_ID_CURR
    GROUP BY p.SK_ID_CURR, a.TARGET
) AS history
GROUP BY previous_history
ORDER BY default_rate_percent DESC;


-- KEY FINDING

-- Returning clients with a previous Refused application have the highest current default rate (10.32%),
-- compared with 7.13% for clients with no Refused or Canceled applications and 6.94% for clients with a Canceled application.

-- This suggests that a history of refused applications is associated with higher current default risk among returning clients.