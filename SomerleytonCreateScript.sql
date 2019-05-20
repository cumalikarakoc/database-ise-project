/*-------------------------------------------------------------*\
|			Constraints Script			|
|---------------------------------------------------------------|
|	Gemaakt door: 	Cumali karakoç,				|
|			Simon van Noppen,			|
|			Henkie van den Oord,			|
|			Jeroen Rikken,				|
|			Rico Salemon				|
|	Versie:		1.0					|
|	Gemaakt op:	17-5-2019 10:48:23			|
\*-------------------------------------------------------------*/

drop index ANIMAL_OF_SPECIES_FK;

drop index ANIMAL_PK;

drop table ANIMAL;

drop index ENCLOSURE_HAS_ANIMAL_FK;

drop index ANIMAL_IN_ENCLOSURE_FK;

drop index ANIMAL_ENCLOSURE_PK;

drop table ANIMAL_ENCLOSURE;

drop index ANIMAL_IS_DIAGNOSED2_FK;

drop index ANIMAL_IS_DIAGNOSED_FK;

drop index ANIMAL_IS_DIAGNOSED_PK;

drop table ANIMAL_IS_DIAGNOSED;

drop table ANIMAL_PARENT;

drop index PRESCRIPTION_OF_VET_VISIT_FK;

drop index VET_VISITED_ANIMAL_FK;

drop index ANIMAL_CHECK_UP_FK;

drop index ANIMAL_VISITS_VET_PK;

drop table ANIMAL_VISITS_VET;

drop index HEADKEEPER_OF_AREA2_FK;

drop index AREA_PK;

drop table AREA;

drop index AREA_HAS_KEEPER_FK;

drop index KEEPER_IN_AREA_FK;

drop index AREA_KEEPER_PK;

drop table AREA_KEEPER;

drop index DELIVERY_ORDER_FK;

drop index DELIVERY_PK;

drop table DELIVERY;

drop index DIAGNOSIS_PK;

drop table DIAGNOSIS;

drop index ORDER_DISCREPANCY_FK;

drop index DISCREPANCY_PK;

drop table DISCREPANCY;

drop index ENCLOSURE_IN_AREA_FK;

drop index ENCLOSURE_PK;

drop table ENCLOSURE;

drop index ANIMAL_EXCHANGE_FK;

drop index EXCHANGE_PK;

drop table EXCHANGE;

drop index FOOD_TO_BE_FED_FK;

drop index FEEDING_FOR_ANIMAL_FK;

drop index FEEDING_PK;

drop table FEEDING;

drop index FOOD_TYPE_PK;

drop table FOOD_KIND;

drop index INVOICE_PK;

drop table INVOICE;

drop index KEEPER_PK;

drop table KEEPER;

drop index FOOD_IN_LINE_ITEM_FK;

drop index ITEM_IN_ORDER_FK;

drop index LINE_ITEM_PK;

drop table LINE_ITEM;

drop index BREEDING_MATE_FK;

drop index BREEDING_PK;

drop table MATING;

drop index OFFSPRING_PK;

drop table OFFSPRING;

drop index ORDER_SUPPLIER_FK;

drop index ORDER_PK;

drop table "ORDER";

drop index PRESCRIPTION_PK;

drop table PRESCRIPTION;

drop index ANIMAL_REINTRODUCTION_FK;

drop index REINTRODUCTION_PK;

drop table REINTRODUCTION;

drop index SPECIES_PK;

drop table SPECIES;

drop index SPECIES_WITH_GENDER_FK;

drop index SPECIES_GENDER_PK;

drop table SPECIES_GENDER;

drop index ANIMAL_SPOTTED_FK;

drop index SPOTTED_PK;

drop table SPOTTED;

drop index FOOD_IN_STOCK_FK;

drop index ANIMAL_FOODSTOCK_FK;

drop index STOCK_PK;

drop table STOCK;

drop index SUPPLIER_PK;

drop table SUPPLIER;

drop index SUPPLIES_FOOD_TYPE2_FK;

drop index SUPPLIES_FOOD_TYPE_FK;

drop index SUPPLIES_FOOD_TYPE_PK;

drop table SUPPLIES_FOOD_TYPE;

drop index VET_PK;

drop table VET;

drop domain ADDRESS;

drop domain AGE;

drop domain AMOUNT;

drop domain DATE;

drop domain FOOD_TYPE_DOMAIN;

drop domain GENDER;

drop domain ID;

drop domain LOAN_TYPE;

drop domain MONEY;

drop domain NAME;

drop domain PHONE;

drop domain PLACE;

drop domain SEQ_NUM;

drop domain STATE;

drop domain TEXT;

