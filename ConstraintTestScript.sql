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

/*Test should raise an error if there is no reintroduction_date before the spot_date*/
BEGIN TRANSACTION;
-- drop fk constraints
ALTER TABLE reintroduction DROP CONSTRAINT fk_animal_reintroduction;
ALTER TABLE spotted DROP CONSTRAINT fk_animal_spotted;

INSERT INTO reintroduction VALUES('an-1', '2018-12-12', 'location', null);
INSERT INTO spotted VALUES('an-1', '2019-01-01');

UPDATE reintroduction SET reintroduction_date = '2019-05-05';
ROLLBACK;

--delete
BEGIN TRANSACTION;
-- drop fk constraints
ALTER TABLE reintroduction DROP CONSTRAINT fk_animal_reintroduction;
ALTER TABLE spotted DROP CONSTRAINT fk_animal_spotted;

INSERT INTO reintroduction VALUES('an-1', '2018-12-12', 'location', null);
INSERT INTO spotted VALUES('an-1', '2019-01-01');

DELETE FROM reintroduction WHERE animal_id = 'an-1';
ROLLBACK;
/*=============*/