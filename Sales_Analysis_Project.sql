use sales_analysis;
 
-- Sales Analysis

-- 1. Basic Delivery Performance Report 
-- Problem: Find the percentage of orders delivered late vs. on time. 
-- Goal: Help logistics team fix delivery issues. 

SELECT 
    ROUND(SUM(order_delivered_customer_date > order_estimated_delivery_date) / COUNT(*) * 100,
            2) AS 'Late_%',
    ROUND(SUM(order_delivered_customer_date <= order_estimated_delivery_date) / COUNT(*) * 100,
            2) AS 'On_Time_%'
FROM
    orders
WHERE
    order_status = 'delivered';

-- 2. Customer Review Analysis 
-- Problem: Find the average customer rating for each product category. 
-- Goal: Identify which categories customers love or hate.

with c1 as (SELECT 
    review_score, order_id
FROM
    order_reviews),

c2 as (SELECT 
    order_id, product_id
FROM
    order_items),

c3 as (SELECT 
    product_id, product_category_name
FROM
    products),

c4 as (SELECT 
    product_category_name, product_category_name_english
FROM
    category_name)

SELECT 
    product_category_name_english AS 'category_name',
    ROUND(AVG(review_score), 2) AS 'average_customer_rating',
    CASE
        WHEN AVG(review_score) > 2.5 THEN 'love'
        ELSE 'hate'
    END AS 'satisfaction_label'
FROM
    c1
        JOIN
    c2 ON c1.order_id = c2.order_id
        JOIN
    c3 ON c2.product_id = c3.product_id
        JOIN
    c4 ON c3.product_category_name = c4.product_category_name
GROUP BY 1;

-- 3. Top Selling Products and Categories 
-- Problem: Find the top 10 best-selling product categories. 
-- Goal: Help the marketing team promote the best products.

with c1 as (SELECT 
    product_id, product_category_name
FROM
    products),

c2 as (SELECT 
    order_id, product_id, price, freight_value
FROM
    order_items)

SELECT 
    product_category_name_english AS category_name,
    ROUND(SUM(price + freight_value), 2) AS total_sale
FROM
    c2
        JOIN
    c1 ON c1.product_id = c2.product_id
        JOIN
    category_name cn ON cn.product_category_name = c1.product_category_name
GROUP BY 1
ORDER BY total_sale DESC
LIMIT 10;

-- 4. Payment Types and Trends 
-- Problem: Find out which payment method customers use the most (credit card, boleto, etc.). 
-- Goal: Plan for payment system improvements datasets.

with c1 as (SELECT 
    customer_id, order_id
FROM
    orders),

c2 as (SELECT 
    payment_type, order_id
FROM
    order_payments)

SELECT 
    payment_type, COUNT(customer_id) AS total_customers
FROM
    c1
        JOIN
    c2 ON c1.order_id = c2.order_id
GROUP BY 1
ORDER BY total_customers DESC
LIMIT 1;

-- 5.Average review score per product category 

with c1 as (SELECT 
    *
FROM
    category_name),

c2 as (SELECT 
    product_id, product_category_name
FROM
    products),

c3 as (SELECT 
    order_id, product_id
FROM
    order_items),

c4 as (SELECT 
    order_id, review_score
FROM
    order_reviews)

SELECT 
    product_category_name_english AS 'category_name',
    ROUND(AVG(review_score), 2) AS 'avg_review_score'
FROM
    c1
        JOIN
    c2 ON c1.product_category_name = c2.product_category_name
        JOIN
    c3 ON c2.product_id = c3.product_id
        JOIN
    c4 ON c3.order_id = c4.order_id
GROUP BY 1;

-- 6. Delivery Performance 
-- Identify regions with most late deliveries.

with c1 as(SELECT 
    customer_id,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM
    orders),

c2 as (SELECT 
    customer_id, customer_city
FROM
    customers)

SELECT 
    customer_city,
    ROUND(SUM(order_delivered_customer_date > order_estimated_delivery_date) / COUNT(*) * 100,
            2) AS `Late_%`
