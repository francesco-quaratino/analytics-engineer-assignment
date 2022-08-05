.DEFAULT_GOAL := run

00-create-tables-pre-load-file-2020-Jan:
	@echo "Creating tables 'event_raw' and 'event_clean"
	@sqlite3 db/assignment.db  ".read sql/00-create-tables.sql"	

01-ingest-file-2020-Jan: 00-create-tables-pre-load-file-2020-Jan
	@echo "Ingesting Jan-2020 file into the 'event_raw' table"
	@sqlite3 db/assignment.db  ".read sql/01-ingest-file-2020-Jan.sql"

02-clean-data-2020-Jan: 01-ingest-file-2020-Jan
	@echo "Cleaning raw data and loading Jan-2020 data into the 'event_clean' table"
	@sqlite3 db/assignment.db  ".read sql/02-clean-data.sql"

03-daily-sales-2020-Jan: 02-clean-data-2020-Jan
	@echo "Loading the daily_sales table with Jan-2020 data"
	@sqlite3 db/assignment.db  ".read sql/03-daily-sales.sql"

04-daily-stats-2020-Jan: 03-daily-sales-2020-Jan
	@echo "Loading the daily_stats table with Jan-2020 data"
	@sqlite3 db/assignment.db  ".read sql/04-daily-stats.sql"

05-daily-conversion-funnel-2020-Jan: 04-daily-stats-2020-Jan
	@echo "Loading the daily_conversion_funnel table with Jan-2020 data"
	@sqlite3 db/assignment.db  ".read sql/05-daily-conversion-funnel.sql"

06-daily-ticket-size-2020-Jan: 05-daily-conversion-funnel-2020-Jan
	@echo "Loading the daily_ticket_size table with Jan-2020 data"
	@sqlite3 db/assignment.db  ".read sql/06-daily-ticket-size.sql"


00-create-tables-pre-load-file-2020-Feb: 06-daily-ticket-size-2020-Jan
	@echo "Creating tables 'event_raw' and 'event_clean"
	@sqlite3 db/assignment.db  ".read sql/00-create-tables.sql"	

01-ingest-file-2020-Feb: 00-create-tables-pre-load-file-2020-Feb
	@echo "Ingesting Feb-2020 file into the 'event_raw' table"
	@sqlite3 db/assignment.db  ".read sql/01-ingest-file-2020-Feb.sql"

02-clean-data-2020-Feb: 01-ingest-file-2020-Feb
	@echo "Cleaning raw data and loading Feb-2020 data into the 'event_clean' table"
	@sqlite3 db/assignment.db  ".read sql/02-clean-data.sql"

03-daily-sales-2020-Feb: 02-clean-data-2020-Feb
	@echo "Loading the daily_sales table with Feb-2020 data"
	@sqlite3 db/assignment.db  ".read sql/03-daily-sales.sql"

04-daily-stats-2020-Feb: 03-daily-sales-2020-Feb
	@echo "Loading the daily_stats table with Feb-2020 data"
	@sqlite3 db/assignment.db  ".read sql/04-daily-stats.sql"

05-daily-conversion-funnel-2020-Feb: 04-daily-stats-2020-Feb
	@echo "Loading the daily_conversion_funnel table with Feb-2020 data"
	@sqlite3 db/assignment.db  ".read sql/05-daily-conversion-funnel.sql"

06-daily-ticket-size-2020-Feb: 05-daily-conversion-funnel-2020-Feb
	@echo "Loading the daily_ticket_size table with Feb-2020 data"
	@sqlite3 db/assignment.db  ".read sql/06-daily-ticket-size.sql"


99-last-task: 06-daily-ticket-size-2020-Feb

root-target: 99-last-task
	@echo "Process completed. Well done!"

# TODO: Add all the necessary steps to complete the assignment
run: root-target

