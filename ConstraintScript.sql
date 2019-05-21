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
/*===== CONSTRAINT 10 ===== */
--Een dier kan niet gezien zijn in het wild voor zijn eerste vrijlating.
-- table SPOTTED
CREATE OR REPLACE FUNCTION TRP_SPOTTED_AFTER_RELEASE() RETURNS TRIGGER AS $$
   BEGIN
   IF(NEW.spot_date < (SELECT reintroduction_date FROM REINTRODUCTION WHERE animal_id = NEW.animal_id ORDER BY reintroduction_date ASC LIMIT 1)) THEN
      RAISE EXCEPTION 'Spot_date must be after the date when the animal is reintroduced to wild.';
	  END IF;
      RETURN NEW;
   END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TR_SPOTTED_AFTER_RELEASE AFTER INSERT OR UPDATE ON SPOTTED
FOR EACH ROW 
EXECUTE PROCEDURE TRP_SPOTTED_AFTER_RELEASE();

--table REINTRODUCTION
CREATE OR REPLACE FUNCTION TRP_REINTRODUCTION_BEFORE_SPOTTED() RETURNS TRIGGER AS $$
   BEGIN
   IF((TG_OP = 'INSERT' OR TG_OP = 'UPDATE') 
	  AND NEW.reintroduction_date > (SELECT MAX(spot_date) FROM SPOTTED WHERE animal_id = NEW.animal_id)) THEN
      RAISE EXCEPTION 'Reintroduction date must be before the date when the animal is spotted.';
	  RETURN NEW;
	ELSIF(TG_OP = 'DELETE' AND COALESCE((SELECT MIN(spot_date) FROM SPOTTED WHERE animal_id = OLD.animal_id), CURRENT_DATE) < 
		  						COALESCE((SELECT MIN(reintroduction_date) FROM REINTRODUCTION WHERE animal_id = OLD.animal_id), CURRENT_DATE)) THEN
		RAISE EXCEPTION 'The reintoroduction date % of animal % may not be deleted because this animal is spotted after the reintroduction. Remove the associated spot_date first please.', OLD.reintroduction_date, OLD.animal_id;
		END IF;
      RETURN OLD;
   END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TR_REINTRODUCTION_BEFORE_SPOTTED AFTER INSERT OR UPDATE OR DELETE ON REINTRODUCTION
FOR EACH ROW 
EXECUTE PROCEDURE TRP_REINTRODUCTION_BEFORE_SPOTTED();
/*==============*/