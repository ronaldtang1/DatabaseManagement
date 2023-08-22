-- If LOCAL is specified, the file is read by the client program on the client host and sent to the server.
-- for default .csv file use comma-terminated

-- \r\n for files created on windows machines, \n for files created on Mac or UNIX machines

/* data for selected attributes, on CCI server (must specify LOCAL, otherwise, error) */
LOAD DATA LOCAL INFILE 'db/transaction_data.csv'
INTO TABLE transaction
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
(trn_id, src_id, cat_id, trn_type, trn_method, trn_amt, @date_variable, trn_notes)
SET 
  trn_date = STR_TO_DATE(@date_variable, '%c/%e/%Y %H:%i:%s');

show warnings;
