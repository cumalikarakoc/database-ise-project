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
/* Constraint 1 OrderStates Test */
/* These inserts and updates pass when one of the four accepted states is inserted.*/
--insert
begin transaction;
alter table "ORDER"
drop constraint fk_order_supplier;

insert into "ORDER" values ('Order1', 'supplier', 'Paid', current_date, null),
('Order2', 'Supplier2', 'Awaiting payment', current_date, null),
('Order3', 'Supplier2', 'Not complete', current_date, null),
('Order4', 'Supplier4', 'Placed', current_date, null);
rollback transaction;

--update
begin transaction;
alter table "ORDER"
drop constraint fk_order_supplier;

insert into "ORDER" values ('Order1', 'supplier', 'Awaiting payment', current_date, null);

update "ORDER"
set state = 'Paid';
rollback transaction;


/*The following inserts and updates will fail because the state is not allowed*/
--insert
begin transaction;
alter table "ORDER"
drop constraint fk_order_supplier;

insert into "ORDER" values ('Order1', 'Supplier', 'Placed', current_date, null),
('Order2', 'Supplier2', 'Canceled', current_date, null);
rollback transaction;

--update
begin transaction;
alter table "ORDER"
drop constraint fk_order_supplier;

insert into "ORDER" values ('Order1', 'Supplier', 'Placed', current_date, null);

update "ORDER"
set State = 'Removed';
rollback transaction;

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

/*===== CONSTRAINT 10 SpottedAfterRelease ===== */
/*Test should pass if the spot_date  is same as the the reintroduction_date or later than the reintroduction_date.*/
-- insert
begin transaction;
alter table reintroduction drop constraint if exists fk_animal_reintroduction;
alter table spotted drop constraint if exists fk_animal_spotted;

insert into reintroduction values('an-1', '2018-10-05', 'location', null);
insert into reintroduction values('an-1', '2019-11-05', 'location', null);
insert into spotted values('an-1', '2018-10-05');
rollback;

--update
begin transaction;
alter table reintroduction drop constraint if exists fk_animal_reintroduction;
alter table spotted drop constraint if exists fk_animal_spotted;

insert into reintroduction values('an-1', '2018-10-05', 'location', null);
insert into reintroduction values('an-1', '2019-11-05', 'location', null);
insert into spotted values('an-1', '2018-10-05');

update spotted set spot_date = '2018-11-06' where animal_id = 'an-1';
rollback;

/*Test should raise an error if spot_date is before the date when the animal is reintroduced in wild.*/
--insert
begin transaction;
alter table reintroduction drop constraint if exists fk_animal_reintroduction;
alter table spotted drop constraint if exists fk_animal_spotted;

insert into reintroduction values('an-1', '2018-12-12', 'location', null);
insert into reintroduction values('an-1', '2019-11-05', 'location', null);
insert into spotted values('an-1', '2018-10-11');
rollback

--update
begin transaction;
alter table reintroduction drop constraint if exists fk_animal_reintroduction;
alter table spotted drop constraint if exists fk_animal_spotted;

insert into reintroduction values('an-1', '2018-10-05', 'location', null);
insert into reintroduction values('an-1', '2019-11-05', 'location', null);
insert into spotted values('an-1', '2018-10-05');

update spotted set spot_date = '2018-04-04' where animal_id = 'an-1'; 
rollback;

/*Test should pass if the there is still a reintroduction_date before the oldest spot_date after deleting or updating.*/
-- update
begin transaction;
alter table reintroduction drop constraint if exists fk_animal_reintroduction;
alter table spotted drop constraint if exists fk_animal_spotted;

insert into reintroduction values('an-1', '2017-04-04', 'location', null);
insert into reintroduction values('an-1', '2018-12-12', 'location', null);
insert into spotted values('an-1', '2019-01-01');

update reintroduction set reintroduction_date = '2019-05-05' where animal_id = 'an-1' and reintroduction_date = '2017-04-04';
rollback;

-- delete
begin transaction;
alter table reintroduction drop constraint if exists fk_animal_reintroduction;
alter table spotted drop constraint if exists fk_animal_spotted;

