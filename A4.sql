-- 5a.
drop view if exists v_user_info;
create view v_user_info as
CONCAT('(', substring(usr_phone,1,3),')', substring(usr_phone,4,3),'-', substring(usr_phone,7,4)) as usr_phone,
usr_email
from user
order by usr_lname asc;

--good (This works for me)
drop view if exists v_user_info;
create view v_user_info as
select usr_id, usr_fname, usr_lname,
CONCAT
(
    '(',
    substring(usr_phone,1,3),
    ')',
    substring(usr_phone,4,3),
    '-',
    substring(usr_phone,7,4)
)
as usr_phone,
usr_email
from user
order by usr_lname asc;

/* answer for 5a
mysql> select * from v_user_info;
+--------+-----------+------------+---------------+--------------------+
| usr_id | usr_fname | usr_lname  | usr_phone     | usr_email          |
+--------+-----------+------------+---------------+--------------------+
|      5 | Johnny    | Depp       | (100)178-4526 | jdepp@horizon.com  |
|      1 | John      | Doe        | (571)324-7659 | jdoe@aol.com       |
|      4 | Billy     | Joel       | (908)675-3018 | bjoel@comcast.net  |
|      2 | Jane      | Parker     | (313)657-9012 | jparker@yahoo.com  |
|      3 | Bonnie    | Val Kyries | (501)674-9831 | bvalkyries@att.net |
+--------+-----------+------------+---------------+--------------------+ 
*/

-- 5b.
drop view if exists v_institution_info;
create view v_institution_info as
select ins_name, 
CONCAT(ins_street, ", ", ins_city, ", ", ins_state, " ", substring(ins_zip,1,5), '-', substring(ins_zip,6,4)) as address,
CONCAT('(', substring(ins_phone,1,3), ')', substring(ins_phone,4,3), '-', substring(ins_phone,7,4)) as ins_phone,
ins_email, ins_url
from institution
order by ins_name asc;

select * from v_institution_info;

/* answer for 5b
+------------------------+-----------------------------------------------+---------------+-------------------------+---------------------------+
| ins_name               | address                                       | ins_phone     | ins_email               | ins_url                   |
+------------------------+-----------------------------------------------+---------------+-------------------------+---------------------------+
| Great Lakes Loan Group | 2401 International Ln, Madison, WI 53704-3121 | (800)236-4300 | info@gllg.com           | http://www.gllg.com       |
| Regions                | 2320 Tennessee St, Tallahassee, FL 32304-7634 | (800)555-1234 | bob@regions.com         | http://www.regions.com    |
| SunTrust               | 17823 South Ave., Atlanta, GA 30353-8974      | (800)555-6789 | contact@suntrust.com    | http://www.suntrust.com   |
| TIAA-CREF              | 730 3rd Ave., NY, NY 10017-2093               | (800)719-1185 | info@tiaacreff.com      | http://www.tiaacreff.com  |
| Wells Fargo            | 87413 Pennsacola, Tallahassee, FL 32302-1251  | (800)555-4321 | chiggins@wellsfargo.com | http://www.wellsfargo.com |
+------------------------+-----------------------------------------------+---------------+-------------------------+---------------------------+
*/

-- 5c.
drop view if exists v_category_types;
create view v_category_types as
select distinct cat_id, cat_type
from transaction
natural join category;

select *from v_category_types;

/* results for 5c
+--------+----------------+
| cat_id | cat_type       |
+--------+----------------+
|      1 | housing        |
|      2 | food           |
|      3 | transportation |
|      4 | insurance      |
|      5 | personal       |
+--------+----------------+
*/

-- 5d. 
DROP PROCEDURE IF EXISTS UserInstitutionAccountInfo;
DELIMITER //
CREATE PROCEDURE UserInstitutionAccountInfo(IN usrid INT)
BEGIN
select usr_fname, usr_lname, ins_name, act_type
from user u
    join source s on u.usr_id=s.usr_id
    join institution i on s.ins_id=i.ins_id
    join account a on s.act_id=a.act_id
    where u.usr_id = usrid
    order by act_type desc;
END //
DELIMITER ;

-- call procedure 
SET @uid=5;
CALL UserInstitutionAccountInfo(@uid);

/* results for 5d
+-----------+-----------+------------------------+----------+
| usr_fname | usr_lname | ins_name               | act_type |
+-----------+-----------+------------------------+----------+
| Johnny    | Depp      | SunTrust               | savings  |
| Johnny    | Depp      | Great Lakes Loan Group | mortgage |
+-----------+-----------+------------------------+----------+
*/

