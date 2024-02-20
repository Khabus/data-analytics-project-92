Считаем количество покупателей:
SELECT
    COUNT(customer_id) AS customers_count
from customers;

АНАЛИЗ ОТДЕЛА ПРОДАЖ
Первый отчет (ищем продавцов с наибольшей выручкой)
select
    concat(e.first_name, ' ', e.last_name) as name,
    COUNT(s.sales_id) as opeartions,
    ROUND(SUM(s.quantity * p.price), 0) as income
from employees e 
left join sales s 
    ON e.employee_id = s.sales_person_id 
join products p 
    on p.product_id = s.product_id
group by 1
order by 3 desc
limit 10;

Второй отчет (отчет с продавцами, чья выручка ниже средней выручки всех продавцов)
with Average_income AS(
    SELECT
    concat(e.first_name, ' ', e.last_name) as name,
    ROUND(AVG(s.quantity * p.price), 0) as average_income
from employees e 
left join sales s 
    ON e.employee_id = s.sales_person_id 
join products p 
    on p.product_id = s.product_id
group by 1
)
select
    name,
    average_income
from Average_income
group by 1,2
having average_income <= (select AVG(average_income) from Average_income)
order by 2 asc;

Третий отчет( отчет с данными по выручке по каждому продавцу и дню недели)
with tab as(
select
    CONCAT(e.first_name, ' ', e.last_name) as name,
    TO_CHAR(s.sale_date, 'day') as weekday,
    EXTRACT(ISODOW from s.sale_date) as dayoftheweek,
    ROUND(SUM(s.quantity * p.price), 0) as income
from employees e
left join sales s
on s.sales_person_id = e.employee_id
left join products p
on s.product_id = p.product_id
group by 1, 2, 3
order by 3
)
select name, weekday, income
from tab

АНАЛИЗ ПОКУПАТЕЛЕЙ
Первый отчет (количество покупателей в разных возрастных группах)
with tab as(
select *,
case
	when age between 16 and 25 then '16-25'
	when age between 26 and 40 then '26-40'
	when age > 40 then '40+'
end as age_category
from customers
)
select age_category, COUNT(age)
from tab
group by 1
order by 1;

Второй отчет (количество уникальных покупателей и выручка)
with tab as(
select
    s.customer_id,
    to_char(sale_date, 'YYYY-MM') as date,
    s.quantity * p.price as income
from sales s 
left join products p 
on s.product_id = p.product_id
)
select
    date,
    COUNT (distinct customer_id),
    ROUND(SUM(income), 0) as income
from tab 
group by 1
order by 1 ASC;

Третий отчет (покупатели, первая покупка которых пришлась на время проведения специальных акций)
with tab as(
select distinct
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as customer,
    s.sale_date as sale_date,
    CONCAT(e.first_name, ' ', e.last_name) as seller,
    first_value (p.price*s.quantity) over (partition by c.customer_id order by s.sale_date) as fst_prch,
    row_number () over (partition by c.customer_id order by s.sale_date) as r_n
from sales s 
left join customers c 
on s.customer_id = c.customer_id 
left join employees e 
on s.sales_person_id = e.employee_id 
left join products p 
on s.product_id = p.product_id 
order by 1
)
select customer,
    sale_date,
    seller
from tab
where fst_prch = 0 and r_n = 1;
