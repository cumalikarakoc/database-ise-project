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

/*===== Constraint 1 OrderStates =====*/
/* These inserts and updates pass when one of the four accepted states is inserted.*/
--insert
begin transaction;
alter table "ORDER"
drop constraint fk_order_supplier;

insert into "ORDER" values ('Order1', 'supplier', 'Paid', current_date, null),
('Order2', 'Supplier2', 'Awaiting payment', current_date, null),
('Order3', 'Supplier2', 'Not complete', current_date, null),
('Order4', 'Supplier4', 'Placed', current_date, null);
rollback;

--update
begin transaction;
alter table "ORDER"
drop constraint fk_order_supplier;

insert into "ORDER" values ('Order1', 'supplier', 'Awaiting payment', current_date, null);

update "ORDER"
set state = 'Paid';
rollback;


/*The following inserts and updates will fail because the state is not allowed*/
--insert
begin transaction;
alter table "ORDER"
drop constraint fk_order_supplier;

insert into "ORDER" values ('Order1', 'Supplier', 'Placed', current_date, null),
('Order2', 'Supplier2', 'Canceled', current_date, null);
rollback;

--update
begin transaction;
alter table "ORDER"
drop constraint fk_order_supplier;

insert into "ORDER" values ('Order1', 'Supplier', 'Placed', current_date, null);

update "ORDER"
set State = 'Removed';
rollback;

/*===== Constraint 2 OtherThanPlacedHasDelivery =====*/
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

/*===== Constraint 3 PaidHasInvoice =====*/
/* Tests should pass upon inserting a paid order or updating an order state to paid.*/
-- insert
begin transaction;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
insert into invoice values('1');
insert into supplier values('jumbo', '123213', 'ijssellaan');
insert into "ORDER" values(1, 'jumbo', 'Paid', '2019-12-12', '1');
rollback;

-- update 
begin transaction;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
insert into invoice values('1');
insert into supplier values('jumbo', '123213', 'ijssellaan');
insert into "ORDER" values(1, 'jumbo', 'Paid', '2019-12-12', '1');
update "ORDER" set state = 'Paid', invoice_id = '1';
rollback;


/* Tests should raise a check constraint error if order is paid and no invoice is associated*/
--insert
begin transaction;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
insert into invoice values('1');
insert into supplier values('jumbo', '123213', 'ijssellaan');
insert into "ORDER" values(1, 'jumbo', 'Paid', '2019-12-12', null);
rollback;

--update 
begin transaction;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
insert into invoice values('1');
insert into supplier values('jumbo', '123213', 'ijssellaan');
insert into "ORDER" values(1, 'jumbo', 'Placed', '2019-12-12', null);
update "ORDER" set invoice_id = '1';
rollback;

/* Tests should not pass if state is not paid and an invoice is attached to the order. */
--insert
begin transaction;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
insert into invoice values('1');
insert into supplier values('jumbo', '123213', 'ijssellaan');
insert into "ORDER" values(1, 'jumbo', 'Placed', '2019-12-12', 1);
rollback;

--update 
begin transaction;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
insert into invoice values('1');
insert into supplier values('jumbo', '123213', 'ijssellaan');
insert into "ORDER" values(1, 'jumbo', 'Placed', '2019-12-12', 1);
update "ORDER" set state = 'Awaiting payment', invoice_id = '1';
rollback;

/* Constraint 4 NotCompleteHasDiscrepancy */
/* The trigger on ORDER will be tested first. The next insert and update will fail
 because there isn't a discrepancy note */
--insert
begin transaction;
alter table "ORDER"
drop constraint fk_order_ivoice_of_invoice;

alter table "ORDER"
drop constraint fk_order_supplier;

insert into "ORDER" values
('Order3', 'Supplier2', 'Not complete', current_date, null);
rollback;

--update
begin transaction;
alter table "ORDER"
drop constraint fk_order_ivoice_of_invoice;

alter table "ORDER"
drop constraint fk_order_supplier;

insert into "ORDER" values
('Order2', 'Supplier2', 'Awaiting payment', current_date, null);
update "ORDER"
set state = 'Not complete';
rollback;

/* The following test will succeed because a discrepancy note exists. For a discrepancy note to be created,
there has to be an order. Thats why an order is created first.*/
--insert
begin transaction;

alter table "ORDER"
drop constraint fk_order_ivoice_of_invoice;

alter table "ORDER"
drop constraint fk_order_supplier;

insert into "ORDER" values
('1', 'test', 'Placed', current_date, null);
insert into DISCREPANCY (order_id, message, place_date) values
('1', 'test', current_date);
update "ORDER"
set state = 'Not complete';
rollback;

/* Now the trigger on DISCREPANCY will be tested. This wil fail because the order it gets assigned to hasnt the state Not complete.
When deleted it will also fail because the order is still not completed.*/
--update
begin transaction;

alter table "ORDER"
drop constraint fk_order_ivoice_of_invoice;

alter table "ORDER"
drop constraint fk_order_supplier;

insert into "ORDER" values
('1', 'test', 'Placed', current_date, null),
('2', 'test', 'Paid', current_date, null);
insert into discrepancy (order_id, message, place_date) values
('1', 'test', current_date);
update "ORDER"
set state = 'Not complete';
update discrepancy
set order_id = '2';
rollback;

--delete
begin transaction;
alter table "ORDER"
drop constraint fk_order_ivoice_of_invoice;

alter table "ORDER"
drop constraint fk_order_supplier;

insert into "ORDER" values
('1', 'test', 'Placed', current_date, null);
insert into discrepancy (order_id, message, place_date) values
('1', 'test', current_date);
update "ORDER"
set state = 'Not complete';
delete from discrepancy;
rollback;