insert into reintroduction values('an-1', '2017-04-04', 'location', null);
insert into reintroduction values('an-1', '2018-12-12', 'location', null);
insert into spotted values('an-1', '2019-01-01');

delete from reintroduction where animal_id = 'an-1' and reintroduction_date = '2017-04-04';
rollback;

/*Test should raise an error if there is no reintroduction_date before the oldest spot_date*/
-- update
begin transaction;
alter table reintroduction drop constraint if exists fk_animal_reintroduction;
alter table spotted drop constraint if exists fk_animal_spotted;

insert into reintroduction values('an-1', '2017-04-04', 'location', null);
insert into reintroduction values('an-1', '2018-12-12', 'location', null);
insert into spotted values('an-1', '2018-01-01');

update reintroduction set reintroduction_date = '2019-05-05' where animal_id = 'an-1' and reintroduction_date = '2017-04-04';
rollback;

-- delete
begin transaction;
alter table reintroduction drop constraint if exists fk_animal_reintroduction;
alter table spotted drop constraint if exists fk_animal_spotted;

insert into reintroduction values('an-1', '2017-04-04', 'location', null);
insert into reintroduction values('an-1', '2019-04-03', 'location', null);
insert into spotted values('an-1', '2019-01-01');

delete from reintroduction where animal_id = 'an-1' and reintroduction_date = '2017-04-04';
rollback;

/*===== Constraint 11 AnimalReturned =====*/
/* Tests should pass when return_date is on the same date as exchange_date or later.*/
-- insert
begin transaction;
alter table EXCHANGE drop constraint if exists fk_animal_exchange;

insert into EXCHANGE values('an-1', '2019-01-01', '2019-02-02', 'comments', 'to', 'place');
rollback;

-- update
begin transaction;
alter table EXCHANGE drop constraint if exists fk_animal_exchange;

insert into EXCHANGE values('an-1', '2019-01-01', '2019-02-02', 'comments', 'to', 'place');

update EXCHANGE set return_date = '2019-03-03' where animal_id = 'an-1';
rollback;

/* Tests should fail if return_date is earlier than the exchange_date.*/
-- insert
begin transaction;
alter table EXCHANGE drop constraint if exists fk_animal_exchange;

insert into EXCHANGE values('an-1', '2019-01-01', '2018-11-25', 'comments', 'to', 'place');
rollback;

--update
begin transaction;
alter table EXCHANGE drop constraint if exists fk_animal_exchange;

insert into EXCHANGE values('an-1', '2019-01-01', '2018-11-25', 'comments', 'to', 'place');

update EXCHANGE set exchange_date = '2018-03-03' where animal_id = 'an-1';
rollback;

/*===== CONSTRAINT 15 LineItemWeight =====*/
/* Tests should pass upon inserting a line_item or updating an line_item where the weight is higher than 0.*/

