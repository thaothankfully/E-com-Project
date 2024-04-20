select * from ecom.dbo.customer_details
---Avg age of all customers:
select round(avg(age),0) as Average_age
from ecom.dbo.customer_details 
---Gender distribution:
select (select count(gender)from ecom.dbo.customer_details where gender = 'Male')*100 /count(gender)
as Male_percentage
from ecom.dbo.customer_details;
select (select count(gender)from ecom.dbo.customer_details where gender = 'Female')*100 /count(gender)
as Female_percentage
from ecom.dbo.customer_details;
---Types of items purchased:
select Item_Purchased,count(Item_Purchased) as Type_items_purchased
from ecom.dbo.customer_details
group by Item_Purchased
order by Type_items_purchased desc
---Most purchased category:
select category, count(category) as Ranking_most_purchased_category
from ecom.dbo.customer_details
group by category
order by Ranking_most_purchased_category desc
---Avg purchased amount:
select Category, round(avg(Purchase_Amount),2) as Avg_purchase_amount
from ecom.dbo.customer_details
group by category
---Most common location:
SELECT TOP 5 Location, COUNT(Location) as Most_common_location
FROM ecom.dbo.customer_details
GROUP BY Location
ORDER BY Most_common_location desc
---Distribution of size among women:
SELECT
	SUM(CASE WHEN Size = 'L' THEN 1 END)*100.0/COUNT(*) AS [%_of_size_L],
	SUM(CASE WHEN Size = 'M' THEN 1 END)*100.0/COUNT(*) AS [%_of_size_M],
	SUM(CASE WHEN Size = 'S' THEN 1 END)*100.0/COUNT(*) AS [%_of_size_S],
	SUM(CASE WHEN Size= 'XL' THEN 1 END)*100.0/COUNT(*) AS [%_of_size_XL]
FROM ecom.dbo.customer_details
WHERE Gender = 'Female'
---
SELECT
	TOP 5 Color, COUNT(Color) AS Most_common_color 
FROM ecom.dbo.customer_details
GROUP BY Color
---++where category is clothing, find out the top selling color in accordance with each season
SELECT Season, Color, COUNT(Color) as Top_selling_color
FROM ecom.dbo.customer_details
WHERE Category = 'Clothing'
GROUP BY Season, Color
ORDER BY Season, Top_selling_color DESC
		-------------------------------using subquery
select Season, Color, Top_selling_color
from (select Season, Color, COUNT(Color) as Top_selling_color,
	row_number() over (partition by Season order by COUNT(Color) desc) as ranking
	from ecom.dbo.customer_details
	where category ='Clothing'
	group by Season, Color) as subs
	where ranking = 1
	---------------------using CTE:
with subs as
(select Season, Color, COUNT(Color) as Top_selling_color,
	row_number() over (partition by Season order by COUNT(Color) desc) as ranking
	from ecom.dbo.customer_details
	where category ='Clothing'
	group by Season, Color)
select Season, Color, Top_selling_color from subs
where ranking = 1

----++avg review_rating of each category:
select category, round(avg(review_rating),2) as Average_rating
from ecom.dbo.customer_details
group by category
---++highest avg review_rating of each category in each Location
with subs as
	(select Category, Location, avg(Review_Rating) as Average_rating, 
	ROW_NUMBER() over(partition by Location order by avg(Review_Rating))as ranking
	from ecom.dbo.customer_details
	where Category = 'Footwear'
	group by Category, Location)
select Location, round(Average_rating,2) as Avg_review_rating
from subs
where ranking = 1
---++ % of women having subs status
SELECT 
	SUM( CASE WHEN Subscription_Status = 'No' THEN 1 END)*100/COUNT(*) AS [%_women_having_subs]
FROM ecom.dbo.customer_details
WHERE Gender = 'Female'
---++ list of locations have more men subs than woman
SELECT Location, 
	CASE 
		WHEN Subscription_Status = 'Yes' AND Gender = 'Male' THEN 'Men_with_subs'
		WHEN Subscription_Status = 'Yes' AND Gender = 'Female' THEN 'Female_with_subs'
		 ELSE 'Other'
	END AS a
FROM ecom.dbo.customer_details
GROUP BY Location
HAVING SUM(Subscription_Status = 'Yes' AND Gender = 'Male') > SUM(Subscription_Status = 'Yes' AND Gender = 'Female')

SELECT Location
FROM ecom.dbo.customer_details
WHERE Subscription_Status = 'Yes'
GROUP BY Location
HAVING SUM(CASE WHEN Gender = 'Male' THEN 1 ELSE 0 END) > SUM(CASE WHEN Gender = 'Female' THEN 1 ELSE 0 END);

---++ avg purchase amount of people who subs compared with ppl dont
SELECT 
    AVG(CASE WHEN Subscription_Status = 'Yes' THEN Purchase_Amount ELSE NULL END) AS a,
    AVG(CASE WHEN Subscription_Status = 'No' THEN Purchase_Amount ELSE NULL END) AS b
FROM ecom.dbo.customer_details;

---++ avg age of people who subs
SELECT ROUND(AVG(Age),0) as Average_age
FROM ecom.dbo.customer_details
WHERE Subscription_Status = 'Yes'
---++ most common shipping type per location
with subs as
(SELECT Location, Shipping_Type,
	ROW_NUMBER() OVER (PARTITION BY Location ORDER BY COUNT(Shipping_Type)) as ranking
FROM ecom.dbo.customer_details
GROUP BY Location, Shipping_Type)
SELECT Location, Shipping_Type as Most_common_shipping_type
FROM subs
WHERE ranking = 1
---++ do women apply discount more than men?
SELECT
	SUM(CASE WHEN Discount_Applied = 'Yes' AND Gender = 'Female' THEN 1 END) as Number_of_women_apply_discount,
	SUM(CASE WHEN Discount_Applied = 'Yes' AND Gender = 'Male' THEN 1 END) as Number_of_men_apply_discount
FROM ecom.dbo.customer_details
---++ do woman use promo code more than men?
SELECT 
	SUM(CASE WHEN Gender = 'Male' AND Promo_Code_Used = 'Yes' THEN 1 END) As Number_of_men_use_promo_code,
	SUM(CASE WHEN Gender = 'Female' AND Promo_Code_Used = 'Yes' THEN 1 END) As Number_of_women_use_promo_code
FROM ecom.dbo.customer_details
---++ most commom payment method per locatiom
With subs as
	(SELECT Location, Payment_Method,
	ROW_NUMBER () OVER(PARTITION BY Location ORDER BY COUNT(Payment_Method)) AS ranking
	FROM ecom.dbo.customer_details
	GROUP BY Location, Payment_Method)
SELECT Location, Payment_Method
FROM subs
WHERE ranking = 1
---++ most common frequency of purchase per gender, category
 
