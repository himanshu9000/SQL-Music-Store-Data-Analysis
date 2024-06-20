-- Set 1 

-- Q1: Who is the senior most employee based on job title? 

SELECT title, first_name , last_name
FROM employee
	ORDER BY levels DESC LIMIT 1 ;


-- Q2: Which countries have the most Invoices? 

SELECT  billing_country, COUNT(*) AS c
FROM invoice
	GROUP BY billing_country ORDER BY c DESC ;


-- Q3: What are top 3 values of total invoice? 

SELECT total 
FROM invoice
	ORDER BY total DESC 
		LIMIT 3;


-- Q4: Which city has the best customers? 
--     We would like to throw a promotional Music Festival in the city we made the most money.
--     Write a query that returns one city that has the highest sum of invoice totals. 
--	   Return both the city name & sum of all invoice totals.

SELECT billing_city, SUM(total) AS s
FROM invoice
	GROUP BY billing_city
		ORDER BY s DESC LIMIT 1;


-- Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
--	   Write a query that returns the person who has spent the most money.*/

SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS s
FROM customer c   INNER JOIN invoice i
				   ON c.customer_id = i.customer_id
						GROUP BY c.customer_id
							ORDER BY s DESC LIMIT 1;



-- SET 2

-- 1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
--	  Return your list ordered alphabetically by email starting with A

select distinct c.email , c.first_name , c.last_name , g.name
from customer c
	INNER JOIN invoice i  ON c.customer_id = i.customer_id
	INNER JOIN invoice_line il  ON  i.invoice_id = il.invoice_id
	INNER JOIN track t   ON  il.track_id = t.track_id
	INNER JOIN genre g   ON  t.genre_id = g.genre_id 
		where g.name = 'Rock'  
			order by c.email ; 


-- 2. Let's invite the artists who have written the most rock music in our dataset. 
--	  Write a query that returns the Artist name and total track count of the top 10 rock bands.

select a.name , count(a.artist_id) as total_songs
from artist a
	INNER JOIN album ab  ON a.artist_id = ab.artist_id
	INNER JOIN track t   ON t.album_id  = ab.album_id
	INNER JOIN genre g   ON t.genre_id = g.genre_id 
		where g.name = 'Rock' 
			group by a.name 
				order by total_songs desc Limit 10 ;


-- 3. Return all the track names that have a song length longer than the average song length. 
--    Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first

select name , milliseconds
from track 
	where milliseconds > ( select Avg(Milliseconds)
							 from track )
			order by milliseconds desc ;



-- Set 3

-- 1. Find how much amount spent by each customer on artists? Write a query to return customer name, 
--    artist name and total spent

WITH best_selling_artist AS ( SELECT a.artist_id AS artist_id, a.name AS artist_name, SUM(il.unit_price * il.quantity) AS total_sales
								FROM invoice_line il  
									INNER JOIN track t ON t.track_id = il.track_id
								    INNER JOIN album ab ON ab.album_id = t.album_id
								    INNER JOIN artist a ON a.artist_id = ab.artist_id
										GROUP BY 1
											ORDER BY total_sales DESC LIMIT 1
							 )
	
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice i
	INNER JOIN customer c ON c.customer_id = i.customer_id
	INNER JOIN invoice_line il ON il.invoice_id = i.invoice_id
	INNER JOIN track t ON t.track_id = il.track_id
	INNER JOIN album alb ON alb.album_id = t.album_id
	INNER JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
		GROUP BY 1,2,3,4
			ORDER BY amount_spent DESC;


-- 2. We want to find out the most popular music Genre for each country. We determine the most popular 
--	  genre as the genre with the highest amount of purchases. Write a query that returns each country 
--	  along with the top Genre. For countries where the maximum number of purchases is shared return all Genres


WITH popular_genre AS ( SELECT COUNT(il.quantity) AS purchases, c.country, g.name, g.genre_id, 
							ROW_NUMBER() OVER( PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC ) AS RN 
						    FROM invoice_line il
								INNER JOIN invoice i  ON i.invoice_id = il.invoice_id
								INNER JOIN customer c ON c.customer_id = i.customer_id
								INNER JOIN track t    ON t.track_id = il.track_id
								INNER JOIN genre g  ON g.genre_id = t.genre_id
									GROUP BY 2,3,4
										ORDER BY c.country , purchases DESC
						)
	
SELECT * 
FROM popular_genre 
	WHERE RN <= 1 ;


-- 3. Write a query that determines the customer that has spent the most on music for each country. 
--	  Write a query that returns the country along with the top customer and how much they spent. 
-- 	  For countries where the top amount spent is shared, provide all customers who spent this amount

WITH Customter_with_country AS ( SELECT c.customer_id, 
										 c.first_name , 
									     c.last_name , 
										 i.billing_country, 
										 SUM(i.total) AS total_spending,
	    								 ROW_NUMBER() OVER( PARTITION BY i.billing_country ORDER BY SUM(i.total) DESC ) AS RN 
								  FROM invoice i
									  INNER JOIN customer c  ON c.customer_id = i.customer_id
										  GROUP BY 1,2,3,4
											  ORDER BY total_spending , RN DESC
								)
	
SELECT * 
FROM Customter_with_country 
	WHERE RN <= 1 ;
