--Report 4: Cube
--Level 2:
SELECT
  decode(GROUPING(pl.suburb), 1, 'All Suburb', pl.suburb) as Suburb,
    decode(GROUPING(r.rentperiodid), 1, 'All Period', r.rentperiodid) as Time_period,
    decode(GROUPING( pr.propertytypeid), 1, 'All Property Type', pr.propertytypeid) as Property_type,
    SUM(pr.total_rental_fee) AS total_rental_fee
FROM
    propertylocationdim  pl,
    rentperioddim        r,
    propertyrentfactv1   pr
WHERE
        r.rentperiodid = pr.rentperiodid
    AND pl.locationid = pr.locationid
    AND r.rentperiodid != 'Not Rent'
GROUP BY
    CUBE(pl.suburb,
         r.rentperiodid,
         pr.propertytypeid);

--level 0         
SELECT
    decode(GROUPING(pl.suburb), 1, 'All Suburb', pl.suburb) as Suburb,
    decode(GROUPING(r.rentperiodid), 1, 'All Period', r.rentperiodid) as Time_period,
    decode(GROUPING( pr.propertytypeid), 1, 'All Property Type', pr.propertytypeid) as Property_type,
    SUM(pr.total_rental_fee) AS total_rental_fee
FROM
    propertylocationdimv2  pl,
    rentperioddimv2        r,
    propertyrentfactv2   pr
WHERE
        r.rentperiodid = pr.rentperiodid
    AND pl.locationid = pr.locationid
    AND r.rentperiodid != 'Not Rent'
GROUP BY
    CUBE(pl.suburb,
         r.rentperiodid,
         pr.propertytypeid);
         
--Report 5: Partial Cube
--Level 2:
SELECT
    decode(GROUPING(pl.suburb), 1, 'All Suburb', pl.suburb) as Suburb,
    decode(GROUPING(r.rentperiodid), 1, 'All Period', r.rentperiodid) as Time_period,
    decode(GROUPING( pr.propertytypeid), 1, 'All Property Type', pr.propertytypeid) as Property_type,
    SUM(pr.total_rental_fee) AS total_rental_fee
FROM
    propertylocationdim  pl,
    rentperioddim        r,
    propertyrentfactv1   pr
WHERE
        r.rentperiodid = pr.rentperiodid
    AND pl.locationid = pr.locationid
    AND r.rentperiodid != 'Not Rent'
GROUP BY
    pr.propertytypeid,
    CUBE(r.rentperiodid,
         pl.suburb);

--level 0 
SELECT
    decode(GROUPING(pl.suburb), 1, 'All Suburb', pl.suburb)                                      
    AS suburb,
    decode(GROUPING(r.rentperiodid), 1, 'All Period', r.rentperiodid)                            
    AS time_period,
    decode(GROUPING(pr.propertytypeid), 1, 'All Property Type', pr.propertytypeid)              
    AS property_type,
    SUM(pr.total_rental_fee)                                                                     
    AS total_rental_fee
FROM
    propertylocationdimv2  pl,
    rentperioddimv2        r,
    propertyrentfactv2   pr
WHERE
        r.rentperiodid = pr.rentperiodid
    AND pl.locationid = pr.locationid
    AND r.rentperiodid != 'Not Rent'
GROUP BY
    pr.propertytypeid,
    CUBE(r.rentperiodid,
         pl.suburb);
         
--Report 6: Roll-up
--Level 2:
SELECT
    decode(GROUPING(pl.statename), 1, 'All statename', pl.statename) as State,
    decode(GROUPING(t.season), 1, 'All Season', t.season) as Season,
    decode(GROUPING( ps.propertytypeid), 1, 'All Property Type', ps.propertytypeid) as Property_Type,
    SUM(ps.total_sale_amount) AS total_sale_amount
FROM
    propertylocationdim  pl,
    timedim              t,
    propertysalefactv1   ps
WHERE
        t.timeid = ps.timeid
    AND pl.locationid = ps.locationid
    AND ps.timeid is not null
GROUP BY
    ROLLUP(pl.statename,
           t.season,
           ps.propertytypeid);
           
--level 0
SELECT
    decode(GROUPING(pl.statename), 1, 'All statename', pl.statename)                            
    AS state,
    decode(GROUPING(t.season), 1, 'All Season', t.season)                                        
    AS season,
    decode(GROUPING(ps.propertytypeid), 1, 'All Property Type', ps.propertytypeid)              
    AS property_type,
    SUM(ps.total_sale_amount)                                                                    
    AS total_sale_amount
FROM
    propertylocationdimv2  pl,
    timedimv2              t,
    propertysalefactv2   ps
WHERE
        t.timeid = ps.timeid
    AND pl.locationid = ps.locationid
    AND ps.timeid IS NOT NULL
GROUP BY
    ROLLUP(pl.statename,
           t.season,
           ps.propertytypeid);

--Report 7: Partial Roll-up
--Level 2:
SELECT
    decode(GROUPING(pl.statename), 1, 'All statename', pl.statename) as State,
    decode(GROUPING(t.season), 1, 'All Season', t.season) as Season,
    decode(GROUPING( ps.propertytypeid), 1, 'All Property Type', ps.propertytypeid) as Property_Type,
    SUM(ps.total_sale_amount) AS total_sale_amount
FROM
    propertylocationdim  pl,
    timedim              t,
    propertysalefactv1   ps
WHERE
        t.timeid = ps.timeid
    AND pl.locationid = ps.locationid
    AND ps.timeid is not null
GROUP BY
    ps.propertytypeid,
    ROLLUP(pl.statename,
           t.season);
           

--level 0
SELECT
    decode(GROUPING(pl.statename), 1, 'All statename', pl.statename)                             
    AS state,
    decode(GROUPING(t.season), 1, 'All Season', t.season)                                        
    AS season,
    decode(GROUPING(ps.propertytypeid), 1, 'All Property Type', ps.propertytypeid)              
    AS property_type,
    SUM(ps.total_sale_amount)                                                                    
    AS total_sale_amount
FROM
    propertylocationdimv2  pl,
    timedimv2              t,
    propertysalefactv2   ps
WHERE
        t.timeid = ps.timeid
    AND pl.locationid = ps.locationid
    AND ps.timeid IS NOT NULL
GROUP BY
    ps.propertytypeid,
    ROLLUP(pl.statename,
           t.season);