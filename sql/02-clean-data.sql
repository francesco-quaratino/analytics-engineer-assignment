
with
-- import CTEs
source_events as (

    select * from event_raw

    where rowid <> 1

),

target_table as (

    select 
    
        datetime(coalesce(max(event_time), '1900-01-01')) as latest_date 
    
    from event_clean

),
-- logical CTEs
clean_nulls as (

    select

        nullif(trim(event_time), '') as event_time,
        nullif(lower(trim(event_type)), '') as event_type,
        nullif(trim(product_id), '') as product_id,
        nullif(trim(category_id), '') as category_id,
        nullif(lower(trim(category_code)), '') as category_code,
        nullif(lower(trim(brand)), '') as brand,
        nullif(trim(price), '') as price,
        nullif(trim(user_id), '') as user_id,
        nullif(trim(user_session), '') as user_session

    from source_events

),

clean_data_types as (

    select 

        datetime(substr(event_time, 1, 19)) as event_time,
        event_type,
        case 
            when cast(product_id as integer) = product_id then product_id 
            else null 
        end as product_id,
        case 
            when cast(category_id as integer) = category_id then category_id 
            else null 
        end as category_id,
        category_code,
        brand,
        case 
            when cast(price as float) = price then price 
            else null 
        end as price,
        case 
            when cast(user_id as integer) = user_id then user_id 
            else null 
        end as user_id,
        user_session
        
    from clean_nulls

),
-- final CTE
final as (

    select * from clean_data_types

    where event_time > ( 
        
        select latest_date from target_table

    )    

)
-- simple insert from select statement
insert into event_clean ( 

    event_time,
    event_type,
    product_id,
    category_id,
    category_code,
    brand,
    price,
    user_id,
    user_session

)

select 

    event_time,
    event_type,
    product_id,
    category_id,
    category_code,
    brand,
    price,
    user_id,
    user_session
    
from final;