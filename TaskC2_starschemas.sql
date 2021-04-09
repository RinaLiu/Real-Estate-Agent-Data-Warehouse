--RentPeriodDimV2
drop table rentperioddimV2;
create table rentperioddimV2 (
rentPeriodID varchar2(10),
rentPeriodDesc varchar2(50));

insert into rentperioddimV2 values('Short', 'Rent period < 6 months');
insert into rentperioddimV2 values('Medium', 'Rent period between 6-12 months');
insert into rentperioddimV2 values('Long', 'Rent period > 12 months');

--PropertyLocationDimV2
drop table PropertyLocationDimV2;
create table PropertyLocationDimV2 as
select  a.address_id as locationID, a.street, a.suburb,a.postcode, 
p.state_code as statecode ,state_name as statename
from address a join postcode p on p.postcode=a.postcode
join state s on s.state_code=p.state_code;

--advertisementdimV2
drop table advertisementdimV2;
create table advertisementdimV2 as
select advert_id as advertID, advert_name as advertname
from advertisement;

--propertyAdvertBridgeV2
drop table propertyAdvertBridgeV2;
create table propertyAdvertBridgeV2 as 
select advert_id as advertID, property_id as propertyID, cost
from property_advert;

--propertyAdvertDImV2
drop table propertyAdvertDImV2;
create table propertyAdvertDimV2 as  
select p.property_id as propertyid, 1/count(a.advert_ID) as weightFactor,
listagg (a.advert_id,'-') within group (order by a.advert_id) as advertList
from property_advert a,property p
where a.property_id = p.property_id
group by p.property_id;

--propertyScaleDimV2
drop table propertyScaleDimV2;
create table propertyScaleDimV2 (
PropertyScaleID varchar2(20),
PropertyScaleDesc varchar2(50));

insert into propertyScaleDimV2 values('Extra Small', '<= 1 bedroom');
insert into propertyScaleDimV2 values('Small', '2-3 bedroom');
insert into propertyScaleDimV2 values('Medium', '3-6 bedroom');
insert into propertyScaleDimV2 values('Large', '6-10 bedroom');
insert into propertyScaleDimV2 values('Extra Large', '>10 bedroom');

--fetureCategoryDimV2
drop table featureCategoryDimV2;
create table featureCategoryDimV2 (
featureCategoryID varchar2(20),
featureCategoryDesc varchar(50));

insert into featureCategoryDimV2 values('Very basic', '<10 fetures');
insert into featureCategoryDimV2 values('Standard', '10-20 fetures');
insert into featureCategoryDimV2 values('Luxurious', '>20 fetures');

--featureDIMV2
drop table featureDIMV2;
create table featureDIMV2 as
select feature_code as featureID,feature_description as featuredesc from feature;

--propertyfeatureBridgeV2
drop table propertyfeatureBridgeV2;
create table propertyfeatureBridgeV2 as
select property_id as propertyid,feature_code as featureID from property_feature;

--propertyfeatureDimV2
drop table propertyfeatureDimV2;
create table propertyfeatureDimV2 as 
select p.property_id as propertyid, 1/count(a.feature_code) as weightFactor,
listagg (a.feature_code,'-') within group (order by a.feature_code) as featureList
from property_feature a,property p
where a.property_id = p.property_id
group by p.property_id;

--clientWishFeatureBridgeV2
drop table clientWishFeatureBridgeV2;
create table clientWishFeatureBridgeV2 as
select person_id as clientid,feature_code as featureid
from client_wish;

--clientWishDimV2
drop table clientWishDimV2;
create table clientWishDimV2 as
select c.person_id as clientid,
1/count(w.feature_code) as weightFactor,
listagg (w.feature_code,'-') within group (order by w.feature_code) as featureList
from client_wish w,client c
where w.person_id = c.person_id 
group by c.person_id;

--clientBudgetDImV2
drop table clientBudgetDImV2;
create table clientBudgetDImV2 (
budgetCategoryID varchar(20),
budgetCategoryDesc varchar(50));

insert into clientBudgetDImV2 values('Low', '<1000');
insert into clientBudgetDImV2 values('Medium', '1001-100000');
insert into clientBudgetDImV2 values('High', '100001-10000000');

