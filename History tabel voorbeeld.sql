create role test 

create table HistoryTest (
 Id serial,
 Tstamp timestamp default now(),
 TableName text,
 Operation text,
 Who text,
 New_val json,
 Old_val json
);

create table testPerson (
 id int not null,
 name varchar(20) not null
)

CREATE FUNCTION change_trigger() RETURNS trigger AS $$
	DECLARE
		CurrentUser text = (select current_user);
        BEGIN
		
                IF      TG_OP = 'INSERT'

                THEN

                        INSERT INTO HistoryTest (TableName, operation, Who, new_val)

                                VALUES (TG_RELNAME, TG_OP, CurrentUser, row_to_json(NEW));

                        RETURN NEW;

                ELSIF   TG_OP = 'UPDATE'

                THEN

                        INSERT INTO HistoryTest (TableName, operation, Who, new_val, old_val)

                                VALUES (TG_RELNAME, TG_OP, CurrentUser, row_to_json(NEW), row_to_json(OLD));

                        RETURN NEW;

                ELSIF   TG_OP = 'DELETE'

                THEN

                        INSERT INTO HistoryTest (TableName, operation, Who, old_val)

                                VALUES (TG_RELNAME, TG_OP, CurrentUser, row_to_json(OLD));

                        RETURN OLD;

                END IF;

        END;

$$ LANGUAGE 'plpgsql';

CREATE TRIGGER t BEFORE INSERT OR UPDATE OR DELETE ON testPerson

        FOR EACH ROW EXECUTE PROCEDURE change_trigger();

select * from HistoryTest

set role test

set role postgres

grant select on HistoryTest to test;
grant insert, update, delete on testPerson to test;
grant usage, select on sequence HistoryTest_id_seq to test;

revoke all on testPerson from public
revoke all on HistoryTest from public

insert into testPerson values (1, 'Henk')
insert into testPerson values(2, 'Siem')
insert into testPerson values(3, 'Cumali')
insert into testPerson values(4, 'Jeroen')

update testPerson
set name = 'Rico'
where id = 1

delete from testPerson
where id = 1

delete from testPerson