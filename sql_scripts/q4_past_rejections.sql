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
                
                -- Result: Never Refused -> 6.98% default (207,209 applicants)
                --         Previously Refused -> 10.32% default (100,284 applicants)
                -- Conclusion: past rejections were the right call -- applicants with a
                -- prior refusal default ~48% more often than those never refused, even on
                -- the loan that DID get approved. The rejection criteria is picking up a
                -- real, persistent risk signal, not rejecting good business by mistake.