drop domain WEIGHT;

/*==============================================================*/
/* Domain: ADDRESS                                              */
/*==============================================================*/
create domain ADDRESS as VARCHAR(128);

/*==============================================================*/
/* Domain: AGE                                                  */
/*==============================================================*/
create domain AGE as DECIMAL(3,2);

/*==============================================================*/
/* Domain: AMOUNT                                               */
/*==============================================================*/
create domain AMOUNT as INT4;

/*==============================================================*/
/* Domain: DATE                                                 */
/*==============================================================*/
create domain DATE as DATE;

/*==============================================================*/
/* Domain: FOOD_TYPE_DOMAIN                                     */
/*==============================================================*/
create domain FOOD_TYPE_DOMAIN as VARCHAR(100);

/*==============================================================*/
/* Domain: GENDER                                               */
/*==============================================================*/
create domain GENDER as VARCHAR(15);

/*==============================================================*/
/* Domain: ID                                                   */
/*==============================================================*/
create domain ID as VARCHAR(10);

/*==============================================================*/
/* Domain: LOAN_TYPE                                            */
/*==============================================================*/
create domain LOAN_TYPE as VARCHAR(16);

/*==============================================================*/
/* Domain: MONEY                                                */
/*==============================================================*/
create domain MONEY as MONEY;

/*==============================================================*/
/* Domain: NAME                                                 */
/*==============================================================*/
create domain NAME as VARCHAR(128);

/*==============================================================*/
/* Domain: PHONE                                                */
/*==============================================================*/
create domain PHONE as VARCHAR(16);

/*==============================================================*/
/* Domain: PLACE                                                */
/*==============================================================*/
create domain PLACE as VARCHAR(128);

/*==============================================================*/
/* Domain: SEQ_NUM                                              */
/*==============================================================*/
create domain SEQ_NUM as INT4;

/*==============================================================*/
/* Domain: STATE                                                */
/*==============================================================*/
create domain STATE as VARCHAR(32);

/*==============================================================*/
/* Domain: TEXT                                                 */
/*==============================================================*/
create domain TEXT as VARCHAR(1024);

/*==============================================================*/
/* Domain: WEIGHT                                               */
/*==============================================================*/
create domain WEIGHT as DECIMAL(5,3);

/*==============================================================*/
/* Table: ANIMAL                                                */
/*==============================================================*/
create table ANIMAL (
   ANIMAL_ID            ID                   not null,
   GENDER_S             GENDER               not null,
   ANIMAL_NAME          VARCHAR(1024)        null,
   BIRTH_PLACE          PLACE                null,
   BIRTH_DATE           DATE                 null,
   ENGLISH_NAME         NAME                 not null,
   constraint PK_ANIMAL primary key (ANIMAL_ID)
);

/*==============================================================*/
/* Index: ANIMAL_PK                                             */
/*==============================================================*/
create unique index ANIMAL_PK on ANIMAL (
ANIMAL_ID
);

/*==============================================================*/
/* Index: ANIMAL_OF_SPECIES_FK                                  */
/*==============================================================*/
create  index ANIMAL_OF_SPECIES_FK on ANIMAL (
ENGLISH_NAME
);

/*==============================================================*/
/* Table: ANIMAL_ENCLOSURE                                      */
/*==============================================================*/
create table ANIMAL_ENCLOSURE (
   ANIMAL_ID            ID                   not null,
   SINCE                DATE                 not null,
   AREA_NAME            NAME                 not null,
   ENCLOSURE_NUM        SEQ_NUM              not null,
   END_DATE             DATE                 null,
   constraint PK_ANIMAL_ENCLOSURE primary key (ANIMAL_ID, SINCE)
);

/*==============================================================*/
/* Index: ANIMAL_ENCLOSURE_PK                                   */
/*==============================================================*/
create unique index ANIMAL_ENCLOSURE_PK on ANIMAL_ENCLOSURE (
ANIMAL_ID,
SINCE
);

/*==============================================================*/
/* Index: ANIMAL_IN_ENCLOSURE_FK                                */
/*==============================================================*/
create  index ANIMAL_IN_ENCLOSURE_FK on ANIMAL_ENCLOSURE (
ANIMAL_ID
);

/*==============================================================*/
/* Index: ENCLOSURE_HAS_ANIMAL_FK                               */
/*==============================================================*/
create  index ENCLOSURE_HAS_ANIMAL_FK on ANIMAL_ENCLOSURE (
AREA_NAME,
ENCLOSURE_NUM
);

