-- Author: Aroa
-- Q4: Were past rejections the right call?

SELECT
    CASE WHEN pa.SK_ID_CURR IS NOT NULL THEN 'Previously Refused' ELSE 'Never Refused' END AS rejection_history,
    COUNT(DISTINCT a.SK_ID_CURR) AS applicants,
    ROUND(AVG(a.TARGET) * 100, 2) AS default_rate_pct
FROM application a
LEFT JOIN (
    SELECT DISTINCT SK_ID_CURR FROM previous_application WHERE NAME_CONTRACT_STATUS = 'Refused'
) pa ON a.SK_ID_CURR = pa.SK_ID_CURR
GROUP BY rejection_history;

-- Result: 6.98% default if never refused, 10.32% if previously refused.
-- Conclusion: rejections were the right call -- a past refusal still
-- predicts more risk today, even on a loan that did get approved.

-- Extra: does risk scale with number of past refusals, not just yes/no?
SELECT
    CASE
        WHEN r.refusal_count IS NULL THEN 'Never Refused'
        WHEN r.refusal_count = 1 THEN 'Refused Once'
        ELSE 'Refused 2+ Times'
    END AS rejection_history,
    COUNT(*) AS applicants,
    ROUND(AVG(a.TARGET) * 100, 2) AS default_rate_pct
FROM application a
LEFT JOIN (
    SELECT SK_ID_CURR, COUNT(*) AS refusal_count
    FROM previous_application
    WHERE NAME_CONTRACT_STATUS = 'Refused'
    GROUP BY SK_ID_CURR
) r ON a.SK_ID_CURR = r.SK_ID_CURR
GROUP BY rejection_history
ORDER BY FIELD(rejection_history, 'Never Refused', 'Refused Once', 'Refused 2+ Times');

-- Result: risk climbs with each extra refusal (6.98% -> 8.84% -> 11.61%),
-- not just a one-time flag.

-- Extra: does the REASON for the past refusal matter?
SELECT
    pa.CODE_REJECT_REASON,
    COUNT(DISTINCT a.SK_ID_CURR) AS applicants,
    ROUND(AVG(a.TARGET) * 100, 2) AS default_rate_pct
FROM application a
JOIN previous_application pa ON a.SK_ID_CURR = pa.SK_ID_CURR
WHERE pa.NAME_CONTRACT_STATUS = 'Refused'
GROUP BY pa.CODE_REJECT_REASON
ORDER BY default_rate_pct DESC;

-- Result: SCOFR stands out at 20.93%, more than double the baseline --
-- worth flagging on its own instead of lumping all rejection reasons
-- together.

-- Caveat: this only sees refused applicants who came back and got
-- approved -- the ones who never reapplied aren't in this data.
