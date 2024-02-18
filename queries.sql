--Считаем количество покупателей:
SELECT
    COUNT(customer_id) AS customers_count
from customers;
--Первый отчет(ищем продавцов с наибольшей выручкой)
select
    concat(e.first_name, ' ', e.last_name) as name,
    COUNT(s.sales_id) as opeartions,
    SUM(s.quantity * p.price) as income
from employees e 
left join sales s 
    ON e.employee_id = s.sales_person_id 
join products p 
    on p.product_id = s.product_id
group by 1
order by 3 desc
limit 10;
-- Второй отчет (отчет с продавцами, чья выручка ниже средней выручки всех продавцов)
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

--Третий отчет( отчет с данными по выручке по каждому продавцу и дню недели)
with tab as(
select
    CONCAT(e.first_name, ' ', e.last_name) as name,
    TO_CHAR(s.sale_date, 'day') as weekday,
    EXTRACT(ISODOW from s.sale_date) as dayoftheweek,
    SUM(s.quantity * p.price) as income
from employees e
left join sales s
on s.sales_person_id = e.employee_id
left join products p
on s.product_id = p.product_id
group by 1, 2, 3
order by 3
)
select name, weekday, income
from tab;