/*==============================================================*/
/* Table: ANIMAL_IS_DIAGNOSED                                   */
/*==============================================================*/
create table ANIMAL_IS_DIAGNOSED (
   DIAGNOSIS_NAME       NAME                 not null,
   ANIMAL_ID            ID                   not null,
   VISIT_DATE           DATE                 not null,
   constraint PK_ANIMAL_IS_DIAGNOSED primary key (ANIMAL_ID, DIAGNOSIS_NAME, VISIT_DATE)
);

/*==============================================================*/
/* Index: ANIMAL_IS_DIAGNOSED_PK                                */
/*==============================================================*/
create unique index ANIMAL_IS_DIAGNOSED_PK on ANIMAL_IS_DIAGNOSED (
ANIMAL_ID,
DIAGNOSIS_NAME,
VISIT_DATE
);

/*==============================================================*/
/* Index: ANIMAL_IS_DIAGNOSED_FK                                */
/*==============================================================*/
create  index ANIMAL_IS_DIAGNOSED_FK on ANIMAL_IS_DIAGNOSED (
DIAGNOSIS_NAME
);

/*==============================================================*/
/* Index: ANIMAL_IS_DIAGNOSED2_FK                               */
/*==============================================================*/
create  index ANIMAL_IS_DIAGNOSED2_FK on ANIMAL_IS_DIAGNOSED (
ANIMAL_ID,
VISIT_DATE
);

/*==============================================================*/
/* Table: ANIMAL_PARENT                                         */
/*==============================================================*/
create table ANIMAL_PARENT (
   CHILD_ID             VARCHAR(10)          not null,
   PARENT_ID            VARCHAR(10)          not null,
   constraint PK_ANIMAL_PARENT primary key (CHILD_ID, PARENT_ID)
);

/*==============================================================*/
/* Table: ANIMAL_VISITS_VET                                     */
/*==============================================================*/
create table ANIMAL_VISITS_VET (
   ANIMAL_ID            ID                   not null,
   VISIT_DATE           DATE                 not null,
   PRESCRIPTION         TEXT                 null,
   VET_NAME             NAME                 not null,
   NEXT_VISIT           DATE                 null,
   constraint PK_ANIMAL_VISITS_VET primary key (ANIMAL_ID, VISIT_DATE)
);

/*==============================================================*/
/* Index: ANIMAL_VISITS_VET_PK                                  */
/*==============================================================*/
create unique index ANIMAL_VISITS_VET_PK on ANIMAL_VISITS_VET (
ANIMAL_ID,
VISIT_DATE
);

/*==============================================================*/
/* Index: ANIMAL_CHECK_UP_FK                                    */
/*==============================================================*/
create  index ANIMAL_CHECK_UP_FK on ANIMAL_VISITS_VET (
ANIMAL_ID
);

/*==============================================================*/
/* Index: VET_VISITED_ANIMAL_FK                                 */
/*==============================================================*/
create  index VET_VISITED_ANIMAL_FK on ANIMAL_VISITS_VET (
VET_NAME
);

/*==============================================================*/
/* Index: PRESCRIPTION_OF_VET_VISIT_FK                          */
/*==============================================================*/
create  index PRESCRIPTION_OF_VET_VISIT_FK on ANIMAL_VISITS_VET (
PRESCRIPTION
);

/*==============================================================*/
/* Table: AREA                                                  */
/*==============================================================*/
create table AREA (
   AREA_NAME            NAME                 not null,
   HEADKEEPER           NAME                 not null,
   constraint PK_AREA primary key (AREA_NAME)
);

/*==============================================================*/
/* Index: AREA_PK                                               */
/*==============================================================*/
create unique index AREA_PK on AREA (
AREA_NAME
);

/*==============================================================*/
/* Index: HEADKEEPER_OF_AREA2_FK                                */
/*==============================================================*/
create  index HEADKEEPER_OF_AREA2_FK on AREA (
HEADKEEPER
);

/*==============================================================*/
/* Table: AREA_KEEPER                                           */
/*==============================================================*/
create table AREA_KEEPER (
   KEEPER_NAME          NAME                 not null,
   WORK_DATE            DATE                 not null,
   AREA_NAME            NAME                 not null,
   constraint PK_AREA_KEEPER primary key (KEEPER_NAME, WORK_DATE)
);

/*==============================================================*/
/* Index: AREA_KEEPER_PK                                        */
/*==============================================================*/
create unique index AREA_KEEPER_PK on AREA_KEEPER (
KEEPER_NAME,
WORK_DATE
);

/*==============================================================*/
/* Index: KEEPER_IN_AREA_FK                                     */
/*==============================================================*/
create  index KEEPER_IN_AREA_FK on AREA_KEEPER (
KEEPER_NAME
);