FROM
    c1
        JOIN
    c2 ON c1.customer_id = c2.customer_id
GROUP BY 1
ORDER BY `Late_%` DESC;

-- 7. Customer Review Analysis  
-- Identify categories with most 5-star and 1-star reviews. 

with c1 as (SELECT 
    review_score, order_id
FROM
    order_reviews),

c2 as (SELECT 
    order_id, product_id
FROM
    order_items),

c3 as (SELECT 
    product_id, product_category_name
FROM
    products),

c4 as (SELECT 
    product_category_name, product_category_name_english
FROM
    category_name)

SELECT 
    product_category_name_english AS 'category_name',
    count(case when review_score=5 then 1 end) as '5-star_reviews',
    count(case when review_score=1 then 1 end) as '1-star_reviews'
FROM
    c1
        JOIN
    c2 ON c1.order_id = c2.order_id
        JOIN
    c3 ON c2.product_id = c3.product_id
        JOIN
    c4 ON c3.product_category_name = c4.product_category_name
GROUP BY 1;

-- 8.Payment Behavior 
-- Analyze the average payment value per order.

with c1 as (SELECT 
    payment_value, order_id
FROM
    order_payments),

c2 as (SELECT 
    order_id, order_status
FROM
    orders
WHERE
    order_status = 'Delivered')
        
SELECT 
    c1.order_id,
    ROUND(AVG(payment_value), 2) AS 'average_payment_value'
FROM
    c1
        JOIN
    c2 ON c1.order_id = c2.order_id
GROUP BY 1
ORDER BY average_payment_value DESC;

-- 9. How many orders does an average customer place? 

SELECT 
    customer_id, COUNT(order_id) AS average_order
FROM
    orders
WHERE
    order_status = 'delivered'
GROUP BY 1;

-- 10. Which cities have the most active customers?

SELECT 
    customer_city, COUNT(o.customer_id) AS active_customers
FROM
    customers c
        JOIN
    orders o ON o.customer_id = c.customer_id
WHERE
    order_status = 'delivered'
GROUP BY 1
ORDER BY active_customers DESC;

-- 11. Distribution of review scores.

with c1 as (SELECT 
    order_id, review_score
FROM
    order_reviews),

c2 as (SELECT 
    order_id, customer_id
FROM
    orders)

SELECT 
    review_score, COUNT(customer_id) AS review_count
FROM
    c1
        JOIN
    c2 ON c1.order_id = c2.order_id
GROUP BY 1
ORDER BY review_score;

-- 12. Relation between delivery time and review score.

with c1 as (SELECT 
    order_id,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM
    orders),

c2 as (SELECT 
    order_id, review_score
FROM
    order_reviews)

SELECT 
    CASE
        WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 'Late'
        ELSE 'On_Time'
    END AS 'delivery_status',
    ROUND(AVG(review_score), 2) AS 'average_review_score',
    COUNT(*) AS review_count
FROM
    c1
        JOIN
    c2 ON c1.order_id = c2.order_id
GROUP BY 1;
 
-- 13. Average delay days (delivered date vs estimated date)

with c1 as (SELECT 
    order_status,
    order_id,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM
    orders
WHERE
    order_status = 'delivered')

SELECT 
    ROUND(AVG(DATEDIFF(order_delivered_customer_date,
                    order_estimated_delivery_date)),
            2) AS average_delay_days
FROM
    c1;
    
-- 14. Categories with most orders. 

with c1 as (SELECT 
    *
FROM
    category_name),

c2 as (SELECT 
    product_id, product_category_name
FROM
    products),

c3 as (SELECT 
    product_id, order_id
FROM
    order_items)

SELECT 
    product_category_name_english AS category_name,
    COUNT(order_id) AS total_orders
FROM
    c1
        JOIN
    c2 ON c1.product_category_name = c2.product_category_name
        JOIN
    c3 ON c2.product_id = c3.product_id
