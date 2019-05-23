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

===========================================================================
= Animal_id		= Since		= End_date		= Allowed =
===========================================================================
= 2			= 2019-05-23	= 2019-05-25		= Yes	  =
= 2			= 2019-05-27	= 2019-05-28		= No	  =
= 2			= 2019-05-27	= 2019-05-29		= No	  =
= 2			= 2019-05-29	= null			= Yes	  =
= 2			= 2019-05-30	= null			= No	  =
===========================================================================

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
   where animal_id = new.animal_id and ((new.since > since
   and new.since < end_date)
   or
   (new.end_date > since
   and new.end_date < end_date)
   or
   (new.since < since
    and new.end_date > end_date
   ))) then
   raise exception 'The dates overlap';
  end if;
 return null;
end;
$$ language 'plpgsql';
