-- https://www.metabase.com/docs/latest/getting-started.html
-- http://metabase-alink-production.eba-mfddijec.us-east-1.elasticbeanstalk.com
select count(*) from orders where subtotal > 40


select
    year(created_at) as created_year,
    month(created_at) as created_month,
    count(*)
    
from orders
where subtotal > 40
group by created_year, created_month

select
    product_id,
    category,
    median(reviews.rating) as median_rating
    
from reviews
left join products on products.id=reviews.product_id
where category='Gizmo'
group by product_id
having median_rating < 4




select
    year(orders.created_at) as created_year,
    month(orders.created_at) as created_month,
    avg(subtotal) as average_sale_price

from ORDERS
left join products on products.id = ORDERS.product_id
where category='Gizmo'
group by created_year, created_month

with sale_amounts as (

    select
        year(orders.created_at) as created_year,
        month(orders.created_at) as created_month,
        avg(subtotal) as average_sale_price

    from ORDERS
    left join products on products.id = ORDERS.product_id
    where category='Gizmo'
    group by created_year, created_month

)

select 
    created_year,
    created_month,
    100 * (90-average_sale_price) / 90 as percent_off_from_target
    
from sale_amounts 
order by created_year desc, created_month desc



with low_rated_gizmo_products as (

    select
        product_id,
        category,
        median(reviews.rating) as median_rating
        
    from reviews
    left join products on products.id=reviews.product_id
    where category='Gizmo'
    group by product_id
 
), 

sale_amounts as (

    select
        year(orders.created_at) as created_year,
        month(orders.created_at) as created_month,
        case when median_rating > 4 then 'high rated gizmo' else 'low rated gizmo' end as rating_category,
        avg(subtotal) as average_sale_price

    from ORDERS
    inner join low_rated_gizmo_products on low_rated_gizmo_products.product_id = ORDERS.product_id
    group by created_year, created_month, rating_category

)

select 
    created_year,
    created_month,
    rating_category,
    100 * (90-average_sale_price) / 90 as percent_off_from_target
    
from sale_amounts 
order by created_year desc, created_month desc, rating_category


with products_with_low_rating as (
    
    select
        product_id,
        category,
        median(reviews.rating) as median_rating
        
    from reviews
    left join products on products.id=reviews.product_id
    where category='Gizmo'
    group by product_id

),

sales_by_gizmo_label as (
    
    select 
        year(created_at) as created_year,
        month(created_at) as created_month,
        case when median_rating < 3 then 'low rated gizmo' else 'high rated gizmo' end as rating_label,
        sum(subtotal) as sales_total,
        count(distinct orders.id) as order_count
        
    from orders
    inner join products_with_low_rating on orders.product_id=products_with_low_rating.product_id
    group by created_year, created_month, rating_label
    
)

select
    created_year,
    created_month,
    rating_label,
    sales_total / order_count as avg_sales_price
    
from sales_by_gizmo_label
order by created_year desc, created_month desc, rating_label
    