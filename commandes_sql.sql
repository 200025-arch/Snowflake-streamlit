-- ==============================
-- INITIALISATION
-- ==============================
CREATE OR REPLACE DATABASE linkedin;

USE DATABASE linkedin;

-- Stage S3
CREATE OR REPLACE STAGE bucket_s3 URL = 's3://snowflake-lab-bucket/';

-- Formats de fichiers
CREATE OR REPLACE FILE FORMAT csv_format
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  RECORD_DELIMITER = '\n'
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  NULL_IF = ('')
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;

CREATE OR REPLACE FILE FORMAT json_format
  TYPE = 'JSON';

-- ==============================
-- TABLES & CHARGEMENT : CSV
-- ==============================

-- Table Benefits
CREATE
OR
REPLACE
TABLE benefits (
    job_id INTEGER,
    inferred STRING,
    tipe STRING
);

COPY INTO benefits
FROM @bucket_s3 / benefits.csv FILE_FORMAT = (FORMAT_NAME = csv_format);

select * from benefits;

-- Table Employee_counts
CREATE
OR
REPLACE
TABLE employee_counts (
    company_id INTEGER,
    employee_count STRING,
    follower_count STRING,
    time_recorded INTEGER
);

COPY INTO employee_counts
FROM @bucket_s3 / employee_counts.csv FILE_FORMAT = (FORMAT_NAME = csv_format);

select * from employee_counts;

-- Table Job_Skills
CREATE
OR
REPLACE
TABLE job_skills (
    job_id INTEGER,
    skill_abr STRING
);

COPY INTO job_skills
FROM @bucket_s3 / job_skills.csv FILE_FORMAT = (FORMAT_NAME = csv_format);

select * from job_skills;

-- Table Jobs_Postings
CREATE
OR
REPLACE
TABLE jobs_postings (
    job_id STRING,
    company_name STRING,
    title STRING,
    description STRING,
    max_salary STRING,
    original_listed_time STRING,
    closed_time STRING,
    pay_period STRING,
    formatted_work_type STRING,
    location STRING,
    expiry STRING,
    views STRING,
    remote_allowed STRING,
    applies STRING,
    application_url STRING,
    job_posting_url STRING,
    application_type STRING,
    listed_time STRING,
    posting_domain STRING,
    formatted_experience_level STRING,
    skills_desc STRING,
    sponsored STRING,
    company_website STRING,
    company_email STRING,
    work_type STRING,
    currency STRING,
    compensation_type STRING,
    job_tags STRING
);

COPY INTO jobs_postings
FROM
    @bucket_s3 / job_postings.csv FILE_FORMAT = (FORMAT_NAME = csv_format) ON_ERROR = 'CONTINUE';

-- ==============================
-- VUES DE NETTOYAGE
-- ==============================

-- Vue benefits nettoyée
CREATE OR REPLACE VIEW benefits_clean AS
SELECT job_id, LOWER(inferred) IN ('true', 'yes', '1') AS inferred, tipe AS type
FROM benefits;

select * from benefits_clean;

Vue jobs_postings nettoyée
CREATE OR REPLACE VIEW jobs_postings_clean AS
SELECT
    job_id,
    company_name,
    title,
    description,
    TRY_TO_DOUBLE (max_salary) AS max_salary,
    pay_period,
    formatted_work_type,
    location,
    TRY_TO_NUMBER (applies) AS applies,
    TRY_TO_TIMESTAMP (original_listed_time) AS original_listed_time,
    LOWER(remote_allowed) IN ('true', 'yes', '1') AS remote_allowed,
    TRY_TO_NUMBER (views) AS views,
    job_posting_url,
    application_url,
    application_type,
    TRY_TO_TIMESTAMP (expiry) AS expiry,
    TRY_TO_TIMESTAMP (closed_time) AS closed_time,
    formatted_experience_level,
    skills_desc,
    TRY_TO_TIMESTAMP (listed_time) AS listed_time,
    posting_domain,
    LOWER(sponsored) IN ('true', 'yes', '1') AS sponsored,
    work_type,
    currency,
    compensation_type,
    company_email,
    company_website,
    job_tags
FROM jobs_postings;

select * from jobs_postings_clean;

