## Project decisions


### Data cleansing

The data cleansing tasks covered are:
- remove the first row from the staging table ```event_raw``` (```where rowid <> 1```) as it holds the csv header row.
- remove leading and trailing spaces (```trim(column_name)```).
- make text columns lowercase.
- remove the `UTC` suffix from timestamps (```substr(event_time, 1, 19)```).
- convert to integer/float the columns expected to be so, and set them as ```null``` if convertion fails (```case when cast(price as float) = price then price else null end```).

### Incremental load

The incremantal loading is implemented with the following assumptions on the source csv files:

- they do not overlap (i.e. given an event, it can be found in one-and-only-one of the provided files).
- they are ingested in chronological order from the oldest to the newest (e.g. 2020-Feb.csv is ingested only after 2020-Jan.csv was ingested).  

Within each of the .sql script, the incremental loading is achieved by:

1) fetching, in the `import CTEs` code-block, the latest timestamp for which data is available in the target table (i.e. the one the script is aiming to load (in the example below `event_clean`). 
```
target_table as (
    select 
        datetime(coalesce(max(event_time), '1900-01-01')) as latest_date 
    from event_clean    
),
```

2) filtering out, in the `final CTE`, the rows with timestamp older than the latest timestamp, in order to prevent loading the same data twice.
```
final as (
    select * from clean_data_types
    where event_time > (         
        select latest_date from target_table
    )    
)
```

### SQL code style

- [snake_case](https://en.wikipedia.org/wiki/Snake_case) is adopted for database objects and sql commands
- CTEs are structured in the following blocks:
  - ```import CTEs```: where all source tables are collected in a separate CTE, and preferably using a ```select * ```
  - ```logical CTEs```: where the ```import CTEs``` are subject to transformations, including aggregations
  - ```final CTE```: where the ```logical CTEs``` are joined together to produce the final data set to be loaded
  - ```simple insert from select statement```: where the target table is loaded using ```insert into ... select ... from final``` statement
- There are no comments in the code, other than those referring to the CTE blocks as above, since the code is written to be self-explanatory (*"One of the more common motivations for writing comments is bad code"* - R.C.Martins, 'Clean Code').   
