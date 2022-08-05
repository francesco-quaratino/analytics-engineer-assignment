with
-- import CTEs
source_daily_stats as (

    select * from daily_stats

),

target_table as (

    select 
    
        datetime(coalesce(max(date), '1900-01-01')) as latest_date 
    
    from daily_conversion_funnel

),
-- logical CTEs
conversion_funnel as (
    
    select 

        date,
        visitors,
        viewers,
        leaders,
        purchasers,
        cast(viewers as float) / visitors as visitor_to_viewer,
        cast(leaders as float) / viewers as viewer_to_leader,
        cast(purchasers as float) / leaders as leader_to_purchaser

    from source_daily_stats

), 
-- final CTE
final as (
    select

        date,
        visitors,
        viewers,
        leaders,
        purchasers,
        printf("%.2f", visitor_to_viewer) as visitor_to_viewer,
        printf("%.2f", viewer_to_leader) as viewer_to_leader,
        printf("%.2f", leader_to_purchaser) as leader_to_purchaser

    from conversion_funnel
    where date > ( 
        
        select latest_date from target_table 

    )     

)
-- simple insert from select statement
insert into daily_conversion_funnel (

    date,
    visitors,
    viewers,
    leaders,
    purchasers,
    visitor_to_viewer,
    viewer_to_leader,
    leader_to_purchaser

)

select

    date,
    visitors,
    viewers,
    leaders,
    purchasers,
    visitor_to_viewer,
    viewer_to_leader,
    leader_to_purchaser

from final;