--clientDImV2
drop table clientDimV2;
create table clientDimV2 as
select c.person_id as clientid, 
p.gender,
c.max_budget as maxbudget,
c.min_budget as minbudget
from client c, person p
where p.person_id=c.person_id;

select * from clientDImV2;

--clientServiceHistoryDImv2
drop table clientServiceHistoryDImv2;
create table clientServiceHistoryDImv2 as
select distinct client_person_id as clientID, rent_start_date as startDate, 'Rent ' as ServiceType from rent;

insert into clientServiceHistoryDImv2 (
select client_person_id  as clientID ,sale_date as startDate,'Sale ' as ServiceType 
from sale );
insert into clientServiceHistoryDImv2 (
select client_person_id  as clientID ,visit_date as startDate,'Visit' as ServiceType 
from visit );

--OfficeDImV2
drop table OfficeDImV2;
create table OfficeDImV2 as
select office_id as officeid, office_name as office_name
from office;

alter table OfficeDImV2 add (officeSize varchar2(20),numOfAgent numeric(3));


update OfficeDImV2 o
set numOfAgent = 
(select count(*) from agent_Office a where a.office_id=o.officeid group by a.office_id);

update OfficeDImV2
set numOfAgent = 0
where numOfAgent is null;

update OfficeDImV2
set officeSize ='Small' where numOfAgent <4;
update OfficeDImV2
set officeSize ='Medium' where numOfAgent <=12 and numOfAgent >=4;
update OfficeDImV2
set officeSize ='Big' where numOfAgent >12;

--agentOfficeBridgeV2
drop table agentOfficeBridgeV2;
create table agentOfficeBridgeV2 as
select person_id as agentid, office_id as officeid
from agent_office;

--agentDimV2
drop table agentDimV2;
create table agentDimV2 as
select a.person_id as agentid, gender, salary as agentSalary,
1/count(ao.office_id) as weightFactor,
listagg (ao.office_id,'-') within group (order by ao.office_id) as officeList
from agent_office ao, agent a, person p
where ao.person_id = a.person_id 
and a.person_id=p.person_id
group by a.person_id, gender, salary;

--timedimV2
drop table tempdim1;
drop table tempdim2;

create table tempdim1 as
select distinct to_char(visit_date,'ddmmyyyy') as timeid, extract(year from visit_date) as year,
extract(month from visit_date) as month, extract(day from visit_date) as day
from visit;

create table tempdim2 as
select distinct to_char(sale_date,'ddmmyyyy') as timeid, extract(year from sale_date) as year,
extract(month from sale_date) as month, extract(day from sale_date) as day
from sale;
delete from tempdim2 where timeid is null;
select * from tempdim2;
drop table tempdim6;
create table tempdim6 as 
SELECT timeid, year, month, day
FROM   tempdim1
UNION
SELECT timeid, year, month, day
FROM   tempdim2
ORDER BY timeid;

--timeDimV2
drop table timeDimV2;
create table timeDimV2 as select distinct * from tempdim6;

    --addseason
ALTER TABLE timeDimV2 
    ADD (season VARCHAR2(20));

update timeDimV2
    set season = 'Summer' where month = 12;
update timeDimV2
    set season = 'Summer' where month <= 02 and month >=01;
update timeDimV2
    set season = 'Autumn' where month >= 03 and month <= 05;
update timeDimV2
    set season = 'Spring' where month >= 09 and month <= 11;
update timeDimV2
    set season = 'Winter' where month >= 06 and month <= 08;

    --addweekdayname
ALTER TABLE timeDimV2 
    ADD (weekday VARCHAR2(20));

update timeDimV2
     set weekday = 'Monday' where (SELECT to_char(to_date(timeid,'ddmmyy'),'d') FROM DUAL ) = 1;
update timeDimV2
     set weekday = 'Tuesday' where (SELECT to_char(to_date(timeid,'ddmmyy'),'d') FROM DUAL ) = 2;
update timeDimV2
     set weekday = 'Wednesday' where (SELECT to_char(to_date(timeid,'ddmmyy'),'d') FROM DUAL ) = 3;
