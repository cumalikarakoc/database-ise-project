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
/* ====== CONSTRAINT 14 DiscrepancyDate ======*/
/* Tests should pass upon insert a discrapency date or updating it */
--Insert
BEGIN TRANSACTION;
Insert into invoice values (1);
Insert into supplier values ('berry', '06123456789', 'arnhem');
Insert into "ORDER" values (1, 'berry', 'awaiting', '03-03-2019', 1);
Insert into discrepancy values (1, 1, 'test', '04-04-2019');
ROLLBACK;

--Update
BEGIN TRANSACTION;
Insert into invoice values (1);
Insert into supplier values ('berry', '06123456789', 'arnhem');
Insert into "ORDER" values (1, 'berry', 'awaiting', '03-03-2019', 1);
Insert into discrepancy values (1, 1, 'test', '04-04-2019');
Update discrepancy set place_date = '05-05-2019' where discrepancy_id = 1;
ROLLBACK;

/* Tests should fail after inserting and updating a earlier date */
--Insert
BEGIN TRANSACTION;
Insert into invoice values (1);
Insert into supplier values ('berry', '06123456789', 'arnhem');
Insert into "ORDER" values (1, 'berry', 'awaiting', '03-03-2019', 1);
Insert into discrepancy values (1, 1, 'test', '02-02-2019');
ROLLBACK;

--Update
BEGIN TRANSACTION;
Insert into invoice values (1);
Insert into supplier values ('berry', '06123456789', 'arnhem');
Insert into "ORDER" values (1, 'berry', 'awaiting', '03-03-2019', 1);
Insert into discrepancy values (1, 1, 'test', '04-04-2019');
Update discrepancy set place_date = '02-02-2019' where discrepancy_id = 1;
ROLLBACK;

/* Constraint 4 NotCompleteHasDiscrepancy */
/* The trigger on ORDER will be tested first. The next insert and update will fail
 because there isn't a discrepancy note */
--insert
begin transaction;
insert into "ORDER" values
('Order3', 'Supplier2', 'Not complete', current_date, null);
rollback transaction;

--update
begin transaction;
insert into "ORDER" values
('Order2', 'Supplier2', 'Awaiting payment', current_date, null);
update "ORDER"
set state = 'Not complete';
rollback transaction;

/* The following test will succeed because a discrepancy note exists. For a discrepancy note to be created,
there has to be an order. Thats why an order is created first.*/
--insert
begin transaction;
insert into "ORDER" values
('1', 'test', 'Placed', current_date, null);
insert into DISCREPANCY (order_id, message, place_date) values
('1', 'test', current_date);
update "ORDER"
set state = 'Not complete';
rollback transaction

/* Now the trigger on DISCREPANCY will be tested. This wil fail because the order it gets assigend to hasnt the state Not complete.
When deleted it will also fail because the order is still not completed.*/
--update
begin transaction;
insert into "ORDER" values
('1', 'test', 'Placed', current_date, null),
('2', 'test', 'Paid', current_date, null);
insert into DISCREPANCY (order_id, message, place_date) values
('1', 'test', current_date);
update "ORDER"
set state = 'Not complete';
update DISCREPANCY
set order_id = '2';
rollback transaction;

--delete
begin transaction;
insert into "ORDER" values
('1', 'test', 'Placed', current_date, null);
insert into DISCREPANCY (order_id, message, place_date) values
('1', 'test', current_date);
update "ORDER"
set state = 'Not complete';
delete from DISCREPANCY;
rollback transaction;

/* The following tests will succeed. Because the order has been completed, so its state changes. */
--update
begin transaction;
insert into "ORDER" values
('1', 'test', 'Placed', current_date, null),
('2', 'test', 'Paid', current_date, null);
insert into DISCREPANCY (order_id, message, place_date) values
('1', 'test', current_date),
('2', 'test', current_date);
update "ORDER"
set state = 'Not complete';
update "ORDER"
set state = 'Not complete';
update DISCREPANCY
set order_id = '2';
rollback transaction;

--delete
begin transaction;
insert into "ORDER" values
('1', 'test', 'Placed', current_date, null);
insert into DISCREPANCY (order_id, message, place_date) values
('1', 'test', current_date);
delete from DISCREPANCY;
rollback transaction;

