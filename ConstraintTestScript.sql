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
start transaction;
insert into supplier values
('Jumbo','123456789','Ruitenberglaan 27 Arnhem');
insert into "ORDER" values
(1,'Jumbo','placed','12-12-18');
insert into delivery values
(1,1,'message',null);
rollback;

--update
start transaction;
insert into supplier values
('Jumbo','123456789','Ruitenberglaan 27 Arnhem');
insert into "ORDER" values
(1,'Jumbo','placed','12-12-18');
insert into delivery values
(1,1,'message',null);
update "ORDER"
set state = 'other';
update "ORDER"
set state = 'placed';
rollback;

/* test should pass upon inserting an order with state other than placed or updating an order state to something other than placed
because there is a delivery note*/
-- insert cannot be done cause the delivery note foreign key is not nullable

--update
start transaction;
insert into supplier values
('Jumbo','123456789','Ruitenberglaan 27 Arnhem');
insert into "ORDER" values
(1,'Jumbo','placed','12-12-18');
insert into delivery values
(1,1,'message',null);
update "ORDER"
set state = 'other';
rollback;

/* test should fail upon inserting an order with state other than placed or updating an order state to something other than placed
Because the is no delivery note*/
-- insert
start transaction;
insert into supplier values
('Jumbo','123456789','Ruitenberglaan 27 Arnhem');
insert into "ORDER" values
(1,'Jumbo','other','12-12-18');
rollback;

--update
start transaction;
insert into supplier values
('Jumbo','123456789','Ruitenberglaan 27 Arnhem');
insert into "ORDER" values
(1,'Jumbo','placed','12-12-18');
update "ORDER"
set state = 'other';
rollback;

/* test should pass upon deleting a delivery or updating a delivery
because the order it corresponds to is placed*/
-- delete
start transaction;
insert into supplier values
('Jumbo','123456789','Ruitenberglaan 27 Arnhem');
insert into "ORDER" values
(1,'Jumbo','placed','12-12-18');
insert into delivery values
(1,1,'message',null);
delete from delivery;
rollback;

--update
start transaction;
insert into supplier values
('Jumbo','123456789','Ruitenberglaan 27 Arnhem');
insert into "ORDER" values
(1,'Jumbo','placed','12-12-18'),
(2,'Jumbo','placed','10-10-18');
insert into delivery values
(1,1,'message',null);
update delivery
set Order_id = 2;
rollback;

/* test should fail upon deleting a delivery or updating a delivery
because the order it correpsonds to is something other than placed*/
-- delete
start transaction;
insert into supplier values
('Jumbo','123456789','Ruitenberglaan 27 Arnhem');
insert into "ORDER" values
(1,'Jumbo','placed','12-12-18');
insert into delivery values
(1,1,'message',null);
update "ORDER"
set State = 'other';
delete from delivery;
rollback;

--update
start transaction;
insert into supplier values
('Jumbo','123456789','Ruitenberglaan 27 Arnhem');
insert into "ORDER" values
(1,'Jumbo','placed','12-12-18'),
(2,'Jumbo','placed','10-10-18');
insert into delivery values
(1,1,'message',null);
update "ORDER"
set State = 'other'
where Order_id = '1';
update delivery
set Order_id = 2;
rollback;

/*============*/

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
/* ============= */