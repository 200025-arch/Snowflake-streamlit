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

-- Vue jobs_postings nettoyée
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
    jobs_postings_clean jp
    JOIN companies_clean c ON jp.company_name = c.name
GROUP BY
    company_size
ORDER BY nb_offres DESC;

-- Top 10 des secteurs avec le plus d’offres par intitulé
SELECT i.industry_name, jp.title, COUNT(*) AS nb_postes
FROM
    jobs_postings_clean jp
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
            jobs_postings_clean jp
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
FROM jobs_postings_clean
GROUP BY
    formatted_work_type
ORDER BY nb_offres DESC;