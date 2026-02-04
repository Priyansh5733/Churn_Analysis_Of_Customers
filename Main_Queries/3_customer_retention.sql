WITH customer_last_purchase AS (SELECT 
concat(givenname,' ',surname ) AS Cleaned_name,
orderdate,
customerkey,
row_number() OVER (PARTITION BY customerkey order BY ORDERdate DESC) rn,
first_purchase_date,
ca.cohort_year 
FROM cohort_analysis ca 
),

 last_purchase AS (SELECT 
cleaned_name,
ct.orderdate AS last_purchase_date,
customerkey,
first_purchase_date,
cohort_year
FROM customer_last_purchase  ct
WHERE rn=1
),

Churned_customers AS(SELECT cleaned_name,
customerkey,
first_purchase_date,
last_purchase_date,
cohort_year,
CASE 
	WHEN last_purchase_date <(SELECT MAX(ORDERDATE) FROM SALES)- INTERVAL '6 months' THEN 'churned_customer'
	ELSE 'Active'
END AS Churned_or_not
FROM last_purchase lp
)

SELECT
    cohort_year,
    Churned_or_not,
    COUNT(customerkey) AS num_customers,
    SUM(COUNT(customerkey)) OVER(PARTITION  BY cohort_year) AS total_customers,
    ROUND(
        COUNT(customerkey) / SUM(COUNT(customerkey)) OVER(PARTITION  BY cohort_year),
        2
    ) AS status_percentage
FROM churned_customers
GROUP BY Churned_or_not,cohort_year