/*==============================================================*/
/* Index: AREA_HAS_KEEPER_FK                                    */
/*==============================================================*/
create  index AREA_HAS_KEEPER_FK on AREA_KEEPER (
AREA_NAME
);

/*==============================================================*/
/* Table: DELIVERY                                              */
/*==============================================================*/
create table DELIVERY (
   DELIVERY_ID          serial               not null,
   ORDER_ID             ID                   not null,
   MESSAGE              TEXT                 not null,
   AMEND                TEXT                 null,
   constraint PK_DELIVERY primary key (DELIVERY_ID)
);

/*==============================================================*/
/* Index: DELIVERY_PK                                           */
/*==============================================================*/
create unique index DELIVERY_PK on DELIVERY (
DELIVERY_ID
);

/*==============================================================*/
/* Index: DELIVERY_ORDER_FK                                     */
/*==============================================================*/
create  index DELIVERY_ORDER_FK on DELIVERY (
ORDER_ID
);

/*==============================================================*/
/* Table: DIAGNOSIS                                             */
/*==============================================================*/
create table DIAGNOSIS (
   DIAGNOSIS_NAME       NAME                 not null,
   constraint PK_DIAGNOSIS primary key (DIAGNOSIS_NAME)
);

/*==============================================================*/
/* Index: DIAGNOSIS_PK                                          */
/*==============================================================*/
create unique index DIAGNOSIS_PK on DIAGNOSIS (
DIAGNOSIS_NAME
);

/*==============================================================*/
/* Table: DISCREPANCY                                           */
/*==============================================================*/
create table DISCREPANCY (
   DISCREPANCY_ID       serial	             not null,
   ORDER_ID             ID                   not null,
   MESSAGE           	TEXT                 not null,
   PLACE_DATE           DATE                 not null,
   constraint PK_DISCREPANCY primary key (DISCREPANCY_ID)
);

/*==============================================================*/
/* Index: DISCREPANCY_PK                                        */
/*==============================================================*/
create unique index DISCREPANCY_PK on DISCREPANCY (
DISCREPANCY_ID
);

/*==============================================================*/
/* Index: ORDER_DISCREPANCY_FK                                  */
/*==============================================================*/
create  index ORDER_DISCREPANCY_FK on DISCREPANCY (
ORDER_ID
);

/*==============================================================*/
/* Table: ENCLOSURE                                             */
/*==============================================================*/
create table ENCLOSURE (
   AREA_NAME            NAME                 not null,
   ENCLOSURE_NUM        SEQ_NUM              not null,
   constraint PK_ENCLOSURE primary key (AREA_NAME, ENCLOSURE_NUM)
);

/*==============================================================*/
/* Index: ENCLOSURE_PK                                          */
/*==============================================================*/
create unique index ENCLOSURE_PK on ENCLOSURE (
AREA_NAME,
ENCLOSURE_NUM
);

/*==============================================================*/
/* Index: ENCLOSURE_IN_AREA_FK                                  */
/*==============================================================*/
create  index ENCLOSURE_IN_AREA_FK on ENCLOSURE (
AREA_NAME
);

/*==============================================================*/
/* Table: EXCHANGE                                              */
/*==============================================================*/
create table EXCHANGE (
   ANIMAL_ID            ID                   not null,
   EXCHANGE_DATE        DATE                 not null,
   RETURN_DATE          DATE                 null,
   COMMENT              TEXT                 null,
   LOAN_TYPE            LOAN_TYPE            not null,
   PLACE                VARCHAR(128)         not null,
   constraint PK_EXCHANGE primary key (ANIMAL_ID, EXCHANGE_DATE)
);

/*==============================================================*/
/* Index: EXCHANGE_PK                                           */
/*==============================================================*/
create unique index EXCHANGE_PK on EXCHANGE (
ANIMAL_ID,
EXCHANGE_DATE
);

/*==============================================================*/
/* Index: ANIMAL_EXCHANGE_FK                                    */
/*==============================================================*/
create  index ANIMAL_EXCHANGE_FK on EXCHANGE (
ANIMAL_ID
);

/*==============================================================*/
/* Table: FEEDING                                               */
/*==============================================================*/
create table FEEDING (
   ANIMAL_ID            ID                   not null,
   FOOD_TYPE_FT         FOOD_TYPE_DOMAIN     not null,
   SINCE_F              DATE                 not null,
   AMOUNT               WEIGHT               not null,
   constraint PK_FEEDING primary key (ANIMAL_ID, FOOD_TYPE_FT, SINCE_F)
);

/*==============================================================*/
/* Index: FEEDING_PK                                            */
/*==============================================================*/
create unique index FEEDING_PK on FEEDING (
ANIMAL_ID,
FOOD_TYPE_FT,
SINCE_F
);

