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

/* Constraint 1 OrderStates
Column ORDER(State) An order must have one of the following states: Paid, Not complete, Awaiting payment, placed.

=========================================
= State			= Possible?	=
=========================================
= Placed		= Yes		=
= Awaiting payment 	= Yes		=
= Delivered		= No		=
= Not paid		= No		=
=========================================

To apply this constraint, a check constraint needs to be created. 
The constraint checks if an order has one of the four states mentioned before.
*/

alter table "ORDER"
add constraint CHK_ORDER_STATE 
check (State in('Order completed', 'Paid', 'Awaiting payment', 'Not complete'));