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

/*===== Constraint 5 AnimalGender =====*/
/* column ANIMAL(Gender)can be male, female or other.*/
alter table animal drop constraint if exists CHK_ANIMAL_GENDER;

alter table animal add constraint CHK_ANIMAL_GENDER
check(gender_s in ('male','female','other'));