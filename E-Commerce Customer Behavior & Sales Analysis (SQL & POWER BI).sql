/*

Project Name   : E-Commerce Customer Behavior & Sales Analysis
Author         : Ankit Yadav
Role           : Data Analyst
Objective      : Analyze revenue performance, customer behavior, and operational efficiency
Dataset        : fact_ord (e-commerce transaction data)
Grain          : One row per order line item
Key Metrics    : Revenue, Orders, AOV, CLV, Retention Rate
Tools Used     : SQL, Power BI
Last Updated   : 2026-01-24



=====================================================
SECTION 1: CORE BUSINESS & SALES PERFORMANCE
Purpose: Measure overall business health and revenue
===================================================== */

-- Q1. Total revenue, total orders, and average order value (AOV)

SELECT
    COUNT(DISTINCT Order_ID) AS total_orders,
    Round(SUM(Total_Amount),2) AS total_revenue,
    ROUND(SUM(Total_Amount) / COUNT(DISTINCT Order_ID),2) AS avg_order_value
FROM fact_ord;

-- Insight: Average order value is ₹1,277.44; total revenue 21.77M 
--			from 17,049 orders shows strong business volume.


-- Q2. Revenue trend by year and month

select 
       YEAR(date) as years,
	   MONTH(date) as months,
	   ROUND(SUM(total_amount),2) as total_revenue
from fact_ord
group by YEAR(date),MONTH(date)
order by years desc,months asc;

-- Insight:Revenue peaks in Mar–Dec 2023 (1.38–1.58M); early 2024 slightly lower, showing seasonal trends.

-- Q3. Product categories with highest revenue and order volume

select 
       Product_Category,
	   ROUND(SUM(total_amount),2) as category_revenue,
	   COUNT(Distinct Order_ID) as order_valume
from fact_ord
group by Product_Category
order by category_revenue desc;

-- Insight:Electronics generates highest revenue (₹10.48M);Sports has highest order volume (2,248 orders), 
--		   showing revenue vs order volume differences.


-- Q4. Cities contributing the most to total revenue

select 
       City,
	   ROUND(SUM(total_amount),2) as city_revenue
from fact_ord
group by City
order by city_revenue desc;

-- Insight: Istanbul (₹5.64M) leads, followed by Ankara and Izmir;
--			major cities drive revenue, lower-performing cities could use targeted campaigns.


-- Q5. Total discounts given and their impact on revenue

select
       Round(SUM(Discount_Amount),2) as total_discount,
	   Round(SUM(total_amount),2) as revenue_after_discount,
	   Round(SUM(total_amount  + discount_amount),2)as revenue_before_discount
from fact_ord ;

-- Insight: Total discounts ~₹1.19M, ~5% of potential revenue; helped drive customer purchase volume.


/* =====================================================
   SECTION 2: CUSTOMER BEHAVIOR & VALUE ANALYSIS
   Purpose: Understand customers, loyalty, and value
   ===================================================== */




-- Q6. What is the distribution of customers by gender and age group?

select 
	    Gender,
		case
			when Age<20 then 'Below 20'
			when Age between 20 and 29 then '20-29'
			when Age between 30 and 39 then '30-39'
			when Age between 40 and 49 then '40-49'
			when Age between 50 and 59 then '50-59'
			else 'Above 60' end as age_group,
			COUNT(distinct Customer_ID) as cust_count
			from fact_ord
			group by Gender,
		case
			when Age<20 then 'Below 20'
			when Age between 20 and 29 then '20-29'
			when Age between 30 and 39 then '30-39'
			when Age between 40 and 49 then '40-49'
			when Age between 50 and 59 then '50-59'
			else 'Above 60' end
			order by Gender,age_group; 

-- Insight: Most customers are male/female aged 30–39 (Female: 788, Male: 785), showing primary target segment.


-- Q7. How many customers are new versus returning customers?
select 
       Is_Returning_Customer,
	   COUNT(Customer_ID) AS CUST_COUNT 
	   from fact_ord
       GROUP BY Is_Returning_Customer;


-- Insight: ~88% returning customers (15,039) indicates strong customer loyalty, 
--			but total customers = 17,049, so returning customers are ~88%.


-- Q8. What is the customer retention rate based on returning customers?

-- Formula: returning customers / total unique customers * 100


SELECT
    ROUND(
        COUNT(DISTINCT CASE WHEN Is_Returning_Customer = 1 THEN Customer_ID END) * 100.0
        / COUNT(DISTINCT Customer_ID), 2
    ) AS [customer retention rate %]
FROM fact_ord;



-- Insight: Very high retention shows repeat purchases are main revenue driver.


-- Q9. What is the customer lifetime value (CLV) for each customer?

