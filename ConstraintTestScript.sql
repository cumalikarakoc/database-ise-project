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

/* This stored procedure is going te be run before every tests.
It drops all constraints except for the one it is testing so they dont interfere with each other.
1 parameter is given it is connected to the constraint that is going to be tested.*/
create or replace function USP_DROP_CONSTRAINTS(int) returns void
language plpgsql
as $$
begin
    if ($1 != 1) then
        alter table "ORDER" drop constraint if exists CHK_ORDER_STATE;
    end if;
    if ($1 != 2) then
        drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER on "ORDER";
        drop trigger if exists TR_OTHER_THAN_PLACED_HAS_DELIVERY_DELIVERY on delivery;
    end if;
    if ($1 != 3) then
        alter table "ORDER" drop constraint if exists CHK_PAID_HAS_INVOICE;
    end if;
    if ($1 != 4) then
        drop trigger if exists TR_NOT_COMPLETE_HAS_DISCREPANCY on "ORDER";
        drop trigger if exists TR_DISCREPANCY_NOTE_HAS_ORDER on discrepancy;
    end if;
    if ($1 != 5) then
        alter table animal drop constraint if exists CHK_ANIMAL_GENDER;
    end if;
    if ($1 != 6) then
        drop trigger if exists TR_ANIMAL_HAS_ONE_ENCLOSURE on animal_enclosure;
    end if;
    if ($1 != 7) then
        alter table exchange drop constraint if exists CHK_LOAN_TYPE;
    end if;
    if ($1 != 8) then
        alter table animal_visits_vet drop constraint if exists CHK_NEXT_VISIT_VET;
    end if;
    if ($1 != 9) then
        alter table animal_enclosure drop constraint if exists CHK_ENCLOSURE_DATE;
    end if;
    if ($1 != 10) then
        drop trigger if exists TR_SPOTTED_AFTER_RELEASE on spotted;
        drop trigger if exists TR_REINTRODUCTION_BEFORE_SPOTTED on reintroduction;
    end if;
    if ($1 != 11) then
        alter table exchange drop constraint if exists CHK_ANIMAL_RETURNED;
    end if;
    if ($1 != 12) then
        drop trigger if exists TR_OFFSPRING_PARENTS on mating;
        drop trigger if exists TR_OFFSPRING_ID on offspring;
    end if;
    if ($1 != 13) then
        alter table mating drop constraint if exists CHK_MATE_AND_ANIMAL_ID;
    end if;
    if ($1 != 14) then
        drop trigger if exists TR_DISCREPANCY_DATE on discrepancy;
    end if;
    if ($1 != 15) then
        alter table line_item drop constraint if exists CHK_LINE_ITEM_WEIGHT;
    end if;
    if ($1 != 16) then
        alter table line_item drop constraint if exists CHK_LINE_ITEM_PRICE;
    end if;
    if ($1 != 17) then
        alter table stock drop constraint if exists CHK_STOCK_AMOUNT;
    end if;
    if ($1 != 18) then
        alter table feeding drop constraint if exists CHK_FEEDING_AMOUNT;
    end if;
    if ($1 != 19) then
        drop trigger if exists TR_ANIMAL_VISITS_VET on animal_visits_vet;
    end if;
    if ($1 != 20) then
        alter table species_gender drop constraint if exists CHK_MATURITY_AGE;
    end if;
    if ($1 != 21) then
        alter table species_gender drop constraint if exists CHK_AVERAGE_WEIGHT;
    end if;
    if ($1 != 22) then
        drop trigger if exists TR_ENCLOSURE_SINCE_AFTER_BIRTH_DATE on animal_enclosure;
        drop trigger if exists TR_ANIMAL_BIRTH_DATE_BEFORE_ENCLOSURE_SINCE on animal;
    end if;
end;
$$;

/*===== Constraint 1 OrderStates =====*/
/* These inserts and updates pass when one of the four accepted states is inserted.*/
--1. insert
begin transaction;
select USP_DROP_CONSTRAINTS(1);
do
$$
begin
alter table "ORDER"
drop constraint fk_order_supplier;
insert into "ORDER" values ('Order1', 'supplier', 'Paid', current_date, null),
('Order2', 'Supplier2', 'Awaiting payment', current_date, null),
('Order3', 'Supplier2', 'Not complete', current_date, null),
('Order4', 'Supplier4', 'Placed', current_date, null);
raise notice 'C1. Test 1 passed';
exception when others then
raise notice 'C1. Test 1 failed. (%)', SQLERRM;
end;
$$;
rollback;

--2. update
begin transaction;
select USP_DROP_CONSTRAINTS(1);
do
$$
begin
alter table "ORDER"
drop constraint fk_order_supplier;
insert into "ORDER" values ('Order1', 'supplier', 'Awaiting payment', current_date, null);
update "ORDER"
set state = 'Paid';
raise notice 'C1. Test 2 passed';
exception when others then
raise notice 'C1. Test 2 failed. (%)', SQLERRM;
end;
$$;
rollback;


/*The following inserts and updates will fail because the state is not allowed*/
--3. insert
begin transaction;
select USP_DROP_CONSTRAINTS(1);
do
$$
begin
alter table "ORDER"
drop constraint fk_order_supplier;
insert into "ORDER" values ('Order1', 'Supplier', 'Placed', current_date, null),
('Order2', 'Supplier2', 'Canceled', current_date, null);
raise notice 'C1. Test 3 failed';
exception when others then
raise notice 'C1. Test 3 passed (%)', SQLERRM;
end;
$$;
rollback;

--4. update
begin transaction;
select USP_DROP_CONSTRAINTS(1);
do
$$
begin
alter table "ORDER"
drop constraint fk_order_supplier;
insert into "ORDER" values ('Order1', 'Supplier', 'Placed', current_date, null);
update "ORDER"
set State = 'Removed';
raise notice 'C1. Test 3 failed';
exception when others then
raise notice 'C1. Test 4 passed (%)',SQLERRM ;
end;
$$;
rollback;

/*===== Constraint 2 OtherThanPlacedHasDelivery =====*/
/* test should pass upon inserting an order with state placed or updating an order state to placed
because there is a delivery note*/
--1. insert
begin transaction;
select USP_DROP_CONSTRAINTS(2);
do
$$
begin
insert into supplier values
('Jumbo','123456789','Ruitenberglaan 27 Arnhem');
insert into "ORDER" values
(1,'Jumbo','Placed','12-12-18',null);
insert into delivery values
(1,1,'message',null);
raise notice 'C2. Test 1 passed';
exception when others then
raise notice 'c2. Test 1 failed (%)',SQLERRM ;
end;
$$;
rollback;

--2. update
begin transaction;
select USP_DROP_CONSTRAINTS(2);
do
$$
begin
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
raise notice 'C2. Test 2 passed';
exception when others then
raise notice 'c2. Test 2 failed (%)',SQLERRM ;
end;
$$;
rollback;

/* test should pass upon inserting an order with state other than placed or updating an order state to something other than placed
because there is a delivery note*/
-- insert cannot be done cause the delivery note foreign key is not nullable

--3. update
begin transaction;
select USP_DROP_CONSTRAINTS(2);
do
$$
begin
insert into supplier values
('Jumbo','123456789','Ruitenberglaan 27 Arnhem');
insert into "ORDER" values
(1,'Jumbo','Placed','12-12-18',null);
insert into delivery values
(1,1,'message',null);
update "ORDER"
set state = 'Awaiting payment';
raise notice 'C2. Test 3 passed';
exception when others then
raise notice 'c2. Test 3 failed (%)',SQLERRM ;
end;
$$;
rollback;

/* test should fail upon inserting an order with state other than placed or updating an order state to something other than placed
Because there is no delivery note*/
--4. insert
begin transaction;
select USP_DROP_CONSTRAINTS(2);
do
$$
begin
insert into supplier values
('Jumbo','123456789','Ruitenberglaan 27 Arnhem');
insert into "ORDER" values
(1,'Jumbo','Awaiting payment','12-12-18',null);
    raise notice 'C2. Test 4 failed';
exception when others then
    raise notice 'C2. Test 4 passed (%)', SQLERRM;
end;
$$;
rollback;

--5. update
begin transaction;
select USP_DROP_CONSTRAINTS(2);
do
$$
begin
insert into supplier values
('Jumbo','123456789','Ruitenberglaan 27 Arnhem');
insert into "ORDER" values
(1,'Jumbo','Placed','12-12-18', null);
update "ORDER"
set state = 'Awaiting payment';
    raise notice 'C2. Test 5 failed';
    exception when others then
    raise notice 'C2. Test 5 passed (%)', SQLERRM;
end;
$$;
rollback;

/* test should pass upon deleting a delivery or updating a delivery
because the order it corresponds to is placed*/
--6. delete
begin transaction;
select USP_DROP_CONSTRAINTS(2);
do
$$
begin
insert into supplier values
('Jumbo','123456789','Ruitenberglaan 27 Arnhem');
insert into "ORDER" values
(1,'Jumbo','Placed','12-12-18', null);
insert into delivery values
(1,1,'message',null);
delete from delivery;
raise notice 'C2. Test 6 passed';
    exception when others then
    raise notice 'C2. Test 6 failed (%)', SQLERRM;
end;
$$;
rollback;

--7. update
begin transaction;
select USP_DROP_CONSTRAINTS(2);
do
$$
begin
insert into supplier values
('Jumbo','123456789','Ruitenberglaan 27 Arnhem');
insert into "ORDER" values
(1,'Jumbo','Placed','12-12-18', null),
(2,'Jumbo','Placed','10-10-18', null);
insert into delivery values
(1,1,'message',null);
update delivery
set Order_id = 2;
raise notice 'C2. Test 7 passed';
    exception when others then
    raise notice 'C2. Test 7 failed (%)', SQLERRM;
end;
$$;
rollback;

/* test should fail upon deleting a delivery or updating a delivery
because the order it correpsonds to is something other than Placed*/
--8. delete
begin transaction;
select USP_DROP_CONSTRAINTS(2);
do
$$
begin
insert into supplier values
('Jumbo','123456789','Ruitenberglaan 27 Arnhem');
insert into "ORDER" values
(1,'Jumbo','Placed','12-12-18', null);
insert into delivery values
(1,1,'message',null);
update "ORDER"
set State = 'Awaiting payment';
delete from delivery;
    raise notice 'C2. Test 8 failed';
exception when others then
    raise notice 'C2. Test 8 passed (%)', SQLERRM;
end;
$$;
rollback;

--9. update
begin transaction;
select USP_DROP_CONSTRAINTS(2);
do
$$
begin
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
    raise notice 'C2. Test 8 failed';
exception when others then
    raise notice 'C2. Test 9 passed (%)', SQLERRM;
