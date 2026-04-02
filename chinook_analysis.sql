/*
Chinook Database Analysis Project

Description:
Analysis of a digital music store dataset to uncover
customer behavior, revenue trends, and product performance.

Key Insights:
- Identified top customers by spending
- Analyzed revenue distribution across countries
- Found top-selling artists and genres
- Evaluated employee support performance

Tools:
- PostgreSQL (pgAdmin)
*/

--=========================
--CUSTOMER ANALYSIS PROJECT
--=========================

--1./*Total Spent by each Customer*/
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    ROUND(SUM(i.total)::numeric, 3) AS total_spent
FROM customer c
JOIN invoice i
    ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

--2./*Total Revenue by Country*/
SELECT 
    billing_country,
    ROUND(SUM(total)::numeric, 3) AS total_revenue,
    COUNT(*) AS number_of_invoices
FROM invoice
GROUP BY billing_country
ORDER BY total_revenue DESC;

--3./*Top 10 selling artists*/
SELECT 
    ar.name AS artist_name,
    ROUND(SUM(il.unit_price * il.quantity)::numeric) AS revenue
FROM invoice_line il
JOIN track t
    ON il.track_id = t.track_id
JOIN album al
    ON t.album_id = al.album_id
JOIN artist ar
    ON al.artist_id = ar.artist_id
GROUP BY ar.name
ORDER BY revenue DESC
LIMIT 10;

--4./*Most Consumed Genres*/
SELECT 
    g.name AS genre_name,
    SUM(il.quantity) AS total_tracks_sold
FROM invoice_line il
JOIN track t
    ON il.track_id = t.track_id
JOIN genre g
    ON t.genre_id = g.genre_id
GROUP BY g.name
ORDER BY total_tracks_sold DESC;

--5./*Average Invoice Total by Customer Country */
SELECT 
    c.country,
    COUNT(i.invoice_id) AS invoice_count,
    ROUND(SUM(i.total),3) AS total_revenue,
    ROUND(AVG(i.total), 3) AS avg_invoice_total
FROM customer c
JOIN invoice i
    ON c.customer_id = i.customer_id
GROUP BY c.country
ORDER BY total_revenue DESC;

--6./*Employees and Number of Supported Customers*/
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    COUNT(c.customer_id) AS customers_supported
FROM employee e
LEFT JOIN customer c
    ON e.employee_id = c.support_rep_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY customers_supported DESC;

--7./*Customers who spend above AVG*/
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    ROUND(SUM(i.total)::numeric, 2) AS total_spent
FROM customer c
JOIN invoice i
    ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(i.total) > (
    SELECT AVG(total_spent)
    FROM (
        SELECT SUM(total) AS total_spent
        FROM invoice
        GROUP BY customer_id
    ) sub
)
ORDER BY total_spent DESC;


