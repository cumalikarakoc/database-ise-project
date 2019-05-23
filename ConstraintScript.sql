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

/*===== CONSTRAINT 3 PaidHasInvoice =====*/
ALTER TABLE "ORDER" DROP CONSTRAINT IF EXISTS CHCK_PAID_HAS_INVOICE;

ALTER TABLE "ORDER" ADD CONSTRAINT CHCK_PAID_HAS_INVOICE
CHECK((state = 'paid' AND invoice_id IS NOT NULL) OR (state != 'paid' AND invoice_id IS NULL));

/*===== CONSTRAINT 14 DiscrepancyDate =====*/
/* column DISCREPANCY(Place_date) cannot be before ORDER(Order_date)*/

CREATE OR REPLACE FUNCTION TR_DISCREPANCY_DATE_FUNC()
  RETURNS trigger AS
$$
BEGIN
	
	IF(NEW.place_date < (Select order_date from "ORDER" where order_id = NEW.order_id)) then
		RAISE EXCEPTION 'place date is before orderdate. please adjust the date'; 
	end if;
    RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER TR_DISCREPANCY_DATE 
  AFTER INSERT OR UPDATE
  ON discrepancy
  FOR EACH ROW
  EXECUTE PROCEDURE TR_DISCREPANCY_DATE_FUNC();
/*===== Constraint 17 StockAmount ======*/
ALTER TABLE "stock" DROP CONSTRAINT IF EXISTS CHK_STOCK_AMOUNT;

ALTER TABLE "stock" ADD CONSTRAINT CHK_STOCK_AMOUNT  
CHECK (amount >= 0);


/*===== CONSTRAINT 21 SpeciesWeight =====*/
/* column SPECIES_GENDER(Weight) must be higher than 0 */
ALTER TABLE "species_gender" DROP CONSTRAINT IF EXISTS CHK_AVERAGE_WEIGHT;

ALTER TABLE "species_gender" ADD CONSTRAINT CHK_AVERAGE_WEIGHT 
CHECK (average_weight > 0);
/*================*/