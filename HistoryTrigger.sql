

CREATE FUNCTION tgr_change_history_trigger() RETURNS trigger AS $$
DECLARE
    CurrentUser text = (select current_user);
BEGIN
    IF      TG_OP = 'INSERT'
    THEN
        EXECUTE 'INSERT INTO '|| quote_ident(TG_TABLE_NAME) ||' (operation, Who, new_val)
        VALUES ('|| TG_OP ||', ' || CurrentUser ||', ' || quote_literal(row_to_json(NEW)) ||');';
        RETURN NEW;
    ELSIF   TG_OP = 'UPDATE'
    THEN
        EXECUTE 'INSERT INTO '|| quote_ident(TG_TABLE_NAME) ||' (operation, Who, new_val, old_val)
        VALUES ('|| TG_OP || ', '|| CurrentUser ||', "'|| quote_literal(row_to_json(NEW)) || '", '|| quote_literal(row_to_json(OLD)) ||');';
        RETURN NEW;
    ELSIF   TG_OP = 'DELETE'
    THEN
        EXECUTE 'INSERT INTO '|| quote_ident(TG_TABLE_NAME) ||'(TableName, operation, Who, old_val)
        VALUES ('|| TG_RELNAME ||', '|| TG_OP || ', '|| CurrentUser ||', '|| quote_literal(row_to_json(OLD)) ||');';
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE 'plpgsql';



CREATE OR REPLACE FUNCTION create_history_triggers() RETURNS void as $$
DECLARE
    rec text;
    BEGIN
        FOR rec IN
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema='public' 
            and table_name not like 'hist%'
            LOOP
            EXECUTE 'CREATE TRIGGER History_trigger BEFORE INSERT OR UPDATE OR DELETE ON '|| quote_ident(rec) ||'
                       FOR EACH ROW EXECUTE PROCEDURE tgr_change_history_trigger();' ;
        END LOOP;
    END;
$$ LANGUAGE 'plpgsql';

SELECT create_history_triggers();

begin transaction;
CREATE TRIGGER History_trigger BEFORE INSERT OR UPDATE OR DELETE ON species 
	FOR EACH ROW EXECUTE PROCEDURE tgr_change_history_trigger();

insert into species values ('ape', 'ape', 'ape', 'ape', 'ape');
rollback;