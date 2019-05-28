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
alter table "ORDER" drop constraint if exists CHK_PAID_HAS_INVOICE;

alter table "ORDER" add constraint CHK_PAID_HAS_INVOICE
check((state = 'Paid' and invoice_id is not null) or (state != 'Paid' and invoice_id is null));
                                                      
/* Constraint 4 NotCompleteHasDiscrepancy
Column ORDER(State) An order with the state not complete has a discrepancy note.

=================================================================
= State			= Action		= Allowed	=
=================================================================
= Not Complete		= delete discrepancy	= no		=
= Paid			= delete discrepancy	= yes		=
=================================================================

To apply this constraint, a trigger is created on table order. It will check the state after every update or insert.
There is another trigger created on discrepancy in case when a discrepancy gets deleted or a note is assigned to another order
that does not have the state not complete.
*/

--Order trigger
create or replace function TRP_NOT_COMPLETE_HAS_DISCREPANCY() returns trigger as $$

begin
 if new.state = 'Not complete' then
  if new.order_id not in (select order_id from DISCREPANCY where order_id = new.order_id) then
   raise exception 'Order % requires a discrepancy note.', NEW.order_id;
  end if;
 end if;
 return new;
end;
$$ language 'plpgsql';

create trigger TR_NOT_COMPLETE_HAS_DISCREPANCY after insert or update on "ORDER"
 for each row execute procedure TRP_NOT_COMPLETE_HAS_DISCREPANCY();

--discrepancy trigger
create or replace function TRP_DISCREPANCY_NOTE_HAS_ORDER() returns trigger as $$

begin
 if (TG_OP = 'UPDATE') then
  if (select state from "ORDER" where order_id = new.order_id) <> 'Not complete' then
   raise exception 'Order % doesnt have the state Not complete', new.order_id;
  end if;  
 elsif (TG_OP = 'DELETE') then
  if (select state from "ORDER" where order_id = old.order_id) = 'Not complete' then
   raise exception 'Order % has state Not complete', old.order_id;
  end if;
 end if;
 return old;
end;
$$ language 'plpgsql';

create trigger TR_DISCREPANCY_NOTE_HAS_ORDER after update or delete on DISCREPANCY
 for each row execute procedure TRP_DISCREPANCY_NOTE_HAS_ORDER();

/*===== Constraint 5 AnimalGender =====*/
/* column ANIMAL(Gender)can be male, female or other.*/
alter table animal drop constraint if exists CHK_ANIMAL_GENDER;

alter table animal add constraint CHK_ANIMAL_GENDER
check(gender_s in ('male','female','other'));
                   
/*===== Constraint 6 AnimalHasOneEnclosure =====*/
/* Columns ANIMAL_ENCLOSURE(Animal_id, Since, End_date) an animal cant stay in two enclosures at a time

The table represents inserts. So if the since or end_date overlaps with previous dates it isnt allowed.
===========================================================================
= Animal_id		= Since		= End_date		= Allowed =
===========================================================================
= 2			= 2019-05-23	= 2019-05-25		= Yes	  =
= 2			= 2019-05-27	= 2019-05-28		= Yes	  = 
= 2			= 2019-05-27	= 2019-05-29		= No	  = This inst allowed because the since date is before the previous end date
= 2			= 2019-05-29	= null			= Yes	  = 
= 2			= 2019-05-30	= null			= No	  = This isnt allowed because the previous end date is null. That means the animal is
=========================================================================== still assigend to a enclosure

A trigger will be created wich checks if dates don't overlap
*/

create or replace function TRP_ANIMAL_HAS_ONE_ENCLOSURE() returns trigger as $$

begin
  if exists (select End_date from animal_enclosure where animal_id = new.animal_id and End_date is null and not (animal_id = new.animal_id and since = new.since)) then
   raise exception 'An animal % can stay at one enclosure at a time', new.animal_id;
  end if;
   if exists
   (select since, end_date 
   from animal_enclosure
   where animal_id = new.animal_id and ((new.since >= since
   and new.since < end_date)
   or
   (new.end_date > since
   and new.end_date =< end_date)
   or
   (new.since =< since
    and new.end_date >= end_date
   ))) then
   raise exception 'The enclosure dates for animal % overlap', new.animal_id;
  end if;
 return null;
end;
$$ language 'plpgsql';

create trigger TR_ANIMAL_HAS_ONE_ENCLOSURE after insert or update on animal_enclosure
 for each row execute procedure TRP_ANIMAL_HAS_ONE_ENCLOSURE();

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
alter table animal_enclosure drop constraint if exists CHK_ENCLOSURE_DATE;

alter table animal_enclosure add constraint CHK_ENCLOSURE_DATE
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
alter table exchange drop constraint if exists CHK_ANIMAL_RETURNED ;

alter table exchange add constraint CHK_ANIMAL_RETURNED
check(return_date >= exchange_date);

/*===== Constraint 12 OffspringId =====*/
/* Columns OFFSRPING(Offspring_id, Animal_id, Mate_id) An animal may not be its own parent or child.*/
-- MATING
create or replace function TRP_OFFSPRING_PARENTS() returns trigger as $$
   begin
   if(new.mate_id in (select offspring_id from OFFSPRING where animal_id = new.animal_id and mating_date = new.mating_date)) then
      raise exception 'An animal may not be its own parent.';
	  end if;
      return new;
   end;
$$ language plpgsql;

create trigger TR_OFFSPRING_PARENTS after update on MATING
for each row 
execute procedure TRP_OFFSPRING_PARENTS();

