﻿/*-------------------------------------------------------------*\
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
/* ============= */



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
/* ============= */

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
