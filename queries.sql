SELECT COUNT(customer_id) AS customers_count
from customers;
--считаем количество покупателей
---------
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
-- ищем продавцов с наибольшей выручкой
