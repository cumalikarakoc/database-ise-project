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
rollback transaction

--update
begin transaction;
alter table "ORDER"
drop constraint fk_order_supplier;

insert into "ORDER" values ('Order1', 'supplier', 'Awaiting payment', current_date, null);

update "ORDER"
set state = 'Paid'
rollback transaction


/*The following inserts and updates will fail because the state is not allowed*/
--insert
begin transaction;
alter table "ORDER"
drop constraint fk_order_supplier;

insert into "ORDER" values ('Order1', 'Supplier', 'Placed', current_date, null),
('Order2', 'Supplier2', 'Canceled', current_date, null);

rollback transaction

--update
begin transaction;
alter table "ORDER"
drop constraint fk_order_supplier;

insert into "ORDER" values ('Order1', 'Supplier', 'Placed', current_date, null);

update "ORDER"
set State = 'Removed'
where Order_id = 'Order1';
rollback transaction