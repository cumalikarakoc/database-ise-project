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

/* Constraint 4 NotCompleteHasDiscrepancy */
/* The trigger on ORDER will be tested first. The next insert and update will fail
 because there isn't a discrepancy note */
--insert
begin transaction;
insert into "ORDER" values ('Order3', 'Supplier2', 'Not complete', current_date, null);
rollback transaction

--update
begin transaction;
insert into "ORDER" values ('Order2', 'Supplier2', 'Awaiting payment', current_date, null);

update "ORDER"
set state = 'Not complete'
where order_id = 'Order2';
rollback transaction

/* The following test will succeed because a discrepancy note exists. For a discrepancy note to be created,
there has to be an order. Thats why an order is created first.*/
--insert
begin transaction;
insert into "ORDER" values ('1', 'test', 'Placed', current_date, null);

insert into DISCREPANCY (order_id, message, place_date) values ('1', 'test', current_date);

update "ORDER"
set state = 'Not complete'
where order_id = '1';
rollback transaction

/* Now the trigger on DISCREPANCY will be tested. This wil fail because the order it gets assigend to hasnt the state Not complete.
When deleted it will also fail because the order is still not completed.*/
--update
begin transaction;
 insert into "ORDER" values ('1', 'test', 'Placed', current_date, null);
 insert into "ORDER" values ('2', 'test', 'Paid', current_date, null);

 insert into DISCREPANCY (order_id, message, place_date) values ('1', 'test', current_date);

 update "ORDER"
 set state = 'Not complete'
 where order_id = '1';

 update DISCREPANCY
 set order_id = '2';
rollback transaction

--delete
begin transaction;
 insert into "ORDER" values ('1', 'test', 'Placed', current_date, null);
 insert into DISCREPANCY (order_id, message, place_date) values ('1', 'test', current_date);

 update "ORDER"
 set state = 'Not complete'
 where order_id = '1';

 delete from DISCREPANCY
 where order_id = '1';
rollback transaction

/* The following tests will succeed. Because the order has been completed, so its state changes. */

--update
begin transaction;
 insert into "ORDER" values ('1', 'test', 'Placed', current_date, null);
 insert into "ORDER" values ('2', 'test', 'Paid', current_date, null);

 insert into DISCREPANCY (order_id, message, place_date) values ('1', 'test', current_date);
 insert into DISCREPANCY (order_id, message, place_date) values ('2', 'test', current_date);

 update "ORDER"
 set state = 'Not complete'
 where order_id = '1';

 update "ORDER"
 set state = 'Not complete'
 where order_id = '2';

 update DISCREPANCY
 set order_id = '2';
rollback transaction 

--delete
begin transaction;
 insert into "ORDER" values ('1', 'test', 'Placed', current_date, null);
 insert into DISCREPANCY (order_id, message, place_date) values ('1', 'test', current_date);

 delete from DISCREPANCY
 where order_id = '1';
rollback transaction 