/* The following tests will succeed. Because the order has been completed, so its state changes. */
--update
begin transaction;
alter table "ORDER"
drop constraint fk_order_ivoice_of_invoice;

alter table "ORDER"
drop constraint fk_order_supplier;

insert into "ORDER" values
('1', 'test', 'Placed', current_date, null),
('2', 'test', 'Paid', current_date, null);
insert into discrepancy (order_id, message, place_date) values
('1', 'test', current_date),
('2', 'test', current_date);
update "ORDER"
set state = 'Not complete';
update "ORDER"
set state = 'Not complete';
update discrepancy
set order_id = '2';
rollback;

--delete
begin transaction;
alter table "ORDER"
drop constraint fk_order_ivoice_of_invoice;

alter table "ORDER"
drop constraint fk_order_supplier;

insert into "ORDER" values
('1', 'test', 'Placed', current_date, null);
insert into discrepancy (order_id, message, place_date) values
('1', 'test', current_date);
delete from discrepancy;
rollback;

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

/*===== Constraint 6 AnimalHasOneEnclosure =====*/
/* The following tests will succeed because none of the the dates will overlap */

--insert
begin transaction;
alter table animal_enclosure
drop constraint fk_animal_in_enclosure;

alter table animal_enclosure
drop constraint fk_enclosure_has_animal;

insert into ANIMAL_ENCLOSURE values
('1', 'test', 1, '2019-05-23', '2019-05-24');

insert into ANIMAL_ENCLOSURE values
('1', 'test', 2, '2019-05-25', '2019-05-26');

rollback transaction;

--update
begin transaction;
alter table animal_enclosure
drop constraint fk_animal_in_enclosure;

alter table animal_enclosure
drop constraint fk_enclosure_has_animal;

insert into ANIMAL_ENCLOSURE values
('1', 'test', 3, '2019-01-01', '2019-01-31');

insert into ANIMAL_ENCLOSURE values
('1', 'test', 1, '2019-05-23', null);

update ANIMAL_ENCLOSURE
set End_date = '2019-05-24'
where Animal_id = '1' and since = '2019-05-23';

rollback transaction;

/* The following test will fail because the new since date is in between an older since and end_date.*/
--insert
begin transaction;
alter table animal_enclosure
drop constraint fk_animal_in_enclosure;

alter table animal_enclosure
drop constraint fk_enclosure_has_animal;

insert into ANIMAL_ENCLOSURE values
('1', 'test', 1, '2019-05-23', '2019-05-25');

insert into ANIMAL_ENCLOSURE values
('1', 'test', 2, '2019-05-24', '2019-05-26');
rollback transaction;

--update
begin transaction;
alter table animal_enclosure
drop constraint fk_animal_in_enclosure;

alter table animal_enclosure
drop constraint fk_enclosure_has_animal;

insert into ANIMAL_ENCLOSURE values
('1', 'test', 1, '2019-05-23', '2019-05-25'),
('1', 'test', 2, '2019-05-25', '2019-05-31'),
('1', 'test', 3, '2019-06-01', '2019-06-02');

update animal_enclosure
set Since = '2019-05-24'
where animal_id = '1' and Since = '2019-05-25';

rollback;

/* The next test will fail because the end_date is in between an older since date and end_date*/
--insert
begin transaction;
alter table animal_enclosure
drop constraint fk_animal_in_enclosure;

alter table animal_enclosure
drop constraint fk_enclosure_has_animal;

insert into ANIMAL_ENCLOSURE values
('1', 'test', 1, '2019-05-23', '2019-05-25');

insert into ANIMAL_ENCLOSURE values
('1', 'test', 2, '2019-05-10', '2019-05-24');
rollback transaction;

--update
begin transaction;
alter table animal_enclosure
drop constraint fk_animal_in_enclosure;

alter table animal_enclosure
drop constraint fk_enclosure_has_animal;

insert into ANIMAL_ENCLOSURE values
('1', 'test', 1, '2019-05-23', '2019-05-25'),
('1', 'test', 2, '2019-05-25', '2019-05-31');

update animal_enclosure
set since = '2019-05-10',
    End_date = '2019-05-26'
where animal_id = '1' and Since = '2019-05-23';
rollback;

/* This test will fail because the the new since date and end_date are in between a older since date and end_date. */
--insert
begin transaction;
alter table animal_enclosure
drop constraint fk_animal_in_enclosure;

alter table animal_enclosure
drop constraint fk_enclosure_has_animal;

insert into ANIMAL_ENCLOSURE values
('1', 'test', 1, '2019-05-23', '2019-05-30');

insert into ANIMAL_ENCLOSURE values
('1', 'test', 1,  '2019-05-24','2019-05-26');

rollback;

--update
begin transaction;
alter table animal_enclosure
drop constraint fk_animal_in_enclosure;

alter table animal_enclosure
drop constraint fk_enclosure_has_animal;

insert into ANIMAL_ENCLOSURE values
('1', 'test', 1, '2019-05-23', '2019-05-25'),
('1', 'test', 2, '2019-05-25', '2019-05-31');

update animal_enclosure
set since = '2019-05-26',
    End_date = '2019-05-29'
where animal_id = '1' and Since = '2019-05-23';
rollback;

/* The following test will fail because the new since date is before the old since date and the new end_date is after the old end_date */
--insert
begin transaction;
alter table animal_enclosure
drop constraint fk_animal_in_enclosure;

alter table animal_enclosure
drop constraint fk_enclosure_has_animal;

insert into ANIMAL_ENCLOSURE values
('1', 'test', 1, '2019-05-23', '2019-05-25');

insert into ANIMAL_ENCLOSURE values
('1', 'test', 1, '2019-05-20', '2019-05-26');
rollback transaction;

--update
begin transaction;
alter table animal_enclosure
drop constraint fk_animal_in_enclosure;

