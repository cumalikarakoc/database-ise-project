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

/*===== CONSTRAINT 2 OtherThanPlacedHasDelivery =====*/
/* test should pass upon inserting an order with state placed or updating an order state to placed
because there is a delivery note*/
-- insert
begin transaction;
insert into supplier values
('Jumbo','123456789','Ruitenberglaan 27 Arnhem');
insert into "ORDER" values
(1,'Jumbo','Placed','12-12-18',null);
insert into delivery values
(1,1,'message',null);
rollback;

--update
begin transaction;
insert into supplier values
('Jumbo','123456789','Ruitenberglaan 27 Arnhem');
insert into "ORDER" values
(1,'Jumbo','Placed','12-12-18',null);
insert into delivery values
(1,1,'message',null);
update "ORDER"
set state = 'Awaiting payment';
update "ORDER"
set state = 'Placed';
rollback;

/* test should pass upon inserting an order with state other than placed or updating an order state to something other than placed
because there is a delivery note*/
-- insert cannot be done cause the delivery note foreign key is not nullable

--update
begin transaction;
insert into supplier values
('Jumbo','123456789','Ruitenberglaan 27 Arnhem');
insert into "ORDER" values
(1,'Jumbo','Placed','12-12-18',null);
insert into delivery values
(1,1,'message',null);
update "ORDER"
set state = 'Awaiting payment';
rollback;

/* test should fail upon inserting an order with state other than placed or updating an order state to something other than placed
Because the is no delivery note*/
-- insert
begin transaction;
insert into supplier values
('Jumbo','123456789','Ruitenberglaan 27 Arnhem');
insert into "ORDER" values
(1,'Jumbo','Awaiting payment','12-12-18',null);
rollback;

--update
begin transaction;
insert into supplier values
('Jumbo','123456789','Ruitenberglaan 27 Arnhem');
insert into "ORDER" values
(1,'Jumbo','Placed','12-12-18', null);
update "ORDER"
set state = 'Awaiting payment';
rollback;

/* test should pass upon deleting a delivery or updating a delivery
because the order it corresponds to is placed*/
-- delete
begin transaction;
insert into supplier values
('Jumbo','123456789','Ruitenberglaan 27 Arnhem');
insert into "ORDER" values
(1,'Jumbo','Placed','12-12-18', null);
insert into delivery values
(1,1,'message',null);
delete from delivery;
rollback;

--update
begin transaction;
insert into supplier values
('Jumbo','123456789','Ruitenberglaan 27 Arnhem');
insert into "ORDER" values
(1,'Jumbo','Placed','12-12-18', null),
(2,'Jumbo','Placed','10-10-18', null);
insert into delivery values
(1,1,'message',null);
update delivery
set Order_id = 2;
rollback;

/* test should fail upon deleting a delivery or updating a delivery
because the order it correpsonds to is something other than Placed*/
-- delete
begin transaction;
insert into supplier values
('Jumbo','123456789','Ruitenberglaan 27 Arnhem');
insert into "ORDER" values
(1,'Jumbo','Placed','12-12-18', null);
insert into delivery values
(1,1,'message',null);
update "ORDER"
set State = 'Awaiting payment';
delete from delivery;
rollback;

--update
begin transaction;
insert into supplier values
('Jumbo','123456789','Ruitenberglaan 27 Arnhem');
insert into "ORDER" values
(1,'Jumbo','Placed','12-12-18', null),
(2,'Jumbo','Placed','10-10-18', null);
insert into delivery values
(1,1,'message',null);
update "ORDER"
set State = 'Awaiting payment'
where Order_id = '1';
update delivery
set Order_id = 2;
rollback;

/*===== CONSTRAINT 3 PaidHasInvoice =====*/
/* Tests should pass upon inserting a paid order or updating an order state to paid.*/
-- insert
BEGIN TRANSACTION;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
INSERT INTO invoice VALUES('1');
INSERT INTO supplier VALUES('jumbo', '123213', 'ijssellaan');
INSERT INTO "ORDER" VALUES(1, 'jumbo', 'Paid', '2019-12-12', '1');
ROLLBACK;

-- update 
BEGIN TRANSACTION;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
INSERT INTO invoice VALUES('1');
INSERT INTO supplier VALUES('jumbo', '123213', 'ijssellaan');
INSERT INTO "ORDER" VALUES(1, 'jumbo', 'Paid', '2019-12-12', '1');
UPDATE "ORDER" SET state = 'Paid', invoice_id = '1';
ROLLBACK;


