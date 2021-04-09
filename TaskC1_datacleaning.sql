drop table address;
drop table advertisement;
drop table agent;
drop table agent_office;
drop table client;
drop table client_wish;
drop table feature;
drop table office;
drop table person;
drop table person2;
drop table postcode;
drop table property;
drop table property2;
drop table property_advert;
drop table property_feature;
drop table rent;
drop table sale;
drop table state;
drop table visit;

--create table
create table address as select * from MonRE.Address;
create table advertisement as select * from MonRE.advertisement;
create table agent as select * from MonRE.agent;
create table agent_office as select * from MonRE.agent_office;
create table client as select * from MONRE.client;
create table client_wish as select * from MONRE.client_wish;
create table feature as select * from MonRE.feature;
create table office as select * from MonRE.office;
create table person2 as select * from MonRE.person;
create table postcode as select * from MonRE.postcode;
create table property2 as select * from MonRE.property;
create table property_advert as select * from MONRE.property_advert;
create table property_feature as select * from MONRE.property_feature;
create table rent as select * from MonRE.rent;
create table sale as select * from MonRE.sale;
create table state as select * from MonRE.state;
create table visit as select * from MonRE.visit;
--11duplicated rows in person table
select count (*) from person2;
create table person as select distinct * from person2;
select count (*) from person;
--12duplicated rows in property table
select count (*) from property2;
create table property as select distinct * from property2;



--data cleaning
--check data valid

--1 person_id does not exist in person table
select * from agent where person_id not in (select person_id from person);
select count(*) from person where person_id = 6997;
delete from agent where person_id = 6997;
--2 salary is negatove
select * from agent where salary <0;
delete from agent where person_id = 6844;
delete from agent where person_id = 6000;
insert into agent values (6844, 100000);
insert into agent values (6000, 120000);
select * from agent where person_id = 6844;
select * from agent where person_id = 6000;

--3 person_id does not exist in person table
select * from agent_office where person_id not in (select person_id from person);
select * from property_advert where agent_person_id = 6997;
delete from agent_office where person_id = 6997;
--4 person_id does not exist in person table
select * from client where person_id not in (select person_id from person);
select * from person where person_id = 7000;
select * from rent where client_person_id = 7000;
select * from sale where client_person_id = 7000;
delete from client where person_id = 7000;
--5 max budget is negative
--6 max budget smaller than min budget
select * from client where max_budget <= min_budget;
delete from client where max_budget <= min_budget;
insert into client values (5900, 50 , 8500);
insert into client values (5901, 150 , 3500);
insert into client values (5902, 5400 , 12500);
--7 state is null
select * from state where state_code  is null or state_name  is null;
select * from state;
delete from state where state_code  is null;
--8 invalid person null
select * from person where address_id not in (select address_id from address);
delete from person where person_id = 7001;
--9 startdate earilier than end date
select rent.rent_id, rent.property_id, to_char(rent.rent_start_date, 'YYYY:mon:DD'),to_char(rent.rent_end_date, 'YYYY:mon:DD')
from  rent where to_char(rent_start_date, 'yyyy:mm') > to_char(rent_end_date, 'yyyy:mm');
select * from rent where rent_id = 3284;
delete from rent where rent_id = 3284;
insert into rent values (3284, 6002, 6001, 5741, TO_DATE('01/06/2019', 'dd/mm/YYYY'), TO_DATE('31/12/2021', 'dd/mm/YYYY'), 500); 
--10 client_person_id not in client list
select client_person_id, agent_person_id, property_id, duration, to_char(visit.visit_date, 'yyyy:mon:dd'), duration from visit where client_person_id not in (select person_id from client);
select * from visit where agent_person_id not in (select person_id from agent);
select * from agent where person_id = '6001';
select * from client where person_id = '6000';
select * from person where person_id = '6001';
select * from person where person_id = '6000';
select * from visit where to_char(visit.visit_date, 'yyyy') > 2020;
select * from visit where client_person_id = 6000;
delete from visit where client_person_id = 6000;

commit;


