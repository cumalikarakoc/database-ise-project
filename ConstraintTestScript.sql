/*-------------------------------------------------------------*\
|			Constraint Test Script			|
|---------------------------------------------------------------|
|	Gemaakt door: 	Cumali karakoç,				|
|			Simon van Noppen,			|
|			Henkie van den Oord,			|
|			Jeroen Rikken,				|
|			Rico Salemon				|
|	Versie:		1.0					|
|	Gemaakt op:	5/7/2019 13:42				|
\*-------------------------------------------------------------*/

--Constraint 6 AnimalHasOneEnclosure
/* The following tests will succeed because none of the the date will overlap */

--insert
begin transaction;
alter table ANIMAL_ENCLOSURE
drop constraint fk_animal_in_enclosure;

alter table ANIMAL_ENCLOSURE
drop constraintfk_enclosure_has_animal;

insert into ANIMAL_ENCLOSURE values
('1', '2019-05-23', 'test', 1, '2019-05-24');

insert into ANIMAL_ENCLOSURE values
('1', '2019-05-25', 'test', 2, '2019-05-26');
rollback transaction;

--update
begin transaction;
alter table ANIMAL_ENCLOSURE
drop constraint fk_animal_in_enclosure;

alter table ANIMAL_ENCLOSURE
drop constraintfk_enclosure_has_animal;

insert into ANIMAL_ENCLOSURE values
('1', '2019-05-23', 'test', 1, null);

update ANIMAL_ENCLOSURE
set End_date = '2019-05-24'
where Animal_id = '1';
rollback transaction;

/* The following test will fail because the dates overlap */
--insert
begin transaction;
alter table ANIMAL_ENCLOSURE
drop constraint fk_animal_in_enclosure;

alter table ANIMAL_ENCLOSURE
drop constraintfk_enclosure_has_animal;

insert into ANIMAL_ENCLOSURE values
('1', '2019-05-23', 'test', 1, '2019-05-25');

insert into ANIMAL_ENCLOSURE values
('1', '2019-05-24', 'test', 2, '2019-05-26');
rollback transaction;