-- Home Credit Default Risk — database schema
-- Columns match notebooks/column_selection_combined.ipynb exactly.

CREATE DATABASE IF NOT EXISTS home_credit;
USE home_credit;

-- One row per applicant. Root table: bureau and previous_application
-- both hang off it via SK_ID_CURR.
CREATE TABLE application (
    SK_ID_CURR          INT PRIMARY KEY,
    TARGET               INT,
    CODE_GENDER          VARCHAR(5),
    CNT_CHILDREN         INT,
    CNT_FAM_MEMBERS      INT,
    NAME_FAMILY_STATUS   VARCHAR(50),
    FLAG_OWN_CAR         VARCHAR(5),
    FLAG_OWN_REALTY      VARCHAR(5),
    AMT_INCOME_TOTAL     FLOAT,
    AMT_CREDIT           FLOAT,
    AMT_ANNUITY          FLOAT,
    NAME_CONTRACT_TYPE   VARCHAR(50),
    NAME_INCOME_TYPE     VARCHAR(50),
    OCCUPATION_TYPE      VARCHAR(50),
    NAME_EDUCATION_TYPE  VARCHAR(50),
    NAME_HOUSING_TYPE    VARCHAR(50),
    DAYS_BIRTH           INT,
    DAYS_EMPLOYED        INT
);

-- Prior credits at OTHER institutions, reported to the credit bureau.
-- Trimmed for Q2 only, so it has no surviving natural key from the raw
-- data (SK_ID_BUREAU was dropped) — `id` is a surrogate PK just so the
-- table has one, it isn't used for anything analytically.
CREATE TABLE bureau (
    id                      INT AUTO_INCREMENT PRIMARY KEY,
    SK_ID_CURR              INT,
    CREDIT_DAY_OVERDUE      INT,
    AMT_CREDIT_SUM_OVERDUE  FLOAT,
    FOREIGN KEY (SK_ID_CURR) REFERENCES application(SK_ID_CURR)
);

-- Prior applications with Home Credit itself (approved, refused, etc.).
CREATE TABLE previous_application (
    SK_ID_PREV             INT PRIMARY KEY,
    SK_ID_CURR              INT,
    NAME_CONTRACT_STATUS    VARCHAR(50),
    CODE_REJECT_REASON      VARCHAR(50),
    NAME_PORTFOLIO          VARCHAR(50),
    NAME_PRODUCT_TYPE       VARCHAR(50),
    NAME_YIELD_GROUP        VARCHAR(50),
    CHANNEL_TYPE            VARCHAR(50),
    NAME_SELLER_INDUSTRY    VARCHAR(50),
    FOREIGN KEY (SK_ID_CURR) REFERENCES application(SK_ID_CURR)
);

-- Aroa's addition: a separate table, NOT a replacement for
-- previous_application above. Same source CSV, but keeps the
-- amount/date columns Carla trimmed out, needed to dig into the Q3
-- residual (why "clean history" returning clients still default more
-- than new ones). See q3_extended_repeat_client_drivers.sql.
CREATE TABLE previous_application_extended (
    SK_ID_PREV             INT PRIMARY KEY,
    SK_ID_CURR              INT,
    NAME_CONTRACT_STATUS    VARCHAR(50),
    AMT_CREDIT              FLOAT,
    AMT_ANNUITY              FLOAT,
    DAYS_DECISION            INT,
    FOREIGN KEY (SK_ID_CURR) REFERENCES application(SK_ID_CURR)
);
