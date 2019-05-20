/*-------------------------------------------------------------*\
|			Constraints Script			|
|---------------------------------------------------------------|
|	Gemaakt door: 	Cumali karakoç,				|
|			Simon van Noppen,			|
|			Henkie van den Oord,			|
|			Jeroen Rikken,				|
|			Rico Salemon				|
|	Versie:		1.0					|
|	Gemaakt op:	5/7/2019 13:42				|
\*-------------------------------------------------------------*/

/* Constraint 2 VetVisitDate
Colom ORDER(State) An order with state that is not ‘placed’, must have a delivery note.
=================================================
= State		= Delivery note	= Yes/No	=
=================================================
= Other		= Does not exist= No		=
= Placed	= Does not exist= Yes 		=
= Placed	= Exists	= Yes		=
= Other		= Exists	= Yes		=
=================================================
To apply this constraint a trigger needs to be created on table order.
This trigger needs to check if the state is changed to something other than placed if it is then there should be a delivery note for that order.

For this constraint there will also need to be checked if a delivery note is not deleted for a order that is something other than placed.
To do this a trigger wil be created on the delivery table.
*/

-- Trigger function for trigger on table order.
Create or replace function TRP_VET_VISIT_DATE_ORDER()
Returns trigger as
$$
Begin
	If not exists (select 1 from delivery where Order_id = new.Order_id) then
	Raise exception 'There is no delivery note for order % while it is %.', new.Order_id, new.State;
	end if;
	return new;
end;
$$
Language 'plpgsql';

Create trigger TR_VET_VISIT_DATE_ORDER
after insert or update
on "ORDER"
for each row
when (new.state <> 'placed')
execute procedure TRP_VET_VISIT_DATE_ORDER();

-- Trigger function for trigger on table delivery.
Create or replace function TRP_VET_VISIT_DATE_DELIVERY()
Returns trigger as
$$
Begin
	If exists (select 1 from "ORDER" where state <> 'placed' and Order_id = old.Order_id) then
	Raise exception 'There is no delivery note for order % while it is %.', old.Order_id, (select state from "ORDER" where Order_id = old.Order_id);
	end if;
	return new;
end;
$$
Language 'plpgsql';

Create trigger TR_VET_VISIT_DATE_DELIVERY
after update or delete
on delivery
for each row
execute procedure TRP_VET_VISIT_DATE_DELIVERY();