/*==============================================================*/
/* Index: FEEDING_FOR_ANIMAL_FK                                 */
/*==============================================================*/
create  index FEEDING_FOR_ANIMAL_FK on FEEDING (
ANIMAL_ID
);

/*==============================================================*/
/* Index: FOOD_TO_BE_FED_FK                                     */
/*==============================================================*/
create  index FOOD_TO_BE_FED_FK on FEEDING (
FOOD_TYPE_FT
);

/*==============================================================*/
/* Table: FOOD_KIND                                             */
/*==============================================================*/
create table FOOD_KIND (
   FOOD_TYPE_FT         FOOD_TYPE_DOMAIN     not null,
   constraint PK_FOOD_KIND primary key (FOOD_TYPE_FT)
);

/*==============================================================*/
/* Index: FOOD_TYPE_PK                                          */
/*==============================================================*/
create unique index FOOD_TYPE_PK on FOOD_KIND (
FOOD_TYPE_FT
);

/*==============================================================*/
/* Table: INVOICE                                               */
/*==============================================================*/
create table INVOICE (
   INVOICE_ID           ID                   not null,
   constraint PK_INVOICE primary key (INVOICE_ID)
);

/*==============================================================*/
/* Index: INVOICE_PK                                            */
/*==============================================================*/
create unique index INVOICE_PK on INVOICE (
INVOICE_ID
);

/*==============================================================*/
/* Table: KEEPER                                                */
/*==============================================================*/
create table KEEPER (
   KEEPER_NAME          NAME                 not null,
   constraint PK_KEEPER primary key (KEEPER_NAME)
);

/*==============================================================*/
/* Index: KEEPER_PK                                             */
/*==============================================================*/
create unique index KEEPER_PK on KEEPER (
KEEPER_NAME
);

/*==============================================================*/
/* Table: LINE_ITEM                                             */
/*==============================================================*/
create table LINE_ITEM (
   ORDER_ID             ID                   not null,
   FOOD_TYPE_FT         FOOD_TYPE_DOMAIN     not null,
   PRICE                MONEY                not null,
   WEIGHT               WEIGHT               not null,
   constraint PK_LINE_ITEM primary key (ORDER_ID, FOOD_TYPE_FT)
);

/*==============================================================*/
/* Index: LINE_ITEM_PK                                          */
/*==============================================================*/
create unique index LINE_ITEM_PK on LINE_ITEM (
ORDER_ID,
FOOD_TYPE_FT
);

/*==============================================================*/
/* Index: ITEM_IN_ORDER_FK                                      */
/*==============================================================*/
create  index ITEM_IN_ORDER_FK on LINE_ITEM (
ORDER_ID
);

/*==============================================================*/
/* Index: FOOD_IN_LINE_ITEM_FK                                  */
/*==============================================================*/
create  index FOOD_IN_LINE_ITEM_FK on LINE_ITEM (
FOOD_TYPE_FT
);

/*==============================================================*/
/* Table: MATING                                                */
/*==============================================================*/
create table MATING (
   ANIMAL_ID            ID	             not null,
   MATING_DATE          DATE                 not null,
   MATING_PLACE         PLACE                not null,
   MATE_ID              ID          	     null,
   constraint PK_MATING primary key (ANIMAL_ID, MATING_DATE)
);

/*==============================================================*/
/* Index: BREEDING_PK                                           */
/*==============================================================*/
create unique index BREEDING_PK on MATING (
ANIMAL_ID,
MATING_DATE
);

/*==============================================================*/
/* Index: BREEDING_MATE_FK                                      */
/*==============================================================*/
create  index BREEDING_MATE_FK on MATING (
ANIMAL_ID
);

/*==============================================================*/
/* Table: OFFSPRING                                             */
/*==============================================================*/
create table OFFSPRING (
   MATING_DATE          DATE                 not null,
   OFFSPRING_NAME       NAME                 not null,
   ANIMAL_ID            ID                   not null,
   OFFSPRING_ID         ID                   null,
   constraint PK_OFFSPRING primary key (MATING_DATE, OFFSPRING_NAME, ANIMAL_ID)
);

/*==============================================================*/
/* Index: OFFSPRING_PK                                          */
/*==============================================================*/
create unique index OFFSPRING_PK on OFFSPRING (
MATING_DATE,
OFFSPRING_NAME,
ANIMAL_ID
);