alter table animal_enclosure
drop constraint fk_enclosure_has_animal;

insert into ANIMAL_ENCLOSURE values
('1', 'test', 1, '2019-05-23', '2019-05-25'),
('1', 'test', 2, '2019-05-25', '2019-05-31');

update animal_enclosure
set since = '2019-05-24',
    End_date = '2019-06-01'
where animal_id = '1' and Since = '2019-05-23';
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

/*===== Constraint 8 NextVisitVet =====*/
/*Tests should pass when a next_visit that is later than visit_date is inserted or updated*/
-- insert
begin transaction;
alter table animal_visits_vet drop constraint if exists fk_animal_check_up;
alter table animal_visits_vet drop constraint if exists fk_prescription_of_vet_visit;
alter table animal_visits_vet drop constraint if exists fk_vet_visited_animal;

insert into animal_visits_vet values
('sai-1','10-10-2018','pil','Bob','12-12-2018'),
('sai-2','10-10-2018','pil','BOB','12-12-2018');
rollback;
-- update
begin transaction;
alter table animal_visits_vet drop constraint if exists fk_animal_check_up;
alter table animal_visits_vet drop constraint if exists fk_prescription_of_vet_visit;
alter table animal_visits_vet drop constraint if exists fk_vet_visited_animal;

insert into animal_visits_vet values
('sai-1','10-10-2018','pil','Bob','12-12-2018'),
('sai-2','10-10-2018','pil','BOB','12-12-2018'); 

update animal_visits_vet values
set next_visit = '11-11-2018';
rollback;

/* tests should fail because next_visit that is before visit_date is inserted or updated*/
-- insert
begin transaction;
alter table animal_visits_vet drop constraint if exists fk_animal_check_up;
alter table animal_visits_vet drop constraint if exists fk_prescription_of_vet_visit;
alter table animal_visits_vet drop constraint if exists fk_vet_visited_animal;

insert into animal_visits_vet values
('sai-1','10-10-2018','pil','Bob','12-12-2018'),
('sai-2','12-12-2018','pil','BOB','10-10-2018');
rollback;
-- update
begin transaction;
alter table animal_visits_vet drop constraint if exists fk_animal_check_up;
alter table animal_visits_vet drop constraint if exists fk_prescription_of_vet_visit;
alter table animal_visits_vet drop constraint if exists fk_vet_visited_animal;

insert into animal_visits_vet values
('sai-1','11-11-2018','pil','Bob','12-12-2018'),
('sai-2','11-11-2018','pil','BOB','12-12-2018'); 

update animal_visits_vet values
set next_visit = '10-10-2018';
rollback;

/* tests should fail because next_visit that is before visit_date is inserted or updated*/
-- insert
begin transaction;
alter table animal_visits_vet drop constraint if exists fk_animal_check_up;
alter table animal_visits_vet drop constraint if exists fk_prescription_of_vet_visit;
alter table animal_visits_vet drop constraint if exists fk_vet_visited_animal;

insert into animal_visits_vet values
('sai-1','10-10-2018','pil','Bob','12-12-2018'),
('sai-2','11-11-2018','pil','BOB','11-11-2018');
rollback;
-- update
begin transaction;
alter table animal_visits_vet drop constraint if exists fk_animal_check_up;
alter table animal_visits_vet drop constraint if exists fk_prescription_of_vet_visit;
alter table animal_visits_vet drop constraint if exists fk_vet_visited_animal;

insert into animal_visits_vet values
('sai-1','10-10-2018','pil','Bob','11-11-2018'),
('sai-2','11-11-2018','pil','BOB','12-12-2018'); 

update animal_visits_vet values
set next_visit = '11-11-2018';
rollback;

/*===== Constraint 9 EnclosureEndDate =====*/
/* Tests should pass when end_date is on the same date as the date of stay of the animal or later.*/
-- insert
begin transaction;
alter table animal_enclosure drop constraint if exists fk_animal_in_enclosure;
alter table animal_enclosure drop constraint if exists fk_enclosure_has_animal;

insert into animal_enclosure values('an-1', '2019-01-01', 'area', 1, '2019-02-02');
rollback;

--update
begin transaction;
alter table animal_enclosure drop constraint if exists fk_animal_in_enclosure;
alter table animal_enclosure drop constraint if exists fk_enclosure_has_animal;

insert into animal_enclosure values('an-1', '2019-01-01', 'area', 1, '2019-02-02');

update animal_enclosure set since = '2019-01-20';
rollback;

/* Tests should fail when end_date is earlier than the date of stay of the animal.*/
-- insert
begin transaction;
alter table animal_enclosure drop constraint if exists fk_animal_in_enclosure;
alter table animal_enclosure drop constraint if exists fk_enclosure_has_animal;

insert into animal_enclosure values('an-1', '2019-01-01', 'area', 1, '2018-02-02');
rollback;

-- update
begin transaction;
alter table animal_enclosure drop constraint if exists fk_animal_in_enclosure;
alter table animal_enclosure drop constraint if exists fk_enclosure_has_animal;

insert into animal_enclosure values('an-1', '2019-01-01', 'area', 1, '2019-02-02');

update animal_enclosure set since = '2019-03-05';
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

-- update
begin transaction;
alter table reintroduction drop constraint if exists fk_animal_reintroduction;
alter table spotted drop constraint if exists fk_animal_spotted;

insert into reintroduction values('an-1', '2018-10-05', 'location', null);
insert into reintroduction values('an-1', '2019-11-05', 'location', null);
insert into spotted values('an-1', '2018-10-05');

update spotted set spot_date = '2018-11-06';
rollback;

