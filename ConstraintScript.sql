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

/* Constraint 4 NotCompleteHasDiscrepancy
Column ORDER(State) An order with the state not complete has a discrepancy note.

=========================================================
= State			= Action		Allowed	=
=========================================================
= Not Complete		= delete discrepancy	no	=
= Paid			= delete discerepancy	yes	=
=========================================================

To apply this constraint, a triggger is created on table order. It will check the state after every update or insert.
There is another trigger created on discrepany in case when a discrepancy gets deleted or a note is assigned to another order
that hasnt the state not complete.
*/

--Order trigger
create or replace function TRP_NOT_COMPLETE_HAS_DISCREPANCY() returns trigger as $$

begin
 if new.state = 'Not complete' then
  if old.order_id not in (select order_id from DISCREPANCY where order_id = old.order_id) then
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