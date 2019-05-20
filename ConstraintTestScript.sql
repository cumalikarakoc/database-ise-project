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

/*===== Constraint 5 AnimalGender =====*/

/* Test should pass when inserting or updating animal gender to 'male' */
-- insert
begin transaction;
insert into species values
('Monkey','Things with long arms',null,null,null);
insert into animal values
(1,'male','Abu' ,'Engeland', '12-12-18', 'Monkey'),
(2,'male','Koko','Engeland', '10-10-18', 'Monkey');
rollback;

-- update
begin transaction;
insert into species values
('Monkey','Things with long arms',null,null,null);
insert into animal values
(1,'female','Abu' ,'Engeland', '12-12-18', 'Monkey'),
(2,'female','Koko','Engeland', '10-10-18', 'Monkey');
update animal
set gender_s = 'male';
rollback;

/* Test should pass when inserting or updating animal gender to 'female' */
-- insert
-- insert
begin transaction;
insert into species values
('Monkey','Things with long arms',null,null,null);
insert into animal values
(1,'female','Abu' ,'Engeland', '12-12-18', 'Monkey'),
(2,'female','Koko','Engeland', '10-10-18', 'Monkey');
rollback;

-- update
begin transaction;
insert into species values
('Monkey','Things with long arms',null,null,null);
insert into animal values
(1,'male','Abu' ,'Engeland', '12-12-18', 'Monkey'),
(2,'male','Koko','Engeland', '10-10-18', 'Monkey');
update animal
set gender_s = 'female';
rollback;

/* Test should pass when inserting or updating animal gender to 'other' */
-- insert
begin transaction;
insert into species values
('Monkey','Things with long arms',null,null,null);
insert into animal values
(1,'other','Abu' ,'Engeland', '12-12-18', 'Monkey'),
(2,'other','Koko','Engeland', '10-10-18', 'Monkey');
rollback;

-- update
begin transaction;
insert into species values
('Monkey','Things with long arms',null,null,null);
insert into animal values
(1,'male','Abu' ,'Engeland', '12-12-18', 'Monkey'),
(2,'male','Koko','Engeland', '10-10-18', 'Monkey');
update animal
set gender_s = 'other';
rollback;

/* Test should fail when inserting or updating animal gender to something other than 'male', 'female', 'other' */
-- insert
begin transaction;
insert into species values
('Monkey','Things with long arms',null,null,null);
insert into animal values
(1,'male','Abu' ,'Engeland', '12-12-18', 'Monkey'),
(2,'something','Koko','Engeland', '10-10-18', 'Monkey');
rollback;

-- update
begin transaction;
insert into species values
('Monkey','Things with long arms',null,null,null);
insert into animal values
(1,'male','Abu' ,'Engeland', '12-12-18', 'Monkey'),
(2,'male','Koko','Engeland', '10-10-18', 'Monkey');
update animal
set gender_s = 'something';
rollback;

/*============*/