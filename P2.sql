SET ANSI_WARNINGS ON;
GO

use master;
GO

--drop existing database
IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'rt20g')
DROP DATABASE rt20g;
GO

--create database if not exists
IF NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'rt20g')
CREATE DATABASE rt20g;
GO

use rt20g;
GO

-- ------------------------
-- Patient table
-- ------------------------
IF OBJECT_ID (N'dbo.patient',N'U') IS NOT NULL
DROP TABLE dbo.patient;
GO

CREATE TABLE dbo.patient
(
pat_id SMALLINT not null identity(1,1),
pat_ssn int NOT NULL check (pat_ssn > 0 and pat_ssn <= 999999999),
pat_fname VARCHAR(15) NOT NULL,
pat_lname VARCHAR(30) NOT NULL,
pat_street VARCHAR(30) NOT NULL,
pat_city VARCHAR(30) NOT NULL,
pat_state CHAR(2) NOT NULL DEFAULT 'FL',
pat_zip CHAR(9) NOT NULL check (pat_zip like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
pat_phone bigint NOT NULL check (pat_phone like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
pat_email VARCHAR(100) NULL,
pat_dob DATE NOT NULL,
pat_gender CHAR(1) NOT NULL CHECK (pat_gender IN ('m','f')),
pat_notes VARCHAR(45) NULL,
PRIMARY KEY (pat_id),

--make sure SSNs and State IDs are unique
CONSTRAINT ux_pat_snn unique nonclustered (pat_ssn ASC)
);

-- ------------------------
-- medication table
-- ------------------------
IF OBJECT_ID (N'dbo.medication',N'U') IS NOT NULL
DROP TABLE dbo.medication;

CREATE TABLE dbo.medication
(
med_id SMALLINT NOT NULL identity(1,1),
med_name VARCHAR(100) NOT NULL,
med_price DECIMAL(5,2) NOT NULL CHECK (med_price > 0),
med_shelf_life date NOT NULL,
med_notes VARCHAR(255) NULL,
PRIMARY KEY (med_id)
);

-- --------------------
-- prescription table 
-- --------------------
IF OBJECT_ID (N'dbo.prescription',N'U') IS NOT NULL
DROP TABLE dbo.prescription;

CREATE TABLE dbo.prescription
(
pre_id SMALLINT NOT NULL identity(1,1),
pat_id SMALLINT NOT NULL,
med_id SMALLINT NOT NULL,
pre_date DATE NOT NULL,
pre_dosage VARCHAR(255) NOT NULL,
pre_num_refills varchar(3) NOT NULL,
pre_notes VARCHAR(255) NULL,
PRIMARY KEY (pre_id),

--make sure combination of pat_id, med_id, and pre_date is unique 
CONSTRAINT ux_pat_id_med_id_pre_date unique nonclustered
(pat_id ASC, med_id ASC, pre_date ASC),

CONSTRAINT fk_prescription_patient
FOREIGN KEY (pat_id)
REFERENCES dbo.patient (pat_id)
ON DELETE NO ACTION
ON UPDATE CASCADE,

CONSTRAINT fk_prescription_medication
FOREIGN KEY (med_id)
REFERENCES dbo.medication (med_id)
ON DELETE NO ACTION
ON UPDATE CASCADE
);

-- --------------------
-- treatment table
-- --------------------
IF OBJECT_ID (N'dbo.treatment',N'U') IS NOT NULL
DROP TABLE dbo.treatment;

CREATE TABLE dbo.treatment
(
trt_id SMALLINT NOT NULL identity(1,1),
trt_name VARCHAR(255) NOT NULL,
trt_price DECIMAL(8,2) NOT NULL CHECK (trt_price > 0),
trt_notes VARCHAR(255) NULL,
PRIMARY KEY (trt_id)
);

-- ----------------------
-- physician table
-- ----------------------
IF OBJECT_ID (N'dbo.physician',N'U') IS NOT NULL
DROP TABLE dbo.physician;
GO

CREATE TABLE dbo.physician
(
phy_id SMALLINT NOT NULL identity(1,1),
phy_specialty varchar(25) NOT NULL,
phy_fname VARCHAR(15) NOT NULL,
phy_lname VARCHAR(30) NOT NULL,
phy_street VARCHAR(30) NOT NULL,
phy_city VARCHAR(30) NOT NULL,
phy_state CHAR(2) NOT NULL DEFAULT 'FL',
phy_zip CHAR(9) NOT NULL check (phy_zip like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
phy_phone bigint NOT NULL check (phy_phone like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
phy_fax bigint NOT NULL check (phy_fax > 0 and phy_fax <= 9999999999),
phy_email VARCHAR(100) NULL,
phy_url VARCHAR(100) NULL,
phy_notes VARCHAR(255) NULL,
PRIMARY KEY (phy_id),
);

-- ------------------------
-- patient_treatment table
-- ------------------------
IF OBJECT_ID (N'dbo.patient_treatment',N'U') IS NOT NULL
DROP TABLE dbo.patient_treatment;

CREATE TABLE dbo.patient_treatment
(
ptr_id SMALLINT NOT NULL identity(1,1),
pat_id SMALLINT NOT NULL,
phy_id SMALLINT NOT NULL,
trt_id SMALLINT NOT NULL,
ptr_date DATE NOT NULL,
ptr_start TIME(0) NOT NULL,
ptr_end TIME(0) NOT NULL,
ptr_results VARCHAR(255) NULL,
ptr_notes VARCHAR(255) NULL,
PRIMARY KEY (ptr_id),

--make sure combination of pat_id, phy_id, trt_id, and prt_date is unique
CONSTRAINT ux_pat_id_phy_id_trt_id_ptr_date unique nonclustered
(pat_id ASC, phy_id ASC, trt_id ASC, ptr_date ASC),

CONSTRAINT fk_patient_treatment_patient
FOREIGN KEY (pat_id)
REFERENCES dbo.patient(pat_id)
ON DELETE NO ACTION
ON UPDATE CASCADE,

CONSTRAINT fk_patient_treatment_physician
FOREIGN KEY (phy_id)
REFERENCES dbo.physician(phy_id)
ON DELETE NO ACTION
ON UPDATE CASCADE,

CONSTRAINT fk_patient_treatment_treatment
FOREIGN KEY (trt_id)
REFERENCES dbo.treatment(trt_id)
ON DELETE NO ACTION
ON UPDATE CASCADE
);

-- --------------------
-- administration table
-- --------------------
IF OBJECT_ID (N'dbo.administration_lu',N'U') IS NOT NULL
DROP TABLE dbo.administration_lu;

CREATE TABLE dbo.administration_lu
(
pre_id SMALLINT NOT NULL,
ptr_id SMALLINT NOT NULL,
PRIMARY KEY (pre_id, ptr_id),

CONSTRAINT fk_administration_lu_prescription
FOREIGN KEY (pre_id)
REFERENCES dbo.prescription(pre_id)
ON DELETE NO ACTION
ON UPDATE CASCADE,

CONSTRAINT fk_administration_lu_patient_treatment
FOREIGN KEY (ptr_id)
REFERENCES dbo.patient_treatment(ptr_id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
);

--show tables
SELECT * FROM information_schema.tables;

--disable all constraints
EXEC sp_msforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all"

-- ---------------------------
-- data for table dbo.patient
-- ---------------------------
INSERT INTO dbo.patient
(pat_ssn, pat_fname, pat_lname, pat_street, pat_city, pat_state, pat_zip, pat_phone, pat_email, pat_dob, pat_gender, pat_notes)

VALUES
('123456789', 'Carla', 'Vanderbilt', '5133 3rd Road', 'Lake Worth', 'FL', '334908789', 5678901234,'csweeney@yahoo.com', '11-26-1961', 'F', NULL),
('789123488', 'Amanda', 'Lindell', '2241 W. Pensacola Street', 'Tallahassee', 'FL', '777678543', 6784929431, 'amc10c@my.fsu.edu', '04-04-1981', 'F', NULL),
('987456321', 'David', 'Stephens', '1293 Banana Code Drive', 'Panama City', 'FL', '323091234', 7705551234, 'mjowett@comcast.net', '1965-05-15', 'M', NULL),
('365214986', 'Chris', 'Thrombough', '987 Learning Drive', 'Tallahassee', 'FL', '323011234', 4408905678, 'landbeck@fsu.edu', '1969-08-09', 'M', NULL),
('326598236', 'Spencer', 'Moore', '787 Tharpe Road', 'Taliahassee', 'FL', '323061234', 7814929431, 'spencer@my.fsu.edu','1990-08-14','M', NULL);

-- ------------------------
-- Data for dbo.medication
-- ------------------------
INSERT INTO dbo.medication
(med_name, med_price, med_shelf_life, med_notes)

VALUES
('Abilify',200.00,'09-23-2014',NULL),
('Aciphex',125.00,'06-24-2015',NULL),
('Actonel',250.00,'06-25-2016',NULL),
('Actoplus MET',412.00,'06-26-2017',NULL),
('Actos',89.00,'06-27-2018',NULL);

-- -------------------------
-- Data for dbo.presciption
-- -------------------------
INSERT INTO dbo.prescription
(pat_id, med_id, pre_date, pre_dosage, pre_num_refills, pre_notes)

VALUES
(1, 1, '2011-12-01', 'take one per day', '1',NULL),
(1, 2, '2004-12-31', 'take as needed', '2', NULL),
(2, 3, '1999-12-31', 'take two before and after dinner', '1', NULL),
(2, 4, '1999-07-31', 'take one per day', '2', NULL),
(3, 5, '2011-01-01', 'take as needed', '1', NULL);

-- ------------------------
-- Data for dbo.physician
-- ------------------------
INSERT INTO dbo.physician
(phy_specialty, phy_fname, phy_lname, phy_street, phy_city, phy_state, phy_zip, phy_phone, phy_fax, phy_email, phy_url, phy_notes)

VALUES
('family medicine', 'tom', 'smith', '987 peach st', 'tampa', 'FL', '336101234', '9876543210', '7814909810', 'tsmith@gmail.com', 'tsmithfamilymed.com', NULL),
('internal medicine', 'steve', 'williams', '963 plum st', 'miami', 'FL', '435311234', '9657841234', '4049329189', 'swilliams@gmail.com', 'swiliamsmedicine.com', NULL), 
('pediatrician', 'ronald', 'burns', '645 wave circle', 'orlando', 'FL', '332149089', '7709871234', '5674329087', 'rburns@gmail.com', 'rburnspediactrics.com', NULL),
('psychiatrist', 'pete', 'roger', '1233 stadium circle', 'orlando', 'FL', '332147867', '5674321234', '9087651234', 'peteroger@gmail.com', 'progerpysch.com', NULL),
('dermatology', 'dave', 'roger', '645 hard drive', 'miami', 'FL', '545129089', '6785499012', '7818920980', 'droger@gmail.com', 'drogerderma.com', NULL);

-- --------------------------------
--  Data for table dbo.treatment
-- --------------------------------
INSERT INTO dbo.treatment
(trt_name, trt_price, trt_notes)

VALUES
('knee replacement',2000.00,NULL),
('heart transplant',130000.00,NULL),
('hip replacement',40000.00, NULL),
('tonsils removed',5000.00,NULL),
('skin graft',2000.00,NULL);

-- ------------------------------------
-- Data for table dbo.patient_treatment
-- ------------------------------------
INSERT INTO patient_treatment
(pat_id, phy_id, trt_id, ptr_date, ptr_start, ptr_end, ptr_results, ptr_notes)

VALUES
(1,1,1,'2011-12-23','07:09:09','10:12:15','success patient is fine',NULL),
(1,2,2,'2011-12-24','08:08:09','11:12:13','complications patient will repeat procedure at a later time',NULL),
(2,3,3,'2011-12-25','09:08:09','12:12:15','died during surgery',NULL),
(2,4,4,'2011-12-26','10:09:10','13:12:15','success patient is fine',NULL),
(2,5,5,'2011-12-27','11:08:09','14:12:15','complications patient will repeat procedure at a later time', NULL);

-- --------------------------------------
-- Data for table dbo.adminstration_lu
-- --------------------------------------
INSERT INTO dbo.administration_lu
(pre_id, ptr_id)

VALUES (1,1),(2,2),(3,3),(4,4),(5,5);

--enable all constraints 
exec sp_msforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all"

/* first check belongs with WITH
(ensures data gets checked for consistency when activating constraint)

second check with constraint
(type of constraint)
*/

-- show data
select * from dbo.patient;
select * from dbo.medication;
select * from dbo.prescription;
select * from dbo.physician;
select * from dbo.treatment;
select * from dbo.patient_treatment;
select * from dbo.administration_lu;

-- 5a
use rt20g;
go

begin transaction;
select pat_fname, pat_lname, pat_notes, med_name, med_shelf_life, pre_dosage, pre_num_refills
from medication m
join prescription pr on pr.med_id = m.med_id
join patient p on pr.pat_id = p.pat_id
order by med_price desc;
commit;

--5b
use rt20g;
go

IF OBJECT_ID (N'dbo.v_physician_patient_treatments', N'V') IS NOT NULL
DROP VIEW dbo.v_physician_patient_treatments;
GO

create view dbo.v_physician_patient_treatments as
select phy_fname, phy_lname, trt_name, trt_price, ptr_results, ptr_date, ptr_start, ptr_end
from physician p, patient_treatment pt, treatment t
where p.phy_id = pt.phy_id
and pt.trt_id = t.trt_id;
go

select * from dbo.v_physician_patient_treatments order by trt_price desc;
go

SELECT * FROM information_schema.tables;
go

--5c
use rt20g;
go

IF OBJECT_ID('AddRecord') IS NOT NULL
DROP PROCEDURE AddRecord;
go

CREATE PROCEDURE dbo.AddRecord
(
@patid SMALLINT,
@phyid SMALLINT,
@trtid SMALLINT,
@ptrdate DATE,
@ptrstart TIME,
@ptrend TIME,
@ptrresults VARCHAR(255),
@ptrnotes VARCHAR(255)
) AS
insert into dbo.patient_treatment
(pat_id, phy_id, trt_id, ptr_date, ptr_start, ptr_end, ptr_results, ptr_notes)
values
(@patid, @phyid, @trtid, @ptrdate, @ptrstart, @ptrend, @ptrresults, @ptrnotes);

select * from dbo.v_physician_patient_treatments;
GO

EXEC dbo.AddRecord 5, 5, 5, '2013-04-23', '11:00:00', '12:30:00', 'released', 'ok';

--5d
begin transaction;
select * from dbo.administration_lu;
delete from dbo.administration_lu where pre_id = 5 and ptr_id = 10;
select * from dbo.administration_lu;
commit;

--5e
use rt20g;
go

IF OBJECT_ID('dbo.UpdatePatient') IS NOT NULL
DROP PROCEDURE dbo.UpdatePatient;
GO

CREATE PROCEDURE dbo.UpdatePatient
(
@patid SMALLINT,
@patstreet VARCHAR(30),
@patcity VARCHAR(30),
@patstate CHAR(2),
@patzip CHAR(9),
@patphone bigint,
@patemail VARCHAR(100),
@patnotes VARCHAR(45)
) AS

--check data before select * from dbo.patient;
update dbo.patient
set
pat_street=@patstreet,
pat_city=@patcity,
pat_state=@patstate,
pat_zip=@patzip,
pat_phone=@patphone,
pat_email=@patemail,
pat_notes=@patnotes
where
pat_id=@patid;

--check data after
select * from dbo.patient;
GO

--call stored procedure
EXEC dbo.UpdatePatient
3,
'1600 Pennsylvania Avenue NW',
'Washington',
'DC',
'205001234',
2024561111,
'comments@whitehouse.gov',
'Was an IT developer--got a demotion! :)';
go

--5f
EXEC sp_help 'dbo.patient_treatment';
ALTER TABLE dbo.patient_treatment add ptr_prognosis varchar(255) NULL default 'testing';
EXEC sp_help 'dbo.patient_treatment';