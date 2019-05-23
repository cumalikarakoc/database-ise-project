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

/*Constraint 6 
Columns ANIMAL_ENCLOSURE(Animal_id, Since, End_date) an animal cant stay in two enclosures at a time

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
  if exists (select End_date from ANIMAL_ENCLOSURE where animal_id = new.animal_id and End_date is null and not (animal_id = new.animal_id and since = new.since)) then
   raise exception 'An animal % can stay at one enclosure at a time', new.animal_id;
  end if;
   if exists
   (select since, end_date 
   from ANIMAL_ENCLOSURE
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

create trigger TR_ANIMAL_HAS_ONE_ENCLOSURE after insert or update on ANIMAL_ENCLOSURE
 for each row execute procedure TRP_ANIMAL_HAS_ONE_ENCLOSURE();
