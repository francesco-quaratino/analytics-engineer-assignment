drop table if exists event_raw;

create table event_raw (
	event_time text,
	event_type text,
	product_id text,
	category_id	text,
	category_code text,
	brand text,
	price text,
	user_id	text,
	user_session text
);


create table if not exists event_clean (
	event_time text,
	event_type text,
	product_id integer,
	category_id	integer,
	category_code text,
	brand text,
	price float,
	user_id	integer,
	user_session text
);


create table if not exists daily_sales (
    date text, 
    total_sales float
);


create table if not exists daily_stats (
	date text,
	visitors integer,
	sessions integer,
	viewers integer,
	views integer,
	leaders integer,
	leads integer,
	purchasers integer,
	purchases integer
);


create table if not exists daily_conversion_funnel (
	date text,
	visitors integer,
	viewers integer,
	leaders integer,
	purchasers integer,
	visitor_to_viewer float,
	viewer_to_leader float,
	leader_to_purchaser float
);


create table if not exists daily_ticket_size (
	date text,
	total_sales integer,
	min_ticket float,
	perc_ticket_25th float,
	perc_ticket_50th float,
	perc_ticket_75th float,
	max_ticket float
);