-- 5e. 
DROP PROCEDURE IF EXISTS UserAccountTransactionInfo;
DELIMITER //
CREATE PROCEDURE UserAccountTransactionInfo()
BEGIN
select usr_fname, usr_lname, act_type, trn_type, trn_method,
CONCAT('$', FORMAT(trn_amt, 2)) as trn_amount,
DATE_FORMAT(trn_date, '%c%/%e%/%y %r') trn_timestamp,
trn_notes
from user
    natural join source
    natural join transaction
    natural join account
    order by usr_lname desc, trn_amt;
END //
DELIMITER ;

-- call procedure
CALL UserAccountTransactionInfo();

DROP PROCEDURE IF EXISTS UserAccountTransactionInfo;

/* answer for 5e
+-----------+------------+-------------+----------+------------+------------+---------------------+-----------+
| usr_fname | usr_lname  | act_type    | trn_type | trn_method | trn_amount | trn_timestamp       | trn_notes |
+-----------+------------+-------------+----------+------------+------------+---------------------+-----------+
| Bonnie    | Val Kyries | investment  | debit    | pos        | $983.50    | 3/17/06 06:29:04 PM | NULL      |
| Jane      | Parker     | mortgage    | credit   | bank       | $56.92     | 2/13/04 09:34:06 AM | in bank   |
| Jane      | Parker     | school loan | debit    | pos        | $153.67    | 6/9/03 10:19:06 AM  | NULL      |
| Jane      | Parker     | mortgage    | credit   | atm        | $785.34    | 6/9/02 05:12:51 AM  | NULL      |
| Jane      | Parker     | school loan | credit   | atm        | $815.67    | 8/21/08 05:09:36 PM | NULL      |
| John      | Doe        | checking    | debit    | 518        | $22.85     | 5/9/07 12:05:32 PM  | check no. |
| John      | Doe        | checking    | credit   | auto       | $763.21    | 4/1/06 09:46:08 PM  | NULL      |
| John      | Doe        | savings     | debit    | 834        | $816.24    | 9/23/05 10:31:23 AM | check no. |
| John      | Doe        | checking    | debit    | 1342       | $1,095.85  | 6/9/03 11:01:00 PM  | check no. |
| John      | Doe        | savings     | credit   | auto       | $2,235.09  | 1/7/02 11:59:59 AM  | NULL      |
+-----------+------------+-------------+----------+------------+------------+---------------------+-----------+
*/

-- 5f.
drop view if exists v_user_debits_info;
create view v_user_debits_info as
select usr_fname, usr_lname, trn_type, concat('$',format(sum(trn_amt),2)) as debit_amt
from user
    natural join source
    natural join transaction
where trn_type='debit'
group by usr_id
order by sum(trn_amt) desc;

select *from v_user_debits_info;

--remove from server memory 
drop view if exists v_user_debits_info;

/* answer for 5f
+-----------+------------+----------+-----------+
| usr_fname | usr_lname  | trn_type | debit_amt |
+-----------+------------+----------+-----------+
| John      | Doe        | debit    | $1,934.94 |
| Bonnie    | Val Kyries | debit    | $983.50   |
| Jane      | Parker     | debit    | $153.67   |
+-----------+------------+----------+-----------+
*/

-- 5g.
START TRANSACTION;
SELECT *FROM transaction;

INSERT INTO transaction
(trn_id, src_id, cat_id, trn_type, trn_method, trn_amt, trn_date, trn_notes)
VALUES
(NULL, 2, 1, 'credit', 'auto', 2235.09, '2002-01-07 11:59:59', NULL);

SELECT *FROM transaction;

select @tid := max(trn_id) from transaction;

update transaction
set trn_notes='transaction has been updated'
where trn_id = @tid;

SELECT * FROM transaction;

delete from transaction
where trn_id = @tid;

SELECT * FROM transaction;

Commit;