update timeDimV2
     set weekday = 'Thursday' where (SELECT to_char(to_date(timeid,'ddmmyy'),'d') FROM DUAL ) = 4;     
update timeDimV2
     set weekday = 'Friday' where (SELECT to_char(to_date(timeid,'ddmmyy'),'d') FROM DUAL ) = 5;
update timeDimV2
     set weekday = 'Saturday' where (SELECT to_char(to_date(timeid,'ddmmyy'),'d') FROM DUAL ) = 6;
update timeDimV2
     set weekday = 'Sunday' where (SELECT to_char(to_date(timeid,'ddmmyy'),'d') FROM DUAL ) = 7;
     
select * from timeDimV2;
select count(*) from timeDimV2;

--temppropertyRentFactV2
drop table temppropertyRentFactV2;
create table temppropertyRentFactV2 as
select r.rent_id as rentid, r.property_id as propertyid, r.agent_person_id as agentid, p.address_id as locationid,
p.property_type as propertytypeid,r.rent_start_date,r.rent_end_date,p.property_no_of_bedrooms,sum(price) as total_rental_fee,count(rent_id) as numOfRent
from rent r,property p
where r.property_id = p.property_id
group by r.rent_id, r.client_person_id, r.property_id, r.agent_person_id, p.address_id,p.property_type,r.rent_start_date,
r.rent_end_date,p.property_no_of_bedrooms;
    --add rentperiod
alter table temppropertyRentFactV2 add rentperiodid varchar(10);

update temppropertyRentFactV2
set rentperiodid='Short'
where add_months(rent_start_date,6)>=rent_end_date;
update temppropertyRentFactV2
set rentperiodid='Medium'
where add_months(rent_start_date,12)>=rent_end_date and add_months(rent_start_date,6)<=rent_end_date;
update temppropertyRentFactV2
set rentperiodid='Long'
where add_months(rent_start_date,12)<rent_end_date;
update temppropertyRentFactV2
set rentperiodid='Not Rent'
where rentperiodid is null
;
    --propertyscale
alter table temppropertyRentFactV2 add propertyScaleid varchar(20);

update temppropertyRentFactV2
set propertyScaleid='Extra Small'
where property_no_of_bedrooms<=1;

update temppropertyRentFactV2
set propertyScaleid='Small'
where property_no_of_bedrooms between 2 and 3;

update temppropertyRentFactV2
set propertyScaleid='Medium'
where property_no_of_bedrooms between 3 and 6;

update temppropertyRentFactV2
set propertyScaleid='Large'
where property_no_of_bedrooms between 6 and 10;

update temppropertyRentFactV2
set propertyScaleid='Extra Large'
where property_no_of_bedrooms >10;

alter table temppropertyRentFactV2 add numoffeature numeric(2);

update temppropertyRentFactV2 f
set numoffeature = (select count(*) from property_feature p where p.property_id=f.propertyid group by p.property_id);

alter table temppropertyRentFactV2 add featureCategoryID varchar(20);

update temppropertyRentFactV2
set featureCategoryID='Very Basic'
where numoffeature<10;
update temppropertyRentFactV2
set featureCategoryID='Very Basic'
where numoffeature is null;
update temppropertyRentFactV2
set featureCategoryID='Standard'
where numoffeature between 10 and 20;
update temppropertyRentFactV2
set featureCategoryID='Luxurious'
where numoffeature>20;

--propertyrentFact
drop table propertyrentFactV2;
create table propertyrentFactV2 as
select rentid, propertyid, agentid, locationid, propertyTypeid, rentperiodid,propertyScaleID,
FeatureCategoryID,total_rental_fee, numofrent
from temppropertyRentFactV2;


--temppropertySaleFactV2
drop table temppropertySaleFactV2;
create table temppropertySaleFactV2 as
select r.sale_id as saleid, r.property_id as propertyid, r.agent_person_id as agentid, p.address_id as locationid,
p.property_type as propertytypeid, p.property_no_of_bedrooms,to_char(sale_date,'ddmmYYYY') as timeid,
sum(price) as total_sale_amount,count(sale_id) as numOfsale
from sale r,property p
where r.property_id = p.property_id
group by r.sale_id, r.property_id , r.agent_person_id, r.client_person_id, p.address_id, sale_date, property_no_of_bedrooms, property_type;

