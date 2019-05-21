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

/* Constraint 2 OtherThanPlacedHasDelivery
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
create or replace function TRP_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER()
returns trigger as
$$
begin
	if not exists (select 1 from delivery where Order_id = new.Order_id) then
	raise exception 'There is no delivery note for order % while it is %.', new.Order_id, new.State;
	end if;
	return new;
end;
$$
language 'plpgsql';

create trigger TR_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER
after insert or update
on "ORDER"
for each row
when (new.state <> 'Placed')
execute procedure TRP_OTHER_THAN_PLACED_HAS_DELIVERY_ORDER();

-- Trigger function for trigger on table delivery.
create or replace function TRP_OTHER_THAN_PLACED_HAS_DELIVERY_DELIVERY()
returns trigger as
$$
begin
	if exists (select 1 from "ORDER" where state <> 'Placed' and Order_id = old.Order_id) then
	raise exception 'There is no delivery note for order % while it is %.', old.Order_id, (select state from "ORDER" where Order_id = old.Order_id);
	end if;
	return old;
end;
$$
language 'plpgsql';

create trigger TR_OTHER_THAN_PLACED_HAS_DELIVERY_DELIVERY
after update or delete
on delivery
for each row
execute procedure TRP_OTHER_THAN_PLACED_HAS_DELIVERY_DELIVERY();

/*===== CONSTRAINT 3 PaidHasInvoice =====*/
ALTER TABLE "ORDER" DROP CONSTRAINT IF EXISTS CHCK_PAID_HAS_INVOICE;

ALTER TABLE "ORDER" ADD CONSTRAINT CHCK_PAID_HAS_INVOICE
CHECK((state = 'Paid' AND invoice_id IS NOT NULL) OR (state != 'Paid' AND invoice_id IS NULL));

/*===== CONSTRAINT 16 LineItemPrice =====*/
/* column LINE_ITEM(price) must be equal to 0 or higher*/
ALTER TABLE line_item DROP CONSTRAINT IF EXISTS CHK_LINE_ITEM_PRICE;
ALTER TABLE line_item ADD CONSTRAINT CHK_LINE_ITEM_PRICE
CHECK(price >= '0.00');

/*===== CONSTRAINT 21 SpeciesWeight =====*/
/* column SPECIES_GENDER(Weight) must be higher than 0 */
ALTER TABLE "species_gender" DROP CONSTRAINT IF EXISTS CHK_AVERAGE_WEIGHT;

ALTER TABLE "species_gender" ADD CONSTRAINT CHK_AVERAGE_WEIGHT
CHECK (average_weight > 0);
/*================*/
