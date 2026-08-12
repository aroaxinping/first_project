USE home_credit;

-- Q2: How does prior credit history relate to default risk?

SELECT
    CASE
        WHEN b.SK_ID_CURR IS NULL THEN 'No bureau credit history'
        ELSE 'Has bureau credit history'
    END AS credit_history_status,
    COUNT(*) AS total_applicants,
    SUM(a.TARGET) AS applicants_with_repayment_difficulties,
    ROUND(AVG(a.TARGET) * 100, 2) AS default_rate_percent
FROM application AS a
LEFT JOIN (
    SELECT DISTINCT SK_ID_CURR
    FROM bureau
) AS b
    ON a.SK_ID_CURR = b.SK_ID_CURR
GROUP BY credit_history_status;

/*
FINDINGS

Applicants without bureau credit history had a default rate of 10.13%,
compared with 7.73% for applicants with bureau credit history.

Conclusion:
Applicants without bureau credit history were more likely to experience
repayment difficulties, with a difference of 2.40 percentage points.

This result shows an association and does not prove causation.
*/

-- Aroa's addition: "has bureau history" lumps together clean and troubled
-- records into one bucket. Splitting "has history" by whether any of it
-- was overdue gives a finer-grained, 3-tier answer.
SELECT
    CASE
        WHEN b.SK_ID_CURR IS NULL THEN 'No bureau history'
        WHEN b.troubled = 1 THEN 'Troubled history'
        ELSE 'Clean history'
    END AS bureau_history_status,
    COUNT(*) AS total_applicants,
    SUM(a.TARGET) AS defaults,
    ROUND(AVG(a.TARGET) * 100, 2) AS default_rate_percent
FROM application AS a
LEFT JOIN (
    SELECT SK_ID_CURR, MAX(CREDIT_DAY_OVERDUE > 0 OR AMT_CREDIT_SUM_OVERDUE > 0) AS troubled
    FROM bureau
    GROUP BY SK_ID_CURR
) AS b ON a.SK_ID_CURR = b.SK_ID_CURR
GROUP BY bureau_history_status
ORDER BY default_rate_percent DESC;

/*
FINDING

Splitting bureau history by overdue status reveals a clear 3-tier
gradient: Troubled history 15.79%, No bureau history 10.13%, Clean
history 7.62%.

Conclusion:
Bureau history isn't just present-or-absent -- having a troubled history
(any overdue days or overdue amount) more than doubles the default rate
compared to a clean one. Having no history at all sits in between,
closer to troubled than clean. Worth pricing risk in three tiers, not two.
*/
