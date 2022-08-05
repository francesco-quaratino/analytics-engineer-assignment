with
-- import CTEs
source_events as (
    
    select * from event_clean

),

source_daily_sales as (

    select * from daily_sales

),

target_table as (

    select 
    
        datetime(coalesce(max(date), '1900-01-01')) as latest_date 
    
    from daily_ticket_size

),
-- logical CTEs
tickets as ( 

    select 
    
        distinct

        date(event_time) as date, 
        sum(price) over (partition by date(event_time), user_session) as ticket_size 

    from source_events
    where event_type = 'purchase'

),

items as (

    select

        date,
        count(*) as total_number
    
    from tickets
    group by date

),

tickets_ranks as (

    select

        date,
        ticket_size,
        dense_rank() over (partition by date order by ticket_size) as ticket_rank
    
    from tickets

),

percentiles as (

    select 

        date,
        cast(round(0.25 * (total_number + 1), 0) as integer) as percentile_rank_25,
        cast(round(0.50 * (total_number + 1), 0) as integer) as percentile_rank_50,
        cast(round(0.75 * (total_number + 1), 0) as integer) as percentile_rank_75                

    from items

),

percentile_tickets as (

    select

        percentiles.date, 
        perc_25.ticket_size as perc_ticket_25th,
        perc_50.ticket_size as perc_ticket_50th,
        perc_75.ticket_size as perc_ticket_75th

    from percentiles 
    inner join tickets_ranks as perc_25 on percentiles.date = perc_25.date 
        and percentiles.percentile_rank_25 = perc_25.ticket_rank
    inner join tickets_ranks as perc_50 on percentiles.date = perc_50.date 
        and percentiles.percentile_rank_50 = perc_50.ticket_rank          
    inner join tickets_ranks as perc_75 on percentiles.date = perc_75.date 
        and percentiles.percentile_rank_75 = perc_75.ticket_rank

),

agg_tickets as ( 

    select 
    
        date, 
        min(ticket_size) as min_ticket,
        max(ticket_size) as max_ticket

    from tickets 
    group by date

),

-- final CTE
final as (

    select 

        source_daily_sales.date,
        source_daily_sales.total_sales,
        printf("%.2d", agg_tickets.min_ticket) as min_ticket,
        printf("%.2f", percentile_tickets.perc_ticket_25th) as perc_ticket_25th,
        printf("%.2f", percentile_tickets.perc_ticket_50th) as perc_ticket_50th,
        printf("%.2f", percentile_tickets.perc_ticket_75th) as perc_ticket_75th,
        printf("%.2d", agg_tickets.max_ticket) as max_ticket

    from source_daily_sales
    inner join agg_tickets on source_daily_sales.date = agg_tickets.date
    inner join percentile_tickets on agg_tickets.date = percentile_tickets.date
    where source_daily_sales.date > ( 
        
        select latest_date from target_table 

    )     
)
-- simple insert from select statement
insert into daily_ticket_size (

	date,
	total_sales,
	min_ticket,
	perc_ticket_25th,
	perc_ticket_50th,
	perc_ticket_75th,
	max_ticket

)
select 

	date,
	total_sales,
	min_ticket,
	perc_ticket_25th,
	perc_ticket_50th,
	perc_ticket_75th,
	max_ticket

from final;