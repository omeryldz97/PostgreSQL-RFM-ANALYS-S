-- Preview the first 4 rows
SELECT * FROM flo_data AS f LIMIT 4;

-- STEP 1: Data Control & Cleaning
-- Check total observation count
SELECT COUNT(*) FROM flo_data AS f;

-- STEP 2: Determining Reference Date
-- Setting the analysis date to 2 days after the maximum order date in the dataset
SELECT MAX(f.last_order_date) + interval '2 days' AS analysis_date FROM flo_data AS f;

-- STEP 3: Calculating RFM Metrics
WITH cte_1 AS (
    SELECT
        f.master_id,
        -- Corrected Recency: Using a dynamic analysis date instead of CURRENT_DATE
        (SELECT MAX(last_order_date) + interval '2 days' FROM flo_data) - f.last_order_date AS recency,
        f.order_num_total_ever_offline + f.order_num_total_ever_online AS frequency,
        f.customer_value_total_ever_offline + f.customer_value_total_ever_online AS monetary
    FROM flo_data AS f
),
cte_2 AS (
    SELECT 
        *, 
        CASE 
            WHEN recency <= '30 days'::interval THEN 5
            WHEN recency <= '60 days'::interval THEN 4
            WHEN recency <= '90 days'::interval THEN 3
            WHEN recency <= '120 days'::interval THEN 2
            ELSE 1
        END AS recency_score,
        CASE
            WHEN frequency >= 20 THEN 5
            WHEN frequency >= 10 THEN 4
            WHEN frequency >= 5 THEN 3
            WHEN frequency >= 2 THEN 2
            ELSE 1 
        END AS frequency_score,
        CASE
            WHEN monetary >= 5000 THEN 5
            WHEN monetary >= 3000 THEN 4
            WHEN monetary >= 1500 THEN 3
            WHEN monetary >= 500 THEN 2
            ELSE 1
        END AS monetary_score
    FROM cte_1
),
cte_3 AS (
    SELECT 
        master_id,
        recency_score,
        frequency_score,
        monetary_score,
        CONCAT(recency_score, frequency_score) AS rf_score -- Standard RF scoring usually excludes Monetary for segmentation
    FROM cte_2
),
cte_4 AS (
    SELECT *,
        CASE
            WHEN rf_score ~ '^[1-2][1-2]' THEN 'Hibernating'
            WHEN rf_score ~ '^[1-2][3-4]' THEN 'At Risk'
            WHEN rf_score ~ '^[1-2]5' THEN 'Cant Loose'
            WHEN rf_score ~ '^3[1-2]' THEN 'About to Sleep'
            WHEN rf_score ~ '^33' THEN 'Need Attention'
            WHEN rf_score ~ '^[3-4][4-5]' THEN 'Loyal Customers'
            WHEN rf_score ~ '^41' THEN 'Promising'
            WHEN rf_score ~ '^51' THEN 'New Customers'
            WHEN rf_score ~ '^[4-5][2-3]' THEN 'Potential Loyalists'
            WHEN rf_score ~ '^5[4-5]' THEN 'Champions'
            ELSE 'Other'
        END AS segments        
    FROM cte_3
)
SELECT * FROM cte_4;






