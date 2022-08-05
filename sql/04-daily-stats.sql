with
-- import CTEs
source_events as (

	select * from event_clean

),

target_table as (

    select 
    
        datetime(coalesce(max(date), '1900-01-01')) as latest_date 
    
    from daily_stats

),
-- logical CTEs
_visitors as (

	select

		date(event_time) as date, 
		count(distinct user_id) as visitors,
		count(distinct user_session) as sessions

	from source_events
	group by date

),

_viewers as (

	select

		date(event_time) as date, 
		count(distinct user_id) as viewers,
		count(distinct product_id) as views

	from source_events
	where event_type = 'view'
	group by date

),

_leaders as (

	select 

		date(event_time) as date, 
		count(distinct user_id) as leaders,
		count(*) as leads

	from source_events
	where event_type = 'cart'
	group by date	

),

_purchases as (

	select 

		date(event_time) as date, 
		count(distinct user_id) as purchasers,
		count(*) as purchases

	from source_events
	where event_type = 'purchase'
	group by date	

),
-- final CTE
final as (

	select 

		_visitors.date,
		coalesce(_visitors.visitors, 0) as visitors,
		coalesce(_visitors.sessions, 0) as sessions,
		coalesce(_viewers.viewers, 0) as viewers,
		coalesce(_viewers.views, 0) as views,
		coalesce(_leaders.leaders, 0) as leaders,
		coalesce(_leaders.leads, 0) as leads,
		coalesce(_purchases.purchasers, 0) as purchasers,
		coalesce(_purchases.purchases, 0) as purchases

	from _visitors
	left join _viewers on _visitors.date = _viewers.date
	left join _leaders on _visitors.date = _leaders.date
	left join _purchases on _visitors.date = _purchases.date
    where _visitors.date > ( 
        
        select latest_date from target_table 

    )   


)
-- simple insert from select statement
insert into daily_stats (

	date,
	visitors,
	sessions,
	viewers,
	views,
	leaders,
	leads,
	purchasers,
	purchases

)

select 

	date,
	visitors,
	sessions,
	viewers,
	views,
	leaders,
	leads,
	purchasers,
	purchases

from final;