end;
$$;
rollback;

/*===== Constraint 3 PaidHasInvoice =====*/
/* Tests should pass upon inserting a paid order or updating an order state to paid.*/
--1. insert
begin transaction;
select USP_DROP_CONSTRAINTS(3);
do
$$
begin
    insert into invoice values('1');
    insert into supplier values('jumbo', '123213', 'ijssellaan');
    insert into "ORDER" values(1, 'jumbo', 'Paid', '2019-12-12', '1');
    raise notice 'C3. Test 1 passed';
    exception when others then
    raise notice 'C3. Test 1 failed (%)', SQLERRM;
end;
$$;
rollback;

--2. update
begin transaction;
select USP_DROP_CONSTRAINTS(3);
do
$$
begin
    insert into invoice values('1');
    insert into supplier values('jumbo', '123213', 'ijssellaan');
    insert into "ORDER" values(1, 'jumbo', 'Paid', '2019-12-12', '1');
    update "ORDER" set state = 'Paid', invoice_id = '1';
    raise notice 'C3. Test 2 passed';
    exception when others then
    raise notice 'C3. Test 2 failed (%)', SQLERRM;
end;
$$;
rollback;

/* Tests should raise a check constraint error if order is paid and no invoice is associated*/
--3. insert
begin transaction;
select USP_DROP_CONSTRAINTS(3);
do
$$
begin
    insert into invoice values('1');
    insert into supplier values('jumbo', '123213', 'ijssellaan');
    insert into "ORDER" values(1, 'jumbo', 'Paid', '2019-12-12', null);
    raise notice 'C3. Test 3 failed';
    exception when others then
    raise notice 'C3. Test 3 passed (%)', SQLERRM;
end;
$$;
rollback;

--4. update
begin transaction;
select USP_DROP_CONSTRAINTS(3);
do
$$
begin
    insert into invoice values('1');
    insert into supplier values('jumbo', '123213', 'ijssellaan');
    insert into "ORDER" values(1, 'jumbo', 'Placed', '2019-12-12', null);
    update "ORDER" set invoice_id = '1';
    raise notice 'C3. Test 4 failed';
    exception when others then
    raise notice 'C3. Test 4 passed (%)', SQLERRM;
end;
$$;
rollback;

/* Tests should not pass if state is not paid and an invoice is attached to the order. */
--5. insert
begin transaction;
select USP_DROP_CONSTRAINTS(3);
do
$$
begin
    insert into invoice values('1');
    insert into supplier values('jumbo', '123213', 'ijssellaan');
    insert into "ORDER" values(1, 'jumbo', 'Placed', '2019-12-12', 1);
    raise notice 'C3. Test 5 failed';
    exception when others then
    raise notice 'C3. Test 5 passed (%)', SQLERRM;
end;
$$;
rollback;

--6. update
begin transaction;
select USP_DROP_CONSTRAINTS(3);
do
$$
begin
    insert into invoice values('1');
    insert into supplier values('jumbo', '123213', 'ijssellaan');
    insert into "ORDER" values(1, 'jumbo', 'Placed', '2019-12-12', 1);
    update "ORDER" set state = 'Awaiting payment', invoice_id = '1';
    raise notice 'C3. Test 6 failed';
    exception when others then
    raise notice 'C3. Test 6 passed (%)', SQLERRM;
end;
$$;
rollback;

/* Constraint 4 NotCompleteHasDiscrepancy */
/* The trigger on ORDER will be tested first. The next insert and update will fail
 because there isn't a discrepancy note */
--1. insert
begin transaction;
select USP_DROP_CONSTRAINTS(4);
do
$$
begin
alter table "ORDER" drop constraint if exists fk_order_supplier;
insert into "ORDER" values
('Order3', 'Supplier2', 'Not complete', current_date, null);
    raise notice 'C4. Test 1 failed';
    exception when others then
    raise notice 'C4. Test 1 passed (%)', SQLERRM;
end;
$$;
rollback;

--2. update
begin transaction;
select USP_DROP_CONSTRAINTS(4);
do
$$
begin
alter table "ORDER" drop constraint if exists fk_order_supplier;
insert into "ORDER" values
('Order2', 'Supplier2', 'Awaiting payment', current_date, null);
update "ORDER"
set state = 'Not complete';
    raise notice 'C4. Test 2 failed';
    exception when others then
    raise notice 'C4. Test 2 passed (%)', SQLERRM;
end;
$$;
rollback;

/* The following test will succeed because a discrepancy note exists. For a discrepancy note to be created,
there has to be an order. Thats why an order is created first.*/
--3. insert
begin transaction;
select USP_DROP_CONSTRAINTS(4);
do
$$
begin
alter table "ORDER" drop constraint if exists fk_order_supplier;
insert into "ORDER" values
('1', 'test', 'Placed', current_date, null);
insert into DISCREPANCY (order_id, message, place_date) values
('1', 'test', current_date);
update "ORDER"
set state = 'Not complete';
raise notice 'C4. Test 3 passed';
    exception when others then
    raise notice 'C4. Test 3 failed (%)', SQLERRM;
end;
$$;
rollback;

/* Now the trigger on DISCREPANCY will be tested. This wil fail because the order it gets assigend to does not have the state Not complete.
When deleted it will also fail because the order is still not completed.*/
--4. update
begin transaction;
select USP_DROP_CONSTRAINTS(4);
do
$$
begin
alter table "ORDER" drop constraint if exists fk_order_supplier;
insert into "ORDER" values
('1', 'test', 'Placed', current_date, null),
('2', 'test', 'Paid', current_date, null);
insert into discrepancy (order_id, message, place_date) values
('1', 'test', current_date);
update "ORDER"
set state = 'Not complete';
update discrepancy
set order_id = '2';
    raise notice 'C4. Test 4 failed';
    exception when others then
    raise notice 'C4. Test 4 passed (%)', SQLERRM;
end;
$$;
rollback;

--5. delete
begin transaction;
select USP_DROP_CONSTRAINTS(4);
do
$$
begin

alter table "ORDER" drop constraint if exists fk_order_supplier;
insert into "ORDER" values
('1', 'test', 'Placed', current_date, null);
insert into discrepancy (order_id, message, place_date) values
('1', 'test', current_date);
update "ORDER"
set state = 'Not complete';
delete from discrepancy;
    raise notice 'C4. Test 5 failed';
    exception when others then
    raise notice 'C4. Test 5 passed (%)', SQLERRM;
end;
$$;
rollback;

/* The following tests will succeed. Because the order has been completed, so its state changes. */
--6. update
begin transaction;
select USP_DROP_CONSTRAINTS(4);
do
$$
begin
alter table "ORDER" drop constraint if exists fk_order_supplier;
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
raise notice 'C4. Test 6 passed';
    exception when others then
    raise notice 'C4. Test 6 failed (%)', SQLERRM;
end;
$$;
rollback;

--7. delete
begin transaction;
select USP_DROP_CONSTRAINTS(4);
do
$$
begin
alter table "ORDER" drop constraint if exists fk_order_supplier;
insert into "ORDER" values
('1', 'test', 'Placed', current_date, null);
insert into discrepancy (order_id, message, place_date) values
('1', 'test', current_date);
delete from discrepancy;
raise notice 'C4. Test 7 passed';
    exception when others then
    raise notice 'C4. Test 7 failed (%)', SQLERRM;
end;
$$;
rollback;

/*===== Constraint 5 AnimalGender =====*/
/* Test should pass when inserting or updating animal gender to 'male' */
--1. insert
begin transaction;
select USP_DROP_CONSTRAINTS(5);
do
$$
begin
insert into species values
('Monkey','Things with long arms',null,null,null);
insert into animal values
(1,'male','Abu' ,'Engeland', '12-12-18', 'Monkey'),
(2,'male','Koko','Engeland', '10-10-18', 'Monkey');
raise notice 'C5. Test 1 passed';
    exception when others then
    raise notice 'C5. Test 1 failed (%)', SQLERRM;
end;
$$;
rollback;

--2. update
begin transaction;
select USP_DROP_CONSTRAINTS(5);
do
$$
begin
insert into species values
('Monkey','Things with long arms',null,null,null);
insert into animal values
(1,'female','Abu' ,'Engeland', '12-12-18', 'Monkey'),
(2,'female','Koko','Engeland', '10-10-18', 'Monkey');
update animal
set gender_s = 'male';
raise notice 'C5. Test 2 passed';
    exception when others then
    raise notice 'C5. Test 2 failed (%)', SQLERRM;
end;
$$;
rollback;

/* Test should pass when inserting or updating animal gender to 'female' */
--3. insert
begin transaction;
select USP_DROP_CONSTRAINTS(5);
do
$$
begin
insert into species values
('Monkey','Things with long arms',null,null,null);
insert into animal values
(1,'female','Abu' ,'Engeland', '12-12-18', 'Monkey'),
(2,'female','Koko','Engeland', '10-10-18', 'Monkey');
raise notice 'C5. Test 3 passed';
    exception when others then
    raise notice 'C5. Test 3 failed (%)', SQLERRM;
end;
$$;
rollback;

--4. update
begin transaction;
select USP_DROP_CONSTRAINTS(5);
do
$$
begin
insert into species values
('Monkey','Things with long arms',null,null,null);
insert into animal values
(1,'male','Abu' ,'Engeland', '12-12-18', 'Monkey'),
(2,'male','Koko','Engeland', '10-10-18', 'Monkey');
update animal
set gender_s = 'female';
raise notice 'C5. Test 4 passed';
    exception when others then
    raise notice 'C5. Test 4 failed(%)', SQLERRM;
end;
$$;
rollback;

/* Test should pass when inserting or updating animal gender to 'other' */
--5. insert
begin transaction;
select USP_DROP_CONSTRAINTS(5);
do
$$
begin
insert into species values
('Monkey','Things with long arms',null,null,null);
insert into animal values
(1,'other','Abu' ,'Engeland', '12-12-18', 'Monkey'),
(2,'other','Koko','Engeland', '10-10-18', 'Monkey');
raise notice 'C5. Test 5 passed';
    exception when others then
    raise notice 'C5. Test 5 failed(%)', SQLERRM;
end;
$$;
rollback;

--6. update
begin transaction;
select USP_DROP_CONSTRAINTS(5);
do
$$
begin
insert into species values
('Monkey','Things with long arms',null,null,null);
insert into animal values
(1,'male','Abu' ,'Engeland', '12-12-18', 'Monkey'),
(2,'male','Koko','Engeland', '10-10-18', 'Monkey');
update animal
set gender_s = 'other';
raise notice 'C5. Test 6 passed';
    exception when others then
    raise notice 'C5. Test 6 failed(%)', SQLERRM;
