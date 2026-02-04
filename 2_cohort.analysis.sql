SELECT cohort_year,
count(DISTINCT customerkey) AS total_customers,
sum(net_revenue) AS total_net_revenue,
sum(net_revenue)/count(DISTINCT customerkey) AS customer_revenue
FROM cohort_analysis ca 
WHERE orderdate=ca.first_purchase_date 
GROUP BY cohort_year 