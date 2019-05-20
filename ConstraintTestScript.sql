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
/*===== CONSTRAINT 10 ===== */
/*Test should raise an error if spot_date is before the date when the animal is reintroduced in wild.*/
BEGIN TRANSACTION;
-- drop fk constraints
ALTER TABLE reintroduction DROP CONSTRAINT fk_animal_reintroduction;
ALTER TABLE spotted DROP CONSTRAINT fk_animal_spotted;

INSERT INTO reintroduction VALUES('an-1', '2018-12-12', 'location', null);
INSERT INTO spotted VALUES('an-1', '2018-10-11');
ROLLBACK;
/*=============*/