end;
$$;
rollback;

/* Test should fail when inserting or updating animal gender to something other than 'male', 'female', 'other' */
--7. insert
begin transaction;
select USP_DROP_CONSTRAINTS(5);
do
$$
begin
insert into species values
('Monkey','Things with long arms',null,null,null);
insert into animal values
(1,'male','Abu' ,'Engeland', '12-12-18', 'Monkey'),
(2,'something','Koko','Engeland', '10-10-18', 'Monkey');
    raise notice 'C5. Test 7 failed';
    exception when others then
    raise notice 'C5. Test 7 passed (%)', SQLERRM;
end;
$$;
rollback;

--8. update
begin transaction;
select USP_DROP_CONSTRAINTS(5);
do
$$
begin
insert into species values
('Monkey','Things with long arms',null,null,null);
insert into animal values
(1,'male','Abu' ,'Engeland', '12-12-18', 'Monkey'),
(2,'male','Koko','Engeland', '10-10-18', 'Monkey');
update animal
set gender_s = 'something';
  raise notice 'C5. Test 8 failed';
exception when others then
raise notice 'C5. Test 8 passed (%)', SQLERRM;
end;
$$;
rollback;

/*===== Constraint 6 AnimalHasOneEnclosure =====*/
/* The following tests will succeed because none of the the dates will overlap */

--1. insert
begin transaction;
select USP_DROP_CONSTRAINTS(6);
do
$$
begin
alter table animal_enclosure
drop constraint fk_animal_in_enclosure;
alter table animal_enclosure
drop constraint fk_enclosure_has_animal;

insert into animal_enclosure values
('1', 'test', 1, '2019-05-23', '2019-05-24');

insert into animal_enclosure values
('1', 'test', 2, '2019-05-25', '2019-05-26');
raise notice 'C6. Test 1 passed';
  exception when others then
  raise notice 'C6. Test 1 failed(%)', SQLERRM;
end;
$$;
rollback;

--2. update
begin transaction;
select USP_DROP_CONSTRAINTS(6);
do
$$
begin
alter table animal_enclosure
drop constraint fk_animal_in_enclosure;
alter table animal_enclosure
drop constraint fk_enclosure_has_animal;

insert into animal_enclosure values
('1', 'test', 3, '2019-01-01', '2019-01-31');

insert into animal_enclosure values
('1', 'test', 1, '2019-05-23', null);

update animal_enclosure
set End_date = '2019-05-24'
where Animal_id = '1' and since = '2019-05-23';
raise notice 'C6. Test 2 passed';
  exception when others then
  raise notice 'C6. Test 2 failed(%)', SQLERRM;
end;
$$;
rollback;

/* The following test will fail because the new since date is in between an older since and end_date.*/
--3. insert
begin transaction;
select USP_DROP_CONSTRAINTS(6);
do
$$
begin
alter table animal_enclosure
drop constraint fk_animal_in_enclosure;
alter table animal_enclosure
drop constraint fk_enclosure_has_animal;

insert into animal_enclosure values
('1', 'test', 1, '2019-05-23', '2019-05-25');

insert into animal_enclosure values
('1', 'test', 2, '2019-05-24', '2019-05-26');
  raise notice 'C6. Test 3 failed';
    exception when others then
    raise notice 'C6. Test 3 passed (%)', SQLERRM;
end;
$$;
rollback;

--4. update
begin transaction;
select USP_DROP_CONSTRAINTS(6);
do
$$
begin
alter table animal_enclosure
drop constraint fk_animal_in_enclosure;
alter table animal_enclosure
drop constraint fk_enclosure_has_animal;

insert into animal_enclosure values
('1', 'test', 1, '2019-05-23', '2019-05-25'),
('1', 'test', 2, '2019-05-25', '2019-05-31'),
('1', 'test', 3, '2019-06-01', '2019-06-02');

update animal_enclosure
set Since = '2019-05-24'
where animal_id = '1' and Since = '2019-05-25';
  raise notice 'C6. Test 4 failed';
    exception when others then
    raise notice 'C6. Test 4 passed (%)', SQLERRM;
end;
$$;
rollback;

/* The next test will fail because the end_date is in between an older since date and end_date*/
--5. insert
begin transaction;
select USP_DROP_CONSTRAINTS(6);
do
$$
begin
alter table animal_enclosure
drop constraint fk_animal_in_enclosure;
alter table animal_enclosure
drop constraint fk_enclosure_has_animal;

insert into animal_enclosure values
('1', 'test', 1, '2019-05-23', '2019-05-25');

insert into animal_enclosure values
('1', 'test', 2, '2019-05-10', '2019-05-24');
  raise notice 'C6. Test 5 failed';
  exception when others then
  raise notice 'C6. Test 5 passed (%)', SQLERRM;
end;
$$;
rollback;

--6. update
begin transaction;
select USP_DROP_CONSTRAINTS(6);
do
$$
begin
alter table animal_enclosure
drop constraint fk_animal_in_enclosure;
alter table animal_enclosure
drop constraint fk_enclosure_has_animal;

insert into animal_enclosure values
('1', 'test', 1, '2019-05-23', '2019-05-25'),
('1', 'test', 2, '2019-05-25', '2019-05-31');

update animal_enclosure
set since = '2019-05-10',
    End_date = '2019-05-26'
where animal_id = '1' and Since = '2019-05-23';
  raise notice 'C6. Test 6 failed';
  exception when others then
  raise notice 'C6. Test 6 passed (%)', SQLERRM;
end;
$$;
rollback;

/* This test will fail because the the new since date and end_date are in between a older since date and end_date. */
--7. insert
begin transaction;
select USP_DROP_CONSTRAINTS(6);
do
$$
begin
alter table animal_enclosure
drop constraint fk_animal_in_enclosure;
alter table animal_enclosure
drop constraint fk_enclosure_has_animal;

insert into animal_enclosure values
('1', 'test', 1, '2019-05-23', '2019-05-30');

insert into animal_enclosure values
('1', 'test', 1,  '2019-05-24','2019-05-26');
  raise notice 'C6. Test 7 failed';
  exception when others then
  raise notice 'C6. Test 7 passed (%)', SQLERRM;
end;
$$;
rollback;

--8. update
begin transaction;
select USP_DROP_CONSTRAINTS(6);
do
$$
begin
alter table animal_enclosure
drop constraint fk_animal_in_enclosure;
alter table animal_enclosure
drop constraint fk_enclosure_has_animal;

insert into animal_enclosure values
('1', 'test', 1, '2019-05-23', '2019-05-25'),
('1', 'test', 2, '2019-05-25', '2019-05-31');

update animal_enclosure
set since = '2019-05-26',
    End_date = '2019-05-29'
where animal_id = '1' and Since = '2019-05-23';
  raise notice 'C6. Test 8 failed';
  exception when others then
  raise notice 'C6. Test 8 passed (%)', SQLERRM;
end;
$$;
rollback;

/* The following test will fail because the new since date is before the old since date and the new end_date is after the old end_date */
--9. insert
begin transaction;
select USP_DROP_CONSTRAINTS(6);
do
$$
begin
alter table animal_enclosure
drop constraint fk_animal_in_enclosure;
alter table animal_enclosure
drop constraint fk_enclosure_has_animal;

insert into animal_enclosure values
('1', 'test', 1, '2019-05-23', '2019-05-25');

insert into animal_enclosure values
('1', 'test', 1, '2019-05-20', '2019-05-26');
  raise notice 'C6. Test 9 failed';
  exception when others then
  raise notice 'C6. Test 9 passed (%)', SQLERRM;
end;
$$;
rollback;

--10. update
begin transaction;
select USP_DROP_CONSTRAINTS(6);
do
$$
begin
alter table animal_enclosure
drop constraint fk_animal_in_enclosure;
alter table animal_enclosure
drop constraint fk_enclosure_has_animal;

insert into animal_enclosure values
('1', 'test', 1, '2019-05-23', '2019-05-25'),
('1', 'test', 2, '2019-05-25', '2019-05-31');

update animal_enclosure
set since = '2019-05-24',
    End_date = '2019-06-01'
where animal_id = '1' and Since = '2019-05-23';
  raise notice 'C6. Test 10 failed';
  exception when others then
  raise notice 'C6. Test 10 passed (%)', SQLERRM;
end;
$$;
rollback;

/*===== Constraint 7 LoanType =====*/
/* Tests should pass when loan type 'to' is inserted or updated */
--1. insert
begin transaction;
select USP_DROP_CONSTRAINTS(7);
do
$$
begin
alter table exchange drop constraint fk_animal_exchange;
insert into exchange values
(1,'10-10-18','12-12-18',null,'to','kuala lumper');
  raise notice 'C7. Test 1 passed';
  exception when others then
  raise notice 'C7. Test 1 failed (%)', SQLERRM;
end;
$$;
rollback;

--2. update
begin transaction;
select USP_DROP_CONSTRAINTS(7);
do
$$
begin
alter table exchange drop constraint fk_animal_exchange;
insert into exchange values
(1,'10-10-18','12-12-18',null,'from','kuala lumper');
update exchange
set loan_type = 'to';
  raise notice 'C7. Test 2 passed';
  exception when others then
  raise notice 'C7. Test 2 failed (%)', SQLERRM;
end;
$$;
rollback;

/* Tests should pass when loan type 'from' is inserted or updated */
--3. insert
begin transaction;
select USP_DROP_CONSTRAINTS(7);
do
$$
begin
alter table exchange drop constraint fk_animal_exchange;
insert into exchange values
(1,'10-10-18','12-12-18',null,'from','kuala lumper');
  raise notice 'C7. Test 3 passed';
  exception when others then
  raise notice 'C7. Test 3 failed (%)', SQLERRM;
end;
$$;
rollback;

--4. update
begin transaction;
select USP_DROP_CONSTRAINTS(7);
do
$$
begin
alter table exchange drop constraint fk_animal_exchange;
insert into exchange values
(1,'10-10-18','12-12-18',null,'to','kuala lumper');
update exchange
set loan_type = 'from';
    raise notice 'C7. Test 4 passed';
    exception when others then
    raise notice 'C7. Test 4 failed (%)', SQLERRM;
end;
$$;
rollback;

/* Tests should fail when loan type is not 'to' or 'from' inserted or updated */
--5. insert
begin transaction;
select USP_DROP_CONSTRAINTS(7);
do
$$
begin
alter table exchange drop constraint fk_animal_exchange;
insert into exchange values
(1,'10-10-18','12-12-18',null,'tow','kuala lumper');
    raise notice 'C7. Test 5 failed';
    exception when others then
    raise notice 'C7. Test 5 passed (%)', SQLERRM;
end;
$$;
rollback;

