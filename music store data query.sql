create database music_store;
use music_STORE;

-- Q1. What is the total number of tracks available in each genre?

SELECT 
    g.genre_id, g.name, COUNT(t.track_id) AS trackCount
FROM
    genre g
        JOIN
    track t ON T.Genre_Id = G.Genre_Id
GROUP BY g.name
ORDER BY trackCount DESC;



-- Q.2 Who are the top 5 customers based on the number of tracks purchased?

SELECT 
    Customer.First_Name,
    Customer.Last_Name,
    COUNT(Invoice_Line.Track_Id) AS TotalTracksPurchased
FROM
    Invoice_Line
        JOIN
    Invoice ON Invoice_Line.Invoice_Id = Invoice.Invoice_Id
        JOIN
    Customer ON Invoice.Customer_Id = Customer.Customer_Id
GROUP BY Customer.First_Name , Customer.Last_Name
ORDER BY TotalTracksPurchased DESC
LIMIT 5;


-- Q.3 Which employee has processed the most invoices?

SELECT 
    E.First_Name,
    E.Last_Name,
    COUNT(I.Invoice_Id) AS InvoicesProcessed
FROM
    Invoice I
        JOIN
    Employee E ON I.billing_city = E.city
GROUP BY E.First_Name , E.Last_Name
ORDER BY InvoicesProcessed DESC
LIMIT 1;


-- Q.4 Find the total sales made in each year.

SELECT 
    YEAR(Invoice.Invoice_Date) AS Year,
    SUM(Invoice.Total) AS TotalSales
FROM
    Invoice
GROUP BY Year
ORDER BY Year;

-- How many customers are there from each country?

SELECT Country, COUNT(Customer_Id) AS NumberOfCustomers
FROM Customer
GROUP BY Country
ORDER BY NumberOfCustomers DESC;


--  Q5: Who is the senior most employee , return (first_name) and (last_name) as full name  based on job title? 

SELECT 
    title, CONCAT(first_name, ' ', last_name) AS full_name
FROM
    employee
ORDER BY levels DESC
LIMIT 1;



-- Q6: Which countries have the most Invoices? 

SELECT COUNT(*) AS c, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY c DESC ;



-- Q7: What are top 3 values of total invoice? 

SELECT total 
FROM invoice
ORDER BY total DESC
limit 3;



-- Which invoice had the highest total amount?
SELECT Invoice_Id, Total
FROM Invoice
ORDER BY Total DESC
LIMIT 1;

-- Find the average amount spent per invoice for each customer.
SELECT Customer.First_Name, Customer.Last_Name, AVG(Invoice.Total) AS AverageInvoiceTotal
FROM Invoice
JOIN Customer ON Invoice.Customer_Id = Customer.Customer_Id
GROUP BY Customer.First_Name, Customer.Last_Name
ORDER BY AverageInvoiceTotal DESC;

-- Find the top 3 employees who have processed the most sales (total invoice amount).

SELECT Employee.First_Name, Employee.Last_Name, SUM(Invoice.Total) AS TotalSales
FROM Invoice
JOIN Employee ON billing_city = Employee.city
GROUP BY Employee.First_Name, Employee.Last_Name
ORDER BY TotalSales DESC
LIMIT 3;


-- Find the total sales for each artist.

SELECT Artist.Name AS ArtistName, SUM(Invoice_Line.Unit_Price * Invoice_Line.Quantity) AS TotalSales
FROM Invoice_Line
JOIN Track ON Invoice_Line.Track_Id = Track.Track_Id
JOIN Album2 ON Track.Album_Id = Album2.Album_Id
JOIN Artist ON Album2.Artist_Id = Artist.Artist_Id
GROUP BY Artist.Name
ORDER BY TotalSales DESC;

-- Which country has the highest average invoice total?
SELECT Billing_Country AS Country, AVG(Total) AS AverageInvoiceTotal
FROM Invoice
GROUP BY Billing_Country
ORDER BY AverageInvoiceTotal DESC
LIMIT 1;

-- Return the customers who made more than 5 purchases and have spent more than the average amount across all customers.

WITH CustomerPurchases AS (
    SELECT Customer.Customer_Id, 
           Customer.First_Name, 
           Customer.Last_Name, 
           COUNT(Invoice.Invoice_Id) AS NumberOfPurchases, 
           SUM(Invoice.Total) AS TotalSpent
    FROM Customer
    JOIN Invoice ON Customer.Customer_Id = Invoice.Customer_Id
    GROUP BY Customer.Customer_Id, Customer.First_Name, Customer.Last_Name
),
AverageSpent AS (
    SELECT AVG(TotalSpent) AS AvgSpent
    FROM CustomerPurchases
)
SELECT First_Name, Last_Name, NumberOfPurchases, TotalSpent
FROM CustomerPurchases
WHERE NumberOfPurchases > 5 AND TotalSpent > (SELECT AvgSpent FROM AverageSpent)
ORDER BY TotalSpent DESC;


/* Q8: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT billing_city,SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;



-- Q.11 What is the average length of tracks in each genre?

SELECT Genre.Name AS GenreName, AVG(Track.Milliseconds) AS AverageTrackLength
FROM Track
JOIN Genre ON Track.Genre_Id = Genre.Genre_Id
GROUP BY Genre.Name
ORDER BY AverageTrackLength DESC;



/* Q9: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT customer.customer_id, first_name, last_name, SUM(total) AS total_spending
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_spending DESC
LIMIT 1;





/* Q10: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */


SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;




/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album2 ON album2.album_id = track.album_id
JOIN artist ON artist.artist_id = album2.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;


/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT name,milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track )
ORDER BY milliseconds DESC;




/* Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */



WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album2 ON album2.album_id = track.album_id
	JOIN artist ON artist.artist_id = album2.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album2 alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;


/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */


/* Method 1: Using CTE */

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC 
)
SELECT * FROM popular_genre WHERE RowNo <= 1;


/* Method 2: : Using Recursive */

WITH RECURSIVE
	sales_per_country AS(
		SELECT COUNT(*) AS purchases_per_genre, customer.country, genre.name, genre.genre_id
		FROM invoice_line
		JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
		JOIN customer ON customer.customer_id = invoice.customer_id
		JOIN track ON track.track_id = invoice_line.track_id
		JOIN genre ON genre.genre_id = track.genre_id
		GROUP BY 2,3,4
		ORDER BY 2
	),
	max_genre_per_country AS (SELECT MAX(purchases_per_genre) AS max_genre_number, country
		FROM sales_per_country
		GROUP BY 2
		ORDER BY 2)

SELECT sales_per_country.* 
FROM sales_per_country
JOIN max_genre_per_country ON sales_per_country.country = max_genre_per_country.country
WHERE sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;


/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Method 1: using CTE */

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1;


/* Method 2: Using Recursive */

WITH RECURSIVE 
	customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 2,3 DESC),

	country_max_spending AS(
		SELECT billing_country,MAX(total_spending) AS max_spending
		FROM customter_with_country
		GROUP BY billing_country)

SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customter_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;


