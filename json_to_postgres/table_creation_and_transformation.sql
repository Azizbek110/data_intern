CREATE TABLE books (
        id      numeric      PRIMARY KEY,
        title       text,
        author      text,
        genre       text,
        publisher   text,
        year        integer,
        price       text
    );

	
--proper name
ALTER TABLE books RENAME COLUMN id TO book_id;
ALTER TABLE books RENAME COLUMN pub_year TO publication_year

--adding currency columns
ALTER TABLE books ADD COLUMN currency VARCHAR(3);

--extracting currency from price 
UPDATE books
SET
    currency = CASE
        WHEN price LIKE '$%' THEN 'USD'
        WHEN price LIKE '€%' THEN 'EUR'
    END,
    price = REGEXP_REPLACE(price, '^[$€]', '')

--applying proper data type for calculation
ALTER TABLE books ALTER COLUMN price TYPE NUMERIC(10,2) USING price::NUMERIC(10,2);


--summary table logic based one requirements
select publication_year, count(book_id) as book_count,
round(avg(case when currency = 'USD' then price else price * 1.2 end), 2) as average_price
from books
group by publication_year
order by publication_year;

--creating summary table
CREATE TABLE summary (
    publication_year INTEGER PRIMARY KEY,
    book_count       INTEGER,
    average_price    NUMERIC(10,2)
)


--inserting to summary
INSERT INTO summary (publication_year, book_count, average_price)
SELECT
    publication_year,
    COUNT(book_id),
    ROUND(AVG(CASE WHEN currency = 'USD' THEN price
                   WHEN currency = 'EUR' THEN price * 1.2
                   ELSE price
              END), 2)
FROM books
GROUP BY publication_year;


select *
from summary
