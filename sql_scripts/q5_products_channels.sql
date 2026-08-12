-- Q5 Which products and channels concentrate the risk?

-- Compare current default risk by previous product type
SELECT
    p.NAME_PORTFOLIO AS product_type,
    COUNT(*) AS total_clients,
    SUM(a.TARGET) AS defaults,
    ROUND(100 * AVG(a.TARGET), 2) AS default_rate_percent
FROM (
    SELECT DISTINCT
        SK_ID_CURR,
        NAME_PORTFOLIO
    FROM previous_application
) AS p
JOIN application AS a
    ON p.SK_ID_CURR = a.SK_ID_CURR
GROUP BY p.NAME_PORTFOLIO
ORDER BY default_rate_percent DESC;

-- Cards has the highest default rate among the product categories (9.55%). 
-- Cars has a very small number of clients (297), so its rate should be interpreted with caution.



-- Compare current default risk by previous application channel
SELECT
    p.CHANNEL_TYPE AS channel_type,
    COUNT(*) AS total_clients,
    SUM(a.TARGET) AS defaults,
    ROUND(100 * AVG(a.TARGET), 2) AS default_rate_percent
FROM (
    SELECT DISTINCT
        SK_ID_CURR,
        CHANNEL_TYPE
    FROM previous_application
) AS p
JOIN application AS a
    ON p.SK_ID_CURR = a.SK_ID_CURR
GROUP BY p.CHANNEL_TYPE
ORDER BY default_rate_percent DESC;

-- AP + (Cash loan) is the channel associated with the highest current default rate (11.28%).
-- The result suggests that previous applications through this channel are associated with a higher current default risk.


-- Compare current default risk by previous yield group
SELECT
    p.NAME_YIELD_GROUP AS yield_group,
    COUNT(*) AS total_clients,
    SUM(a.TARGET) AS defaults,
    ROUND(100 * AVG(a.TARGET), 2) AS default_rate_percent
FROM (
    SELECT DISTINCT
        SK_ID_CURR,
        NAME_YIELD_GROUP
    FROM previous_application
) AS p
JOIN application AS a
    ON p.SK_ID_CURR = a.SK_ID_CURR
GROUP BY p.NAME_YIELD_GROUP
ORDER BY default_rate_percent DESC;

-- The high yield group has the highest default rate (9.01%), followed by the XNA group (8.78%).
-- Default rates decrease as the yield group moves from high to low.
-- This suggests that previous applications with higher yield groups are associated with higher current default risk.


-- Compare current default risk by previous seller industry
SELECT
    p.NAME_SELLER_INDUSTRY AS seller_industry,
    COUNT(*) AS total_clients,
    SUM(a.TARGET) AS defaults,
    ROUND(100 * AVG(a.TARGET), 2) AS default_rate_percent
FROM (
    SELECT DISTINCT
        SK_ID_CURR,
        NAME_SELLER_INDUSTRY
    FROM previous_application
) AS p
JOIN application AS a
    ON p.SK_ID_CURR = a.SK_ID_CURR
GROUP BY p.NAME_SELLER_INDUSTRY
ORDER BY default_rate_percent DESC;

-- Auto technology has the highest default rate among seller industries (10.30%), although it represents a relatively small number of clients (3,553).
-- Connectivity has the second-highest default rate (8.87%) and represents a much larger group (135,523 clients).
-- The results suggest that previous applications associated with certain seller industries may be linked to higher current default risk.




SELECT 
	p.NAME_PORTFOLIO AS product_type,
    p.CHANNEL_TYPE AS channel_type,
    COUNT(*) AS total_clients,
    SUM(a.TARGET) AS defaults,
    ROUND(100 * AVG(a.TARGET), 2) AS default_rate_percent
FROM (
	SELECT DISTINCT
        SK_ID_CURR,
        NAME_PORTFOLIO,
        CHANNEL_TYPE
    FROM previous_application
) AS p
JOIN application AS a
ON p.SK_ID_CURR = a.SK_ID_CURR
GROUP BY p.NAME_PORTFOLIO, p.CHANNEL_TYPE
HAVING COUNT(*) >= 1000 					-- to focus on combinations with enough clients and avoid unreliable small groups.
ORDER BY default_rate_percent DESC;






