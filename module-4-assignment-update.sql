-- Very close, though there are some subtle errors in three of these. 7/10.

-- 4.1 
-- CREATE an empty table with 3cols "year" (integer), "description" (text), "sales" (numeric)
-- include a DROP IF EXISTS statement. Call table product_summary
DROP TABLE IF EXISTS product_summary;
CREATE TABLE product_summary
(year INTEGER,
description TEXT,
sales NUMERIC
);

-- 4.2 
-- Write a (set of) statements that inserts rows into your TABLE
INSERT INTO product_summary
VALUES
(2014, 'BANANA Organic', 176818.73),
(2015, 'BANANA Organic', 258541.96),
(2014, 'AVOCADO Hass Organic', 146480.34),
(2014, 'ChickenBreastBoneless/Skinless', 204630.90);

SELECT *
FROM product_summary;

-- 4.3 
-- Update the year for the row containing avocado to 2022
UPDATE product_summary
SET year = 2022
WHERE description like 'AVOC%';

SELECT *
FROM product_summary;

-- 4.4 
-- DELETE the oldest banana from the TABLE
DELETE FROM product_summary
WHERE year IN (SELECT min(year)
			   FROM product_summary)
	AND description like 'BANANa%';

SELECT *
FROM product_summary;

-- 4.5 
SELECT `umt-msba.wedge_example.department_date`.department, `umt-msba.wedge_example.departments`.dept_name, SUM(spend) as dept_spend
FROM `umt-msba.wedge_example.department_date`
INNER JOIN `umt-msba.wedge_example.departments` on `umt-msba.wedge_example.department_date`.department = `umt-msba.wedge_example.departments`.department
WHERE EXTRACT(YEAR FROM date) = 2015
GROUP BY department, dept_name;

-- 4.6 
-- FROM table umt-msba.wedge_example.owner_spend_date 
--return card_no , year , month , spend , and items . Those
--last two columns should be the sum of the columns of the same name in the original table. Filter
--your results to owner-year-month combinations between $750 and $1250, order by spend in
--descending order, and only return the top 10 rows.
SELECT card_no, EXTRACT(YEAR FROM date) AS year, EXTRACT(MONTH from date) AS month, sum(spend) as spend, sum(items) as num_items
 FROM `umt-msba.wedge_example.owner_spend_date` 
WHERE spend > 750 
GROUP BY card_no, year, month
HAVING spend > 750
  AND spend < 1250
ORDER BY spend DESC
LIMIT 10;
-- Please note that when you're working with aggregated data, 
-- you should use the HAVING clause to filter the results, 
-- not the WHERE clause. The WHERE clause is used to filter 
-- rows before they are grouped and aggregated. 
-- The HAVING clause is used to filter the results after they 
-- are grouped and aggregated. 
-- FIXED


-- 4.7
-- use the table umt-msba.transactions.transArchive_201001_201003 . 
-- following columns:
-- The total number of rows, which you can get with COUNT(*)
-- The number of unique card numbers
-- The total "spend". This value is in a field called total
-- The number of unique product descriptions ( description )
-- One of these return values is going to look pretty weird. See if you can figure out why it's so
-- weird. Type the answer in a comment in your .sql file.
SELECT COUNT(*) as total_rows, COUNT(DISTINCT card_no) as unique_cards, SUM(total) as total, COUNT(DISTINCT description) as unique_prod_descr
FROM `umt-msba.transactions.transArchive_201001_201003`;
-- The "total" column looks funky because the value is much lower than the others (3.13), 
-- it looks like the wedge had a lot of returns and $0 transctions in these three days
-- Maybe first day with a new system and testing all the products?
-- Close. But it's the balancing of payments and item costs.

-- 4.8 
-- Repeat 4.7, but group by year
SELECT EXTRACT(YEAR from datetime) as year, 
        COUNT(*) as total_rows, 
        COUNT(DISTINCT card_no) as unique_cards, 
        SUM(total) as total, 
        COUNT(DISTINCT description) as unique_prod_descr
FROM `umt-msba.transactions.transArchive_*`
GROUP BY year;

-- 4.9
SELECT EXTRACT(YEAR from datetime) as year,
       sum(total) as spend,
       COUNT(DISTINCT CONCAT(CAST(EXTRACT(DATE from datetime) AS STRING), 
              CAST(register_no AS STRING),
              CAST(emp_no AS STRING),
              CAST(trans_no AS STRING))
              ) AS trans,
        SUM(CASE WHEN trans_status IN ('V', 'R') THEN -1
                  ELSE 1 
                    END) AS items
FROM `umt-msba.transactions.transArchive_*`
WHERE department NOT IN (0, 15)
  (AND trans_status IS NULL -- This has a logic error
  OR trans_status IN (" ", "V", "R"))
GROUP BY year
ORDER BY year;

-- 4.10
-- Copy 4.9 but add cols date and hour
SELECT EXTRACT(DATE from datetime) as date,
       EXTRACT(HOUR from datetime) as hour,
       sum(total) as spend,
       COUNT(DISTINCT CONCAT(CAST(EXTRACT(DATE from datetime) AS STRING), 
              CAST(register_no AS STRING),
              CAST(emp_no AS STRING),
              CAST(trans_no AS STRING))
              ) AS trans,
        SUM(CASE WHEN trans_status IN ('V', 'R') THEN -1
                  ELSE 1 
                    END) AS items
FROM `umt-msba.transactions.transArchive_*`
WHERE department NOT IN (0, 15)
  (AND trans_status IS NULL -- same issue here. 
  OR trans_status IN (" ", "V", "R"))
GROUP BY date, hour
ORDER BY date, hour;




