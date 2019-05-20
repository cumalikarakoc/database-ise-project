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
CREATE OR REPLACE FUNCTION TRP_SPOTTED_AFTER_RELEASE() RETURNS TRIGGER AS $$
   BEGIN
   IF(NEW.spot_date < (SELECT reintroduction_date FROM REINTRODUCTION where animal_id = new.animal_id ORDER BY reintroduction_date ASC LIMIT 1)) THEN
      RAISE EXCEPTION 'Spot_date must be after the date when the animal is reintroduced to wild.';
	  END IF;
      RETURN NEW;
   END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TR_SPOTTED_AFTER_RELEASE AFTER INSERT OR UPDATE ON SPOTTED
FOR EACH ROW 
EXECUTE PROCEDURE TRP_SPOTTED_AFTER_RELEASE();
/*==============*/