GROUP BY 1
ORDER BY total_orders DESC;

-- 15. Which 3 product categories have the best customer ratings?

with c1 as (SELECT 
    order_id, review_score
FROM
    order_reviews),

c2 as (SELECT 
    order_id, product_id
FROM
    order_items),

c3 as (SELECT 
    product_id, product_category_name
FROM
    products),

c4 as (SELECT 
    *
FROM
    category_name)

SELECT 
    product_category_name_english AS 'category_name',
    AVG(review_score) AS best_rating
FROM
    c1
        JOIN
    c2 ON c1.order_id = c2.order_id
        JOIN
    c3 ON c2.product_id = c3.product_id
        JOIN
    c4 ON c3.product_category_name = c4.product_category_name
GROUP BY 1
ORDER BY best_rating DESC
LIMIT 3;
 
-- 16. Name 3 cities where most deliveries happen.

with c1 as (SELECT 
    customer_id, customer_city
FROM
    customers),

c2 as (SELECT 
    order_id, customer_id
FROM
    orders)

SELECT 
    customer_city, COUNT(order_id) AS 'max_orders'
FROM
    c1
        JOIN
    c2 ON c1.customer_id = c2.customer_id
GROUP BY 1
ORDER BY max_orders DESC
LIMIT 3;

-- 17. Calculate the average delivery delay (in days) for each state.

with c1 as (SELECT 
    customer_state, customer_id
FROM
    customers),

c2 as (SELECT 
    order_id,
    customer_id,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM
    orders
WHERE
    order_delivered_customer_date > order_estimated_delivery_date)

SELECT 
    customer_state,
    ROUND(AVG(DATEDIFF(order_delivered_customer_date,
                    order_estimated_delivery_date)),
            2) AS 'Late_Delivery'
FROM
    c1
        JOIN
    c2 ON c1.customer_id = c2.customer_id
GROUP BY 1;

-- 18. Find the top 5 product categories with the highest number of late deliveries. 

with c1 as (SELECT 
    *
FROM
    category_name),

c2 as (SELECT 
    product_id, product_category_name
FROM
    products),

c3 as (SELECT 
    product_id, order_id
FROM
    order_items),

c4 as (SELECT 
    order_id,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM
    orders)

SELECT 
    product_category_name_english AS category_name,
    COUNT(order_delivered_customer_date > order_estimated_delivery_date) AS total_late_deliveries
FROM
    c1
        JOIN
    c2 ON c1.product_category_name = c2.product_category_name
        JOIN
    c3 ON c2.product_id = c3.product_id
        JOIN
    c4 ON c3.order_id = c4.order_id
GROUP BY 1
ORDER BY total_late_deliveries DESC
LIMIT 5;

-- 19. List the top 10 cities with the highest number of unique customers. 

SELECT 
    customer_city,
    COUNT(DISTINCT customer_id) AS uniq_cust
FROM
    customers
GROUP BY 1
ORDER BY uniq_cust DESC
LIMIT 10;

-- 20. Find the most common review score for each product category. 

with c1 as (SELECT 
    *
FROM
    category_name),

c2 as (SELECT 
    product_id, product_category_name
FROM
    products),

c3 as (SELECT 
    order_id, product_id
FROM
    order_items),

c4 as (SELECT 
    order_id, review_score
FROM
    order_reviews)

Select category_name, 
	   review_score from
(Select product_category_name_english as category_name , 
		review_score , 
        count(*) ,
		rank() over(partition by product_category_name_english order by count(*) desc) as ranking
from c1 join c2 on c1.product_category_name = c2.product_category_name
join c3 on c2.product_id = c3.product_id
join c4 on c3.order_id = c4.order_id
group by 1,2 ) as review_score 
where ranking=1
order by review_score asc;

-- 21. Identify the top 5 products that received the most 1-star reviews. 

with c1 as (SELECT 
    product_id
FROM
    products),

c2 as (SELECT 
    order_id, product_id
FROM
    order_items),

