CREATE OR REPLACE VIEW public.cohort_analysis
AS WITH customer_revenue AS (
         SELECT s.customerkey,
            s.orderdate,
            sum(s.quantity::double precision * s.netprice * s.exchangerate) AS net_revenue,
            count(s.orderkey) AS num_orders,
            c.countryfull,
            c.givenname,
            c.surname,
            c.age
           FROM sales s
             LEFT JOIN customer c ON c.customerkey = s.customerkey
          GROUP BY s.customerkey, c.countryfull, c.givenname, c.surname, c.age, s.orderdate
        )
 SELECT customerkey,
    orderdate,
    net_revenue,
    num_orders,
    countryfull,
    givenname,
    surname,
    age,
    min(orderdate) OVER (PARTITION BY customerkey) AS first_purchase_date,
    EXTRACT(year FROM min(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year,
        CASE
            WHEN EXTRACT(year FROM orderdate) = EXTRACT(year FROM min(orderdate) OVER (PARTITION BY customerkey)) THEN 'same_year'::text
            ELSE 'different_year'::text
        END AS same_diff
   FROM customer_revenue cr;

