create table ANIMAL (
  animal_id int not null,
  animal_name varchar(100) not null,
  constraint PK_ANIMAL primary key (animal_id)
)

create table ENCLOSURE (
  enclosure_num int not null,
  constraint PK_ENCLOSURE primary key (enclosure_num)
)

create table ANIMAL_ENCLOSURE (
  animal_id int not null,
  enclosure_num int not null,
  since date not null,
  end_date date null,
  constraint PK_ANIMAL_ENCLOSURE primary key (animal_id, enclosure_num, since)
)

alter table ANIMAL_ENCLOSURE
add constraint FK_ANIMAL_IN_ENCLOSURE foreign key (animal_id) references ANIMAL (animal_id),
add constraint FK_ENCLOSURE_HAS_ANIMAL foreign key (enclosure_num) references ENCLOSURE (enclosure_num)