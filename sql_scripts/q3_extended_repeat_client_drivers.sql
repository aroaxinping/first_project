-- Author: Aroa
-- Extended follow-up to Q3 (see q3_returning_clients.sql)

-- Why: q3_returning_clients.sql ruled out application count and unused
-- offers as explanations for why even "clean history" returning clients
-- (7.13% default) are still riskier than brand-new clients (5.96%). That
-- ruled out what's available in the trimmed previous_application table.
-- This file goes back to the raw CSV for the columns Carla trimmed out
-- (AMT_CREDIT, AMT_ANNUITY, DAYS_DECISION), loaded into a separate table,
-- previous_application_extended, to test two more hypotheses.

USE home_credit;

-- Restrict to the same "clean history" cohort as q3_returning_clients.sql:
-- returning clients whose previous applications were never Refused or
-- Canceled -- just Approved.

-- Hypothesis 3: does the TOTAL AMOUNT of previously approved credit matter?
SELECT
    CASE
        WHEN total_credit < 88219 THEN 'Q1 lowest prior credit'
        WHEN total_credit < 180000 THEN 'Q2'
        WHEN total_credit < 414703 THEN 'Q3'
        ELSE 'Q4 highest prior credit'
    END AS credit_bucket,
    COUNT(*) AS total_clients,
    ROUND(100 * AVG(a.TARGET), 2) AS default_rate_percent
FROM (
    SELECT SK_ID_CURR, SUM(AMT_CREDIT) AS total_credit
    FROM previous_application_extended
    WHERE NAME_CONTRACT_STATUS = 'Approved'
      AND SK_ID_CURR NOT IN (
          SELECT SK_ID_CURR FROM previous_application
          WHERE NAME_CONTRACT_STATUS IN ('Refused', 'Canceled')
      )
    GROUP BY SK_ID_CURR
) t
JOIN application a ON t.SK_ID_CURR = a.SK_ID_CURR
GROUP BY credit_bucket
ORDER BY default_rate_percent DESC;

-- Result: clear gradient, but the OPPOSITE of a naive "more debt = more
-- risk" guess. Lowest prior credit quartile: 9.58% default. Highest: 5.53%.
-- Interpretation: a large approved credit history is a trust signal, not
-- a burden -- Home Credit doesn't approve big amounts for clients who
-- already look risky, so a large total is itself evidence of
-- creditworthiness.

-- Hypothesis 4: does HOW RECENTLY the last decision happened matter?
SELECT
    CASE
        WHEN avg_days >= -529.5 THEN 'Q4 most recent'
        WHEN avg_days >= -944.8 THEN 'Q3'
        WHEN avg_days >= -1478.9 THEN 'Q2'
        ELSE 'Q1 oldest'
    END AS recency_bucket,
    COUNT(*) AS total_clients,
    ROUND(100 * AVG(a.TARGET), 2) AS default_rate_percent
FROM (
    SELECT SK_ID_CURR, AVG(DAYS_DECISION) AS avg_days
    FROM previous_application_extended
    WHERE NAME_CONTRACT_STATUS = 'Approved'
      AND SK_ID_CURR NOT IN (
          SELECT SK_ID_CURR FROM previous_application
          WHERE NAME_CONTRACT_STATUS IN ('Refused', 'Canceled')
      )
    GROUP BY SK_ID_CURR
) t
JOIN application a ON t.SK_ID_CURR = a.SK_ID_CURR
GROUP BY recency_bucket
ORDER BY default_rate_percent DESC;

-- Result: another clear gradient. Most recent previous decision: 8.85%
-- default -- the riskiest bucket in this whole file. Oldest previous
-- decision: 6.29%.
-- Interpretation: needing credit again very recently is the risk signal,
-- not a long-dormant credit relationship. A client whose last approved
-- loan was years ago has an established, stable track record; one who
-- was just approved again right before this application may be cycling
-- through credit out of financial pressure.

-- CONCLUSION (updates q3_returning_clients.sql's open question):
-- The residual risk in "clean history" returning clients is not a
-- single unexplained factor -- it's actually two real, opposing signals
-- that the trimmed table couldn't see:
--   - Large total prior credit approved -> LOWER risk (a trust signal).
--   - A very recent previous decision -> HIGHER risk (a pressure signal).
-- The 7.13% average in q3_returning_clients.sql was blending clients
-- who look safer than new clients (older relationship, large credit)
-- with clients who look riskier (recent activity, small credit) into one
-- number. Recommendation: score returning clients on recency and prior
-- credit size specifically, rather than treating "has a clean history"
-- as one uniform risk category.
