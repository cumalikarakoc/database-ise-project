/*-------------------------------------------------------------*\
|			Constraint Test Script			|
|---------------------------------------------------------------|
|	Gemaakt door: 	Cumali karakoç,				|
|			Simon van Noppen,			|
|			Henkie van den Oord,			|
|			Jeroen Rikken,				|
|			Rico Salemon				|
|	Versie:		1.0					|
|	Gemaakt op:	5/7/2019 13:42				|
\*-------------------------------------------------------------*/

/*===== CONSTRAINT 3 PaidHasInvoice =====*/
/* Tests should pass upon inserting a paid order or updating an order state to paid.*/
-- insert
BEGIN TRANSACTION;
INSERT INTO invoice VALUES('1');
INSERT INTO supplier VALUES('jumbo', '123213', 'ijssellaan');
INSERT INTO "ORDER" VALUES(1, 'jumbo', 'paid', '2019-12-12', '1');
ROLLBACK;

-- update 
BEGIN TRANSACTION;
INSERT INTO invoice VALUES('1');
INSERT INTO supplier VALUES('jumbo', '123213', 'ijssellaan');
INSERT INTO "ORDER" VALUES(1, 'jumbo', 'paid', '2019-12-12', '1');
UPDATE "ORDER" SET state = 'paid', invoice_id = '1';
ROLLBACK;


/* Tests should raise a check constraint error if order is paid and no invoice is associated*/
--insert
BEGIN TRANSACTION;
INSERT INTO invoice VALUES('1');
INSERT INTO supplier VALUES('jumbo', '123213', 'ijssellaan');
INSERT INTO "ORDER" VALUES(1, 'jumbo', 'paid', '2019-12-12', null);
ROLLBACK;

--update 
BEGIN TRANSACTION;
INSERT INTO invoice VALUES('1');
INSERT INTO supplier VALUES('jumbo', '123213', 'ijssellaan');
INSERT INTO "ORDER" VALUES(1, 'jumbo', 'placed', '2019-12-12', null);
UPDATE "ORDER" SET invoice_id = '1';
ROLLBACK;

/* Tests should not pass if state is not paid and an invoice is attached to the order. */
--insert
BEGIN TRANSACTION;
INSERT INTO invoice VALUES('1');
INSERT INTO supplier VALUES('jumbo', '123213', 'ijssellaan');
INSERT INTO "ORDER" VALUES(1, 'jumbo', 'placed', '2019-12-12', 1);
ROLLBACK;

--update 
BEGIN TRANSACTION;
INSERT INTO invoice VALUES('1');
INSERT INTO supplier VALUES('jumbo', '123213', 'ijssellaan');
INSERT INTO "ORDER" VALUES(1, 'jumbo', 'placed', '2019-12-12', 1);
UPDATE "ORDER" SET state = 'awaiting payment', invoice_id = '1';
ROLLBACK;

/*===== Constraint 7 LoanType =====*/
/* Tests should pass when loan type 'to' is inserted or updated */
-- insert
begin transaction;
-- drop fk constraints
alter table exchange drop constraint fk_animal_exchange;
-- insert
insert into exchange values
(1,'10-10-18','12-12-18',null,'to','kuala lumper');
rollback;
 
-- update
begin transaction;
-- drop fk constraints
alter table exchange drop constraint fk_animal_exchange;
-- insert
insert into exchange values
(1,'10-10-18','12-12-18',null,'from','kuala lumper');
update exchange
set loan_type = 'to';
rollback; 

/* Tests should pass when loan type 'from' is inserted or updated */
-- insert
begin transaction;
-- drop fk constraints
alter table exchange drop constraint fk_animal_exchange;
-- insert
insert into exchange values
(1,'10-10-18','12-12-18',null,'from','kuala lumper');
rollback;
 
-- update
begin transaction;
-- drop fk constraints
alter table exchange drop constraint fk_animal_exchange;
-- insert
insert into exchange values
(1,'10-10-18','12-12-18',null,'to','kuala lumper');
update exchange
set loan_type = 'from';
rollback; 

/* Tests should fail when loan type is not 'to' or 'from' inserted or updated */
-- insert
begin transaction;
-- drop fk constraints
alter table exchange drop constraint fk_animal_exchange;
-- insert
insert into exchange values
(1,'10-10-18','12-12-18',null,'tow','kuala lumper');
rollback;
 
-- update
begin transaction;
-- drop fk constraints
alter table exchange drop constraint fk_animal_exchange;
-- insert
insert into exchange values
(1,'10-10-18','12-12-18',null,'from','kuala lumper');
update exchange
set loan_type = 'tow';
rollback; 

/* ============= */