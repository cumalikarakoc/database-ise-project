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

=================================================
= State			= has discrepancy	=
=================================================
= Placed		= no			=
= Awaiting payment 	= no			=
= Not Complete		= yes			=
= Not paid		= no			=
=================================================

To apply this constraint, a triggger is created on table order. It will check the state after every update or insert.
*/

create or replace function TRP_NOT__COMPLETE_HAS_DISCREPANCY() returns trigger as $$

begin
 if NEW.state = ('Not complete') then
  insert into DISCREPANCY (order_id, message, place_date) values (NEW.order_id, 'Order is not complete', current_date);
  raise notice 'A discrepancy note has been added to order %', NEW.order_id;
 end if;
 return null;
end;
$$ language 'plpgsql';

create trigger TR_NOT__COMPLETE_HAS_DISCREPANCY after insert or update on "ORDER"
 for each row execute procedure TRP_NOT__COMPLETE_HAS_DISCREPANCY();