/*Test should raise an error if spot_date is before the date when the animal is reintroduced in wild.*/
--insert
begin transaction;
alter table reintroduction drop constraint if exists fk_animal_reintroduction;
alter table spotted drop constraint if exists fk_animal_spotted;

insert into reintroduction values('an-1', '2018-12-12', 'location', null);
insert into reintroduction values('an-1', '2019-11-05', 'location', null);
insert into spotted values('an-1', '2018-10-11');
rollback;

--update
begin transaction;
alter table reintroduction drop constraint if exists fk_animal_reintroduction;
alter table spotted drop constraint if exists fk_animal_spotted;

insert into reintroduction values('an-1', '2018-10-05', 'location', null);
insert into reintroduction values('an-1', '2019-11-05', 'location', null);
insert into spotted values('an-1', '2018-10-05');

update spotted set spot_date = '2018-04-04';
rollback;

/*Test should pass if the there is still a reintroduction_date before the oldest spot_date after deleting or updating.*/
-- update
begin transaction;
alter table reintroduction drop constraint if exists fk_animal_reintroduction;
alter table spotted drop constraint if exists fk_animal_spotted;

insert into reintroduction values('an-1', '2017-04-04', 'location', null);
insert into reintroduction values('an-1', '2018-12-12', 'location', null);
insert into spotted values('an-1', '2019-01-01');

update reintroduction set reintroduction_date = '2019-05-05' where reintroduction_date = '2017-04-04';
rollback;

-- delete
begin transaction;
alter table reintroduction drop constraint if exists fk_animal_reintroduction;
alter table spotted drop constraint if exists fk_animal_spotted;

insert into reintroduction values('an-1', '2017-04-04', 'location', null);
insert into reintroduction values('an-1', '2018-12-12', 'location', null);
insert into spotted values('an-1', '2019-01-01');

delete from reintroduction where reintroduction_date = '2017-04-04';
rollback;

/*Test should raise an error if there is no reintroduction_date before the oldest spot_date*/
-- update
begin transaction;
alter table reintroduction drop constraint if exists fk_animal_reintroduction;
alter table spotted drop constraint if exists fk_animal_spotted;

insert into reintroduction values('an-1', '2017-04-04', 'location', null);
insert into reintroduction values('an-1', '2018-12-12', 'location', null);
insert into spotted values('an-1', '2018-01-01');

update reintroduction set reintroduction_date = '2019-05-05' where reintroduction_date = '2017-04-04';
rollback;

-- delete
begin transaction;
alter table reintroduction drop constraint if exists fk_animal_reintroduction;
alter table spotted drop constraint if exists fk_animal_spotted;

insert into reintroduction values('an-1', '2017-04-04', 'location', null);
insert into reintroduction values('an-1', '2019-04-03', 'location', null);
insert into spotted values('an-1', '2019-01-01');

delete from reintroduction where reintroduction_date = '2017-04-04';
rollback;

/*===== Constraint 11 AnimalReturned =====*/
/* Tests should pass when return_date is on the same date as exchange_date or later.*/
-- insert
begin transaction;
alter table exchange drop constraint if exists fk_animal_exchange;

insert into exchange values('an-1', '2019-01-01', '2019-02-02', 'comments', 'to', 'place');
rollback;

-- update
begin transaction;
alter table exchange drop constraint if exists fk_animal_exchange;

insert into exchange values('an-1', '2019-01-01', '2019-02-02', 'comments', 'to', 'place');

update exchange set return_date = '2019-03-03';
rollback;

/* Tests should fail if return_date is earlier than the exchange_date.*/
-- insert
begin transaction;
alter table exchange drop constraint if exists fk_animal_exchange;

insert into exchange values('an-1', '2019-01-01', '2018-11-25', 'comments', 'to', 'place');
rollback;

--update
begin transaction;
alter table exchange drop constraint if exists fk_animal_exchange;

insert into exchange values('an-1', '2019-01-01', '2018-11-25', 'comments', 'to', 'place');

update exchange set exchange_date = '2018-03-03';
rollback;

/*===== CONSTRAINT 12 OffspringId =====*/
/* Test should pass if the updated mating_id is not the same as the offspring_id in table offspring. */
begin transaction;
alter table mating drop constraint if exists fk_breeding_mate; -- MATING(animal_id) -> ANIMAL(animal_id)
alter table mating drop constraint if exists fk_mating_breeding__animal; -- MATING(mate_id) -> ANIMAL(animal_id)
alter table offspring drop constraint if exists fk_offsprin_animal_of_animal; -- OFFSPRING(offspring_id) -> ANIMAL(animal_id)

insert into mating values('an-1', '2019-04-04', 'ica', 'mate-1');
insert into offspring values('2019-04-04', 'an offspring', 'an-1', 'off-1');

update mating set mate_id = 'mate-2';
rollback;

/* Test should fail if the updated mate_id is the same as the offspring_id of the concerning mating. */
begin transaction;
alter table mating drop constraint if exists fk_breeding_mate; -- MATING(animal_id) -> ANIMAL(animal_id)
alter table mating drop constraint if exists fk_mating_breeding__animal; -- MATING(mate_id) -> ANIMAL(animal_id)
alter table offspring drop constraint if exists fk_offsprin_animal_of_animal; -- OFFSPRING(offspring_id) -> ANIMAL(animal_id)

insert into mating values('an-1', '2019-04-04', 'ica', 'mate-1');
insert into offspring values('2019-04-04', 'an offspring', 'an-1', 'off-1');

update mating set mate_id = 'off-1';
rollback;

/* Test should pass if an offspring is inserted or updated with a different id than the animal_id or the mate_id. */
-- insert
begin transaction;
alter table mating drop constraint if exists fk_breeding_mate; -- MATING(animal_id) -> ANIMAL(animal_id)
alter table mating drop constraint if exists fk_mating_breeding__animal; -- MATING(mate_id) -> ANIMAL(animal_id)
alter table offspring drop constraint if exists fk_offsprin_animal_of_animal; -- OFFSPRING(offspring_id) -> ANIMAL(animal_id)