/*
mysql> INSERT INTO transaction
    -> (trn_id, src_id, cat_id, trn_type, trn_method, trn_amt, trn_date, trn_notes)
    -> VALUES
    -> (NULL, 2, 1, 'credit', 'auto', 2235.09, '2002-01-07 11:59:59', NULL);
Query OK, 1 row affected (0.00 sec)

mysql> 
mysql> SELECT *FROM transaction;
+--------+--------+--------+----------+------------+---------+---------------------+-----------+
| trn_id | src_id | cat_id | trn_type | trn_method | trn_amt | trn_date            | trn_notes |
+--------+--------+--------+----------+------------+---------+---------------------+-----------+
|      1 |      2 |      1 | credit   | auto       | 2235.09 | 2002-01-07 11:59:59 | NULL      |
|      2 |      3 |      2 | credit   | atm        |  785.34 | 2002-06-09 05:12:51 | NULL      |
|      3 |      4 |      3 | debit    | pos        |  153.67 | 2003-06-09 10:19:06 | NULL      |
|      4 |      1 |      4 | debit    | 1342       | 1095.85 | 2003-06-09 23:01:00 | check no. |
|      5 |      1 |      1 | debit    | 518        |   22.85 | 2007-05-09 12:05:32 | check no. |
|      6 |      3 |      2 | credit   | bank       |   56.92 | 2004-02-13 09:34:06 | in bank   |
|      7 |      2 |      3 | debit    | 834        |  816.24 | 2005-09-23 10:31:23 | check no. |
|      8 |      5 |      2 | debit    | pos        |  983.50 | 2006-03-17 18:29:04 | NULL      |
|     11 |      2 |      1 | credit   | auto       | 2235.09 | 2002-01-07 11:59:59 | NULL      |
+--------+--------+--------+----------+------------+---------+---------------------+-----------+
9 rows in set (0.00 sec)

mysql> 
mysql> select @tid := max(trn_id) from transaction;
+---------------------+
| @tid := max(trn_id) |
+---------------------+
|                  11 |
+---------------------+
1 row in set, 1 warning (0.00 sec)

mysql> 
mysql> update transaction
    -> set trn_notes='transaction has been updated'
    -> where trn_id = @tid;
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> 
mysql> SELECT * FROM transaction;
+--------+--------+--------+----------+------------+---------+---------------------+------------------------------+
| trn_id | src_id | cat_id | trn_type | trn_method | trn_amt | trn_date            | trn_notes                    |
+--------+--------+--------+----------+------------+---------+---------------------+------------------------------+
|      1 |      2 |      1 | credit   | auto       | 2235.09 | 2002-01-07 11:59:59 | NULL                         |
|      2 |      3 |      2 | credit   | atm        |  785.34 | 2002-06-09 05:12:51 | NULL                         |
|      3 |      4 |      3 | debit    | pos        |  153.67 | 2003-06-09 10:19:06 | NULL                         |
|      4 |      1 |      4 | debit    | 1342       | 1095.85 | 2003-06-09 23:01:00 | check no.                    |
|      5 |      1 |      1 | debit    | 518        |   22.85 | 2007-05-09 12:05:32 | check no.                    |
|      6 |      3 |      2 | credit   | bank       |   56.92 | 2004-02-13 09:34:06 | in bank                      |
|      7 |      2 |      3 | debit    | 834        |  816.24 | 2005-09-23 10:31:23 | check no.                    |
|      8 |      5 |      2 | debit    | pos        |  983.50 | 2006-03-17 18:29:04 | NULL                         |
|     11 |      2 |      1 | credit   | auto       | 2235.09 | 2002-01-07 11:59:59 | transaction has been updated |
+--------+--------+--------+----------+------------+---------+---------------------+------------------------------+
9 rows in set (0.00 sec)

mysql> 
mysql> delete from transaction
    -> where trn_id = @tid;
Query OK, 1 row affected (0.00 sec)

mysql> 
mysql> SELECT * FROM transaction;
+--------+--------+--------+----------+------------+---------+---------------------+-----------+
| trn_id | src_id | cat_id | trn_type | trn_method | trn_amt | trn_date            | trn_notes |
+--------+--------+--------+----------+------------+---------+---------------------+-----------+
|      1 |      2 |      1 | credit   | auto       | 2235.09 | 2002-01-07 11:59:59 | NULL      |
|      2 |      3 |      2 | credit   | atm        |  785.34 | 2002-06-09 05:12:51 | NULL      |
|      3 |      4 |      3 | debit    | pos        |  153.67 | 2003-06-09 10:19:06 | NULL      |
|      4 |      1 |      4 | debit    | 1342       | 1095.85 | 2003-06-09 23:01:00 | check no. |
|      5 |      1 |      1 | debit    | 518        |   22.85 | 2007-05-09 12:05:32 | check no. |
|      6 |      3 |      2 | credit   | bank       |   56.92 | 2004-02-13 09:34:06 | in bank   |
|      7 |      2 |      3 | debit    | 834        |  816.24 | 2005-09-23 10:31:23 | check no. |
|      8 |      5 |      2 | debit    | pos        |  983.50 | 2006-03-17 18:29:04 | NULL      |
+--------+--------+--------+----------+------------+---------+---------------------+-----------+
8 rows in set (0.00 sec)

mysql> 
mysql> Commit;
Query OK, 0 rows affected (0.01 sec)
*/