-- OFFSPRING
create or replace function TRP_OFFSPRING_ID() returns trigger as $$
   begin
   if(new.offspring_id = new.animal_id or new.offspring_id = (select mate_id from mating where animal_id = new.animal_id and mating_date = new.mating_date)) then
      raise exception 'An animal may not be its own child.';
	  end if;
      return new;
   end;
$$ language plpgsql;

create trigger TR_OFFSPRING_ID after insert or update on offspring
for each row 
execute procedure TRP_OFFSPRING_ID();

/*===== Constraint 13 MateAndAnimalId =====*/
/* Columns MATING(Animal_id, Mate_id) Animal_id and mate_id cannot be the same.*/
alter table mating drop constraint if exists CHK_MATE_AND_ANIMAL_ID;

alter table mating add constraint CHK_MATE_AND_ANIMAL_ID
check(animal_id <> mate_id);

/*===== CONSTRAINT 14 DiscrepancyDate =====*/
/* column DISCREPANCY(Place_date) cannot be before ORDER(Order_date)*/

create or replace function TRP_DISCREPANCY_DATE_FUNC()
  returns trigger AS
$$
begin
	
	if(new.place_date < (select order_date from "ORDER" where order_id = new.order_id)) then
		raise exception 'place date is before orderdate. please adjust the date'; 
	end if;
    return new;
end;
$$
language 'plpgsql';

create trigger TR_DISCREPANCY_DATE 
  after insert or update
  on discrepancy
  for each row
  execute procedure TRP_DISCREPANCY_DATE_FUNC();

/*===== CONSTRAINT 15 LineItemWeight =====*/
/* column LINE_ITEM(price) must be higher than 0*/
alter table line_item drop constraint if exists CHK_LINE_ITEM_WEIGHT;
alter table line_item add constraint CHK_LINE_ITEM_WEIGHT
check(weight > 0);

/*===== CONSTRAINT 16 LineItemPrice =====*/
/* column LINE_ITEM(price) must be equal to 0 or higher*/
alter table line_item drop constraint if exists CHK_LINE_ITEM_PRICE;
alter table line_item add constraint CHK_LINE_ITEM_PRICE
check(price >= '0.00');


/*====== CONSTRAINT 17 ======*/
/* column STOCK(Amount) must be higher than or equal to 0. */
alter table "stock" drop constraint if exists CHK_STOCK_AMOUNT;

alter table "stock" add constraint CHK_STOCK_AMOUNT  
check (amount >= 0);

/*===== CONSTRAINT 18 FeedingAmount =====*/
/* The weight of the food fed to an animal has to be 0 or higher*/
alter table feeding drop constraint if exists CHK_FEEDING_AMOUNT;
alter table feeding add constraint CHK_FEEDING_AMOUNT
check(amount > 0);

/*===== CONSTRAINT 19 AnimalVisitsVet =====*/
/* An animal cannot visit a vet before his birth date*/
create or replace function TRP_ANIMAL_VISITS_VET()
	returns trigger as
  $$
	begin
		if (new.visit_date < (select birth_date from animal where animal_id = new.animal_id ))
		then raise exception 'An animal cannot visit a vet before his birth date';
		end if;
	return new;
		end;
  $$
  language 'plpgsql';

create trigger TR_ANIMAL_VISITS_VET before insert or update
  on animal_visits_vet for each row execute procedure TRP_ANIMAL_VISITS_VET();

/*===== Constraint 20 MaturityAge ======*/
/* column SPECIES_GENDER(Maturity_age) Age must be higher or equal to 0. */
alter table "species_gender" drop constraint if exists CHK_MATURITY_AGE ;

alter table "species_gender" add constraint CHK_MATURITY_AGE   
check (maturity_age >= 0);

/*===== CONSTRAINT 21 SpeciesWeight =====*/
/* column SPECIES_GENDER(Weight) must be higher than 0 */
alter table "species_gender" drop constraint if exists CHK_AVERAGE_WEIGHT;

alter table "species_gender" add constraint CHK_AVERAGE_WEIGHT
check (average_weight > 0);

/*===== CONSTRAINT 22 AnimalEnclosureSince =====*/
/* An animal cannot be in an enclosure before his birth_date*/
create or replace function TRP_ENCLOSURE_SINCE_AFTER_BIRTH_DATE()
  returns trigger as
$$
begin
  if (new.since < (select birth_date from animal where animal_id = new.animal_id ))
  then raise exception 'An animal cannot be in an enclosure before its birth_date';
  end if;
  return new;
end;
$$
language 'plpgsql';

create or replace function TRP_ANIMAL_BIRTH_DATE_BEFORE_ENCLOSURE_SINCE()
  returns trigger as
$$
begin
  if (new.birth_date > (select since from animal_enclosure where animal_id = new.animal_id ))
  then raise exception 'An animal cannot be in an enclosure before its birth_date';
  end if;
  return new;
end;
$$
language 'plpgsql';

drop trigger if exists TR_ENCLOSURE_SINCE_AFTER_BIRTH_DATE on animal_enclosure;
create trigger TR_ENCLOSURE_SINCE_AFTER_BIRTH_DATE before insert or update
  on animal_enclosure for each row execute procedure TRP_ENCLOSURE_SINCE_AFTER_BIRTH_DATE();

drop trigger if exists TR_ANIMAL_BIRTH_DATE_BEFORE_ENCLOSURE_SINCE on animal;
create trigger TR_ANIMAL_BIRTH_DATE_BEFORE_ENCLOSURE_SINCE before update
  on animal for each row execute procedure TRP_ANIMAL_BIRTH_DATE_BEFORE_ENCLOSURE_SINCE();
/*=============*/