--6. update
begin transaction;
select USP_DROP_CONSTRAINTS(7);
do
$$
begin
alter table exchange drop constraint fk_animal_exchange;
insert into exchange values
(1,'10-10-18','12-12-18',null,'from','kuala lumper');
update exchange
set loan_type = 'tow';
    raise notice 'C7. Test 6 failed';
    exception when others then
    raise notice 'C7. Test 6 passed (%)', SQLERRM;
end;
$$;
rollback;

/*===== Constraint 8 NextVisitVet =====*/
/*Tests should pass when a next_visit that is later than visit_date is inserted or updated*/
--1. insert
begin transaction;
select USP_DROP_CONSTRAINTS(8);
do
$$
begin
alter table animal_visits_vet drop constraint if exists fk_animal_check_up;
alter table animal_visits_vet drop constraint if exists fk_prescription_of_vet_visit;
alter table animal_visits_vet drop constraint if exists fk_vet_visited_animal;

insert into animal_visits_vet values
('sai-1','10-10-2018','pil','Bob','12-12-2018'),
('sai-2','10-10-2018','pil','BOB','12-12-2018');
    raise notice 'C8. Test 1 passed';
    exception when others then
    raise notice 'C8. Test 1 failed (%)', SQLERRM;
end;
$$;
rollback;

--2. update
begin transaction;
select USP_DROP_CONSTRAINTS(8);
do
$$
begin
alter table animal_visits_vet drop constraint if exists fk_animal_check_up;
alter table animal_visits_vet drop constraint if exists fk_prescription_of_vet_visit;
alter table animal_visits_vet drop constraint if exists fk_vet_visited_animal;

insert into animal_visits_vet values
('sai-1','10-10-2018','pil','Bob','12-12-2018'),
('sai-2','10-10-2018','pil','BOB','12-12-2018');

update animal_visits_vet values
set next_visit = '11-11-2018';
    raise notice 'C8. Test 2 passed';
    exception when others then
    raise notice 'C8. Test 2 failed (%)', SQLERRM;
end;
$$;
rollback;

/* tests should fail because next_visit that is before visit_date is inserted or updated*/
--3. insert
begin transaction;
select USP_DROP_CONSTRAINTS(8);
do
$$
begin
alter table animal_visits_vet drop constraint if exists fk_animal_check_up;
alter table animal_visits_vet drop constraint if exists fk_prescription_of_vet_visit;
alter table animal_visits_vet drop constraint if exists fk_vet_visited_animal;

insert into animal_visits_vet values
('sai-1','10-10-2018','pil','Bob','12-12-2018'),
('sai-2','12-12-2018','pil','BOB','10-10-2018');
    raise notice 'C8. Test 3 failed';
    exception when others then
    raise notice 'C8. Test 3 passed (%)', SQLERRM;
end;
$$;
rollback;

--4. update
begin transaction;
select USP_DROP_CONSTRAINTS(8);
do
$$
begin
alter table animal_visits_vet drop constraint if exists fk_animal_check_up;
alter table animal_visits_vet drop constraint if exists fk_prescription_of_vet_visit;
alter table animal_visits_vet drop constraint if exists fk_vet_visited_animal;

insert into animal_visits_vet values
('sai-1','11-11-2018','pil','Bob','12-12-2018'),
('sai-2','11-11-2018','pil','BOB','12-12-2018');

update animal_visits_vet values
set next_visit = '10-10-2018';
    raise notice 'C8. Test 4 failed';
    exception when others then
    raise notice 'C8. Test 4 passed (%)', SQLERRM;
end;
$$;
rollback;

/* tests should fail because next_visit that is before visit_date is inserted or updated*/
--5. insert
begin transaction;
select USP_DROP_CONSTRAINTS(8);
do
$$
begin
alter table animal_visits_vet drop constraint if exists fk_animal_check_up;
alter table animal_visits_vet drop constraint if exists fk_prescription_of_vet_visit;
alter table animal_visits_vet drop constraint if exists fk_vet_visited_animal;

insert into animal_visits_vet values
('sai-1','10-10-2018','pil','Bob','12-12-2018'),
('sai-2','11-11-2018','pil','BOB','11-11-2018');
    raise notice 'C8. Test 5 failed';
    exception when others then
    raise notice 'C8. Test 5 passed (%)', SQLERRM;
end;
$$;
rollback;

--6. update
begin transaction;
select USP_DROP_CONSTRAINTS(8);
do
$$
begin
alter table animal_visits_vet drop constraint if exists fk_animal_check_up;
alter table animal_visits_vet drop constraint if exists fk_prescription_of_vet_visit;
alter table animal_visits_vet drop constraint if exists fk_vet_visited_animal;

insert into animal_visits_vet values
('sai-1','10-10-2018','pil','Bob','11-11-2018'),
('sai-2','11-11-2018','pil','BOB','12-12-2018');

update animal_visits_vet values
set next_visit = '11-11-2018';
    raise notice 'C8. Test 6 failed';
    exception when others then
    raise notice 'C8. Test 6 passed (%)', SQLERRM;
end;
$$;
rollback;

/*===== Constraint 9 EnclosureEndDate =====*/
/* Tests should pass when end_date is on the same date as the date of stay of the animal or later.*/
--1. insert
begin transaction;
select USP_DROP_CONSTRAINTS(9);
do
$$
begin
alter table animal_enclosure drop constraint if exists fk_animal_in_enclosure;
alter table animal_enclosure drop constraint if exists fk_enclosure_has_animal;

insert into animal_enclosure values('an-1', 'area', 1, '2019-01-01', '2019-02-02');
    raise notice 'C9. Test 1 passed';
    exception when others then
    raise notice 'C9. Test 1 failed (%)', SQLERRM;
end;
$$;
rollback;

--2. update
begin transaction;
select USP_DROP_CONSTRAINTS(9);
do
$$
begin
alter table animal_enclosure drop constraint if exists fk_animal_in_enclosure;
alter table animal_enclosure drop constraint if exists fk_enclosure_has_animal;

insert into animal_enclosure values('an-1', 'area', 1, '2019-01-01', '2019-02-02');

update animal_enclosure set since = '2019-01-20';

    raise notice 'C9. Test 2 passed';
    exception when others then
    raise notice 'C9. Test 2 failed (%)', SQLERRM;
end;
$$;
rollback;

/* Tests should fail when end_date is earlier than the date of stay of the animal.*/
--3. insert
begin transaction;
select USP_DROP_CONSTRAINTS(9);
do
$$
begin
alter table animal_enclosure drop constraint if exists fk_animal_in_enclosure;
alter table animal_enclosure drop constraint if exists fk_enclosure_has_animal;

insert into animal_enclosure values('an-1', 'area', 1, '2019-01-01', '2018-02-02');
    raise notice 'C9. Test 3 failed';
    exception when others then
    raise notice 'C9. Test 3 passed (%)', SQLERRM;
end;
$$;
rollback;

--4. update
begin transaction;
select USP_DROP_CONSTRAINTS(9);
do
$$
begin
alter table animal_enclosure drop constraint if exists fk_animal_in_enclosure;
alter table animal_enclosure drop constraint if exists fk_enclosure_has_animal;

insert into animal_enclosure values('an-1', 'area', 1, '2019-01-01', '2019-02-02');

update animal_enclosure set since = '2019-03-05';
    raise notice 'C9. Test 4 failed';
    exception when others then
    raise notice 'C9. Test 4 passed (%)', SQLERRM;
end;
$$;
rollback;

/*===== CONSTRAINT 10 SpottedAfterRelease ===== */
/*Test should pass if the spot_date  is same as the the reintroduction_date or later than the reintroduction_date.*/
--1. insert
begin transaction;
select USP_DROP_CONSTRAINTS(10);
do
$$
begin
alter table reintroduction drop constraint if exists fk_animal_reintroduction;
alter table spotted drop constraint if exists fk_animal_spotted;

insert into reintroduction values('an-1', '2018-10-05', 'location', null);
insert into reintroduction values('an-1', '2019-11-05', 'location', null);
insert into spotted values('an-1', '2018-10-05');
    raise notice 'C10. Test 1 passed';
    exception when others then
    raise notice 'C10. Test 1 failed (%)', SQLERRM;
end;
$$;
rollback;

--2. update
begin transaction;
select USP_DROP_CONSTRAINTS(10);
do
$$
begin
alter table reintroduction drop constraint if exists fk_animal_reintroduction;
alter table spotted drop constraint if exists fk_animal_spotted;

insert into reintroduction values('an-1', '2018-10-05', 'location', null);
insert into reintroduction values('an-1', '2019-11-05', 'location', null);
insert into spotted values('an-1', '2018-10-05');

update spotted set spot_date = '2018-11-06';
    raise notice 'C10. Test 2 passed';
    exception when others then
    raise notice 'C10. Test 2 failed (%)', SQLERRM;
end;
$$;
rollback;

/*Test should raise an error if spot_date is before the date when the animal is reintroduced in wild.*/
--3. insert
begin transaction;
select USP_DROP_CONSTRAINTS(10);
do
$$
begin
alter table reintroduction drop constraint if exists fk_animal_reintroduction;
alter table spotted drop constraint if exists fk_animal_spotted;

insert into reintroduction values('an-1', '2018-12-12', 'location', null);
insert into reintroduction values('an-1', '2019-11-05', 'location', null);
insert into spotted values('an-1', '2018-10-11');
    raise notice 'C10. Test 3 failed';
    exception when others then
    raise notice 'C10. Test 3 passed (%)', SQLERRM;
end;
$$;
rollback;

--4. update
begin transaction;
select USP_DROP_CONSTRAINTS(10);
do
$$
begin
alter table reintroduction drop constraint if exists fk_animal_reintroduction;
alter table spotted drop constraint if exists fk_animal_spotted;

insert into reintroduction values('an-1', '2018-10-05', 'location', null);
insert into reintroduction values('an-1', '2019-11-05', 'location', null);
insert into spotted values('an-1', '2018-10-05');

update spotted set spot_date = '2018-04-04';
    raise notice 'C10. Test 4 failed';
    exception when others then
    raise notice 'C10. Test 4 passed (%)', SQLERRM;
end;
$$;
rollback;

/*Test should pass if the there is still a reintroduction_date before the oldest spot_date after deleting or updating.*/
--5. update
begin transaction;
select USP_DROP_CONSTRAINTS(10);
do
$$
begin
alter table reintroduction drop constraint if exists fk_animal_reintroduction;
alter table spotted drop constraint if exists fk_animal_spotted;

insert into reintroduction values('an-1', '2017-04-04', 'location', null);
insert into reintroduction values('an-1', '2018-12-12', 'location', null);
insert into spotted values('an-1', '2019-01-01');