--extra credit
drop view if exists v_user_finance_info;
create view v_user_finance_info as 
select usr_fname, usr_lname,
CONCAT('(', substring(ins_phone,1,3), ')', substring(usr_phone,4,3), '-', substring(usr_phone,7,4)) as usr_phone,
ins_name,
CONCAT('(', substring(ins_phone,1,3), ')', substring(ins_phone,4,3), '-', substring(ins_phone,7,4)) as ins_phone,
ins_contact, act_type,
DATE_FORMAT(src_start_date, '%c%/%e%/%y') act_start_date,
trn_id, trn_type, trn_method,
CONCAT('$', FORMAT(trn_amt, 2)) as trn_amount,
DATE_FORMAT(trn_date, '%c%/%e%/%y %r') trn_timestamp,
cat_type,
trn_notes
from user
    natural join source
    natural join institution
    natural join transaction
    natural join category
    natural join account
    order by usr_lname asc;

select * from v_user_finance_info;

 --remove from server memory
drop view if exists v_user_finance_info;

/* extra credit answer
+-----------+------------+---------------+-------------+---------------+----------------+-------------+----------------+--------+----------+------------+------------+---------------------+----------------+-----------+
| usr_fname | usr_lname  | usr_phone     | ins_name    | ins_phone     | ins_contact    | act_type    | act_start_date | trn_id | trn_type | trn_method | trn_amount | trn_timestamp       | cat_type       | trn_notes |
+-----------+------------+---------------+-------------+---------------+----------------+-------------+----------------+--------+----------+------------+------------+---------------------+----------------+-----------+
| John      | Doe        | (800)324-7659 | Regions     | (800)555-1234 | Bob Flounder   | checking    | 3/31/01        |      4 | debit    | 1342       | $1,095.85  | 6/9/03 11:01:00 PM  | insurance      | check no. |
| John      | Doe        | (800)324-7659 | Regions     | (800)555-1234 | Bob Flounder   | checking    | 3/31/01        |      5 | debit    | 518        | $22.85     | 5/9/07 12:05:32 PM  | housing        | check no. |
| John      | Doe        | (800)324-7659 | Regions     | (800)555-1234 | Bob Flounder   | savings     | 5/7/01         |      1 | credit   | auto       | $2,235.09  | 1/7/02 11:59:59 AM  | housing        | NULL      |
| John      | Doe        | (800)324-7659 | Regions     | (800)555-1234 | Bob Flounder   | savings     | 5/7/01         |      7 | debit    | 834        | $816.24    | 9/23/05 10:31:23 AM | transportation | check no. |
| Jane      | Parker     | (800)657-9012 | Regions     | (800)555-1234 | Bob Flounder   | mortgage    | 1/2/03         |      2 | credit   | atm        | $785.34    | 6/9/02 05:12:51 AM  | food           | NULL      |
| Jane      | Parker     | (800)657-9012 | Regions     | (800)555-1234 | Bob Flounder   | mortgage    | 1/2/03         |      6 | credit   | bank       | $56.92     | 2/13/04 09:34:06 AM | food           | in bank   |
| Jane      | Parker     | (800)657-9012 | Wells Fargo | (800)555-4321 | Cheryl Higgins | school loan | 11/19/05       |      3 | debit    | pos        | $153.67    | 6/9/03 10:19:06 AM  | transportation | NULL      |
| Bonnie    | Val Kyries | (800)674-9831 | Wells Fargo | (800)555-4321 | Cheryl Higgins | investment  | 9/9/02         |      8 | debit    | pos        | $983.50    | 3/17/06 06:29:04 PM | food           | NULL      |
+-----------+------------+---------------+-------------+---------------+----------------+-------------+----------------+--------+----------+------------+------------+---------------------+----------------+-----------+
*/