select 
       Customer_ID,
	   SUM(total_amount) 
	   as CLV from fact_ord

group by Customer_ID
order by CLV desc;

-- Insight: Top customers contribute ₹50K+ each; small group drives significant revenue.


-- Q10. Which customers are the top contributors to total revenue?


select top 10 
             Customer_ID,
			 sum(total_amount)
			 as Top_contributors from fact_ord

group by Customer_ID
order by Top_contributors desc;


-- Insight: CUST_01573 is the highest contributor (~₹50,628), followed by a few others each contributing ₹36K–47K,
--			highlighting a high-value customer segment that drives significant revenue.

/* =====================================================
   SECTION 3: ENGAGEMENT, OPERATIONS & EXPERIENCE
   Purpose: Analyze user behavior, delivery, and satisfaction
   ===================================================== */


-- Q11. How does device type (Mobile, Desktop, Tablet) impact revenue and orders?

select 
		Device_Type,
		ROUND(SUM(total_amount),2) as revenue ,
		COUNT(ORDER_ID) as orders from fact_ord

group by Device_Type
order by revenue desc,
		 orders desc;


-- Insight: Mobile drives the majority of revenue (~₹12.03M) and orders (9,543),
--			making mobile optimization crucial for growth, while desktop (~₹7.66M, 5,845 orders) and
--			tablet (~₹2.09M, 1,661 orders) contribute less


-- Q12. What is the relationship between session duration and total revenue?


select
    case
        when session_duration_minutes < 5 then '<5 min'
        when session_duration_minutes between 5 and 10 then '5–10 min'
        when session_duration_minutes between 11 and 15 then '11–15 min'
        when session_duration_minutes between 16 and 20 then '16–20 min'
        else '20+ min'
    end as session_bucket,
    Round(SUM(total_amount),2) as total_revenue
from fact_ord
group by
    case
        when session_duration_minutes < 5 then '<5 min'
        when session_duration_minutes between 5 and 10 then '5–10 min'
        when session_duration_minutes between 11 and 15 then '11–15 min'
        when session_duration_minutes between 16 and 20 then '16–20 min'
        else '20+ min'
    end
order by total_revenue desc;


-- Insight: 11–15 min sessions generate highest revenue (~₹12.08M);
--			very short and very long sessions contribute little.


-- Q13. How does the number of pages viewed affect order value?


with pages_group as (
    select 
        case
             when pages_viewed between 1 and 5 then '1-5'
             when pages_viewed between 6 and 10 then '6-10'
             when pages_viewed between 11 and 15 then '11-15'
             else '15+' 
        end as pages_views,
        order_id,
        total_amount
    from fact_ord
)
select 
    pages_views,
    COUNT(order_id) as orders,
    ROUND(SUM(total_amount),2) as total_revenue,
    ROUND(SUM(total_amount)/COUNT(order_id),2) as avg_order_value
from pages_group
group by pages_views
order by orders desc;


-- Insight: 6–15 page views drive most orders with high avg. order value (~₹1,272–₹1,304);
--			very high page views (15+) are few but show highest AOV (~₹1,570).



-- Q14. How does delivery time impact customer ratings?

select 
		Delivery_Time_Days,
		Customer_Rating from fact_ord;



-- Insight: Orders delivered in 2–5 days generally receive higher ratings (4–5), boosting customer satisfaction.


-- Q15. Which high-revenue orders received low customer ratings (potential risk cases)?


select top 10              -- we can adjust here
    order_id,
    total_amount as revenue,
    customer_rating
from fact_ord
where customer_rating <= 2   -- we can adjust here
order by total_amount desc;


-- Insight: Some very high-value orders (>₹16K) got low ratings (≤2), indicating potential product or delivery issues.

------------------------------------------------------------
/* =====================================================
   END OF SQL ANALYSIS
   =====================================================


   -- Summary Insights

-- 1. Electronics & Home/Garden drive revenue; Sports & Beauty lead orders.
-- 2. Top 10 customers contribute disproportionally; focus retention (e.g., CUST_01573 ~₹50.6K).
-- 3. Returning customers (~88%) generate majority of revenue.
-- 4. Mobile dominates revenue (~₹12M) and orders (9,543); optimize mobile UX.
-- 5. Mid-late 2023 revenue peaks; plan seasonal promotions.
-- 6. Sessions 11–15 min & 6–15 page views → higher avg order value (~₹1,271–₹1,304).
-- 7. Delivery 2–5 days → higher ratings (4–5); speed improves satisfaction.
-- 8. Some high-value orders (>₹16K) have low ratings (≤2); review operations/products.
-- 9. Low engagement (<5 min/<6 pages) → minimal revenue; moderate engagement drives value.
-- 10. Focus: top customer retention, mobile UX, delivery speed, high-value order issues.

*/