update reintroduction set reintroduction_date = '2019-05-05' where reintroduction_date = '2017-04-04';
    raise notice 'C10. Test 5 passed';
    exception when others then
    raise notice 'C10. Test 5 failed (%)', SQLERRM;
end;
$$;
rollback;

--6. delete
begin transaction;
select USP_DROP_CONSTRAINTS(10);
do
$$
begin
alter table reintroduction drop constraint if exists fk_animal_reintroduction;
alter table spotted drop constraint if exists fk_animal_spotted;

insert into reintroduction values('an-1', '2017-04-04', 'location', null);
insert into reintroduction values('an-1', '2018-12-12', 'location', null);
insert into spotted values('an-1', '2019-01-01');

delete from reintroduction where reintroduction_date = '2017-04-04';
    raise notice 'C10. Test 6 passed';
    exception when others then
    raise notice 'C10. Test 6 failed (%)', SQLERRM;
end;
$$;
rollback;

/*Test should raise an error if there is no reintroduction_date before the oldest spot_date*/
--7. update
begin transaction;
select USP_DROP_CONSTRAINTS(10);
do
$$
begin
alter table reintroduction drop constraint if exists fk_animal_reintroduction;
alter table spotted drop constraint if exists fk_animal_spotted;

insert into reintroduction values('an-1', '2017-04-04', 'location', null);
insert into reintroduction values('an-1', '2018-12-12', 'location', null);
insert into spotted values('an-1', '2018-01-01');

update reintroduction set reintroduction_date = '2019-05-05' where reintroduction_date = '2017-04-04';
    raise notice 'C10. Test 7 failed';
    exception when others then
    raise notice 'C10. Test 7 passed (%)', SQLERRM;
end;
$$;
rollback;

--8. delete
begin transaction;
select USP_DROP_CONSTRAINTS(10);
do
$$
begin
alter table reintroduction drop constraint if exists fk_animal_reintroduction;
alter table spotted drop constraint if exists fk_animal_spotted;

insert into reintroduction values('an-1', '2017-04-04', 'location', null);
insert into reintroduction values('an-1', '2019-04-03', 'location', null);
insert into spotted values('an-1', '2019-01-01');

delete from reintroduction where reintroduction_date = '2017-04-04';
    raise notice 'C10. Test 8 failed';
    exception when others then
    raise notice 'C10. Test 8 passed (%)', SQLERRM;
end;
$$;
rollback;

/*===== Constraint 11 AnimalReturned =====*/
/* Tests should pass when return_date is on the same date as exchange_date or later.*/
--1. insert
begin transaction;
select USP_DROP_CONSTRAINTS(11);
do
$$
begin
alter table exchange drop constraint if exists fk_animal_exchange;

insert into exchange values('an-1', '2019-01-01', '2019-02-02', 'comments', 'to', 'place');
    raise notice 'C11. Test 1 passed';
    exception when others then
    raise notice 'C11. Test 1 failed (%)', SQLERRM;
end;
$$;
rollback;

--2. update
begin transaction;
select USP_DROP_CONSTRAINTS(11);
do
$$
begin
alter table exchange drop constraint if exists fk_animal_exchange;

insert into exchange values('an-1', '2019-01-01', '2019-02-02', 'comments', 'to', 'place');

update exchange set return_date = '2019-03-03';
    raise notice 'C11. Test 2 passed';
    exception when others then
    raise notice 'C11. Test 2 failed (%)', SQLERRM;
end;
$$;
rollback;

/* Tests should fail if return_date is earlier than the exchange_date.*/
--3. insert
begin transaction;
select USP_DROP_CONSTRAINTS(11);
do
$$
begin
alter table exchange drop constraint if exists fk_animal_exchange;

insert into exchange values('an-1', '2019-01-01', '2018-11-25', 'comments', 'to', 'place');
    raise notice 'C11. Test 3 failed';
    exception when others then
    raise notice 'C11. Test 3 passed (%)', SQLERRM;
end;
$$;
rollback;

--4. update
begin transaction;
select USP_DROP_CONSTRAINTS(11);
do
$$
begin
alter table exchange drop constraint if exists fk_animal_exchange;

insert into exchange values('an-1', '2019-01-01', '2018-11-25', 'comments', 'to', 'place');

update exchange set exchange_date = '2018-03-03';
    raise notice 'C11. Test 4 failed';
    exception when others then
    raise notice 'C11. Test 4 passed (%)', SQLERRM;
end;
$$;
rollback;

/*===== CONSTRAINT 12 OffspringId =====*/
/* Test should pass if the updated mating_id is not the same as the offspring_id in table offspring. */
--1. insert
begin transaction;
select USP_DROP_CONSTRAINTS(12);
do
$$
begin
alter table mating drop constraint if exists fk_breeding_mate; -- MATING(animal_id) -> ANIMAL(animal_id)
alter table mating drop constraint if exists fk_mating_breeding__animal; -- MATING(mate_id) -> ANIMAL(animal_id)
alter table offspring drop constraint if exists fk_offsprin_animal_of_animal; -- OFFSPRING(offspring_id) -> ANIMAL(animal_id)

insert into mating values('an-1', '2019-04-04', 'ica', 'mate-1');
insert into offspring values('2019-04-04', 'an offspring', 'an-1', 'off-1');

update mating set mate_id = 'mate-2';
    raise notice 'C12. Test 1 passed';
    exception when others then
    raise notice 'C12. Test 1 failed (%)', SQLERRM;
end;
$$;
rollback;

/* Test should fail if the updated mate_id is the same as the offspring_id of the concerning mating. */
--2. update
begin transaction;
select USP_DROP_CONSTRAINTS(12);
do
$$
begin
alter table mating drop constraint if exists fk_breeding_mate; -- MATING(animal_id) -> ANIMAL(animal_id)
alter table mating drop constraint if exists fk_mating_breeding__animal; -- MATING(mate_id) -> ANIMAL(animal_id)
alter table offspring drop constraint if exists fk_offsprin_animal_of_animal; -- OFFSPRING(offspring_id) -> ANIMAL(animal_id)

insert into mating values('an-1', '2019-04-04', 'ica', 'mate-1');
insert into offspring values('2019-04-04', 'an offspring', 'an-1', 'off-1');

update mating set mate_id = 'off-1';
    raise notice 'C12. Test 2 failed';
    exception when others then
    raise notice 'C12. Test 2 passed (%)', SQLERRM;
end;
$$;
rollback;

/* Test should pass if an offspring is inserted or updated with a different id than the animal_id or the mate_id. */
--3. insert
begin transaction;
select USP_DROP_CONSTRAINTS(12);
do
$$
begin
alter table mating drop constraint if exists fk_breeding_mate; -- MATING(animal_id) -> ANIMAL(animal_id)
alter table mating drop constraint if exists fk_mating_breeding__animal; -- MATING(mate_id) -> ANIMAL(animal_id)
alter table offspring drop constraint if exists fk_offsprin_animal_of_animal; -- OFFSPRING(offspring_id) -> ANIMAL(animal_id)

insert into mating values('an-1', '2019-04-04', 'ica', 'mate-1');
insert into offspring values('2019-04-04', 'an offspring', 'an-1', 'off-1');
    raise notice 'C12. Test 3 passed';
    exception when others then
    raise notice 'C12. Test 3 failed (%)', SQLERRM;
end;
$$;
rollback;

--4. update
begin transaction;
select USP_DROP_CONSTRAINTS(12);
do
$$
begin
alter table mating drop constraint if exists fk_breeding_mate; -- MATING(animal_id) -> ANIMAL(animal_id)
alter table mating drop constraint if exists fk_mating_breeding__animal; -- MATING(mate_id) -> ANIMAL(animal_id)
alter table offspring drop constraint if exists fk_offsprin_animal_of_animal; -- OFFSPRING(offspring_id) -> ANIMAL(animal_id)

insert into mating values('an-1', '2019-04-04', 'ica', 'mate-1');
insert into offspring values('2019-04-04', 'an offspring', 'an-1', 'off-1');

update offspring set offspring_id = 'off-2';
    raise notice 'C12. Test 4 passed';
    exception when others then
    raise notice 'C12. Test 4 failed (%)', SQLERRM;
end;
$$;
rollback;

/*Test should fail if an inserted or updated offspring has the same id as the animal_id or the mate_id*/
--5. insert
begin transaction;
select USP_DROP_CONSTRAINTS(12);
do
$$
begin
alter table mating drop constraint if exists fk_breeding_mate; -- MATING(animal_id) -> ANIMAL(animal_id)
alter table mating drop constraint if exists fk_mating_breeding__animal; -- MATING(mate_id) -> ANIMAL(animal_id)
alter table offspring drop constraint if exists fk_offsprin_animal_of_animal; -- OFFSPRING(offspring_id) -> ANIMAL(animal_id)

insert into mating values('an-1', '2019-04-04', 'ica', 'mate-1');
insert into offspring values('2019-04-04', 'an offspring', 'an-1', 'an-1');
    raise notice 'C12. Test 5 failed';
    exception when others then
    raise notice 'C12. Test 5 passed (%)', SQLERRM;
end;
$$;
rollback;

--6. update
begin transaction;
select USP_DROP_CONSTRAINTS(12);
do
$$
begin
alter table mating drop constraint if exists fk_breeding_mate; -- MATING(animal_id) -> ANIMAL(animal_id)
alter table mating drop constraint if exists fk_mating_breeding__animal; -- MATING(mate_id) -> ANIMAL(animal_id)
alter table offspring drop constraint if exists fk_offsprin_animal_of_animal; -- OFFSPRING(offspring_id) -> ANIMAL(animal_id)

insert into mating values('an-1', '2019-04-04', 'ica', 'mate-1');
insert into offspring values('2019-04-04', 'an offspring', 'an-1', 'off-1');

update offspring set offspring_id = 'mate-1';
    raise notice 'C12. Test 6 failed';
    exception when others then
    raise notice 'C12. Test 6 passed (%)', SQLERRM;
end;
$$;
rollback;

/*===== Constraint 13 MateAndAnimalId ===== */
/* Tests should pass because mate id and animal id are not the same */
--1. insert
begin transaction;
select USP_DROP_CONSTRAINTS(13);
do
$$
begin
alter table mating drop constraint fk_breeding_mate;
alter table mating drop constraint fk_mating_breeding__animal;

insert into mating values
('sai-1', '12-12-18', 'duiven', 'sai-2'),
('sai-2', '01-01-19', 'duiven', 'sai-1');
    raise notice 'C13. Test 1 passed';
    exception when others then
    raise notice 'C13. Test 1 failed (%)', SQLERRM;
end;
$$;
rollback;

