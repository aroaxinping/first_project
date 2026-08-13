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


-- Aroa's addition: WHY are returning clients riskier than new ones? Testing
-- two more hypotheses before settling on an explanation.

-- Hypothesis 1: is it just about HOW MANY times someone applied before?
SELECT
    CASE
        WHEN app_count = 1 THEN '1 previous application'
        WHEN app_count BETWEEN 2 AND 3 THEN '2-3 previous applications'
        ELSE '4+ previous applications'
    END AS application_count_bucket,
    COUNT(*) AS total_clients,
    SUM(a.TARGET) AS defaults,
    ROUND(100 * AVG(a.TARGET), 2) AS default_rate_percent
FROM (
    SELECT SK_ID_CURR, COUNT(*) AS app_count
    FROM previous_application
    GROUP BY SK_ID_CURR
) AS counts
JOIN application AS a ON counts.SK_ID_CURR = a.SK_ID_CURR
GROUP BY application_count_bucket
ORDER BY default_rate_percent DESC;

-- Result: flat at ~8% regardless of count (8.38% / 7.84% / 8.33% for 1 /
-- 2-3 / 4+ applications) -- no dose-response pattern. Ruled out: it's not
-- about how much someone shops for credit.

-- Hypothesis 2: within the "clean" group (no Refused/Canceled), does an
-- unused offer (approved but never taken) carry extra risk?
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
            WHEN MAX(p.NAME_CONTRACT_STATUS = 'Unused offer') = 1 THEN 'Had Unused Offer'
            ELSE 'Approved Only'
        END AS previous_history
    FROM previous_application AS p
    JOIN application AS a ON p.SK_ID_CURR = a.SK_ID_CURR
    GROUP BY p.SK_ID_CURR, a.TARGET
) AS history
GROUP BY previous_history
ORDER BY default_rate_percent DESC;

-- Result: Had Unused Offer (7.10%) ~= Approved Only (7.13%) -- ruled out
-- too, an unused offer isn't a risk signal on its own.

-- Conclusion: the higher risk in returning clients is mostly driven by
-- refusal history (10.32%), not by application volume or unused offers.
-- But there's a residual we can't fully explain with this schema: even
-- "Approved Only" returning clients (a totally clean history) still
-- default at 7.13%, above the 5.96% baseline for brand-new clients.
-- That's not a specific red flag we can point to here -- more likely a
-- selection effect (people who seek credit more than once may just run
-- tighter finances in general). Amounts/dates aren't in this trimmed
-- table, so we can't dig further without going back to the raw CSV.

-- For a deeper look at WHY (using extra columns not in this trimmed
-- table -- amounts and dates), see q3_extended_repeat_client_drivers.sql