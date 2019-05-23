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

--Constraint 6
create or replace function TRP_ANIMAL_HAS_ONE_ENCLOSURE() returns trigger as $$

begin

 if (TG_OP = 'UPDATE') then
  if new.End_date < old.Since then
   raise exception 'End date cant be before new date';
   return old;
  end if;
 end if;

 if (TG_OP = 'INSERT') then
  if (select Since from ANIMAL_ENCLOSURE where Animal_id = new.Animal_id order by End_date asc limit 1) is not null then --check if animal lived in an enclosure before.
   if (select End_date from ANIMAL_ENCLOSURE where Animal_id = new.Animal_id order by End_date desc limit 1) is null then
    raise exception 'Animal is still asigned to another enclosure';
   end if;
   if new.Since < (select End_date from ANIMAL_ENCLOSURE where Animal_id = new.Animal_id order by End_date desc limit 1) then --check if the end date of the previous enclosure an animal stayed in, is before the since date that is inserted.
    raise exception 'The end date of the previous stay has to be before the since date';
   end if;
  else
   raise notice 'Eerste verblijf';
  end if;
  if new.Since > new.End_date then
   raise exception 'The end date has to be after the since date'; 
  end if;
 end if;
 return null;
end;

$$ language 'plpgsql';