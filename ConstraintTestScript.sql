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
drop constraint fk_enclosure_has_animal;

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
drop constraint fk_enclosure_has_animal;

insert into ANIMAL_ENCLOSURE values
('1', '2019-05-23', 'test', 1, null);

update ANIMAL_ENCLOSURE
set End_date = '2019-05-24'
where Animal_id = '1';
rollback transaction;

/* The following test will fail because the new since date is in between an older since and end_date.*/
--insert
begin transaction;
alter table ANIMAL_ENCLOSURE
drop constraint fk_animal_in_enclosure;

alter table ANIMAL_ENCLOSURE
drop constraint fk_enclosure_has_animal;

insert into ANIMAL_ENCLOSURE values
('1', '2019-05-23', 'test', 1, '2019-05-25');

insert into ANIMAL_ENCLOSURE values
('1', '2019-05-24', 'test', 2, '2019-05-26');
rollback transaction;

--update
begin transaction;
alter table ANIMAL_ENCLOSURE
drop constraint fk_animal_in_enclosure;

alter table ANIMAL_ENCLOSURE
drop constraint fk_enclosure_has_animal;

insert into ANIMAL_ENCLOSURE values
('1', '2019-05-23', 'test', 1, '2019-05-25'),
('1', '2019-05-25', 'test', 2, '2019-05-31'),
('1', '2019-06-01', 'test', 3, '2019-06-02');

update ANIMAL_ENCLOSURE
set Since = '2019-05-24'
where animal_id = '1' and Since = '2019-05-25';

rollback transaction;

/* The next test will fail because the end_date is in between an older since date and end_date*/
--insert
begin transaction;
alter table ANIMAL_ENCLOSURE
drop constraint fk_animal_in_enclosure;

alter table ANIMAL_ENCLOSURE
drop constraint fk_enclosure_has_animal;

insert into ANIMAL_ENCLOSURE values
('1', '2019-05-23', 'test', 1, '2019-05-25');

insert into ANIMAL_ENCLOSURE values
('1', '2019-05-10', 'test', 2, '2019-05-24');
rollback transaction;

--update
begin transaction;
alter table ANIMAL_ENCLOSURE
drop constraint fk_animal_in_enclosure;

alter table ANIMAL_ENCLOSURE
drop constraint fk_enclosure_has_animal;

insert into ANIMAL_ENCLOSURE values
('1', '2019-05-23', 'test', 1, '2019-05-25'),
('1', '2019-05-25', 'test', 2, '2019-05-31');

update ANIMAL_ENCLOSURE
set since = '2019-05-10',
    End_date = '2019-05-26'
where animal_id = '1' and Since = '2019-05-23';


/* This test will fail because the the new since date and end_date are in between a older since date and end_date. */
--insert
begin transaction;
alter table ANIMAL_ENCLOSURE
drop constraint fk_animal_in_enclosure;

alter table ANIMAL_ENCLOSURE
drop constraint fk_enclosure_has_animal;

insert into ANIMAL_ENCLOSURE values
('1', '2019-05-23', 'test', 1, '2019-05-30');

insert into ANIMAL_ENCLOSURE values
('1', '2019-05-24', 'test', 1, '2019-05-26');

rollback transaction;

--update
begin transaction;
alter table ANIMAL_ENCLOSURE
drop constraint fk_animal_in_enclosure;

alter table ANIMAL_ENCLOSURE
drop constraint fk_enclosure_has_animal;

insert into ANIMAL_ENCLOSURE values
('1', '2019-05-23', 'test', 1, '2019-05-25'),
('1', '2019-05-25', 'test', 2, '2019-05-31');

update ANIMAL_ENCLOSURE
set since = '2019-05-26',
    End_date = '2019-05-29'
where animal_id = '1' and Since = '2019-05-23';
rollback transaction;

/* The following test will fail because the new since date is before the old since date and the new end_date is before the old end_date */
--insert
begin transaction;
alter table ANIMAL_ENCLOSURE
drop constraint fk_animal_in_enclosure;

alter table ANIMAL_ENCLOSURE
drop constraint fk_enclosure_has_animal;

insert into ANIMAL_ENCLOSURE values
('1', '2019-05-23', 'test', 1, '2019-05-25');

insert into ANIMAL_ENCLOSURE values
('1', '2019-05-20', 'test', 1, '2019-05-26');
rollback transaction;

--update
begin transaction;
alter table ANIMAL_ENCLOSURE
drop constraint fk_animal_in_enclosure;

alter table ANIMAL_ENCLOSURE
drop constraint fk_enclosure_has_animal;

insert into ANIMAL_ENCLOSURE values
('1', '2019-05-23', 'test', 1, '2019-05-25'),
('1', '2019-05-25', 'test', 2, '2019-05-31');

update ANIMAL_ENCLOSURE
set since = '2019-05-24',
    End_date = '2019-06-01'
where animal_id = '1' and Since = '2019-05-23';
rollback transaction;