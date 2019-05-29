/*-------------------------------------------------------------*\
|			Index scripts   			|
|---------------------------------------------------------------|
|	Gemaakt door: 	Cumali karakoç,				|
|			Simon van Noppen,			|
|			Henkie van den Oord,			|
|			Jeroen Rikken,				|
|			Rico Salemon				|
|	Versie:		1.0					|
|	Gemaakt op:	5/7/2019 13:42				|
\*-------------------------------------------------------------*/

/*===== Constraint 2 OtherThanPlacedHasDelivery =====*/
/* This index is created to make the trigger on the tabel order execute faster.*/
begin transaction;
alter table "ORDER" drop constraint if exists fk_order_supplier;
insert into "ORDER" values(1,'Jumbo', 'Placed','10-10-2018',null);
insert into delivery values(1,1,'150kg','100kg');
-- create index IDX_OTHER_THAN_PLACED_ORDER on delivery(order_id);
explain select 1 from delivery where Order_id = '1';

rollback;