CREATE OR REPLACE VIEW jobs_postings_clean_named AS
SELECT
    job_id,
    CASE
        WHEN company_name = '601919.0' THEN 'IBM'
        WHEN company_name = '7361.0' THEN 'GE HealthCare'
        WHEN company_name = '19850.0' THEN 'GE Power'
        WHEN company_name = '1511.0' THEN 'Hewlett Packard Enterprise'
        WHEN company_name = '2780388.0' THEN 'Oracle'
        WHEN company_name = '241762.0' THEN 'Deloitte'
        WHEN company_name = '502882.0' THEN 'Siemens'
        WHEN company_name = '7003330.0' THEN 'PwC'
        WHEN company_name = '5258388.0' THEN 'Ericsson'
        WHEN company_name = '2138573.0' THEN 'JPMorgan Chase & Co.'
        WHEN company_name = '814025.0' THEN 'DWS Group'
        WHEN company_name = '11088832.0' THEN 'CTG'
        WHEN company_name = '64549636.0' THEN 'OCLC'
        WHEN company_name = '15142330.0' THEN 'GHX'
        WHEN company_name = '1344.0' THEN 'Milliman'
        WHEN company_name = '166572.0' THEN 'The Bolton Group'
        WHEN company_name = '163787.0' THEN 'Harmer'
        WHEN company_name = '86265278.0' THEN 'Clark Davis Associates'
        WHEN company_name = '2673675.0' THEN 'Culver Careers (CulverCareers.com)'
        WHEN company_name = '22141.0' THEN 'ITR Group'
        WHEN company_name = '15564.0' THEN 'Comrise'
        WHEN company_name = '82808548.0' THEN 'Profiles'
        WHEN company_name = '1441.0' THEN 'Eurasia Group'
        WHEN company_name = '54544813.0' THEN 'MATRIX Resources'
        WHEN company_name = '13074.0' THEN 'Ohio Department of Development'
        WHEN company_name = '40888889.0' THEN 'Huxley'
        WHEN company_name = '28014.0' THEN 'LAIKA Studios'
        WHEN company_name = '7587370.0' THEN 'ArenaNet LLC'
        WHEN company_name = '8280.0' THEN 'Motion Recruitment'
        WHEN company_name = '19637.0' THEN 'MSNBC'
        WHEN company_name = '1318.0' THEN 'CEI'
        WHEN company_name = '18040365.0' THEN 'Levi, Ray & Shoup, Inc. (LRS)'
        WHEN company_name = '7587370.0' THEN 'PlayStation'
        WHEN company_name = '11842128.0' THEN 'CDK Global'
        WHEN company_name = '15356840.0' THEN 'General Dynamics Land Systems'
        WHEN company_name = '814025.0' THEN 'Panasonic Avionics Corporation'
        WHEN company_name = '18287.0' THEN 'Bell Flight'
        ELSE company_name
    END AS company_name,
    -- Ajoute les autres colonnes si nécessaire
FROM jobs_postings_clean;

select * from jobs_postings_clean_named;

title,
description,
TRY_TO_DOUBLE (max_salary) AS max_salary,
pay_period,
formatted_work_type,
location,
TRY_TO_NUMBER (applies) AS applies,
TRY_TO_TIMESTAMP (original_listed_time) AS original_listed_time,
LOWER(remote_allowed) IN ('true', 'yes', '1') AS remote_allowed,
TRY_TO_NUMBER (views) AS views,
job_posting_url,
application_url,
application_type,
TRY_TO_TIMESTAMP (expiry) AS expiry,
TRY_TO_TIMESTAMP (closed_time) AS closed_time,
formatted_experience_level,
skills_desc,
TRY_TO_TIMESTAMP (listed_time) AS listed_time,
posting_domain,
LOWER(sponsored) IN ('true', 'yes', '1') AS sponsored,
work_type,
currency,
compensation_type,
company_email,
company_website,
job_tags
FROM jobs_postings;

select * from jobs_postings_clean_named;

-- ==============================
-- TABLES & VUES : JSON
-- ==============================

-- Companies
CREATE OR REPLACE TABLE companies (company VARIANT);

COPY INTO companies
FROM @bucket_s3 / companies.json FILE_FORMAT = (FORMAT_NAME = json_format);

CREATE OR REPLACE VIEW companies_clean AS
SELECT
  value:company_id::STRING AS company_id,
  value:name::STRING AS name,
  value:description::STRING AS description,
  value:company_size::STRING AS company_size,
  value:state::STRING AS state,
  value:country::STRING AS country,
  value:city::STRING AS city,
  value:zip_code::STRING AS zip_code,
  value:address::STRING AS address,
  value:url::STRING AS url
FROM companies,
LATERAL FLATTEN(input => company);

select * from companies_clean;

list @bucket_s3;

-- Company Industries
CREATE OR REPLACE TABLE company_industries_raw (data VARIANT);

COPY INTO company_industries_raw
FROM @bucket_s3 / company_industries.json FILE_FORMAT = (FORMAT_NAME = json_format);

CREATE OR REPLACE VIEW company_industries_clean AS
SELECT
  value:company_id::STRING AS company_id,
  value:industry::STRING AS industry
FROM company_industries_raw,
LATERAL FLATTEN(input => data);

select * from company_industries_clean;

-- Company Specialities
CREATE OR REPLACE TABLE company_specialities_raw (data VARIANT);

COPY INTO company_specialities_raw
FROM @bucket_s3 / company_specialities.json FILE_FORMAT = (FORMAT_NAME = json_format);

CREATE OR REPLACE VIEW company_specialities_clean AS
SELECT
  value:company_id::STRING AS company_id,
  value:speciality::STRING AS speciality
FROM company_specialities_raw,
LATERAL FLATTEN(input => data);

select * from company_specialities_clean;

