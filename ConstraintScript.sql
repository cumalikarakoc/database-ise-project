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
/* Constraint 1 OrderStates
Column ORDER(State) An order must have one of the following states: Paid, Not complete, Awaiting payment, placed.

To apply this constraint, a check constraint needs to be created. 
The constraint checks if an order has one of the four states mentioned before.
*/

alter table "ORDER"
add constraint CHK_ORDER_STATE 
check (State in('Placed', 'Paid', 'Awaiting payment', 'Not complete'));


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

/*===== Constraint 3 PaidHasInvoice =====*/
/*A paid order should have an invoice otherwise not.*/
ALTER TABLE "ORDER" DROP CONSTRAINT IF EXISTS CHK_PAID_HAS_INVOICE;

ALTER TABLE "ORDER" ADD CONSTRAINT CHCK_PAID_HAS_INVOICE
CHECK((state = 'Paid' AND invoice_id IS NOT NULL) OR (state != 'Paid' AND invoice_id IS NULL));

/*===== Constraint 5 AnimalGender =====*/
/* column ANIMAL(Gender)can be male, female or other.*/
alter table animal drop constraint if exists CHK_ANIMAL_GENDER;

alter table animal add constraint CHK_ANIMAL_GENDER
check(gender_s in ('male','female','other'));

/*===== Constraint 7 LoanType =====*/
/* Column EXCHANGE(Loan_type) loan type can only be ‘to’ or ‘from’.*/
Alter table exchange drop constraint if exists CHK_LOAN_TYPE;

alter table exchange add constraint CHK_LOAN_TYPE
CHECK(loan_type in ('to','from'));

/*===== Constraint 8 NextVisitVet =====*/
/* Columns ANIMAL_VISITS_VET(Next_visit, Visit_date) The next visit date cant be before the visit date. */
alter table animal_visits_vet drop constraint if exists CHK_NEXT_VISIT_VET;

alter table animal_visits_vet add constraint CHK_NEXT_VISIT_VET
check(next_visit > visit_date);

/*===== Constraint 9 EnclosureEndDate =====*/
/* Columns ANIMAL_ENCLOSURE(Since, End_date)  The end date may not be before the date when the animal is moved to the enclosure.*/
alter table ANIMAL_ENCLOSURE drop constraint if exists CHK_ENCLOSURE_DATE;

alter table ANIMAL_ENCLOSURE add constraint CHK_ENCLOSURE_DATE
check(end_date >= since);

/*===== Constraint 10 SpottedAfterRelease ===== */
/* An animal cannot have been seen in the wild before its first release. */
-- SPOTTED
create or replace function TRP_SPOTTED_AFTER_RELEASE() returns trigger as $$
   begin
   if(new.spot_date < (select reintroduction_date from reintroduction where animal_id = new.animal_id order by reintroduction_date asc limit 1)) then
      raise exception 'Spot_date must be after the date when the animal is reintroduced to wild.';
	  end if;
      return new;
   end;
$$ language plpgsql;

create trigger TR_SPOTTED_AFTER_RELEASE after insert or update on spotted
for each row 
execute procedure TRP_SPOTTED_AFTER_RELEASE();

-- REINTRODUCTION
create or replace function TRP_REINTRODUCTION_BEFORE_SPOTTED() returns trigger as $$
   begin
   if((tg_op = 'UPDATE' or tg_op= 'DELETE') and
	  coalesce((select min(spot_date) from spotted where animal_id = old.animal_id), current_date) < 
		  	   coalesce((select min(reintroduction_date) from reintroduction where animal_id = old.animal_id), current_date)) then
   if(tg_op = 'UPDATE') then
      raise exception 'Reintroduction date must be before the date when the animal is spotted.';
	elsif(tg_op = 'DELETE') then
		raise exception 'The reintoroduction date % of animal % may not be deleted because this animal is spotted after this reintroduction. Remove the associated spot_date first please.', old.reintroduction_date, old.animal_id;
		end if;
	end if; 
	return old;
   end;
$$ language plpgsql;

create trigger TR_REINTRODUCTION_BEFORE_SPOTTED after update or delete on reintroduction
for each row 
execute procedure TRP_REINTRODUCTION_BEFORE_SPOTTED();

/*===== Constraint 11 AnimalReturned =====*/
/* Column EXCHANGE(Return_date) An animal can only be returned after it has been exchanged.*/
alter table EXCHANGE drop constraint if exists CHK_ANIMAL_RETURNED ;

alter table EXCHANGE add constraint CHK_ANIMAL_RETURNED
check(return_date >= exchange_date);

/*===== CONSTRAINT 15 LineItemWeight =====*/
/* column LINE_ITEM(price) must be higher than 0*/
ALTER TABLE line_item DROP CONSTRAINT IF EXISTS CHK_LINE_ITEM_WEIGHT;
ALTER TABLE line_item ADD CONSTRAINT CHK_LINE_ITEM_WEIGHT
CHECK(weight > 0);

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
/*=============*/