/* ====== Constraint 17 StockAmount ======*/
/* Tests should pass upon inserting or updating a value higher than 0 */
--Insert
BEGIN TRANSACTION;
ALTER TABLE stock DROP CONSTRAINT IF EXISTS fk_animal_foodstock;
ALTER TABLE stock DROP CONSTRAINT IF EXISTS fk_food_in_stock;

INSERT INTO stock values ('apen', 'bananen', 5);
ROLLBACK;

--Update
BEGIN TRANSACTION;
ALTER TABLE stock DROP CONSTRAINT IF EXISTS fk_animal_foodstock;
ALTER TABLE stock DROP CONSTRAINT IF EXISTS fk_food_in_stock;

INSERT INTO stock values ('apen', 'bananen', 5);
UPDATE stock SET amount = 6 where area_name = 'apen' and food_type_ft = 'bananen';
ROLLBACK;

/* Tests should pass upon inserting or updating a value equal to 0 */
--Insert
BEGIN TRANSACTION;
ALTER TABLE stock DROP CONSTRAINT IF EXISTS fk_animal_foodstock;
ALTER TABLE stock DROP CONSTRAINT IF EXISTS fk_food_in_stock;

INSERT INTO stock values ('apen', 'bananen', 0);
ROLLBACK;

--Update
BEGIN TRANSACTION;
ALTER TABLE stock DROP CONSTRAINT IF EXISTS fk_animal_foodstock;
ALTER TABLE stock DROP CONSTRAINT IF EXISTS fk_food_in_stock;

INSERT INTO stock values ('apen', 'bananen', 5);
UPDATE stock SET amount = 0 where area_name = 'apen' and food_type_ft = 'bananen';
ROLLBACK;

/* Tests should fail upon inserting or updating a value lower than 0 */
--Insert
BEGIN TRANSACTION;
ALTER TABLE stock DROP CONSTRAINT IF EXISTS fk_animal_foodstock;
ALTER TABLE stock DROP CONSTRAINT IF EXISTS fk_food_in_stock;

INSERT INTO stock values ('apen', 'bananen', -5);
ROLLBACK;

--Update
BEGIN TRANSACTION;
ALTER TABLE stock DROP CONSTRAINT IF EXISTS fk_animal_foodstock;
ALTER TABLE stock DROP CONSTRAINT IF EXISTS fk_food_in_stock;

INSERT INTO stock values ('apen', 'bananen', 5);
UPDATE stock SET amount = -5 where area_name = 'apen' and food_type_ft = 'bananen';
ROLLBACK;

/* ====== CONSTRAINT 20 MaturityAge ======*/
/* Tests should pass upon inserting or updating a age higher than 0*/
--Insert
BEGIN TRANSACTION;
ALTER TABLE species_gender DROP CONSTRAINT IF EXISTS fk_species_with_gender;

INSERT INTO species_gender values ('aap', '', 5, 5);
ROLLBACK;

--Update
BEGIN TRANSACTION;
ALTER TABLE species_gender DROP CONSTRAINT IF EXISTS fk_species_with_gender;

INSERT INTO species_gender values ('aap', 'male', 5, 5);
UPDATE species_gender SET maturity_age = 6 where english_name = 'aap' and gender = 'male';
ROLLBACK;

/* Tests should pass upon inserting or updating a age equal to 0*/
--Insert
BEGIN TRANSACTION;
ALTER TABLE species_gender DROP CONSTRAINT IF EXISTS fk_species_with_gender;

INSERT INTO species_gender values ('aap', '', 5, 0);
ROLLBACK;

--Update
BEGIN TRANSACTION;
ALTER TABLE species_gender DROP CONSTRAINT IF EXISTS fk_species_with_gender;

INSERT INTO species_gender values ('aap', 'male', 5, 5);
UPDATE species_gender SET maturity_age = 0 where english_name = 'aap' and gender = 'male';
ROLLBACK;

/* Tests should fail upon inserting or updating a age lower than 0 */
--Insert
BEGIN TRANSACTION;
ALTER TABLE species_gender DROP CONSTRAINT IF EXISTS fk_species_with_gender;

INSERT INTO species_gender values ('aap', '', 5, -2);
ROLLBACK;

--Update
BEGIN TRANSACTION;
ALTER TABLE species_gender DROP CONSTRAINT IF EXISTS fk_species_with_gender;

INSERT INTO species_gender values ('aap', 'male', 5, 5);
UPDATE species_gender SET maturity_age = -2 where english_name = 'aap' and gender = 'male';
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
