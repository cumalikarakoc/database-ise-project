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
CHECK(state = 'paid' OR invoice_id IS NULL);

/*=============*/