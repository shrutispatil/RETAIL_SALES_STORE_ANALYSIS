sales store
PROJECT_1_SQL 

Query 1
Create database project1_sales_store
Query 2
create table sales_store(
transaction_id text,
customer_id	text,
customer_name text,
customer_age text,
gender	text,
product_id text,
product_name text,
product_category text,
quantiy	text,
prce text,
payment_mode text,
purchase_date text,
time_of_purchase text,
status text
);
Query3—import csv file/data--
copy sales_store(transaction_id,	
customer_id, customer_name, customer_age,
gender,	product_id, product_name, product_category,	
quantiy, prce, payment_mode, purchase_date, time_of_purchase, status
)
from 'G:\SQL\project1_sales_store.csv'
delimiter ','
csv header;
Query4—change data type text to int, varchar etc—
alter table sales_store
alter column customer_age type integer
using customer_age:: integer

*****************************************************************************
alter table sales_store
alter column customer_name type varchar(80)
*****************************************************************************
alter table sales_store
alter column customer_id type varchar
*****************************************************************************
alter table sales_store
alter column transaction_id type varchar
*****************************************************************************
alter table sales_store
alter column gender type varchar
*****************************************************************************
alter table sales_store
alter column product_id type varchar
*****************************************************************************
alter table sales_store
alter column product_name type varchar
*****************************************************************************
alter table sales_store
alter column product_category type varchar
*****************************************************************************
alter table sales_store
alter column quantiy type integer
using quantiy:: integer;
*****************************************************************************
alter table sales_store
alter column prce type float
using prce:: float;
*****************************************************************************
alter table sales_store
alter column payment_mode type varchar(80)
*****************************************************************************
alter table sales_store
alter column purchase_date type date
using purchase_date:: date;
*****************************************************************************
alter table sales_store
alter column time_of_purchase type time
using time_of_purchase:: time;
*****************************************************************************
alter table sales_store
alter column status type varchar(80)

Query5– make copy of data set—
select * from sales_store     –original table—
--duplicate/copy--
select * into sales_store_copy from sales_store
select * from sales_store_copy

Query6–data cleaning steps—
--step 1--check duplicates and delete duplicates--
 select transaction_id , count(*)
 from sales_store_copy
 group by transaction_id
 having count(transaction_id)>1

--'TXN855235'
--'TXN240646'
--'TXN342128'
--'TXN981773'

--anotgher detailed way-
begin;
with mycte as (select *, ctid,
row_number() over(partition by transaction_id order by transaction_id) as rownum
from sales_store_copy)

delete from sales_store_copy as c
using mycte
where c.ctid=mycte.ctid
and mycte.rownum>1;

-- select * from mycte
-- where rownum>1


--step 2--correction of headings--wrong spelled--
alter table sales_store_copy
rename column quantiy to quantity

alter table sales_store_copy
rename column prce to price

--step 3--to check data type--
select column_name, data_type
from information_schema.columns
where table_name='sales_store_copy'

--step 4--to check nulls and treat nulls--
select * from sales_store_copy
where transaction_id is null
or customer_id is null
or customer_name is null
or customer_age is null
or gender is null
or product_id is null
or product_name is null
or product_category is null
or quantity is null
or price is null
or payment_mode is null
or purchase_date is null
or time_of_purchase is null
or status is null

--transaction_id--
begin;
delete from sales_store_copy
where transaction_id is null
rollback;
commit;

--customer_id--
select * from sales_store_copy
where customer_name = 'Ehsaan Ram'

update sales_store_copy
set customer_id= 'CUST9494'
where transaction_id= 'TXN977900'
-- ***************************************************************
select * from sales_store_copy
where customer_name= 'Damini Raju'

update sales_store_copy
set customer_id='CUST1401'
where transaction_id='TXN985663'


--customer_name--
select * from sales_store_copy
where customer_id= 'CUST1003'

update sales_store_copy
set customer_name='Mahika Saini', customer_age=35, gender='Male'
where transaction_id='TXN432798'


--step 5--data cleaning--
select distinct gender
from sales_store_copy

update sales_store_copy
set gender= 'M'
where gender='Male'

update sales_store_copy
set gender='F'
where gender='Female'
-- **************************************************************

select distinct product_name
from sales_store_copy
--***************************************************************
select distinct payment_mode
from sales_store_copy

update sales_store_copy
set payment_mode= 'Credit Card'
where payment_mode='CC'