/* Tests should raise a check constraint error if order is paid and no invoice is associated*/
--insert
BEGIN TRANSACTION;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
INSERT INTO invoice VALUES('1');
INSERT INTO supplier VALUES('jumbo', '123213', 'ijssellaan');
INSERT INTO "ORDER" VALUES(1, 'jumbo', 'Paid', '2019-12-12', null);
ROLLBACK;

--update 
BEGIN TRANSACTION;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
INSERT INTO invoice VALUES('1');
INSERT INTO supplier VALUES('jumbo', '123213', 'ijssellaan');
INSERT INTO "ORDER" VALUES(1, 'jumbo', 'Placed', '2019-12-12', null);
UPDATE "ORDER" SET invoice_id = '1';
ROLLBACK;

/* Tests should not pass if state is not paid and an invoice is attached to the order. */
--insert
BEGIN TRANSACTION;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
INSERT INTO invoice VALUES('1');
INSERT INTO supplier VALUES('jumbo', '123213', 'ijssellaan');
INSERT INTO "ORDER" VALUES(1, 'jumbo', 'Placed', '2019-12-12', 1);
ROLLBACK;

--update 
BEGIN TRANSACTION;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
INSERT INTO invoice VALUES('1');
INSERT INTO supplier VALUES('jumbo', '123213', 'ijssellaan');
INSERT INTO "ORDER" VALUES(1, 'jumbo', 'Placed', '2019-12-12', 1);
UPDATE "ORDER" SET state = 'Awaiting payment', invoice_id = '1';
ROLLBACK;

/*===== Constraint 5 AnimalGender =====*/
/* Test should pass when inserting or updating animal gender to 'male' */
-- insert
begin transaction;
insert into species values
('Monkey','Things with long arms',null,null,null);
insert into animal values
(1,'male','Abu' ,'Engeland', '12-12-18', 'Monkey'),
(2,'male','Koko','Engeland', '10-10-18', 'Monkey');
rollback;

-- update
begin transaction;
insert into species values
('Monkey','Things with long arms',null,null,null);
insert into animal values
(1,'female','Abu' ,'Engeland', '12-12-18', 'Monkey'),
(2,'female','Koko','Engeland', '10-10-18', 'Monkey');
update animal
set gender_s = 'male';
rollback;

/* Test should pass when inserting or updating animal gender to 'female' */
-- insert
-- insert
begin transaction;
insert into species values
('Monkey','Things with long arms',null,null,null);
insert into animal values
(1,'female','Abu' ,'Engeland', '12-12-18', 'Monkey'),
(2,'female','Koko','Engeland', '10-10-18', 'Monkey');
rollback;

-- update
begin transaction;
insert into species values
('Monkey','Things with long arms',null,null,null);
insert into animal values
(1,'male','Abu' ,'Engeland', '12-12-18', 'Monkey'),
(2,'male','Koko','Engeland', '10-10-18', 'Monkey');
update animal
set gender_s = 'female';
rollback;

/* Test should pass when inserting or updating animal gender to 'other' */
-- insert
begin transaction;
insert into species values
('Monkey','Things with long arms',null,null,null);
insert into animal values
(1,'other','Abu' ,'Engeland', '12-12-18', 'Monkey'),
(2,'other','Koko','Engeland', '10-10-18', 'Monkey');
rollback;

-- update
begin transaction;
insert into species values
('Monkey','Things with long arms',null,null,null);
insert into animal values
(1,'male','Abu' ,'Engeland', '12-12-18', 'Monkey'),
(2,'male','Koko','Engeland', '10-10-18', 'Monkey');
update animal
set gender_s = 'other';
rollback;

/* Test should fail when inserting or updating animal gender to something other than 'male', 'female', 'other' */
-- insert
begin transaction;
insert into species values
('Monkey','Things with long arms',null,null,null);
insert into animal values
(1,'male','Abu' ,'Engeland', '12-12-18', 'Monkey'),
(2,'something','Koko','Engeland', '10-10-18', 'Monkey');
rollback;

-- update
begin transaction;
insert into species values
('Monkey','Things with long arms',null,null,null);
insert into animal values
(1,'male','Abu' ,'Engeland', '12-12-18', 'Monkey'),
(2,'male','Koko','Engeland', '10-10-18', 'Monkey');
update animal
set gender_s = 'something';
rollback;

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

/*===== CONSTRAINT 16 LineItemPrice =====*/
/* Tests should pass upon inserting a line_item or updating an line_item that is 0 or higher.*/

/* Test should pass as the price is higher than 0*/
-- insert
BEGIN TRANSACTION;
INSERT INTO invoice VALUES('p1');
INSERT INTO supplier VALUES('jumbo', '123123', 'ijssellaan');
INSERT INTO "ORDER" VALUES('o123', 'jumbo', 'paid', '2019-12-12', 'p1');
INSERT INTO food_kind VALUES('banaan');
INSERT INTO line_item VALUES('o123', 'banaan', 1, 10);
ROLLBACK;

