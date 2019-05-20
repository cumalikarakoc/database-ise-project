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
/* test should pass upon inserting a paid order or updating an order state to paid.*/
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
INSERT INTO "ORDER" VALUES(1, 'jumbo', 'piad', '2019-12-12', '1');
UPDATE "ORDER" SET state = 'paid', invoice_id = '1';
ROLLBACK;


/* Tests should raise a check constraint error*/
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
UPDATE "ORDER" SET state = 'paid', invoice_id = '1';
ROLLBACK;

/* Tests should not pass if state is not paid and an invoice is attached to the order. */
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