--2. update
begin transaction;
select USP_DROP_CONSTRAINTS(13);
do
$$
begin
alter table mating drop constraint fk_breeding_mate;
alter table mating drop constraint fk_mating_breeding__animal;

insert into mating values
('sai-1', '12-12-18', 'duiven', 'sai-2'),
('sai-2', '01-01-19', 'duiven', 'sai-1');

update mating
set animal_id = 'sai-3';
    raise notice 'C13. Test 2 passed';
    exception when others then
    raise notice 'C13. Test 2 failed (%)', SQLERRM;
end;
$$;
rollback;

/* Tests should fail because mate id and animal id are the same */
--3. insert
begin transaction;
select USP_DROP_CONSTRAINTS(13);
do
$$
begin
alter table mating drop constraint fk_breeding_mate;
alter table mating drop constraint fk_mating_breeding__animal;

insert into mating values
('sai-1', '12-12-18', 'duiven', 'sai-2'),
('sai-2', '01-01-19', 'duiven', 'sai-2');
    raise notice 'C13. Test 3 failed';
    exception when others then
    raise notice 'C13. Test 3 passed (%)', SQLERRM;
end;
$$;
rollback;

--4. update
begin transaction;
select USP_DROP_CONSTRAINTS(13);
do
$$
begin
alter table mating drop constraint fk_breeding_mate;
alter table mating drop constraint fk_mating_breeding__animal;

insert into mating values
('sai-1', '12-12-18', 'duiven', 'sai-2'),
('sai-2', '01-01-19', 'duiven', 'sai-1');

update mating
set animal_id = 'sai-2';
    raise notice 'C13. Test 4 failed';
    exception when others then
    raise notice 'C13. Test 4 passed (%)', SQLERRM;
end;
$$;
rollback;

/* ====== CONSTRAINT 14 DiscrepancyDate ======*/
/* Tests should pass upon insert a discrapency date or updating it */
--1. Insert
begin transaction;
select USP_DROP_CONSTRAINTS(14);
do
$$
begin
alter table "ORDER" drop constraint fk_order_invoice_of_invoice;
alter table "ORDER" drop constraint fk_order_supplier;

Insert into "ORDER" values ('1', 'berry', 'awaiting', '03-03-2019', '1');
Insert into discrepancy values (1, 1, 'test', '04-04-2019');
    raise notice 'C14. Test 1 passed';
    exception when others then
    raise notice 'C14. Test 1 failed (%)', SQLERRM;
end;
$$;
rollback;

--2. Update
begin transaction;
select USP_DROP_CONSTRAINTS(14);
do
$$
begin
alter table "ORDER" drop constraint fk_order_invoice_of_invoice;
alter table "ORDER" drop constraint fk_order_supplier;

Insert into "ORDER" values ('1', 'berry', 'awaiting', '03-03-2019', '1');
Insert into discrepancy values (1, 1, 'test', '04-04-2019');
Update discrepancy set place_date = '05-05-2019';
    raise notice 'C14. Test 2 passed';
    exception when others then
    raise notice 'C14. Test 2 failed (%)', SQLERRM;
end;
$$;
rollback;

/* Tests should fail after inserting and updating a earlier date */
--3. insert
begin transaction;
select USP_DROP_CONSTRAINTS(14);
do
$$
begin
alter table "ORDER" drop constraint fk_order_invoice_of_invoice;
alter table "ORDER" drop constraint fk_order_supplier;

Insert into "ORDER" values ('1', 'berry', 'awaiting', '03-03-2019', '1');
Insert into discrepancy values (1, 1, 'test', '02-02-2019');
    raise notice 'C14. Test 3 failed';
    exception when others then
    raise notice 'C14. Test 3 passed (%)', SQLERRM;
end;
$$;
rollback;

--4. update
begin transaction;
select USP_DROP_CONSTRAINTS(14);
do
$$
begin
alter table "ORDER" drop constraint fk_order_invoice_of_invoice;
alter table "ORDER" drop constraint fk_order_supplier;

Insert into "ORDER" values ('1', 'berry', 'awaiting', '03-03-2019', '1');
Insert into discrepancy values (1, 1, 'test', '04-04-2019');
Update discrepancy set place_date = '02-02-2019';
    raise notice 'C14. Test 4 failed';
    exception when others then
    raise notice 'C14. Test 4 passed (%)', SQLERRM;
end;
$$;
rollback;

/*===== CONSTRAINT 15 LineItemWeight =====*/
/* Tests should pass upon inserting a line_item or updating an line_item where the weight is higher than 0.*/