-- update
BEGIN TRANSACTION;
INSERT INTO invoice VALUES('p1');
INSERT INTO supplier VALUES('jumbo', '123123', 'ijssellaan');
INSERT INTO "ORDER" VALUES('o123', 'jumbo', 'paid', '2019-12-12', 'p1');
INSERT INTO food_kind VALUES('banaan');
INSERT INTO line_item VALUES('o123', 'banaan', 1, 10);
UPDATE line_item SET price = 20;
ROLLBACK;


/* Test should pass as the price is equal to 0*/
-- insert
BEGIN TRANSACTION;
INSERT INTO invoice VALUES('p1');
INSERT INTO supplier VALUES('jumbo', '123123', 'ijssellaan');
INSERT INTO "ORDER" VALUES('o123', 'jumbo', 'paid', '2019-12-12', 'p1');
INSERT INTO food_kind VALUES('banaan');
INSERT INTO line_item VALUES('o123', 'banaan', 0, 10);
ROLLBACK;

-- update
BEGIN TRANSACTION;
INSERT INTO invoice VALUES('p1');
INSERT INTO supplier VALUES('jumbo', '123123', 'ijssellaan');
INSERT INTO "ORDER" VALUES('o123', 'jumbo', 'paid', '2019-12-12', 'p1');
INSERT INTO food_kind VALUES('banaan');
INSERT INTO line_item VALUES('o123', 'banaan', 1, 10);
UPDATE line_item SET price = 0;
ROLLBACK;


 /*Test should fail as the price is lower than 0*/
-- insert
BEGIN TRANSACTION;
INSERT INTO invoice VALUES('p1');
INSERT INTO supplier VALUES('jumbo', '123123', 'ijssellaan');
INSERT INTO "ORDER" VALUES('o123', 'jumbo', 'paid', '2019-12-12', 'p1');
INSERT INTO food_kind VALUES('banaan');
INSERT INTO line_item VALUES('o123', 'banaan', -1, 10);
ROLLBACK;

-- update
BEGIN TRANSACTION;
INSERT INTO invoice VALUES('p1');
INSERT INTO supplier VALUES('jumbo', '123123', 'ijssellaan');
INSERT INTO "ORDER" VALUES('o123', 'jumbo', 'paid', '2019-12-12', 'p1');
INSERT INTO food_kind VALUES('banaan');
INSERT INTO line_item VALUES('o123', 'banaan', 1, 10);
UPDATE line_item SET price = -1;
ROLLBACK;

/* ====== CONSTRAINT 21 SpeciesWeight ======*/
/* Tests should pass upon insert a species gender or updating it */
--Insert
BEGIN TRANSACTION;
INSERT INTO species VALUES('Apes', 'Are apes', 'Apes', 'Apes', '');
INSERT INTO species_gender VALUES('Apes', 'male', 9.5, 009.5);
ROLLBACK;

--Update
BEGIN TRANSACTION;
INSERT INTO species VALUES('Apes', 'Are apes', 'Apes', 'Apes', '');
INSERT INTO species_gender VALUES('Apes', 'male', 9.5, 009.5);
UPDATE species_gender set average_weight = 10.1 where english_name = 'Apes';
ROLLBACK;

/* Tests should raise a check constraint error upon insert a species gender or updating it when the weight is 0 */
--Insert
BEGIN TRANSACTION;
INSERT INTO species VALUES('Apes', 'Are apes', 'Apes', 'Apes', '');
INSERT INTO species_gender VALUES('Apes', 'male', 0, 009.5);
ROLLBACK;

--Update
BEGIN TRANSACTION;
INSERT INTO species VALUES('Apes', 'Are apes', 'Apes', 'Apes', '');
INSERT INTO species_gender VALUES('Apes', 'male', 9.5, 009.5);
UPDATE species_gender set average_weight = 0 where english_name = 'Apes';
ROLLBACK;

/* Tests should raise a check constraint error upon insert a species gender or updating it when the weight is lower then 0 */
--Insert
BEGIN TRANSACTION;
INSERT INTO species VALUES('Apes', 'Are apes', 'Apes', 'Apes', '');
INSERT INTO species_gender VALUES('Apes', 'male', -5, 009.5);
ROLLBACK;

--Update
BEGIN TRANSACTION;
INSERT INTO species VALUES('Apes', 'Are apes', 'Apes', 'Apes', '');
INSERT INTO species_gender VALUES('Apes', 'male', 9.5, 009.5);
UPDATE species_gender set average_weight = -5 where english_name = 'Apes';
ROLLBACK;
/*================*/
