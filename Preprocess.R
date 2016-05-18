require(RPostgreSQL);
drv <- dbDriver("PostgreSQL");
pgdb <- dbConnect(drv, user = 'postgres', password = '1234',dbname = 'tianchidb', host = '127.0.0.1');
artist <- dbReadTable(pgdb,'t_artist');
users <- dbReadTable(pgdb,'t_user');