alter table temppropertySaleFactV2 add propertyScaleid varchar(20);

update temppropertySaleFactV2
set propertyScaleid='Extra Small'
where property_no_of_bedrooms<=1;

update temppropertySaleFactV2
set propertyScaleid='Small'
where property_no_of_bedrooms between 2 and 3;

update temppropertySaleFactV2
set propertyScaleid='Medium'
where property_no_of_bedrooms between 3 and 6;

update temppropertySaleFactV2
set propertyScaleid='Large'
where property_no_of_bedrooms between 6 and 10;

update temppropertySaleFactV2
set propertyScaleid='Extra Large'
where property_no_of_bedrooms >10;

alter table temppropertySaleFactV2 add numoffeature numeric(2);

update temppropertySaleFactV2 f
set numoffeature = 
(select count(*) from property_feature p where p.property_id=f.propertyid group by p.property_id);

alter table temppropertySaleFactV2 add featureCategoryID varchar(20);

update temppropertySaleFactV2
set featureCategoryID='Very Basic'
where numoffeature<10;
update temppropertySaleFactV2
set featureCategoryID='Very Basic'
where numoffeature is null;
update temppropertySaleFactV2
set featureCategoryID='Standard'
where numoffeature between 10 and 20;
update temppropertySaleFactV2
set featureCategoryID='Luxurious'
where numoffeature>20;

--PropertySaleFactv2
drop table PropertySaleFactv2;
create table PropertySaleFactv2 as
select saleid, propertyid,agentid,locationid,timeid, propertytypeid,propertyscaleid,featurecategoryid,total_sale_amount,numofsale
from temppropertySaleFactV2;

--propertyVisit
drop table propertyVisitFactv2;
create table propertyVisitFactv2 as 
select to_char(visit_date,'ddmmYYYY') as timeid, agent_person_id as agentid, client_person_id as clientid, property_id as propertyid, 
duration, count(*) as total_sale_amount
from visit
group by to_char(visit_date,'ddmmYYYY'), agent_person_id, client_person_id, property_id, duration;


--clientTempFactV2
drop table clientTempFactV2;
create table clientTempFactV2 as
select person_id as clientid, min_budget, max_budget,count(person_id) as TotalNoOfClients
from client
group by person_id,min_budget,max_budget;

alter table clientTempFactV2 add budgetCategoryid varchar2(20);
update clientTempFactV2
set budgetCategoryid = 'Low'
where max_budget>0 and max_budget<=1000;
update clientTempFactV2
set budgetCategoryid = 'Medium'
where max_budget>1001 and max_budget<=100000;
update clientTempFactV2
set budgetCategoryid = 'High'
where max_budget>100001 and max_budget<=10000000;

--ClientFact
drop table ClientFactv2;
create table ClientFactv2 as
select clientid,budgetcategoryid,totalnoofclients
from clientTempFactV2;

--AgentFact
drop table AgentFactv2;
create table AgentFactv2 as
select a.person_id as agentid, sum(salary) as total_Agent_Salary,count(*) as total_agent
from agent a, person p
where a.person_id=p.person_id
group by a.person_id, p.gender;


commit;
--RentPeriodDIm
drop table rentperioddim;
create table rentPeriodDim (
rentPeriodID varchar2(10),
rentPeriodDesc varchar2(50));

insert into rentperioddim values('Short', 'Rent period < 6 months');
insert into rentperioddim values('Medium', 'Rent period between 6-12 months');
insert into rentperioddim values('Long', 'Rent period > 12 months');
insert into rentperioddim values('Not Rent', 'Property has not rented out');

--rentPRiceDim
drop table rentPricedim;
create table rentPricedim as 
select property_id as propertyid, rent_start_date as startdate,rent_end_date as enddate,
price from rent;

--PropertyLocationDim
drop table PropertyLocationDim;
create table PropertyLocationDim as
select  distinct suburb || a.postcode as locationID, suburb,a.postcode, 
p.state_code as statecode ,state_name as statename
from address a join postcode p on p.postcode=a.postcode
join state s on s.state_code=p.state_code;