/* Test should pass as the weight is higher than 0*/
-- insert
BEGIN TRANSACTION;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
INSERT INTO invoice VALUES('p1');
INSERT INTO supplier VALUES('jumbo', '123123', 'ijssellaan');
INSERT INTO "ORDER" VALUES('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
INSERT INTO food_kind VALUES('banaan');
INSERT INTO line_item VALUES('o123', 'banaan', 10, 10);
ROLLBACK;

-- update
BEGIN TRANSACTION;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
INSERT INTO invoice VALUES('p1');
INSERT INTO supplier VALUES('jumbo', '123123', 'ijssellaan');
INSERT INTO "ORDER" VALUES('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
INSERT INTO food_kind VALUES('banaan');
INSERT INTO line_item VALUES('o123', 'banaan', 10, 15);
UPDATE line_item SET weight = 10;
ROLLBACK;


/* Test should fail as the weight is equal to 0*/
-- insert
BEGIN TRANSACTION;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
INSERT INTO invoice VALUES('p1');
INSERT INTO supplier VALUES('jumbo', '123123', 'ijssellaan');
INSERT INTO "ORDER" VALUES('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
INSERT INTO food_kind VALUES('banaan');
INSERT INTO line_item VALUES('o123', 'banaan', 10, 0);
ROLLBACK;

-- update
BEGIN TRANSACTION;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
INSERT INTO invoice VALUES('p1');
INSERT INTO supplier VALUES('jumbo', '123123', 'ijssellaan');
INSERT INTO "ORDER" VALUES('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
INSERT INTO food_kind VALUES('banaan');
INSERT INTO line_item VALUES('o123', 'banaan', 10, 10);
UPDATE line_item SET weight = 0;
ROLLBACK;


/*Test should fail as the weight is lower than 0*/
-- insert
BEGIN TRANSACTION;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
INSERT INTO invoice VALUES('p1');
INSERT INTO supplier VALUES('jumbo', '123123', 'ijssellaan');
INSERT INTO "ORDER" VALUES('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
INSERT INTO food_kind VALUES('banaan');
INSERT INTO line_item VALUES('o123', 'banaan', 10, -10);
ROLLBACK;

-- update
BEGIN TRANSACTION;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
INSERT INTO invoice VALUES('p1');
INSERT INTO supplier VALUES('jumbo', '123123', 'ijssellaan');
INSERT INTO "ORDER" VALUES('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
INSERT INTO food_kind VALUES('banaan');
INSERT INTO line_item VALUES('o123', 'banaan', 10, 10);
UPDATE line_item SET weight = -10;
ROLLBACK;


/*===== CONSTRAINT 16 LineItemPrice =====*/
/* Tests should pass upon inserting a line_item or updating an line_item where the price is 0 or higher.*/

/* Test should pass as the price is higher than 0*/
-- insert
BEGIN TRANSACTION;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
INSERT INTO invoice VALUES('p1');
INSERT INTO supplier VALUES('jumbo', '123123', 'ijssellaan');
INSERT INTO "ORDER" VALUES('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
INSERT INTO food_kind VALUES('banaan');
INSERT INTO line_item VALUES('o123', 'banaan', 1, 10);
ROLLBACK;

-- update
BEGIN TRANSACTION;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
INSERT INTO invoice VALUES('p1');
INSERT INTO supplier VALUES('jumbo', '123123', 'ijssellaan');
INSERT INTO "ORDER" VALUES('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
INSERT INTO food_kind VALUES('banaan');
INSERT INTO line_item VALUES('o123', 'banaan', 1, 10);
UPDATE line_item SET price = 20;
ROLLBACK;


/* Test should pass as the price is equal to 0*/
-- insert
BEGIN TRANSACTION;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
INSERT INTO invoice VALUES('p1');
INSERT INTO supplier VALUES('jumbo', '123123', 'ijssellaan');
INSERT INTO "ORDER" VALUES('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
INSERT INTO food_kind VALUES('banaan');
INSERT INTO line_item VALUES('o123', 'banaan', 0, 10);
ROLLBACK;

-- update
BEGIN TRANSACTION;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
INSERT INTO invoice VALUES('p1');
INSERT INTO supplier VALUES('jumbo', '123123', 'ijssellaan');
INSERT INTO "ORDER" VALUES('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
INSERT INTO food_kind VALUES('banaan');
INSERT INTO line_item VALUES('o123', 'banaan', 1, 10);
UPDATE line_item SET price = 0;
ROLLBACK;


 /*Test should fail as the price is lower than 0*/
-- insert
BEGIN TRANSACTION;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
INSERT INTO invoice VALUES('p1');
INSERT INTO supplier VALUES('jumbo', '123123', 'ijssellaan');
INSERT INTO "ORDER" VALUES('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
INSERT INTO food_kind VALUES('banaan');
INSERT INTO line_item VALUES('o123', 'banaan', -1, 10);
ROLLBACK;

-- update
BEGIN TRANSACTION;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
INSERT INTO invoice VALUES('p1');
INSERT INTO supplier VALUES('jumbo', '123123', 'ijssellaan');
INSERT INTO "ORDER" VALUES('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
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