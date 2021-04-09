--a.simple report
--Report 1: Top 5 property type with highest average price in Victoria
--level 2
SELECT
    *
FROM
    (
        SELECT
            ps.propertytypeid,
            ROUND(avg(s.price),2) AS average_price,
            RANK() OVER(
                ORDER BY
                    avg(s.price) DESC
            ) AS price_rank
        FROM
            salepricedim         s,
            propertysalefactv1   ps,
            propertylocationdim  pl
        WHERE
                s.propertyid = ps.propertyid
            AND pl.locationid = ps.locationid
            AND pl.statename IN 'Victoria'
            AND ps.timeid is not null
        GROUP BY
            ps.propertytypeid
    )
WHERE
    price_rank <= 5;
--level 0
SELECT
    *
FROM
    (
        SELECT
            ps.propertytypeid,
            ROUND(avg(ps.total_sale_amount),2) AS average_price,
            RANK() OVER(
                ORDER BY
                    avg(ps.total_sale_amount) DESC
            ) AS price_rank
        FROM
            propertysalefactv2   ps,
            propertylocationdimv2 pl
        WHERE
                 pl.locationid = ps.locationid
            AND pl.statename IN 'Victoria'
            AND ps.timeid is not null
        GROUP BY
            ps.propertytypeid
    )
WHERE
    price_rank <= 5;
--Report 2: Top 50% property type with highest average price in Victoria
--level 2
SELECT
    *
FROM
    (
        SELECT
            ps.propertytypeid,
            ROUND(avg(s.price),2) AS average_price,
            PERCENT_RANK() OVER(
                ORDER BY
                    avg(s.price) DESC
            ) AS price_rank
        FROM
            salepricedim         s,
            propertysalefactv1   ps,
            propertylocationdim  pl
        WHERE
                s.propertyid = ps.propertyid
            AND pl.locationid = ps.locationid
            AND pl.statename IN 'Victoria'
            and ps.timeid is not null
        GROUP BY
            ps.propertytypeid
    )
WHERE
    price_rank <= 0.5;
--level 0
SELECT
    *
FROM
    (
        SELECT
            ps.propertytypeid,
            ROUND(avg(ps.total_sale_amount),2) AS average_price,
            PERCENT_RANK() OVER(
                ORDER BY
                    avg(ps.total_sale_amount) DESC
            ) AS price_rank
        FROM
            
            propertysalefactv2   ps,
            propertylocationdimv2  pl
        WHERE
                 pl.locationid = ps.locationid
            AND pl.statename IN 'Victoria'
            and ps.timeid is not null
        GROUP BY
            ps.propertytypeid
    )
WHERE
    price_rank <= 0.5;
--Report 3: show all percent rank of property type with highest average price in Victoria
--level 2
SELECT
    ps.propertytypeid,
    ROUND(avg(s.price),2) AS average_price,
    PERCENT_RANK() OVER(
        ORDER BY
            avg(s.price) DESC
    ) AS price_rank
FROM
    salepricedim         s,
    propertysalefactv1   ps,
    propertylocationdim  pl
WHERE
        s.propertyid = ps.propertyid
    AND pl.locationid = ps.locationid
    AND pl.statename IN 'Victoria'
    AND ps.timeid is not null
GROUP BY
    ps.propertytypeid;
--level 0
SELECT
    ps.propertytypeid,
    ROUND(avg(ps.total_sale_amount),2) AS average_price,
    PERCENT_RANK() OVER(
        ORDER BY
            avg(ps.total_sale_amount) DESC
    ) AS price_rank
FROM
    propertysalefactv2   ps,
    propertylocationdimv2  pl
WHERE
         pl.locationid = ps.locationid
    AND pl.statename IN 'Victoria'
    AND ps.timeid is not null
GROUP BY
    ps.propertytypeid;
