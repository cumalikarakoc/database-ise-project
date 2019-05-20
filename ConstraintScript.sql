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

/*===== Constraint 3 PaidHasInvoice =====*/
ALTER TABLE "ORDER" DROP CONSTRAINT IF EXISTS CHK_PAID_HAS_INVOICE;

ALTER TABLE "ORDER" ADD CONSTRAINT CHK_PAID_HAS_INVOICE
CHECK((state = 'paid' AND invoice_id IS NOT NULL) OR (state != 'paid' AND invoice_id IS NULL));

/*===== Constraint 7 LoanType =====*/
/* Column EXCHANGE(Loan_type) loan type can only be ‘to’ or ‘from’.*/
Alter table exchange drop constraint if exists CHK_LOAN_TYPE;

alter table exchange add constraint CHK_LOAN_TYPE
CHECK(loan_type in ('to','from'));
/*=============*/