c3 as (SELECT 
    order_id, review_score
FROM
    order_reviews
WHERE
    review_score = 1)

SELECT 
    c1.product_id, COUNT(review_score) AS one_star_review_count
FROM
    c1
        JOIN
    c2 ON c1.product_id = c2.product_id
        JOIN
    c3 ON c2.order_id = c3.order_id
GROUP BY 1
ORDER BY one_star_review_count DESC
LIMIT 5;

-- 22. Calculate the total revenue generated by each payment type. 

with c1 as (SELECT 
    order_id, payment_type
FROM
    order_payments),

c2 as (SELECT 
    order_id, price, freight_value
FROM
    order_items)

SELECT 
    payment_type,
    ROUND(SUM(price + freight_value), 2) AS total_revenue
FROM
    c1
        JOIN
    c2 ON c1.order_id = c2.order_id
GROUP BY 1
ORDER BY total_revenue DESC;

-- 23. For each product category, calculate the average review score and total number of orders.

with c1 as (SELECT 
    *
FROM
    category_name),

c2 as (SELECT 
    product_id, product_category_name
FROM
    products),

c3 as (SELECT 
    order_id, product_id
FROM
    order_items),

c4 as (SELECT 
    order_id, review_score
FROM
    order_reviews)

SELECT 
    product_category_name_english AS category_name,
    ROUND(AVG(review_score), 2) AS avg_review_score,
    COUNT(c3.order_id) AS total_orders
FROM
    c1
        JOIN
    c2 ON c1.product_category_name = c2.product_category_name
        JOIN
    c3 ON c2.product_id = c3.product_id
        JOIN
    c4 ON c3.order_id = c4.order_id
GROUP BY 1;
 
-- 24. Find the top 5 customers who placed the most orders and their total spending.

with c1 as (SELECT 
    customer_id
FROM
    customers),

c2 as (SELECT 
    customer_id, order_id
FROM
    orders),

c3 as (SELECT 
    order_id, price, freight_value
FROM
    order_items)

SELECT 
    c1.customer_id,
    COUNT(c2.order_id) AS total_orders,
    ROUND(SUM(price + freight_value), 2) AS total_spendings
FROM
    c1
        JOIN
    c2 ON c1.customer_id = c2.customer_id
        JOIN
    c3 ON c2.order_id = c3.order_id
GROUP BY 1
ORDER BY total_orders DESC;
 
-- 25. Determine the number of orders per month and the average delivery time (in days) for each month. 

with c1 as (SELECT 
    order_id,
    order_status,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM
    orders
WHERE
    order_status = 'delivered'),
    
c2 as (SELECT 
    MONTH(order_delivered_customer_date) AS months,
    MONTHNAME(order_delivered_customer_date) AS month_name,
    COUNT(order_id) AS total_orders,
    ROUND(AVG(DATEDIFF(order_delivered_customer_date,
                    order_estimated_delivery_date)),
            2) AS Avg_Delivery_Time
FROM
    c1
GROUP BY 1 , 2
ORDER BY months)

SELECT 
    month_name, total_orders, Avg_Delivery_Time
FROM
    c2 ;
            
-- 26. Identify categories where the majority of reviews are 5-star.

with c1 as (SELECT 
    review_score, order_id
FROM
    order_reviews),

c2 as (SELECT 
    order_id, product_id
FROM
    order_items),

c3 as (SELECT 
    product_id, product_category_name
FROM
    products),

c4 as (SELECT 
    product_category_name, product_category_name_english
FROM
    category_name)

SELECT 
    product_category_name_english AS 'category_name',
    COUNT(CASE
        WHEN review_score = 5 THEN 1
    END) AS '5-star_reviews'
FROM
    c1
        JOIN
    c2 ON c1.order_id = c2.order_id
        JOIN
    c3 ON c2.product_id = c3.product_id
        JOIN
    c4 ON c3.product_category_name = c4.product_category_name
GROUP BY 1
ORDER BY `5-star_reviews` DESC;