Query7--solving business insights questions--
--data analysis--
--q1 top 5 most selliing products by quantity—
-- business problem= which products are most in demand--
--impact= helps prioritize stock and boost sales through targeted promotions--
select distinct status
from sales_store_copy

select product_name, sum(quantity)as total_quantity
from sales_store_copy
where status='delivered'
group by product_name
order by total_quantity desc
limit 5

--q2 which products are frequently cancelled--
--business problem= frequently cancellations affect revenue and cust trust--
--impact=identify poor-performing product to improve quality or remove from catlog--
select product_name, count(status) as freq_cancelled
from sales_store_copy
where status ='cancelled'
group by product_name
order by freq_cancelled desc
limit 5

--q3 what time of the day has the highest no of purchaces--
--business problem= find pick sales time--
--impact=optimize staffing, promotions and server loads --
select 
	case
	when extract(hour from time_of_purchase) between 0 and 5 then 'Night'
	when extract(hour from time_of_purchase) between 6 and 12 then 'Morning'
	when extract(hour from time_of_purchase) between 12 and 17 then 'Afternoon'
	when extract(hour from time_of_purchase) between 17 and 24 then 'Evening'
	end as time_of_day,
	count(*) as total_order
	from sales_store_copy
	group by 
		case
	when extract(hour from time_of_purchase) between 0 and 5 then 'Night'
	when extract(hour from time_of_purchase) between 6 and 12 then 'Morning'
	when extract(hour from time_of_purchase) between 12 and 17 then 'Afternoon'
	when extract(hour from time_of_purchase) between 17 and 24 then 'Evening'
		end 
		order by total_order desc


--q4 top 5 highest spending customer--
--business problem= identify VIP cust--
--impact= personalized offeres, loyalty rewards and retention--
select customer_id, customer_name, 
'$'||to_char(sum(price*quantity),'999,99,99,999')as highest_spent
from sales_store_copy
where status= 'delivered'
group by customer_id, customer_name
order by highest_spent desc
limit 5

--q5 highest revenue generating product_category--
--business problem=identify top performing category--
--impact= refine product strategy, supply chain and promotions,allows bsiness to invest more in specific categories --
select product_category, 
'$'||to_char(sum(price*quantity), '999,99,99,999') as highest_revenue
from sales_store_copy
group by product_category
order by highest_revenue desc

--q6 what is the returned/cancellation rate per preoduct category --
----business problem=monitor disatisfaction trend per category
--impact= reduce returns, improve product discriptions/expectations,helps identify and fix product issues--
select product_category,
 round(count(case when status='returned' then 1 end)*100.0/count(*), 2)|| '%'as r_rate
from sales_store_copy
group by product_category
order by r_rate desc
****************************************************

select product_category,
round(count(case when status='cancelled' then 1 end)*100.0/count(*), 2) || '%'as c_rate
from sales_store_copy
group by product_category
order by c_rate desc


--q7most preferred payment mode --
----business problem= which payment option customer preffer
--impact= stremline payment processing, prioterize payment mode --
select payment_mode,count(payment_mode) AS pmode
from sales_store_copy
group by payment_mode
order by pmode desc


--q8 how does age group affect business behaviour--
----business problem= understand cust demographics/understand most spoending age group
--impact=target that group to generate revenue--
select max(customer_age), min(customer_age) 
from sales_store_copy

select 
case
when customer_age between 18 and 25 then 'teenagers'
when customer_age between 26 and 35 then 'youngster'
when customer_age between 36 and 50 then 'adult'
else 'senior'
end as agegroup,
'₹'||to_char(sum(price*quantity), '999,99,99,999') as total_purchase
 from sales_store_copy
group by agegroup
order by total_purchase desc


--q9 monthly sales trend--
--business problemsa=sales fluctuation go unnoticed 
--impact=plan inventory and marketing according to season--
select 
extract(year from purchase_date) as year,
extract(month from purchase_date) as month,
'₹'||to_char(sum(price*quantity):: numeric, 'FM999,99,99,999') as totalsale
from sales_store_copy
group by year,month
order by year,month asc


--q10 certain gender buying specific product category--
--business problem= GENDER BASED PRODUCT PREFERENCE-- 
--impact= personalized ads, gender focus campaign to increase sales--
select gender, product_category, count(product_category)as countp
from sales_store_copy
group by gender, product_category
order by gender
