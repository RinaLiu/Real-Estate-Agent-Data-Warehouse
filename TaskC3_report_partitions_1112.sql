--report11
--Level 2
SELECT
    ps.propertytypeid,
    t.year,
    pl.statename,
    SUM(ps.numofsale) AS total_num_of_sale,
    RANK() OVER(PARTITION BY ps.propertytypeid
        ORDER BY
            SUM(ps.numofsale) DESC
    ) AS type_rank,
    RANK() OVER(PARTITION BY pl.statename
        ORDER BY
            SUM(ps.numofsale) DESC
    ) AS state_rank
FROM
    propertysalefactv1   ps,
    timedim              t,    
    propertylocationdim  pl
WHERE
        ps.locationid = pl.locationid
    AND ps.timeid = t.timeid
GROUP BY
    ps.propertytypeid, pl.statename, t.year
ORDER BY
    ps.propertytypeid,
    pl.statename,
    t.year;

--level 0
SELECT
    ps.propertytypeid,
    t.year,
    pl.statename,
    SUM(ps.numofsale) AS total_num_of_sale,
    RANK() OVER(PARTITION BY ps.propertytypeid
        ORDER BY
            SUM(ps.numofsale) DESC
    ) AS type_rank,
    RANK() OVER(PARTITION BY pl.statename
        ORDER BY
            SUM(ps.numofsale) DESC
    ) AS state_rank
FROM
    propertysalefactv2   ps,
    timedimv2              t,
    propertylocationdimv2  pl
WHERE
        ps.locationid = pl.locationid
    AND ps.timeid = t.timeid
GROUP BY
    ps.propertytypeid,
    pl.statename,
    t.year
ORDER BY
    ps.propertytypeid,
    pl.statename,
    t.year;

--report12
--Level 2:
SELECT
    pr.propertytypeid,
    pl.statename,
    SUM(pr.numofrent) as total_num_of_rent,
    RANK() OVER(PARTITION BY pr.propertytypeid
        ORDER BY
            SUM(pr.numofrent) DESC
    ) AS type_rank,
    RANK() OVER(PARTITION BY pl.statename
        ORDER BY
            SUM(pr.numofrent) DESC
    ) AS state_rank
FROM
    propertyrentfactv1   pr,
    propertylocationdim  pl
WHERE
        pr.locationid = pl.locationid
GROUP BY
    pr.propertytypeid,
    pl.statename
ORDER BY
    pr.propertytypeid,
    pl.statename;

--level 0 
SELECT
    pr.propertytypeid,
    pl.statename,
    SUM(pr.numofrent) as total_num_of_rent,
    RANK() OVER(PARTITION BY pr.propertytypeid
        ORDER BY
            SUM(pr.numofrent) DESC
    ) AS type_rank,
    RANK() OVER(PARTITION BY pl.statename
        ORDER BY
            SUM(pr.numofrent) DESC
    ) AS state_rank
FROM
    propertyrentfactv2   pr,
    propertylocationdimv2  pl
WHERE
        pr.locationid = pl.locationid
GROUP BY
    pr.propertytypeid,
    pl.statename
ORDER BY
    pr.propertytypeid,
    pl.statename;