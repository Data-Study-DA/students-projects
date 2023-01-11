CREATE TABLE results (
    [date] date 
,   home_team TEXT 
,   away_team TEXT
,   home_score INT
,   away_score INT
,   tournament TEXT
,   city TEXT
,   country TEXT
,   neutral TEXT,
    PRIMARY KEY (date, home_team, away_team)
);
CREATE TABLE goalscorers (
    [date] date
,   home_team TEXT 
,   away_team TEXT
,   team TEXT
,   scorer TEXT
,   minute FLOAT
,   own_goal BOOLEAN
,   penalty BOOLEAN

);

CREATE TABLE shootouts (
    [date] date
,   home_team TEXT 
,   away_team TEXT
,   winner TEXT

);

CREATE TABLE sales (
    transation_id INTEGER PRIMARY KEY
,   transaction_date_id REFERENCES time (date_id)
,   transaction_time_id REFERENCES time (time_id)
,   product_id INTEGER REFERENCES products (product_id)
,   region_id INTEGER REFERENCES regions (region_id)
,   price REAL  
)
