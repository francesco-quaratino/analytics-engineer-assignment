with
-- import CTEs
source_events as (

    select * from event_clean

),

target_table as (

    select 
    
        datetime(coalesce(max(date), '1900-01-01')) as latest_date 
    
    from daily_sales

),
-- logical CTEs
purchases as (

    select 
    
        date(event_time) as date, 
        cast(sum(price) as integer) as total_sales
    
    from source_events
    where event_type = 'purchase'
    group by date
    order by 1

),
-- final CTE
final as (

    select 

        date,
        printf("%.0f", total_sales) as total_sales

    from purchases
    where date > ( 
        
        select latest_date from target_table

    )    

)
-- simple insert from select statement
insert into daily_sales (

    date,
    total_sales

)

select 

    date,
    total_sales

from final;