--advertisementdim
drop table advertisementdim;
create table advertisementdim as
select advert_id as advertID, advert_name as advertname
from advertisement;

--propertyAdvertBridge
drop table propertyAdvertBridge;
create table propertyAdvertBridge as 
select advert_id as advertID, property_id as propertyID, cost
from property_advert;

--propertyAdvertDIm
drop table propertyAdvertDIm;
create table propertyAdvertDim as  
select p.property_id as propertyid, 1/count(a.advert_ID) as weightFactor,
listagg (a.advert_id,'-') within group (order by a.advert_id) as advertList
from property_advert a,property p
where a.property_id = p.property_id
group by p.property_id;

--propertyScaleDim
drop table propertyScaleDim;
create table propertyScaleDim (
PropertyScaleID varchar2(20),
PropertyScaleDesc varchar2(50));

insert into PropertyScaleDim values('Extra Small', '<= 1 bedroom');
insert into PropertyScaleDim values('Small', '2-3 bedroom');
insert into PropertyScaleDim values('Medium', '3-6 bedroom');
insert into PropertyScaleDim values('Large', '6-10 bedroom');
insert into PropertyScaleDim values('Extra Large', '>10 bedroom');

--fetureCategoryDim
drop table fetureCategoryDim;
create table fetureCategoryDim (
fetureCategoryID varchar2(20),
fetureCategoryDesc varchar(50));

insert into fetureCategoryDim values('Very basic', '<10 fetures');
insert into fetureCategoryDim values('Standard', '10-20 fetures');
insert into fetureCategoryDim values('Luxurious', '>20 fetures');

--featureDIM
drop table featureDIM;
create table featureDIM as
select feature_code as featureID,feature_description as featuredesc from feature;

--propertyfeatureBridge
drop table propertyfeatureBridge;
create table propertyfeatureBridge as
select property_id as propertyid,feature_code as featureID from property_feature;

--propertyfeatureDIm
drop table propertyfeatureDIm;
create table propertyfeatureDIm as 
select p.property_id as propertyid, 1/count(a.feature_code) as weightFactor,
listagg (a.feature_code,'-') within group (order by a.feature_code) as featureList
from property_feature a,property p
where a.property_id = p.property_id
group by p.property_id;

--clientWishFeatureBridge
drop table clientWishFeatureBridge;
create table clientWishFeatureBridge as
select person_id as clientid,feature_code as featureid
from client_wish;

--clientWishDim
drop table clientWishDim;
create table clientWishDim as
select c.person_id as clientid,
1/count(w.feature_code) as weightFactor,
listagg (w.feature_code,'-') within group (order by w.feature_code) as featureList
from client_wish w,client c
where w.person_id = c.person_id 
group by c.person_id;

--clientBudgetDIm
drop table clientBudgetDIm;
create table clientBudgetDIm (
budgetCategoryID varchar(20),
budgetCategoryDesc varchar(50));

insert into clientBudgetDIm values('Low', '<1000');
insert into clientBudgetDIm values('Medium', '1001-100000');
insert into clientBudgetDIm values('High', '100001-10000000');

--clientDim
drop table ClientDim;
create table clientDim as
select c.person_id as clientID,gender
from person p,client c
where p.person_id=c.person_id;

--clientServiceHistoryDIm
drop table clientServiceHistoryDIm;
create table clientServiceHistoryDIm as
select distinct client_person_id as clientID, rent_start_date as startDate, 'Rent ' as ServiceType from rent;

insert into clientServiceHistoryDIm (
select client_person_id  as clientID ,sale_date as startDate,'Sale ' as ServiceType 
from sale );
insert into clientServiceHistoryDIm (
select client_person_id  as clientID ,visit_date as startDate,'Visit' as ServiceType 
from visit );

select * from clientServiceHistoryDIm;

--OfficeDIm
drop table OfficeDIm;
create table OfficeDIm as
select office_id as officeid, office_name as office_name
from office;

alter table OfficeDIm add (officeSize varchar2(20),numOfAgent numeric(3));

update OfficeDIm o
set numOfAgent = 
(select count(*) from agent_Office a where a.office_id=o.officeid group by a.office_id);

