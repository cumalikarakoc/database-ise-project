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
/*===== CONSTRAINT 10 ===== */
--Een dier kan niet gezien zijn in het wild voor zijn eerste vrijlating.
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
$$ language plpgsql

create trigger TR_REINTRODUCTION_BEFORE_SPOTTED after update or delete on reintroduction
for each row 
execute procedure TRP_REINTRODUCTION_BEFORE_SPOTTED();
/*==============*/
