-- creating database 'ecom'

create database ecom;
show databases;
use ecom;

-- creating table customer_data

create table customer_data(
		ID int,Year_Birth year,Education varchar(15),Marital_Status varchar(15),
        Income int,Kidhome tinyint ,Teenhome tinyint,Dt_Customer date,
        Recency	tinyint,MntWines smallint,MntFruits smallint,MntMeatProducts smallint,
        MntFishProducts smallint,MntSweetProducts smallint,MntGoldProds smallint,	
        NumDealsPurchases tinyint,NumWebPurchases tinyint,NumCatalogPurchases tinyint,
        NumStorePurchases tinyint,NumWebVisitsMonth tinyint,AcceptedCmp3 tinyint,AcceptedCmp4 tinyint,
        AcceptedCmp5 tinyint,AcceptedCmp1 tinyint,AcceptedCmp2 tinyint,Complain tinyint,
        Z_CostContact tinyint,Z_Revenue tinyint,Response tinyint
        );        
        
show tables;
desc customer_data;
SELECT * FROM customer_data ;

-- ------
# 1. Count the total number of customers in the dataset
SELECT count(ID) AS total_customers from customer_data;

# 2. Find the average income:
SELECT AVG(Income) FROM customer_data;

# 3. List customers with income above $50,000:
SELECT ID, Income FROM customer_data WHERE income > 50000 ORDER BY ID ASC;

# 4. Find customers with more than 3 web visits per month:
SELECT ID, NumWebVisitsMonth FROM customer_data WHERE NumWebVisitsMonth > 3 ORDER BY ID;

# 5. List customers who have accepted at least one campaign:

-- USING WHERE Clause
SELECT ID FROM customer_data 
WHERE AcceptedCmp1 = 1 OR AcceptedCmp2 = 1 OR AcceptedCmp3 = 1 OR
      AcceptedCmp4 = 1 OR AcceptedCmp5 = 1 ORDER BY ID;

-- USING SUBQUERY
SELECT ID 
FROM customer_data
WHERE 1 IN (AcceptedCmp1, AcceptedCmp2, AcceptedCmp3, AcceptedCmp4, AcceptedCmp5)
ORDER BY ID;

-- USING GREATEST
SELECT ID 
FROM customer_data
WHERE  GREATEST(AcceptedCmp1, AcceptedCmp2, AcceptedCmp3, AcceptedCmp4, AcceptedCmp5)=1
ORDER BY ID;

-- USING CASE Statement
SELECT ID
FROM customer_data
WHERE (CASE
			WHEN AcceptedCmp1 = 1 THEN 1
            WHEN AcceptedCmp2 = 1 THEN 1
            WHEN AcceptedCmp3 = 1 THEN 1
            WHEN AcceptedCmp4 = 1 THEN 1
            WHEN AcceptedCmp5 = 1 THEN 1
		END ) = 1
ORDER BY ID;


# 6. Count customers with complaints:
SELECT COUNT(ID) AS count_of_cust_who_complaints
FROM customer_data WHERE Complain= 1;
        
# 7. Calculate total amount spent on wines:
SELECT SUM(MntWines) AS total_amt_spent_on_wines FROM customer_data;

# 8. Find customers with no children at home (customers who do not have any kids or teenagers at home.):
SELECT ID FROM customer_data WHERE Kidhome=0 AND Teenhome=0 ORDER BY ID; 

# 9. Determine the average age of customers:
SELECT ROUND(AVG((YEAR(NOW()) - Year_Birth)),0) AS average_age FROM customer_data;
SELECT AVG(2024 - Year_Birth) AS average_age FROM customer_data;

# 10. List customers by marital status(Group customers by their marital status and count the number of customers in each group).
SELECT Marital_Status, COUNT(ID) AS cnt_of_cust FROM customer_data GROUP BY Marital_Status ORDER BY COUNT(ID) DESC;

# 11. Find the most recent customer:
-- using subquery
SELECT ID, Dt_Customer FROM customer_data WHERE Dt_Customer= (SELECT MAX(Dt_Customer) FROM customer_data);

-- using cte and window function
with cte as (
select id, dt_customer , dense_rank() over(order by dt_customer desc) as rn from customer_data )
select * from cte where rn=1;

# 12. Calculate the total amount spent on each product category( (Wines,Fruits, Meat, Fish, Sweets, Gold).
SELECT  SUM(MntWines) AS total_spent_on_wines,
		SUM(MntFruits) AS total_spent_on_fruits,
        SUM(MntMeatProducts) AS total_spent_on_meat_prod,
        SUM(MntFishProducts) AS total_spent_on_fish_prod,
        SUM(MntSweetProducts) AS total_spent_on_sweet_prod, 
		SUM(MntGoldProds) AS total_spent_on_gold_prod
FROM customer_data; 

# 13. Find the average number of web visits for each customer:
SELECT ID, ROUND(AVG(NumWebVisitsMonth),0) AS average_web_visits FROM customer_data GROUP BY ID;

# 14. Identify high-value customers:List customers who have spent more than $2,000 in total.
WITH TotalAmount AS (
			SELECT ID , 
            (MntWines + MntFruits + MntMeatProducts + MntFishProducts + MntSweetProducts + MntGoldProds )  AS total_spent
			FROM customer_data ORDER BY ID
            )
SELECT * FROM TotalAmount WHERE total_spent > 2000;

# 15. List top 5 customers by wine purchases: 
SELECT ID AS top_5_cust_by_wine_purchase, MntWines AS amount FROM customer_data ORDER BY MntWines DESC limit 5;

# 16. Find the most common education level:
SELECT Education, COUNT(ID) AS total_cust FROM customer_data GROUP BY Education ORDER BY COUNT(ID) DESC LIMIT 1;
 
# 17. Identify customers with high recency:(Recency < 30 days).
SELECT ID AS cust_with_hight_recency FROM customer_data WHERE Recency < 30 ORDER BY ID;

# 18.Calculate the average number of accepted campaigns per customer: .
WITH TotalCamp AS (
	SELECT ID,
		(
		coalesce(AcceptedCmp1,0) +
		coalesce(AcceptedCmp2,0) +
		coalesce(AcceptedCmp3,0) +
		coalesce(AcceptedCmp4,0) +
		coalesce(AcceptedCmp5,0) 
		) AS cnt_camp
	FROM customer_data 
  )
SELECT ID, CEIL(AVG(cnt_camp)) AS avg_campaign
FROM TotalCamp
GROUP BY ID
ORDER BY ID;

# 19. Find customers with the highest total purchases:
WITH TotalPurchase AS (
	SELECT ID,
      ( 
		COALESCE(NumDealsPurchases,0) +
		COALESCE(NumWebPurchases,0) +
		COALESCE(NumCatalogPurchases,0) +
		COALESCE(NumStorePurchases,0) 
	  ) AS ttl_pur
    FROM customer_data
)
SELECT * FROM TotalPurchase
ORDER BY ttl_pur DESC
LIMIT 5;

# 20. List customers by their response to the last campaign:Group customers based on their response to the last campaign.
SELECT CASE 
		WHEN Response=1 THEN 'Accepted'
        ELSE 'Not Accepted'
        END AS Response
, COUNT(ID) 
FROM customer_data GROUP BY Response;