/*==============================================================*/
/* Table: "ORDER"                                               */
/*==============================================================*/
create table "ORDER" (
   ORDER_ID             ID                   not null,
   SUPPLIER_NAME        NAME                 not null,
   STATE                STATE                not null,
   ORDER_DATE           DATE                 not null,
   INVOICE_ID           ID                   null,
   constraint PK_ORDER primary key (ORDER_ID)
);

/*==============================================================*/
/* Index: ORDER_PK                                              */
/*==============================================================*/
create unique index ORDER_PK on "ORDER" (
ORDER_ID
);

/*==============================================================*/
/* Index: ORDER_SUPPLIER_FK                                     */
/*==============================================================*/
create  index ORDER_SUPPLIER_FK on "ORDER" (
SUPPLIER_NAME
);

/*==============================================================*/
/* Table: PRESCRIPTION                                          */
/*==============================================================*/
create table PRESCRIPTION (
   PRESCRIPTION         TEXT                 not null,
   constraint PK_PRESCRIPTION primary key (PRESCRIPTION)
);

/*==============================================================*/
/* Index: PRESCRIPTION_PK                                       */
/*==============================================================*/
create unique index PRESCRIPTION_PK on PRESCRIPTION (
PRESCRIPTION
);

/*==============================================================*/
/* Table: REINTRODUCTION                                        */
/*==============================================================*/
create table REINTRODUCTION (
   ANIMAL_ID            ID                   not null,
   REINTRODUCTION_DATE  DATE                 not null,
   LOCATION             PLACE                not null,
   COMMENT              TEXT                 null,
   constraint PK_REINTRODUCTION primary key (ANIMAL_ID, REINTRODUCTION_DATE)
);

/*==============================================================*/
/* Index: REINTRODUCTION_PK                                     */
/*==============================================================*/
create unique index REINTRODUCTION_PK on REINTRODUCTION (
ANIMAL_ID,
REINTRODUCTION_DATE
);

/*==============================================================*/
/* Index: ANIMAL_REINTRODUCTION_FK                              */
/*==============================================================*/
create  index ANIMAL_REINTRODUCTION_FK on REINTRODUCTION (
ANIMAL_ID
);

/*==============================================================*/
/* Table: SPECIES                                               */
/*==============================================================*/
create table SPECIES (
   ENGLISH_NAME         NAME                 not null,
   DESCRIPTION          TEXT                 not null,
   FAMILY               NAME                 null,
   SPECIES              NAME                 null,
   SUBSPECIES           NAME                 null,
   constraint PK_SPECIES primary key (ENGLISH_NAME)
);

/*==============================================================*/
/* Index: SPECIES_PK                                            */
/*==============================================================*/
create unique index SPECIES_PK on SPECIES (
ENGLISH_NAME
);

/*==============================================================*/
/* Table: SPECIES_GENDER                                        */
/*==============================================================*/
create table SPECIES_GENDER (
   ENGLISH_NAME         NAME                 not null,
   GENDER               GENDER               not null,
   AVERAGE_WEIGHT       WEIGHT               not null,
   MATURITY_AGE         AGE                  not null,
   constraint PK_SPECIES_GENDER primary key (ENGLISH_NAME, GENDER)
);

/*==============================================================*/
/* Index: SPECIES_GENDER_PK                                     */
/*==============================================================*/
create unique index SPECIES_GENDER_PK on SPECIES_GENDER (
ENGLISH_NAME,
GENDER
);

/*==============================================================*/
/* Index: SPECIES_WITH_GENDER_FK                                */
/*==============================================================*/
create  index SPECIES_WITH_GENDER_FK on SPECIES_GENDER (
ENGLISH_NAME
);

/*==============================================================*/
/* Table: SPOTTED                                               */
/*==============================================================*/
create table SPOTTED (
   ANIMAL_ID            ID                   not null,
   SPOT_DATE            DATE                 not null,
   constraint PK_SPOTTED primary key (ANIMAL_ID, SPOT_DATE)
);

/*==============================================================*/
/* Index: SPOTTED_PK                                            */
/*==============================================================*/
create unique index SPOTTED_PK on SPOTTED (
ANIMAL_ID,
SPOT_DATE
);

/*==============================================================*/
/* Index: ANIMAL_SPOTTED_FK                                     */
/*==============================================================*/
create  index ANIMAL_SPOTTED_FK on SPOTTED (
ANIMAL_ID
);

/*==============================================================*/
/* Table: STOCK                                                 */
/*==============================================================*/
create table STOCK (
   AREA_NAME            NAME                 not null,
   FOOD_TYPE_FT         FOOD_TYPE_DOMAIN     not null,
   AMOUNT               WEIGHT               not null,
   constraint PK_STOCK primary key (AREA_NAME, FOOD_TYPE_FT)
);