update officedim
set numOfAgent = 0
where numOfAgent is null;

update officedim
set officeSize ='Small' where numOfAgent <4;
update officedim
set officeSize ='Medium' where numOfAgent <=12 and numOfAgent >=4;
update officedim
set officeSize ='Big' where numOfAgent >12;


select * from officedim;

--agentOfficeBridge
drop table agentOfficeBridge;
create table agentOfficeBridge as 
select person_id as agentid,office_id as officeid
from agent_office;
select * from agentOfficeBridge;

--agentdim
drop table agentdim;
create table agentdim as
select a.person_id as agentid, gender, salary as agentSalary,
1/count(o.office_id) as WeightFactor,
listagg (o.office_id,'-') within group (order by o.office_id) as featureList
from agent a, agent_office o, person p
where a.person_id=p.person_id and o.person_id=a.person_id
group by a.person_id, gender, salary;
select * from agentdim;


--timedim
drop table timeDim;
create table timedim as
select distinct to_char(visit_date,'mmyyyy') as timeid, extract(year from visit_date) as year,
extract(month from visit_date) as month
from visit
union
select distinct to_char(sale_date,'mmyyyy') as timeid, extract(year from sale_date) as year,
extract(month from sale_date) as month
from sale
where sale_date is not null
;

alter table timedim add season varchar2(20);
update timedim
set season = 'Summer'
where month in (12,1,2);
update timedim
set season = 'Spring'
where month in (9,10,11);
update timedim
set season = 'Winter'
where month in (6,7,8);
update timedim
set season = 'Autumn'
where month in (3,4,5);

select * from timedim;

--salePriceDim
drop table salePriceDim;
create table salePriceDim as 
select property_id as propertyid, sale_date as saledate,price
from sale;

--temppropertyRentFactV1
drop table temppropertyRentFactV1;
create table temppropertyRentFactV1 as
select r.property_id as propertyid, agent_person_id as agentid, suburb||postcode as locationid,
property_type as propertytypeid,rent_start_date,rent_end_date,property_no_of_bedrooms,sum(price) as total_rental_fee,count(rent_id) as numOfRent
from rent r,property p, address a
where r.property_id = p.property_id and a.address_id=p.address_id
--and rent_start_date is not null and rent_end_date is not null
group by r.property_id, agent_person_id, suburb||postcode,rent_start_date,rent_end_date,property_no_of_bedrooms,
property_type;

alter table temppropertyRentFactV1 add rentperiodid varchar(10);

update temppropertyRentFactV1
set rentperiodid='Short'
where add_months(rent_start_date,6)>=rent_end_date
;
update temppropertyRentFactV1
set rentperiodid='Medium'
where add_months(rent_start_date,12)>=rent_end_date and add_months(rent_start_date,6)<=rent_end_date
;

update temppropertyRentFactV1
set rentperiodid='Long'
where add_months(rent_start_date,12)<rent_end_date
;

update temppropertyRentFactV1
set rentperiodid='Not Rent'
where rentperiodid is null
;

alter table temppropertyRentFactV1 add propertyScaleid varchar(20);

update temppropertyRentFactV1
set propertyScaleid='Extra Small'
where property_no_of_bedrooms<=1;

update temppropertyRentFactV1
set propertyScaleid='Small'
where property_no_of_bedrooms between 2 and 3;

update temppropertyRentFactV1
set propertyScaleid='Medium'
where property_no_of_bedrooms between 3 and 6;

update temppropertyRentFactV1
set propertyScaleid='Large'
where property_no_of_bedrooms between 6 and 10;

update temppropertyRentFactV1
set propertyScaleid='Extra Large'
where property_no_of_bedrooms >10;

alter table temppropertyRentFactV1 add numoffeature numeric(2);

update temppropertyRentFactV1 f
set numoffeature = 
(select count(*) from property_feature p where p.property_id=f.propertyid group by p.property_id);

alter table temppropertyRentFactV1 add featureCategoryID varchar(20);

