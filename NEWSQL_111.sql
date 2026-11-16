---Q1. Total revenue: male vs. female customers
select 
  gender,
  SUM(purchase_amount) as Total_revenue
from cus_bav_A
group by gender;

--Q2. Customers who used a discount but still spent more than the average purchase amount
SELECT
   customer_id,
   discount_applied,
   purchase_amount
from cus_bav_A
where discount_applied = 'Yes'
and purchase_amount >(SELECT avg(purchase_amount)
   from cus_bav_A
);


--Q3. Top 5 products by average review rating
select 
  item_purchased,
  avg(Review_Rating) as average_ratings
from cus_bav_A
  group by  item_purchased
  order by  Review_Rating DESC
  limit 5;
  
--Q4. Average purchase amount: Standard vs. Express shipping
SELECT
  shipping_type,
  avg(purchase_amount) as average_purchase_amount
from cus_bav_A
   where shipping_type in ('Standard' , 'Express')
group by shipping_type;

--Q5. Subscribers vs. non-subscribers: average spend and total revenue
SELECT
  subscription_sta,
    avg(purchase_amount) as average_spend,
    sum(purchase_amount) as Total_revenue
from cus_bav_A
group by  subscription_sta;


--Q6. Top 5 products with the highest % of purchases with discounts
SELECT "Item_Purchased",
       ROUND(100.0 * SUM(CASE WHEN "Discount_Applied" = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS discount_percentage
FROM cus_bav_A
GROUP BY "Item_Purchased"
ORDER BY discount_percentage DESC
LIMIT 5;


--Q7. Customer segments: New, Returning, Loyal
SELECT
  CASE
    when previous_purchas <=1 then 'New'
    when previous_purchas <=5 then 'Returning'
    else 'loyal'
  end as customer_segment,
    count(*) as total_customers
from cus_bav_A
group by customer_segment;
  

--Q8. Top 3 most purchased products within each category
WITH item_counts AS (
    SELECT Category, "Item_Purchased",
           COUNT("Customer_ID") AS total_orders,
           ROW_NUMBER() OVER (PARTITION BY Category ORDER BY COUNT("Customer_ID") DESC) AS item_rank
    FROM   cus_bav_A
    GROUP BY Category, "Item_Purchased"
)
SELECT item_rank, Category, "Item_Purchased", total_orders
FROM item_counts
WHERE item_rank <= 3;


--Q9. Are repeat buyers (more than 5 previous purchases) also likely to subscribe?
SELECT CASE WHEN "Previous_Purchas" > 5 THEN 'Repeat buyer (>5)' ELSE 'Not repeat (<=5)' END AS buyer_type,
       COUNT(*) AS customers,
       SUM(CASE WHEN "Subscription_Sta" = 'Yes' THEN 1 ELSE 0 END) AS subscribers,
       ROUND(100.0 * SUM(CASE WHEN "Subscription_Sta" = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS subscription_rate_pct
FROM cus_bav_A
GROUP BY buyer_type;

--Q10. Revenue contribution of each age group
SELECT CASE
           WHEN Age <= 25 THEN '18-25'
           WHEN Age <= 35 THEN '26-35'
           WHEN Age <= 45 THEN '36-45'
           WHEN Age <= 55 THEN '46-55'
           ELSE '56+'
       END AS age_group,
       SUM("Purchase_Amount") AS total_revenue,
       ROUND(100.0 * SUM("Purchase_Amount") / (SELECT SUM("Purchase_Amount") FROM  cus_bav_A), 2) AS revenue_pct
FROM  cus_bav_A
GROUP BY age_group
ORDER BY age_group;