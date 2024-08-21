/*

-----------------------------------------------------------------------------------------------------------------------------------
													    Guidelines
-----------------------------------------------------------------------------------------------------------------------------------

The provided document is a guide for the project. Follow the instructions and take the necessary steps to finish
the project in the SQL file			

-----------------------------------------------------------------------------------------------------------------------------------
                                                         Queries
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/
  
/*-- QUESTIONS RELATED TO CUSTOMERS
     [Q1] What is the distribution of customers across states?
     Hint: For each state, count the number of customers.*/
    use wheels; 
     select count(customer_id) as distribution_of_customers , state
     from customer_t
     group by state 
     order by distribution_of_customers desc
     


-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q2] What is the average rating in each quarter?
-- Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.

Hint: Use a common table expression and in that CTE, assign numbers to the different customer ratings. 
      Now average the feedback for each quarter. 

Note: For reference, refer to question number 4. Week-2: mls_week-2_gl-beats_solution-1.sql. 
      You'll get an overview of how to use common table expressions from this question.*/

with feedbackCTE as (
select 
quarter_number, 
case 
when customer_feedback = 'very good' then '5'
when customer_feedback = 'good' then '4'
when customer_feedback = 'okay' then '3'
when customer_feedback = 'bad' then '2'
when customer_feedback = 'very bad' then  '1'
end as rating
from order_t 
)
select quarter_number,
round(AVG(rating),2) as average_customer_rating
from feedbackCTE
group by quarter_number
order by quarter_number;



-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q3] Are customers getting more dissatisfied over time?

Hint: Need the percentage of different types of customer feedback in each quarter. Use a common table expression and
	  determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter.
	  Now use that common table expression to find out the percentage of different types of customer feedback in each quarter.
      Eg: (total number of very good feedback/total customer feedback)* 100 gives you the percentage of very good feedback.
      
Note: For reference, refer to question number 4. Week-2: mls_week-2_gl-beats_solution-1.sql. 
      You'll get an overview of how to use common table expressions from this question.*/
WITH feedback AS (
    SELECT 
        quarter_number, 
        SUM(CASE WHEN customer_feedback = 'very bad' THEN 1 ELSE 0 END) AS very_bad, 
        SUM(CASE WHEN customer_feedback = 'bad' THEN 1 ELSE 0 END) AS bad, 
        SUM(CASE WHEN customer_feedback = 'okay' THEN 1 ELSE 0 END) AS okay, 
        SUM(CASE WHEN customer_feedback = 'good' THEN 1 ELSE 0 END) AS good, 
        SUM(CASE WHEN customer_feedback = 'very good' THEN 1 ELSE 0 END) AS very_good, 
        COUNT(customer_feedback) AS total_feedback 
    FROM 
        order_t 
    GROUP BY 
        quarter_number
)
SELECT 
    quarter_number, 
    ROUND(very_bad / total_feedback * 100, 2) AS Percentage_very_bad,  
    ROUND(bad / total_feedback * 100, 2) AS Percentage_bad, 
    ROUND(okay / total_feedback * 100, 2) AS Percentage_okay, 
    ROUND(good / total_feedback * 100, 2) AS Percentage_good, 
    ROUND(very_good / total_feedback * 100, 2) AS Percentage_very_good 
FROM 
    feedback 
ORDER BY 
    quarter_number;

- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q4] Which are the top 5 vehicle makers preferred by the customer.

Hint: For each vehicle make what is the count of the customers.*/

select p.vehicle_maker, count(customer_id)
from product_t p
join order_t o on o.product_id = p.product_id
group by p.vehicle_maker
order by count(customer_id) desc
limit 5
-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q5] What is the most preferred vehicle make in each state?

Hint: Use the window function RANK() to rank based on the count of customers for each state and vehicle maker. 
After ranking, take the vehicle maker whose rank is 1.*/

select c.state, p.vehicle_maker,
count(c.customer_id)  as count_of_customers , 
Rank() over (partition by state order by count(c.customer_id) desc) as Rank_value
from order_t o
join product_t p on p.product_id = o.product_id
join customer_t c on c.customer_id = o.customer_id
group by  c.state, p.vehicle_maker
order by Rank_value ;

-- ---------------------------------------------------------------------------------------------------------------------------------

/*QUESTIONS RELATED TO REVENUE and ORDERS 

-- [Q6] What is the trend of number of orders by quarters?

Hint: Count the number of orders for each quarter.*/

select quarter_number, count(order_id) as no_of_orders
from order_t
group by quarter_number
order by no_of_orders desc


-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q7] What is the quarter over quarter % change in revenue? 

Hint: Quarter over Quarter percentage change in revenue means what is the change in revenue from the subsequent quarter to the previous quarter in percentage.
      To calculate you need to use the common table expression to find out the sum of revenue for each quarter.
      Then use that CTE along with the LAG function to calculate the QoQ percentage change in revenue.
*/
with quarterly_revenue as
 (
select quarter_number, 
ROUND(sum(vehicle_price - (discount/100) * vehicle_price),2) as revenue
from order_t
group by quarter_number
)
select 
quarter_number, 
revenue,
LAG(revenue) over (order by quarter_number) as previous_quarter_revenue,
ROUND(
    (
        (revenue - LAG(revenue) OVER (ORDER BY quarter_number)) 
        / LAG(revenue) OVER (ORDER BY quarter_number)
    ) * 100, 
    2
) 
AS percentage_change_in_revenue
from quarterly_revenue ;

      
      

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q8] What is the trend of revenue and orders by quarters?

Hint: Find out the sum of revenue and count the number of orders for each quarter.*/

select quarter_number , count(order_id) as no_of_orders ,
ROUND(SUM(vehicle_price - (discount / 100) * vehicle_price), 2) as revenue
from order_t
group by quarter_number
order by quarter_number


-- ---------------------------------------------------------------------------------------------------------------------------------

/* QUESTIONS RELATED TO SHIPPING 
    [Q9] What is the average discount offered for different types of credit cards?

Hint: Find out the average of discount for each credit card type.*/

select c.credit_card_type, 
ROUND(
avg(discount/100 *o.vehicle_price),2) as average_discount 
from order_t o
join customer_t c on c.customer_id = o.customer_id
group by c.credit_card_type
order by c.credit_card_type;







-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q10] What is the average time taken to ship the placed orders for each quarters?
	Hint: Use the dateiff function to find the difference between the ship date and the order date.
*/
select quarter_number,
round(avg(datediff(ship_date, order_date)),2) as average_time
from order_t
group by quarter_number
order by quarter_number

-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------



