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
(1,'Jumbo','Placed','12-12-18',null);
insert into delivery values
(1,1,'message',null);
rollback;

--update
start transaction;
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
start transaction;
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
start transaction;
insert into supplier values
('Jumbo','123456789','Ruitenberglaan 27 Arnhem');
insert into "ORDER" values
(1,'Jumbo','Awaiting payment','12-12-18',null);
rollback;

--update
start transaction;
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
start transaction;
insert into supplier values
('Jumbo','123456789','Ruitenberglaan 27 Arnhem');
insert into "ORDER" values
(1,'Jumbo','Placed','12-12-18', null);
insert into delivery values
(1,1,'message',null);
delete from delivery;
rollback;

--update
start transaction;
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
start transaction;
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
start transaction;
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

/*============*/

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
/* ============= */