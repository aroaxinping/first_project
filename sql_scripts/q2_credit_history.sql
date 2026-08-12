USE home_credit;

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
FINDINGS – RESEARCH QUESTION 2
RESEARCH QUESTION :How does prior credit history relate to default risk?

Applicants without bureau credit history had a default rate of 10.13%,
compared with 7.73% for applicants with bureau credit history.

Conclusion:
Applicants without bureau credit history were more likely to experience
repayment difficulties, with a difference of 2.40 percentage points.

This result shows an association and does not prove causation.
*GROUP BY credit_history_status;

/*
FINDINGS – RESEARCH QUESTION 2

Applicants without bureau credit history had a default rate of 10.13%,
compared with 7.73% for applicants with bureau credit history.

Conclusion:
Applicants without bureau credit history were more likely to experience
repayment difficulties, with a difference of 2.40 percentage points.

This result shows an association and does not prove causation.
*/