/*==============================================================*/
/* Index: STOCK_PK                                              */
/*==============================================================*/
create unique index STOCK_PK on STOCK (
AREA_NAME,
FOOD_TYPE_FT
);

/*==============================================================*/
/* Index: ANIMAL_FOODSTOCK_FK                                   */
/*==============================================================*/
create  index ANIMAL_FOODSTOCK_FK on STOCK (
AREA_NAME
);

/*==============================================================*/
/* Index: FOOD_IN_STOCK_FK                                      */
/*==============================================================*/
create  index FOOD_IN_STOCK_FK on STOCK (
FOOD_TYPE_FT
);

/*==============================================================*/
/* Table: SUPPLIER                                              */
/*==============================================================*/
create table SUPPLIER (
   SUPPLIER_NAME        NAME                 not null,
   PHONE_NUMER          PHONE                not null,
   ADDRESS              ADDRESS              not null,
   constraint PK_SUPPLIER primary key (SUPPLIER_NAME)
);

/*==============================================================*/
/* Index: SUPPLIER_PK                                           */
/*==============================================================*/
create unique index SUPPLIER_PK on SUPPLIER (
SUPPLIER_NAME
);

/*==============================================================*/
/* Table: SUPPLIES_FOOD_TYPE                                    */
/*==============================================================*/
create table SUPPLIES_FOOD_TYPE (
   FOOD_TYPE_FT         FOOD_TYPE_DOMAIN     not null,
   SUPPLIER_NAME        NAME                 not null,
   constraint PK_SUPPLIES_FOOD_TYPE primary key (FOOD_TYPE_FT, SUPPLIER_NAME)
);

/*==============================================================*/
/* Index: SUPPLIES_FOOD_TYPE_PK                                 */
/*==============================================================*/
create unique index SUPPLIES_FOOD_TYPE_PK on SUPPLIES_FOOD_TYPE (
FOOD_TYPE_FT,
SUPPLIER_NAME
);

/*==============================================================*/
/* Index: SUPPLIES_FOOD_TYPE_FK                                 */
/*==============================================================*/
create  index SUPPLIES_FOOD_TYPE_FK on SUPPLIES_FOOD_TYPE (
FOOD_TYPE_FT
);

/*==============================================================*/
/* Index: SUPPLIES_FOOD_TYPE2_FK                                */
/*==============================================================*/
create  index SUPPLIES_FOOD_TYPE2_FK on SUPPLIES_FOOD_TYPE (
SUPPLIER_NAME
);

/*==============================================================*/
/* Table: VET                                                   */
/*==============================================================*/
create table VET (
   VET_NAME             NAME                 not null,
   constraint PK_VET primary key (VET_NAME)
);

/*==============================================================*/
/* Index: VET_PK                                                */
/*==============================================================*/
create unique index VET_PK on VET (
VET_NAME
);

alter table ANIMAL
   add constraint FK_ANIMAL_OF_SPECIES foreign key (ENGLISH_NAME)
      references SPECIES (ENGLISH_NAME);

alter table ANIMAL_ENCLOSURE
   add constraint FK_ANIMAL_IN_ENCLOSURE foreign key (ANIMAL_ID)
      references ANIMAL (ANIMAL_ID);

alter table ANIMAL_ENCLOSURE
   add constraint FK_ENCLOSURE_HAS_ANIMAL foreign key (AREA_NAME, ENCLOSURE_NUM)
      references ENCLOSURE (AREA_NAME, ENCLOSURE_NUM);

alter table ANIMAL_IS_DIAGNOSED
   add constraint FK_ANIMAL_DIAGNOSIS foreign key (DIAGNOSIS_NAME)
      references DIAGNOSIS (DIAGNOSIS_NAME);

alter table ANIMAL_IS_DIAGNOSED
   add constraint FK_DIAGNOSED_ANIMAL foreign key (ANIMAL_ID, VISIT_DATE)
      references ANIMAL_VISITS_VET (ANIMAL_ID, VISIT_DATE);

alter table ANIMAL_PARENT
   add constraint FK_ANIMAL_P_ANIMAL_HA_ANIMAL foreign key (CHILD_ID)
      references ANIMAL (ANIMAL_ID);

alter table ANIMAL_PARENT
   add constraint FK_ANIMAL_P_PARENT_OF_ANIMAL foreign key (PARENT_ID)
      references ANIMAL (ANIMAL_ID);

alter table ANIMAL_VISITS_VET
   add constraint FK_ANIMAL_CHECK_UP foreign key (ANIMAL_ID)
      references ANIMAL (ANIMAL_ID);

