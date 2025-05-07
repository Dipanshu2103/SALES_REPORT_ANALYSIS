**This project explores the Olist e-commerce dataset using SQL. It contains real transactional data from a Brazilian marketplace. The analysis helps uncover business insights around delivery performance, customer satisfaction, product popularity, and payment behavior.**

**Problem Statements & Goals**
1. Delivery Performance
What % of orders were delivered late vs. on time?

Which regions/states face the most delivery issues?

What is the average delivery delay (in days) by state?

2. Customer Review Analysis
Average review score by product category.

Categories with most 5-star and 1-star reviews.

Relation between delivery delay and review score.

3. Top-Selling Products and Categories
Top 10 best-selling product categories.

Top 10 most-sold individual products.

4. Payment Behavior
Most used payment methods.

Average payment value per order.

Total revenue by payment type.

5. Additional Insights
Most active customers & cities.

Monthly order trends and delivery time.

Categories customers love the most.

Products with the most 1-star reviews.

**Tools Used**
1. Python (clean dataset)

2. MySQL (data analysis and querying)

**Dataset Files**
1. olist_customers_dataset.csv

2. olist_geolocation_dataset.csv

3. olist_order_items_dataset.csv

4. olist_order_payments_dataset.csv

5. olist_order_reviews_dataset.csv

6. olist_orders_dataset.csv

7. olist_products_dataset.csv

8. olist_sellers_dataset.csv

9. product_category_name_translation.csv

**Data Preparation**
1. Converted string dates to DATETIME format.

2. Joined datasets using order_id, customer_id, etc.

3. Handled missing values and inconsistent records.

4. Created indexes to speed up query performance.

**Key Insights Summary**
1. X% of deliveries were on time, while Y% were late.

2. Best-rated categories: A, B, C (Avg > 4.5)

3. Most popular payment method: Credit Card

4. Top delivery cities: Sao Paulo, Rio de Janeiro, Belo Horizonte

5. Top product categories: Category A, B, C by volume and revenue
