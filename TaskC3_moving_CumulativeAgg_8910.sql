--report8
--level 2
SELECT
    to_char(cs.startdate, 'YYYY') as year,
    count(cf.clientid) AS total_client,
    SUM(count(cf.clientid)) OVER(
        ORDER BY
            to_char(cs.startdate, 'YYYY')
        ROWS UNBOUNDED PRECEDING
    ) AS moving_n_year_sum
FROM
    clientservicehistorydim  cs,
    clientdim                 c,
    clientfactv1        cf
WHERE
        cf.clientid = c.clientid
    AND c.clientid = cs.clientid
    AND cf.budgetcategoryid IN 'High'
GROUP BY
  to_char(cs.startdate, 'YYYY');

--Level 0:
SELECT
    to_char(cs.startdate, 'YYYY') as year,
    count(cf.clientid) AS total_client,
    SUM(count(cf.clientid)) OVER(
        ORDER BY
            to_char(cs.startdate, 'YYYY')
        ROWS UNBOUNDED PRECEDING
    ) AS moving_n_year_sum
FROM
    clientservicehistorydim  cs,
    clientdimv2                 c,
    clientfactv2        cf
WHERE
        cf.clientid = c.clientid
    AND c.clientid = cs.clientid
    AND cf.budgetcategoryid IN 'High'
GROUP BY
  to_char(cs.startdate, 'YYYY');

--Report9
--level 2
SELECT
    concat(t.year, t.month)          AS sale_date,
    SUM(ps.numofsale)                AS total_sale,
    SUM(SUM(ps.numofsale)) OVER(
        ORDER BY
            t.year
        ROWS UNBOUNDED PRECEDING
    ) AS moving_n_month_sum
FROM
    propertysalefactv1  ps,
    timedim             t
WHERE
    t.timeid = ps.timeid
GROUP BY
    t.year,
    t.month,
    concat(t.year, t.month)
ORDER BY
    concat(t.year, t.month);

--level 0
SELECT
    concat(t.year, t.month)          AS sale_date,
    SUM(ps.numofsale)                AS total_sale,
    SUM(SUM(ps.numofsale)) OVER(
        ORDER BY
            t.year
        ROWS UNBOUNDED PRECEDING
    ) AS moving_n_year_sum
FROM
    propertysalefactv2  ps,
    timedimv2           t
WHERE
    t.timeid = ps.timeid
GROUP BY
    t.year,
    concat(t.year, t.month)
ORDER BY
    concat(t.year, t.month);

--Report10
--level 2
SELECT
    concat(t.year, t.month)           AS sale_date,
    SUM(ps.total_sale_amount)        AS total_sale,
    SUM(SUM(ps.total_sale_amount)) OVER(
        ORDER BY
            t.year
        ROWS UNBOUNDED PRECEDING
    ) AS moving_n_month_sum
FROM
    propertysalefactv1  ps,
    timedim             t
WHERE
    t.timeid = ps.timeid
GROUP BY
    t.month,
    t.year,
    concat(t.year, t.month)
ORDER BY
    concat(t.year, t.month);

--level 0
SELECT
    concat(t.year, t.month)          AS sale_date,
    SUM(ps.total_sale_amount)        AS total_sale,
    SUM(SUM(ps.total_sale_amount)) OVER(
        ORDER BY
            t.year
        ROWS UNBOUNDED PRECEDING
    ) AS moving_n_month_sum
FROM
    propertysalefactv2  ps,
    timedimv2           t
WHERE
        t.timeid = ps.timeid
    AND ps.timeid IS NOT NULL
GROUP BY
    t.year,
    t.month,
    concat(t.year, t.month)
ORDER BY
    concat(t.year, t.month);