alter table ANIMAL_VISITS_VET
   add constraint FK_PRESCRIPTION_OF_VET_VISIT foreign key (PRESCRIPTION)
      references PRESCRIPTION (PRESCRIPTION);

alter table ANIMAL_VISITS_VET
   add constraint FK_VET_VISITED_ANIMAL foreign key (VET_NAME)
      references VET (VET_NAME);

alter table AREA
   add constraint FK_HEADKEEPER_OF_AREA foreign key (HEADKEEPER)
      references KEEPER (KEEPER_NAME);

alter table AREA_KEEPER
   add constraint FK_KEEPER_IN_AREA foreign key (AREA_NAME)
      references AREA (AREA_NAME);

alter table AREA_KEEPER
   add constraint FK_KEEPERS_IN_AREA foreign key (KEEPER_NAME)
      references KEEPER (KEEPER_NAME);

alter table DELIVERY
   add constraint FK_DELIVERY__ORDER foreign key (ORDER_ID)
      references "ORDER" (ORDER_ID);

alter table DISCREPANCY
   add constraint FK_ORDER_DISCREPANCY foreign key (ORDER_ID)
      references "ORDER" (ORDER_ID);

alter table ENCLOSURE
   add constraint FK_ENCLOSURE_IN_AREA foreign key (AREA_NAME)
      references AREA (AREA_NAME);

alter table EXCHANGE
   add constraint FK_ANIMAL_EXCHANGE foreign key (ANIMAL_ID)
      references ANIMAL (ANIMAL_ID);

alter table FEEDING
   add constraint FK_FEEDING_FOR_ANIMAL foreign key (ANIMAL_ID)
      references ANIMAL (ANIMAL_ID);

alter table FEEDING
   add constraint FK_FOOD_TO_BE_FED foreign key (FOOD_TYPE_FT)
      references FOOD_KIND (FOOD_TYPE_FT);

alter table LINE_ITEM
   add constraint FK_FOOD_IN_LINE_TYPE foreign key (FOOD_TYPE_FT)
      references FOOD_KIND (FOOD_TYPE_FT);

alter table LINE_ITEM
   add constraint FK_ITEM_IN_ORDER foreign key (ORDER_ID)
      references "ORDER" (ORDER_ID);

alter table MATING
   add constraint FK_BREEDING_MATE foreign key (ANIMAL_ID)
      references ANIMAL (ANIMAL_ID);

alter table MATING
   add constraint FK_MATING_BREEDING__ANIMAL foreign key (MATE_ID)
      references ANIMAL (ANIMAL_ID);

alter table OFFSPRING
   add constraint FK_OFFSPRIN_ANIMAL_OF_ANIMAL foreign key (OFFSPRING_ID)
      references ANIMAL (ANIMAL_ID);

alter table OFFSPRING
   add constraint FK_OFFSPRIN_OFFSPRING_MATING foreign key (ANIMAL_ID, MATING_DATE)
      references MATING (ANIMAL_ID, MATING_DATE);

alter table "ORDER"
   add constraint FK_ORDER_IVOICE_OF_INVOICE foreign key (INVOICE_ID)
      references INVOICE (INVOICE_ID)
      on delete restrict on update restrict;

alter table "ORDER"
   add constraint FK_ORDER_SUPPLIER foreign key (SUPPLIER_NAME)
      references SUPPLIER (SUPPLIER_NAME);

alter table REINTRODUCTION
   add constraint FK_ANIMAL_REINTRODUCTION foreign key (ANIMAL_ID)
      references ANIMAL (ANIMAL_ID);

alter table SPECIES_GENDER
   add constraint FK_SPECIES_WITH_GENDER foreign key (ENGLISH_NAME)
      references SPECIES (ENGLISH_NAME);

alter table SPOTTED
   add constraint FK_ANIMAL_SPOTTED foreign key (ANIMAL_ID)
      references ANIMAL (ANIMAL_ID);

alter table STOCK
   add constraint FK_ANIMAL_FOODSTOCK foreign key (AREA_NAME)
      references AREA (AREA_NAME);

alter table STOCK
   add constraint FK_FOOD_IN_STOCK foreign key (FOOD_TYPE_FT)
      references FOOD_KIND (FOOD_TYPE_FT);

alter table SUPPLIES_FOOD_TYPE
   add constraint FK_SUPPLIER_HAS_FOOD_TYPE foreign key (FOOD_TYPE_FT)
      references FOOD_KIND (FOOD_TYPE_FT);

alter table SUPPLIES_FOOD_TYPE
   add constraint FK_SUPPLIER_SUPPLIES_FOOD foreign key (SUPPLIER_NAME)
      references SUPPLIER (SUPPLIER_NAME);