insert into mating values('an-1', '2019-04-04', 'ica', 'mate-1');
insert into offspring values('2019-04-04', 'an offspring', 'an-1', 'off-1');
rollback;

-- update
begin transaction;
alter table mating drop constraint if exists fk_breeding_mate; -- MATING(animal_id) -> ANIMAL(animal_id)
alter table mating drop constraint if exists fk_mating_breeding__animal; -- MATING(mate_id) -> ANIMAL(animal_id)
alter table offspring drop constraint if exists fk_offsprin_animal_of_animal; -- OFFSPRING(offspring_id) -> ANIMAL(animal_id)

insert into mating values('an-1', '2019-04-04', 'ica', 'mate-1');
insert into offspring values('2019-04-04', 'an offspring', 'an-1', 'off-1');

update offspring set offspring_id = 'off-2';
rollback;

/*Test should fail if an inserted or updated offspring has the same id as the animal_id or the mate_id*/
-- insert
begin transaction;
alter table mating drop constraint if exists fk_breeding_mate; -- MATING(animal_id) -> ANIMAL(animal_id)
alter table mating drop constraint if exists fk_mating_breeding__animal; -- MATING(mate_id) -> ANIMAL(animal_id)
alter table offspring drop constraint if exists fk_offsprin_animal_of_animal; -- OFFSPRING(offspring_id) -> ANIMAL(animal_id)

insert into mating values('an-1', '2019-04-04', 'ica', 'mate-1');
insert into offspring values('2019-04-04', 'an offspring', 'an-1', 'an-1');
rollback;

--update
begin transaction;
alter table mating drop constraint if exists fk_breeding_mate; -- MATING(animal_id) -> ANIMAL(animal_id)
alter table mating drop constraint if exists fk_mating_breeding__animal; -- MATING(mate_id) -> ANIMAL(animal_id)
alter table offspring drop constraint if exists fk_offsprin_animal_of_animal; -- OFFSPRING(offspring_id) -> ANIMAL(animal_id)

insert into mating values('an-1', '2019-04-04', 'ica', 'mate-1');
insert into offspring values('2019-04-04', 'an offspring', 'an-1', 'off-1');

update offspring set offspring_id = 'mate-1';
rollback;

/*===== Constraint 13 MateAndAnimalId ===== */
/* Tests should pass because mate id and animal id are not the same */
-- insert
begin transaction;
alter table mating drop constraint fk_breeding_mate;
alter table mating drop constraint fk_mating_breeding__animal;

insert into mating values
('sai-1', '12-12-18', 'duiven', 'sai-2'),
('sai-2', '01-01-19', 'duiven', 'sai-1');
rollback;

-- update
begin transaction;
alter table mating drop constraint fk_breeding_mate;
alter table mating drop constraint fk_mating_breeding__animal;

insert into mating values
('sai-1', '12-12-18', 'duiven', 'sai-2'),
('sai-2', '01-01-19', 'duiven', 'sai-1');

update mating
set animal_id = 'sai-3';
rollback;

/* Tests should fail because mate id and animal id are the same */
-- insert
begin transaction;
alter table mating drop constraint fk_breeding_mate;
alter table mating drop constraint fk_mating_breeding__animal;

insert into mating values
('sai-1', '12-12-18', 'duiven', 'sai-2'),
('sai-2', '01-01-19', 'duiven', 'sai-2');
rollback;

-- update
begin transaction;
alter table mating drop constraint fk_breeding_mate;
alter table mating drop constraint fk_mating_breeding__animal;

insert into mating values
('sai-1', '12-12-18', 'duiven', 'sai-2'),
('sai-2', '01-01-19', 'duiven', 'sai-1');

update mating
set animal_id = 'sai-2';
rollback;

/* ====== CONSTRAINT 14 DiscrepancyDate ======*/
/* Tests should pass upon insert a discrapency date or updating it */
--Insert
begin transaction;
alter table "ORDER" drop constraint fk_order_invoice_of_invoice;
alter table "ORDER" drop constraint fk_order_supplier;

Insert into "ORDER" values ('1', 'berry', 'awaiting', '03-03-2019', '1');
Insert into discrepancy values (1, 1, 'test', '04-04-2019');
rollback;

--Update
begin transaction;
alter table "ORDER" drop constraint fk_order_invoice_of_invoice;
alter table "ORDER" drop constraint fk_order_supplier;

Insert into "ORDER" values ('1', 'berry', 'awaiting', '03-03-2019', '1');
Insert into discrepancy values (1, 1, 'test', '04-04-2019');
Update discrepancy set place_date = '05-05-2019';
rollback;

/* Tests should fail after inserting and updating a earlier date */
--Insert
begin transaction;
alter table "ORDER" drop constraint fk_order_invoice_of_invoice;
alter table "ORDER" drop constraint fk_order_supplier;

Insert into "ORDER" values ('1', 'berry', 'awaiting', '03-03-2019', '1');
Insert into discrepancy values (1, 1, 'test', '02-02-2019');
rollback;

--Update
begin transaction;
alter table "ORDER" drop constraint fk_order_invoice_of_invoice;
alter table "ORDER" drop constraint fk_order_supplier;

Insert into "ORDER" values ('1', 'berry', 'awaiting', '03-03-2019', '1');
Insert into discrepancy values (1, 1, 'test', '04-04-2019');
Update discrepancy set place_date = '02-02-2019';
rollback;

/*===== CONSTRAINT 15 LineItemWeight =====*/
/* Tests should pass upon inserting a line_item or updating an line_item where the weight is higher than 0.*/