-- Job Industries
CREATE OR REPLACE TABLE job_industries_raw (data VARIANT);

COPY INTO job_industries_raw
FROM @bucket_s3 / job_industries.json FILE_FORMAT = (FORMAT_NAME = json_format);

CREATE OR REPLACE VIEW job_industries_clean AS
SELECT
  value:job_id::STRING AS job_id,
  value:industry_id::STRING AS industry_id
FROM job_industries_raw,
LATERAL FLATTEN(input => data);

select * from job_industries_clean;

-- ==============================
-- 📚 TABLE DIMENSION MANUELLE
-- ==============================
CREATE
OR
REPLACE
TABLE industries_csv (
    industry_id STRING,
    industry_name STRING
);

INSERT INTO
    industries_csv (industry_id)
SELECT DISTINCT
    industry_id
FROM job_industries_clean
WHERE
    industry_id IS NOT NULL;

SELECT distinct
    industry_id
FROM industries_csv
ORDER BY industry_id ASC;

INSERT INTO
    industries_csv (industry_id, industry_name)
VALUES (
        22,
        'Technologies de l\'information'
    ),
    (2, 'Finance'),
    (3, 'Santé'),
    (4, 'Éducation'),
    (
        5,
        'Distribution et Commerce de détail'
    ),
    (6, 'Transports et Logistique'),
    (7, 'Industrie manufacturière'),
    (8, 'Énergie et Environnement'),
    (9, 'Marketing et Publicité'),
    (10, 'Consulting'),
    (11, 'Assurance'),
    (12, 'Immobilier'),
    (13, 'Services juridiques'),
    (14, 'Tourisme et Hôtellerie'),
    (
        15,
        'Alimentation et Boissons'
    ),
    (16, 'Télécommunications'),
    (
        17,
        'Médias et Divertissement'
    ),
    (
        18,
        'Recherche et Développement'
    ),
    (19, 'Mode et Luxe'),
    (
        20,
        'Organisations à but non lucratif'
    );

select * from industries_csv where industry_name is not null;

list @bucket_s3;

-- ==============================
-- 📊 EXEMPLES DE REQUÊTES
-- ==============================

-- Nb d'offres par taille d'entreprise
SELECT company_size, COUNT(DISTINCT jp.job_id) AS nb_offres
FROM
    jobs_postings_clean_named jp
    JOIN companies_clean c ON jp.company_name = c.name
GROUP BY
    company_size
ORDER BY nb_offres DESC;

-- Top 10 des secteurs avec le plus d’offres par intitulé
SELECT i.industry_name, jp.title, COUNT(*) AS nb_postes
FROM
    jobs_postings_clean_named jp
    JOIN job_industries_clean ji ON jp.job_id = ji.job_id
    JOIN industries_csv i ON ji.industry_id = i.industry_id
GROUP BY
    i.industry_name,
    jp.title
ORDER BY nb_postes DESC
LIMIT 10;

-- Top 10 des métiers les mieux payés par secteur
SELECT *
FROM (
        SELECT i.industry_name, jp.title, jp.max_salary, ROW_NUMBER() OVER (
                PARTITION BY
                    i.industry_name
                ORDER BY jp.max_salary DESC
            ) AS rn
        FROM
            jobs_postings_clean_named jp
            JOIN job_industries_clean ji ON jp.job_id = ji.job_id
            JOIN industries_csv i ON ji.industry_id = i.industry_id
        WHERE
            jp.max_salary IS NOT NULL
    )
WHERE
    rn = 1
ORDER BY max_salary DESC
LIMIT 10;

-- Nb d’offres par type d’emploi
SELECT
    formatted_work_type AS type_emploi,
    COUNT(*) AS nb_offres
FROM jobs_postings_clean_named
GROUP BY
    formatted_work_type
ORDER BY nb_offres DESC;

SELECT DISTINCT
    company_name
FROM jobs_postings_clean_named
LIMIT 100;

-- afficher les sociétés et leurs tailles

SELECT c.name AS company_name, c.company_size
FROM companies_clean c
WHERE
    c.name is not null;

SELECT c.name AS company_name, c.company_size
FROM companies_clean c
WHERE
    c.name is not null;

--Vérification nombre d'offres en fonction de la taille de l'entreprise.

SELECT c.company_size, COUNT(DISTINCT jp.job_id) AS nb_offres
FROM
    jobs_postings_clean_named jp
    JOIN companies_clean c ON jp.company_name = c.name
WHERE
    c.company_size IS NOT NULL
    AND c.name IS NOT NULL
GROUP BY
    c.company_size
ORDER BY
    CASE
        WHEN c.company_size = '1' THEN 1
        WHEN c.company_size = '2' THEN 2
        WHEN c.company_size = '3' THEN 3
        WHEN c.company_size = '4' THEN 4
        WHEN c.company_size = '5' THEN 5
        WHEN c.company_size = '6' THEN 6
        WHEN c.company_size = '7' THEN 7
        ELSE 8
    END;