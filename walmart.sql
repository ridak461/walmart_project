select *from walmart;
drop table walmart
--
select count(*)from walmart;
select *
from
(select 
     payment_method,
	 category,
	 count(*)
     from walmart 
	 group by payment_method, category
)
where count>1000
	 
select count(distinct Branch )
     from walmart ;
select Max (quantity) from walmart ;

----- Business problems 
--Q.1 Find different payment method and number of transactions ,number of qty sold
select 
     payment_method,
	 count(*)as no_payments ,
	 sum(quantity) as no_qty_sold
     from walmart 
	 group by payment_method

---Q.2
---Identify the highest-rated category in each branch, displaying the branch, category
---Avg rating 
select*
from
(select    
       branch,
	   category,
	   Avg(rating) as avg_rating,
	   rank() over(partition by branch order by avg(rating) DESC) as rank
from walmart
group by 1,2
)
where rank = 1

---Q.3  Identify the busiest day for each branch on the number of transactions
select *from walmart 
--our date is in the Text form so first convert it 
select 
date,
TO_CHAR(to_date(date, 'DD/MM/YY'), 'day' )AS day_name
from walmart 
---
select*
from
(select 
     branch,
     TO_CHAR(to_date(date, 'DD/MM/YY'), 'day' )AS day_name,
     count(*) as no_transactions,
     rank() over(partition by branch order by count(*) DESC) as rank
from walmart 
group by 1,2	
)
where rank=1


---- Q.4 
--calculate the total quantity of items sold per payment_method.list paymont method and total quantity 

select 
     payment_method,
	 sum(quantity) as no_qty_sold
	 from walmart 
	 group by payment_method


----Q.5 DEtermine the average,minimum and maximum rating of category for each city.
     ---list the city, avaerage_rating,min_rating, and max_rating
	 select 
	       city,
		   category,
		   min(rating) as min_rating,
		   max(rating) as max_rating,
		   avg(rating) as avg_rating
		   
		  from walmart
           group by 1, 2
---- Q.6 
---Calculate the total profit for each category by considering total_profit as 
---unit_price quantity, profit_margin.  
---list category and total_profit,ordered from highest to lowest profit.
       select 
	   category,
	   sum(total) as total_revenue,
	   sum(total* profit_margin) as profit
	   from walmart 
	   group by 1


---Q.7 
---Determine the most common payment method for each Branch.
---Display Branch and the preferred_payment_method.
   with cte
   as
   (select
         branch,
		 payment_method,
		 count(*) as total_trans,
		 rank() over(partition by branch order by count(*) DESC) as rank
		  from walmart
		 group by 1,2 
)
select *from cte
where rank= 1


---Q.8  
---Categorize sales into 3 group Morning, Afternoon, Evening
---Find out which of the shift and number of invoices
  select 
  branch,
  case 
  when Extract (hour from (time::time))< 12 then 'Morning'
  when extract (hour from (time::time)) between 12 and 17 then 'Afternoon'
  else 'Evening'
  End day_time,
  count(*)
  from walmart
  group by 1,2
  order by 1,3 desc

---Q.9 
--- Identify 5 branch with the highest Decrease ratio in 
---Revenue comapre to last year (current year 2023 and last year 2022)
 select*,
 extract(year from to_date(date, 'DD/MM/YY'))as formated_date 
from walmart
---rdr== last_rev-cr_rev/ls_rev*100
---2022 sales
with revenue_2022
as
(
   select 
    branch, 
    sum(total) as revenue 
    from walmart
    where extract(year from to_date(date, 'DD/MM/YY')) =2022
    group by 1
),
revenue_2023
as
(
    select 
        branch, 
        sum(total) as revenue 
    from walmart
    where extract(year from to_date(date, 'DD/MM/YY')) =2023
     group by 1
)
select
    ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as cr_year_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/
		ls.revenue::numeric * 100, 
		2) as rev_dec_ratio
from revenue_2022 as  ls
join
revenue_2023 as cs
on ls.branch = cs.branch
WHERE 
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5