/* Test should pass as the weight is higher than 0*/
-- insert
begin transaction;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
insert into invoice values('p1');
insert into supplier values('jumbo', '123123', 'ijssellaan');
insert into "ORDER" values('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
insert into food_kind values('banaan');
insert into line_item values('o123', 'banaan', 10, 10);
rollback;

-- update
begin transaction;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
insert into invoice values('p1');
insert into supplier values('jumbo', '123123', 'ijssellaan');
insert into "ORDER" values('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
insert into food_kind values('banaan');
insert into line_item values('o123', 'banaan', 10, 15);
update line_item set weight = 10;
rollback;


/* Test should fail as the weight is equal to 0*/
-- insert
begin transaction;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
insert into invoice values('p1');
insert into supplier values('jumbo', '123123', 'ijssellaan');
insert into "ORDER" values('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
insert into food_kind values('banaan');
insert into line_item values('o123', 'banaan', 10, 0);
rollback;

-- update
begin transaction;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
insert into invoice values('p1');
insert into supplier values('jumbo', '123123', 'ijssellaan');
insert into "ORDER" values('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
insert into food_kind values('banaan');
insert into line_item values('o123', 'banaan', 10, 10);
update line_item set weight = 0;
rollback;


/*Test should fail as the weight is lower than 0*/
-- insert
begin transaction;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
insert into invoice values('p1');
insert into supplier values('jumbo', '123123', 'ijssellaan');
insert into "ORDER" values('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
insert into food_kind values('banaan');
insert into line_item values('o123', 'banaan', 10, -10);
rollback;

-- update
begin transaction;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
insert into invoice values('p1');
insert into supplier values('jumbo', '123123', 'ijssellaan');
insert into "ORDER" values('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
insert into food_kind values('banaan');
insert into line_item values('o123', 'banaan', 10, 10);
update line_item set weight = -10;
rollback;


/*===== CONSTRAINT 16 LineItemPrice =====*/
/* Tests should pass upon inserting a line_item or updating an line_item where the price is 0 or higher.*/

/* Test should pass as the price is higher than 0*/
-- insert
begin transaction;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
insert into invoice values('p1');
insert into supplier values('jumbo', '123123', 'ijssellaan');
insert into "ORDER" values('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
insert into food_kind values('banaan');
insert into line_item values('o123', 'banaan', 1, 10);
rollback;

-- update
begin transaction;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
insert into invoice values('p1');
insert into supplier values('jumbo', '123123', 'ijssellaan');
insert into "ORDER" values('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
insert into food_kind values('banaan');
insert into line_item values('o123', 'banaan', 1, 10);
update line_item set price = 20;
rollback;


/* Test should pass as the price is equal to 0*/
-- insert
begin transaction;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
insert into invoice values('p1');
insert into supplier values('jumbo', '123123', 'ijssellaan');
insert into "ORDER" values('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
insert into food_kind values('banaan');
insert into line_item values('o123', 'banaan', 0, 10);
rollback;

-- update
begin transaction;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
insert into invoice values('p1');
insert into supplier values('jumbo', '123123', 'ijssellaan');
insert into "ORDER" values('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
insert into food_kind values('banaan');
insert into line_item values('o123', 'banaan', 1, 10);
update line_item set price = 0;
rollback;


 /*Test should fail as the price is lower than 0*/
-- insert
begin transaction;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
insert into invoice values('p1');
insert into supplier values('jumbo', '123123', 'ijssellaan');
insert into "ORDER" values('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
insert into food_kind values('banaan');
insert into line_item values('o123', 'banaan', -1, 10);
rollback;

-- update
begin transaction;
drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
insert into invoice values('p1');
insert into supplier values('jumbo', '123123', 'ijssellaan');
insert into "ORDER" values('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
insert into food_kind values('banaan');
insert into line_item values('o123', 'banaan', 1, 10);
update line_item set price = -1;
rollback;

/* ====== Constraint 17 StockAmount ======*/
/* Tests should pass upon inserting or updating a value higher than 0 */
--Insert
begin transaction;
alter table stock drop if exists fk_animal_foodstock;
alter table stock drop if exists fk_food_in_stock;
insert into stock values ('apen', 'bananen', 5);
rollback;

--Update
begin transaction;
alter table stock drop if exists fk_animal_foodstock;
alter table stock drop if exists fk_food_in_stock;
insert into stock values ('apen', 'bananen', 5);
update stock set amount = 6;
rollback;

/* Tests should pass upon inserting or updating a value equal to 0 */
--Insert
begin transaction;
alter table stock drop if exists fk_animal_foodstock;
alter table stock drop if exists fk_food_in_stock;
insert into stock values ('apen', 'bananen', 0);
rollback;

--Update
begin transaction;
alter table stock drop if exists fk_animal_foodstock;
alter table stock drop if exists fk_food_in_stock;
insert into stock values ('apen', 'bananen', 5);
update stock set amount = 0;
rollback;

/* Tests should fail upon inserting or updating a value lower than 0 */
--Insert
begin transaction;
alter table stock drop if exists fk_animal_foodstock;
alter table stock drop if exists fk_food_in_stock;
insert into stock values ('apen', 'bananen', -5);
rollback;

--Update
begin transaction;
alter table stock drop if exists fk_animal_foodstock;
alter table stock drop if exists fk_food_in_stock;
insert into stock values ('apen', 'bananen', 5);
update stock set amount = -5;
rollback;

/* ====== CONSTRAINT 18 FeedingAmount ======*/
/*Test should pass upon inserting/updating a food amount higher than 0*/
--insert
begin transaction;
alter table feeding drop constraint fk_feeding_for_animal;
alter table feeding drop constraint fk_food_to_be_fed;
insert into feeding values('1', 'Kapsalon', '11/11/12',1);
rollback;

--update
begin transaction;
alter table feeding drop constraint fk_feeding_for_animal;
alter table feeding drop constraint fk_food_to_be_fed;
insert into feeding values('1', 'Kapsalon', '11/11/12',1);
update feeding set amount = 2;
rollback;

/*test should fail upon inserting/updating a food amount equal to 0*/
--insert
begin transaction;
alter table feeding drop constraint fk_feeding_for_animal;
alter table feeding drop constraint fk_food_to_be_fed;
insert into feeding values('1', 'Kapsalon', '11/11/12',0);
rollback;

--update
begin transaction;
alter table feeding drop constraint fk_feeding_for_animal;
alter table feeding drop constraint fk_food_to_be_fed;
insert into feeding values('1', 'Kapsalon', '11/11/12',1);
update feeding set amount = 0;
rollback;


/*test should fail upon inserting/updating a food amount less than 0*/
--insert
begin transaction;
alter table feeding drop constraint fk_feeding_for_animal;
alter table feeding drop constraint fk_food_to_be_fed;
insert into feeding values('1', 'Kapsalon', '11/11/12',-1);
rollback;

--update
begin transaction;
alter table feeding drop constraint fk_feeding_for_animal;
alter table feeding drop constraint fk_food_to_be_fed;
insert into feeding values('1', 'Kapsalon', '11/11/12',1);
update feeding set amount = -1;
rollback;

/* ====== CONSTRAINT 19 AnimalVisitsVet ======*/
/* Test should pass upon a visit date after the animal`s birth date*/
--Insert
begin transaction;
alter table animal drop constraint fk_animal_of_species;
alter table animal_visits_vet drop constraint fk_prescription_of_vet_visit;
alter table animal_visits_vet drop constraint fk_vet_visited_animal;
insert into animal values('1', 'male', 'Rico', 'Apeldoorn', '1/1/11', 'Duck');
insert into animal_visits_vet values('1', '12/12/13', 'Regular check', 'Doctor Pol', '12/12/14');
rollback;

--Update
begin transaction;
alter table animal drop constraint fk_animal_of_species;
alter table animal_visits_vet drop constraint fk_prescription_of_vet_visit;
alter table animal_visits_vet drop constraint fk_vet_visited_animal;
insert into animal values('1', 'male', 'Rico', 'Apeldoorn', '1/1/11', 'Duck');
insert into animal_visits_vet values('1', '12/12/13', 'Regular check', 'Doctor Pol', '12/12/20');
update animal_visits_vet set visit_date = '1/1/14';
rollback;

/* Test should pass upon a visit date on the animal`s birth date*/
--Insert
begin transaction;
alter table animal drop constraint fk_animal_of_species;
alter table animal_visits_vet drop constraint fk_prescription_of_vet_visit;
alter table animal_visits_vet drop constraint fk_vet_visited_animal;
insert into animal values('1', 'male', 'Rico', 'Apeldoorn', '1/1/11', 'Duck');
insert into animal_visits_vet values('1', '1/1/11', 'Regular check', 'Doctor Pol', '12/12/14');
rollback;

--Update
begin transaction;
alter table animal drop constraint fk_animal_of_species;
alter table animal_visits_vet drop constraint fk_prescription_of_vet_visit;
alter table animal_visits_vet drop constraint fk_vet_visited_animal;
insert into animal values('1', 'male', 'Rico', 'Apeldoorn', '1/1/11', 'Duck');
insert into animal_visits_vet values('1', '12/12/13', 'Regular check', 'Doctor Pol', '12/12/20');
update animal_visits_vet set visit_date = '1/1/11';
rollback;

/* Test should fail upon a visit date is before the animal`s birth date*/
--Insert
begin transaction;
alter table animal drop constraint fk_animal_of_species;
alter table animal_visits_vet drop constraint fk_prescription_of_vet_visit;
alter table animal_visits_vet drop constraint fk_vet_visited_animal;
insert into animal values('1', 'male', 'Rico', 'Apeldoorn', '1/1/11', 'Duck');
insert into animal_visits_vet values('1', '1/1/10', 'Regular check', 'Doctor Pol', '12/12/14');
rollback;

--Update
begin transaction;
alter table animal drop constraint fk_animal_of_species;
alter table animal_visits_vet drop constraint fk_prescription_of_vet_visit;
alter table animal_visits_vet drop constraint fk_vet_visited_animal;
insert into animal values('1', 'male', 'Rico', 'Apeldoorn', '1/1/11', 'Duck');
insert into animal_visits_vet values('1', '12/12/13', 'Regular check', 'Doctor Pol', '12/12/20');
update animal_visits_vet set visit_date = '1/1/10';
rollback;

/* ====== CONSTRAINT 20 MaturityAge ======*/
/* Tests should pass upon inserting or updating a age higher than 0*/
--Insert
begin transaction;
alter table species_gender drop if exists fk_species_with_gender;
insert into species_gender values ('aap', '', 5, 5);
rollback;

--Update
begin transaction;
alter table species_gender drop if exists fk_species_with_gender;
insert into species_gender values ('aap', 'male', 5, 5);
update species_gender set maturity_age = 6;

/* Tests should pass upon inserting or updating a age equal to 0*/
--Insert
begin transaction;
alter table species_gender drop if exists fk_species_with_gender;
insert into species_gender values ('aap', '', 5, 0);
rollback;

--Update
begin transaction;
alter table species_gender drop if exists fk_species_with_gender;
insert into species_gender values ('aap', 'male', 5, 5);
update species_gender set maturity_age = 0;
rollback;

/* Tests should fail upon inserting or updating a age lower than 0 */
--Insert
begin transaction;
alter table species_gender drop if exists fk_species_with_gender;
insert into species_gender values ('aap', '', 5, -2);
rollback;

--Update
begin transaction;
alter table species_gender drop if exists fk_species_with_gender;
insert into species_gender values ('aap', 'male', 5, 5);
update species_gender set maturity_age = -2;
rollback;

/* ====== CONSTRAINT 21 SpeciesWeight ======*/
/* Tests should pass upon insert a species gender or updating it */
--Insert
begin transaction;
insert into species values('Apes', 'Are apes', 'Apes', 'Apes', '');
insert into species_gender values('Apes', 'male', 9.5, 009.5);
rollback;

--Update
begin transaction;
insert into species values('Apes', 'Are apes', 'Apes', 'Apes', '');
insert into species_gender values('Apes', 'male', 9.5, 009.5);
update species_gender set average_weight = 10.1 where english_name = 'Apes';
rollback;

/* Tests should raise a check constraint error upon insert a species gender or updating it when the weight is 0 */
--Insert
begin transaction;
insert into species values('Apes', 'Are apes', 'Apes', 'Apes', '');
insert into species_gender values('Apes', 'male', 0, 009.5);
rollback;

--Update
begin transaction;
insert into species values('Apes', 'Are apes', 'Apes', 'Apes', '');
insert into species_gender values('Apes', 'male', 9.5, 009.5);
update species_gender set average_weight = 0 where english_name = 'Apes';
rollback;

/* Tests should raise a check constraint error upon insert a species gender or updating it when the weight is lower then 0 */
--Insert
begin transaction;
insert into species values('Apes', 'Are apes', 'Apes', 'Apes', '');
insert into species_gender values('Apes', 'male', -5, 009.5);
rollback;

--Update
begin transaction;
insert into species values('Apes', 'Are apes', 'Apes', 'Apes', '');
insert into species_gender values('Apes', 'male', 9.5, 009.5);
update species_gender set average_weight = -5 where english_name = 'Apes';
rollback;

/* ====== CONSTRAINT 22 AnimalEnclosureSince ======*/
/* Test should pass because the birth_date is after the since enclosure date */
--Insert
begin transaction;
alter table animal drop constraint fk_animal_of_species;
alter table animal_enclosure drop constraint fk_enclosure_has_animal;
insert into animal values('1', 'male', 'Rico', 'Apeldoorn', '1/1/11', 'Duck');
insert into animal_enclosure values('1', 'Mensen', '1', '12/12/12');
rollback;

--Update
begin transaction;
alter table animal drop constraint fk_animal_of_species;
alter table animal_enclosure drop constraint fk_enclosure_has_animal;
insert into animal values('1', 'male', 'Rico', 'Apeldoorn', '1/1/11', 'Duck');
insert into animal_enclosure values('1', 'Mensen', '1', '12/12/12');
update animal_enclosure set since = '12/12/13';
rollback;

--Update birth_date
begin transaction;
alter table animal drop constraint fk_animal_of_species;
alter table animal_enclosure drop constraint fk_enclosure_has_animal;
insert into animal values('1', 'male', 'Rico', 'Apeldoorn', '1/1/11', 'Duck');
insert into animal_enclosure values('1', 'Mensen', '1', '12/12/12');
update animal set birth_date = '12/12/10';
rollback;

/* Test should pass because the birth_date is on the same date as the since enclosure date */
--Insert
begin transaction;
alter table animal drop constraint fk_animal_of_species;
alter table animal_enclosure drop constraint fk_enclosure_has_animal;
insert into animal values('1', 'male', 'Rico', 'Apeldoorn', '1/1/11', 'Duck');
insert into animal_enclosure values('1', 'Mensen', '1', '1/1/11');
rollback;

--Update since date
begin transaction;
alter table animal drop constraint fk_animal_of_species;
alter table animal_enclosure drop constraint fk_enclosure_has_animal;
insert into animal values('1', 'male', 'Rico', 'Apeldoorn', '1/1/11', 'Duck');
insert into animal_enclosure values('1', 'Mensen', '1', '12/12/12');
update animal_enclosure set since = '1/1/11';
rollback;

--Update birth_date
begin transaction;
alter table animal drop constraint fk_animal_of_species;
alter table animal_enclosure drop constraint fk_enclosure_has_animal;
insert into animal values('1', 'male', 'Rico', 'Apeldoorn', '1/1/11', 'Duck');
insert into animal_enclosure values('1', 'Mensen', '1', '12/12/12');
update animal set birth_date = '12/12/12';
rollback;

/* Test should fail because the birth_date is before the since enclosure date */
--Insert
begin transaction;
alter table animal drop constraint fk_animal_of_species;
alter table animal_enclosure drop constraint fk_enclosure_has_animal;
insert into animal values('1', 'male', 'Rico', 'Apeldoorn', '1/1/11', 'Duck');
insert into animal_enclosure values('1', 'Mensen', '1', '1/1/10');
rollback;

--Update since date
begin transaction;
alter table animal drop constraint fk_animal_of_species;
alter table animal_enclosure drop constraint fk_enclosure_has_animal;
insert into animal values('1', 'male', 'Rico', 'Apeldoorn', '1/1/11', 'Duck');
insert into animal_enclosure values('1', 'Mensen', '1', '12/12/12');
update animal_enclosure set since = '1/1/10';
rollback;

--Update birth_date
begin transaction;
alter table animal drop constraint fk_animal_of_species;
alter table animal_enclosure drop constraint fk_enclosure_has_animal;
insert into animal values('1', 'male', 'Rico', 'Apeldoorn', '1/1/11', 'Duck');
insert into animal_enclosure values('1', 'Mensen', '1', '12/12/12');
update animal set birth_date = '1/1/13';
rollback;
/*================*/