update temppropertyRentFactV1
set featureCategoryID='Very Basic'
where numoffeature<10 or numoffeature is null;
update temppropertyRentFactV1
set featureCategoryID='Standard'
where numoffeature between 10 and 20;
update temppropertyRentFactV1
set featureCategoryID='Luxurious'
where numoffeature>20;


select * from temppropertyRentFactV1;

--propertyrentFact
drop table propertyrentFactV1;
create table propertyrentFactv1 as
select propertyid,agentid, locationid,propertyTypeid, rentperiodid,propertyScaleID,
FeatureCategoryID,total_rental_fee,numofrent
from temppropertyRentFactV1;


select * from propertyrentFactV1;

--temppropertySaleFactV1
drop table temppropertySaleFactV1;
create table temppropertySaleFactV1 as
select r.property_id as propertyid, agent_person_id as agentid, suburb||postcode as locationid,
property_type as propertytypeid,property_no_of_bedrooms,to_char(sale_date,'mmyyyy') as timeid,
sum(price) as total_sale_amount,count(sale_id) as numOfsale
from sale r,property p, address a
where r.property_id = p.property_id and a.address_id=p.address_id
group by r.property_id, agent_person_id, suburb||postcode,sale_date,property_no_of_bedrooms,
property_type;

alter table temppropertySaleFactV1 add propertyScaleid varchar(20);

update temppropertySaleFactV1
set propertyScaleid='Extra Small'
where property_no_of_bedrooms<=1;

update temppropertySaleFactV1
set propertyScaleid='Small'
where property_no_of_bedrooms between 2 and 3;

update temppropertySaleFactV1
set propertyScaleid='Medium'
where property_no_of_bedrooms between 3 and 6;

update temppropertySaleFactV1
set propertyScaleid='Large'
where property_no_of_bedrooms between 6 and 10;

update temppropertySaleFactV1
set propertyScaleid='Extra Large'
where property_no_of_bedrooms >10;


alter table temppropertySaleFactV1 add numoffeature numeric(2);

update temppropertySaleFactV1 f
set numoffeature = 
(select count(*) from property_feature p where p.property_id=f.propertyid group by p.property_id);

alter table temppropertySaleFactV1 add featureCategoryID varchar(20);

update temppropertySaleFactV1
set featureCategoryID='Very Basic'
where numoffeature<10 or numoffeature is null;
update temppropertySaleFactV1
set featureCategoryID='Standard'
where numoffeature between 10 and 20;
update temppropertySaleFactV1
set featureCategoryID='Luxurious'
where numoffeature>20;

--PropertySaleFactv1
drop table PropertySaleFactv1;
create table PropertySaleFactv1 as
select propertyid,agentid,locationid,propertytypeid,timeid,propertyscaleid,featurecategoryid,total_sale_amount,numofsale
from temppropertySaleFactV1;

select * from PropertySaleFactv1;

--propertyVisit
drop table propertyVisitFactv1;
create table propertyVisitFactv1 as 
select to_char(visit_date,'mmyyyy') as timeid, agent_person_id as agentid, count(*) as total_sale_amount,
count(distinct property_id) as numodsale
from visit
group by to_char(visit_date,'mmyyyy'), agent_person_id;

select * from propertyVisitFactv1;

--clientFact
drop table TempClientFactv1;
create table TempClientFactv1 as
select person_id as clientid, min_budget, max_budget,count(*) as TotalNoOfClients
from client c
group by person_id,min_budget,max_budget;


alter table TempClientFactv1 add budgetCategoryid varchar2(20);
update TempClientFactv1
set budgetCategoryid = 'Low'
where max_budget>0 and max_budget<=1000;
update TempClientFactv1
set budgetCategoryid = 'Medium'
where max_budget>1001 and max_budget<=100000;
update TempClientFactv1
set budgetCategoryid = 'High'
where max_budget>100001 and max_budget<=10000000;

--ClientFact
drop table ClientFactv1;
create table ClientFactv1 as
select clientid,budgetcategoryid,totalnoofclients
from TempClientFactv1;

--AgentFact
drop table AgentFactv1;
create table AgentFactv1 as
select a.person_id as agentid, sum(salary) as total_Agent_Salary,count(*) as total_agent
from agent a, person p
where a.person_id=p.person_id
group by a.person_id;




commit;


