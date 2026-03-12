

INSERT INTO silver.crm_customers_info(
  customer_id,
  FirstName,
  LastName,
  clean_date,
  clean_region,
  clean_email)

SELECT
 customer_id,
 UPPER(SUBSTRING(first_name,1,1)) + LOWER(SUBSTRING (first_name,2,LEN(first_name))) AS FirstName,---changing the word format
 UPPER(SUBSTRING(last_name,1,1)) + LOWER(SUBSTRING (last_name,2,LEN(last_name))) AS LastName, ----- channging the word format
 COALESCE(
  TRY_CONVERT(DATE,signup_date,23),
  TRY_CONVERT(DATE,signup_date,103),
  TRY_CONVERT(DATE,signup_date,110),
  TRY_CONVERT(DATE,signup_date,111)
  ) AS clean_date,----- Trying out various date format to check which one works best
  CASE 
        WHEN TRIM(region) = '' OR region IS NULL THEN NULL
        ELSE UPPER(SUBSTRING(TRIM(region),1,1)) + LOWER(SUBSTRING(TRIM(region),2,LEN(TRIM(region))))
    END AS clean_region,   ----- Handling NULLs and unwanted spaces
    NULLIF(TRIM(email), '') AS clean_email  ----Handling NULLs
FROM
(
SELECT*,
ROW_NUMBER () OVER (PARTITION BY customer_id ORDER BY COALESCE(
  TRY_CONVERT(DATE,signup_date,23),
  TRY_CONVERT(DATE,signup_date,103),
  TRY_CONVERT(DATE,signup_date,110),
  TRY_CONVERT(DATE,signup_date,111)
  ) DESC ---- Adjusting the ORDER BY with the new date format
) AS Ranking ----- Ranking to spot duplicates
FROM customers_plain
)t
WHERE Ranking = 1 ----- Filtering to remove duplicates