set foreign_key_checks=0;

-- -----------------------------------------------------
-- Table category
-- -----------------------------------------------------
DROP TABLE IF EXISTS category ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS category (
  cat_id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  cat_type ENUM('housing','food','transportation','charity','investment','insurance','clothing','saving','health','personal','recreation','debt','school','childcare','salary','bonus','pension','social security','unemployment','disability','royalty','interest','dividend','tax return','gift','child support','alimony','award','grant','scholarships','inheritance','misc') NOT NULL COMMENT '		',
  cat_notes VARCHAR(255) NULL,
  PRIMARY KEY (cat_id))
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table institution
-- -----------------------------------------------------
DROP TABLE IF EXISTS institution ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS institution (
  ins_id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  ins_name VARCHAR(30) NOT NULL,
  ins_street VARCHAR(30) NOT NULL,
  ins_city VARCHAR(30) NOT NULL,
  ins_state CHAR(2) NOT NULL,
  ins_zip char(9) NOT NULL,
  ins_phone BIGINT UNSIGNED NOT NULL,
  ins_email VARCHAR(100) NOT NULL,
  ins_url VARCHAR(100) NOT NULL,
  ins_contact VARCHAR(45) NULL COMMENT 'person\'s full name',
  ins_notes VARCHAR(255) NULL,
  PRIMARY KEY (ins_id))
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table account
-- -----------------------------------------------------
DROP TABLE IF EXISTS account ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS account (
  act_id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  act_type VARCHAR(20) NOT NULL COMMENT 'checking, savings, loan, investment, bonds, etc.',
  act_notes VARCHAR(255) NULL,
  PRIMARY KEY (act_id))
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table user
-- -----------------------------------------------------
DROP TABLE IF EXISTS user ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS user (
  usr_id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  usr_fname VARCHAR(15) NOT NULL,
  usr_lname VARCHAR(30) NOT NULL,
  usr_street VARCHAR(30) NOT NULL,
  usr_city VARCHAR(30) NOT NULL,
  usr_state CHAR(2) NOT NULL,
  usr_zip char(9) NOT NULL,
  usr_phone BIGINT UNSIGNED NOT NULL,
  usr_email VARCHAR(100) NULL,
  usr_notes VARCHAR(255) NULL,
  PRIMARY KEY (usr_id))
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table source
-- -----------------------------------------------------
DROP TABLE IF EXISTS source ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS source (
  src_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  usr_id TINYINT UNSIGNED NOT NULL,
  ins_id TINYINT UNSIGNED NOT NULL,
  act_id TINYINT UNSIGNED NOT NULL,
  src_start_date DATE NOT NULL,
  src_end_date DATE NULL,
  src_notes VARCHAR(255) NULL,
  PRIMARY KEY (src_id),
  
  -- create indexes for FKS (Note: Modern DBMSs automatically do this!)
  INDEX idx_source_institution (ins_id ASC),
  INDEX idx_source_account (act_id ASC),
  INDEX idx_source_user (usr_id ASC),
  
  -- create unique index to prevent spurious data values 
  UNIQUE INDEX ux_usr_ins_act (usr_id ASC, act_id ASC, ins_id ASC),
  
  -- create FKS
  CONSTRAINT fk_source_institution
    FOREIGN KEY (ins_id)
    REFERENCES institution (ins_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    
  CONSTRAINT fk_source_account
    FOREIGN KEY (act_id)
    REFERENCES account (act_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    
  CONSTRAINT fk_source_person
    FOREIGN KEY (usr_id)
    REFERENCES user (usr_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Table transaction
-- -----------------------------------------------------
DROP TABLE IF EXISTS transaction ;

SHOW WARNINGS;
CREATE TABLE IF NOT EXISTS transaction (
  trn_id MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT,
  src_id SMALLINT UNSIGNED NOT NULL,
  cat_id TINYINT UNSIGNED NOT NULL,
  trn_type ENUM('credit','debit') NOT NULL,
  trn_method VARCHAR(15) NOT NULL COMMENT 'for example, atm, pos, check number, transfer, bank, etc.',
  trn_amt DECIMAL(7,2) NOT NULL,
  trn_date DATETIME NOT NULL,
  trn_notes VARCHAR(255) NULL,
  PRIMARY KEY (trn_id),

  -- create indexes for FKS (Note: Modern DBMSs automatically do this!)
  INDEX idx_transaction_category (cat_id ASC),
  INDEX idx_transaction_source (src_id ASC),

  -- create FKS
  CONSTRAINT fk_transaction_category
    FOREIGN KEY (cat_id)
    REFERENCES category (cat_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
    
  CONSTRAINT fk_transaction_source1
    FOREIGN KEY (src_id)
    REFERENCES source (src_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SHOW WARNINGS;

-- -----------------------------------------------------
-- Data for table category
-- -----------------------------------------------------
START TRANSACTION;

INSERT INTO category (cat_id, cat_type, cat_notes) VALUES (DEFAULT, 'housing', NULL);
INSERT INTO category (cat_id, cat_type, cat_notes) VALUES (DEFAULT, 'food', NULL);
INSERT INTO category (cat_id, cat_type, cat_notes) VALUES (DEFAULT, 'transportation', NULL);
INSERT INTO category (cat_id, cat_type, cat_notes) VALUES (DEFAULT, 'insurance', NULL);
INSERT INTO category (cat_id, cat_type, cat_notes) VALUES (DEFAULT, 'personal', NULL);
INSERT INTO category (cat_id, cat_type, cat_notes) VALUES (DEFAULT, 'recreation', NULL);
INSERT INTO category (cat_id, cat_type, cat_notes) VALUES (DEFAULT, 'clothing', NULL);
INSERT INTO category (cat_id, cat_type, cat_notes) VALUES (DEFAULT, 'saving', NULL);
INSERT INTO category (cat_id, cat_type, cat_notes) VALUES (DEFAULT, 'health', NULL);
INSERT INTO category (cat_id, cat_type, cat_notes) VALUES (DEFAULT, 'investment', NULL);
INSERT INTO category (cat_id, cat_type, cat_notes) VALUES (DEFAULT, 'debt', NULL);
INSERT INTO category (cat_id, cat_type, cat_notes) VALUES (DEFAULT, 'school', NULL);
INSERT INTO category (cat_id, cat_type, cat_notes) VALUES (DEFAULT, 'childcare', NULL);
INSERT INTO category (cat_id, cat_type, cat_notes) VALUES (DEFAULT, 'misc', NULL);

COMMIT;


-- -----------------------------------------------------
-- Data for table institution
-- -----------------------------------------------------
START TRANSACTION;

INSERT INTO institution (ins_id, ins_name, ins_street, ins_city, ins_state, ins_zip, ins_phone, ins_email, ins_url, ins_contact, ins_notes) VALUES (DEFAULT, 'Regions', '2320 Tennessee St', 'Tallahassee', 'FL', 323047634, 8005551234, 'bob@regions.com', 'http://www.regions.com', 'Bob Flounder', NULL);
INSERT INTO institution (ins_id, ins_name, ins_street, ins_city, ins_state, ins_zip, ins_phone, ins_email, ins_url, ins_contact, ins_notes) VALUES (DEFAULT, 'Wells Fargo', '87413 Pennsacola', 'Tallahassee', 'FL', 323021251, 8005554321, 'chiggins@wellsfargo.com', 'http://www.wellsfargo.com', 'Cheryl Higgins', NULL);
INSERT INTO institution (ins_id, ins_name, ins_street, ins_city, ins_state, ins_zip, ins_phone, ins_email, ins_url, ins_contact, ins_notes) VALUES (DEFAULT, 'SunTrust', '17823 South Ave.', 'Atlanta', 'GA', 303538974, 8005556789, 'contact@suntrust.com', 'http://www.suntrust.com', 'Louise McFlaggen', NULL);
INSERT INTO institution (ins_id, ins_name, ins_street, ins_city, ins_state, ins_zip, ins_phone, ins_email, ins_url, ins_contact, ins_notes) VALUES (DEFAULT, 'Great Lakes Loan Group', '2401 International Ln', 'Madison', 'WI', 537043121, 8002364300, 'info@gllg.com', 'http://www.gllg.com', 'John Redland', NULL);
INSERT INTO institution (ins_id, ins_name, ins_street, ins_city, ins_state, ins_zip, ins_phone, ins_email, ins_url, ins_contact, ins_notes) VALUES (DEFAULT, 'TIAA-CREF', '730 3rd Ave.', 'NY', 'NY', 100172093, 8007191185, 'info@tiaacreff.com', 'http://www.tiaacreff.com', 'Peter Bane', NULL);

COMMIT;


-- -----------------------------------------------------
-- Data for table account
-- -----------------------------------------------------
START TRANSACTION;

INSERT INTO account (act_id, act_type, act_notes) VALUES (DEFAULT, 'checking', NULL);
INSERT INTO account (act_id, act_type, act_notes) VALUES (DEFAULT, 'savings', NULL);
INSERT INTO account (act_id, act_type, act_notes) VALUES (DEFAULT, 'mortgage', NULL);
INSERT INTO account (act_id, act_type, act_notes) VALUES (DEFAULT, 'school loan', NULL);
INSERT INTO account (act_id, act_type, act_notes) VALUES (DEFAULT, 'investment', NULL);
INSERT INTO account (act_id, act_type, act_notes) VALUES (DEFAULT, 'credit card', NULL);

COMMIT;


-- -----------------------------------------------------
-- Data for table user
-- -----------------------------------------------------
START TRANSACTION;

INSERT INTO user (usr_id, usr_fname, usr_lname, usr_street, usr_city, usr_state, usr_zip, usr_phone, usr_email, usr_notes) VALUES (DEFAULT, 'John', 'Doe', '123 Main St', 'Des Moines', 'IA', 645320123, 5713247659, 'jdoe@aol.com', NULL);
INSERT INTO user (usr_id, usr_fname, usr_lname, usr_street, usr_city, usr_state, usr_zip, usr_phone, usr_email, usr_notes) VALUES (DEFAULT, 'Jane', 'Parker', '85378 Elm St.', 'Detroit', 'MI', 482347821, 3136579012, 'jparker@yahoo.com', NULL);
INSERT INTO user (usr_id, usr_fname, usr_lname, usr_street, usr_city, usr_state, usr_zip, usr_phone, usr_email, usr_notes) VALUES (DEFAULT, 'Bonnie', 'Val Kyries', '39167 Alabama Ave', 'Chicago', 'IL', 500147863, 5016749831, 'bvalkyries@att.net', NULL);
INSERT INTO user (usr_id, usr_fname, usr_lname, usr_street, usr_city, usr_state, usr_zip, usr_phone, usr_email, usr_notes) VALUES (DEFAULT, 'Billy', 'Joel', '503 Foothill Blvd.', 'Sacramento', 'CA', 908675301, 9086753018, 'bjoel@comcast.net', NULL);
INSERT INTO user (usr_id, usr_fname, usr_lname, usr_street, usr_city, usr_state, usr_zip, usr_phone, usr_email, usr_notes) VALUES (DEFAULT, 'Johnny', 'Depp', '123 4th Ave', 'New York', 'NY', 200256743, 1001784526, 'jdepp@horizon.com', NULL);

COMMIT;


-- -----------------------------------------------------
-- Data for table source
-- -----------------------------------------------------
START TRANSACTION;

INSERT INTO source (src_id, usr_id, ins_id, act_id, src_start_date, src_end_date, src_notes) VALUES (DEFAULT, 1, 1, 1, '2001-03-31', NULL, NULL);
INSERT INTO source (src_id, usr_id, ins_id, act_id, src_start_date, src_end_date, src_notes) VALUES (DEFAULT, 1, 1, 2, '2001-05-07', NULL, NULL);
INSERT INTO source (src_id, usr_id, ins_id, act_id, src_start_date, src_end_date, src_notes) VALUES (DEFAULT, 2, 1, 3, '2003-01-02', '2010-07-11', NULL);
INSERT INTO source (src_id, usr_id, ins_id, act_id, src_start_date, src_end_date, src_notes) VALUES (DEFAULT, 2, 2, 4, '2005-11-19', NULL, NULL);
INSERT INTO source (src_id, usr_id, ins_id, act_id, src_start_date, src_end_date, src_notes) VALUES (DEFAULT, 3, 2, 5, '2002-09-09', '2011-02-24', NULL);
INSERT INTO source (src_id, usr_id, ins_id, act_id, src_start_date, src_end_date, src_notes) VALUES (DEFAULT, 4, 2, 1, '2003-01-02', NULL, NULL);
INSERT INTO source (src_id, usr_id, ins_id, act_id, src_start_date, src_end_date, src_notes) VALUES (DEFAULT, 5, 3, 2, '2004-06-19', '2007-11-09', NULL);
INSERT INTO source (src_id, usr_id, ins_id, act_id, src_start_date, src_end_date, src_notes) VALUES (DEFAULT, 3, 4, 1, '2006-12-31', NULL, NULL);
INSERT INTO source (src_id, usr_id, ins_id, act_id, src_start_date, src_end_date, src_notes) VALUES (DEFAULT, 4, 5, 2, '2007-02-14', NULL, NULL);
INSERT INTO source (src_id, usr_id, ins_id, act_id, src_start_date, src_end_date, src_notes) VALUES (DEFAULT, 5, 4, 3, '2008-04-07', NULL, NULL);

COMMIT;


-- -----------------------------------------------------
-- Data for table transaction
-- -----------------------------------------------------
START TRANSACTION;

INSERT INTO transaction (trn_id, src_id, cat_id, trn_type, trn_method, trn_amt, trn_date, trn_notes) VALUES (DEFAULT, 2, 1, 'credit', 'auto', 2235.09, '2002-01-07 11:59:59', NULL);
INSERT INTO transaction (trn_id, src_id, cat_id, trn_type, trn_method, trn_amt, trn_date, trn_notes) VALUES (DEFAULT, 3, 2, 'credit', 'atm', 785.34, '2002-06-09 05:12:51', NULL);
INSERT INTO transaction (trn_id, src_id, cat_id, trn_type, trn_method, trn_amt, trn_date, trn_notes) VALUES (DEFAULT, 4, 3, 'debit', 'pos', 153.67, '2003-06-09 10:19:06', NULL);
INSERT INTO transaction (trn_id, src_id, cat_id, trn_type, trn_method, trn_amt, trn_date, trn_notes) VALUES (DEFAULT, 1, 4, 'debit', '1342', 1095.85, '2003-06-09 23:01:00', 'check no.');
INSERT INTO transaction (trn_id, src_id, cat_id, trn_type, trn_method, trn_amt, trn_date, trn_notes) VALUES (DEFAULT, 1, 1, 'debit', '518', 22.85, '2007-05-09 12:05:32', 'check no.');
INSERT INTO transaction (trn_id, src_id, cat_id, trn_type, trn_method, trn_amt, trn_date, trn_notes) VALUES (DEFAULT, 3, 2, 'credit', 'bank', 56.92, '2004-02-13 09:34:06', 'in bank');
INSERT INTO transaction (trn_id, src_id, cat_id, trn_type, trn_method, trn_amt, trn_date, trn_notes) VALUES (DEFAULT, 2, 3, 'debit', '834', 816.24, '2005-09-23 10:31:23', 'check no.');
INSERT INTO transaction (trn_id, src_id, cat_id, trn_type, trn_method, trn_amt, trn_date, trn_notes) VALUES (DEFAULT, 5, 2, 'debit', 'pos', 983.5, '2006-03-17 18:29:04', NULL);
INSERT INTO transaction (trn_id, src_id, cat_id, trn_type, trn_method, trn_amt, trn_date, trn_notes) VALUES (DEFAULT, 1, 5, 'credit', 'auto', 763.21, '2006-04-01 21:46:08', NULL);
INSERT INTO transaction (trn_id, src_id, cat_id, trn_type, trn_method, trn_amt, trn_date, trn_notes) VALUES (DEFAULT, 4, 1, 'credit', 'atm', 815.67, '2008-08-21 17:09:36', NULL);

COMMIT;

set foreign_key_checks=1;