/* Test should pass as the weight is higher than 0*/
--1. insert
begin transaction;
select USP_DROP_CONSTRAINTS(15);
do
$$
begin
insert into invoice values('p1');
insert into supplier values('jumbo', '123123', 'ijssellaan');
insert into "ORDER" values('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
insert into food_kind values('banaan');
insert into line_item values('o123', 'banaan', 10, 10);
    raise notice 'C15. Test 1 passed';
    exception when others then
    raise notice 'C15. Test 1 failed (%)', SQLERRM;
end;
$$;
rollback;

--2. update
begin transaction;
select USP_DROP_CONSTRAINTS(15);
do
$$
begin
insert into invoice values('p1');
insert into supplier values('jumbo', '123123', 'ijssellaan');
insert into "ORDER" values('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
insert into food_kind values('banaan');
insert into line_item values('o123', 'banaan', 10, 15);
update line_item set weight = 10;
    raise notice 'C15. Test 2 passed';
    exception when others then
    raise notice 'C15. Test 2 failed (%)', SQLERRM;
end;
$$;
rollback;


/* Test should fail as the weight is equal to 0*/
--3. insert
begin transaction;
select USP_DROP_CONSTRAINTS(15);
do
$$
begin
insert into invoice values('p1');
insert into supplier values('jumbo', '123123', 'ijssellaan');
insert into "ORDER" values('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
insert into food_kind values('banaan');
insert into line_item values('o123', 'banaan', 10, 0);
    raise notice 'C15. Test 3 failed';
    exception when others then
    raise notice 'C15. Test 3 passed (%)', SQLERRM;
end;
$$;
rollback;

--4. update
begin transaction;
select USP_DROP_CONSTRAINTS(15);
do
$$
begin
insert into invoice values('p1');
insert into supplier values('jumbo', '123123', 'ijssellaan');
insert into "ORDER" values('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
insert into food_kind values('banaan');
insert into line_item values('o123', 'banaan', 10, 10);
update line_item set weight = 0;
    raise notice 'C15. Test 3 failed';
    exception when others then
    raise notice 'C15. Test 3 passed (%)', SQLERRM;
end;
$$;
rollback;


/*Test should fail as the weight is lower than 0*/
--5. insert
begin transaction;
select USP_DROP_CONSTRAINTS(15);
do
$$
begin
insert into invoice values('p1');
insert into supplier values('jumbo', '123123', 'ijssellaan');
insert into "ORDER" values('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
insert into food_kind values('banaan');
insert into line_item values('o123', 'banaan', 10, -10);
    raise notice 'C15. Test 5 failed';
    exception when others then
    raise notice 'C15. Test 5 passed (%)', SQLERRM;
end;
$$;
rollback;

--6. update
begin transaction;
select USP_DROP_CONSTRAINTS(15);
do
$$
begin
insert into invoice values('p1');
insert into supplier values('jumbo', '123123', 'ijssellaan');
insert into "ORDER" values('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
insert into food_kind values('banaan');
insert into line_item values('o123', 'banaan', 10, 10);
update line_item set weight = -10;
    raise notice 'C15. Test 6 failed';
    exception when others then
    raise notice 'C15. Test 6 passed (%)', SQLERRM;
end;
$$;
rollback;


/*===== CONSTRAINT 16 LineItemPrice =====*/
/* Tests should pass upon inserting a line_item or updating an line_item where the price is 0 or higher.*/

/* Test should pass as the price is higher than 0*/
--1. insert
begin transaction;
select USP_DROP_CONSTRAINTS(16);
do
$$
begin
insert into invoice values('p1');
insert into supplier values('jumbo', '123123', 'ijssellaan');
insert into "ORDER" values('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
insert into food_kind values('banaan');
insert into line_item values('o123', 'banaan', 1, 10);
    raise notice 'C16. Test 1 passed';
    exception when others then
    raise notice 'C16. Test 1 failed (%)', SQLERRM;
end;
$$;
rollback;

--2. update
begin transaction;
select USP_DROP_CONSTRAINTS(16);
do
$$
begin
insert into invoice values('p1');
insert into supplier values('jumbo', '123123', 'ijssellaan');
insert into "ORDER" values('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
insert into food_kind values('banaan');
insert into line_item values('o123', 'banaan', 1, 10);
update line_item set price = 20;
    raise notice 'C16. Test 2 passed';
    exception when others then
    raise notice 'C16. Test 2 failed (%)', SQLERRM;
end;
$$;
rollback;


/* Test should pass as the price is equal to 0*/
--3. insert
begin transaction;
select USP_DROP_CONSTRAINTS(16);
do
$$
begin
insert into invoice values('p1');
insert into supplier values('jumbo', '123123', 'ijssellaan');
insert into "ORDER" values('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
insert into food_kind values('banaan');
insert into line_item values('o123', 'banaan', 0, 10);
    raise notice 'C16. Test 3 passed';
    exception when others then
    raise notice 'C16. Test 3 failed (%)', SQLERRM;
end;
$$;
rollback;

--4. update
begin transaction;
select USP_DROP_CONSTRAINTS(16);
do
$$
begin
insert into invoice values('p1');
insert into supplier values('jumbo', '123123', 'ijssellaan');
insert into "ORDER" values('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
insert into food_kind values('banaan');
insert into line_item values('o123', 'banaan', 1, 10);
update line_item set price = 0;
    raise notice 'C16. Test 4 passed';
    exception when others then
    raise notice 'C16. Test 4 failed (%)', SQLERRM;
end;
$$;
rollback;


 /*Test should fail as the price is lower than 0*/
--5. insert
begin transaction;
select USP_DROP_CONSTRAINTS(16);
do
$$
begin
insert into invoice values('p1');
insert into supplier values('jumbo', '123123', 'ijssellaan');
insert into "ORDER" values('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
insert into food_kind values('banaan');
insert into line_item values('o123', 'banaan', -1, 10);
    raise notice 'C16. Test 5 failed';
    exception when others then
    raise notice 'C16. Test 5 passed (%)', SQLERRM;
end;
$$;
rollback;

--6. update
begin transaction;
select USP_DROP_CONSTRAINTS(16);
do
$$
begin
insert into invoice values('p1');
insert into supplier values('jumbo', '123123', 'ijssellaan');
insert into "ORDER" values('o123', 'jumbo', 'Paid', '2019-12-12', 'p1');
insert into food_kind values('banaan');
insert into line_item values('o123', 'banaan', 1, 10);
update line_item set price = -1;
    raise notice 'C16. Test 6 failed';
    exception when others then
    raise notice 'C16. Test 6 passed (%)', SQLERRM;
end;
$$;
rollback;

/* ====== Constraint 17 StockAmount ======*/
/* Tests should pass upon inserting or updating a value higher than 0 */
--1. insert
begin transaction;
select USP_DROP_CONSTRAINTS(17);
do
$$
begin
alter table stock drop constraint if exists fk_animal_foodstock;
alter table stock drop constraint if exists fk_food_in_stock;
insert into stock values ('apen', 'bananen', 5);
    raise notice 'C17. Test 1 passed';
    exception when others then
    raise notice 'C17. Test 1 failed (%)', SQLERRM;
end;
$$;
rollback;

--2. update
begin transaction;
select USP_DROP_CONSTRAINTS(17);
do
$$
begin
alter table stock drop constraint if exists fk_animal_foodstock;
alter table stock drop constraint if exists fk_food_in_stock;
insert into stock values ('apen', 'bananen', 5);
update stock set amount = 6;
    raise notice 'C17. Test 2 passed';
    exception when others then
    raise notice 'C17. Test 2 failed (%)', SQLERRM;
end;
$$;
rollback;

/* Tests should pass upon inserting or updating a value equal to 0 */
--3. insert
begin transaction;
select USP_DROP_CONSTRAINTS(17);
do
$$
begin
alter table stock drop constraint if exists fk_animal_foodstock;
alter table stock drop constraint if exists fk_food_in_stock;
insert into stock values ('apen', 'bananen', 0);
    update stock set amount = 6;
    raise notice 'C17. Test 3 passed';
    exception when others then
    raise notice 'C17. Test 3 failed (%)', SQLERRM;
end;
$$;
rollback;

--4. update
begin transaction;
select USP_DROP_CONSTRAINTS(17);
do
$$
begin
alter table stock drop constraint if exists fk_animal_foodstock;
alter table stock drop constraint if exists fk_food_in_stock;
insert into stock values ('apen', 'bananen', 5);
update stock set amount = 0;
    raise notice 'C17. Test 4 passed';
    exception when others then
    raise notice 'C17. Test 4 failed (%)', SQLERRM;
end;
$$;
rollback;

/* Tests should fail upon inserting or updating a value lower than 0 */
--5. insert
begin transaction;
select USP_DROP_CONSTRAINTS(17);
do
$$
begin
alter table stock drop constraint if exists fk_animal_foodstock;
alter table stock drop constraint if exists fk_food_in_stock;
insert into stock values ('apen', 'bananen', -5);
    raise notice 'C17. Test 5 failed';
    exception when others then
    raise notice 'C17. Test 5 passed (%)', SQLERRM;
end;
$$;
rollback;

--6. update
begin transaction;
select USP_DROP_CONSTRAINTS(17);
do
$$
begin
alter table stock drop constraint if exists fk_animal_foodstock;
alter table stock drop constraint if exists fk_food_in_stock;
insert into stock values ('apen', 'bananen', 5);
update stock set amount = -5;
    raise notice 'C17. Test 6 failed';
    exception when others then
    raise notice 'C17. Test 6 passed (%)', SQLERRM;
end;
$$;
rollback;

/* ====== CONSTRAINT 18 FeedingAmount ======*/
/*Test should pass upon inserting/updating a food amount higher than 0*/
--1. insert
begin transaction;
select USP_DROP_CONSTRAINTS(18);
do
$$
begin
alter table feeding drop constraint if exists fk_feeding_for_animal;
alter table feeding drop constraint if exists fk_food_to_be_fed;
insert into feeding values('1', 'Kapsalon', '11/11/12',1);
    raise notice 'C18. Test 1 passed';
    exception when others then
    raise notice 'C18. Test 1 failed (%)', SQLERRM;
end;
$$;
rollback;

--2. update
begin transaction;
select USP_DROP_CONSTRAINTS(18);
do
$$
begin
alter table feeding drop constraint if exists fk_feeding_for_animal;
alter table feeding drop constraint if exists fk_food_to_be_fed;
insert into feeding values('1', 'Kapsalon', '11/11/12',1);
update feeding set amount = 2;
    raise notice 'C18. Test 2 passed';
    exception when others then
    raise notice 'C18. Test 2 failed (%)', SQLERRM;
end;
$$;
rollback;

/*test should fail upon inserting/updating a food amount equal to 0*/
--3. insert
begin transaction;
select USP_DROP_CONSTRAINTS(18);
do
$$
begin
alter table feeding drop constraint if exists fk_feeding_for_animal;
alter table feeding drop constraint if exists fk_food_to_be_fed;
insert into feeding values('1', 'Kapsalon', '11/11/12',0);
    raise notice 'C18. Test 3 failed';
    exception when others then
    raise notice 'C18. Test 3 passed (%)', SQLERRM;
end;
$$;
rollback;

--4. update
begin transaction;
select USP_DROP_CONSTRAINTS(18);
do
$$
begin
alter table feeding drop constraint if exists fk_feeding_for_animal;
alter table feeding drop constraint if exists fk_food_to_be_fed;
insert into feeding values('1', 'Kapsalon', '11/11/12',1);
update feeding set amount = 0;
    raise notice 'C18. Test 4 failed';
    exception when others then
    raise notice 'C18. Test 4 passed (%)', SQLERRM;
end;
$$;
rollback;


/*test should fail upon inserting/updating a food amount less than 0*/
--5. insert
begin transaction;
select USP_DROP_CONSTRAINTS(18);
do
$$
begin
alter table feeding drop constraint if exists fk_feeding_for_animal;
alter table feeding drop constraint if exists fk_food_to_be_fed;
insert into feeding values('1', 'Kapsalon', '11/11/12',-1);
    raise notice 'C18. Test 5 failed';
    exception when others then
    raise notice 'C18. Test 5 passed (%)', SQLERRM;
end;
$$;
rollback;

--6. update
begin transaction;
select USP_DROP_CONSTRAINTS(18);
do
$$
begin
alter table feeding drop constraint if exists fk_feeding_for_animal;
alter table feeding drop constraint if exists fk_food_to_be_fed;
insert into feeding values('1', 'Kapsalon', '11/11/12',1);
update feeding set amount = -1;
    raise notice 'C18. Test 6 failed';
    exception when others then
    raise notice 'C18. Test 6 passed (%)', SQLERRM;
end;
$$;
rollback;

/* ====== CONSTRAINT 19 AnimalVisitsVet ======*/
/* Test should pass upon a visit date after the animal`s birth date*/
--1. insert
begin transaction;
select USP_DROP_CONSTRAINTS(19);
do
$$
begin
alter table animal drop constraint if exists fk_animal_of_species;
alter table animal_visits_vet drop constraint if exists fk_prescription_of_vet_visit;
alter table animal_visits_vet drop constraint if exists fk_vet_visited_animal;
insert into animal values('1', 'male', 'Rico', 'Apeldoorn', '1/1/11', 'Duck');
insert into animal_visits_vet values('1', '12/12/13', 'Regular check', 'Doctor Pol', '12/12/14');
    raise notice 'C19. Test 1 passed';
    exception when others then
    raise notice 'C19. Test 1 failed (%)', SQLERRM;
end;
$$;
rollback;

--2. update
begin transaction;
select USP_DROP_CONSTRAINTS(19);
do
$$
begin
alter table animal drop constraint if exists fk_animal_of_species;
alter table animal_visits_vet drop constraint if exists fk_prescription_of_vet_visit;
alter table animal_visits_vet drop constraint if exists fk_vet_visited_animal;
insert into animal values('1', 'male', 'Rico', 'Apeldoorn', '1/1/11', 'Duck');
insert into animal_visits_vet values('1', '12/12/13', 'Regular check', 'Doctor Pol', '12/12/20');
update animal_visits_vet set visit_date = '1/1/14';
    raise notice 'C19. Test 2 passed';
    exception when others then
    raise notice 'C19. Test 2 failed (%)', SQLERRM;
end;
$$;
rollback;

/* Test should pass upon a visit date on the animal`s birth date*/
--3. insert
begin transaction;
select USP_DROP_CONSTRAINTS(19);
do
$$
begin
alter table animal drop constraint if exists fk_animal_of_species;
alter table animal_visits_vet drop constraint if exists fk_prescription_of_vet_visit;
alter table animal_visits_vet drop constraint if exists fk_vet_visited_animal;
insert into animal values('1', 'male', 'Rico', 'Apeldoorn', '1/1/11', 'Duck');
insert into animal_visits_vet values('1', '1/1/11', 'Regular check', 'Doctor Pol', '12/12/14');
    raise notice 'C19. Test 3 passed';
    exception when others then
    raise notice 'C19. Test 3 failed (%)', SQLERRM;
end;
$$;
rollback;

--4. update
begin transaction;
select USP_DROP_CONSTRAINTS(19);
do
$$
begin
alter table animal drop constraint if exists fk_animal_of_species;
alter table animal_visits_vet drop constraint if exists fk_prescription_of_vet_visit;
alter table animal_visits_vet drop constraint if exists fk_vet_visited_animal;
insert into animal values('1', 'male', 'Rico', 'Apeldoorn', '1/1/11', 'Duck');
insert into animal_visits_vet values('1', '12/12/13', 'Regular check', 'Doctor Pol', '12/12/20');
update animal_visits_vet set visit_date = '1/1/11';
    raise notice 'C19. Test 4 passed';
    exception when others then
    raise notice 'C19. Test 4 failed (%)', SQLERRM;
end;
$$;
rollback;

/* ====== CONSTRAINT 20 MaturityAge ======*/
/* Tests should pass upon inserting or updating a age higher than 0*/
--1. insert
begin transaction;
select USP_DROP_CONSTRAINTS(20);
do
$$
begin
    alter table species_gender drop constraint if exists fk_species_with_gender;
    insert into species_gender values ('aap', '', 5, 5);
    raise notice 'C20. Test 1 passed';
    exception when others then
    raise notice 'C20. Test 1 failed (%)', SQLERRM;
end;
$$;
rollback;

--2. update
begin transaction;
select USP_DROP_CONSTRAINTS(20);
do
$$
begin
    alter table species_gender drop constraint if exists fk_species_with_gender;
    insert into species_gender values ('aap', 'male', 5, 5);
    update species_gender set maturity_age = 6;
    raise notice 'C20. Test 2 passed';
    exception when others then
    raise notice 'C20. Test 2 failed (%)', SQLERRM;
end;
$$;
rollback;

/* Tests should pass upon inserting or updating a age equal to 0*/
--3. insert
begin transaction;
select USP_DROP_CONSTRAINTS(20);
do
$$
begin
    alter table species_gender drop constraint if exists fk_species_with_gender;
    insert into species_gender values ('aap', '', 5, 0);
    raise notice 'C20. Test 3 passed';
    exception when others then
    raise notice 'C20. Test 3 failed (%)', SQLERRM;
end;
$$;
rollback;

--4. update
begin transaction;
select USP_DROP_CONSTRAINTS(20);
do
$$
begin
    alter table species_gender drop constraint if exists fk_species_with_gender;
    insert into species_gender values ('aap', 'male', 5, 5);
    update species_gender set maturity_age = 0;
    raise notice 'C20. Test 4 passed';
    exception when others then
    raise notice 'C20. Test 4 failed (%)', SQLERRM;
end;
$$;
rollback;

/* Tests should fail upon inserting or updating a age lower than 0 */
--5. insert
begin transaction;
select USP_DROP_CONSTRAINTS(20);
do
$$
begin
    alter table species_gender drop constraint if exists fk_species_with_gender;
    insert into species_gender values ('aap', '', 5, -2);
    raise notice 'C20. Test 5 failed';
    exception when others then
    raise notice 'C20. Test 5 passed (%)', SQLERRM;
end;
$$;
rollback;

--6. update
begin transaction;
select USP_DROP_CONSTRAINTS(20);
do
$$
begin
    alter table species_gender drop constraint if exists fk_species_with_gender;
    insert into species_gender values ('aap', 'male', 5, 5);
    update species_gender set maturity_age = -2;
    raise notice 'C20. Test 5 failed';
    exception when others then
    raise notice 'C20. Test 5 passed (%)', SQLERRM;
end;
$$;
rollback;

/* ====== CONSTRAINT 21 SpeciesWeight ======*/
/* Tests should pass upon insert a species gender or updating it */
--1. insert
begin transaction;
select USP_DROP_CONSTRAINTS(21);
do
$$
begin
    insert into species values('Apes', 'Are apes', 'Apes', 'Apes', '');
    insert into species_gender values('Apes', 'male', 9.5, 009.5);
    raise notice 'C21. Test 1 passed';
    exception when others then
    raise notice 'C21. Test 1 failed (%)', SQLERRM;
end;
$$;
rollback;

--2. update
begin transaction;
select USP_DROP_CONSTRAINTS(21);
do
$$
begin
    insert into species values('Apes', 'Are apes', 'Apes', 'Apes', '');
    insert into species_gender values('Apes', 'male', 9.5, 009.5);
    update species_gender set average_weight = 10.1 where english_name = 'Apes';
    raise notice 'C21. Test 2 passed';
    exception when others then
    raise notice 'C21. Test 2 failed (%)', SQLERRM;
end;
$$;
rollback;


/* Tests should raise a check constraint error upon insert a species gender or updating it when the weight is 0 */
--3. insert
begin transaction;
select USP_DROP_CONSTRAINTS(21);
do
$$
begin
    insert into species values('Apes', 'Are apes', 'Apes', 'Apes', '');
    insert into species_gender values('Apes', 'male', 0, 009.5);
    raise notice 'C21. Test 3 failed';
    exception when others then
    raise notice 'C21. Test 3 passed (%)', SQLERRM;
end;
$$;
rollback;

--4. update
begin transaction;
select USP_DROP_CONSTRAINTS(21);
do
$$
begin
    insert into species values('Apes', 'Are apes', 'Apes', 'Apes', '');
    insert into species_gender values('Apes', 'male', 9.5, 009.5);
    update species_gender set average_weight = 0 where english_name = 'Apes';
    raise notice 'C21. Test 4 failed';
    exception when others then
    raise notice 'C21. Test 4 passed (%)', SQLERRM;
end;
$$;
rollback;

/* Tests should raise a check constraint error upon insert a species gender or updating it when the weight is lower then 0 */
--5. insert
begin transaction;
select USP_DROP_CONSTRAINTS(21);
do
$$
begin
    insert into species values('Apes', 'Are apes', 'Apes', 'Apes', '');
    insert into species_gender values('Apes', 'male', -5, 009.5);
    raise notice 'C21. Test 5 failed';
    exception when others then
    raise notice 'C21. Test 5 passed (%)', SQLERRM;
end;
$$;
rollback;

--6. update
begin transaction;
select USP_DROP_CONSTRAINTS(21);
do
$$
begin
    insert into species values('Apes', 'Are apes', 'Apes', 'Apes', '');
    insert into species_gender values('Apes', 'male', 9.5, 009.5);
    update species_gender set average_weight = -5 where english_name = 'Apes';
    raise notice 'C21. Test 6 failed';
    exception when others then
    raise notice 'C21. Test 6 passed (%)', SQLERRM;
end;
$$;
rollback;

/* ====== CONSTRAINT 22 AnimalEnclosureSince ======*/
/* Test should pass because the birth_date is after the since enclosure date */
--1. insert
begin transaction;
select USP_DROP_CONSTRAINTS(22);
do
$$
begin
    alter table animal drop constraint if exists fk_animal_of_species;
    alter table animal_enclosure drop constraint if exists fk_enclosure_has_animal;
    insert into animal values('1', 'male', 'Rico', 'Apeldoorn', '1/1/11', 'Duck');
    insert into animal_enclosure values('1', 'Mensen', '1', '12/12/12');
    raise notice 'C22. Test 1 passed';
    exception when others then
    raise notice 'C22. Test 1 failed (%)', SQLERRM;
end;
$$;
rollback;

--2. update
begin transaction;
select USP_DROP_CONSTRAINTS(22);
do
$$
begin
    alter table animal drop constraint if exists fk_animal_of_species;
    alter table animal_enclosure drop constraint if exists fk_enclosure_has_animal;
    insert into animal values('1', 'male', 'Rico', 'Apeldoorn', '1/1/11', 'Duck');
    insert into animal_enclosure values('1', 'Mensen', '1', '12/12/12');
    raise notice 'C22. Test 2 passed';
    exception when others then
    raise notice 'C22. Test 2 failed (%)', SQLERRM;
end;
$$;
rollback;

--3. update birth_date
begin transaction;
select USP_DROP_CONSTRAINTS(22);
do
$$
begin
    alter table animal drop constraint if exists fk_animal_of_species;
    alter table animal_enclosure drop constraint if exists fk_enclosure_has_animal;
    insert into animal values('1', 'male', 'Rico', 'Apeldoorn', '1/1/11', 'Duck');
    insert into animal_enclosure values('1', 'Mensen', '1', '12/12/12');
    update animal set birth_date = '12/12/10';
    raise notice 'C22. Test 3 passed';
    exception when others then
    raise notice 'C22. Test 3 failed (%)', SQLERRM;
end;
$$;
rollback;

/* Test should pass because the birth_date is on the same date as the since enclosure date */
--4. insert
begin transaction;
select USP_DROP_CONSTRAINTS(22);
do
$$
begin
    alter table animal drop constraint if exists fk_animal_of_species;
    alter table animal_enclosure drop constraint if exists fk_enclosure_has_animal;
    insert into animal values('1', 'male', 'Rico', 'Apeldoorn', '1/1/11', 'Duck');
    raise notice 'C22. Test 4 passed';
    exception when others then
    raise notice 'C22. Test 4 failed (%)', SQLERRM;
end;
$$;
rollback;

--5. update since date
begin transaction;
select USP_DROP_CONSTRAINTS(22);
do
$$
begin
    alter table animal drop constraint if exists fk_animal_of_species;
    alter table animal_enclosure drop constraint if exists fk_enclosure_has_animal;
    insert into animal values('1', 'male', 'Rico', 'Apeldoorn', '1/1/11', 'Duck');
    insert into animal_enclosure values('1', 'Mensen', '1', '12/12/12');
    update animal_enclosure set since = '1/1/11';
    raise notice 'C22. Test 5 passed';
    exception when others then
    raise notice 'C22. Test 5 failed (%)', SQLERRM;
end;
$$;
rollback;

--6. update birth_date
begin transaction;
select USP_DROP_CONSTRAINTS(22);
do
$$
begin
    alter table animal drop constraint if exists fk_animal_of_species;
    alter table animal_enclosure drop constraint if exists fk_enclosure_has_animal;
    insert into animal values('1', 'male', 'Rico', 'Apeldoorn', '1/1/11', 'Duck');
    insert into animal_enclosure values('1', 'Mensen', '1', '12/12/12');
    update animal set birth_date = '12/12/12';
    raise notice 'C22. Test 6 passed';
    exception when others then
    raise notice 'C22. Test 6 failed (%)', SQLERRM;
end;
$$;
rollback;

/* Test should fail because the birth_date is before the since enclosure date */
--7. insert
begin transaction;
select USP_DROP_CONSTRAINTS(22);
do
$$
begin
    alter table animal drop constraint if exists fk_animal_of_species;
    alter table animal_enclosure drop constraint if exists fk_enclosure_has_animal;
    insert into animal values('1', 'male', 'Rico', 'Apeldoorn', '1/1/11', 'Duck');
    insert into animal_enclosure values('1', 'Mensen', '1', '1/1/10');
    raise notice 'C22. Test 7 failed';
    exception when others then
    raise notice 'C22. Test 7 passed (%)', SQLERRM;
end;
$$;
rollback;

--8. update since date
begin transaction;
select USP_DROP_CONSTRAINTS(22);
do
$$
begin
    alter table animal drop constraint if exists fk_animal_of_species;
    alter table animal_enclosure drop constraint if exists fk_enclosure_has_animal;
    insert into animal values('1', 'male', 'Rico', 'Apeldoorn', '1/1/11', 'Duck');
    insert into animal_enclosure values('1', 'Mensen', '1', '12/12/12');
    update animal_enclosure set since = '1/1/10';
    raise notice 'C22. Test 8 failed';
    exception when others then
    raise notice 'C22. Test 8 passed (%)', SQLERRM;
end;
$$;
rollback;

--9. update birth_date
begin transaction;
select USP_DROP_CONSTRAINTS(22);
do
$$
begin
    alter table animal drop constraint if exists fk_animal_of_species;
    alter table animal_enclosure drop constraint if exists fk_enclosure_has_animal;
    insert into animal values('1', 'male', 'Rico', 'Apeldoorn', '1/1/11', 'Duck');
    insert into animal_enclosure values('1', 'Mensen', '1', '12/12/12');
    update animal set birth_date = '1/1/13';
    raise notice 'C22. Test 9 failed';
    exception when others then
    raise notice 'C22. Test 9 passed (%)', SQLERRM;
end;
$$;
rollback;

/*================*/